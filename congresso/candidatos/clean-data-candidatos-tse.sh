#!/bin/bash

set -e
# set -d

for ano in 2010; do 
	DPATH="$PWD/consulta_cand_${ano}/*.txt"
	BPATH="$PWD/consulta_cand_${ano}_clean"
	TFILE="$PWD/out.tmp.$$"
	echo "Limpando dados de $ano"
	[ ! -d $BPATH ] && mkdir -p $BPATH || :
	for f in $DPATH
	do
	  if [ -f $f -a -r $f ]; then
	    /bin/cp -f $f $BPATH
	    sed -e 's/\([^"]\);\([^"]\)/\1|\2/g' -e 's/\([^"]\);"/\1|"/g' -e 's/";\([^"]\)/"|\1/g' -e 's/"//g' "$f" > $TFILE && mv $TFILE "$f"
	  else
	   echo "Error: Cannot read $f"
	  fi
	rm -rf $BPATH
	done
done
