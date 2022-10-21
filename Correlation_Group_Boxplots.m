function Correlation_Group_Boxplots(datatypes,inputdir,outputdir,corrthres)
% This code generates boxplots to summarize group results based on the outputs of Correlation_Calc.m (all GM voxels).
%
% datatypes: BH or CDB data.
%                   e.g. 'bh' or 'cdb'
% inputdir: The location of the input files (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Lag_Compare/'
% outputdir: The location of the plot to be saved (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Lag_Compare/'
% corrthres: A list of correlation thresholds used. 

tic

summary_slope = [];
summary_intercept = [];
summary_r = [];
summary_percentage_task = [];
summary_percentage_rest = [];
summary_percentage_union = [];

% list sub-06 separately
summary_slope_sub06 = [];
summary_intercept_sub06 = [];
summary_r_sub06 = [];
summary_percentage_task_sub06 = [];
summary_percentage_rest_sub06 = [];
summary_percentage_union_sub06 = [];

% prepare to save plots
set(groot,'defaultFigureVisible','off') %Turns off plot display
scrsz = get(0,'ScreenSize');
set(figure,'position',scrsz);

% prepare for boxplot group name
if strcmp(datatypes,'bh')
    name_short = char('None','0','0.1','0.2','0.3','0.4','0.5','0.6','0.7');
    name = repmat(name_short,9,1);
    name_percent_union = char('None_union','None_union','None_union','None_union','None_union','None_union','None_union','None_union','None_union', ...
    '0_union','0_union','0_union','0_union','0_union','0_union','0_union','0_union','0_union', ...
    '0.1_union','0.1_union','0.1_union','0.1_union','0.1_union','0.1_union','0.1_union','0.1_union','0.1_union', ...
    '0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union', ...
    '0.3_union','0.3_union','0.3_union','0.3_union','0.3_union','0.3_union','0.3_union','0.3_union','0.3_union', ...
    '0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union', ...
    '0.5_union','0.5_union','0.5_union','0.5_union','0.5_union','0.5_union','0.5_union','0.5_union','0.5_union', ...
    '0.6_union','0.6_union','0.6_union','0.6_union','0.6_union','0.6_union','0.6_union','0.6_union','0.6_union', ...
    '0.7_union','0.7_union','0.7_union','0.7_union','0.7_union','0.7_union','0.7_union','0.7_union','0.7_union');
elseif strcmp(datatypes,'cdb') % CDB amplitude threshold only goes to 0.6
    name_short = char('None','0','0.1','0.2','0.3','0.4','0.5','0.6','0.7');
    name = repmat(name_short,8,1);
    name_percent_union = char('None_union','None_union','None_union','None_union','None_union','None_union','None_union','None_union', ...
    '0_union','0_union','0_union','0_union','0_union','0_union','0_union','0_union', ...
    '0.1_union','0.1_union','0.1_union','0.1_union','0.1_union','0.1_union','0.1_union','0.1_union', ...
    '0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union', ...
    '0.3_union','0.3_union','0.3_union','0.3_union','0.3_union','0.3_union','0.3_union','0.3_union', ...
    '0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union', ...
    '0.5_union','0.5_union','0.5_union','0.5_union','0.5_union','0.5_union','0.5_union','0.5_union', ...
    '0.6_union','0.6_union','0.6_union','0.6_union','0.6_union','0.6_union','0.6_union','0.6_union', ...
    '0.7_union','0.7_union','0.7_union','0.7_union','0.7_union','0.7_union','0.7_union','0.7_union');
end

% load all mat files
for i = 1:length(corrthres)
    summaryplot_name = sprintf('%.0f_summaryvalues.mat',corrthres(i)*10);
    datafile = load(fullfile(inputdir,summaryplot_name));
    datafile = datafile.summaryplot;
    if strcmp(datatypes,'cdb') && corrthres(i) ~= 0.7
        summary_slope = [summary_slope,datafile([1:4,6:end],1)];
        summary_intercept = [summary_intercept,datafile([1:4,6:end],2)];
        summary_r = [summary_r,datafile([1:4,6:end],3)];
        summary_percentage_task = [summary_percentage_task,datafile([1:4,6:end],4)];
        summary_percentage_rest = [summary_percentage_rest,datafile([1:4,6:end],5)];
        summary_percentage_union = [summary_percentage_union,datafile([1:4,6:end],6)];
    
        summary_slope_sub06 = [summary_slope_sub06,datafile([5],1)];
        summary_intercept_sub06 = [summary_intercept_sub06,datafile([5],2)];
        summary_r_sub06 = [summary_r_sub06,datafile([5],3)];
        summary_percentage_task_sub06 = [summary_percentage_task_sub06,datafile([5],4)];
        summary_percentage_rest_sub06 = [summary_percentage_rest_sub06,datafile([5],5)];
        summary_percentage_union_sub06 = [summary_percentage_union_sub06,datafile([5],6)];
    else
        summary_slope = [summary_slope,datafile(:,1)];
        summary_intercept = [summary_intercept,datafile(:,2)];
        summary_r = [summary_r,datafile(:,3)];
        summary_percentage_task = [summary_percentage_task,datafile(:,4)];
        summary_percentage_rest = [summary_percentage_rest,datafile(:,5)];
        summary_percentage_union = [summary_percentage_union,datafile(:,6)];
    end
end


% Average correlation value: 
% (1) Fisher's Z transform, before averaging
summary_r = atanh(summary_r); % from r to ZF

% (2) Average Fisher's Z (ZF)
% aver_ZF = mean(ZF(~isnan(ZF)));
 
% (3) Convert average back to r
% summary_r = (exp(2*aver_ZF)-1)/(exp(2*aver_ZF)+1); 

% takes the median value of each threshold and save for comparison with smoothed 
median_percentages = median(summary_percentage_union);
median_slopes = median(summary_slope);
median_r = median(summary_r);

% reshape matrix for boxplots
summary_slope = reshape(summary_slope',[],1);
summary_intercept = reshape(summary_intercept',[],1);
summary_r = reshape(summary_r',[],1);

% plot task/rest/union to see trends
summary_percentage_task = reshape(summary_percentage_task,[],1);
summary_percentage_rest = reshape(summary_percentage_rest,[],1);
summary_percentage_union = reshape(summary_percentage_union,[],1);
%summary_percentage = [summary_percentage_task;summary_percentage_rest;summary_percentage_union]; % this was originally to see task vs. rest remaining voxel percentages
summary_percentage = [summary_percentage_union];

% read in median values from less smoothed outputs for comparison
smoothed_compare = 1;
if smoothed_compare == 1
    datafile = load(fullfile('C:\Users\s\OneDriveNU\Active\Lag_Compare_BH\median\','percentages.mat'));
    unsmoothed_percentage = datafile.median_percentages;
    datafile = load(fullfile('C:\Users\s\OneDriveNU\Active\Lag_Compare_BH\median\','slopes.mat'));
    unsmoothed_slopes = datafile.median_slopes;
    datafile = load(fullfile('C:\Users\s\OneDriveNU\Active\Lag_Compare_BH\median\','r.mat'));
    unsmoothed_r = datafile.median_r;
end

% plot for slopes
figure
boxplot(summary_slope,name)
hold on
if strcmp(datatypes,'cdb')
    plot(summary_slope_sub06,'go')
    legend(['sub-06'])
end
xlabel('Amplitude thresholds')
ylabel({'Slope'})
title({'Slope of Agreement between Lag Values'})
axis square
%ylim([0 1.3])
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'k');

% plot the less smoothed median data for comparison
if smoothed_compare == 1
    plot(1:9,unsmoothed_slopes,'-*','linewidth',1,'Color','k')
    legend({"Group Median Value" + newline  + "of Less Smoothed Data"},'location','southeast')
end

pic = gcf;
picname = sprintf('Summary_Slopes');
saveas(pic,fullfile(outputdir,picname),'png');

% plot for intercepts
figure
boxplot(summary_intercept,name)
if strcmp(datatypes,'cdb')
    hold on
    plot(summary_intercept_sub06,'go')
    legend(['sub-06'])
end
xlabel('Amplitude threshold for masking')
ylabel('intercept (seconds)')
title('Across-subjects Summary, Intercepts, GM mask')
ylim([-1 1])

pic = gcf;
picname = sprintf('Summary_Intercepts');
saveas(pic,fullfile(outputdir,picname),'png');

% plot for correlation coefficients
figure
boxplot(summary_r,name)
hold on
if strcmp(datatypes,'cdb')
    plot(summary_r_sub06,'go')
    legend(['sub-06'])
end
xlabel('Amplitude thresholds')
ylabel("Fisher's Z(r)")
title({'Spatial Correlation of Lag Values'})
axis square
%ylim([0 1]) values different for ZF transformed
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'k');

% plot the less smoothed median data for comparison
if smoothed_compare == 1
    plot(1:9,unsmoothed_r,'-*','linewidth',1,'Color','k')
end

pic = gcf;
picname = sprintf('Summary_r');
saveas(pic,fullfile(outputdir,picname),'png');

% plot for voxel percentages
figure
boxplot(summary_percentage*100,name_percent_union) % change this line to plot task and rest with union
hold on
if strcmp(datatypes,'cdb')
    plot(summary_percentage_union_sub06*100,'go')
    legend(['sub-06'])
end
xlabel('Amplitude thresholds')
ylabel('Voxels remaining (%)')
title('GM voxels satisfying amplitude threshold')
xticklabels({'None','0','0.1','0.2','0.3','0.4','0.5','0.6','0.7'})
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'k');
axis square

% plot the less smoothed median data for comparison
if smoothed_compare == 1
    plot(1:9,unsmoothed_percentage*100,'-*','linewidth',1,'Color','k')
end

pic = gcf;
picname = sprintf('Summary_percentage');
saveas(pic,fullfile(outputdir,picname),'png');

set(groot,'defaultFigureVisible','on')

% save values for comparison with smoothed Rapidtide outputs
savevalues = 0;
if savevalues == 1
    median_dir = fullfile(inputdir,'median');
    save(fullfile(median_dir,'percentages.mat'),'median_percentages');
    save(fullfile(median_dir,'slopes.mat'),'median_slopes');
    save(fullfile(median_dir,'r.mat'),'median_r');
end

toc
