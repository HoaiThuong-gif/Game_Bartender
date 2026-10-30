"""Geometry regression tests; uses the same isolated runtime as scan_server."""
import importlib.util
from pathlib import Path
from types import SimpleNamespace
import unittest

import cv2
import numpy as np
import open3d as o3d

spec = importlib.util.spec_from_file_location('scan_server', Path(__file__).with_name('scan_server.py'))
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)
engine.np, engine.o3d, engine.cv2 = np, o3d, cv2


class ReconstructionTests(unittest.TestCase):
    def trajectory(self):
        angle = np.linspace(0, 2*np.pi, 48, endpoint=False)
        centers = np.column_stack((np.cos(angle), .2*np.sin(2*angle), np.sin(angle)))
        rotation = np.array([[0., -1, 0], [1, 0, 0], [0, 0, 1]])
        views, frames = [], {}
        for i, center in enumerate(centers):
            pose = np.column_stack((np.eye(3), -center))
            name = f'{i}.jpg'
            views.append(dict(center=center, pose=pose, image=SimpleNamespace(name=name)))
            ar = np.eye(4)
            ar[:3, :3] = rotation @ np.diag([1, -1, -1])
            ar[:3, 3] = rotation @ center * .4 + [1, 2, 3]
            frames[name] = dict(pose=ar.flatten(order='F').tolist())
        return views, frames, rotation

    def test_metric_scale_and_camera_conventions(self):
        views, frames, expected = self.trajectory()
        rotation, scale = engine.metric_alignment(views, frames)
        np.testing.assert_allclose(rotation, expected, atol=1e-10)
        self.assertAlmostEqual(scale, .4)

    def test_wrong_camera_axes_rejected_even_with_matching_centers(self):
        views, frames, _ = self.trajectory()
        for frame in frames.values():
            ar = np.asarray(frame['pose']).reshape(4, 4, order='F').copy()
            ar[:3, :3] = np.eye(3)
            frame['pose'] = ar.flatten(order='F').tolist()
        with self.assertRaisesRegex(ValueError, 'Huong camera'):
            engine.metric_alignment(views, frames)

    def test_stationary_camera_does_not_produce_metric_scale(self):
        views, frames, _ = self.trajectory()
        for view in views:
            view['center'] = np.zeros(3)
        with self.assertRaises(ValueError):
            engine.metric_alignment(views, frames)

    def test_refined_triangle_bridging_unmeasured_gap_is_removed(self):
        vertices = np.array([[0., 0, 0], [1, 0, 0], [0, 1, 0]])
        mesh = o3d.geometry.TriangleMesh(o3d.utility.Vector3dVector(vertices),
                                        o3d.utility.Vector3iVector([[0, 1, 2]]))
        cloud = o3d.geometry.PointCloud(o3d.utility.Vector3dVector(vertices))
        engine.filter_dense_support(mesh, cloud, .05)
        self.assertEqual(len(mesh.triangles), 0)

    def test_measured_surface_survives_support_filter(self):
        mesh = o3d.geometry.TriangleMesh.create_sphere(radius=.1, resolution=15)
        cloud = mesh.sample_points_uniformly(20000)
        count = len(mesh.triangles)
        engine.filter_dense_support(mesh, cloud, .01)
        self.assertEqual(len(mesh.triangles), count)
        self.assertTrue(engine.mesh_quality(mesh)['acceptable'])

    def test_intersecting_shells_are_not_acceptable(self):
        mesh = o3d.geometry.TriangleMesh.create_sphere(resolution=15)
        other = o3d.geometry.TriangleMesh.create_sphere(resolution=15).translate([.5, 0, 0])
        self.assertFalse(engine.mesh_quality(mesh + other)['acceptable'])


if __name__ == '__main__':
    unittest.main()
