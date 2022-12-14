#!/usr/bin/env bash

# The script expects exactly one arg: the directory in which the workspace will be set up.
# It may not be a good idea to use the dir where this script resides in or a subdir as workspace 
# dir if you cloned this bootstrap script repo: As the script will also clone some repos, you 
# would end up with repos in repos. Though this is not a problem in itself, it may get tricky in
# the long run.

# complain if there is no cli arg
wsdir=$1
if [ "x$wsdir" = "x" ]; then
  echo Please specify a dir for the workspace. Do not use a subdir of this to avoid repo in repo.
  exit 1
fi

# prerequisites are node, npm, yarn, stripes-cli (and git inter alia, of course)
# stripes-cli is expected to be installed globally
# my environment works with
# node:    v16.14.0
# npm:     8.5.2
# yarn:    1.22.17
# stripes: 2.6.1
# Note: I installed stripes-cli as described in https://github.com/folio-org/stripes-cli/blob/master/README.md#installation
# Note: This script is designed for the use with the (somewhat?) deprecated
# yarn 1. It may/should also work with yarn 2, no garantees, however.

echo node version: $(node -v)
echo npm version: $(npm -v)
echo yarn version: $(yarn -v)
echo stripes version: $(stripes --version)

mkdir -p $wsdir
cd $wsdir

# A stripes workspace is actually a [yarn workspace](https://classic.yarnpkg.com/blog/2017/08/02/introducing-workspaces/)
# that is configured for use in stripes context.
# There is no real doc/introduction to workspaces included here (do google, rtm), just this:
# A workspace is useful if you want/need to work with several modules/repos at once, e.g. if you
# want to introduce new features that affect more than one module. Each module you want to work 
# with is cloned/copied to the workspace. Typically you need one or more modules and a platform.
# Yarn will take care of combinedly administering all the dependencies of the individual modules.
# Particularly, the cloned modules will be used as dependencies for each other.
# (Note the symlinks in node_modules/@folio after executing this script or in the docs link above.

# Note: Atm, only platform-complete is up-to-date and workable. You are strongly advised, however,
# to manually reduce the number of modules before building. (see below)

# You may preferedly want to use the command `stripes workspace` to set up a workspace.
# It will take care for you of the following steps (including `yarn install`).
# However, there may occur version mismatches, for example if you want to work with
# - the latest builds/commits/snapshot
# - the stripes modules, not only app modules
# - an older release.
# This stems from the behavior of `stripes workspace` which basically 

# first, we create a package.json for the yarn workspace
echo create package.json for workspace
cat - > package.json <<END
{
  "private": true,
  "workspaces": [
      "*"
  ],
  "devDependencies": {
    "@folio/stripes-cli": "^2.6.0"
  },
  "dependencies": {
    "@folio/stripes-form": "^7.1.1",
    "@folio/stripes-final-form": "^6.1.1",
    "@folio/stripes-components": "^10.0.0",
    "@folio/stripes-connect": "^7.0.0",
    "@folio/stripes-logger": "^1.0.0",
    "moment": "^2.29.0",
    "react": "^17.0.2",
    "react-dom": "^17.0.2",
    "react-intl": "^5.7.0",
    "react-router": "^5.2.0",
    "react-router-dom": "^5.2.0",
    "redux-observable": "^1.2.0",
    "rxjs": "^6.6.3"
  }
}
END

# Second, we clone the modules we need
# You may also just copy the module if you don't plan to commit/push any changes.

# For this example we clone stripes-util, stripes-core, and platform-complete.
# At the time of writing this script, the master branches of the modules are not compatible.
# That is why, when using `stripes workspace`, we get a defunct workspace.
# You can either fix the version by hand or install the repos manually, as done here.
echo clone module repos

# The platform
git clone https://github.com/folio-org/platform-complete.git
# at time of writing tis script, platform-complete master branch is 3.9.0 which is Nolana release.
# To freeze this state and make this example more lasting, lets check out a certain commit. 
cd platform-complete
git checkout c21d09a466
cd ..

# The stripes core
git clone https://github.com/folio-org/stripes-core.git
# at the time of writing this script, stripes-core master branch is 8.4.0, which is Orchid release.
# but we need 8.3.1 of Nolana release to get dependencies right with platform-complete
cd stripes-core
git checkout b8.3
cd ..

# The stripes util, where the functionality for effective callnumber composition resides
# we clone it from my repository to obtain the slightly more sophisticated concatenation of 
# call number fields.
git clone https://github.com/mnscholz/stripes-util.git


# Third, adjust platform-complete.
# Remove all the modules/apps you don't really need.
# Building the whole platform takes a lot of time and even may cause memory issues...
# So, for the sake of efficiency, restrict yourself!
# We need to remove the modules from the files platform-complete/package.json and
# platform-complete/stripes.config.js.
# Only remove dependencies/modules that begin with @folio!
echo adjust platform

cat platform-complete/package.json |
grep -v "@folio/acquisition-units" | 
grep -v "@folio/agreements" | 
grep -v "@folio/bulk-edit" | 
grep -v "@folio/courses" | 
grep -v "@folio/dashboard" | 
grep -v "@folio/data-export" | 
grep -v "@folio/data-import" | 
grep -v "@folio/eholdings" | 
grep -v "@folio/erm-comparisons" | 
grep -v "@folio/erm-usage" | 
grep -v "@folio/export-manager" | 
grep -v "@folio/finance" | 
grep -v "@folio/gobi-settings" | 
grep -v "@folio/invoice" | 
grep -v "@folio/ldp" | 
grep -v "@folio/licenses" | 
grep -v "@folio/local-kb-admin" | 
grep -v "@folio/marc-authorities" | 
grep -v "@folio/oai-pmh" | 
grep -v "@folio/orders" | 
grep -v "@folio/organizations" | 
grep -v "@folio/plugin-bursar-export" | 
grep -v "@folio/plugin-eusage-reports" | 
grep -v "@folio/plugin-find-agreement" | 
grep -v "@folio/plugin-find-authority" | 
grep -v "@folio/plugin-find-contact" | 
grep -v "@folio/plugin-find-eresource" | 
grep -v "@folio/plugin-find-erm-usage-data-provider" | 
grep -v "@folio/plugin-find-fund" | 
grep -v "@folio/plugin-find-import-profile" | 
grep -v "@folio/plugin-find-license" | 
grep -v "@folio/plugin-find-organization" | 
grep -v "@folio/plugin-find-package-title" | 
grep -v "@folio/plugin-find-po-line" | 
grep -v "@folio/quick-marc" | 
grep -v "@folio/receiving" | 
grep -v "@folio/remote-storage" | 
grep -v "@folio/stripes-erm-components" > tmp
mv tmp platform-complete/package.json

cat platform-complete/stripes.config.js |
grep -v "@folio/acquisition-units" | 
grep -v "@folio/agreements" | 
grep -v "@folio/bulk-edit" | 
grep -v "@folio/courses" | 
grep -v "@folio/dashboard" | 
grep -v "@folio/data-export" | 
grep -v "@folio/data-import" | 
grep -v "@folio/eholdings" | 
grep -v "@folio/erm-comparisons" | 
grep -v "@folio/erm-usage" | 
grep -v "@folio/export-manager" | 
grep -v "@folio/finance" | 
grep -v "@folio/gobi-settings" | 
grep -v "@folio/invoice" | 
grep -v "@folio/ldp" | 
grep -v "@folio/licenses" | 
grep -v "@folio/local-kb-admin" | 
grep -v "@folio/marc-authorities" | 
grep -v "@folio/oai-pmh" | 
grep -v "@folio/orders" | 
grep -v "@folio/organizations" | 
grep -v "@folio/plugin-bursar-export" | 
grep -v "@folio/plugin-eusage-reports" | 
grep -v "@folio/plugin-find-agreement" | 
grep -v "@folio/plugin-find-authority" | 
grep -v "@folio/plugin-find-contact" | 
grep -v "@folio/plugin-find-eresource" | 
grep -v "@folio/plugin-find-erm-usage-data-provider" | 
grep -v "@folio/plugin-find-fund" | 
grep -v "@folio/plugin-find-import-profile" | 
grep -v "@folio/plugin-find-license" | 
grep -v "@folio/plugin-find-organization" | 
grep -v "@folio/plugin-find-package-title" | 
grep -v "@folio/plugin-find-po-line" | 
grep -v "@folio/quick-marc" | 
grep -v "@folio/receiving" | 
grep -v "@folio/remote-storage" | 
grep -v "@folio/stripes-erm-components" > tmp
mv tmp platform-complete/stripes.config.js

# Fourth, install all the dependencies
echo install dependencies, this may take some minutes!
echo warnings are usually ok and display a lot. If errors, try to figure it out...
yarn install

# Fifth, done with preparing, serve the dish
echo
echo -----
echo
echo if no errors occured, everything should be set up correctly.
echo
echo Go to $wsdir/platform-complete/stripes.config.js and change the okapi settings
echo appropriately.
echo
echo Now you may serve the platform by running this:
echo cd $wsdir/platform-complete';' stripes serve stripes.config.js --host 0.0.0.0
echo
echo When serving, first wait until '"'webpack built ...'"' appeared two times,
echo then direct your browser to http://<your-server-domain>:3000
# Note that the --host option is required to access this stripes from another machine, otherwise
# it is only accessible from localhost.

# Troubleshooting:
# If you either run into errors when accessing stripes via browser or stripes won't serve due to
# version problems, you may want to use `yarn why <package>` to see if there are multiple versions
# of a module in your dependencies.
# Especially, check the stripes-* modules (node_modules/@folio/stripes*), like so:
# `yarn why @folio/stripes-core`
# If the output mentions more than one version, you will probably have installed/cloned two 
# incompatible versions of modules in your workspace.

