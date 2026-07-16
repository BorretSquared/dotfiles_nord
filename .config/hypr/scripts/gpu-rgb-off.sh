#!/bin/bash

set -u

GPU_NAME="Intel Arc A770 Limited Edition"

for attempt in 1 2 3 4 5; do
    if openrgb --noautoconnect -d "$GPU_NAME" -m Direct -c 000000 >/dev/null 2>&1; then
        exit 0
    fi

    sleep 2
done

exit 1