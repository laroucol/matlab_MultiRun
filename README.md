MultiRun v 0.0.9
==========

A Matlab tool for facilitating parameter calibration of detim/debam.
Given a valid ```input.txt```, MultiRun can take ranges of model
parameters, and then execute DEBAM or DETiM for every permutation
of these parameters. Model output is directed into folders with
unique alphanumeric names to ensure that output data is not overwritten,
and that lengthy model runs do not need to be repeated. 

As of version 0.0.8, MultiRun is compatible with versions 2.x.x of DEBAM and DETiM,
and incompatible with earlier versions.  Version 0.0.7, which is compatible
with earlier versions on the models, are still available
[here](https://github.com/fmuzf/matlab_hk_MultiRun/releases).


### What you need:
  1. Compiled versions of DEBaM or DETIM.
  2. A valid ```input.txt``` file for said model. In this file, you
     should set all of the parameters to the one's you would like the model
     to use, with the exceptions of those MultiRun will change for each model run.
  3. Model inputs to go along with the model. See the model documentation for
     setting these up.
  4. A list of model parameters, combinations of which will be run by the model
     The syntax for this should be familiar
     from, for example, Matlab's ```plot``` function.  If we would like the model
     to read from ```base_input.txt``` run ```debam``` and run every combination
     of parameters, where ```icekons``` takes on every value in ```[5.0 : 0.1 : 6.0]```
     and ```firnkons``` takes on every value in ```[350 : 0.1 : 351]```
     we would make the call:
     ```matlab
     runs = modelMultiRun('detim', 'base_input.txt', 'icekons', [5.0:0.1:6.0], 'firnkons', [350:0.1:351]);
     ```
     This will result in one hundred model runs, wherein the configuration files passed to
     DETIM are identical to ```base_input.txt```, except that icekons and firnkons
     have been changed to match the values passed to modelMultiRun, and with
     output directories determined by a hashing function. In all, 100
     runs will occur, corresponding to the 100 pairings of an element of ```[5.0:0.1:6.0]```
     and ```[350:0.1:351]```.

Installation
------------
1. If you haven't already, download and compile the latest version of
  [DEBaM and DETIM](https://github.com/regine/meltmodel).
  MultiRun supports versions 2.x.x of the models.
  If you already have a version downloaded and compiled,
  there is no reason to re-download them, just use the copy you currently have.
2. Download MultiRun, either with ```git```, or download the
 [zipball](https://github.com/fmuzf/matlab_hk_MultiRun/archive/master.zip).
3. *Important*: Make sure the folder ```+MultiRun``` is in your Matlab Path; it's not enough
   to navigate to the containing folder with Matlab, as the script changes
   the working directory. Alternately, you can add the folder containing ```+MultiRun```
   to your Matlab Path.  Mathworks has helpful documentation 
   [about the Matlab Path](http://www.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html)
   and [how to change it](http://www.mathworks.com/help/matlab/ref/pathtool.html).
4. You're done. MultiRun is now available to Matlab, and you can access
    its functions and classes via ```MultiRun.<function/classname>```.


Quick Start
-----------
1. Compile DEBaM/DETIM. Install MultiRun. *Make sure MultiRun is in your Matlab path*.
2. Configure a ```input.txt``` parameter file for DEBaM/DETIM. Set all of the parameters
  for the model run to the values you want them to be when the model is run, except for the
  values you will be change using MultiRun, these can be set to anything.  This file can have any
  name, we call it ```input.txt``` by convention, MultiRun will read it, and use it
  to produce ```input.txt``` files for DEBaM/DETIM regardless of its name.
3. Open Matlab.
4. Is MultiRun in your Matlab path? Check by trying:
```
> MultiRun.modelMultiRun()
``` 
in Matlab.  Your *should get an error of the form: ```??? Input argument "config" is undefined.```.
If you get a different error, reinstall MultiRun.
5. For convenience, lets assign the *full path* to your ```input.txt``` file and the
  full path to the model executable you want to run to variables. i.e.
```matlab
> modelName = '/home/luser/meltmodel/bin/debam';
> configName = '/home/luser/my_glacier_folder/input.txt';
```
where you set ```modelName``` to the full filename of debam (detim, if you're going to run detim),
on your machine, an ```configName```` to the full filename of your ```input.txt```.
6. Run the ```modelMultiRun``` command from ```MultiRun```, to use matlab to run the model over
ranges of parameter values:
```
> [hashes, status, err, changes, runs] = MultiRun.modelMultiRun(modelName, configName, 'icekons', [5:0.1:6], 'rockkons', [0:0.1:0.5])
```
This will execute the model, modifying your ```input.txt``` so that
```icekons``` and ```rockkons``` take on every combination of values
in ```[5: 0.1 : 6]``` and ```[0 : 0.1 : 0.5]```, respectively.
7. The output of each model run is located in a subdirectory of the ```outpath``` you specified
in your original ```input.txt```. If ```outpath``` was set to ```/home/luser/modeloutput/```,
you will find subdirectories of ```/home/luser/modeloutput/```, with long alpha-numeric names.
Each directory contains:
  * An ```input.txt``` for a single run of the model.
  * A ```changes.txt``` file which describes the changes made to the original ```input.txt```.
  * A directory ```outpath```, which contains the output of that single model run, corresponding that ```input.txt```.
  * A file ```runstatus.lock```, which exists to assist ```MultiRun``` from re-running a specific parameter
    configuration more than once. If you need to re-run a configuration for some reason, this file should be deleted
    first.
8. In Matlab, ```modelMultiRun``` has returned quite a bit of information to you which you can use
to further manipulate your finished runs. These are outlined in the API below.
9. Have Fun! 


API (Available functions and How to Use them)
------
MultiRun provides a method for running the models over a range of
parameter values, as well as a helper class which manages each
individual run of the model, and ensures that the model is not
run more times than necessary.


## function modelMultiRun

To run the model multiple times the function ```modelMultiRun``` is available.

```[hashes, status, err, changes, runs] = MultiRun.modelMultiRun(modelpath, basefile, varargin)```

### Arguments: 

* ```modelpath``` - fully qualified path to the executable of the model you want to run (debam/detim).
* ```basefile``` - fully qualified path to a valid parameter file for the model, this will be modified based upon the the list of key-value
  pairs passed to varargin
* ```varargin``` - a list of key-value pairs which are modified, e.g.
 ```modelMultiRun('debam', 'input.txt', 'icekons', [5:0.1:6])```
 will run the model with ```icekons``` set to each value in ```[5:0.1:6]```.

### Returns:
* ```hashes``` - Cell array of hashes of each run
* ```status``` - status(i) = Array of return status of run with hash hashes{i}
* ```err``` - Error messages associated by incomplete runs
* ```changes``` - array of changes made to input.txt
* ```runs``` - a container.Maps indexed by hashes of HashedRun objects,
   each corresponding to a single model run.

### E.g.
Suppose we have a file ```base_input.txt```, which (aside from the name)
is a valid parameter file for DEBaM/DETIM, and a copy of ```detim``` (for example)
located at ```/home/luser/local/bin/detim```.
In Matlab, we run:
```matlab
basefile = '/home/luser/base_input.txt';
modelpath = '/home/luser/local/bin/detim';

 [hashes, status, err, changes, runs] = MultiRun.modelMultiRun(modelpath, basefile, 'icekons', [5, 6.0], 'firnkons', [350, 351]);
```
at the command line. MultiRun will take the parameter file
from ```/home/luser/base_input.txt``` and generate ```input.txt```
 files which contain every combination of the parameters
```icekons``` and ```firnkons```, given the values you've assigned them
(in this case there are four combinations).
 To decrease the possibility
that one run will overwrite another, each generated file is placed in a directory
with name determined by the SHA-1 hash of the modified parameter file,
and the model's output is directed to that folder as well.
If ```outpath``` is set to ```/home/luser/mytest``` in ```base_input.txt```,
this model run will result in a directory structure which looks like:

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
Once the parameter file is generates, Matlab then changes its
current working directory to the folder containing the parameter
file, and executes the command in ```modelpath``` (in our example ```detim```).

Since the long alpha-numeric directory names can be difficult to traverse, especially
when there are lots of them, ```multiModelRun``` also writes a file ```changes.txt```
which lists the changes made to to the original parameter file for that run, i.e.:
```bash
$ cd mytest/output/a729f3b8529edf74e2d57cf64ba8cc91fc64907e/
$ ls
changes.txt     input.txt      outpath        runstatus.lock
$ cat changes.txt
Base parameter file: /home/luser/mytest/input.txt
New parameter file: /home/luser/mytest/output/a729f3b8529edf74e2d57cf64ba8cc91fc64907e/index.txt
Changes made:
  icekons = 6
  firnkons = 350
```

### What happens:
For each run, MultiRun uses the helper class ```MultiRun.HashedRun``` to
generate a nearly-unique alpha-numeric identifier for that particular model run.
This is done by:
- Generating an ```input.txt``` file from the passed parameters,
- Taking the SHA-1 hash of the text in this file
- Modifying the ```outpath``` parameter of the ```containers.Map``` containing
  the configuration to ```<original-outpath>/<SHA hash>/outpath/```.

MultiModelRun returns several cell-arrays; entries with the same index correspond to the same model run
  1. ```hashes```: the SHA-1 hash of the ```input.txt``` parameter files
  2. ```status```: Returned status of the model run.
  3. ```err```: Sting detailing any errors encountered; is empty if none occur
  4. ```changes```: Strings listing any changes made to ```base_input``` for this run
  5. ```runs```: a ```containers.Map``` object, whose keys are the hashes of each run, and whose
    values are the HashedRun objects of each run.

- HashedRun checks to see whether or not there is already a parameter file in the new output path.
  This is done by checking a lockfile ```runstatus.lockfile```, the contents of which
  tell whether or not this parameter file has been run, is currently running, or is waiting to
  be run.
- If no lockfile is found, the new configuration file is written
  to disk at ```<original-outpath>/<SHA hash>/input.txt```.

- If a lockfile is found, it's status is returned and an error is posted.
- The model is run as a system subprocess, if any errors occur ```status[i]``` is
 set, and an error message is returned.
- In particular, if every entry in ```status``` is ```1```, we know that
 every model run exited successfully.


Each run is managed by a helper class called ```HashedRun```. The ```HashedRun``` class
manages the run; building a directory structure for that run alone, and ensuring that
each configuration is only run once.

## class HashedRun

Each run is managed by a ```HashedRun``` class, which makes the
appropriate directories, checks to see if the run has been completed
previously 


### Methods: 
  - ```hr = MultiRun.HashedRun(config, model)```
       Object constructor function
       __Arguments__: 
      * ```config```: The text of a valid Model 'input.txt'
      * ```model```: the fully-qualified path for the model executable

  - ```[success, err] = genConfig(self)```
       Generate this run's input.txt, and write it to disk.
       __Returns__: 
       * ```success``` : success code is
          - 0 something has gone wrong
          - 1 parameter file has been generated
          - 2 parameter file already existed
       * ```err```: error message, if empty everything is fine

  - ```[success, err] = runModel(self)```
       Execute the model, checking to make sure that the model hasn't run
       already.
       __Returns__:
       * ```success```: codes for completion are:
          - 0 : an error has occurred
          - 1 : The model has been run successfully
          - 2 : the lockfile indicates the model has
          already run
       * ```err```: error message.  

### Properties: 
  - ```configMap```: Map container containing info for the model run
  - ```hash```:  SHA-1 hash of input.txt corresponding to configMap
  - ```model```: Fully qualified path to model executable
  - ```outPath```L Path where model will be outputting
    


License
-------
BSD
