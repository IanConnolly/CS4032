#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
rm -rf $DIR/directory_server $DIR/distributed_file_server $DIR/remote_file_proxy
git clone https://github.com/IanConnolly/directory_server.git $DIR/directory_server
git clone https://github.com/IanConnolly/distributed_file_server.git $DIR/distributed_file_server
git clone https://github.com/IanConnolly/remote_file_proxy.git $DIR/remote_file_proxy
for d in */ ; do
    ( cd $DIR/$d ; bundle install )
done