#!/usr/bin/env bash

export PATH=/data/predict/mongodb-linux-x86_64-rhel70-4.4.6/bin:$PATH

if [ -z $1 ] || [ ! -d $1 ]
then
    echo """./dpimport_files_status.sh /path/to/nda_root/ VM
Provide /path/to/nda_root/ and VM
VM name examples:
    dpstage for dpstage.dipr.partners.org
    rc-predict for rc-predict.bwh.harvard.edu
    rc-predict-dev for rc-predict-dev.bwh.harvard.edu
    It is the first part of the server name."""
    exit
else
    export NDA_ROOT=$1
fi

source /data/predict/utility/.vault/.env.${2}

echo Importing to mongodb://dpdash:MONGO_PASS@$HOST:$PORT
echo ''

# delete old collections
mongo --tls --tlsCAFile $state/ssl/ca/cacert.pem --tlsCertificateKeyFile $state/ssl/mongo_client.pem mongodb://dpdash:$MONGO_PASS@$HOST:$PORT/dpdata?authSource=admin --eval "assess=[\"flowcheck\"]" /data/predict/utility/remove_assess.js

# delete metadata
mongo --tls --tlsCAFile $state/ssl/ca/cacert.pem --tlsCertificateKeyFile $state/ssl/mongo_client.pem mongodb://dpdash:$MONGO_PASS@$HOST:$PORT/dpdata?authSource=admin /data/predict/utility/remove_metadata.js


# import new collections
export PATH=/data/predict/miniconda3/bin:$PATH
cd $NDA_ROOT

# metadata
import.py -c $CONFIG combined_metadata.csv
import.py -c $CONFIG "*_status/*_metadata.csv"

# project level files status
import.py -c $CONFIG combined-AMPSCZ-flowcheck-day1to1.csv
import.py -c $CONFIG "*_status/combined-*-flowcheck-day1to1.csv"

# subject level files status
import.py -c $CONFIG "*_status/??-*-flowcheck-day1to1.csv"

