#!/bin/bash
DIR=$1
DIR=${DIR%/}
TMPDIR=${DIR}
if [ -d "$DIR" ]; then
  pushd "$DIR" > /dev/null 2>&1
  ls | fgrep -v infiles.txt | sort -n > infiles.txt
  mkdir "$TMPDIR"
  cat infiles.txt | while read FNAME; do
    BASIS=$(grep -E -B 1 "^$FNAME\$" infiles.txt | grep -v $FNAME)
    if [ "$BASIS" != "" ]; then
      echo "Creating diff between $BASIS and $FNAME..."
      xdelta3 encode -9 -I 0 -s $BASIS $FNAME "$TMPDIR/${BASIS}_${FNAME}.xpatch"
    else
      export STARTING_POINT=$FNAME
    fi
  done
  INITIAL_FILE=$(head -1 infiles.txt)
  cp "$INITIAL_FILE" "$TMPDIR/"
  rm infiles.txt
  tar cjf "${DIR}.tar.bz2" "$TMPDIR/" && rm -rf "$TMPDIR"/
  popd > /dev/null 2>&1
  mv "${DIR}/${DIR}.tar.bz2" .
else
  echo "Must specify a directory."
  exit 1
fi

# Secondary compression:
#   -S [djw|fgk] -0..-9
# Disable checksum:
#   -n
# Disable small string-matching compression:
#   -N
# Memory options:
#   -B     bytes source window size
#   -W     bytes input window size
#   -P     size compression duplicates window
#   -I     size instruction buffer size (0 = unlimited)

