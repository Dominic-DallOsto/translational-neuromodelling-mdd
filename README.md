# TNU MDD Project

## Dataset

We used [this](https://bicr-resource.atr.jp/srpbsopen/) dataset based on the paper by [Yamashita et al.](https://doi.org/10.1371/journal.pbio.3000966). To run this code, the data should be downloaded and extracted (~75 GB compressed, ~250 GB uncompressed).

## Preprocessing

To run the preprocessing:

1. Download some or all of the dataset. Should be a folder called `SRPBS_OPEN` with a bunch of metadata files `*.tsv` and a `data` subdirectory.
2. Change the file extensions on the rsfMRI scans to .nii (not clear why these aren't already like this...): `python Preprocessing/rename_nii_files.py <path-to-SBPBS_OPEN>`
3. Run the MATLAB preprocessing script for a particular subject: `preproprocessing_pipeline('path-to-SRPBS_OPEN', subject-number)`
4. For batch preprocessing, save the ids of the subjects to be processed in a text file and call `run_propro('path-to-SRPBS_OPEN', 'path-to-ids-file', Nth-subject-in-ids-file-to-run)`. An example is shown in `Preprocessing/prepro_COI.sh` to run on the ETH computing cluster.
5. Additionally, `preproprocessing_pipeline` can be called with a third parameter, specifying which steps of the pipeline to run.

The final output for rDCM is `rDCM/dcm_A_<subject-number>.mat` and for correlations is `correlation/correlation_components_<subject-number>.mat`

## Classifier Training

Classifier and cross validation protocols are specified in `Classifier/run_classifiers.py`. Different datasets variations are specified in `Classifier/run_different_classifier_splits.ipynb`, and this notebook is also used to launch classifier training.

## Results

Summary classification results graphs are generated in `Dataset Analysis/Stats_on_Classifiers.ipynb`. Statistical tests are performed in `Dataset Analysis/descriptive_stats.ipynb`.

## Useful links

Some information about the scan protocols they used is [here](https://bicr.atr.jp/wp-content/uploads/2018/08/UnifiedProtocol-1-1.pdf). (Actually, just found that some of the missing field map parameters might be specified in the .nii metadata when opening an individual scan volume in SPM).
