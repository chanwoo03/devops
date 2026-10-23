#!/bin/bash

cd "$(dirname "$0")" || exit 1

for i in $(seq 1 720); do
    if IDS="$(docker compose ps --status running -q web)"; then
        COUNT="$(printf '%s\n' "$IDS" |
                 awk 'NF {n++} END {print n+0}')"

        if [ "$COUNT" -lt 3 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') web ${COUNT}개: 복구 시도" \
                >> keep-web.log

            if docker compose up -d --scale web=3; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') 복구 명령 성공" \
                    >> keep-web.log
            else
                echo "$(date '+%Y-%m-%d %H:%M:%S') 복구 명령 실패" \
                    >> keep-web.log
            fi
        fi
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') 개수 조회 실패" \
            >> keep-web.log
    fi

    sleep 5
done
