#!/bin/bash

# Check if gh command is installed
if ! command -v gh &> /dev/null
then
    echo "gh command could not be found. Please install the GitHub CLI."
    exit 1
fi

# Check if required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <email_address> <repo_list>"
    exit 1
fi

email_address=$1
repo_list=$2

IFS=',' read -ra repos <<< "$repo_list"
owner="bioconductor-source"
uid=$(gh api "/search/users?q=$email_address" --jq ".items[0].login")

for repo in "${repos[@]}"
do
    echo "Adding $uid for $email_address as writer to $owner/$repo"
    gh api --method PUT "/repos/$owner/$repo/collaborators/$uid" -f permission=write && git clone https://github.com/$owner/$repo && cd $repo && git remote add bioc https://git.bioconductor.org/packages/$repo && git pull bioc devel && git push origin devel && cd .. && rm -rf $repo
done
