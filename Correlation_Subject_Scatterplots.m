function Correlation_Subject_Scatterplots(datatypes,restlag,tasklag,mask_inputdir,mask_prefix,outputdir,subject_list)
% This code outputs subject-specific scatterplots showing the relationship between lag values for rest and task, at several
% different thresholds, with regression lines on the scatterplots.
%
% datatypes: BH or CDB data.
%                   e.g. 'bh' or 'cdb'
% restlag: The location of the previously made rest segment lag matrix files (ends in '/')
%                   e.g. 'C:\Users\s\Desktop\Output_smoothed\sub-01_task-rest_bh\'
% tasklag: The location of the previously made task segment lag matrix files (ends in '/')
%                   e.g. 'C:\Users\s\Desktop\Output_task\sub-01_task-BH\'   
% mask_inputdir: The location of the maskfile to be applied (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Data/ATLAS_FILES/GM_0.5/'
% mask_prefix: The name of the mask file. 
%                   e.g. mask_prefix ='_T1_fast_pve_1_GM-MASK50_SBRef'
% outputdir: The location of the plot to be saved (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Lag_Compare/'
% subject_list: Which subjects to run the analysis on 
%                   e.g. subject_list={'sub-01';'sub-02';'sub-03';'sub-04';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10'}

tic
set(groot,'defaultFigureVisible','off') %Turns off plot display
%scrsz = get(0,'ScreenSize');
figure('Position', [1, 1, 1080, 1080])
t = tiledlayout(3,3,'TileSpacing','tight','Padding','tight');

for s = 1:length(subject_list)
    subject = subject_list{s};
    if strcmp(datatypes,'cdb') && strcmp(subject,'sub-06') % For sub-06, CDB amplitude threshold only goes to 0.6
        corrthres_all = [0,0.4,0.6];
    else
        corrthres_all = [0,0.4,0.7];
    end
    nexttile
    for ii = 1:size(corrthres_all,2)
    corrthres = corrthres_all(ii);

    % load file names, this part of the code may need to be changed based on file naming conventions from Rapidtide  
    if strcmp(datatypes,'cdb')
        rest_file = sprintf('%s%s_task-rest_%s/%s_task-rest_%s_desc-maxtime_map.nii.gz',restlag,subject,datatypes,subject,datatypes);
        task_file = sprintf('%s%s_task-%s/%s_task-%s_desc-maxtime_map.nii.gz',tasklag,subject,upper(datatypes),subject,upper(datatypes));
        maskname = sprintf('%s%s%s.nii.gz',mask_inputdir,subject,mask_prefix); % GM mask
        corrfitmask_rest_name = sprintf('%s%s_task-rest_%s/%s_task-rest_%s_desc-corrfit_mask.nii.gz',restlag,subject,datatypes,subject,datatypes);
        corrfitmask_task_name = sprintf('%s%s_task-%s/%s_task-%s_desc-corrfit_mask.nii.gz',tasklag,subject,upper(datatypes),subject,upper(datatypes));
        corr_rest_name = sprintf('%s%s_task-rest_%s/%s_task-rest_%s_desc-maxcorr_map.nii.gz',restlag,subject,datatypes,subject,datatypes);
        corr_task_name = sprintf('%s%s_task-%s/%s_task-%s_desc-maxcorr_map.nii.gz',tasklag,subject,upper(datatypes),subject,upper(datatypes));
    elseif strcmp(datatypes,'bh')
        rest_file = sprintf('%s%s_task-rest_bh/%s_task-rest_bhnothres_desc-maxtime_map.nii.gz',restlag,subject,subject);
        task_file = sprintf('%s%s_task-BH/%s_task-BH_desc-maxtime_map.nii.gz',tasklag,subject,subject);
        maskname = sprintf('%s%s%s.nii.gz',mask_inputdir,subject,mask_prefix); % GM mask
        corrfitmask_rest_name = sprintf('%s%s_task-rest_bh/%s_task-rest_bhnothres_desc-corrfit_mask.nii.gz',restlag,subject,subject);
        corrfitmask_task_name = sprintf('%s%s_task-BH/%s_task-BH_desc-corrfit_mask.nii.gz',tasklag,subject,subject);
        corr_rest_name = sprintf('%s%s_task-rest_bh/%s_task-rest_bhnothres_desc-maxcorr_map.nii.gz',restlag,subject,subject);
        corr_task_name = sprintf('%s%s_task-BH/%s_task-BH_desc-maxcorr_map.nii.gz',tasklag,subject,subject);
    end

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
    for i = 1:size(mask,1)
        for j = 1:size(mask,2)
            for k = 1:size(mask,3)
                if mask(i,j,k) == 1 % check if GM voxels
                    if corrfitmask_rest(i,j,k) == 1 && corrfitmask_task(i,j,k) == 1 % remove 0 values from rapidtide output mask   
                        if corr_rest(i,j,k) > corrthres && corr_task(i,j,k) > corrthres % only allow voxels with both correlation values greater than corrthres
                            if isnan(task_lag(i,j,k)) || isnan(rest_lag(i,j,k)) % remove NaN value, if any
                                continue
                            elseif abs(task_lag(i,j,k)) > 14.7 || abs(rest_lag(i,j,k)) > 14.7 % remove boundary lag value       
                                continue
                            end
                            task_lag_val = [task_lag_val,task_lag(i,j,k)];
                            rest_lag_val = [rest_lag_val,rest_lag(i,j,k)];       
                        end
                    end                
                end
            end
        end
    end
 
% explore correlation results after removing influential points based on cook's distance:
%mdl = fitlm(task_lag_val,rest_lag_val); 
%c_threshold  = 4/length(task_lag_val); % appropriate threshold setting?
%c_remove = find((mdl.Diagnostics.CooksDistance)>c_threshold);
%for r = 1:length(c_remove) % this loop is quite inefficient...
%    r_index = c_remove(r);
%    task_lag_val(r_index) = NaN;
%    rest_lag_val(r_index) = NaN;
%end

task_lag_val = task_lag_val(~isnan(task_lag_val));
rest_lag_val = rest_lag_val(~isnan(rest_lag_val));

% plot scatterplot
colorlist = [169/256 169/256 169/256;238/256 130/256 238/256;1 0 0]; % define line colors
scatter(task_lag_val,rest_lag_val,3,colorlist(ii,:),'o','filled')
hold on

% plot regression line
p1 = polyfit(task_lag_val,rest_lag_val,1);
% get r value here if needed

x = -15:0.00001:15;
yfit = polyval(p1,x); % = p1(1) * x + p1(2);
plot(x,yfit,'color',colorlist(ii,:)) %,'LineWidth',2)
axis square
hold on
    end

% plot y=x
ynorm = x;
plot(x,ynorm,'color',[0,0,0]) %,'LineWidth',2)
hold on
    
ylim([-8 8])
xlim([-8 8])
xticks([-8:2:8])
yticks([-8:2:8])
%set(gca,'fontsize',24)
title_temp = sprintf('%s',subject);
%title_temp = sprintf('Spatial correlation of relative hemodynamic lag values');
title(title_temp)
if strcmp(datatypes,'bh')
    %legend({'0','0','0.4','0.4','0.7','0.7','y=x'},'fontsize',20, 'Location','southeast')
    xlabel('BH+REST')
    ylabel('REST')
elseif strcmp(datatypes,'cdb')
    xlabel('CDB+REST')
    ylabel('REST')
end
    %if strcmp(subject,'sub-06') % sub-06 only goes up to 0.6
    %    legend({'0','0','0.4','0.4','0.6','0.6','y=x'},'fontsize',20, 'Location','southeast') 
    %else
    %    legend({'0','0','0.4','0.4','0.7','0.7','y=x'},'fontsize',20, 'Location','southeast')
    %end

%pic = gcf;
%picname = sprintf('%s_%s',subject,datatypes);
%saveas(pic,fullfile(outputdir,picname),'png');
%hold off
end

picname = sprintf('subplot_%s',datatypes);
saveas(gcf,fullfile(outputdir,picname),'png');
hold off

set(groot,'defaultFigureVisible','on') %Turns on plot display
toc

