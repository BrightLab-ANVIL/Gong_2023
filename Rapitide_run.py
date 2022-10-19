import os

subjects = ["sub-01"]  #"sub-01", "sub-02", "sub-03", "sub-04", "sub-06","sub-07", "sub-08", "sub-09", "sub-10"
data_types = ["_task-BH"] #"_task-rest_bh", "_task-CDB", "_task-rest_cdb"

for s in subjects:
    for d in data_types:

        input_file = "C:/Users/s/Desktop/Data/fMRI/" + s + d + "_acq-mb4_bold_mc_brain.nii.gz"
        output_prefix = "C:/Users/s/Desktop/Output/" + s + d + "/" + s + d
        GM_mask_file = "C:/Users/s/Desktop/Data/ATLAS_FILES/GM_0.5/" + s + "_T1_fast_pve_1_GM-MASK50_SBRef.nii.gz"

        rapidtide_command = "python C:/Users/s/anaconda3/Scripts/rapidtide" + " " + input_file + " " + output_prefix + " " + \
             "--globalmeaninclude" + " " + GM_mask_file + ":1 " + "--refineinclude" + " " + GM_mask_file + ":1" + " " + "--delaymapping --datatstep 1.2 --detrendorder 0 --oversampfac 4 --passes 3 --despecklepasses 4 --filterband lfo --searchrange -15 15 --pickleft --nolimitoutput --spatialfilt -1"

        print(rapidtide_command)
        os.system(rapidtide_command)

# FIRST RUN (the rapidtide_command above)
# Writing "--spatialfilt -1" sets sigma to be half the mean voxel dimension.  Half the mean voxel dimension is the reccomended smoothing setting in rapidtide. In these datsets the mean voxel dimension was 2mm so sigma is 1mm (FWHM 2.35mm).

# SECOND RUN (the rapidtide_command above, changing sigma)
# Re-ran the above rapidtide_command, for each subject and data_type, changing sigma to be σ = 2.13mm (FWHM 5mm)
