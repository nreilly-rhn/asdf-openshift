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

install_version() {  
  local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"
  local arch="$4"
  local platform="$5"
  
  declare -A tools=([opensift-client]=oc [openshift-install]=openshift-install [oc-mirror]=oc-mirror)
  for tool in "${!tools[@]}"; do
    #curl "${curl_opts}" 
    echo "${tool}: ${tools[$tool]}"
	  printf "install_type: ${install_type}\n"
    printf "version: ${version}\n"
    printf "install_path: ${install_path}\n"
    printf "arch: ${arch}\n"
    printf "platform: ${platform}\n"
  done
#
	#if [ "$install_type" != "version" ]; then
	#	fail "asdf-$TOOL_NAME supports release installs only"
	#fi
#
	#(
	#	mkdir -p "$install_path"
	#	cp -r "$ASDF_DOWNLOAD_PATH"/promtool "$install_path"
#
	#	local tool_cmd
	#	tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
	#	test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."
#
	#	echo "$TOOL_NAME $version installation was successful!"
	#) || (
	#	rm -rf "$install_path"
	#	fail "An error occurred while installing $TOOL_NAME $version."
	#)
}

get_arch() {
	local machine
	machine=$(uname -m)

	if [[ "$machine" =~ "x86_64" ]]; then
		echo "amd64"
		return
	elif [[ "$machine" =~ arm.* ]]; then
		echo "$machine"
		return
	fi

	fail "Unknown arch"
}

get_platform() {
	local uname
	uname=$(uname)

	if [[ "$uname" =~ "Darwin" ]]; then
		echo "darwin"
		return
	fi

	if [[ "$uname" =~ "Linux" ]]; then
		echo "linux"
		return
	fi

	fail "Unknown platform"
}