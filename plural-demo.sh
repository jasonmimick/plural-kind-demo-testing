#!/usr/bin/env bash

REPO="${1:-$(whoami)-plural-demo}"
gh repo create "${REPO}" --public \
    --clone \
    --description "Plural Rocks"

cd "${REPO}"
echo "Created new GitHub repository: ${REPO} (pwd=$(pwd))"
echo "${REPO} \nMy first Plural deployment, hold on" > README.md
git add .
git status
sleep 5
git commit -a -m "README"
git branch -m main
git push --set-upstream origin main
sleep 5
echo "Starting plural project creation and local depoyment with kind"
plural init
plural bundle install console console-kind
plural build
plural deploy --commit "$(whoami)'s first deployment"
