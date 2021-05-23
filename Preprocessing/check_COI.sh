#!/bin/bash
cd ../QualityCheck_prepro
matlab -singleCompThread -batch "addpath /cluster/scratch/ddallosto/spm12;run_quality_check('/cluster/scratch/ddallosto/COI')"
cd ../Preprocessing
