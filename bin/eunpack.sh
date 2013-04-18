#!/bin/bash
PACKAGE="$1"

if [ ! -e "$PACKAGE" ]; then
  echo "Must specify a package."
  exit 1
fi

tar xjf "$PACKAGE"
(
  cd "${PACKAGE%.tar.bz2}"
  while [ 1 ]; do

    BASIS=$(ls | grep -v -E '\.epatch$' | sort -n | tail -1 2>/dev/null)
    if [ ! -e "$BASIS" ]; then
      echo "Couldn't find a basis file to work from."
      exit 1
    fi
    DIFF=$(ls ${BASIS}_*.epatch 2> /dev/null)
    SUFFIX=${DIFF#${BASIS}_}
    TARGET=${SUFFIX%.epatch}

    if [ -e "$DIFF" ]; then
      echo "Rebuilding $TARGET via $BASIS and $DIFF..."
      edelta -q patch $BASIS $TARGET $DIFF && rm $DIFF
    else
      echo "Looks like we're done here."
      exit 0
    fi
  done
)
