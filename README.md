# YUBISET  
A collection of scripts to make OpenPGP key generation and YubiKey manipulation easy. 

# What does it do?

- create GPG keys on Yubikey
- Set user information for Yubikey (name, lang, etc)
- Set User and Admin PIN for Yubikey

# Table of Contents

- [YUBISET](#yubiset)
- [What does it do?](#what-does-it-do)
- [Supported Environments](#supported-environments)
- [Supported Yubikeys](#supported-yubikeys)
- [Prerequisites](#prerequisites)
  * [Linux](#linux)
  * [Mac](#mac)
- [Download](#download)
  * [Verifying The Download](#verifying-the-download)
- [Usage](#usage)
  * [Unix](#unix)
    + [Start here: Key generation & Yubikey setup (all in one script)](#start-here-key-generation--yubikey-setup-all-in-one-script-1)
      - [Move PGP keys to Yubikey only](#move-pgp-keys-to-yubikey-only-1)
      - [Reset Yubikey's OpenPGP module](#reset-yubikeys-openpgp-module-1)
      - [Find Yubikey Slot](#find-yubikey-slot-1)
- [For Developers](#for-developers)
  * [Clone with git](#clone-with-git)
  * [Flush issues](#flush-issues)
  * [README.md Table of Contents](#readmemd-table-of-contents)

# Supported Environments
* Unix (Bash)

# Supported Yubikeys
* Yubikey 5 (firmware >5.2)

# Prerequisites  
The only thing you'll need is a working gpg installation:

## Linux  
Use the *GnuPG* package provided with your distribution or follow the instructions on [https://gnupg.org](https://gnupg.org).

## Mac  
`brew install gnupg pinentry-mac ykman`

# Download
[https://github.com/JanMosigItemis/yubiset/releases](https://github.com/JanMosigItemis/yubiset/releases)

## Verifying The Download  
Every release comes as a zip file of the form `yubiset_[TAG].[TIMESTAMP].zip`. 

The file is accompanied by the [SHA-512](https://en.wikipedia.org/wiki/SHA-2) hash code of the zip stored into `[ZIP_FILE_NAME].sha512`. You may verify the hash code of your download like this:
```
# This makes sure, you downloaded an exact copy of the release from GitHub.
sha512sum -c yubiset_vt.t.t.test.201907042021.sha512
yubiset_vt.t.t.test.201907042021.zip: OK # This is the supposed output.

```

There is a third file called `[ZIP_FILE_NAME].sha512.gpg`. This can be used to verify that the hash code has not been tempered with. The verification is done via [GPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard) like this:
```
gpg --verify yubiset_vt.t.t.test.201907042021.sha512.gpg
gpg: Signature made 07/04/19 20:21:11 W. Europe Daylight Time
gpg:                using RSA key 0xE9EC6651133A788F
gpg: Good signature from "Jan Mosig itemis GitHub Signing Key (Signing key for GitHub release artifacts of JanMosigItemis) <ja
n.mosig@itemis.de>" [ultimate]
Primary key fingerprint: DFC5 B2E2 74B5 A83E DC56  2A48 3622 572E E5F1 E2D4
     Subkey fingerprint: BE63 6888 FDA6 4B7C E7F7  1BF7 E9EC 6651 133A 788F
```

If you perform both steps, there is a very high chance that your download is legit.

In case you are missing my public GitHub signing key, you can download it here: https://gist.github.com/JanMosigItemis/ce1ffd36a4ab860962009f7a9a6ff2ec. Unzip the file and import the key like this:
```
gpg --import JanMosigItemisGitHub.asc
```

# Usage

## Unix

### Start here: Key generation & Yubikey setup (all in one script)
```
cd unix/bash
sh yubiset.sh
```


The following scripts may be used standalone but are also called from the `yubiset` main script:

#### Move PGP keys to Yubikey only
```
cd unix/bash
sh setupyubi.sh "Given Name Surname" "my.email@provider.com" "PGP key id" "passphrase"
```
Due to security reasons the passphrase may also be omitted. In this case the user will be prompted to enter it.

#### Reset Yubikey's OpenPGP module
**BE AWARE:** Only tested with Yubikey 4 NEO and Yubikey 5
```
cd unix/bash
sh resetyubi.sh
```

#### Find Yubikey Slot
```
cd unix/bash
sh findyubi.sh
```

### Key Branding  
It is possible to "brand" your generated keys, i. e. give the user name and the comment a custom touch e. g. for your company. This can be controlled by editing the file `unix/bash/lib/branding.sh`.

The default will produce a key like this:

```
sec   rsa4096/0x94AF5E3D1575AC6A 2019-07-01 [C] [expires: 2020-06-30]
      Key fingerprint = 3B90 7B16 76E6 9F6F 59D1  D103 94AF 5E3D 1575 AC6A
uid                   [ultimate] Max Muster <max.muster@host.de>
```

However a `branding.sh` like this:
```
declare -r branded_user_name="${user_name} (itemis AG)"
declare -r branded_user_comment="Vocational key of itemis AG's Max Muster"
```
will produce the following key:
```
sec   rsa4096/0x94AF5E3D1575AC6A 2019-07-01 [C] [expires: 2020-06-30]
      Key fingerprint = 3B90 7B16 76E6 9F6F 59D1  D103 94AF 5E3D 1575 AC6A
uid                   [ultimate] Max Muster (itemis AG) (Vocational OpenPGP key of itemis AG's Max Muster) <max.muster@host.de>
```

*Be aware:* GPG does not support arbitrary charaters in key comments. Especially parantheses '(' and ')' will cause problems. Don't use them.

## Flush issues
Be aware that on some file systems / operating systems generating (log) files may take some time and in order for the gpg-agent and scdaemon to recognize changes it may also take some time, so retrying probes etc. is advised in order to make sure the script does not unnecessarily fail.
