#!/usr/bin/env bash

set -euo pipefail

declare -A tools=(
  [openshift-client]=oc
  [openshift-install]=openshift-install
  [oc-mirror]=oc-mirror
  [ccoctl]=ccoctl
  [opm]=opm
)
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

download_release() {
	local version
  local arch=$(get_arch)
  local platform=$(get_platform)
	version="$1"
  for tool in "${!tools[@]}"; do
    if [[ ${tool} == 'oc-mirror' ]]; then
      filename="${tool}.tar.gz"
    else
      filename="${tool}-${platform}-${version}.tar.gz"
    fi

    url="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/${filename}"
    
    printf "* Downloading $tool release $version...\n"
	  curl "${curl_opts[@]}" -o "${ASDF_DOWNLOAD_PATH}"/"$filename" -C - "$url" || fail "Could not download $url"
    
    #printf "${tool}: ${tools[$tool]}\n"
    #printf "version: ${version}\n"
    #printf "arch: ${arch}\n"
    #printf "platform: ${platform}\n"
    #printf "filename: ${file_name}\n"
    #printf "URL: ${url}\n"
    #printf "${ASDF_DOWNLOAD_PATH}\n"
  done
}

install_version() {  
  local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"
  local arch="$4"
  local platform="$5"
  

	if [ "$install_type" != "version" ]; then
		fail "asdf-openshift supports release installs only"
	fi

	(
		mkdir -p "$install_path"

    for tool in "${!tools[@]}"; do
      if [[ ${tool} == 'oc-mirror' ]]; then
        filename="${tool}.tar.gz"
      else
        filename="${tool}-${platform}-${version}.tar.gz"
      fi
    tar xzf "${ASDF_DOWNLOAD_PATH}"/"${filename}" -C "${ASDF_DOWNLOAD_PATH}" --exclude README.md
    cp  "${ASDF_DOWNLOAD_PATH}/${tools[$tool]}" "${install_path}" 
    done
		cp -r "${ASDF_DOWNLOAD_PATH}" "$install_path"
#
		local tool_cmd
		tool_cmd="$(echo "${tools[$tool]}" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."
#
		echo "${tools[$tool]} $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing ${tools[$tool]} $version."
	)
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