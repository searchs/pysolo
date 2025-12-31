# Release Process (Automated)

This project uses **commitizen** and **GitHub Actions** for fully automated versioning and PyPI publishing.

## How It Works

1. **Feature branches** → **Pull requests to `develop`**
   - All commits must follow [Conventional Commit](https://www.conventionalcommits.org/) format:
     - `feat: ...` → minor version bump
     - `fix: ...` → patch version bump
     - `BREAKING CHANGE: ...` → major version bump

2. **PR merge to `develop`** → **Manual merge to `main`** (or auto-merge if configured)
   - Tests pass automatically on develop

3. **Push to `main` branch** → **Release workflow triggers**
   - Auto-detects conventional commits since last tag
   - Runs `cz bump --yes` to:
     - Update `pyproject.toml` version
     - Update `CHANGELOG.md` with release notes
     - Create a git commit and tag (e.g., `v0.2.1`)
   - Builds the package (`uv build`)
   - Publishes to PyPI using `PYPI_TOKEN` secret
   - Re-runs tests to verify release

## Setup Required

### 1. GitHub Secrets

Add these secrets to your repository settings (`Settings > Secrets and variables > Actions`):

- **`PYPI_TOKEN`** — Your PyPI API token
  - Get from https://pypi.org/manage/account/tokens/
  - Use token type: "Project-specific" for `pysolo` if available, else "Account-wide"
  - Example: `pypi-AgEIcHlwaS5vcmc...` (starts with `pypi-`)

### 2. Branch Protection (Recommended)

On `main` branch, enable:
- ✅ Require PR reviews before merge
- ✅ Require status checks to pass (CI workflow must pass)
- ✅ Require branches to be up to date before merge
- ✅ Restrict who can push (only admins, e.g., GitHub Actions bot via release workflow)

This ensures only tested code reaches `main` and auto-triggers release.

### 3. Configure Git Auth for Commitizen

The release workflow uses `GITHUB_TOKEN` (auto-provided) which has limited permissions. If commits fail:
- Add a Personal Access Token (PAT) as `GH_TOKEN` secret with `repo` scope
- Update `.github/workflows/release.yml` to use it:
  ```yaml
  - uses: actions/checkout@v6
    with:
      token: ${{ secrets.GH_TOKEN || secrets.GITHUB_TOKEN }}
  ```

## Manual Release (If Needed)

If you need to trigger a release manually without merging to main:

1. Use GitHub Actions "Run workflow" UI:
   - Go to **Actions > Release**
   - Click **"Run workflow"** button
   - Select branch (usually `main`)

Or trigger locally:
```bash
git checkout develop
git commit -m "feat: add new feature"  # Conventional commit
git push origin develop
# Create PR, get approval
# Merge PR to develop
git checkout main
git pull origin develop
git push origin main  # Triggers release workflow
```

## Rollback a Release

If a release fails or has a bug:

1. Find the tag: `git tag -l`
2. Delete the remote tag: `git push origin --delete v0.2.1`
3. Delete local tag: `git tag -d v0.2.1`
4. Yank the release on PyPI (if published):
   - Go to https://pypi.org/manage/project/pysolo/history/
   - Click version → "Options" → "Yank release"

## Troubleshooting

### "Cannot find conventional commits" error
- Ensure commit messages follow format: `feat:`, `fix:`, `refactor:`, etc.
- Check: `git log --oneline | head -5`

### "Publish skipped (token not configured)"
- Add `PYPI_TOKEN` secret (see Setup section)
- Re-run release workflow via GitHub Actions UI

### Release created but not published to PyPI
- Check workflow logs: **Actions > Release > [workflow run]**
- Verify token is valid and not expired
- Check `uv publish` step in logs

### Version not updating in `pyproject.toml`
- Ensure no uncommitted changes on `main` branch
- Run: `git status` (should be clean)
- Manually run `uv run cz bump --dry-run` locally to test
