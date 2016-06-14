#!/bin/bash
#
# Script to either copy or download license files.
# 
# (c) Daniel Kesler <kesler.daniel@gmail.com>
#

TARGET_DIR=${1}
shift

PKG_NAME=${1}
shift

PKG_DIR=${1}
shift

DOWNLOAD_DIR=${1}
shift

LICENSE=${1}
shift

LICENSE_FILES=${1}
shift

LICENSE_DIR=${TARGET_DIR}/usr/share/licenses/${PKG_NAME}

echo "TARGET_DIR: ${TARGET_DIR}"
echo "PKG_NAME: ${PKG_NAME}"
echo "PKG_DIR: ${PKG_DIR}"
echo "DL_DIR: ${DOWNLOAD_DIR}"
echo "LICENSE: ${LICENSE}"
echo "LICENSE_FILES: ${LICENSE_FILES}"

# @param $1 URL
# @param $2 output filename
download_file()
{
	wget --no-check-certificate $1 -O $2
}

# @param $1 license name
licname_to_file()
{
	local lic=$1
	
	if [ x"$lic" == x"Public domain" ]; then
		#echo "Public domain, no need for a license file"
		true
	elif [ x"$lic" == x"GPL" ]; then
		LIC_FILE=${DOWNLOAD_DIR}/gpl.txt
		if [ ! -e ${LIC_FILE} ]; then
			download_file "https://www.gnu.org/licenses/gpl.txt" "${LIC_FILE}"
		fi
		echo "${LIC_FILE}"
	fi
}

# License files are defined
if [ -n "${LICENSE_FILES}" ]; then
	
	for lf in ${LICENSE_FILES}; do
		if [ -e ${PKG_DIR}/${lf} ]; then
			mkdir -p ${LICENSE_DIR}
			cp ${PKG_DIR}/${lf} ${LICENSE_DIR}
		else
			echo "!!!! ${PKG_DIR}/${lf} not found."
		fi
	done

	exit 0
fi

# License files are not defined, try to deduce license by name 
# and download it

if [ -n "${LICENSE}" ]; then
	LIC=$(licname_to_file "${LICENSE}")
	if [ -n "${LIC}" ]; then
		mkdir -p ${LICENSE_DIR}
		cp ${LIC} ${LICENSE_DIR}
	fi

fi
