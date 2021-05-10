# TNU MDD Project

## Preprocessing

To run the preprocessing:

1. Download some or all of the dataset. Should be a folder called `SRPBS_OPEN` with a bunch of metadata files `*.tsv` and a `data` subdirectory.
2. Change the file extensions on the rsfMRI scans to .nii (not clear why these aren't already like this...): `python Preprocessing/rename_nii_files.py <path-to-SBPBS_OPEN>`

3. Run the MATLAB preprocessing script for a particular subject: `prepro_subject('path-to-SRPBS_OPEN', subject-number, 1)`
