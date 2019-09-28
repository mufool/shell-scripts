#!/bin/bash

if [ $# != 2 ]; then
	echo "Usage : git_push.sh file|dir comment"
	exit 0;
fi

git add $1
git commit -m $2

git push -u origin master
