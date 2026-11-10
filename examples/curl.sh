#!/usr/bin/env bash
#
# Every call in this file works without a key, except the ones that read
# the course list.
#
#   bash examples/curl.sh
#
# Set MKS_KEY in the environment for the course level calls.
#
set -euo pipefail

BASE="https://dev.vtu.drshn.tech/api"
KEY="${MKS_KEY:-your-key}"

echo "1. The schemes"
curl -s "$BASE" | head -20

echo
echo "2. The branch list of the 2022 scheme"
curl -s "$BASE/schemes/2022/branches?limit=3" | head -30

echo
echo "3. One branch, with the credit total of each semester"
curl -s "$BASE/schemes/2022/branches/cs"

echo
echo "4. The courses of one semester, with a key"
curl -s "$BASE/schemes/2022/branches/cs/semesters/3" -H "X-API-Key: $KEY"

echo
echo "5. The whole 2022 scheme in one answer, with a key"
curl -s "$BASE/schemes/2022/export" -H "X-API-Key: $KEY" -o /tmp/vtu-2022.json
echo "saved $(wc -c < /tmp/vtu-2022.json) bytes to /tmp/vtu-2022.json"

echo
echo "6. A course level call without a key is refused"
curl -s -o /dev/null -w "status %{http_code}\n" "$BASE/schemes/2022/branches/cs/semesters/3"
curl -s "$BASE/schemes/2022/branches/cs/semesters/3"

echo
echo "7. An unknown scheme returns a 404 with a JSON body"
curl -s -o /dev/null -w "status %{http_code}\n" "$BASE/schemes/2030"
curl -s "$BASE/schemes/2030"

echo
echo "8. The limit headers are on every answer"
curl -s -D - -o /dev/null "$BASE/schemes" | grep -i "ratelimit\|retry-after" || true
