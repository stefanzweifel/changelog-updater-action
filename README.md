# changelog-updater Action

A GitHub Action to update a changelog with the latest release notes.

The Action …

- adds a new second level heading for the new release
- pastes your release notes in the appropriate place in `CHANGELOG.md`

*If your changelog follows the ["Keep a Changelog"](https://keepachangelog.com/) format and contains an "Unreleased"-heading, the Action will update the heading to point to the compare view between the latest version and `HEAD`. (Read more about this [here](https://github.com/stefanzweifel/php-changelog-updater#expected-changelog-formats))*

Don't want to use GitHub Actions? Checkout the [changelog-updater CLI](https://github.com/stefanzweifel/php-changelog-updater) that powers this Action.
Want to learn more about this Action? Read my [introduction blog post](https://stefanzweifel.io/posts/2021/11/13/introducing-the-changelog-updater-action).

## Usage

The Action is best used in a Workflow that listens to the `release`-event and the type `released`. This way, the name and body of your release will be added to the CHANGELOG.

The following is an example Workflow ready to be used.

The Workflow checks out [the target branch of the release](https://docs.github.com/en/rest/reference/releases#create-a-release--parameters), updates the `./CHANGELOG.md`-file with the name and the contents of the just released release and commits the changes back to your repository using [git-auto-commit](https://github.com/stefanzweifel/git-auto-commit-action).

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
          ref: ${{ github.event.release.target_commitish }}

      - name: Update Changelog
        uses: stefanzweifel/changelog-updater-action@v1
        with:
          latest-version: ${{ github.event.release.tag_name }}
          release-notes: ${{ github.event.release.body }}

      - name: Commit updated CHANGELOG
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          branch: ${{ github.event.release.target_commitish }}
          commit_message: Update CHANGELOG
          file_pattern: CHANGELOG.md
```

To generate the release notes automatically for you, I can recommend using the [release-drafter](https://github.com/release-drafter/release-drafter) Action. 

## Inputs

Checkout [`action.yml`](https://github.com/stefanzweifel/changelog-updater-action/blob/main/action.yml) for a full list of supported inputs.

## Expected Changelog Formats

At minimum, the Action requires an empty `CHANGELOG.md` file to exist in your repository.
When executed, the Action will place the release notes at the bottom of the document.
If your changelog already contains a **second level heading**, the Action will put the release notes above previous release notes in the document.

Your changelog will look something like this:

```md
# Changelog

## v1.1.0 - 2021-02-01

### Added

- New Feature A

## v1.0.0 - 2021-01-01

- Initial Release
```

If you want to learn more on how the Action determines the place for the release notes, read the the [notes in the README of the CLI](https://github.com/stefanzweifel/php-changelog-updater#expected-changelog-formats) that powers this Action.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/changelog-updater-action/tags).

We also provide major version tags to make it easier to always use the latest release of a major version. For example you can use `stefanzweifel/changelog-updater-action@v1` to always use the latest release of the current major version.
(More information about this [here](https://help.github.com/en/actions/building-actions/about-actions#versioning-your-action).)

## Credits

* [Stefan Zweifel](https://github.com/stefanzweifel)
* [All Contributors](https://github.com/stefanzweifel/changelog-updater-action/graphs/contributors)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/changelog-updater-action/blob/main/LICENSE) file for details.
