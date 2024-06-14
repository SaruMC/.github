#!/bin/bash

ORG_NAME="SaruMC"
README_FILE="README.md"


repo_count=0

page=1
per_page=100

while true; do
  response=$(curl -s -H "Authorization: token $GH_PAT" \
    "https://api.github.com/orgs/$ORG_NAME/repos?per_page=$per_page&page=$page")

  repos_in_page=$(echo "$response" | jq '. | length')

  if [ "$repos_in_page" -eq "0" ]; then
    break
  fi

  repo_count=$((repo_count + repos_in_page))
  page=$((page + 1))
done

# Update the README.md file
sed -i.bak "s/more than \[.* software projects\]/more than \[$repo_count software projects\]/" $README_FILE

# Commit and push changes if there are any updates
if ! git diff --quiet $README_FILE; then
  git config --global user.email "actions-user"
  git config --global user.name "actions@github.com"
  git add $README_FILE
  git commit -m "Update repository count in README.md"
  git push
fi
