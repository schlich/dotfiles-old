# JJ workflow

`jj-ci` is the general JJ-first publication flow. It installs from this flake
with `prek` and `gh-stack`. Prek runs explicitly during validation because JJ
changes do not invoke Git hooks.

```nu
# Inspect the local JJ change and open PRs.
jj-ci status

# Advance main and update an empty working copy to origin/main.
jj-ci sync

# Run deterministic local formatting and evaluation gates.
jj-ci validate

# Describe the current JJ change if needed, create/update its PR, and enable auto-merge.
jj-ci publish --auto-merge

# Inspect GitHub settings, then explicitly reconcile safe repository defaults.
jj-ci github reconcile
jj-ci github reconcile --apply
```

`jj-ci publish` names publication bookmarks as
`trunk/<descriptive-change-title>-<change-id>`. The stable change-ID suffix
prevents collisions while the title makes PR branches identifiable.
For an ad hoc publication from a change based on `main`, use
`jj git push --change @`. Jujutsu creates and pushes its configured
`trunk/<change-id>` bookmark instead of updating `main`; use
`jj-ci publish --auto-merge` when the matching pull request should be created
and queued automatically.

Use JJ for all change, bookmark, rebase, and push operations. Git is for
read-only interoperability only. GitHub owns required checks, merge queues, and
delivery to `main`.

Publishing finishes the current changeset and starts an empty child changeset
for follow-up work. Later edits therefore do not rewrite the pushed revision.
To intentionally update an already published PR, explicitly return to that
changeset before publishing it again.

`jj-ci validate` and `jj-ci publish` invoke `jj-describe` automatically when a
non-empty current change has no description. The command stops if the helper
does not add a subject.

For an explicitly planned dependency stack, create and push the ordered JJ
bookmarks, link the existing PRs with `gh stack link`, inspect with
`gh stack view --json`, and submit the fully green stack with:

```nu
jj-ci stack-merge <stack-or-pr>
```

Do not use `gh stack init`, `add`, `submit`, `sync`, or `rebase`: those commands
mutate Git-managed branches and bypass the JJ ownership boundary.
