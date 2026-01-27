# Contributing

Thanks for your interest in contributing to hadolint-gh-action!

## Development

The action is written in bash (4 or newer). Key files:

- `action.yml` - GitHub Action definition
- `hadolint.sh` - Entry point
- `lib/` - Core logic (main.sh, validate.sh, hadolint.sh)
- `test/` - Tests using [bash_unit](https://github.com/pgrange/bash_unit)

## Running tests locally

Install dependencies:

- [hadolint](https://github.com/hadolint/hadolint)
- [bash_unit](https://github.com/pgrange/bash_unit)
- [jq](https://stedolan.github.io/jq/)
- [shellcheck](https://github.com/koalaman/shellcheck)
- [shfmt](https://github.com/mvdan/sh)

Run tests:

```bash
bash_unit test/*.sh
```

## Submitting changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure tests pass and add new tests if needed
5. Submit a pull request

## Creating a release

1. Make sure the version number in `lib/hadolint.sh` matches what you expect to release (semver)
2. Create a draft release on GitHub and generate release notes
3. Have a coffee and think about all the mistakes you made
4. Ship it
5. Update the major tag to point to the same commit as the release:
   ```bash
   git tag -f v1 $(git rev-parse HEAD) # assuming HEAD points to the release commit
   git push -f origin v1
   ```
