# Specimen inventory

A simple R Shiny dashboard for `data/example.csv`, with total and per-type
specimen counts, collection-date bins, and chart filters.

## Run locally

In an R session, install the application and publishing packages once:

```r
install.packages(c("shiny", "rsconnect"), repos = "https://cloud.r-project.org")
```

Then run from the repository root:

```r
shiny::runApp(".")
```

## Publish to Posit Connect from Git

The root `manifest.json` identifies `app.R` as an R Shiny application and records
its R package dependencies. The target Connect server provides R 4.6.1.

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

```r
rsconnect::writeManifest(
  appDir = ".",
  appFiles = c("app.R", "data/example.csv", "README.md", "LICENSE"),
  appMode = "shiny"
)
```

Commit and push the changed files together with `manifest.json`. Connect will
fetch updates when automatic updates are enabled. To request an immediate update,
select **Settings > Current Bundle > Update Now** in Connect.
