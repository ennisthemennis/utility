#!/usr/bin/env bash

export PATH=/data/predict/utility/:$PATH
if [ -z $1 ] || [ ! -d $1 ]
then
    echo """./generate_file_status.sh /path/to/nda_root/ VM
Provide /path/to/nda_root/ and VM
VM name examples:
    dpstage for dpstage.dipr.partners.org
    rc-predict for rc-predict.bwh.harvard.edu
    It is the first part of the server name."""
    exit
else
    export NDA_ROOT=$1
fi


name='combined'
rm ${NDA_ROOT}/${name}_metadata.csv
rm ${NDA_ROOT}/Pronet_status/*csv
rm ${NDA_ROOT}/Prescient_status/*csv


# use pnlpipe3 environment to bypass the error below
# https://gist.github.com/tashrifbillah/24efeec3219ba3c58c92adc419aac7be#gistcomment-4037001
source /data/pnl/soft/pnlpipe3/miniconda3/bin/activate base && conda activate pnlpipe3 && \
subject_files_status_for_dpdash.py $NDA_ROOT && \
cd ${NDA_ROOT}/Pronet_status && \
project_files_status_for_dpdash.py PRONET ../${name}_metadata.csv *-flowcheck-day1to1.csv && \
chmod g+w * && \
cd ${NDA_ROOT}/Prescient_status && \
project_files_status_for_dpdash.py PRESCIENT ../${name}_metadata.csv *-flowcheck-day1to1.csv && \
chmod g+w *


cd ${NDA_ROOT}
echo AMPSCZ,1,'-',${name} >> ${name}_metadata.csv
cat Pronet_status/${name}-PRONET-flowcheck-day1to1.csv > ${name}-AMPSCZ-flowcheck-day1to1.csv
tail -n +2 Prescient_status/${name}-PRESCIENT-flowcheck-day1to1.csv >> ${name}-AMPSCZ-flowcheck-day1to1.csv
renumber_days.py ${name}-AMPSCZ-flowcheck-day1to1.csv

# export the above csv files to remote MongoDB server
cd /data/predict/utility
./dpimport_files_status.sh $NDA_ROOT $2

