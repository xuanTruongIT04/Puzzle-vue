#!/user/bin/env sh

set -e

npm install

npm run build

cd dist/

git init

git add -A

git commit -m "New Deployment"

git push -f https://github.com/xuanTruongIT04/Puzzle-vue master:gh-pages

cd -
