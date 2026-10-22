# Pixel Hop

Retro pixel game for iPhone and iPad that Patrick builds with his son. The son is the game designer: he decides what the game becomes, Claude turns his ideas into code. Swift 6, SwiftUI shell, RealityKit 3D world (iOS 18+), no dependencies.

## Working with the game designer

- Ideas come from a kid, usually in German, playful and vague ("der Frosch soll Feuer spucken"). Pick the most fun interpretation and make the smallest change that shows it in the game. Only ask back when an idea really can't be understood.
- Afterwards explain in one or two simple German sentences what changed and what to try in the game.
- One idea per PR, so each one can be tried on its own.
- Kid-friendly only: cartoon level, no ads, no in-app purchases, no tracking, no network, no accounts.
- Privacy: never put the child's name, photos, voice or other personal data into code, commits, PRs or screenshots.

## Code

- **World rules live in `WORLD.md`** (units, map characters, textures, voxel models, Hopper, camera). Read it before changing the world and keep it up to date.
- `PixelHop/PixelHopApp.swift` app entry, `PixelHop/GameView.swift` RealityView + HUD, `PixelHop/Game.swift` game state and per-frame logic, `PixelHop/Scenery.swift` materials, sky, shadow.
- World building blocks: `WorldMap.swift` (home island map + tile lookup), `WorldGen.swift` (rules for the infinite world), `Chunks.swift` (loads 16×16 chunks around Hopper), `Hash.swift`, `Residents.swift` + `Species.swift` + `Animals.swift` (inhabitants Hopper can talk to), `Adventure.swift` + `Quest.swift` + `Grummels.swift` + `Loot.swift` (errands, hearts and the monsters guarding the items), `Textures.swift` (block textures and `Block` catalog), `Models.swift` (props and voxel models from `VoxelModel`), `Nature.swift` (tree and rock variants), `Critters.swift` + `Life.swift` (birds, butterflies, fish, smoke and other things that move), `Cue.swift` + `Sounds.swift` (sound and vibration for every event, CC0 WAVs in `PixelHop/Sounds/`), `Terrain.swift` (map to mesh), `Atlas.swift` (single texture with baked face shading), `MeshBuilder.swift`, `Face.swift`.
- Pixel art is ASCII: one string per row, one character per pixel, characters are keys of `Palette.colors`, `.` is transparent. 2D HUD art lives in `Icons.swift` and is drawn with `PixelArt.image`.
- iPhone: landscape only. iPad: all orientations and resizable windows; RealityView and the SwiftUI HUD adapt on their own.
- Every file in `PixelHop/` is picked up automatically (synced folder). Never touch `project.pbxproj` to add files.
- Default actor isolation is `MainActor`. No code comments, match the surrounding style, small focused files.

## Pipeline

- Claude Code cloud runs on Linux without Xcode: you cannot build or run the app there. Work on a branch and open a PR; `.github/workflows/ci.yml` builds it on macOS, launches it in the iPhone simulator and prints screenshots as base64 JPEG between `SCREENSHOT-BEGIN <name>`/`SCREENSHOT-END <name>` in the job log (`start` at the home island, `village` via the launch argument `-screenshotStart x,z`). Decode and look at it before merging visual changes. If the check goes red, read the log and push a fix as a new commit.
- When the CI check is green, Claude merges the PR itself (squash, with a commit message so no trailer is added). `.github/workflows/testflight.yml` then archives, signs via the App Store Connect API key (cloud signing) and uploads to TestFlight. Build number = GitHub run number. It shows up in TestFlight about 20-30 min after the merge.
- Commits: conventional prefix (`feat:`, `fix:` ...), no `Co-Authored-By` or session trailers, no force push.
- Local: `open PixelHop.xcodeproj`, run on a simulator. Screenshots go to `__dev/`.
