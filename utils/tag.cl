#!/bin/sh
if git status --porcelain | grep "^ M"
then
    printf "found uncommitted changes!\n"
    exit 223
fi
git_tags=$(git log --tags --simplify-by-decoration --pretty="format:%d")
last_tag=$(echo $git_tags | cut -f1 -d")")
last_version=$(echo $last_tag | sed -e 's/^.*tag: //' | cut -f1 -d"," | cut -f1 -d")")
last_version_number=${last_version#v}
version=$(grep Version DESCRIPTION | cut -f2 -d' ')
if test $last_version_number != $version; 
then
    git tag -a v${version}
fi
