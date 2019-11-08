#!/usr/bin/env bash
#shellcheck disable=SC2034
set -eauo pipefail

main() {
  # @todo Pull JSON from API when complete
  local src=$1
  local i=0

  mkdir -p ingress

  for site in $(jq -rc '.sites' $src | jq -r '.[] | @base64'); do
    _jq() {
      echo ${site} | base64 --decode | jq -r ${1}
    }

    i=$(( i + 1 ))

    FROM=$(_jq '.from')
    TO=$(_jq '.to')

    NAME=$(_jq '.name')
    DESCRIPTION=$(_jq '.description')

    [[ "$NAME" == "null" ]] && {
      NAME=$FROM
    }
    NAME=$(echo $NAME | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_ -]/-/g' | tr '.' '-' | tr -s '-' | xargs)

    [[ "$DESCRIPTION" == "null" ]]&& {
      DESCRIPTION="Redirects $FROM to https://$TO"
    }

    OWNERS=""
    j=0
    for owner in $(_jq '.owners' | jq -r 'values | .[] | @base64'); do
      _owner() {
        echo ${owner} | base64 --decode | jq -r "${1} | values"
      }
      [[ $j -gt 0 ]] && OWNERS+="; "
      OWNERS+="$(_owner '.name') $(_owner '.unit') <$(_owner '.email')>"
      j=$(( j + 1 ))
    done

    [[ -z "$OWNERS" ]] && OWNERS="${DEFAULT_OWNER:-}"

    printf "$(printf "%03d" $i) - $NAME :: $(_jq '.from') => $(_jq '.to')"
    printf " == %s\n" "$OWNERS"

    dockerize -template "ingress.yaml.tmpl:ingress/ingress-$NAME.yaml"
  done
}

main ${1:-sites.json}
