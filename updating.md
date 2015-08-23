# Updating MultiRun

As the models are updated, Multirun may also need to be modified to track these
changes. In particular, changes to the format of ```input.txt``` will break
MultiRun, and require changes.

## Updating glazer to reflect changes to input.txt
Due to the positional nature of ```input.txt``` any change to the format of
```input.txt``` requires corresponding changes to the methods used by MultiRun
to read and write copies of ```input.txt```.

These methods reside in two files:
1) The reader: ```matlab_MultiRun/+MultiRun/+lib/+glazer/degreeToMaps.m```
2) The writer: ```matlab_MultiRun/+MultiRun/+lib/+glazer/mapToDegrees.m```
both of which will need to be updated to comply with a new ```input.txt```.

We're going to proceed by imagining that we're adding a new variable to
```input.txt``` called ```meanconductivity```.

### Updating ```mapToDegrees```
We'll begin with what needs to be modified in the writer method.

```mapToDegrees``` works by accepting a dictionary object which contains the
configuration variable names as keys with the corresponding values being the
dictionary values, the method then builds ```input.txt``` as a sting, which
later is written to a file. Most lines in ```mapToDegrees``` use Matlab's
```sprintf``` function to format a single line of the new ```input.txt``` file,
including the value of the variable to be written, as well as the corresponding
comment.

Adding a new variable to ```input.txt``` is as easy as adding a new line to the
file of the form
```matlab
ostr = [ostr sprintf('%s    %%mean conductivity of ice. meanconductivity\n', dropZeros(CC('meanconductivity')];
```
Let's break down what's happening in this line.
1) First, we retrieve the value of ```meanconductivity``` from the Map object
we've passed to mapToDegrees.
```matlab
CC('meanconductivity')
```
2) Since ```meanconductivity``` is a floating point value, we use a helper value
```dropZeros``` to format the number into a string without any trailing zeros,
this function is defined in the bottom of ```mapToDegrees.m```.
```matlab
dropZeros(CC('meanconductivity'))
```
3) We use ```sprintf``` to convert this output into a string including any
comments we want to include in ```input.txt```. We use the ```%s``` format
parameter because the output of ```dropZeros``` is a string; different data
types require different formatting parameters to correctly format i.e. ```%i```
for integers.
```matlab
sprintf('%s    %%mean conductivity of ice. meanconductivity\n', dropZeros(CC('meanconductivity')
```
4) Matlab treats strings as arrays of characters, so we use its array
concatenation syntax to join the string we've created to the end of the existing
```input.txt``` string, ```ostr```.
```matlab
ostr = [ostr sprintf('%s    %%mean conductivity of ice. meanconductivity\n', dropZeros(CC('meanconductivity')];

```

### Updating ```degreeToMaps```
Now we tackle modifying the reader method: ```degreeToMaps.m```.
This method reads in a string which we have read from ```input.txt```, reads the
values for specific variables based on their location within the file, and
inserts them into a Maps object.

A typical line in ```degreeToMaps``` looks like:
```matlab
c('loutyes') = toInt(linePosOffset(15, 11));
```
Let's break down what this call does:
1) First we read in the 11th word of line 15
```matlab
linePosOffset(15, 11)
```
3) We then convert the returned sting ro an Integer
```matlab
toInt(linePosOffset(15, 11))
```
4) Finally, we assign the value of ```'loutyes'``` in our Map ```c``` to this integer
```matlab
c('loutyes') = toInt(linePosOffset(15, 11));
```
Adding a new variable to input.txt consists of adding a line such as the above,
and then modifying each line where a variable in input.txt occurs _after_ the newly added variable
to reflect the new line number on which it is now found.

For example, suppose we add the variable ```meanconductivity``` on line 103 of
```input.txt```. we would add the line:
```matlab
c('meanconductivity') = str2double(lineposOffset(103, 1));
```
to ```degreeToMaps```.
Then, we would update the lines corresponding to variables which come later in ```input.txt```:

```diff
--- matlab_MultiRun/+MultiRun/+lib/+glazer/degreeToMaps.m
+++ matlab_MultiRun/+MultiRun/+lib/+glazer/degreeToMaps.m

  c('meanconductivity') = str2double(lineposOffset(103, 1));
-  c('albsnow') = str2double(lineposOffset(103, 1));
-  c('albslush') = str2double(lineposOffset(104, 1));
-  c('albice') = str2double(lineposOffset(105, 1));
-  c('albfirn') = str2double(lineposOffset(106, 1));
-  c('albrock') = str2double(lineposOffset(107, 1));
+  c('albsnow') = str2double(lineposOffset(104, 1));
+  c('albslush') = str2double(lineposOffset(105, 1));
+  c('albice') = str2double(lineposOffset(106, 1));
+  c('albfirn') = str2double(lineposOffset(107, 1));
+  c('albrock') = str2double(lineposOffset(108, 1));
.
.
.
```
