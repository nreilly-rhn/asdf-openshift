#!/usr/bin/env bash

set -euo pipefail


fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

list_all_versions() {
  curl -sL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/ \
    | sed -n 's/.*<a href="\(4\.[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\)\/">/\1/'p \
  	| sort -t. -k 2,2n -k 3,3n \
  	| sed ':a; N; $!ba; s/\n/ /g'
  printf "${versions}"
}