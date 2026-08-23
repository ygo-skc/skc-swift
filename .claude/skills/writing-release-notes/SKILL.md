---
name: writing-release-notes
description: Use when preparing an app release and you need user-facing release notes, "What's New" text, or a changelog for the App Store, Play Store, or TestFlight from git history since the last tag.
---

# Writing Release Notes

## Overview

Commit messages name a change for maintainers. Release notes name the **symptom** for users. Translating between the two is the whole job — a release note is never a paraphrased commit subject.

Users see about three lines before "more" in the App Store. Front-load accordingly.

## The Output Contract

Release notes are **2–4 short paragraphs of plain prose, 60–120 words total**, in this order:

1. **The headline change** — what a user notices first when they open the app
2. **What feels faster or smoother** — only if they would actually feel it
3. **Fixes, named by symptom** — what the user saw going wrong
4. **A one-line sweep** of minor leftovers (optional)

Each paragraph is one unbroken line; the store wraps text itself, so manual line breaks arrive as ragged text. Describe features with the words a user would use for them.

Deliver it in a fenced code block in chat, ready to paste. Write a file only when asked.

## Gathering Evidence

```sh
git describe --tags --abbrev=0          # last shipped tag
git log <tag>..HEAD --oneline
git diff <tag>..HEAD --stat
```

Then **read the diffs** for every file on a user-visible path — screens, views, navigation, network. Commit subjects name intent for maintainers ("Custom hash funcs to avoid parsing huge objects") and describe felt and unfelt changes in identical language. The subject alone cannot tell you which you have.

## What Earns a Line

The test: **could a user notice this without being told?**

| Found in the diff | The line it earns |
|---|---|
| Modal sheet replaced by inline content plus a pushed screen | "See X without digging for it" |
| A shared client now rebuilt when its connection dies | "X kept failing after a network drop until you force quit — now it recovers on its own" |
| `max(0, …)` guarding a size calculation | "Fixed a crash on very narrow screens" |
| Caching, lazy loading, cheaper hashing, fewer redraws | Folded into one "faster and smoother" clause — rarely its own line |
| Refactors, renames, dependency bumps, test and preview fixes | Nothing — leave them out |

Fixes get **symptom-first** phrasing: name what the user saw, not the mechanism. That phrasing also tells anyone who hit the bug that updating is worth it.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Paraphrasing commit subjects | Read the diff, describe the effect |
| `### Added` / `### Fixed` sections, version numbers, dependency bumps | That is a maintainer `CHANGELOG.md` — a different artifact from store notes |
| Naming internal types or screens by their code names | Use the label the user sees on screen |
| Hard-wrapping paragraphs | One unbroken line each |
| Writing a file unprompted | Output in chat; the user is pasting it |

## Before Handing It Off

Check that `MARKETING_VERSION` was bumped in `SKCSwift.xcodeproj/project.pbxproj` (`CURRENT_PROJECT_VERSION` moves with it) and whether the release tag exists yet — tags are `vX.Y.Z`, and the default branch is `release`. Report what is missing rather than tagging or committing unasked.
