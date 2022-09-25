function CorrelationBand_Calc(datatypes,restlag,tasklag,mask_inputdir,mask_prefix,outputdir,subject_list,subplotyes)
% This code computes the correlation between task and rest segments on the lag times 
% at different amplitude threshold bands calculated from the rapiditde toolbox. 
% This code reads in rapidtide outputs of amplitude and
% lag times and outputs:
%       1. Excel sheets and .mat files at different thresholds
%       for future group average analysis and plotting
%       2. Single subject plots summarizing the distribution of delay times in task and rest  (histograms, probability density plots) and scatterplots to visualize their relationship
%
% datatypes: BH or CDB data.
%                   e.g. 'bh' or 'cdb'
% restlag: The location of the previously made rest segment lag matrix files (ends in '/')
%                   e.g. 'C:\Users\s\Desktop\Output_rest\sub-01_task-rest_bh\'
% tasklag: The location of the previously made task segment lag matrix files (ends in '/')
%                   e.g. 'C:\Users\s\Desktop\Output_task\sub-01_task-BH\'   
% mask_inputdir: The location of the maskfile to be applied (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Data/ATLAS_FILES/GM_0.5/'
% mask_prefix: The name of the mask file. 
%          e.g. mask_prefix ='_T1_fast_pve_1_GM-MASK50_SBRef'
% outputdir: The location of the plot to be saved (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Lag_Compare/'
% subject_list: Which subjects to run the analysis on 
%                   e.g. subject_list={'sub-01';'sub-02';'sub-03';'sub-04';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10'}
% subplotyes: specifies whether to output 9 plots, or a single plot with
% subplots. In the single plots mode, it also outputs histograms and
% probability density estimate plots for each subject.
%                   e.g. '1' is subplot; '0' is 9 plots

tic

maskID = mask_prefix;
for corrthres = [0,0.2,0.4]
    exceldata = [];
    summaryplot = [];
if subplotyes == 1
    set(groot,'defaultFigureVisible','off') %Turns off plot display
    scrsz = get(0,'ScreenSize');
    set(figure,'position',scrsz);
end
for s = 1:length(subject_list)
    exceldata = [exceldata;[s,s,s,s,s,s]];
    subject = subject_list{s};
    if subplotyes == 0
    set(groot,'defaultFigureVisible','off') %Turns off plot display
    scrsz = get(0,'ScreenSize');
    set(figure,'position',scrsz);  
    end
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

    % initialize voxel counters
    union_counter = 0;
    task_counter = 0;
    rest_counter = 0;
    GM_counter = sum(sum(sum(mask)));

%  Selecting - and counting - voxels used for later plotting and regression
    task_lag_val = [];
    rest_lag_val = [];
    for i = 1:size(mask,1)
        for j = 1:size(mask,2)
            for k = 1:size(mask,3)
                if mask(i,j,k) == 1 % check if GM voxels
                    if corrfitmask_rest(i,j,k) == 1 && corrfitmask_task(i,j,k) == 1 % remove 0 values from rapidtide output mask                      
                        if corrthres+0.2 >= corr_rest(i,j,k) && corr_rest(i,j,k) > corrthres && corrthres+0.2 >= corr_task(i,j,k) && corr_task(i,j,k) > corrthres 
                            % only allow voxels with both correlation values in the corrthres band
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
                        elseif corr_rest(i,j,k) > corrthres && corrthres+0.2 >= corr_rest(i,j,k) % count voxels that only pass threhold in one time segment
                            rest_counter = rest_counter + 1;
                        elseif corr_task(i,j,k) > corrthres && corrthres+0.2 >= corr_task(i,j,k)
                            task_counter = task_counter + 1;
                        end
                    elseif corrfitmask_rest(i,j,k) == 1 && corr_rest(i,j,k) > corrthres && corrthres+0.2 >= corr_rest(i,j,k) % count voxels that only appear in one time segment but passed the threshold
                        rest_counter = rest_counter + 1;
                    elseif corrfitmask_task(i,j,k) == 1 && corr_task(i,j,k) > corrthres && corrthres+0.2 >= corr_task(i,j,k)
                        task_counter = task_counter + 1;
                    end                
                end
            end
        end
    end

task_lag_val = task_lag_val(~isnan(task_lag_val));
rest_lag_val = rest_lag_val(~isnan(rest_lag_val));

% plot scatterplot and perform regression
if subplotyes == 1
    hold(subplot(3,3,s),'on') 
elseif subplotyes == 0
    hold on
end
scatter(task_lag_val,rest_lag_val,3,'o')
p1 = polyfit(task_lag_val,rest_lag_val,1);
x = -15:0.00001:15;
yfit = polyval(p1,x); % = p1(1) * x + p1(2);
plot(x,yfit,'-r','LineWidth',1)
[r, PVAL] = corrcoef([task_lag_val',rest_lag_val']); % stat testing not helpful now, p-val 0 from so many data points

ylim([-15 15])
xlim([-15 15])
if subplotyes == 1
    title(sprintf('%s',subject))
else
    title_temp = sprintf('Lag values of %s vs. resting-state, %.1f',upper(datatypes),corrthres);
    title(title_temp)
end
xlabel('task lag')
ylabel('rest lag')
hold off

% save values
corrfitmask_restsum = sum(sum(sum(corrfitmask_rest)));  % save the number of voxels that have value when outputted by rapidtide
corrfitmask_tasksum = sum(sum(sum(corrfitmask_task)));
exceldata = [exceldata;[p1(1),p1(2),r(1,2),PVAL(1,2),corrfitmask_restsum,corrfitmask_tasksum]];
summaryplot = [summaryplot;[p1(1),p1(2),r(1,2),task_counter/GM_counter,rest_counter/GM_counter,union_counter/GM_counter]]; % percentage of voxels passing the threshold in the GM mask

% save plot for single plots
if subplotyes == 0
    pic = gcf;
    picname = sprintf('%.0f_Lagtime_Compare_%s',corrthres*10,subject);
    saveas(pic,fullfile(outputdir,subject,picname),'png');
end

% plot histograms
if subplotyes == 0
    % figure 1
    figure;
    plot_data_task=task_lag_val;
    [f,xi] = ksdensity(plot_data_task);
    plot(xi,f,'color',[0 0.2 0.5],'LineWidth',3)

    hold on
    plot_data_rest=rest_lag_val;
    [f,xi] = ksdensity(plot_data_rest);
    plot(xi,f,'color',[0 0.7 0.3],'LineWidth',3)
    
    legend('task','rest')
    xlabel('Lag (sec)')
    set(gca,'FontSize',12)
    xlim([-8 8])
    ylabel('pde')
    ylim([0 0.5])
    title(subject)
    
    % save figure
    pic = gcf;
    picname = sprintf('%.0f_Lagtime_Compare_curve_%s',corrthres*10,subject);
    saveas(pic,fullfile(outputdir,subject,picname),'png');
    
    %figure 2
    figure;
    subplot(1,2,1)
    plot_data_task=task_lag_val;
    histogram(plot_data_task,'BinWidth', 0.9, 'Normalization','probability')
    title('task')
    ylim([0 0.5])
    subplot(1,2,2)
    plot_data_rest=rest_lag_val;
    histogram(plot_data_rest,'BinWidth', 0.9, 'Normalization','probability')
    title('rest')
    ylim([0 0.5])
    
    % save figure
    pic = gcf;
    picname = sprintf('%.0f_Lagtime_Compare_hist_%s',corrthres*10,subject);
    saveas(pic,fullfile(outputdir,subject,picname),'png');
    set(groot,'defaultFigureVisible','on')
end


end

% save plot for subplots
if subplotyes == 1
    pic = gcf;
    picname = sprintf('Lagtime_Compare_pic');
    saveas(pic,fullfile(outputdir,picname),'png');
    set(groot,'defaultFigureVisible','on')
end

% save numbers to excel
exceldata = [["slope","intercept","r","p-val","rest","task"];exceldata];
exceldata_name = sprintf('%.0f_Lagtime_Compare_values.xlsx',corrthres*10);
txtdir = fullfile(outputdir,exceldata_name);
xlswrite(txtdir,exceldata);

% save as .mat file for across-subject summary
summaryplot_name = sprintf('%.0f_summaryvalues.mat',corrthres*10);
save(fullfile(outputdir,summaryplot_name),'summaryplot');

end

toc

