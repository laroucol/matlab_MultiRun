Wordplay
==========
v 0.0.2
-----

A simple-minded keyword argument parser for Matlab. Takes a
list of keyword - value pairs and returns paired lists. 
Useage
------
 
```matlab
>> [keys, vals] = wordplay.getKwargs('greeting', 'hello', 'name', 'Chad', 'age', 35)

keys = 

    'greeting'    'name'    'age'


vals = 

    'hello'    'Chad'    [35]
```


Installation
------------
1. Download. 
2. Place ```+wordplay`` in your MATLAB path.


License
-------
BSD
