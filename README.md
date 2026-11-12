# MY TOMORROW — VALORA

A mobile-first, offline 3D life-simulation project set in a fictional English-inspired European town around the year 2000.

## Current milestone: 0.2.0 — daily life systems

- Small walkable town with a town hall, library, cafe, shop and home.
- Third-person player movement.
- Touch controls for Android and keyboard controls for desktop testing.
- First objective: visit the town hall and interact to receive 12 Valora Crowns (VC).\n- In-game clock and day counter, with a changing sun intensity.\n- Hunger and energy needs that gradually decrease.\n- Cafe and shop purchases; rest at home; study at the library.\n- Automatic local save/load for money, needs, day/time, quest state and player position.
- No account, network connection, ads or paid services.

## Engine and target

- Godot 4.3 stable
- 3D, GL Compatibility renderer for broad mobile support
- Android landscape, arm64-v8a
- Android export preset: `Android`

## Controls

| Action | Keyboard | Touch |
|---|---|---|
| Move | WASD / arrows | Direction buttons |
| Jump | Space | پرش |
| Interact | E | تعامل |

## Build locally

1. Install Godot 4.3 stable and its matching export templates.
2. Install Android Studio command-line SDK tools, Android platform 34, and a compatible JDK 17.
3. Configure Android SDK and Java paths in Godot Editor Settings → Export → Android.
4. Open this folder in Godot and run the project.
5. Export using the Android preset.

## Automated Android build

Every push to `main` or pull request runs the workflow in `.github/workflows/android-apk.yml`. A successful run uploads `MY-TOMORROW-Android-APK` as a downloadable artifact.

## Project structure

- `project.godot` — project and input configuration
- `scenes/main.tscn` — main scene
- `scripts/main.gd` — town, HUD, daily needs, economy, interactions, save/load and first quest
- `scripts/player.gd` — player movement
- `export_presets.cfg` — Android export configuration

## Status and verification

This is the clean-source foundation. The first GitHub Actions run is the authoritative check for GDScript parsing and Android export. Do not treat an APK as ready until the workflow has completed and the artifact has been downloaded and installed on a device.
