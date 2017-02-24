#!/bin/bash

# Author: Daniel Kesler (kesler.daniel@gmail.com)


BASE_DIR=$1

shift

echo $BASE_DIR
echo $@

for subdir in $(ls $BASE_DIR); do
	if [ -d "$BASE_DIR/$subdir" ]; then
		echo $@ >> $BASE_DIR/$subdir/modules.dep
	fi
done
