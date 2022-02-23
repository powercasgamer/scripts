#!/bin/bash

git add .
git commit -m "update" -s
git push origin master
./ban.sh