#!/bin/bash

set -e

dir=$1

names="kimkh415 aseibel saospark carlosv yuhengz"

for name in ${names};
do
	setfacl -m user:${name}:rwx ${dir};
done
