#!/bin/bash
for METHODS in edelta xdelta bsdiff "edelta xdelta" "edelta bsdiff" "xdelta bsdiff" "xdelta edelta bsdiff"; do
  rm -rf *.dpack*
  ELAPSED=$( (time ./sample.rb $METHODS > /dev/null) 2>&1 | grep real | awk '{ print $2 }' )
  echo "* $METHODS: $ELAPSED"
  bzip2 -9 *.dpack
  for PACK in *.dpack.bz2; do
    echo "  * ${PACK%.dpack.bz2}: $(printf "%10d" $(($(stat -f%z $PACK) + 0)))"
  done
done
