# changelog-updater Action.

A GitHub Action to automatically update a ["Keep a Changelog"](https://keepachangelog.com/) CHANGELOG with the latest release notes.

The Action …

- automatically updates the `Unreleased`-heading to point to the compare view between the latest version and `HEAD`.
- adds a new second level heading for the new release.
- pastes your release notes in the appropriate place in `CHANGELOG.md`.

Don't want to use GitHub Actions? Checkout the [changelog-updater CLI](https://github.com/stefanzweifel/php-changelog-updater) that powers this Action.

## Usage

The Action is best used in a Workflow that listens to the `release`-event and the type `released`. This way, the name and body of your release will be added to the CHANGELOG.

The following is an example Workflow ready to be used.

The Workflow checks out the default `main`-branch of your repository, updates the `./CHANGELOG.md`-file with the name and the contents of the just released release and commits the changes back to your repository using [git-auto-commit](https://github.com/stefanzweifel/git-auto-commit-action).

```yaml
# .github/workflows/update-changelog.yaml
name: "Update Changelog"

on:
  release:
    types: [released]

jobs:
  update:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        with:
          ref: main

      - name: Update Changelog
        uses: stefanzweifel/changelog-updater-action@v1
        with:
          release-notes: ${{ github.event.release.body }}
          latest-version: ${{ github.event.release.name }}

      - name: Commit updated CHANGELOG
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          branch: main
          commit_message: Update CHANGELOG
          file_pattern: CHANGELOG.md
```

To generate the release notes automatically for you, I can recommend using the [release-drafter](https://github.com/release-drafter/release-drafter) Action. 

## Inputs

Checkout [`action.yml`](https://github.com/stefanzweifel/changelog-updater-action/blob/main/action.yml) for a full list of supported inputs.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/changelog-updater-action/tags).

We also provide major version tags to make it easier to always use the latest release of a major version. For example you can use `stefanzweifel/git-auto-commit-action@v1` to always use the latest release of the current major version.
(More information about this [here](https://help.github.com/en/actions/building-actions/about-actions#versioning-your-action).)

## Credits

* [Stefan Zweifel](https://github.com/stefanzweifel)
* [All Contributors](https://github.com/stefanzweifel/changelog-updater-action/graphs/contributors)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/changelog-updater-action/blob/main/LICENSE) file for details.
