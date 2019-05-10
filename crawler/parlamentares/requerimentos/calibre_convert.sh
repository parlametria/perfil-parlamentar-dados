#!/bin/bash

DIR_DATA=$1

for f in $(ls $DIR_DATA/); do
   echo $f
    for g in $(ls $DIR_DATA/$f/pdf/); do
      filename="${g%.*}"
      echo $filename
      ebook-convert $DIR_DATA/$f/pdf/$filename.pdf $DIR_DATA/$f/txt/$filename.txt
    done
done
