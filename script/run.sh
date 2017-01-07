#!/bin/bash

installed=`gem list | grep nokogiri`

if [ "${installed}" == "" ]; then
  echo "[INFO] nokogiri is not installed. install nokogiri start ........."
  gem install nokogiri
fi

installed=`gem list | grep parallel`

if [ "${installed}" == "" ]; then
  echo "[INFO] parallel is not installed. install parallel start ........."
  gem install parallel
fi

# initialize csv file
: > result.csv

curDir=`pwd`
scriptDir=`dirname $0`
year=${1:-17}

echo "[INFO] -----------------------------------------------------"
echo "[INFO] Start scraping " 20${year} " mynavi"
echo "[INFO] -----------------------------------------------------"

ruby ${scriptDir}/main.rb --year ${year} --file ${curDir}/result.csv

echo "[INFO] -----------------------------------------------------"
echo "[INFO] End scraping"
echo "[INFO] check ${curDir}/result.csv"
echo "[INFO] -----------------------------------------------------"