#!/bin/bash -v
test -n "$KUBECFG" || KUBECFG=./bin/kubectl
test -x "$KUBECFG" || {
    echo "error: missing kubectl executable at $KUBECFG" >&2
    exit 1
}

test -n "$servicehost" || servicehost=$(hostname -i|cut -f1 -d' ')
test -n "$servicehost" || {
    echo "failed to determine service host" >&2
    exit 1
}

ts=$(date +'%Y%m%d%H%M%S')

for prof in heap block; do
    curl http://${servicehost}:10251/debug/pprof/$prof >framework.$ts.$prof
    minions=$($KUBECFG get nodes|sed -e '1d' -e '/^$/d' -e 's/[ \t]\+.*$//g')
    for m in $minions; do
        curl http://${m}:10250/debug/pprof/$prof >minion.${m}.$ts.$prof
    done
done
