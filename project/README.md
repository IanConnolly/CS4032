## Distributed File System

* Ruby dependencies
* ```./compile.sh```
* ```bundle exec project/directory_server/dir-d --port <port>``` will start the directory server
* ```bundle exec project/distributed_file_server --port <port> --name <name> --folder <folderforstorage> --directory <host:port>``` will start the file server
* You can now use the ```remote_file_proxy``` library, either from a shell or in another Ruby application.


Implemented are:

* Local proxy library ([IanConnolly/remote_file_proxy](https://github.com/IanConnolly/remote_file_proxy))
* Distributed File Server ([IanConnolly/distributed_file_server](https://github.com/IanConnolly/distributed_file_server))
* Directory Service ([IanConnolly/directory_server](https://github.com/IanConnolly/directory_server))
* Caching ([distributed_file_server/lib/distributed_file_server/cache.rb](https://github.com/IanConnolly/distributed_file_server/blob/master/lib/distributed_file_server/cache.rb))
* Replication (inherent in [IanConnolly/distributed_file_server](https://github.com/IanConnolly/distributed_file_server))

Note:

Start as many distributed file servers as you like, and have your local proxy library connect to any of them.

You can override which server the library connects to with ```RFile.config! host, port```.

In general, start the directory server first before starting any distributed file servers. The Directory Server is
a SPOF for the directory service, but each individual file server will work independently of it.


Usage, (once servers are started):

```ruby
require 'remote_file_proxy'

RFile.config! localhost, 5000
f = RFile.open('test.txt', 'r')
f.write "test string"
f.close 
```

etc., with a significant amount of of Ruby's ```File``` class implemented.

