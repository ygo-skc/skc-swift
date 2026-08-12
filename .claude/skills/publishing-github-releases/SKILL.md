---
name: publishing-github-releases
description: Use when cutting a release — creating a version tag, drafting or publishing a GitHub release, or writing a release body with the gh CLI.
---

# Publishing GitHub Releases

## Overview

**The previous release is the spec.** Every repo has a house style for release bodies, and it is already written down — in the last release. Read it before writing a line of the new one.

Maintainer release notes are a different artifact from app store "What's New" text. A repo often ships both from the same tag, and they share no wording. **RELATED SKILL:** use `writing-release-notes` for the store-facing version.

## Recon: Run This First

```sh
git describe --tags --abbrev=0        # last shipped tag
gh release view <last-tag>            # THE STYLE SPEC
gh release list --limit 5             # title convention
git cat-file -t <last-tag>            # 'commit' = lightweight, 'tag' = annotated
git status --porcelain                # uncommitted work that would miss the tag
git rev-parse HEAD @{u}               # is local ahead of the remote?
```

Extract and match:

| Convention | Where it shows |
|---|---|
| Title format (`v1.2.3: Descriptive Title`) | `gh release list` |
| Section headings and their order | previous body |
| Technical depth — type names or plain prose | previous body |
| Trailing compare link | last line of previous body |
| Tag object type | `git cat-file -t` |
| Draft-then-publish habit | `created` vs `published` differing in `gh release view` |

## Creating It

1. Confirm the version was bumped and HEAD is pushed — tag what the remote has, not local-only commits.
2. Write the body to a file, in the previous release's shape.
3. Tag the exact commit, matching the existing object type, and push:
   ```sh
   git tag v1.2.3 <sha> && git push origin v1.2.3
   ```
4. Create the release:
   ```sh
   gh release create v1.2.3 --draft --verify-tag \
     --title "v1.2.3: …" --notes-file notes.md --generate-notes
   ```

`--generate-notes` appends the `**Full Changelog**` compare link, matching earlier releases without hand-writing the URL. `--verify-tag` fails loudly rather than inventing a tag.

## Draft by Default

Publishing notifies watchers and is awkward to walk back; a draft costs one command to promote:

```sh
gh release publish v1.2.3
```

Publish directly only when the repo's history shows `created` == `published`, or the user says to.

The tag push in step 3 is immediately public even while the release stays a draft. Say so when reporting.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Reusing store "What's New" prose as the release body | Different audience — match the previous release |
| Writing notes from `git log --oneline` | Read the diffs; see `writing-release-notes` |
| Tagging a stale HEAD | Re-check `git status` and `@{u}` — the tree may have moved mid-session |
| Hand-writing the compare URL | `--generate-notes` |
| Annotated tag in a repo of lightweight ones | Match `git cat-file -t` |
| Sweeping unrelated uncommitted files into the release | Tag the app state; tooling commits go separately |
