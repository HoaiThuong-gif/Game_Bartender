# Rubik: camera input (Android)

## UI and navigation

The main Rubik screen retains the existing interactive WebView on a full dark
background. Two equal-width text buttons sit in the bottom safe area: GIẢI RUBIK
and THÁCH ĐẤU. There are no mode cards or decorative icons on this screen.
Challenge still opens the existing development placeholder.

GIẢI RUBIK offers camera input and the unchanged manual input screen. Camera
input captures faces in the existing URFDLB order. Each capture displays the
sampled image region and an editable 3x3 color result. The user can retake, edit
any sticker (including a misclassified center), and confirm. Wrong centers and
missing colors block confirmation. Confirmed faces can be revisited. All six
faces appear on a final review screen with per-color counts before solving.

## Shared state and solver

Camera → RubikColorDetector → reviewed colors → RubikScanController/CubeState
→ CubeInputController.load/solve → CubeValidationService → RubikSolverService
(existing cuber 0.4.0) → existing SolutionScreen.

There is no second cube model, solver, color mapping, or 3D renderer. The scan
controller only tracks confirmed faces and constructs the existing immutable
CubeState. Existing validation enforces 54 stickers, fixed distinct centers,
nine of each color, and cuber's cubie/orientation/parity checks. Invalid data
stays on review with an error, editable faces and per-color counts. Physically
impossible data cannot reliably be attributed to a particular face, so its
error asks the user to check orientation instead of inventing a culprit.

Hold the requested center facing the camera and the indicated neighboring
center above it. For U, B is above; for D, F is above; other faces have U above.
Turn the whole cube between captures, without twisting individual layers.
The existing fixed color scheme is required: U white, R red, F green, D yellow,
L orange, B blue.

## Detection

- Capture a still JPEG only on a button press; no image-stream detection.
- Decode and bake EXIF orientation, then limit the longest image edge to 1280.
- Match the centered preview aspect ratio and use a square occupying 82% of
  its shorter side. Overlay and detector share the same fraction.
- Read 225 samples (15×15) across the central half of each sticker to avoid
  seams. Use the per-channel median RGB and convert it to HSV.
- Classify white by low saturation and chromatic colors by hue ranges. Very
  dark or unsupported hues remain unknown. Sparse glare has less influence
  on the median than on a single pixel or arithmetic mean.
- Mark uncertain cells when samples disagree, brightness is low, saturation
  is borderline, or hue is close to a classification boundary. These flags
  are heuristics, not calibrated accuracy probabilities.
- Display the exact sampled crop alongside the editable result. The user
  must confirm every face; unknown colors cannot be confirmed.

Decoding, sampling and thumbnail encoding run in an isolate. No server, ML,
OpenCV, contour detection or automatic perspective correction is used.

## Packages and camera resources

- [camera 0.12.1](https://pub.dev/packages/camera): maintained by flutter.dev;
  native preview, still capture and runtime permission handling. Uses the
  endorsed CameraX Android implementation.
- [image 4.10.1](https://pub.dev/packages/image): Dart JPEG decoding, EXIF
  orientation, cropping and pixel sampling.

Both were published recently when checked for this change. Exact transitive
versions are recorded in pubspec.lock. Camera requires Android SDK 24+, which
matches this project's Flutter minimum SDK (24).

AndroidManifest declares CAMERA and marks camera hardware optional so manual
input remains available on devices without a rear camera. Audio is disabled;
no microphone permission is requested by this flow. The native plugin handles
the runtime camera prompt. Denial shows a Settings explanation and retry.

Native open/capture/close operations are serialized. The screen releases the
camera when backgrounded, reviewing a capture, showing final review, or leaving.
On resume it opens only if a live preview is needed. Capture generation tokens
discard stale results after leaving or backgrounding. Temporary captures are
deleted after reading; images are not uploaded or saved to the gallery.

## Verification and remaining device checks

`flutter analyze`: no issues. `flutter test`: 30 tests passed, including six new
camera tests and the existing manual input, validation, solver, orientation,
preview bridge and solution tests.

New tests use generated JPEGs and a fake camera. They exercise asymmetric
row/column order, EXIF rotation, sparse glare, dark/invalid input, fixed centers,
color counts, six detected scrambled faces through the real solver, denied
permission/retry, background/resume/disposal, retake, editing and the existing
solution route. They do not measure recognition accuracy on real photographs.

Android debug ARM64 build command:

```sh
flutter build apk --debug --target-platform android-arm64
```

Artifact: `build/app/outputs/flutter-apk/app-debug.apk`.

The available emulator reported `offline`; no on-device camera or visual test
was performed. This is an implemented fixed-grid recognition first version,
not a validated automatic scanner. Test on a physical Android phone:

1. Camera permission allow/deny and re-enable in Settings; app background,
   screen lock, resume, leaving while capturing, and repeated entry/exit.
2. Portrait capture and EXIF rotation; verify the sampled thumbnail matches
   the overlay. Preview/JPEG fields of view can vary across camera devices;
   matching their aspect ratios assumes centered crops, not calibrated optics.
3. Six faces under neutral indoor light, daylight and warm light. Check red
   versus orange, white versus reflections, shadows, faded/nonstandard stickers.
4. Correct/retake a face, review previous faces, reject invalid colors/counts,
   and solve a real scrambled cube through the existing guide.
5. Verify manual input and main-screen 3D drag/pinch performance still work.

Keep the cube face frontal and aligned to the overlay. Strong perspective,
motion blur, glare, unusual color schemes and automatic white balance can
misclassify colors; manual correction remains necessary. No real-world accuracy
percentage is claimed. This project currently has no iOS target configuration.

## Files

Modified:

- `lib/games/rubik/screens/rubik_screen.dart`
- `lib/games/rubik/screens/rubik_solver_screen.dart`
- `pubspec.yaml`
- `pubspec.lock`
- `android/app/src/main/AndroidManifest.xml`

Created:

- `lib/games/rubik/screens/rubik_scan_screen.dart`
- `lib/games/rubik/controllers/rubik_scan_controller.dart`
- `lib/games/rubik/services/rubik_camera_service.dart`
- `lib/games/rubik/services/rubik_color_detector.dart`
- `lib/games/rubik/widgets/rubik_scan_preview.dart`
- `lib/games/rubik/widgets/rubik_scan_face_grid.dart`
- `test/rubik_scan_test.dart`
- `docs/rubik-camera.md`
