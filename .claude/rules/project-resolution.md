# Project Resolution (paivot vault)

A session's project is the work it advances, not the folder it started in. PoC and customer work often starts in a shared repo such as `sedemo-platform`, so paivot's `[VAULT] Project: <repo>` line is only a hint.

- On the first substantive prompt, infer the project (customer or PoC names, existing `~/Claude/projects/*.md` notes) and confirm it in one line before using it. If nothing points away from the repo, the repo is the project.
- Read context from, capture into, and name the session after the resolved project. At session end, update that note's `status`, `next` and `updated_at`.
- Full convention: `vlt vault="Claude" read file="Project Resolution"`.
