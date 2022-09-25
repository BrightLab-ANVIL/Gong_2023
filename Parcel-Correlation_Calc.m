function Parcel-Correlation_Calc(restlag,tasklag,mask_inputdir,mask_prefix,outputdir,subject_list)
% This code computes the correlation between task and rest segments on the lag times 
% at different amplitude thresholds calculated from the rapiditde toolbox. 
% This function is the same Correlation_Calc.m but performs the analysis seperately for each GM subregion. 
%
% This code reads in rapidtide outputs of amplitude and
% lag times and outputs:
%       Single subject remaining voxel percentages of different parcels (from atlas) and correlation outputs, at different amplitude thresholds.
%
% restlag: The location of the previously made rest segment lag matrix files (ends in '/')
%                   e.g. 'C:\Users\s\OneDriveNU\Data\Rapidtide_run\Output\'
% tasklag: The location of the previously made task segment lag matrix files (ends in '/')
%                   e.g. 'C:\Users\s\OneDriveNU\Data\Rapidtide_run\Output_task\'   
% mask_inputdir: The location of the maskfile to be applied (ends in '/')
%                   e.g. 'C:\Users\s\OneDriveNU\Data\ATLAS_FILES\MNI_2mm_subject_atlas\'
% mask_prefix: The name of the mask file. Instead of a GM mask indicating 0 or 1, this code reads in an atlas file, with regions coded 1 to 9.
%                   e.g. mask_prefix ='_ATLAS_SBRef-maxprob-thr25-2mm' 
% outputdir: The location of the plot to be saved (ends in '/')
%                   e.g. 'C:\Users\s\OneDriveNU\Active\Lag_Compare_MNI\'
% subject_list: Which subjects to run the analysis on 
%                   e.g. subject_list={'sub-01';'sub-02';'sub-03';'sub-04';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10'}
%

tic

for corrthres = [-5,0:0.1:0.7] % sets the amplitude thresholds
    exceldata = [];
    summaryplot = [];

for s = 1:length(subject_list)
    exceldata = [exceldata;[s,s,s,s,s,s]];
    subject = subject_list{s}; 

    % load file names                    
    rest_file = sprintf('%s%s_task-rest_bh/%s_task-rest_bh_desc-maxtime_map.nii.gz',restlag,subject,subject);
    task_file = sprintf('%s%s_task-BH/%s_task-BH_desc-maxtime_map.nii.gz',tasklag,subject,subject);
    maskname = sprintf('%s%s%s.nii.gz',mask_inputdir,subject,mask_prefix); % subject MNI atlas with 9 regions
    corrfitmask_rest_name = sprintf('%s%s_task-rest_bh/%s_task-rest_bh_desc-corrfit_mask.nii.gz',restlag,subject,subject);
    corrfitmask_task_name = sprintf('%s%s_task-BH/%s_task-BH_desc-corrfit_mask.nii.gz',tasklag,subject,subject);
    corr_rest_name = sprintf('%s%s_task-rest_bh/%s_task-rest_bh_desc-maxcorr_map.nii.gz',restlag,subject,subject);
    corr_task_name = sprintf('%s%s_task-BH/%s_task-BH_desc-maxcorr_map.nii.gz',tasklag,subject,subject);

    % Process lag file, ready for comparison 
    datafile1 = load_untouch_nii(rest_file);
    datafile2 = load_untouch_nii(task_file);
    rest_lag = datafile1.img;
    task_lag = datafile2.img;
    mask = load_untouch_nii(maskname);
    mask = mask.img;
    corrfitmask_rest = load_untouch_nii(corrfitmask_rest_name);
    corrfitmask_rest = corrfitmask_rest.img;
    corrfitmask_task = load_untouch_nii(corrfitmask_task_name);
    corrfitmask_task = corrfitmask_task.img;
    corr_rest_file = load_untouch_nii(corr_rest_name);
    corr_task_file = load_untouch_nii(corr_task_name);
    corr_rest = corr_rest_file.img;
    corr_task = corr_task_file.img;

%  Selecting - and counting - voxels used for later plotting and regression
    task_lag_val = [];
    rest_lag_val = [];

for mm = 1:9
    % initialize voxel counters
    union_counter = 0;
    task_counter = 0;
    rest_counter = 0;
    mask_counter = size(find(mask==mm),1); 
    for i = 1:size(mask,1)
        for j = 1:size(mask,2)
            for k = 1:size(mask,3)
                if mask(i,j,k) == mm % parcel number
                    if corrfitmask_rest(i,j,k) == 1 && corrfitmask_task(i,j,k) == 1 % remove 0 values from rapidtide output mask                      
                        if corr_rest(i,j,k) > corrthres && corr_task(i,j,k) > corrthres % only allow voxels with both correlation values greater than corrthres
                            union_counter = union_counter + 1;
                            rest_counter = rest_counter + 1;
                            task_counter = task_counter + 1;
                            if isnan(task_lag(i,j,k)) || isnan(rest_lag(i,j,k)) % remove NaN value, if any
                                continue
                            elseif abs(task_lag(i,j,k)) > 14.7 || abs(rest_lag(i,j,k)) > 14.7 % remove boundary lag value       
                                continue
                            end
                            task_lag_val = [task_lag_val,task_lag(i,j,k)];
                            rest_lag_val = [rest_lag_val,rest_lag(i,j,k)];
                        elseif corr_rest(i,j,k) > corrthres % counter voxels that only pass threhold in one time segment
                            rest_counter = rest_counter + 1;
                        elseif corr_task(i,j,k) > corrthres
                            task_counter = task_counter + 1;
                        end
                    elseif corrfitmask_rest(i,j,k) == 1 && corr_rest(i,j,k) > corrthres % count voxels that only appear in one time segment but passed the threshold
                        rest_counter = rest_counter + 1;
                    elseif corrfitmask_task(i,j,k) == 1 && corr_task(i,j,k) > corrthres
                        task_counter = task_counter + 1;
                    end                
                end
            end
        end
    end
% save values
task_lag_val = task_lag_val(~isnan(task_lag_val));
rest_lag_val = rest_lag_val(~isnan(rest_lag_val));
p1 = polyfit(task_lag_val,rest_lag_val,1);
[r, PVAL] = corrcoef([task_lag_val',rest_lag_val']); % stat testing not helpful right now, p-val 0 from so many data points

corrfitmask_restsum = sum(sum(sum(corrfitmask_rest)));  % save the number of voxels that have value when outputted by rapidtide
corrfitmask_tasksum = sum(sum(sum(corrfitmask_task)));
exceldata = [exceldata;[p1(1),p1(2),r(1,2),PVAL(1,2),corrfitmask_restsum,corrfitmask_tasksum]];
summaryplot = [summaryplot;[p1(1),p1(2),r(1,2),task_counter/mask_counter,rest_counter/mask_counter,union_counter/mask_counter]]; % percentage of voxels passing the threshold in the GM mask

end

end

% save numbers to excel
exceldata = [["slope","intercept","r","p-val","rest","task"];exceldata];
exceldata_name = sprintf('%.0f_Lagtime_Compare_values_MNI.xlsx',corrthres*10);
txtdir = fullfile(outputdir,exceldata_name);
xlswrite(txtdir,exceldata);

% save as .mat file for across-subject summary
summaryplot_name = sprintf('%.0f_summaryvalues_MNI.mat',corrthres*10);
save(fullfile(outputdir,summaryplot_name),'summaryplot');

end

toc

