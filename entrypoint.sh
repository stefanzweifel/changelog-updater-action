#!/bin/sh -l

php /changelog-updater update \
--release-notes="$1" \
--latest-version="$2" \
--release-date="$3" \
--path-to-changelog="$4" \
--compare-url-target-revision="$5" \
--heading-text="$6" \
--github-actions-output \
--write
