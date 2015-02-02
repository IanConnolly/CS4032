CS4032
======

Assorted solutions to labs/assignments for TCD's CS4032 Distributed Systems
Michaelmas Term 2014.

* Labs 1 + 2 are written in Haskell.
* Lab 3/4 (The Chat Server) is written in Python.
* The Distributed File System Project is written in Ruby

## Installing Haskell

The [Haskell Platform](https://www.haskell.org/platform/) is the recommended
way to install Haskell (Note for OSX: it is no longer on Homebrew and must
be installed via the setup binary).

For the assignments without extra library dependencies (currently all of them),
you can get away with only having the Glasgow Haskell Compiler installed and
not the whole platform. However, I don't recommend this.

All assignments are compiled and tested on OSX 10.9 using GHC 7.6.3.

## Installing Python

UNIX distributions and OSX should come with Python installed already.

Python 2.7.x is required.

## Installing Ruby

* Install ruby-2.1.x via your system package manager.
* Install [http://bundler.io/](Bundler) via ```gem install bundler```

## Labs

All labs can be compiled as one by running ```./compile.sh``` from the root
of this repository or by running the individual folders' ```compile.sh```.

**Lab 1**

* Haskell dependencies, and any modern PHP version.
* ```./compile.sh```
* Start PHP echo server ```php -S localhost:8000```
* ```./client```

**Lab 2**

* Haskell Dependencies
* ```./compile.sh```
* ```./server <port-number>``` to start
* For interactive use: ```./client localhost 8000``` and follow prompts.

**Chat Server**

* Python dependencies
* ```python chat_server/lab4.py```

**Distributed File System**

* Ruby dependencies
* ```./compile.sh```
* ```bundle exec project/directory_server/dir-d --port <port>``` will start the directory server
* ```bundle exec project/distributed_file_server --port <port> --name <name> --folder <folderforstorage> --directory <host:port>``` will start the file server
* You can now use the ```remote_file_proxy``` library, either from a shell or in another Ruby application.