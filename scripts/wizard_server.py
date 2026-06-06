#!/usr/bin/env python3
"""
Trellis onboarding wizard — local server (stdlib only, no pip installs).

Serves onboarding/index.html and gives the wizard a tiny writeback API so that
clicking "Create my team" actually scaffolds the notebook — the user never has
to touch a terminal beyond the single `./scripts/start.sh` launch.

Endpoints:
  GET  /                 -> the wizard
  GET  /api/health       -> {ok, workspace, name, defaultParent}  (lets the page detect the launcher)
  POST /api/scaffold     -> runs init.sh + add-domain.sh per mentor, writes
                            .trellis/intake-brief.md, returns {ok, notebook}

Nothing here is load-bearing for the running system — it is first-run
convenience only. The notebook itself stays pure markdown + git (FIRST_PRINCIPLES P5).
"""
import json
import os
import re
import subprocess
import sys
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

FRAMEWORK_ROOT = os.environ.get("TRELLIS_FRAMEWORK", "")
NOTEBOOK = os.environ.get("TRELLIS_NOTEBOOK", "")
DEFAULT_NAME = os.environ.get("TRELLIS_NAME", "")
DEFAULT_WORKSPACE = os.environ.get("TRELLIS_WORKSPACE", "")
PORT = int(os.environ.get("TRELLIS_PORT", "8765"))

WIZARD_DIR = os.path.join(FRAMEWORK_ROOT, "onboarding")


def slugify(s):
    return re.sub(r"_+", "_", re.sub(r"[^a-z0-9]+", "_", (s or "").lower())).strip("_")


def resolve_notebook(payload):
    """Pick the notebook path the user chose in the wizard, safely.

    Falls back to the launcher default (NOTEBOOK) if absent. Expands ~, makes
    relative paths relative to the framework's parent, and refuses to scaffold
    inside the framework folder itself.
    """
    raw = (payload.get("notebookPath") or "").strip()
    if not raw:
        return NOTEBOOK
    p = os.path.expanduser(raw)
    if not os.path.isabs(p):
        p = os.path.join(os.path.dirname(FRAMEWORK_ROOT), p)
    p = os.path.normpath(p)
    fr = os.path.normpath(FRAMEWORK_ROOT)
    if p == fr or p.startswith(fr + os.sep):
        return NOTEBOOK  # never scaffold inside the framework — use the safe default
    return p


def run(cmd):
    """Run a command (argv list, never shell=True) and return (ok, output)."""
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, cwd=FRAMEWORK_ROOT)
        return p.returncode == 0, (p.stdout + p.stderr)
    except Exception as e:  # noqa: BLE001
        return False, str(e)


def scaffold(payload):
    """Create the notebook skeleton + a folder per mentor + the intake brief."""
    workspace = (payload.get("workspace") or DEFAULT_WORKSPACE or "My Mentor Team").strip()
    name = (payload.get("userName") or DEFAULT_NAME or "").strip()
    mentors = [m for m in (payload.get("mentors") or []) if str(m).strip()]
    signals = [s for s in (payload.get("signals") or []) if str(s).strip()]
    review_day = (payload.get("reviewDay") or "Sunday").strip()
    season_days = str(payload.get("seasonDays") or "90").strip()
    time_ceiling = str(payload.get("timeCeiling") or "180").strip()
    time_label = (payload.get("timeLabel") or "").strip()
    season_label = (payload.get("seasonLabel") or season_days + " days").strip()
    notebook = resolve_notebook(payload)

    env = dict(os.environ, WORKSPACE_NAME=workspace)
    init = [
        "bash", os.path.join(FRAMEWORK_ROOT, "scripts", "init.sh"),
        "--notebook", notebook, "--client", "claude-cowork",
        "--review-day", review_day,
        "--season-length", season_days if season_days.isdigit() else "90",
        "--time-ceiling", time_ceiling if time_ceiling.isdigit() else "180",
    ]
    if name:
        init += ["--name", name]
    try:
        p = subprocess.run(init, capture_output=True, text=True, cwd=FRAMEWORK_ROOT, env=env)
        if p.returncode != 0:
            return {"ok": False, "error": "init.sh failed", "detail": p.stdout + p.stderr}
    except Exception as e:  # noqa: BLE001
        return {"ok": False, "error": str(e)}

    created = []
    for m in mentors:
        sl = slugify(m)
        if not sl:
            continue
        ok, _ = run(["bash", os.path.join(FRAMEWORK_ROOT, "scripts", "add-domain.sh"),
                     sl, "--notebook", notebook])
        if ok:
            created.append(sl)

    write_brief(notebook, workspace, name, mentors, signals, time_label, review_day, season_label)
    return {"ok": True, "notebook": notebook, "mentors": created}


def write_brief(notebook, workspace, name, mentors, signals, time_label, review_day, season_label):
    """Inject the user's wizard choices into CLAUDE.md (the agent entry point).

    CLAUDE.md is what Claude auto-reads when the folder is connected, so the
    brief belongs there \u2014 NOT in a hidden .trellis/ file the agent won't find.
    We replace the content between the SETUP_BRIEF markers init.sh wrote.
    """
    m_lines = "\n".join(f"- {m}  (slug: {slugify(m)})" for m in mentors) or "- (none chosen \u2014 ask me)"
    s_lines = "\n".join(f"- {s}" for s in signals) or "- (none yet)"
    section = f"""## Setup brief

*The user just finished the setup wizard. These are STARTING choices \u2014 confirm them in conversation, don't treat them as final. Run **PROTOCOL: INTAKE** now.*

**Who**
- Name: {name or "(ask at intake)"}
- Notebook: {workspace}

**Mentors to hire** (each needs INTAKE Part B \u2014 its own first conversation)
{m_lines}

**Rhythm** (confirm with the user)
- Time per day: {time_label or "(ask)"}
- Weekly review day: {review_day}
- Season length: {season_label}

**Signals to connect**
{s_lines}

**What to do:** Read `framework/PROTOCOLS.md`. Run Part A (know the person) once \u2192 write `profile.md` and confirm the rhythm above. Then run Part B for EACH mentor above, asking that domain's own expert questions; seed `done_topics.md` from what the user has already done; end each with one real piece of work and the user's sign-off. Talk to the user \u2014 don't fill in forms."""

    claude_md = os.path.join(notebook, "CLAUDE.md")
    start, end = "<!-- SETUP_BRIEF_START -->", "<!-- SETUP_BRIEF_END -->"
    block = f"{start}\n{section}\n{end}"
    try:
        with open(claude_md, "r") as f:
            content = f.read()
        if start in content and end in content:
            new = re.sub(re.escape(start) + r".*?" + re.escape(end), lambda _: block, content, flags=re.S)
        else:
            new = content.rstrip() + "\n\n" + block + "\n"
        with open(claude_md, "w") as f:
            f.write(new)
    except OSError:
        # CLAUDE.md missing (shouldn't happen) \u2014 write a minimal one so the agent still has an entry point.
        with open(claude_md, "w") as f:
            f.write(f"# {workspace} \u2014 start here\n\nRead `framework/PROTOCOLS.md` and run PROTOCOL: INTAKE.\n\n{block}\n")


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="application/json"):
        data = body.encode() if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *a):  # quiet
        pass

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/api/health":
            return self._send(200, json.dumps(
                {"ok": True, "workspace": DEFAULT_WORKSPACE, "name": DEFAULT_NAME,
                 "defaultParent": os.path.dirname(NOTEBOOK)}))
        if path in ("/", "/index.html"):
            return self._serve_file(os.path.join(WIZARD_DIR, "index.html"), "text/html")
        # only serve files from the wizard dir
        safe = os.path.normpath(path).lstrip("/")
        full = os.path.join(WIZARD_DIR, safe)
        if os.path.isfile(full) and full.startswith(WIZARD_DIR):
            return self._serve_file(full, self._ctype(full))
        return self._send(404, "not found", "text/plain")

    def do_POST(self):
        if urlparse(self.path).path != "/api/scaffold":
            return self._send(404, "not found", "text/plain")
        length = int(self.headers.get("Content-Length", 0))
        try:
            payload = json.loads(self.rfile.read(length) or "{}")
        except Exception:  # noqa: BLE001
            return self._send(400, json.dumps({"ok": False, "error": "bad json"}))
        result = scaffold(payload)
        return self._send(200 if result.get("ok") else 500, json.dumps(result))

    def _serve_file(self, full, ctype):
        try:
            with open(full, "rb") as f:
                self._send(200, f.read(), ctype)
        except OSError:
            self._send(404, "not found", "text/plain")

    @staticmethod
    def _ctype(p):
        if p.endswith(".html"):
            return "text/html"
        if p.endswith(".css"):
            return "text/css"
        if p.endswith(".js"):
            return "application/javascript"
        if p.endswith(".svg"):
            return "image/svg+xml"
        return "application/octet-stream"


def main():
    if not FRAMEWORK_ROOT or not os.path.isdir(WIZARD_DIR):
        print("error: run via scripts/start.sh (TRELLIS_FRAMEWORK not set)", file=sys.stderr)
        sys.exit(1)
    url = f"http://127.0.0.1:{PORT}/"
    httpd = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    print(f"\n  Trellis onboarding wizard running at  {url}")
    print("  (leave this open; press Ctrl+C when you're done)\n")
    try:
        webbrowser.open(url)
    except Exception:  # noqa: BLE001
        pass
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n  wizard closed.\n")
        httpd.shutdown()


if __name__ == "__main__":
    main()
