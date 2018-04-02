#!/bin/bash

function replace_files()
{
	FILES=$(find . -type f -name $1)
	if [[ -n "${FILES}" ]]; then
		curl -L "$2" -o /tmp/$1
		for f in ${FILES}; do
			cp -vf /tmp/$1 ${f}
		done
	fi
}

replace_files config.guess 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
replace_files config.sub 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
