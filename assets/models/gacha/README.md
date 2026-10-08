# Gacha Android 3D benchmark

Place one self-contained GLB here: `test_item.glb`.
All prototype rewards intentionally share this one benchmark model.
The asset directory is declared in `pubspec.yaml`. The GLB must exist on disk
before building; missing assets show a friendly fallback.
After adding/replacing the GLB, rebuild/restart the app to update the asset bundle.
Prefer an uncompressed GLB with embedded textures and no external resources for
the first offline benchmark (Draco/KTX2 decoders can require additional files).

Enable USB debugging, connect an Android phone and run `flutter devices`.
First run `flutter run -d <device-id>` to check the debug-only `[Gacha3D]` logs:
mount and GLB path after revealing; remove/dispose on Lobby or a new ticket;
fresh mount when returning to the revealed result. There is no preload when
launching the app, opening Gacha, drawing a ticket, or partially tearing it.

Then run on that phone in profile mode: `flutter run --profile -d <device-id>`.
Debug logs are disabled in profile/release mode.
Open Gacha from the app's bottom navigation. Measure memory before entering Gacha,
after revealing a ticket, while rotating, after drawing another ticket, and after
switching back to Lobby. Switching tabs keeps the ticket result but unmounts the
viewer; returning to a revealed result creates a fresh viewer. Repeat several times.
Swipe horizontally until at least 65% of the ticket is torn, then scroll below
the reward board to see the viewer. Only manual rotation is enabled; AR,
auto-rotation, animation playback and shadows are disabled.
Record device/WebView versions, GLB size, triangle count, texture dimensions,
load time, Flutter DevTools memory and Android process/GPU memory. Dart heap alone
does not include all WebView/GPU allocations.
