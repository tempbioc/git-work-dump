#!/bin/bash

if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "GitHub CLI is not authenticated. Please authenticate with 'gh auth login'."
    exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <organization-name> <file_with_git_urls>"
    exit 1
fi

ORG_NAME="$1"
URL_FILE="$2"
pkginfo="/tmp/pkginfo"

while IFS= read -r repo_url; do
    REPO_NAME=$(basename "$repo_url")
    
    echo "Processing repository: $REPO_NAME"
    git ls-remote https://github.com/$ORG_NAME/$REPO_NAME devel > $pkginfo && if [ -z "$(cat $pkginfo)" ]; then echo "$REPO_NAME exists and is empty"; else echo "$REPO_NAME exists and is not empty."; continue; fi || ( gh repo create "$ORG_NAME/$REPO_NAME" --public && sleep 10 || sleep 6000 )
    rm -rf $pkginfo

    echo "Cloning $repo_url into $ORG_NAME/$REPO_NAME"
    git clone "$repo_url" "$REPO_NAME" || cd "$REPO_NAME"/.. || echo "$repo_url" >> exceptions
    cd "$REPO_NAME" || continue
    git remote remove origin
    git remote add origin "https://github.com/$ORG_NAME/$REPO_NAME.git"
    git push -u origin --all

    cd ..
    rm -rf "$REPO_NAME"

    echo "Finished processing $REPO_NAME"
done < "$URL_FILE"

echo "All repositories have been processed."

