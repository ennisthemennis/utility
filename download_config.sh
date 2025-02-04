#!/usr/bin/env bash

export PATH=/data/predict/mongodb-database-tools-rhel70-x86_64-100.5.2/bin:$PATH

if [[ $# -lt 3 ]]
then
    echo "Usage: ./download_config.sh config_name owner_id /tmp/config_name.json"
    echo "Provide configuration name and output file name"
    exit 1
fi


if [ -z $HOST ] || [ -z $PORT ] || [ -z $state ] || [ -z $MONGO_PASS ]
then
    echo Define HOST, PORT, state, MONGO_PASS and try again
    exit 1
fi


export GODEBUG=x509ignoreCN=0


tmpJson=/tmp/config_`pgrep -f $0`.json
scriptDir=`dirname $0`

# export from mongodb
mongoexport --ssl --sslCAFile=$state/ssl/ca/cacert.pem --sslPEMKeyFile=$state/ssl/mongo_client.pem --uri="mongodb://dpdash:$MONGO_PASS@$HOST:$PORT/dpdmongo?authSource=admin" --collection=configs --query="{\"name\":\"$1\",\"owner\":\"$2\"}" --out=$tmpJson
# modify according to https://github.com/AMP-SCZ/dpdash/wiki/Configuration-schema
export PATH=/data/predict/miniconda3/bin:$PATH
$scriptDir/_download_config.py $tmpJson $3

rm $tmpJson

