#!/bin/bash

#
# For Ubuntu distribution Version 16.04 LTS
#

set -e
set -x

apt-get update
apt-get -y install python-setuptools
apt-get -y install expect
apt-get -y install unzip

hostname=`ss-get hostname`

# Packages url
anaconda2_url=`ss-get anaconda2_url`
sen2cor_url=`ss-get anaconda2_url`


_install_sen2cor() {
# Create installation temporary directory
mkdir -p ~/installation
cd ~/installation

# Download Anaconda 2 4.3.0
echo "Downloading Anaconda 2 4.3.0"
ANACONDA_CLI=/tmp/anaconda.sh
curl -o $ANACONDA_CLI $anaconda2_url
chmod +x $ANACONDA_CLI

ANACONDA_LOC=/opt/anaconda2

# Install Anaconda
echo "Installing Anaconda 2 4.3.0"
$ANACONDA_CLI -b -p $ANACONDA_LOC

# Put anaconda bin into PATH
export PATH=$ANACONDA_LOC/bin:$PATH
# FIXME: Temporary hack
cat ~/.bashrc >> /.bashrc
mv /.bashrc ~/.bashrc

echo "Verify Anaconda 2 installation"
# Is expected this
python --version
# Python 2.7.13 :: Anaconda custom (64-bit)

cd /tmp
echo "Downloading SEN2COR 2.3.1"
curl -O sen2cor_url

echo "Extracting SEN2COR"
tar xvzf sen2cor-2.3.1.tar.gz

echo "Installing SEN2COR"
cd /tmp/sen2cor-2.3.1/

# Install SEN2COR with expect
#python setup.py install
# Step 1
# SEN2COR 2.3.1 setup script:
# This will finish the configuration of the environment settings.
#
# OK to continue? [y/n]: y

# Step 2
# Please input a path for the sen2cor home directory:
# default is: /home/eo-poc/sen2cor
# Is this OK? [y/n]: y

SEN2COR_LOC=/opt/sen2cor

#export PYTHONPATH=$SEN2COR_LOC:$PYTHONPATH
#echo $PYTHONPATH
#FIXME --prefix redirect PYTHONPATH to new folder /opt/sen2cor
#python setup.py --quiet install --prefix=$SEN2COR_LOC
(echo 'y' ; echo 'n' ; echo $SEN2COR_LOC ; echo 'y') | python setup.py install

cd ~

SEN2COR_BASHRC=$SEN2COR_LOC/L2A_Bashrc
source $SEN2COR_BASHRC
echo "source $SEN2COR_BASHRC"  >> ~/.bashrc

env

echo "Verify SEN2COR installation"
L2A_Process --h
# Sentinel-2 Level 2A Processor (Sen2Cor). Version: 2.3.1,
#Clean-up installation
echo "Clean-up installation"
}

_run_L2A_formating() {
# Create product generation folder
cd /opt
mkdir product
# Downlwoad the test eo-poc test product
gh=https://raw.githubusercontent.com
branch=master
curl -sSfL $gh/SimonNtz/autoscaler/$branch/test_product.zip | bash
# Unzip it to current folder
unzip test_data.zip
# Define main folder path of test product
MAIN_PATH=S2A_OPER_PRD_MSIL1C_PDMC_20161122T194206_R122_V20161122T100322_20161122T100322
# Define raw product path
RAW_PRODUCT_LOC=$MAIN_PATH/$MAIN_PATH.SAFE/
# Process raw product
L2A_Process --resolution 10 $RAW_PRODUCT_LOC
# Add path to processed product
IMG_FOLDER=S2A_USER_PRD_MSIL2A_PDMC_20161122T194206_R122_V20161122T100322_20161122T100322.SAFE
IMG_PRODUCT_LOC=RAW_PRODUCT_NAME/IMG_PRODUCT_NAME/GRANULE/IMG_DATA/R10m/
}


_install_sen2cor

#_run_L2A_formating

ss-display "Sentinel-2 is ready!"
ss-set ready true

exit 0
