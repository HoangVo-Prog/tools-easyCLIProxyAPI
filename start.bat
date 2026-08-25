@echo off
setlocal
cd /d "%~dp0"

where py >nul 2>nul
if %ERRORLEVEL%==0 (
  py -3 -c "import sys; raise SystemExit(0 if sys.version_info>=(3,11) else 1)" || goto :nopy
  goto :okpy
)
where python >nul 2>nul
if %ERRORLEVEL%==0 (
  python -c "import sys; raise SystemExit(0 if sys.version_info>=(3,11) else 1)" || goto :nopy
  goto :okpy
)
:nopy
echo Python 3.11+ is required. Download: https://www.python.org/downloads/
pause
exit /b 1

:okpy
if not exist .venv (
  echo Creating virtual environment .venv ...
  py -3 -m venv .venv 2>nul || python -m venv .venv
)
call .venv\Scripts\activate.bat
echo Installing/updating dependencies ...
python -m pip install -q -U pip
python -m pip install -q -U -r requirements.txt
python -c "from gpt_tool.ensure_deps import ensure_deps; ensure_deps()"
echo Opening GPT-Tool in your browser ...
python -m gpt_tool.server
pause
