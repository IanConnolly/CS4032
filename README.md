CS4032
======

Assorted solutions to labs/assignments for TCD's CS4032 Distributed Systems
Michaelmas Term 2014.

All assignments are written using Haskell. They are currently free from library
dependencies, though any exceptions will be noted in the specific subsection
for that assignment.

## Installing Haskell

The [Haskell Platform](https://www.haskell.org/platform/) is the recommended
way to install Haskell (Note for OSX: it is no longer on Homebrew and must
be installed via the setup binary).

For the assignments without extra library dependencies (currently all of them),
you can get away with only having the Glasgow Haskell Compiler installed and
not the whole platform. However, I don't recommend this.

All assignments are compiled and tested on OSX 10.9 using GHC 7.6.3.

## Labs

All labs can be compiled as one by running ```./compile.sh``` from the root
of this repository or by running the individual folders' ```compile.sh```.

**Lab 1**

* No extra dependencies
* ```./compile.sh```
* Start PHP echo server ```php -S localhost:8000```
* ```./lab1```

**Lab 2**

* No extra dependencies
* ```./compile.sh```
* ```./server <port-number>``` to start
* For interactive use: ```./client localhost 8000``` and follow prompts.
