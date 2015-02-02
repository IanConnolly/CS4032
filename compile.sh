DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for d in $(find . -mindepth 1 -maxdepth 1 -type d); do
    /bin/bash "$d/compile.sh"
done
