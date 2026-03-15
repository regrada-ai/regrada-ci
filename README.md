# regrada-action

Public GitHub Action wrapper for running Regrada while keeping the CLI source in a private repository.

## Repository split

- `regrada-cli` (private): Go source, release workflow, signed artifacts
- `regrada-action` (public): action metadata, installer, CI wrapper scripts

The action never checks out the private CLI repository. It downloads a released binary instead.

## Expected release layout

The installer expects versioned artifacts at a public base URL:

```text
https://regrada.com/releases/latest.txt
https://regrada.com/releases/v0.3.0/checksums.txt
https://regrada.com/releases/v0.3.0/regrada_v0.3.0_linux_amd64.tar.gz
https://regrada.com/releases/v0.3.0/regrada_v0.3.0_linux_arm64.tar.gz
https://regrada.com/releases/v0.3.0/regrada_v0.3.0_darwin_amd64.tar.gz
https://regrada.com/releases/v0.3.0/regrada_v0.3.0_darwin_arm64.tar.gz
```

`latest.txt` should contain a single version string such as `v0.3.0`.

`checksums.txt` should use standard sha256 format:

```text
<sha256>  regrada_v0.3.0_linux_amd64.tar.gz
<sha256>  regrada_v0.3.0_linux_arm64.tar.gz
<sha256>  regrada_v0.3.0_darwin_amd64.tar.gz
<sha256>  regrada_v0.3.0_darwin_arm64.tar.gz
```

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

## Release process

1. Tag a release in the private CLI repository.
2. Build `regrada` tarballs for each supported platform.
3. Publish tarballs, `checksums.txt`, and `latest.txt` to the release host.
4. Tag the public action repository, for example `v1`.
