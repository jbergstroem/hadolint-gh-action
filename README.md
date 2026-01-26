# hadolint-gh-action

A stable, well-tested, highly configurable way of checking your Dockerfile(s) with [hadolint][hadolint].

## Usage

Verify your dockerfiles with hadolint for pull requests:

```yaml
name: Lint
on: pull_request

jobs:
  hadolint:
    runs-on: ubuntu-slim
    name: Hadolint
    steps:
      - uses: actions/checkout@v6
      - uses: jbergstroem/hadolint-gh-action@v1
```

More usage examples [can be found in USAGE.md](USAGE.md).

## Parameters

| Variable          | Default        | Description                                                                                                                                   |
| :---------------- | :------------- | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| dockerfile        | `./Dockerfile` | Path to Dockerfile(s). Accepts shell expansions (`**/Dockerfile`)                                                                             |
| config_file       |                | Path to optional config (hadolint defaults to read `./hadolint.yml` if it exists)                                                             |
| error_level       | `0`            | Fail CI based on hadolint output (`-1`: never, `0`: error, `1`: warning, `2`: info)                                                           |
| annotate          | `true`         | Annotate code inline in the github PR viewer (`true`/`false`)                                                                                 |
| output_format     |                | Set output format (choose between `tty`, `json`, `checkstyle`, `codeclimate`, `gitlab_codeclimate`, `gnu`, `codacy`, `sonarqube` and `sarif`) |
| hadolint_path     |                | Absolute path to hadolint binary. If unset, it is assumed to exist in `$PATH`                                                                 |
| version           | `2.14.0`       | Use a specific version of Hadolint                                                                                                            |
| advanced_security | `false`        | Upload results to GitHub Advanced Security (`true`/`false`)                                                                                   |

## Hadolint version

The github action accepts an input - `version` - to switch/pin to a different version of hadolint.

The output variable `hadolint_version` will always contain what version the action is running.
This can be useful in debugging scenarios where things "break" from one day to the other due to the action being updated.

The shell scripts are developed against the latest version available (which is the default value for the input).

## Output

You can control the behavior of how hadolint presents its findings by configuring:

- annotate: let feedback show inline in your code review
- output_format: store the output in a variable you can pass on to other processing tools

If `output_format` is set, the github action variable `hadolint_output` will contain the output. You can choose what format you prefer depending on how you want to process the results.

These output variables are always populated:

- `hadolint_version`: the version of hadolint used while running the action
- `hadolint_gh_action_version`: the version of this action while running it

## GitHub Advanced Security

Enable `advanced_security` to upload hadolint findings to the [GitHub Advanced Security][gh-advanced-security] dashboard. Results appear in the Security tab of your repository, providing centralized vulnerability tracking.

```yaml
- uses: jbergstroem/hadolint-gh-action@v1
  with:
    advanced_security: true
```

Note: Requires `security-events: write` permission. See [USAGE.md](USAGE.md#github-advanced-security) for a detailed example.

## Robustness

Also known as "can I run this in production". The action itself is tested via CI for all its use cases as well as unit tests for each function. Additionally, `shellcheck` is run against all shell scripts. Releases are cut manually (for now) and the action will strictly follow semver with regards to breaking functionality or options.

## Performance

Due to staying with bash we can avoid Docker-related performance penalties. Yet to be benchmarked, but it is likely on par or faster than other hadolint actions.

[hadolint]: http://github.com/hadolint/hadolint/
[gh-advanced-security]: https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security
