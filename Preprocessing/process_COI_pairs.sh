#!/bin/bash
for patient in {1..124}
do
	echo "submitting patient $patient"
	bsub -J "sub$patient" -W 90 matlab -singleCompThread -batch "addpath /cluster/scratch/ddallosto/spm12;addpath /cluster/scratch/ddallosto/tapas;tapas_init;run_prepro_pairs('/cluster/scratch/ddallosto/SRPBS_OPEN','../Dataset Analysis/COI_pairs.txt',$patient,4:5)"
done
