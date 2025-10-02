#!/bin/bash

# Enable command echoing
set -x

# reference https://www.chromium.org/getting-involved/download-chromium/#chrome-for-testing
export CHROME_VERSION=chrome@stable
export CHROME_FOLDER=/opt

export NVM_DIR=/root/.nvm
export NVM_VERSION=0.40.3

# install Chrome
mkdir -p ${NVM_DIR}

# install NVM to manage Node versions
curl --fail -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

# activate NVM
source ${NVM_DIR}/nvm.sh

# install latest LTS Node version
nvm install --lts

# pre-requisite for --install-deps of @puppeteer/browsers install
apt-get update

# instal Chrome through puppeteer/browsers
npx -y @puppeteer/browsers install --install-deps --path ${CHROME_FOLDER} ${CHROME_VERSION}

# link chrome to standard location
ln -sf $(find ${CHROME_FOLDER}/chrome -type f -name chrome -print) /usr/local/bin/google-chrome

# output chrome version to verify install worked
/usr/local/bin/google-chrome --version || exit 1

# cleanup old chrome install
rm -fr /opt/google

# uninstall NVM and node
rm -fr ${NVM_DIR}

# cleanup apt cache
rm -rf /var/lib/apt/lists/*