function MSI_Histograms(inputdir_corr,inputdir_Tmean,outputdir,subject_list)
% This code generates histograms of Mean Signal Intensity for voxels
% passing certain amplitude thresholds, looping through all subjects.
%
% inputdir_corr: The location of the input correlation amplitude files (ends in '\')
%                   e.g. 'C:\Users\s\OneDriveNU\Data\Rapidtide_run\Output_rest_bh\'
% inputdir_Tmean: The location of the input MSI files (ends in '\')
%                   e.g. 'C:\Users\s\OneDriveNU\Data\Tmean\'
% outputdir: The location of the plot to be saved (ends in '\')
%                   e.g. 'C:\Users\s\OneDriveNU\Active\MSI_histograms\'
% subject_list: Which subjects to run the analysis on 
%                   e.g. {'sub-01';'sub-02';'sub-03';'sub-04';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10'}
%
% EX. MSI_Histograms('C:\Users\s\OneDriveNU\Data\Rapidtide_run\Output_rest_bh\','C:\Users\s\OneDriveNU\Data\Tmean\','C:\Users\s\OneDriveNU\Active\MSI_histograms\',{'sub-01';'sub-02';'sub-03';'sub-04';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10'})

tic

% prepare to save plots
set(groot,'defaultFigureVisible','off') %Turns off plot display
scrsz = get(0,'ScreenSize');
set(figure,'position',scrsz);
subplot_option = 0;

for s = 1:length(subject_list)
    subject = subject_list{s};
    %% generate file names                  
    corrfitmask_rest_name = sprintf('%s%s_task-rest_bh/%s_task-rest_bh_desc-corrfit_mask.nii.gz',inputdir_corr,subject,subject);
    corr_rest_name = sprintf('%s%s_task-rest_bh/%s_task-rest_bh_desc-maxcorr_map.nii.gz',inputdir_corr,subject,subject);
 
    %% load correlation amplitude files
    corrfitmask_rest = load_untouch_nii(corrfitmask_rest_name);
    corrfitmask_rest = corrfitmask_rest.img; % this is a mask of 0&1 for voxels with a correlation amplitude value
    corr_rest_file = load_untouch_nii(corr_rest_name);
    corr_rest = corr_rest_file.img; % this is the amplitude threshold map

    %% load Mean Signal Intensity file
    Tmean_rest_bh_name = sprintf('%s%s_task-rest_bh_acq-mb4_bold_mc_brain_Tmean.nii.gz',inputdir_Tmean,subject);
    Tmean_rest_bh = load_untouch_nii(Tmean_rest_bh_name);
    Tmean_rest_bh = Tmean_rest_bh.img; 

%  Check if voxel passes amplitude threshold
    thres00 = [];    
    thres02 = [];
    thres04 = [];
    thres06 = [];
    for i = 1:size(corrfitmask_rest,1)
        for j = 1:size(corrfitmask_rest,2)
            for k = 1:size(corrfitmask_rest,3)
                if corr_rest(i,j,k) > 0 && corr_rest(i,j,k) <= 0.2 % it's important not to include 0, as they can include voxels outside the brain and introduce negative MSI values
                    thres00 = [thres00,Tmean_rest_bh(i,j,k)];
                elseif corr_rest(i,j,k) > 0.2 && corr_rest(i,j,k) <= 0.4
                    thres02 = [thres02,Tmean_rest_bh(i,j,k)];
                elseif corr_rest(i,j,k) > 0.4 && corr_rest(i,j,k) <= 0.6
                    thres04 = [thres04,Tmean_rest_bh(i,j,k)];
                elseif corr_rest(i,j,k) > 0.6
                    thres06 = [thres06,Tmean_rest_bh(i,j,k)];
                end
            end
        end
    end

% plot&save histograms of MSI
newcolors = {'#0072BD','#77AC30','#EDB120',	'#A2142F'};
colororder(newcolors)
if subplot_option == 1
    subplot(3,3,s)
    line = 2;
else
    line = 4;
end
[f,xi] = ksdensity(thres00);
plot(xi,f,'LineWidth',line)
hold on
[f,xi] = ksdensity(thres02);
plot(xi,f,'LineWidth',line)
[f,xi] = ksdensity(thres04);
plot(xi,f,'LineWidth',line)
[f,xi] = ksdensity(thres06);
plot(xi,f,'LineWidth',line)
xlabel('Mean Signal Intensity')
ylabel('pdf')
%title({'Histogram of voxel MSI'; 'for specific amplitude threhold bands'})
legend('0-0.2','0.2-0.4','0.4-0.6','>0.6')
ylim([0,3*10^(-4)])
xlim([0,3*10^4])
xticks([0:0.5*10^4:3*10^4])

if subplot_option ~= 1
    set(gca,'fontsize',44)
    pic = gcf;
    picname = sprintf('histograms_%s',subject);
    saveas(pic,fullfile(outputdir,picname),'png');
else
    set(gca,'fontsize',16)
    title(subject)
end
hold off

end

if subplot_option == 1
    pic = gcf;
    picname = sprintf('histograms_all');
    saveas(pic,fullfile(outputdir,picname),'png');
end

set(groot,'defaultFigureVisible','on')

toc
