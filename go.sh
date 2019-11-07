#!/usr/bin/env bash
#shellcheck disable=SC2034
set -eauo pipefail

# @todo Pull JSON from API when complete
src=sites.json

numsites=$(jq ".sites | length" "$src")
i=0
while [ $i -lt "$numsites" ]
do
  json=$(jq ".sites[$i]" "$src")
  i=$(( i + 1 ))

  NAME=$(jq -r '.name' <<<"$json" | sed 's/[^a-zA-Z0-9._-]/-/g' | tr '[:upper:]' '[:lower:]' | tr -s '-')
  DESCRIPTION=$(jq -r '.description' <<<"$json")
  FROM=$(jq -r '.from' <<<"$json")
  TO=$(jq -r '.to' <<<"$json")

  numowners=$(jq ".owners | length" <<<"$json")
  j=0
  OWNERS=""

  echo "$(printf "%03d" $i) - $NAME :: $FROM => $TO"

  while [ $j -lt "$numowners" ]
  do
    owner=$(jq ".owners[$j]" <<<"$json")
    [ $j -gt 0 ] && OWNERS+=";"

    j=$(( j + 1 ))

    ownerName=$(jq -r '.name' <<<"$owner")
    ownerEmail=$(jq -r '.email' <<<"$owner")
    ownerUnit=$(jq -r '.unit' <<<"$owner")

    OWNERS+="$ownerName <$ownerEmail>"
  done

  OWNERS=$(echo "$OWNERS" | cut -c 1-63)

  [ -z "$OWNERS" ] && OWNERS="$DEFAULT_OWNER"

  dockerize -template "ingress.yaml.tmpl:ingress/ingress-$NAME.yaml"
done
