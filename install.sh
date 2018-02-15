#!/bin/bash
set -e
HEADER="\033[95m"
ENDC="\033[0m"
inform_user() {
  printf "${HEADER}$@${ENDC}\n"
}

SMLNJ_VERSION=110.82 # (If this changes, you'll likely have to change the patch...)
gf="https://smlnj-gforge.cs.uchicago.edu/svn"
smlnj="${gf}/smlnj"
patch_url="https://raw.githubusercontent.com/jvanburen/smlnj-warn-unused/${SMLNJ_VERSION}/unused-vars.patch"

if ! [ -x "$(command -v svn)" ]; then
  inform_user "SVN is required to download SML"
  exit 1
fi

mkdir -p "smlnj-${SMLNJ_VERSION}"
cd "smlnj-${SMLNJ_VERSION}"

# get the scripts to set up things
inform_user "Downloading SML install scripts"
svn export --username anonsvn --password anonsvn "${smlnj}/admin" || true
# get the release version

inform_user "Downloading SML/NJ release version ${SMLNJ_VERSION}"
svn export --username anonsvn --password anonsvn "${smlnj}/sml/releases/release-${SMLNJ_VERSION}" base || true
# get the other repos necessary
inform_user "Downloading supporting libraries (slow!)"
bash admin/checkout-all.sh --export || true

# build the bootstrapped SMLNJ
inform_user "Configuring SML/NJ"
bash config/install.sh

# fix for if ml-yacc isn't installed already
if ! [ -x "$(command -v ml-yacc)" ]; then
  touch ml-yacc/src/yacc.grm.sig ml-yacc/src/yacc.grm.sml
fi

# Now work on the SML part of the compiler
cd base

inform_user "Downloading and applying patch! :)"
# Get the patch!
if [ -f unused-vars.patch ]; then
  inform_user "Already downloaded patch!"
else
  wget $patch_url \
    || curl -O $patch_url \
    || { inform_user "Could not find a program to download the patch with!" \
      && exit 1; }
fi

# Apply patch!
if [ -f compiler/Elaborator/elaborate/check-unused.sml ]; then
  inform_user "(Assuming patch already applied)"
else
  patch --batch -p0 < "./unused-vars.patch"
fi

inform_user "Building compiler (This may take a bit)"
# bootstrap & compile
cd system
bash ./fixpt
# build the heap image
bash ./makeml
# update with the libraries we just built
bash ./installml

cd ../../..

inform_user "Your new version of SML has been compiled!"
inform_user
inform_user "The executable is smlnj-${SMLNJ_VERSION}/bin/sml"
inform_user
inform_user "To install this new version on macOS, replace your current /usr/local/smlnj with the new directory smlnj-${SMLNJ_VERSION} to install it."
inform_user "Additionally, /usr/local/smlnj/bin should be in your PATH variable to use the sml interpreter"
inform_user
inform_user "Let's try it out now!"
inform_user "Example: let val unused_var = () in () end;"
inform_user
if [ -x "$(command -v rlwrap)" ]; then
  exec rlwrap "smlnj-${SMLNJ_VERSION}/bin/sml"
else
  exec "smlnj-${SMLNJ_VERSION}/bin/sml"
fi
