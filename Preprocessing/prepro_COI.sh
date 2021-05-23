#!/bin/bash
for patient in {1..195}
do
	echo "submitting patient $patient"
	bsub -J "sub$patient" -W 90 matlab -singleCompThread -batch "addpath /cluster/scratch/ddallosto/spm12;addpath /cluster/scratch/ddallosto/tapas;tapas_init;run_prepro('/cluster/scratch/ddallosto/SRPBS_OPEN',$patient,1:3)"
done
