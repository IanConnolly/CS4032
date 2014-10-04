DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ghc "$DIR/server.hs"
ghc "$DIR/client.hs"
