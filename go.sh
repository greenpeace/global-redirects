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

  FROM=$(jq -r '.from' <<<"$json")
  TO=$(jq -r '.to' <<<"$json")

  NAME=$(jq -r '.name | values | @sh' <<<"$json")
  [[ -z "$NAME" ]] && {
    NAME=$FROM
  }
  NAME=$(echo $NAME | sed 's/[^a-zA-Z0-9_ -]/-/g' | tr '.' '-' | tr '[:upper:]' '[:lower:]' | tr -s '-' | xargs)
  DESCRIPTION=$(jq -r '.description | values | @sh' <<<"$json")
  [[ -z "$DESCRIPTION" ]] && {
    DESCRIPTION="Redirects $FROM to https://$TO"
  }

  numowners=$(jq ".owners | length" <<<"$json")
  j=0
  OWNERS=""

  echo "$(printf "%03d" $i) - $NAME :: $FROM => $TO"

  while [ $j -lt "$numowners" ]
  do
    owner=$(jq ".owners[$j]" <<<"$json")
    [ $j -gt 0 ] && OWNERS+=";"

    j=$(( j + 1 ))

    ownerName=$(jq -r '.name | values' <<<"$owner")
    ownerEmail=$(jq -r '.email | values' <<<"$owner")
    ownerUnit=$(jq -r '.unit | values' <<<"$owner")

    OWNERS+="$ownerName $ownerUnit <$ownerEmail>"
  done

  OWNERS=$(echo "$OWNERS" | cut -c 1-63)

  [ -z "$OWNERS" ] && OWNERS="$DEFAULT_OWNER"

  dockerize -template "ingress.yaml.tmpl:ingress/ingress-$NAME.yaml"
done

echo
