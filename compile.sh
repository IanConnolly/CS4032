DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for d in */ ; do
    /bin/bash "$DIR/$d/compile.sh"
done
