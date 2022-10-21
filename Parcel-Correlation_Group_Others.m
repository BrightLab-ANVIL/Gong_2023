function Parcel-Correlation_Group_Others(inputdir,outputdir,corrthres)
% This code generates group summary plots (slope, r, intercepts) based on the outputs of
% Parcel-Correlation_Calc.m.
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

newcolors = {'red','green','blue','cyan','magenta','yellow','#A2142F','#EDB120','#D95319','#77AC30'};
% newcolors = ["","cyan","magenta","yellow","A2142F","#EDB120","#D95319","#77AC30"];
colororder(newcolors)

% plot all GM median
% initialize matrix
summary_slope_GM = [];
%summary_intercept_GM = [];
summary_r_GM = [];

% load all mat files
for i = 1:length(corrthres)
    summaryplot_name = sprintf('%.0f_summaryvalues_MNI.mat',corrthres(i)*10);
    datafile = load(fullfile(inputdir,summaryplot_name));
    datafile = datafile.summaryplot;
    summary_slope_GM = [summary_slope_GM,datafile(:,1)];
    %summary_intercept_GM = [summary_intercept_GM,datafile(:,2)];
    summary_r_GM = [summary_r_GM,datafile(:,3)];
end

% take voxel percentage median across subjects
summary_slope_GM = median(summary_slope_GM);
%summary_intercept_GM = median(summary_intercept_GM);
summary_r_GM = atanh(summary_r_GM); % from r to ZF
summary_r_GM = median(summary_r_GM);

summary_slope_GM = reshape(summary_slope_GM',[],1);
%summary_intercept_GM = reshape(summary_intercept_GM',[],1);
summary_r_GM = reshape(summary_r_GM',[],1);

x = [1:7];
% plot
subplot(1,2,2)
plot(x,summary_slope_GM,'k','LineWidth',3)
hold on

subplot(1,2,1)
plot(x,summary_r_GM,'k','LineWidth',3)
hold on

% plot parcel median
hold on
for mm = 1:9 % 9 lines for 9 parcels

% initialize matrix
summary_slope = [];
%summary_intercept = [];
summary_r = [];

% load all mat files
pick_parcel_data = [mm:9:81];
for i = 1:length(corrthres)
    summaryplot_name = sprintf('%.0f_summaryvalues_MNI.mat',corrthres(i)*10);
    datafile = load(fullfile(inputdir,summaryplot_name));
    datafile = datafile.summaryplot;
    summary_slope = [summary_slope,datafile(pick_parcel_data,1)];
    %summary_intercept = [summary_intercept,datafile(pick_parcel_data,2)];
    summary_r = [summary_r,datafile(pick_parcel_data,3)];
end

% take median across subjectss
summary_slope = median(summary_slope);
%summary_intercept = median(summary_intercept);
summary_r = atanh(summary_r); % from r to ZF
summary_r = median(summary_r);

summary_slope = reshape(summary_slope',[],1);
%summary_intercept = reshape(summary_intercept',[],1);
summary_r = reshape(summary_r',[],1);
summary_r = atanh(summary_r); % from r to ZF

x = [1:7];

% plot
subplot(1,2,2)
plot(x,summary_slope,'LineWidth',2)
xlabel('Amplitude thresholds')
ylabel({'Slope'})
title({'Slope of Agreement between Lag Values'})
axis square

subplot(1,2,1)
plot(x,summary_r,'LineWidth',2)
xlabel('Amplitude thresholds')
ylabel("Fisher's Z(r)")
title('Spatial Correlation of Lag Values')
axis square
end

% add figure labels
subplot(1,2,1)
set(gca,'fontsize',15)
xticklabels({'None','0','0.1','0.2','0.3','0.4','0.5'})
subplot(1,2,2)
set(gca,'fontsize',15)
xticklabels({'None','0','0.1','0.2','0.3','0.4','0.5'})

hold off

% save figures
pic = gcf;
picname = sprintf('Summary_median_others');
saveas(pic,fullfile(outputdir,picname),'png');

toc
