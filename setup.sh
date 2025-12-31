#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="${1:-pysolo}"
PKG_NAME="${PROJECT_NAME//-/_}"

if [[ -d "$PROJECT_NAME" ]]; then
  echo "Directory '$PROJECT_NAME' already exists. Aborting."
  exit 1
fi

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# --- Git ---
git init -q

# --- Basic structure (src-layout) ---
mkdir -p "src/${PKG_NAME}" tests .github/workflows scripts

cat > "src/${PKG_NAME}/__init__.py" <<'PY'
"""
pysolo: Financial operations primitives for Python.

Public API should be re-exported here as it stabilises.
"""
from .money import Money, Currency
PY

cat > "src/${PKG_NAME}/money.py" <<'PY'
from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal, ROUND_HALF_UP
from typing import NewType

Currency = NewType("Currency", str)

@dataclass(frozen=True, slots=True)
class Money:
    amount: Decimal
    currency: Currency

    def quantize(self, exp: str = "0.01", rounding=ROUND_HALF_UP) -> "Money":
        q = Decimal(exp)
        return Money(amount=self.amount.quantize(q, rounding=rounding), currency=self.currency)
PY

# Marker for typed packages (PEP 561)
touch "src/${PKG_NAME}/py.typed"

cat > "tests/test_money.py" <<'PY'
from decimal import Decimal
from pysolo.money import Money, Currency

def test_money_quantize():
    m = Money(amount=Decimal("10.005"), currency=Currency("GBP"))
    assert str(m.quantize().amount) == "10.01"
PY

# --- README / Licence / Changelog ---
cat > "README.md" <<EOF
# ${PROJECT_NAME}

Open-source financial operations primitives for Python.

## Quickstart

\`\`\`bash
uv sync
uv run pytest
\`\`\`

## Example

\`\`\`python
from decimal import Decimal
from ${PKG_NAME}.money import Money, Currency

m = Money(Decimal("10.005"), Currency("GBP"))
print(m.quantize())  # 10.01 GBP (rounded)
\`\`\`
EOF

cat > "LICENSE" <<'EOF'
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

cat > "CHANGELOG.md" <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## Unreleased
- Initial scaffolding
EOF

# --- .gitignore ---
cat > ".gitignore" <<'EOF'
# Python
__pycache__/
*.py[cod]
*.pyd
*.so
*.egg-info/
dist/
build/
.venv/

# Coverage / testing
.coverage
htmlcov/
.pytest_cache/
coverage.xml

# Tooling
.ruff_cache/
.mypy_cache/
EOF

# --- pyproject.toml ---
cat > "pyproject.toml" <<EOF
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "${PROJECT_NAME}"
version = "0.1.0"
description = "Financial operations primitives for Python"
readme = "README.md"
requires-python = ">=3.10"
license = { file = "LICENSE" }
authors = [{ name = "Ola Ajibode" }]
keywords = ["finance", "ledger", "accounting", "money", "operations"]
classifiers = [
  "Development Status :: 3 - Alpha",
  "Intended Audience :: Developers",
  "License :: OSI Approved :: MIT License",
  "Programming Language :: Python :: 3",
  "Programming Language :: Python :: 3 :: Only",
]

dependencies = []

[project.optional-dependencies]
frames = ["polars>=1.0.0", "pandas>=2.0.0"]

[tool.setuptools]
package-dir = {"" = "src"}

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-q --disable-warnings --maxfail=1 --cov=${PKG_NAME} --cov-report=term-missing"

[tool.coverage.run]
branch = true
source = ["${PKG_NAME}"]

[tool.coverage.report]
show_missing = true
skip_covered = true
fail_under = 90

[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "SIM"]
ignore = []

[tool.ruff.format]
quote-style = "double"

[tool.interrogate]
fail-under = 80
ignore-init-module = true
ignore-private = true
ignore-magic = true
verbose = 1
exclude = ["tests", "dist", "build", ".venv"]

[tool.commitizen]
name = "cz_conventional_commits"
version = "0.1.0"
tag_format = "v\$version"
update_changelog_on_bump = true
EOF

# --- pre-commit config ---
cat > ".pre-commit-config.yaml" <<'EOF'
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
        args: ["--fix"]
      - id: ruff-format

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: end-of-file-fixer
      - id: trailing-whitespace
      - id: check-yaml
      - id: check-toml

  - repo: https://github.com/econchick/interrogate
    rev: 1.7.0
    hooks:
      - id: interrogate
        args: ["-c", "pyproject.toml"]

  - repo: https://github.com/commitizen-tools/commitizen
    rev: v3.29.1
    hooks:
      - id: commitizen
      - id: commitizen-branch
EOF

# --- Minimal CI (GitHub Actions) ---
cat > ".github/workflows/ci.yml" <<EOF
name: CI

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12", "3.13"]
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - name: Set up Python
        run: uv python install \${{ matrix.python-version }}
      - name: Sync
        run: uv sync
      - name: Ruff (lint)
        run: uv run ruff check .
      - name: Ruff (format)
        run: uv run ruff format --check .
      - name: Type check (ty)
        run: uv run ty check .
      - name: Type check (pyrefly)
        run: uv run pyrefly check
      - name: Tests
        run: uv run pytest
EOF

# --- uv: initialise environment + add dev deps ---
# Create a uv-managed environment for this project.
uv venv -q

# Add dev dependencies
uv add --dev pytest pytest-cov coverage ruff pre-commit commitizen interrogate ty pyrefly wheel

# Optional data stack (keep as normal deps? we put them in extras, but also handy in dev)
uv add --dev polars pandas

# Install git hooks
uv run pre-commit install

# Initial commit
git add .
git commit -m "chore: bootstrap ${PROJECT_NAME}" -q

echo ""
echo "✅ Bootstrapped '${PROJECT_NAME}'"
echo ""
echo "Next commands:"
echo "  cd ${PROJECT_NAME}"
echo "  uv sync"
echo "  uv run ruff check ."
echo "  uv run ruff format ."
echo "  uv run ty check ."
echo "  uv run pyrefly check"
echo "  uv run pytest"
echo "  uv run coverage html"
echo "  uv run cz bump --dry-run"
