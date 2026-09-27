# Evertrail

Evertrail is an original mobile-first top-down action-RPG prototype built in Godot 4.x.

Set within the broader Chronicle Clash universe, Evertrail focuses on exploration, combat, stealth, world navigation, and location-based adventure systems.

Current direction:

- top-down real-time action gameplay
- world map and region map travel
- towns, villages, interiors, and explorable locations
- combat, stealth, and enemy encounters
- day/night presentation and living environments
- expandable RPG systems for future development

## Run

1. Open Godot 4.x (CI builds with Godot 4.3).
2. Choose **Import**, select this folder's `project.godot`, then **Import & Edit**.
3. Press **F5** or the **Run Project** button. The main scene is `scenes/main.tscn`.

No external dependencies or copyrighted game assets. Placeholder visuals are drawn procedurally, and sound effects are synthesized at runtime.

## Controls

Input bindings are registered at runtime in `scripts/main.gd` (the `[input]` actions in `project.godot` have no default events).

| Action | Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Move | WASD / arrow keys | Left stick | Joystick (lower-left area) |
| Sword | J / Space | South button (A) | SWORD |
| Shield (hold) | K | East button (B) | SHIELD |
| Item 1 / Item 2 | U / I | West (X) / North (Y) | ITEM 1 / ITEM 2 |
| Swap items | Q / Tab | Left shoulder | SWAP |
| Restart after defeat | R / Enter | — | Tap anywhere |

Default items are a bow (limited arrows) and a returning boomerang. Break crates and defeat enemies to find pickups.

## Web build

Every push to `main` runs `.github/workflows/deploy.yml`, which exports the `Web` preset from `export_presets.cfg` to `build/web/index.html` and deploys it to GitHub Pages.

## Android export

There is no Android preset yet. In Godot: **Project → Export → Add… → Android**, install the Android build template if prompted, then export an APK. The project uses the mobile-compatible GL Compatibility renderer and a 1280×720 viewport with `canvas_items` stretch.

Note: `display/window/handheld/orientation` in `project.godot` is currently `1` (portrait). Set it to landscape before shipping an Android build.

## Project layout

- `scenes/main.tscn`: main scene (root node runs `scripts/main.gd`)
- `scripts/main.gd`: test arena, wave flow, input bindings
- `scripts/player.gd`: movement, shield, damage, hit feedback, camera
- `scripts/weapon_controller.gd`: sword combo and item use
- `scripts/projectile.gd`: arrows and returning boomerang
- `scripts/enemy.gd`: reusable wander/chase/windup/recover AI
- `scripts/inventory.gd`: loadout, swapping, ammo
- `scripts/mobile_controls.gd` / `touch_surface.gd`: multitouch controls
- `scripts/hud.gd`: health, items, prompts, defeat UI
- `scripts/interactable.gd` / `pickup.gd`: breakable crates and pickups
- `scripts/sound_manager.gd`: lightweight generated effects
- `scripts/game_bus.gd`: shared sound-effect access

## Gameplay Vision

Evertrail is being developed toward an original fantasy action-RPG experience with world exploration, region-based travel, combat, stealth, towns, interiors, and expandable adventure systems.

See [docs/GAMEPLAY_VISION.md](docs/GAMEPLAY_VISION.md) for the visual direction.
