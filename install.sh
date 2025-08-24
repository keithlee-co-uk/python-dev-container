#!/bin/bash

PRJ_PATH=$(dirname "$(readlink -f "$0")")
cd $PRJ_PATH

# make the `dev` script available to the user

mkdir -p ~/bin
cat dev|sed "s,PRJ_PATH,${PRJ_PATH},g" > ~/bin/dev
chmod u+x ~/bin/dev


