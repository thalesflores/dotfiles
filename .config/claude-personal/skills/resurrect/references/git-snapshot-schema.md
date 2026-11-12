# git-snapshot.sh output shape

```json
{
  "worktrees": [{"path","branch","head"}],
  "branches":  [{"name","head","gone"}],
  "prs":       [{"number","title","branch","url","state"}],
  "recent_log":[{"branch","commits":[{"sha","subject"},...]}],
  "current_branch": "..."
}
```

`gone: true` means the remote branch is deleted (merged or closed). The script
runs `git fetch --prune` first, so this field is authoritative over anything the
planning files claim.
