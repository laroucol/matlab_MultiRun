# Global View
MultiRun is organized to be a stand-alone
[Matlab Package](http://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html),
 primarily to give access to the ```HashedRun``` class and ```modelMultiRun``` method.

# Directory Structure

The directory structure of the MultiRun project look something like this:

```bash
MultiRun
└── +MultiRun
    ├── +config
    ├── +lib
    │   ├── +allcomb
    │   ├── +glazer
    │   ├── +padlock
    │   └── +wordplay
    └── @HashedRun
```

## Directory Descriptions:

* ```+MultiRun```: The MultiRun package directory, everything under this folder
  is part of the MultiRun package
* ```+config```: Contains implementation-specific data for MultiRun, currently an enumeration
  containing error codes used is the only member of this subpackage.
* ```+lib```: Contains libraries/subpackages used by MultiRun. These packages
  are not properly parts of MutiRun, and are (usually) independently maintained.
  These should not be edited directly, but updated from their respective distributions
  (more on this later)
* ```@HashedRun```: Object folder containing the ```HashedRun``` object description.

# Subpackages

MultiRun makes use of several subpackages, locates in the ```+lib``` subdirectory,
These are all copyright their respective owners.  If you're running into trouble,
and suspect the issue is with one of these subpackages, a good first step is to check
that package's webpage, and see if a newer version has been released.

Due to the way that Matlab's packaging and import system works (as of 2011),
updating sublibraries is a pain. Any self-referencing done within packages must be
modified to reference the subpackage of MultiRun.

This is far from ideal, If anyone has a better way of doing this, their input
is much appreciated.

## E.g.
Glazer references itself in the function ```degreeToMaps```,
in MultiRun, this reference must be changed, so that MultiRun's
copy of Glazer points at itself (and not another version,
perhaps installed to the Matlab path). The difference between the two files
is:

```diff
--- matlab_glazer/+glazer/degreeToMaps.m
+++ matlab_MultiRun/+MultiRun/+lib/+glazer/degreeToMaps.m
@@ -21,7 +21,7 @@ function c = degreeToMaps(s)
 %


-  eg = glazer.EntryGetter(s);
+  eg = MultiRun.lib.glazer.EntryGetter(s);

   c = containers.Map();
```

## Subpackages Used By MultiRun
* [```+allcomb```](http://www.mathworks.com/matlabcentral/fileexchange/10064-allcomb) v3.0: Generates all combinations of inputs. By Jos.
* [```+glazer```](https://github.com/fmuzf/matlab_hk_glazer)v0.0.3: Reads DEBAM/DETiM ```input.txt``` files into Matlab ```containers.Maps``` objects.
By Lyman Gillispie.
* [```+padlock```](https://github.com/fmuzf/matlab_padlock) v0.0.4: A lock/status file library, MultiRun uses this to indicate runstatus on the filesystem. By Lyman Gillispie.
* [```+wordplay```](https://github.com/fmuzf/matlab_padlock) v0.0.4: Key-value option parser. Used to parse the parameter-value pairs in ```modelMultiRun```. By Lyman Gillispie.
* [```DataHash.m```](http://www.mathworks.com/matlabcentral/fileexchange/31272-datahash) 27 Jun 2012: Matlab checksum library, used to access Java's SHA-1 routines. Written by Jan Simon.
