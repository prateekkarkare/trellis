# Contributing to Trellis

Thanks for being here. This is a framework intended to outlive any specific tool, so the contribution bar is "does this make the framework simpler, more durable, or more honest about its assumptions?" — not "does this add a feature."

## What we love

- **Bug fixes in the protocol layer.** If a protocol step is ambiguous, contradictory, or pushes the mentor toward sycophantic behaviour, that's a real bug.
- **Better client-setup guides.** New `docs/client-setup/<client>.md` files for tools we haven't covered.
- **Connector adapters.** New stubs in `connectors/` for services that produce useful weekly-review signal.
- **Worked example domains.** A different shape of mentor (creative practice, athletic training, business operations, etc.) under `examples/`.
- **Translations of `core/FIRST_PRINCIPLES.md` and `core/PROTOCOLS.md`.**

## What we're cautious about

- New required machinery. The framework is intentionally markdown + bash. Pull requests that introduce a Node/Python build step, a database, a schema validator, or a web UI need a strong justification rooted in the [first principles](core/FIRST_PRINCIPLES.md).
- New "smart" automation in the user-facing loop. P2 is explicit: the user writes by talking. CLIs that ask the user to fill in structured fields are a regression.
- Scope creep into a knowledge management system. The mentor system is a notebook (P9). A wiki/RAG layer is mentioned in `core/WIKI_BRIDGE.md` but is explicitly out of scope for the core framework.

## How to propose a change

1. Open an issue first for anything bigger than a typo. Describe the problem, the proposed change, and which first principle (if any) it touches.
2. For protocol changes: include a worked example of how the new behaviour differs from the current one in a real session.
3. Keep PRs focused. One change, one PR.
4. Update affected docs in the same PR. If you change a protocol, the docs that reference it must reflect it.

## Code of conduct

Be kind. Be specific. Push back on ideas, not people. If a contributor's PR is wrong, explain why with citations to the principles or to observable failure modes — not with tone.
