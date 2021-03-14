# Hadolint-action

A github action that checks your Dockerfile with [hadolint][hadolint]. It supports a variety of options as well as annotating your Dockerfile with said results.

## Usage

```yaml
name: "Hadolint"
description: "Analyze Dockerfile with Hadolint"
runs:
  steps:
    - uses: actions/checkout@v2
    - run: jbergstroem/hadolint-action@v1
```

## Parameters

| Variable      | Default        | Description                                                                                                                  |
| :------------ | :------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| dockerfile    | `./Dockerfile` | Path to Dockerfile. Accepts shell expansions (`**/Dockerfile`)                                                               |
| config_file   |                | Path to optional config (hadolint defaults to read `./hadolint.yml` if it exists)                                            |
| error_level   | `0`            | Fail CI if hadolint emits output (`0` = error, `1` = warning, `2` = info)                                                    |
| output_file   |                | If set, write results to file                                                                                                |
| output_format | `json`         | Use with output_file to set output format (choose between `tty`, `json`, `checkstyle`, `codeclimate` or `gitlab_codeclimate` |

## Robustness

Also known as "can I run this in production". The action itself is tested via CI for all its use cases. Releases are cut manually (for now) and the action will strictly follow semver with regards to breaking functionality or options.
