function CorrelationBand_Group_Boxplots(inputdir,outputdir,corrthres)
% This code generates boxplots to summarize group results based on the outputs of CorrelationBand_Calc.m (all GM voxels).
%
% inputdir: The location of the input files (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Lag_Compare/'
% outputdir: The location of the plot to be saved (ends in '/')
%                   e.g. 'C:/Users/s/Desktop/Lag_Compare/'
% corrthres: A list of correlation thresholds used. 

tic

summary_slope = [];
summary_r = [];
summary_percentage_union = [];

% prepare to save plots
set(groot,'defaultFigureVisible','off') %Turns off plot display
scrsz = get(0,'ScreenSize');
set(figure,'position',scrsz);

% prepare for boxplot group name
name_short = char('0','0.2','0.4');
name = repmat(name_short,9,1);
name_percent_union = char('0_union','0_union','0_union','0_union','0_union','0_union','0_union','0_union','0_union', ...
    '0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union','0.2_union', ...
    '0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union','0.4_union');

% load all mat files
for i = 1:length(corrthres)
    summaryplot_name = sprintf('%.0f_summaryvalues.mat',corrthres(i)*10);
    datafile = load(fullfile(inputdir,summaryplot_name));
    datafile = datafile.summaryplot;
    summary_slope = [summary_slope,datafile(:,1)];
    summary_r = [summary_r,datafile(:,3)];
    summary_percentage_union = [summary_percentage_union,datafile(:,6)];
end

% Average correlation value: 
% Fisher's Z transform, before averaging
summary_r = atanh(summary_r); % from r to ZF

% takes the median value of each threshold and save for comparison with smoothed 
median_percentages = median(summary_percentage_union);
median_slopes = median(summary_slope);
median_r = median(summary_r);

% plot task/rest/union to see trends
summary_percentage_union = reshape(summary_percentage_union,[],1);
summary_percentage = [summary_percentage_union];
summary_slope = reshape(summary_slope',[],1);
summary_r = reshape(summary_r',[],1);

% read in median values from less smoothed outputs for comparison
smoothed_compare = 1;
if smoothed_compare == 1
    datafile = load(fullfile('C:\Users\s\OneDriveNU\Active\Lag_Compare_BH_band\median\','percentages.mat'));
    unsmoothed_percentage = datafile.median_percentages;
    datafile = load(fullfile('C:\Users\s\OneDriveNU\Active\Lag_Compare_BH_band\median\','slopes.mat'));
    unsmoothed_slopes = datafile.median_slopes;
    datafile = load(fullfile('C:\Users\s\OneDriveNU\Active\Lag_Compare_BH_band\median\','r.mat'));
    unsmoothed_r = datafile.median_r;
end

% plot for slopes
figure
boxplot(summary_slope,name)
hold on
xlabel('Amplitude threshold bands')
xticklabels({'0-0.2','0.2-0.4','0.4-0.6'})
ylabel({'Slope'})
title({'Slope of Agreement between Lag Values'})
axis square
%ylim([0 1.3])
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'k');

% plot the less smoothed median data for comparison
if smoothed_compare == 1
    plot(1:3,unsmoothed_slopes,'-*','linewidth',1,'Color','k')
    legend({"Group Median Value" + newline  + "of Less Smoothed Data"},'location','northwest')
end

pic = gcf;
picname = sprintf('Summary_Slopes');
saveas(pic,fullfile(outputdir,picname),'png');

% plot for correlation coefficients
figure
boxplot(summary_r,name)
hold on
xlabel('Amplitude threshold bands')
xticklabels({'0-0.2','0.2-0.4','0.4-0.6'})
ylabel("Fisher's Z(r)")
title({'Spatial Correlation of Lag Values'})
axis square
%ylim([0 1]) values different for ZF transformed
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'k');

% plot the less smoothed median data for comparison
if smoothed_compare == 1
    plot(1:3,unsmoothed_r,'-*','linewidth',1,'Color','k')
end

pic = gcf;
picname = sprintf('Summary_r');
saveas(pic,fullfile(outputdir,picname),'png');

% plot for voxel percentages
figure
boxplot(summary_percentage*100,name_percent_union) % change this line to plot task and rest with union
hold on
xlabel('Amplitude threshold bands')
ylabel('Voxels remaining (%)')
title('GM voxels satisfying amplitude threshold band')
xticklabels({'0-0.2','0.2-0.4','0.4-0.6'})
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'k');
axis square

% plot the less smoothed median data for comparison
if smoothed_compare == 1
    plot(1:3,unsmoothed_percentage*100,'-*','linewidth',1,'Color','k')
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
