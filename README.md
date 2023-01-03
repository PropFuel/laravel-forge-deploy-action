# Deploy to Laravel Forge Action

This action triggers the deployment of a Laravel Forge site. It can optionally update the site's `.env` file and deployment script prior to triggering the deployment.

## Usage

Add the following entry to your Github workflow YAML file with the required inputs:

```yaml
uses: PropFuel/laravel-forge-deploy-action@v1.0.0
with:
  forge-api-token: your-forge-api-token
  forge-server-id: your-forge-server-id
  forge-site-id: your-forge-site-id
```

### Required Inputs

We recommend storing sensitive data as [GitHub encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

| Input             | Description                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------- |
| `forge-api-token` | Your Forge API Token. This can be generated in your [Account Settings](https://forge.laravel.com/user-profile/api). |
| `forge-server-id` | Your Forge Server ID.                                                                                               |
| `forge-site-id`   | Your Forge Site ID.                                                                                                 |

### Optional Inputs

| Input                | Description                                                                         |
| -------------------- | ----------------------------------------------------------------------------------- |
| `env-file-path`      | Relative path to the file whose content will replace your site's `.env` file.       |
| `deploy-script-path` | Relative path to the file whose content will replace your site's deployment script. |

## Examples

Trigger your site's deployment:

```yaml
name: Deploy on push to main branch

on:
  push:
    branches:
      - main

jobs:
  deploy:
    name: Laravel Forge Deploy
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        uses: PropFuel/laravel-forge-deploy-action@v1.0.0
        with:
          forge-api-token: ${{ secrets.FORGE_API_TOKEN }}
          forge-server-id: ${{ secrets.FORGE_SERVER_ID }}
          forge-site-id: ${{ secrets.FORGE_SITE_ID }}
```

Use a matrix to update the `.env` file, the deployment script, and trigger the deployment of multiple sites:

```yaml
name: Deploy multiple sites

on:
  push:
    branches:
      - main

jobs:
  deploy:
    name: Laravel Forge Deploy
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - serverId: server-1-id
            siteId: site-1-id
          - serverId: server-2-id
            siteId: site-2-id
    steps:
      - name: Checkout the repo
        uses: actions/checkout@v3

      - name: Write a .env file to the current workspace
        run: |
          echo "PROP=fuel" >> .env
          echo "FOO=bar" >> .env

      - name: Deploy
        uses: PropFuel/laravel-forge-deploy-action@v1.0.0
        with:
          forge-api-token: ${{ secrets.FORGE_API_TOKEN }}
          forge-server-id: ${{ matrix.serverId }}
          forge-site-id: ${{ matrix.siteId }}
          env-file-path: .env
          deploy-script-path: path/in/repo/to/deploy.sh
```
