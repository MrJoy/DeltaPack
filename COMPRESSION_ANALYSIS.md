# Delta Compression of Sequential HTML and JSON Snapshots

This is a comparison of 5 `ServiceMonth`s from Brad's accounts, applying a
handful of different techniques to see what produces the greatest net result.

The `ServiceMonth`s are:

* 156683:
  * AWS account.
  * HTML and both CSV formats.
  * 136 samples.
  * 1 fetch failure (truncated CSV -- partial CSV data in sample).
* 156684:
  * AWS account.
  * HTML only.
  * 615 samples.
  * 3 Fetch Failures
  * 1 hiccup where the HTML page was effectively empty of the main contents (header, sidebar, and footer were present, but no actual content was present).
* 172954:
  * AWS account.
  * HTML and both CSV formats.
  * 559 samples.
  * 1 hiccup where the HTML page was effectively empty of the main contents (header, sidebar, and footer were present, but no actual content was present -- naturally, no CSV data is present in this sample).
* 186941:
  * AWS account.
  * HTML and both CSV formats.
  * 189 samples.
  * First 3 samples without CSV data.
* 238416:
  * AWS account.
  * Programmatic access.
  * 4 samples.
  * All absolutely identical except for timestamps and bill IDs.

## TODO

Look into the following:

* vcdiff (HomeBrew 'open-vcdiff'; same algorithm as XDelta, but may produce different results?)
* gdiff (gem)


## Time Results

### Baseline, Natural Sort Order (tar + bzip2)

```bash
time for i in */; do tar cjf baseline_natural_${i%/}.tar.bz2 $i; done
```

    real  0m40.396s
    user  0m40.212s
    sys   0m0.174s

### Baseline, Guaranteed ID Sort Order (tar + bzip2)

```bash
time for i in */; do tar cjf baseline_id_sorted_${i%/}.tar.bz2 $(ls $i | sort | perl -pse "s/^/${i%/}\//g"); done
```

    real  0m40.076s
    user  0m39.899s
    sys   0m0.203s

### Baseline, Ascending Size Sort Order (tar + bzip2)

```bash
time for i in */; do tar cjf baseline_size_sorted_${i%/}.tar.bz2 $(ls -rS $i | perl -pse "s/^/${i%/}\//g"); done
```

    real  0m38.897s
    user  0m38.721s
    sys 0m0.180s

### BSDiff (bsdiff + tar + bzip2)

```bash
time for i in */; do ../bin/bspack.sh $i; mv ${i%/}.tar.bz2 bsdiff_${i%/}.tar.bz2; done
```

    real  1m6.319s
    user  0m58.799s
    sys   0m8.535s

### ZDelta (zdc + tar + bzip2)

```bash
time for i in */; do ../bin/zpack.sh $i; mv ${i%/}.tar.bz2 zdiff_${i%/}.tar.bz2; done
```

    real  0m18.589s
    user  0m13.273s
    sys   0m6.815s

### XDelta (xdelta3 + tar + bzip2)

```bash
time for i in */; do ../bin/xpack.sh $i; mv ${i%/}.tar.bz2 xdiff_${i%/}.tar.bz2; done
```

    real  0m47.207s
    user  0m14.217s
    sys   0m32.215s

### EDelta (edelta + tar + bzip2)

```bash
time for i in */; do ../bin/epack.sh $i; mv ${i%/}.tar.bz2 ediff_${i%/}.tar.bz2; done
```

    real  0m16.363s
    user  0m10.916s
    sys   0m6.746s


## Size Results

(All sizes are actual byte-sizes, not on-disk sizes)

### Uncompressed

* 156683:   26426405
* 156684:  134250992
* 172954:  131191883
* 186941:   36575494
* 238416:    1624384
* Total:   330069158

### Baseline, Natural Sort Order (tar + bzip2)

* 156683:     982229 ( 26.9:1)
* 156684:    5207143 ( 25.8:1)
* 172954:    5147085 ( 25.5:1)
* 186941:    1420943 ( 25.7:1)
* 238416:      32104 ( 50.6:1)
* Total:    12789504 ( 25.8:1)

### Baseline, Guaranteed ID Sort Order (tar + bzip2)

* 156683:     982253 ( 26.9:1)
* 156684:    5206928 ( 25.8:1)
* 172954:    5148157 ( 25.5:1)
* 186941:    1420965 ( 25.7:1)
* 238416:      32010 ( 50.7:1)
* Total:    12790313 ( 25.8:1)

Conclusion: Negligible size differences, not worth looking at much further.

### Baseline, Ascending Size Sort Order (tar + bzip2)

* 156683:     964936 ( 27.4:1)
* 156684:    5365817 ( 25.0:1)
* 172954:    5288551 ( 24.8:1)
* 186941:    1460766 ( 25.0:1)
* 238416:      32039 ( 50.7:1)
* Total:    13112109 ( 25.2:1)

Conclusion: Despite the promising result for SM#156683, this is just a net
loss.

### BSDiff (bsdiff + tar + bzip2)

* 156683:     300672 ( 87.9:1)
* 156684:    1308225 (102.6:1)
* 172954:     766600 (171.1:1)
* 186941:     208024 (175.8:1)
* 238416:      13720 (118.4:1)
* Total:     2597241 (127.1:1)

### ZDelta (zdc + tar + bzip2)

* 156683:     336841 ( 78.5:1)
* 156684:    3580786 ( 37.5:1)
* 172954:    1096961 (119.6:1)
* 186941:     221445 (165.2:1)
* 238416:      14130 (115.0:1)
* Total:     5250163 ( 62.9:1)

### XDelta (xdelta3 + tar + bzip2)

* 156683:     155644 (169.8:1)
* 156684:     984625 (136.3:1)
* 172954:     710515 (184.6:1)
* 186941:     212552 (172.1:1)
* 238416:      13271 (122.4:1)
* Total:     2076607 (158.9:1)

### EDelta (edelta + tar + bzip2)

* 156683:     250728 (105.4:1)
* 156684:    1823923 ( 73.6:1)
* 172954:     971447 (135.0:1)
* 186941:     333186 (109.8:1)
* 238416:      13731 (118.3:1)
* Total:     3393015 ( 97.3:0)

## Initial Conclusions Regarding Size and Speed

BSDiff clearly provides the good compression ratio, but comes at a roughly 50%
penalty in total wall-clock time.  It remains to be seen how that ratio holds
when using network-attached, or even locally-attached spinning disks instead of
an SSD but the clear result is that you're paying a fair amount for the extra
oomph BSDiff offers.

ZDelta presents a promising middle-ground, being faster than a simple tarball,
while apparently offering better overall compression.  That said, the huge
variance and very disappointing result on SM#156684 warrant a much more broad
test run before betting on such an approach, lest it have pathological cases
that produce even worse compression ratios.  Even if it doesn't, the short-term
cost of extra CPU time vs. the long-term cost of archival storage may make it
worth simply using BSDiff.

XDelta seems to be the king of the hill here, with a comparatively small
penalty over a baseline tarball but considerably better compression than
BSDiff.

EDelta, while being the fastest of the bunch, and in certain one-off tests
producing better compression between certain file-pairs than BSDiff, fares
poorly in terms of overall compression ratio -- but still comes out notably
better overall than ZDelta.  Interestingly, ZDelta does outcompress it in the
case of SM#186941 though.


## WTF Is Up With Service Month 156684?

Looks like 'hiccups' in the data cause ZDelta headaches.  The second sample in
the list below is a fetch failure:

```bash
ls -la 27048945.json 27053066.json 27058699.json
```

    -rwxr-xr-x    1 jfrisby  staff  231864 Apr 17 21:10 27048945.json
    -rwxr-xr-x    1 jfrisby  staff    3834 Apr 17 21:10 27053066.json
    -rwxr-xr-x    1 jfrisby  staff  179631 Apr 17 21:10 27058699.json


### Diffing 'Around' The Failure with BSDiff

```bash
bsdiff 27048945.json 27053066.json a.bspatch
bsdiff 27053066.json 27058699.json b.bspatch
bsdiff 27048945.json 27058699.json c.bspatch
```

For clarity:
* Patch 'a' is sample 1 -> sample 2.
* Patch 'b' is sample 2 -> sample 3.
* Patch 'c' is sample 1 -> sample 3.

We can guesstimate the benefits of sidestepping oddball entries by comparing
the compressed sizes of (sample 1 + patch 'a' + patch 'b') vs.
(sample 1 + sample 2 + patch 'c') and seeing what the net difference in tarball
size is.  It's a bit naive, but simply subtracting the difference from the
original tarball size should give us an estimate of the benefits.

Of course, there are actually *three* hiccups here, but I'm looking at just the
one for the moment for simplicity and expedience.

```bash
ls -la *.bspatch
```

    -rw-r--r--  1 jfrisby  staff    977 Apr 18 00:39 a.bspatch
    -rw-r--r--  1 jfrisby  staff  23153 Apr 18 00:39 b.bspatch
    -rw-r--r--  1 jfrisby  staff   1650 Apr 18 00:39 c.bspatch


```bash
tar cjf a.bspatch.tbz2 27048945.json a.bspatch b.bspatch
tar cjf b.bspatch.tbz2 27048945.json c.bspatch 27053066.json
ls -la *.bspatch.tbz2
```

    -rw-r--r--  1 jfrisby  staff  53799 Apr 18 00:39 a.bspatch.tbz2
    -rw-r--r--  1 jfrisby  staff  29856 Apr 18 00:39 b.bspatch.tbz2

A net reduction of 23943 bytes, or 44% for that slice of data.

### Diffing 'Around' The Failure with ZDelta

```bash
zdc 27048945.json 27053066.json a.zpatch
zdc 27053066.json 27058699.json b.zpatch
zdc 27048945.json 27058699.json c.zpatch
ls -la *.zpatch
```

    -rw-r--r--  1 jfrisby  staff    616 Apr 18 00:39 a.zpatch
    -rw-r--r--  1 jfrisby  staff  25110 Apr 18 00:39 b.zpatch
    -rw-r--r--  1 jfrisby  staff  22861 Apr 18 00:39 c.zpatch


```bash
tar cjf a.zpatch.tbz2 27048945.json a.zpatch b.zpatch
tar cjf b.zpatch.tbz2 27048945.json c.zpatch 27053066.json
ls -la *.zpatch.tbz2
```

    -rw-r--r--  1 jfrisby  staff  55476 Apr 18 00:39 a.zpatch.tbz2
    -rw-r--r--  1 jfrisby  staff  53080 Apr 18 00:39 b.zpatch.tbz2

Notably, ZDelta does not like diffing from sample 1 to sample 3 for some
reason, so the net win here is pretty negligible.

### Diffing 'Around' The Failure with XDelta


```bash
xdelta3 encode -s 27048945.json 27053066.json a.xpatch
xdelta3 encode -s 27053066.json 27058699.json b.xpatch
xdelta3 encode -s 27048945.json 27058699.json c.xpatch
ls -la *.xpatch
```

    -rw-r--r--  1 jfrisby  staff    853 Apr 18 02:13 a.xpatch
    -rw-r--r--  1 jfrisby  staff  32422 Apr 18 02:13 b.xpatch
    -rw-r--r--  1 jfrisby  staff   2539 Apr 18 02:13 c.xpatch

```bash
tar cjf a.xpatch.tbz2 27048945.json a.xpatch b.xpatch
tar cjf b.xpatch.tbz2 27048945.json c.xpatch 27053066.json
ls -la *.xpatch.tbz2
```

    -rw-r--r--  1 jfrisby  staff  57407 Apr 18 02:13 a.xpatch.tbz2
    -rw-r--r--  1 jfrisby  staff  30227 Apr 18 02:13 b.xpatch.tbz2

XDelta does very poorly 'recovering' from the hiccup, unlike BSDiff, but does
a respectable job when circumventing it.

### Diffing 'Around' The Failure with EDelta

```bash
edelta -q delta 27048945.json 27053066.json a.epatch
edelta -q delta 27053066.json 27058699.json b.epatch
edelta -q delta 27048945.json 27058699.json c.epatch
ls -la *.epatch
```

    -rw-r--r--  1 jfrisby  staff    753 Apr 18 02:43 a.epatch
    -rw-r--r--  1 jfrisby  staff  25575 Apr 18 02:43 b.epatch
    -rw-r--r--  1 jfrisby  staff   1812 Apr 18 02:43 c.epatch

```bash
tar cjf a.epatch.tbz2 27048945.json a.epatch b.epatch
tar cjf b.epatch.tbz2 27048945.json c.epatch 27053066.json
ls -la *.epatch.tbz2
```

    -rw-r--r--  1 jfrisby  staff  56078 Apr 18 02:43 a.epatch.tbz2
    -rw-r--r--  1 jfrisby  staff  30207 Apr 18 02:43 b.epatch.tbz2

EDelta shows similar characteristics to BSDiff here.


## Initial Conclusions On Outlier Elements

It may be worth investigating a variety of easy-win techniques to try and
mitigate the impact of outlier elements here.  Size-based sort-ordering,
while not useful for plain tarballs, may be of more benefit with the delta
approaches.  Another option might be to identify outliers in terms of a moving
average and stddev, and create a separate 'channel' for them when performing
delta compression.

Also, given the observation that the programmatic-access data is *exactly*
identical, except for metadata -- and this will be a common scenario in
practice most likely, it may be worth splitting data and metadata channels out
before performing delta compression, then compressing each as a separate
stream.  Perhaps even going as far as to identify and maintain a duplication
table -- although that may be overkill as it seems likely that exact
duplication will occur in temporal order and the diffs should handle it just
fine.  Alternatively, ordering data streams by MD5 may be an elegant way to
resolve this issue gracefully.

## A Quick Experiment With Size Ordering

### BSDiff (bsdiff + tar + bzip2)

* 156683:     136406 (193.7:1)
* 156684:    1251915 (107.2:1)
* 172954:    1092412 (120.1:1)
* 186941:     313983 (116.5:1)
* 238416:      13740 (118.2:1)
* Total:     2808456 (117.5:1)

### ZDelta (zdc + tar + bzip2)

* 156683:     116583 (226.7:1)
* 156684:    1333179 (100.7:1)
* 172954:    1194498 (109.8:1)
* 186941:     346543 (105.5:1)
* 238416:      14147 (114.8:1)
* Total:     3004950 (109.8:1)

### XDelta (xdelta3 + tar + bzip2)

* 156683:      95982 (275.3:1)
* 156684:    1398207 ( 96.0:1)
* 172954:    1226329 (107.0:1)
* 186941:     357875 (102.2:1)
* 238416:      13279 (122.3:1)
* Total:     3091672 (106.8:1)

### EDelta (edelta + tar + bzip2)

* 156683:     127883 (206.6:1)
* 156684:    1962229 ( 68.4:1)
* 172954:    1719066 ( 76.3:1)
* 186941:     547353 ( 66.8:1)
* 238416:      13815 (117.6:1)
* Total:     4370346 ( 75.5:1)

## Initial Conclusions About Size Ordering

While this shored up the worst-case for BSDiff quite a bit, BSDiff overall
seems to have come out behind (117.5:1 vs. 127.1:1) -- although it may be worth
investigating how the differing sort orders generalize.

On the other hand, ZDelta made enormous strides here (127.1:1 vs. 62.9:1) --
enough that it may be worth looking at it as an alternative to BSDiff after
all.

XDelta on the other hand, lost out in a big way, despite gaining huge ground on
SM#156683.

EDelta -- not even worth discussing.
