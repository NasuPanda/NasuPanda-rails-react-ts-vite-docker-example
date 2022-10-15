#!/bin/sh

# 参考 : Riakuto!
# リンターを走らせるシェルスクリプト。コミット前に実行する。

# lint-staged-around
#   execute each lint-staged entry in sub-directories projects recursively
#
#   Riakuto! Project by Klemiwary Books

fileTypes="js|jsx|ts|tsx|html|css|less|sass|scss|gql|graphql|json"
target="src|public"

# detect git against tag
if git rev-parse --verify HEAD >/dev/null 2>&1
then
  against=HEAD
else
  # Initial commit: diff against an empty tree object
  against=$(git hash-object -t tree /dev/null)
fi

if [ "$(uname)" == "Darwin" ]; then
  sedOption='-E'
else
  sedOption='-r'
fi

# pick staged projects
stagedProjects=$( \
  git diff --cached --name-only --diff-filter=AM $against | \
  grep -E ".*($target)\/" | \
  grep -E "^.*\/.*\.($fileTypes)$" | \
  grep -vE "(package|tsconfig).*\.json" | \
  sed $sedOption "s/($target)\/.*$//g" | \
  uniq \
)

# execute each lint-staged
rootDir=$(pwd | sed $sedOption "s/\/\.git\/hooks//")

for project in ${stagedProjects[@]}; do
  echo "Executing $project lint-staged entry..."
  cd "$rootDir/$project"
  npx lint-staged 2>/dev/null
done
