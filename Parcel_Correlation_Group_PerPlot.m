function  Parcel_Correlation_Group_PerPlot(inputdir,outputdir,corrthres)
% This code generates a group summary plot (of percentages of voxels 
% remaining) based on the outputs of Parcel-Correlation_Calc.m.
%
% inputdir: The location of the input files (ends in '/')
%                   e.g. 'C:\Users\s\OneDriveNU\Active\Lag_Compare_MNI\'
% outputdir: The location of the plot to be saved (ends in '/')
%                   e.g. 'C:\Users\s\OneDriveNU\Active\Summary_Plots_MNI\'
% corrthres: A list of correlation thresholds used. 
%                   e.g. [-5,0:0.1:0.7]

tic

% prepare to save plots
set(groot,'defaultFigureVisible','off') %Turns off plot display
scrsz = get(0,'ScreenSize');
set(figure,'position',scrsz);

% plot all GM median
% initialize matrix
summary_percentage_task_GM = [];
summary_percentage_rest_GM = [];
summary_percentage_union_GM = [];

% load all mat files
for i = 1:length(corrthres)
    summaryplot_name = sprintf('%.0f_summaryvalues_MNI.mat',corrthres(i)*10);
    datafile = load(fullfile(inputdir,summaryplot_name));
    datafile = datafile.summaryplot;
    summary_percentage_task_GM = [summary_percentage_task_GM,datafile(:,4)];
    summary_percentage_rest_GM = [summary_percentage_rest_GM,datafile(:,5)];
    summary_percentage_union_GM = [summary_percentage_union_GM,datafile(:,6)];
end

% take voxel percentage median across subjects
summary_percentage_task_GM = median(summary_percentage_task_GM);
summary_percentage_rest_GM = median(summary_percentage_rest_GM);
summary_percentage_union_GM = median(summary_percentage_union_GM);

summary_percentage_task_GM = reshape(summary_percentage_task_GM,[],1);
summary_percentage_rest_GM = reshape(summary_percentage_rest_GM,[],1);
summary_percentage_union_GM = reshape(summary_percentage_union_GM,[],1);

x = [1:7];
plot(x,summary_percentage_union_GM*100,'k','LineWidth',3)

% plot parcel median
for mm = 1:9 % 9 lines for 9 parcels

% initialize matrix
summary_percentage_task = [];
summary_percentage_rest = [];
summary_percentage_union = [];

% prepare for boxplot group name
name_short = char('None','0','0.1','0.2','0.3','0.4','0.5');

% load all mat files
pick_parcel_data = [mm:9:81];
for i = 1:length(corrthres)
    summaryplot_name = sprintf('%.0f_summaryvalues_MNI.mat',corrthres(i)*10);
    datafile = load(fullfile(inputdir,summaryplot_name));
    datafile = datafile.summaryplot;
    summary_percentage_task = [summary_percentage_task,datafile(pick_parcel_data,4)];
    summary_percentage_rest = [summary_percentage_rest,datafile(pick_parcel_data,5)];
    summary_percentage_union = [summary_percentage_union,datafile(pick_parcel_data,6)];
end

% take voxel percentage median across subjectss
summary_percentage_task = median(summary_percentage_task);
summary_percentage_rest = median(summary_percentage_rest);
summary_percentage_union = median(summary_percentage_union);

summary_percentage_task = reshape(summary_percentage_task,[],1);
summary_percentage_rest = reshape(summary_percentage_rest,[],1);
summary_percentage_union = reshape(summary_percentage_union,[],1);

x = [1:7];

% plot for voxel percentages
newcolors = {'red','green','blue','cyan','magenta','yellow','#A2142F','#EDB120','#D95319','#77AC30'};
colororder(newcolors)
hold on

plot(x,summary_percentage_union*100,'LineWidth',2)
xlabel('Amplitude thresholds')
ylabel('Voxels remaining (%)')
title('GM-parcel voxels satisfying amplitude threshold')
end

xticklabels({'None','0','0.1','0.2','0.3','0.4','0.5'})
set(gca,'fontsize',18)
ylim([0,100])
axis square
hold off

% save figures
pic = gcf;
picname = sprintf('Summary_percentage_median');
saveas(pic,fullfile(outputdir,picname),'png');
set(groot,'defaultFigureVisible','on')

toc
