# Usage

Here you can find verbose examples of configuring the action to do what you want.

## Changing error level

In many cases, the hadolint "warning" error level can be seen as somewhat verbose.
You can manage this by changing the error level, which tells CI to fail or pass
depending on what output is given by hadolint. Passing `-1` will only generate
output but never fail CI which can be useful if you chain actions as dependencies.

```yaml
name: Lint
on: pull_request

jobs:
  hadolint:
    runs-on: ubuntu-20.04
    name: "Hadolint"
    steps:
      - uses: actions/checkout@v2
      - uses: jbergstroem/hadolint-gh-action@v1
    with:
      # ignore warnings (but still fail on errors) from hadolint
      error_level: 1
```

## Run on certain Dockerfiles

By default, hadolint only looks for a `Dockerfile` in the same directory you would
invoke it from - most often the root of your repository.

Depending on what your you case, you can tailor either when the action should run
or what files you want to pass to it.

### Only run if there are changes to a Dockerfile

If you want to control when you want hadolint to fire, you can tell github actions when it
should run by using the [`on` directive][gh-on]; specifically `paths` or `ignore-paths`.

In this example, the job will only run if there is a change to `Dockerfile` in the commits
found in said PR:

```yaml
name: Lint
on:
  pull_request:
    paths:
      - "./Dockerfile"

jobs:
  hadolint:
    runs-on: ubuntu-20.04
    name: "Hadolint"
    steps:
      - uses: actions/checkout@v2
      - uses: jbergstroem/hadolint-gh-action@v1
```

A similar path pattern could be looking for changes in any `Dockerfile`:

```yaml
name: Lint
on:
  pull_request:
    paths:
      - "**/Dockerfile"
# job goes here
```

### Pass multiple Dockerfiles to process

As found in the [parameters][gh-param], you can pass multiple files for processing:

```yaml
name: Lint
on: pull_request

jobs:
  hadolint:
    runs-on: ubuntu-20.04
    name: "Hadolint"
    steps:
      - uses: actions/checkout@v2
      - uses: jbergstroem/hadolint-gh-action@v1
    with:
      dockerfile: "Dockerfile path/to/my/other/Dockerfile"
```

### Only pass Dockerfiles that are changes in the PR

In certain use-cases – for instance when you have a monorepo with a lot of Dockerfiles; you may
only want to pass the files that are changed in the PR. This would make processing faster.

To achieve this, you first need to find what files are changed and extract the relevant files
as a separate step in your job. Thankfully, there's already an [action for that][gh-changed-files].

```yaml
name: Lint
on: pull_request

jobs:
  hadolint:
    runs-on: ubuntu-20.04
    name: "Hadolint"
    steps:
      - uses: actions/checkout@v2
      - name: Get changed files
        id: changed-files
        uses: tj-actions/changed-files@v9.3
        with:
          # Pass what names/filters you want to catch
          files: |
            **/Dockerfile
          separator: " "
      # Only run if expected files are changed and pass these as input
      - uses: jbergstroem/hadolint-gh-action@v1
        if: steps.changed-files.outputs.any_changed == 'true'
        with:
          dockerfile: "${{ steps.changed-files.outputs.other_changed_files }}"
```

[gh-on]: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#onpushpull_requestpaths
[gh-param]: https://github.com/jbergstroem/hadolint-gh-action#parameters
[gh-changed-files]: https://github.com/tj-actions/changed-files
