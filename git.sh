#!/bin/bash
git clone $GIT_URL $KOGITO_FOLDER
result=$(echo $?)
echo "git clone result: $result"
[ $result -eq 1 ] && exit 1
cd $KOGITO_FOLDER
git checkout $GIT_HASH
result=$(echo $?)
echo "git checkout result: $result"
[ $result -eq 1 ] && exit 1
echo "Finished checkout"
