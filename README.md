Impervious
==========

A tool for running the Hock Melt models with various configurations
from a base config file.

v 0.0.1
-------

Usage
-----

To run the model multiple times the function ```modelMultiRun``` is available.
This function takes as arguments
1. ```modelpath```: the full path to the model executable (may be debam or detim),
2. ```basefile```: the full path to a valid ```input.txt```, which is used as a
basis for each of the model runs
3. ```varargin```: model parameters which will be changed for each run, written as
keyword-value pairs, a la ```plot```.

__E.g.__
Suppose we run 
```matlab
basefile = '/home/luser/work/hock_mass_balance/config/base_input.txt';
modelpath = '/home/luser/local/bin/detim';

runs = impervious.modelMultiRun(modelpath, basefile, 'icekons', [5, 6.0], 'firnkons', [350, 351]);
```
at the Matlab repl. Impervious will take the config file
from ```/home/luser/work/hock_mass_balance/config/base_input.txt```
and generate ```input.txt``` files which contain every combination of the parameters
```icekons``` and ```firnkons```, given the values you've assigned them
(in this case there are four combinations).  To decrease the possibility
that one run will overwrite another, each generated file is placed in a directory
with name determined by the SHA-1 hash of the modified config file,
and the model's output is directed to that folder as well.
This model run will result in a directory structure which looks like:

```
mytest/
└── output
    ├── a729f3b8529edf74e2d57cf64ba8cc91fc64907e
    │   └── outpath
    ├── cdad489ead2ec45681e9a5ec91516623c88433ce
    │   └── outpath
    ├── d5c3a35650dcde462cc5eaea301cfbb62cd050d9
    │   └── outpath
    └── fbf399de8a6ac388aad1647ad918d37f9a3d81f1
        └── outpath
```
Since the long alpha-numeric directory names can be difficult to traverse, especially
when there are lots of them, ```multiModelRun``` also writes a file ```changes.txt```
which lists the changes made to to the base configuration for that run, i.e.:
```
$ cd mytest/output/a729f3b8529edf74e2d57cf64ba8cc91fc64907e/
$ ls
changes.txt     input.txt      outpath        runstatus.lock
$ cat changes.txt
Base config file: /home/luser/Documents/work/hock_mass_balance/mytest/input.txt
New config file: /home/luser/Documents/work/hock_mass_balance/mytest/output/a729f3b8529edf74e2d57cf64ba8cc91fc64907e/index.txt
Changes made:
  icekons = 6
  firnkons = 350
```



Installation
------------
1. Download and compile the latest version of the 
[Hock Melt Models](https://github.com/regine/meltmodel).
2. Download Impervious.
3. Make sure the folder ```+impervious``` is in your Matlab Path.
4. Done.

License
-------
BSD
