# Justfile
# Run `just` to see available recipes.
# If your package import name differs from your project name, set PKG.
# Example: just PKG=finops test

set dotenv-load := true
set positional-arguments := true

# ---------- Config ----------
# Importable Python package name (src/<PKG>/...)

PKG := env_var_or_default("PKG", "finops")
PY := "python"

# Convenience: always use uv run

UV := "uv run"

default:
    @just --list

# ---------- Environment ----------
venv:
    @uv venv

sync:
    @uv sync

install: venv sync
    @echo "✅ Environment ready"

# Optional: add common dev deps (if you didn't already)
dev-add:
    @uv add --dev pytest pytest-cov coverage ruff pre-commit commitizen interrogate ty pyrefly wheel

# ---------- Quality / CI ----------
fmt:
    @{{ UV }} ruff format .

lint: fmt
    @{{ UV }} ruff check .

fix: lint
    @{{ UV }} ruff check --fix .
    @{{ UV }} ruff format .

type:
    @{{ UV }} ty check .
    @{{ UV }} pyrefly check

doccov:
    @{{ UV }} interrogate -c pyproject.toml

test:
    @{{ UV }} pytest

testv:
    @{{ UV }} pytest -vv

cov:
    @{{ UV }} pytest --cov={{ PKG }} --cov-report=term-missing

cov-xml:
    @{{ UV }} pytest --cov={{ PKG }} --cov-report=xml

cov-html:
    @{{ UV }} pytest --cov={{ PKG }} --cov-report=html
    @echo "Open: htmlcov/index.html"

check: lint type test doccov
    @echo "✅ All checks passed"

ci: lint
    @{{ UV }} ruff format --check .
    @just type
    @just test
    @just doccov

# ---------- Pre-commit ----------
pc-install:
    @{{ UV }} pre-commit install
    @echo "✅ pre-commit installed"

pc:
    @{{ UV }} pre-commit run --all-files

# ---------- Packaging ----------
build:
    @uv build
    @echo "✅ Built dist/"

clean:
    @rm -rf dist build .pytest_cache .ruff_cache htmlcov .coverage coverage.xml
    @find . -type d -name "__pycache__" -prune -exec rm -rf {} +
    @find . -type f -name "*.pyc" -delete
    @echo "✅ Cleaned"

# ---------- Versioning / Release (Commitizen) ----------
cz-check:
    @{{ UV }} cz check --rev-range HEAD~20..HEAD

bump-dry:
    @{{ UV }} cz bump --dry-run

bump:
    @{{ UV }} cz bump

changelog:
    @{{ UV }} cz changelog

# ---------- Utilities ----------

# Run any python module: just run -m finops.cli
run *ARGS:
    @{{ UV }} {{ PY }} {{ ARGS }}

# Open a REPL in the uv environment
repl:
    @{{ UV }} {{ PY }}

# Quick smoke import
smoke:
    @{{ UV }} {{ PY }} -c "import {{ PKG }}; print('{{ PKG }} ok')"
