#!/bin/bash

declare -r lib_dir=lib
. "${lib_dir}"/bootstrap.sh
. "${lib_dir}"/lib.sh
# Always make sure that this is declared after bootstrap.sh is sourced in order to make sure, temp dir handling is done correctly.
declare -r yubiset_main_script_runs=true

declare -r keyattr_input="${input_dir}/keyattr.input"
declare -r keygen_input="${input_dir}"/keygen.input
declare -r keygen_input_copy="${yubiset_temp_dir}"/keygen.input.copy
declare -r ondevice_keygen_template="${input_dir}/ondevicekeygen.input.template"
declare -r ondevice_keygen_input="${input_dir}/ondevicekeygen.input"

if [[ "${1}" -eq "4" ]]; then 
	declare -r subkey_length=2048
	declare -r subkeys_input="${input_dir}"/subkeys_2048.input
else
	declare -r subkey_length=4096
	declare -r subkeys_input="${input_dir}"/subkeys.input
fi

declare -r revoke_input="${input_dir}"/revoke.input

pretty_print "OpenPGP key generation and Yubikey setup script"
pretty_print "Version: ${yubiset_version}"
pretty_print
pretty_print "gpg home:                ${gpg_home}"
pretty_print "Subkey length:           ${subkey_length} bit"
pretty_print "Yubiset tmp dir:         ${yubiset_temp_dir}"
pretty_print "Yubiset key backups dir: ${key_backups_dir}"
pretty_print "gpg:                     ${YUBISET_GPG_BIN}"
pretty_print "gpg-connect-agent:       ${YUBISET_GPG_CONNECT_AGENT}"
pretty_print "gpgconf:                 ${YUBISET_GPG_CONF}"
echo

press_any_key

cleanup()
{
	silentDel "${keygen_input_copy}"
	silentDel "${yubiset_temp_dir}"
	echo
}

create_conf_backup()
{
	echo Now making backup copies..

	if [[ -f "${gpg_home}/gpg.conf" ]]; then
		echo "${gpg_home}/gpg.conf => ${gpg_home}/gpg.conf.backup.by.yubiset"
		cp -f "${gpg_home}/gpg.conf" "${gpg_home}/gpg.conf.backup.by.yubiset" || { cleanup; end_with_error "Creating backup of gpg.conf failed."; }
	fi

	if [[ -f "${gpg_home}/gpg-agent.conf" ]]; then
		echo "${gpg_home}/gpg-agent.conf => ${gpg_home}/gpg-agent.conf.backup.by.yubiset"
		cp -f "${gpg_home}/gpg-agent.conf" "${gpg_home}/gpg-agent.conf.backup.by.yubiset" || { cleanup; end_with_error "Creating backup of gpg-agent.conf failed."; }
	fi
	echo ..Success!
	echo
	echo "Now copying yubiset's conf files.."
	silentCopy "${conf_dir}/gpg.conf" "${gpg_home}/gpg.conf" || { cleanup; end_with_error "Replacing gpg.conf failed."; }
	silentCopy "${conf_dir}/gpg-agent.conf" "${gpg_home}/gpg-agent.conf" || { cleanup; end_with_error "Replacing gpg-agent.conf failed."; }
	echo ..Success!
}

delete_master_key()
{
	echo Removing..
	{ "${YUBISET_GPG_BIN}" --batch --yes --delete-secret-keys --pinentry-mode loopback --passphrase "${passphrase}" "${key_fpr}" ; } || { cleanup; end_with_error "Could not delete private master key." ; }
	echo ..Success!

	echo Reimporting private sub keys..
	{ "${YUBISET_GPG_BIN}" --pinentry-mode loopback --passphrase "${passphrase}" --import "${key_dir}/${key_id}.sub_priv.asc" ; } || { cleanup; end_with_error "Re-import of private sub keys failed." ; }
	echo ..Success!
}

#
# GPG CONF SECTION
#
echo "Should your gpg.conf and gpg-agent.conf files be replaced by the ones provided by Yubiset? If you don't know what this is about, it is safe to say 'y' here. Backup copies of the originals will be created first."
if $(are_you_sure "Replace files") ; then create_conf_backup; fi

#
# GPG AGENT RESTART
#
echo
restart_gpg_agent || { cleanup; end_with_error "Could not restart gpg-agent."; }

#
# GPG KEY GENERATION SECTION
#
echo 
pretty_print "We are now about to generate PGP keys."
echo
echo "First, we need a little information from you."
read -p "Please enter your full name: " user_name
read -p "Please enter your full e-mail address: " user_email
echo
passphrase=""


sed "s/FULL_NAME/${user_name}/g" "${ondevice_keygen_template}" > "${ondevice_keygen_input}"
sed -i "" "s/EMAIL/${user_email}/g" "${ondevice_keygen_input}"


#
# YUBIKEY SECTION
#

echo "Checking if we can access your Yubikey.."
(. ./findyubi.sh) || { cleanup; end_with_error "Could not communicate with your Yubikey." ; }
echo "Ok, Yubikey communication is working!"

#
# RESET YUBIKEY
#
echo
echo Now we must reset the OpenPGP module of your Yubikey..
(. ./resetyubi.sh) || { cleanup; end_with_error "Resetting YubiKey ran into an error." ; }

#
# YUBIKEY SETUP AND KEYTOCARD
#
echo
echo Now we need to setup your Yubikey and move the generated subkeys to it..
(. ./setupyubi.sh) || { cleanup; end_with_error "Setting up your Yubikey ran into an error." ; }

pretty_print "All done! Exiting now."

cleanup
