# Chronicle Clash: Combat Grounds

A small, original, mobile-first top-down action-RPG combat prototype for Godot 4.x.

## Run

1. Open Godot 4.x.
2. Choose **Import**, select this folder's `project.godot`, then **Import & Edit**.
3. Press **F6/F5** or the **Run Project** button.

The project contains no external dependencies or copyrighted game assets. All placeholder visuals are drawn procedurally, and sound effects are synthesized at runtime.

## Controls

- Move: WASD / arrow keys / left stick / left-side touch joystick
- Sword: J, Space, gamepad south button, or SWORD touch button
- Shield: hold K, gamepad east button, or SHIELD touch button
- Item 1 / Item 2: U / I, gamepad west/north, or their touch buttons
- Swap equipped items: Q, Tab, left shoulder, or SWAP touch button
- Restart after defeat: R, Enter, or tap anywhere

Default items are bow (limited arrows) and returning boomerang. Break crates and defeat enemies to find pickups.

## Android export

In Godot: **Project → Export → Add Android**, install the Android build template if prompted, choose landscape orientation, then export an APK. The project already uses the mobile-compatible GL renderer and a 1280×720 landscape viewport.

## Project layout

- `scripts/player.gd` — movement, shield, damage, hit feedback, camera
- `scripts/weapon_controller.gd` — sword combo and item use
- `scripts/projectile.gd` — arrows and returning boomerang
- `scripts/enemy.gd` — reusable chase/windup/recover AI
- `scripts/inventory.gd` — loadout, swapping, ammo
- `scripts/mobile_controls.gd` / `touch_surface.gd` — multitouch controls
- `scripts/hud.gd` — health, items, prompts, defeat UI
- `scripts/interactable.gd` / `pickup.gd` — world interaction and rewards
- `scripts/sound_manager.gd` — lightweight generated effects
- `scripts/main.gd` — test arena composition and wave flow
