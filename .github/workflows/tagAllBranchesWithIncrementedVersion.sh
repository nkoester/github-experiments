#!/bin/bash
#
#
# author: Norman Köster
# date: 08.08.2023
# description: This script will automatically tag all MPS branches in the
# repository with the next following version number.
# E.g.: if the last release was $PREFIX.132, this script will create the tags
# 2020.3.133, 2021.1.133, 2021.2.133, 2021.3.133, and 2022.2.133
# version: 1.0
#
#

export previousNextVersion=0
for versionPrefix in "2020.3" "2021.1" "2021.2" "2021.3" "2022.2"; do

    #calculate the next version number
    lastVersion=$(git tag | grep "^${versionPrefix}\.[0-9]*$" | sort -V | tail -n1 | cut -d . -f 3)
    nextVersion=$((lastVersion+1))

    # sanity check
    [[ -z "${lastVersion}" || -z "${nextVersion}"  ]] && echo "Abort due to empty Variable: '${lastVersion} | ${nextVersion}" && exit 1

    # sanity check: avoid diverging version numbers
    if [[ "${previousNextVersion}" != "0"  ]]; then
        [[ "${nextVersion}" != "${previousNextVersion}" ]] && echo "Version mismatch across MPS branches: '${nextVersion} | ${previousNextVersion}" && exit 1
    fi
    # remember the nextVersion
    export previousNextVersion=${nextVersion}

    # actually tag the current branch
    newTag="${versionPrefix}.${nextVersion}"
    echo "New Tag for ${versionPrefix} will be ${newTag}"
    git tag "${versionPrefix}.${nextVersion}"
done

# pushing the tags will trigger the release for each branch
git push --tags
