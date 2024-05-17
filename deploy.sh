#!/user/bin/env sh

set -e

npm run generate

cd dist/

git init

git add -A

git commit -m "New Deployment"

git push -f https://github.com/xuanTruongIT04/Puzzle-vue master:gh-pages

cd -
