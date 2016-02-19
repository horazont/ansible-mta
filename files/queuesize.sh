#!/bin/bash
HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

cd "$(postconf -h queue_directory 2>/dev/null)"

while sleep "$INTERVAL"; do
    active=$((test -d active && find active -type f) | wc -l)
    deferred=$((test -d deferred && find deferred -type f) | wc -l)
    maildrop=$((test -d maildrop && find maildrop -type f) | wc -l)
    incoming=$((test -d incoming && find incoming -type f) | wc -l)
    corrupt=$((test -d corrupt && find corrupt -type f) | wc -l)
    hold=$((test -d hold && find hold -type f) | wc -l)
    echo "PUTVAL \"$HOSTNAME/postfix-mailqueue/gauge-active\" interval=$INTERVAL N:$active"
    echo "PUTVAL \"$HOSTNAME/postfix-mailqueue/gauge-deferred\" interval=$INTERVAL N:$deferred"
    echo "PUTVAL \"$HOSTNAME/postfix-mailqueue/gauge-maildrop\" interval=$INTERVAL N:$maildrop"
    echo "PUTVAL \"$HOSTNAME/postfix-mailqueue/gauge-incoming\" interval=$INTERVAL N:$incoming"
    echo "PUTVAL \"$HOSTNAME/postfix-mailqueue/gauge-corrupt\" interval=$INTERVAL N:$corrupt"
    echo "PUTVAL \"$HOSTNAME/postfix-mailqueue/gauge-hold\" interval=$INTERVAL N:$hold"
done
