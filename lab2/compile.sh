#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ghc "$DIR/server.hs" -XBangPatterns
ghc "$DIR/client.hs"
find $DIR -name "*.o" -o -name "*.hi" | xargs rm
chmod +x "$DIR/server"
chmod +x "$DIR/client"
