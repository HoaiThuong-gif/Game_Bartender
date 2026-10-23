"""Object masks from real images; MobileSAM Apache-2.0, never generates geometry."""
from pathlib import Path
import argparse
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / '.scan-runtime/mobilesam'), str(ROOT / '.scan-runtime/segmentation-deps')]


def segment(directory: Path):
    import cv2
    import numpy as np
    import torch
    from mobile_sam import sam_model_registry, SamPredictor

    torch.set_num_threads(4)
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    model = sam_model_registry['vit_t'](checkpoint=str(ROOT / '.scan-runtime/mobilesam/mobile_sam.pt'))
    predictor = SamPredictor(model.to(device).eval())
    frames = json.loads((directory / 'manifest.json').read_text('utf-8'))['frames']
    output = directory / 'object_masks'
    output.mkdir(exist_ok=True)
    previous_gray = previous_mask = None
    accepted = []
    for index, frame in enumerate(frames):
        image = cv2.imread(str(directory / 'images' / frame['name']))
        if image is None:
            raise ValueError('Cannot read captured image')
        h, w = image.shape[:2]
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        predicted = previous_mask
        if previous_gray is not None:
            points = cv2.goodFeaturesToTrack(previous_gray, 200, .01, 5, mask=previous_mask)
            if points is not None and len(points) >= 6:
                tracked, status, _ = cv2.calcOpticalFlowPyrLK(previous_gray, gray, points, None)
                good = status.ravel() == 1
                if good.sum() >= 6:
                    transform, _ = cv2.estimateAffinePartial2D(points[good], tracked[good], method=cv2.RANSAC)
                    if transform is not None:
                        predicted = cv2.warpAffine(previous_mask, transform, (w, h))
        with torch.inference_mode():
            predictor.set_image(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
            if predicted is None:
                masks, scores, _ = predictor.predict(point_coords=np.array([[w*.5, h*.5]]),
                    point_labels=np.array([1]), multimask_output=True)
            else:
                ys, xs = np.where(predicted > 0)
                if len(xs) < 100:
                    raise ValueError('Object tracking lost; keep the whole object in view')
                box = np.array([xs.min(), ys.min(), xs.max(), ys.max()])
                masks, scores, _ = predictor.predict(box=box, multimask_output=True)
                center_masks, center_scores, _ = predictor.predict(
                    point_coords=np.array([[w*.5, h*.5]]), point_labels=np.array([1]), multimask_output=True)
                masks = np.concatenate([masks, center_masks])
                scores = np.concatenate([scores, center_scores])
        candidates = []
        for mask, score in zip(masks, scores):
            area = float(mask.mean())
            if not .02 < area < .65 or score < .85:
                continue
            if predicted is not None and not .5 < area / max(.001, float((predicted > 0).mean())) < 1.6:
                continue
            if predicted is None:
                rank = float(score) - .1*area
            else:
                overlap = (mask & (predicted > 0)).sum() / max(1, (mask | (predicted > 0)).sum())
                if overlap < .35:continue
                rank = float(score) + .6*overlap - .2*abs(area-float((predicted>0).mean()))
            if mask[:3].any() or mask[-3:].any() or mask[:,:3].any() or mask[:,-3:].any():
                continue
            candidates.append((rank, mask))
        if not candidates:
            cv2.imwrite(str(output / (frame['name'] + '.png')), np.zeros((h,w),np.uint8))
            print(json.dumps({'frame':index+1,'rejected':'uncertain silhouette'}),flush=True)
            continue
        mask = max(candidates, key=lambda item: item[0])[1].astype(np.uint8)
        # Close only small holes; preserve silhouette and never create a 3D surface here.
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
        cv2.imwrite(str(output / (frame['name'] + '.png')), mask * 255)
        previous_gray, previous_mask = gray, mask * 255
        accepted.append(frame['name'])
        print(json.dumps({'frame': index+1, 'total': len(frames), 'area': float(mask.mean())}), flush=True)
    if len(accepted) < 30:
        raise ValueError('Fewer than 30 usable object silhouettes; keep object still and centered')
    (output / 'engine.json').write_text(json.dumps({'engine': 'MobileSAM', 'version':3, 'frames': accepted}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=Path)
    segment(parser.parse_args().directory.resolve())
