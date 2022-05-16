#!/bin/bash

#
#

#
# SETUP SECTION
#
if [[ -z "${lib_dir}" ]] ; then declare -r lib_dir=lib ; fi
. "${lib_dir}"/bootstrap.sh
. "${lib_dir}"/lib.sh


disable_otp() {
	echo "Disabling OTP for YubiKey"
	ykman config usb --disable OTP --force 
}



pretty_print "Yubikey disable OTPscript"
pretty_print "Version: ${yubiset_version}"

#
# PIN SECTION
#
echo
if $(are_you_sure "Should we Disable OTP?") ; then disable_otp ; fi

