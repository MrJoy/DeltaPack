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


## Initial Conclusions Regarding Size and Speed

BSDiff clearly provides the best compression ratio, but comes at a roughly 50%
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


## Initial Conclusions On Outlier Elements

It may be worth investigating a variety of easy-win techniques to try and
mitigate the impact of outlier elements here.  Size-based sort-ordering,
while not useful for plain tarballs, may be of more benefit with the delta
approaches.  Another option might be to identify outliers in terms of a moving
average and stddev, and create a separate 'channel' for them when performing
delta compression.

Also, given the observation that programmatic-access data is *exactly*
identical, except for metadata, it may be worth splitting data and metadata
channels out before performing delta compression, then compressing each as
a separate stream.  Perhaps even going as far as to identify and maintain a
duplication table -- although that may be overkill as it seems likely that
exact duplication will occur in temporal order and the diffs should handle it
just fine.  Alternatively, ordering data streams by MD5 may be an elegant way
to resolve this issue gracefully.

## A Quick Experiment With Size Ordering

