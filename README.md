# Pixel Hop

Retro pixel game for iPhone and iPad. Idea → Claude Code (cloud) → PR → merge → TestFlight.

## One-time setup

1. **App ID**: developer.apple.com → Certificates, IDs & Profiles → Identifiers → `+` → App ID `dev.patrickhaug.pixelhop`.
2. **App**: App Store Connect → Apps → `+` → New App, bundle ID from step 1, any unique name (e.g. "Pixel Hop Haug", can change later).
3. **API key**: App Store Connect → Users and Access → Integrations → App Store Connect API → `+`, role **Admin** (cloud signing creates the distribution certificate). Download the `.p8` once.
4. **GitHub secrets** (repo → Settings → Secrets and variables → Actions):
   - `ASC_KEY_ID` key ID
   - `ASC_ISSUER_ID` issuer ID (top of the API keys page)
   - `ASC_KEY_P8` full content of the `.p8` file
   - `APPLE_TEAM_ID` developer.apple.com → Membership
5. **TestFlight**: App Store Connect → the app → TestFlight → internal group with yourself, so new builds install automatically.
6. **Claude Code cloud**: claude.ai/code → connect the GitHub repo `pixel-hop`.

## Daily flow

1. Open Claude (app or claude.ai/code) on the `pixel-hop` repo and tell it the idea, typed or dictated.
2. Claude opens a PR, CI builds it.
3. Merge the PR (GitHub app is enough), about 20-30 min later the build is in TestFlight.

## Costs

GitHub Actions macOS runners are free for public repos. In a private repo the free minutes cover roughly 15-20 builds per month.
