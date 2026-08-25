# GPT-Tool

Python tool: sign in to ChatGPT with `email|password|totp`, obtain Codex OAuth tokens **without Veriphone or SMS**, and export **one JSON file per account**. It also converts between formats used by [GPTSession2CPAandSub2API](https://github.com/gtxx3600/GPTSession2CPAandSub2API).

No Rust runtime. No account registration. No SIM rental.

## 1-click setup

Install [Python 3.11+](https://www.python.org/downloads/) first (Windows: enable "Add Python to PATH").

| System | What to run |
| --- | --- |
| macOS | Double-click `start.command` (first run: right-click -> Open) |
| Windows | Double-click `start.bat` |
| Linux | `chmod +x start.sh && ./start.sh` |

The launcher creates `.venv`, installs dependencies, and opens `http://127.0.0.1:8765/`.

1. Choose an output format (CPA / Codex / sub2api / ...).
2. On **Export Codex**, paste `email|password|totp`, then run the export.
3. On **Convert JSON**, paste an existing auth/session JSON.
4. Output files are written to `out/`.

## CLI

```bash
python -m gpt_tool.cli export --format cpa --lines accounts.txt --out out
python -m gpt_tool.cli convert --format codex --in session.json --out out
bash export_cpa.sh accounts.txt
```

Format: `cpa` `sub2api` `cockpit` `9router` `codex` `axonhub` `codexmanager`.

## If OpenAI asks for add-phone

OpenAI may still require phone binding during Codex OAuth even if the web account is already phone-verified. This tool **intentionally does not** rent SIMs or use Veriphone. The account is skipped and the error is written to `out/failed.txt`.

## Security

Exported JSON files contain `access_token` / `refresh_token`, which should be treated like passwords. Do not share them and do not commit them to git.

## Dev

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pytest
```
