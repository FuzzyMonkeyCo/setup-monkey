# GitHub Action: Run [@FuzzyMonkeyCo](https://github.com/FuzzyMonkeyCo)'s [`monkey`](https://github.com/FuzzyMonkeyCo/monkey)

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/FuzzyMonkeyCo/setup-monkey?logo=github&sort=semver)](https://github.com/FuzzyMonkeyCo/setup-monkey/releases)

This action installs [`monkey`](https://github.com/FuzzyMonkeyCo/monkey) on GitHub workflows to run `monkey` tests.

```yml
name: fuzzymonkey
on: [pull_request]
jobs:
  monkey-lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - uses: FuzzyMonkeyCo/setup-monkey@v1
    - run: monkey lint
```

## Inputs
### `command`
Optional. `monkey` command to run (e.g. `fuzz` or `fmt`).
### `args`
Optional. Arguments to the command.
### `workdir`
Optional. Where to run the command. (default: `.`).
### `api_key`
Optional. API key from [https://fuzzymonkey.co](https://fuzzymonkey.co).
### `github_token`
**Required**. Used only to tame download rate-limiting. (default: `${{ github.token }}`).

## Outputs
### `code`
Return code of the command. (`0`: no error, `2`: lint failure, `4`: fmt failure, `6`: bug found, `7`: exec failed).
### `seed`
Seed returned by `monkey pastseed`. Non-empty when just ran `monkey fuzz` & found a bug.

## Examples

### Minimal
```yml
name: fuzzymonkey
on: [pull_request]
jobs:
  monkey-lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - uses: FuzzyMonkeyCo/setup-monkey@v1
    - run: monkey lint
```

### Run a command
```yml
name: fuzzymonkey
on: [pull_request]
jobs:
  monkey-fuzz:
    name: Run monkey fuzz
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Monkey fuzz
      uses: FuzzyMonkeyCo/setup-monkey@v1
      with:
        command: fuzz
```

### Advanced
```yml
name: Continuous fuzzing
on:
  schedule:
  - cron: '0 4 * * *' # Runs at 4AM UTC every day
jobs:

  monkey-fmt:
    name: monkey ~ fmt
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Monkey fmt
      uses: FuzzyMonkeyCo/setup-monkey@v1
      with:
        command: fmt
        workdir: ./subdirectory/
        github_token: ${{ secrets.github_token }}

  monkey-fuzz:
    name: monkey ~ fuzz
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Monkey fuzz
      uses: FuzzyMonkeyCo/setup-monkey@v1
      with:
        command: fuzz
        args: --time-budget-overall=30m
        workdir: ./subdirectory/
        api_key: ${{ secrets.FUZZYMONKEY_API_KEY }}
        github_token: ${{ secrets.github_token }}
```
