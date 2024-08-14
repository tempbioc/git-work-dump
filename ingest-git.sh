#!/bin/bash

if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "GitHub CLI is not authenticated. Please authenticate with 'gh auth login'."
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_with_git_urls>"
    exit 1
fi

URL_FILE=$1
ORG_NAME="tempbioc"

while IFS= read -r repo_url; do
    REPO_NAME=$(basename "$repo_url")
    
    echo "Processing repository: $REPO_NAME"

    echo "Cloning $repo_url into $ORG_NAME/$REPO_NAME"
    git clone "$repo_url" "$REPO_NAME" && gh repo create "$ORG_NAME/$REPO_NAME" --public || exit
    cd "$REPO_NAME"
    git remote remove origin
    git remote add origin "https://github.com/$ORG_NAME/$REPO_NAME.git"
    git push -u origin --all

    cd ..
    rm -rf "$REPO_NAME"

    echo "Finished processing $REPO_NAME"
done < "$URL_FILE"

echo "All repositories have been processed."

