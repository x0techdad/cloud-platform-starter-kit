# PowerShell Guidance

> **Note:** this documentation is a work-in-progress - if you see something that's not quite right or missing, we'd really appreciate a PR!

---

## Naming Conventions

### Variables

* Use `camelCase`
* Short but descriptive (<25 characters)
* Avoid special characters and spaces

### Functions and cmdlet

* Use `verb-noun` format and `camelCase` when multiple nouns are required : `get-childItem`.
* Use [approved verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.3) when naming functions or cmdlets.

## Best practices

* https://social.technet.microsoft.com/wiki/contents/articles/25024.best-practice-to-write-powershell-scripts.aspx

> **To Do:** compile community and own best practices on this doc.