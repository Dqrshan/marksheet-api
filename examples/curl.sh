#!/usr/bin/env bash
#
# Every call in this file works without a key or a token.
#
#   bash examples/curl.sh
#
set -euo pipefail

BASE="https://vtu.drshn.tech/api"

echo "1. The schemes"
curl -s "$BASE" | head -20

echo
echo "2. The branch list of the 2022 scheme"
curl -s "$BASE/schemes/2022/branches" | head -20

echo
echo "3. One branch, with the credit total of each semester"
curl -s "$BASE/schemes/2022/branches/cs"

echo
echo "4. The courses of one semester"
curl -s "$BASE/schemes/2022/branches/cs/semesters/3"

echo
echo "5. The whole 2025 scheme in one response"
curl -s "$BASE/schemes/2025" -o /tmp/vtu-2025.json
echo "saved $(wc -c < /tmp/vtu-2025.json) bytes to /tmp/vtu-2025.json"

echo
echo "6. An unknown scheme returns a 404 with a JSON body"
curl -s -o /dev/null -w "status %{http_code}\n" "$BASE/schemes/2030"
curl -s "$BASE/schemes/2030"
