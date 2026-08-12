---
name: writing-release-promos
description: Use when writing social or marketing copy for an app release — a launch post for X/Bluesky/Mastodon, an announcement blurb, or store promotional text.
---

# Writing Release Promos

## Overview

Promo copy is published publicly under someone else's name. **Every factual claim in it must be verified or cut** — a wrong price is not a typo, it is a false statement to consumers who may act on it.

The release note answers *what changed*. The promo answers *why open the app*. **RELATED SKILLS:** `writing-release-notes` for store text, `publishing-github-releases` for the tag.

## Verify Before Writing

These are never safe to infer, however conventional they sound in app marketing:

| Claim | How to establish it |
|---|---|
| Price — "free", "one-time purchase", "no subscription" | Ask the user, or read the live store listing. App marketing copy defaults to "free" so strongly that it gets typed automatically — it is the single most likely fabrication |
| Ratings, install counts, "#1", "most popular" | Ask. Cut if unavailable |
| Platform support (iOS / iPadOS / Mac / Android) | Deployment targets and destinations in the project file |
| Store URL, handle, brand name | Grep the repo — README, `.github/settings.yml`, fastlane config |
| What the release actually does | The diff, not the commit subjects |

Write around anything unverifiable. "On the App Store" is true regardless of price; "Free on iOS" is a coin flip.

Once the price is confirmed, decide whether to state it. A low one-time price is a conversion asset — name it, and name the absence of a subscription, since subscription fatigue is the usual reason people bounce off paid utility apps. Tiers, trials and IAP are the opposite: leave them to the store page rather than spending post copy explaining them. Store prices are localized, so a bare `$` figure is the US tier — fine unless the audience skews elsewhere.

## What Goes In

Hook → the one change that makes someone open the app → link.

| Include | Leave out |
|---|---|
| The single most visible new capability | Bug fixes — advertising a defect to people who never hit it |
| A concrete moment the user recognizes | Performance work on its own: it retains users, it does not convert them |
| The community's own vocabulary for the feature | Internal type names, screen names, version numbers |

Lead with a reason to open the app. "Faster" is not one.

## Platform Mechanics

- Posts carrying external links are down-ranked on X. Keep the body link-free and put the link in the first reply.
- URLs count as 23 characters on X no matter their length. Budget against 280 with that substitution.
- Line breaks inside a post are deliberate formatting and are preserved — unlike store notes, which must not be hand-wrapped.

## Deliver a Recommendation

Ship **one** recommended post. Add alternates only when the angle is genuinely contested, and name which you would post and why. A menu with no recommendation hands the decision back to the person who asked for copy.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Stating a price nobody confirmed | Ask, or use pricing-neutral wording |
| Link in the post body on X | Body link-free, link in reply one |
| Leading with speed or stability | Lead with the capability that is new |
| Promoting a bug fix | Belongs in release notes, not a promo |
| Three options and no opinion | Recommend one, justify it briefly |
