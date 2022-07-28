#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Alpine Linux
update_image "amd64/alpine" "Alpine Linux" "false" "\d{8}"

# Packages
IMG_ARCH="x86_64"
BASE_PKG_URL="https://pkgs.alpinelinux.org/package/edge"
# Main Repo
MAIN_PKG_URL="$BASE_PKG_URL/main/$IMG_ARCH"
update_pkg "python3" "Python 3" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-setuptools" "Python Setup-Tools" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-attrs" "Python Classes" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-idna" "Python IDNA" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-cffi" "Python C-FFI" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "jq" "JQ" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "git" "Git" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "curl" "cURL" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "grep" "Grep" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "bash" "Bash" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "coreutils" "Core-Utilities" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "openssh-client-default" "SSH Client" "false" "$MAIN_PKG_URL" "(\d+\.)+\d+_p\d+-r\d+"
# Community Repo
COMMUNITY_PKG_URL="$BASE_PKG_URL/community/$IMG_ARCH"
update_pkg "py3-autobahn" "Python Autobahn" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-txaio" "Python TXA-IO" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-zope-interface" "Python Zope Interface" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-msgpack" "Python MessagePack" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-twisted" "Python Twisted" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-hyperlink" "Python Hyperlink" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-cryptography" "Python Cryptography" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-typing-extensions" "Python Type-Hints" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-automat" "Python Automat" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-incremental" "Python Incremental" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "py3-constantly" "Python Constantly" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"
update_pkg "docker-cli" "Docker CLI" "false" "$COMMUNITY_PKG_URL" "(\d+\.)+\d+-r\d+"

# Buildbot Tarballs
update_github "buildbot/buildbot" "Buildbot" "APP_VERSION" "(\d+\.)+\d+"


if ! updates_available; then
	#echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi
