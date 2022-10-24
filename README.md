# changelog-updater Action

A GitHub Action to update a changelog with the latest release notes.

The Action …

- adds a new second level heading for the new release
- pastes your release notes in the appropriate place in `CHANGELOG.md`

*If your changelog follows the ["Keep a Changelog"](https://keepachangelog.com/) format and contains an "Unreleased"-heading, the Action will update the heading to point to the compare view between the latest version and `HEAD`. (Read more about this [here](https://github.com/stefanzweifel/php-changelog-updater#expected-changelog-formats))*

Don't want to use GitHub Actions? Checkout the [changelog-updater CLI](https://github.com/stefanzweifel/php-changelog-updater) that powers this Action.
Want to learn more about this Action? Read my [introduction blog post](https://stefanzweifel.io/posts/2021/11/13/introducing-the-changelog-updater-action).


> **Note**  
> This Action will emit warnings in your workflow logs regarding the `set-output` command until **2022-12-31**.   
> The Action has already been [updated](https://github.com/stefanzweifel/php-changelog-updater/pull/30) to support the new syntax and will stop emitting a warning starting 2023-01-01.   
> Please do not open issues regarding this issue.

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

### Advanced Usage

#### Use Tag Date as Release Date

The following workflow is a bit more advanced. It …

- extracts the exact release date from the git tag
- uses the target branch of the release in the "Unreleased" compare URL
- pushes the created commit to the target branch of the commit

<details>
  
<summary>Show update-changelog.yaml</summary>
  
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
          # Fetch entire history of repository to ensure relase date can be
          # extracted from commit of the given tag.
          fetch-depth: 0
          # Checkout target branch of this release. Ensures that the CHANGELOG
          # is not out of date.
          ref: ${{ github.event.release.target_commitish }}

      - name: Extract release date from git tag
        id: release_date
        run: |
          echo "::set-output name=date::$(git log -1 --date=short --format=%ad '${{ github.event.release.tag_name }}')"

      - name: Update Changelog
        uses: stefanzweifel/changelog-updater-action@v1
        with:
          # Pass extracted release date, release notes and version to the Action.
          release-date: ${{ steps.release_date.outputs.date }}
          release-notes: ${{ github.event.release.body }}
          latest-version: ${{ github.event.release.tag_name }}
          compare-url-target-revision: ${{ github.event.release.target_commitish }}

      - name: Commit updated CHANGELOG
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          # Push updated CHANGELOG to release target branch.
          branch: ${{ github.event.release.target_commitish }}
          commit_message: Update CHANGELOG
          file_pattern: CHANGELOG.md
```
  
</details>

#### Trigger Action on `workflow_dispatch` event

[HannesWell](https://github.com/HannesWell) uses the Action in a worfklow triggered by the `workflow_dispatch`: [See workflow](https://github.com/axkr/symja_android_library/blob/b371b64b0893e20a738cf4db23e3a0fafa679b6b/.github/workflows/maven-perform-release.yml).

The workflow …

- is manually triggered
- builds a Java project
- uses the content between the Unreleased and Previous Release heading as relase notes and updates the CHANGELOG.md
- commits the changes and pushes them to GitHub
- creates a new GitHub release and points in the release notes to the right heading for the just released version

This workflow uses the output variables generated by this Action to accomplish this task.

## Inputs

Checkout [`action.yml`](https://github.com/stefanzweifel/changelog-updater-action/blob/main/action.yml) for a full list of supported inputs. 
Check the README of the [underlying CLI](https://github.com/stefanzweifel/php-changelog-updater#cli-options) to learn more about them.

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

## Outputs

The Action exposes some outputs you can further use in your workflow. The Action currently supports the following outputs:

### `release_compare_url`
The generated compare URL for the just created relase. For example `https://github.com/org/repo/compare/v1.0.0...v1.1.0`.
The value is only available, if the Action could generate a compare URL based on the available CHANGELOG data.

### `release_url_fragment`
The URL fragment for the just created release. For example '#v100---2021-02-01'. You can use this to generate URLs that point to the newly created release in your CHANGELOG.

### `unreleased_compare_url`
The generated compare URL between the latest version and the target revision. For example `https://github.com/org/repo/compare/v1.0.0...HEAD`.
The value is only available, if the Action could generate a compare URL based on the available CHANGELOG data.

See [`action.yml`](https://github.com/stefanzweifel/changelog-updater-action/blob/main/action.yml) for details.

See workflow below on how to use these output values in your workflow.

```yaml
- name: Update Changelog
  uses: stefanzweifel/changelog-updater-action@v1
  id: "changelog-updater"
  with:
    # Pass extracted release date, release notes and version to the Action.
    release-date: ${{ steps.release_date.outputs.date }}
    release-notes: ${{ github.event.release.body }}
    latest-version: ${{ github.event.release.tag_name }}
    compare-url-target-revision: ${{ github.event.release.target_commitish }}

- name: "release_compare_url"
  # https://github.com/org/repo/compare/v1.0.0...v1.1.0
  run: "echo ${{ steps.changelog-updater.outputs.release_compare_url }}"

- name: "release_url_fragment"
  # #v100---2021-02-01
  run: "echo ${{ steps.changelog-updater.outputs.release_url_fragment }}"

- name: "unreleased_compare_url"
  # https://github.com/org/repo/compare/v1.0.0...HEAD
  run: "echo ${{ steps.changelog-updater.outputs.unreleased_compare_url }}"
```

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/changelog-updater-action/tags).

We also provide major version tags to make it easier to always use the latest release of a major version. For example you can use `stefanzweifel/changelog-updater-action@v1` to always use the latest release of the current major version.
(More information about this [here](https://help.github.com/en/actions/building-actions/about-actions#versioning-your-action).)

## Credits

* [Stefan Zweifel](https://github.com/stefanzweifel)
* [All Contributors](https://github.com/stefanzweifel/changelog-updater-action/graphs/contributors)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/changelog-updater-action/blob/main/LICENSE) file for details.
