# Hemodynamic timing in resting-state and breathing-task BOLD fMRI
DOI: << paste here when it exists >> 

Unfortunately we do not have the permission to share the fMRI files, but we hope this workflow doc explains the data analysis structure! 

## The breathing task visual stimuli 

The stimuli were created with this [PsychoPy code](https://github.com/RayStick/Breathing-Task-Visual-PsychoPy) using these input arguments:

_Breath Hold + REST_

scan_trigger = 5; doRest = 2; tResting = 480 ; trialnum = 3; tPace = 24 ; tBreathPace = 6; tHold = 15; tExhale = 2; tRecover = 4; BH_instructions = 'BREATH-HOLD task \n \nFollow the breathing instructions \n \nBreathe through your nose'; end_exp_key = 'escape'

_Cued Deep Breathing + REST_

scan_trigger = 5; doRest = 2; tResting = 480; trialnum = 2; tStartRest = 28; tGetReady = 2; tCDB = 8; tCDBPace = 4; tFree = 43; CDB_instructions = 'DEEP BREATHING task \n \nTake deep breaths IN and OUT when cued \n \nBreathe through your nose'; end_exp_key = 'escape'

## Data Analysis Section 1. Rapidtide Run (v2.0.9)
We used a [python script](Rapitide_run.py) to facilitate running multiple subjects, data segments, and smoothing options.

Instructions on downloading and using the Rapidtide toolbox can be found here:
https://rapidtide.readthedocs.io/en/stable/introduction.html

### Inputs
- Pre-processed fMRI file
   - Each fMRI file split into data segments containing 390 volumes (TR of 1.2 seconds)
   - Pre-processing was done prior to the rapidtide run and included: motion correction, brain extraction and detrending (removal of Legendre polynomials up to the 4th degree and the six motion parameters)
- GM mask in fMRI subject space
   - T1-weighted file was segmented into tissue types and a GM tissue mask was subsequently created by thresholding the partial volume estimate image to 0.5 and transforming it to the subject fMRI space

#### To run rapidtide from command line (example for BH task dataset):
```
path_to_rapidtide/rapidtide parent_path/sub-01_task-BH_acq-mb4_bold_mc_brain.nii.gz parent_path/Output_BH/sub-01_task-BH/sub-01_task-BH --globalmeaninclude parent_path/sub-01_GM-MASK50_fMRI.nii.gz:1 --refineinclude parent_path/sub-01_GM-MASK50_fMRI.nii.gz:1 --delaymapping --autosync --datatstep 1.2 --detrendorder 0 --oversampfac 4 --passes 3 --despecklepasses 4 --filterband lfo --searchrange -15 15 --pickleft --nolimitoutput --spatialfilt -1
```

-	Do NOT add or remove the options trailing the directories, they are the same for all file inputs regardless of task or rest. Only change the input and output directories to fit the use of your computer.
-	Rapidtide calculations have some uncertainty, this means the delay values and correlation amplitudes will not always be the same numerical value across repeated runs, but should be of similar value and resemble the same trends.

### Outputs
_Rapidtide_ outputs a folder of many files, here list some which are relevant to our workflow:
- sub-01_task-BH_desc-maxcorr_map.nii.gz
   - This file contains the voxel-wise correlation amplitudes, that will be used for amplitude thresholding in later analysis
- sub-01_task-BH_desc-maxtime_map.nii.gz
    - This file contains the voxel-wise hemodynamic delays
- sub-01_task-BH_commandline.txt
    - This file lists the command executed by Rapidtide, it is good practice to always check the final command line after running the dataset and before proceeding further
 
## Data Analysis Section 2. MATLAB analysis of Rapidtide outputs

### Part 1. All GM voxels

This part was run on the BH+REST dataset (two different levels of smoothing), and the CDB+REST dataset. 

#### 1A) [Correlation_Calc.m](Correlation_Calc.m) (datatypes,restlag,tasklag,mask_inputdir,mask_prefix,outputdir,subject_list,subplotyes)

This function computes the correlation between task+rest and rest segments on the delay times, calculated from the Rapidtide toolbox, at different amplitude thresholds. 

__Inputs__
- Rapidtide sub-x_task-x_desc-maxcorr_map.nii.gz
- Rapidtide sub-x_task-x_desc-maxtime_map.nii.gz
- GM mask

__Outputs__
- Excel sheets and .mat files recording the correlation between delay times at different amplitude thresholds, for future group average analysis and plotting
   - These files are important for generating group average boxplots
- Single subject plots summarizing the distribution of delay times in task and rest  (histograms, probability density plots) and scatterplots to visualize their relationship.  

For analysis of amplitude threshold **bands**, [CorrelationBand_Calc.m](CorrelationBand_Calc.m) was run, and the inputs and outputs match what is described above. An additional output (for less-smoothed Rapidtide outputs only) is a MATLAB data file of group median values of slope, correlation coefficient (Z-transformed), and voxel percentage remaining for each amplitude threshold band. This is for the use of comparing with additionally smoothed Rapidtide outputs in plots.  

#### 1B) [Correlation_Subject-Scatterplots.m](Correlation_Subject-Scatterplots.m) (datatypes,restlag,tasklag,mask_inputdir,mask_prefix,outputdir,subject_list)

This function produces a graphical representation of the previous step, therefore can be done independently of the previous step and is not required for later analysis.

__Inputs__
- Rapidtide sub-x_task-x_desc-maxcorr_map.nii.gz
- Rapidtide sub-x_task-x_desc-maxtime_map.nii.gz
- GM mask

__Outputs__
- Scatterplot of the relationship between delay times (task plotted against rest) at different amplitude thresholds, with regression lines of best fit
   - Only shows representative amplitude thresholds of: all GM (no threshold), 0, 0.4, maximum threshold with unique regression fitting (0.6 for CDB sub-06, 0.7 for others)
   
For analysis of amplitude threshold **bands**, [CorrelationBand_Subject-Scatterplots.m](CorrelationBand_Subject-Scatterplots.m) was run, and the inputs and outputs match what is described above. Representative amplitude threshold bands are plotted: 0-0.2, 0.2-0.4, 0.4-0.6.

#### 1C) [Correlation_Group-Boxplots.m](Correlation_Group-Boxplots.m) (datatypes,inputdir,outputdir,corrthres)

 This function generates group summary plots based on the outputs of (1A). 

__Inputs__
- Correlation_Calc.m outputs - excel sheets and .mat files recording the voxels delay times and correlations at different amplitude thresholds

__Outputs__
- Boxplots of group average slope, correlation coefficient (Z-transformed), intercept, and voxel percentage remaining

For analysis of amplitude threshold **bands**, [CorrelationBand_Group-Boxplots.m](CorrelationBand_Group-Boxplots.m) was run, and the inputs and outputs match what is described above. For additionally smoothed outputs, the less-smoothed outputs are overlaid for ease of comparison.

### Part 2. GM voxels in specific subregions (parcels)

This part was run on the BH+REST dataset (less-smoothed inputs only).

#### 2A)  [Parcel-Correlation_Calc.m](Parcel-Correlation_Calc.m) (restlag,tasklag,mask_inputdir,mask_prefix,outputdir,subject_list)

This function is the same as (1A-Correlation_Calc.m) but performs the correlation seperately for each GM subregion.  

__Inputs__
- Rapidtide sub-x_task-x_desc-maxcorr_map.nii.gz
- Rapidtide sub-x_task-x_desc-maxtime_map.nii.gz
- GM mask: Instead of a GM mask indicating 0 or 1, this code reads in an atlas file. The atlas needs to be transformed to the the same space as the Rapidtide input files and need to contain exactly 9 parcels coded from 1 to 9. With simple changes to the code, the number of required parcels can be changed.  

__Outputs__
- Excel sheets and .mat files recording the correlation between delay times at different amplitude thresholds, for future group average analysis and plotting
  - These files are important for generating group average boxplots

#### 2B)  [Parcel-Correlation_Group-PerPlot.m](Parcel-Correlation_Group-PerPlot.m) (inputdir,outputdir,corrthres)

This function plots the percentage of voxels passing the amplitude threshold in task and rest data segments, using outputs from 2A (Parcel-Correlation_Calc.m)

__Inputs__
- Parcel-Correlation_Calc.m outputs - Excel sheets and .mat files 

__Outputs__
- A plot of median voxel percentage passing each amplitude threshold, across all subjects. Each colored line represents a different GM parcel with the entire GM as a black line.

#### 2C)  [Parcel-Correlation_Group-Others.m](Parcel-Correlation_Group-Others.m) (inputdir,outputdir,corrthres)

This function plots the slope and r (Z-transformed) from the task vs. rest delay regression, using outputs from 2A (Parcel-Correlation_Calc.m)

__Inputs__
- Parcel-Correlation_Calc.m outputs - Excel sheets and .mat files 

__Outputs__
- A plot of median slope and median r (Z-transformed) for each amplitude threshold, across all subjects. Each colored line represents a different GM parcel with the entire GM as a black line.

### Part 3. Mean Signal Intensity Histograms

This part was run on the REST portion of the BH+REST dataset (less-smoothed inputs only, not detrended).
The MSI histograms were displayed in the manuscript next to maps showing which voxels exceeded a threshold of 0.6. These maps were created by viewing the correlation amplitude output from Rapidtide (sub-x_task-BH_desc-maxcorr_map.nii.gz) and thresholding in the FSLeyes viewer. For the group plot, these correlation amplitude maps were first transformed to MNI space, and the number of subjects exceeding this same threshold of 0.6 was summarized.  

#### [MSI_Create_Maps.sh](MSI_Create_Maps.sh) 

This script was used to create the MSI maps, by taking the temporal mean across the resting state portion of the data, not detrended.  

#### [MSI_Histograms.m](MSI_Histograms.m) (inputdir_corr,inputdir_Tmean,outputdir,subject_list)

This function plots the probability density estimates of MSI for voxels in different amplitude threshold bands.

__Inputs__
-	Rapidtide sub-x_task-x_desc-maxcorr_map.nii.gz
-	File containing the voxel-wise MSI values:sub-x_task-rest_bh_acq-mb4_bold_mc_brain_Tmean.nii (created with MSI_Create_Maps.sh) 

__Outputs__
-	Histograms of probability density estimates of MSI for voxels in different amplitude threshold bands of: 0-0.2, 0.2-0.4, 0.4-0.6, >0.6
