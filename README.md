# regrada-action

Public GitHub Action wrapper for running Regrada 

## Usage

```yaml
name: Regrada

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Regrada
        uses: regrada-ai/regrada-action@v1
        with:
          version: latest
          config: regrada.yml
          comment-on-pr: true
```

## Inputs

- `version`: CLI version to install, default `latest`
- `base-url`: release host, default `https://regrada.com/releases`
- `config`: path to `regrada.yml`, default `regrada.yml`
- `comment-on-pr`: whether to update a PR comment, default `true`
- `working-directory`: working directory for the test run, default `.`
