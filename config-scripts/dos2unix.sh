#!/bin/bash

workdir="/mnt/c/Users/pavel/projects/PavelSemyannikov_infra/ansible"

cd $workdir

for i in `find -name *.yml -type f`; do
	tr -d '\015' < $i > $i.tmp
	mv $i.tmp $i
done
