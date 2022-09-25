# bash /mnt/c/Users/s/Documents/Github/Rapidtide-task-rest/MSI_Create_Maps.sh

# <input_file> the imaging data that is your 'REST' portion (not detrended)
input_dir='/mnt/c/Users/s/OneDriveNU/Data/fMRI'
# <output_file>
output_dir='/mnt/c/Users/s/OneDriveNU/Data/Tmean'
subject_list=("01" "02" "03" "04" "06" "07" "08" "09" "10")

# If output directory does not exist, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

for subject_line in "${subject_list[@]}"; do

    echo "--------------------------------"
    echo "${subject} RUNNING"
    echo "--------------------------------"

    subject="sub-${subject_line}"
    fslmaths ${input_dir}/${subject}_task-rest_bh_acq-mb4_bold_mc_brain.nii.gz -Tmean ${output_dir}/${subject}_task-rest_bh_acq-mb4_bold_mc_brain_Tmean.nii.gz
    
    echo "--------------------------------"
    echo "${subject} COMPLETED"
    echo "--------------------------------"

done
