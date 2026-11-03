# Specimen inventory

A simple Streamlit dashboard for `data/example.csv`, with total and per-type
specimen counts, collection-date bins, and chart filters.

## Run locally

With [uv](https://docs.astral.sh/uv/) installed, run from the repository root:

```bash
uv run --python 3.12 --with-requirements requirements.txt streamlit run app.py
```

## Publish to Posit Connect from Git

The root `manifest.json` identifies `app.py` as a Streamlit application and uses
`requirements.txt` for its Python dependencies. The manifest is generated with
Python 3.12; Connect must have a compatible Python runtime available.

In [NIMH Posit Connect](https://appshare.nimh.nih.gov/):

1. Select **Publish > Import from Git**.
2. Enter `https://github.com/nimh-dsst/posit-test-inventory.git`.
3. Select the `main` branch.
4. Select the repository root (`.`) as the target directory.
5. Enter a title and deploy the content.

For a private repository, Connect needs GitHub credentials configured by its
administrator. Use the HTTPS repository URL in Connect.

See the [Git-backed publishing guide](https://appshare.nimh.nih.gov/__docs__/user/git-backed/)
for the complete workflow.

## Update the deployment

After changing application files, data, or dependencies, regenerate the manifest
from the repository root:

```bash
uv run --python 3.12 --with-requirements requirements.txt --with rsconnect-python rsconnect write-manifest streamlit --entrypoint app.py --exclude '.mypy_cache/**' --overwrite .
```

Commit and push the changed files together with `manifest.json`. Connect will
fetch updates when automatic updates are enabled. To request an immediate update,
select **Settings > Current Bundle > Update Now** in Connect.
