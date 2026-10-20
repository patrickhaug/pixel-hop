# Pixel Hop

Retro pixel game for iPhone that Patrick builds with his son. The son is the game designer: he decides what the game becomes, Claude turns his ideas into code. Swift 6, SwiftUI shell, SpriteKit scene, no dependencies.

## Working with the game designer

- Ideas come from a kid, usually in German, playful and vague ("der Frosch soll Feuer spucken"). Pick the most fun interpretation and make the smallest change that shows it in the game. Only ask back when an idea really can't be understood.
- Afterwards explain in one or two simple German sentences what changed and what to try in the game.
- One idea per PR, so each one can be tried on its own.
- Kid-friendly only: cartoon level, no ads, no in-app purchases, no tracking, no network, no accounts.
- Privacy: never put the child's name, photos, voice or other personal data into code, commits, PRs or screenshots.

## Code

- `PixelHop/PixelHopApp.swift` app entry, `PixelHop/GameScene.swift` game logic, `PixelHop/Sprites.swift` palette and pixel art.
- Pixel art is ASCII: one string per row, one character per pixel, characters are keys of `Palette.colors`, `.` is transparent. New sprites are `texture([...])` in `Sprites`.
- World is 100 px high, width follows the screen aspect, origin bottom-left, ground top at `y = 20`. Landscape, iPhone only.
- Every file in `PixelHop/` is picked up automatically (synced folder). Never touch `project.pbxproj` to add files.
- Default actor isolation is `MainActor`. No code comments, match the surrounding style, small focused files.

## Pipeline

- Claude Code cloud runs on Linux without Xcode: you cannot build or run the app there. Work on a branch and open a PR; `.github/workflows/ci.yml` builds it on macOS. If the check goes red, read the log and push a fix as a new commit.
- Patrick merges the PR. `.github/workflows/testflight.yml` then archives, signs via the App Store Connect API key (cloud signing) and uploads to TestFlight. Build number = GitHub run number. It shows up in TestFlight about 20-30 min after the merge.
- Commits: conventional prefix (`feat:`, `fix:` ...), no `Co-Authored-By` or session trailers, no force push.
- Local: `open PixelHop.xcodeproj`, run on a simulator. Screenshots go to `__dev/`.
