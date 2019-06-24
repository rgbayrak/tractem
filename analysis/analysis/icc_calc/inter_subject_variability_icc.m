%% This script is for intra subject and intra rater reproducibility analysis for BLSA tractem data
% Author: roza.g.bayrak@vanderbilt.edu

close all;
clear all;
clc;
addpath('/home-nfs/masi-shared-home/home/local/VANDERBILT/bayrakrg/masimatlab/trunk/users/bayrakrg:')
% % Loading the data from multiple directories
exDir              = '/share4/bayrakrg/tractEM/postprocessing/metric_analysis/icc/';
matDir = fullfile(exDir, 'human_icc_mat/BLSA');  % directory names are as follows -> subject_rater

% load the directories of icc coefficients and their corresponding name files
icc_mat_files = dir(fullfile([matDir, '/*icc.mat']));
name_mat_files = dir(fullfile([matDir, '/*nameMe.mat']));

% abbreviation list
abbList = {'ac'; 'acr'; 'aic'; 'bcc'; 'cp'; 'cgc'; 'cgh'; 'cst'; 'fx'; 'fxst'; 'fl'; 'gcc'; 'icp'; 'ifo'; 'ilf'; 'ml'; 'm'; 'mcp'; 'ol'; 'olfr'; ...
            'opt'; 'pl'; 'pct'; 'pcr'; 'pic'; 'ptr'; 'ss'; 'scc'; 'scp'; 'scr'; 'sfo'; 'slf'; 'tap'; 'tl'; 'unc'};

% initializations
icc_intra_subject = [];
icc_intra_rater = [];
dir_per_tract = [];
name_per_tract = [];

%%%
% This part of the script does the following: 
%       i - loads the icc and name files
%       ii - separates subject id#s and rater names
%       iii - grabs the relevant icc from the icc matrix using masks for:
%       1. intra-subject & 2. intra-rater(intra-subject)
%
% Some abbreviations: 
%   	dis = icc_intra_subject
%
%%%
all_icc = struct;
count = 1;
var = [];
for l = 1:length(icc_mat_files)
    
    % starts from ac goes through the list of tracts
    icc_mat = load(fullfile(icc_mat_files(l).folder, icc_mat_files(l).name));
    name_mat = load(fullfile(name_mat_files(l).folder, name_mat_files(l).name));
    name_mat = struct2cell(name_mat);
    name_mat = name_mat{1,1};
    
    % grab the subject id numbers
    id = {};
    name = {};
    for p = 1:length(name_mat)
        parts = strsplit(name_mat(p), '_');
        id{p} = parts{1}; % subject ids
        if length(parts) == 1
            name{p} = 'NaN';
        else
            name{p} = parts{2}; % rater names  
        end
    end

    
    
    % create masks
    uni_id = unique(id);
    uni_name = unique(name);
    
    % I. INTRA_SUBJECT
    % grab corresponding icc coeff.
%     for m = 1:length(uni_name)
        for d = 1:length(uni_id)
            disp(['For: ' char(uni_id(d)) '_intra-subject_' icc_mat_files(l).name(1:end-4) ' is: '])
            % picks the same subject icc coeff. and masks the rest
            mask_id = strcmp(id,uni_id(d)); 
            
            if sum(mask_id(:)) > 1
                icc_mat_temp = struct2cell(icc_mat); 
                icc_mat_temp = icc_mat_temp{1,1};
                icc_mat_temp = icc_mat_temp(mask_id, mask_id);
                idx = triu(true(size(icc_mat_temp,1)), 1);  % since it is a matrix, we only grab the upper half      
                icc_mat_intra_subject = icc_mat_temp(idx)';
                disp(icc_mat_intra_subject)
                icc_intra_subject{d} = icc_mat_intra_subject; % saving intra-subject icc coefficients into 1xn cell 

                % Save intra-subject results into a giant struct
                 % at this point I know which tract, subject, rater, what icc 
                if sum(mask_id(:)) > 2
                    tri = 1;
                    for x = 1:sum(mask_id(:))
                        for y = x:sum(mask_id(:))
                            if x ~= y
                                temp_name = name(mask_id);
                                all_icc(count).subject = char(uni_id(d));
                                all_icc(count).rater1 = char(temp_name(x));
                                all_icc(count).rater2 = char(temp_name(y));
                                all_icc(count).tract = icc_mat_files(l).name(1:end-8);
                                if length(strfind(icc_mat_files(l).name,'_')) == 2
                                    all_icc(count).tractOne = icc_mat_files(l).name(1:end-10);
                                else
                                    all_icc(count).tractOne = icc_mat_files(l).name(1:end-8);
                                end
                                all_icc(count).icc = icc_mat_intra_subject(tri);
                                count = count + 1;
                                tri = tri + 1;
                            end
                        end
                    end
                else 
                    temp_name = name(mask_id);
                    all_icc(count).subject = char(uni_id(d));
                    all_icc(count).rater1 = char(temp_name(1));
                    all_icc(count).rater2 = char(temp_name(2));
                    all_icc(count).tract = icc_mat_files(l).name(1:end-8);
                    if length(strfind(icc_mat_files(l).name,'_')) == 2
                        all_icc(count).tractOne = icc_mat_files(l).name(1:end-10);
                    else
                        all_icc(count).tractOne = icc_mat_files(l).name(1:end-8);
                    end
                    all_icc(count).icc = icc_mat_intra_subject;
                    count = count + 1;
                end
            end
        end
       
    dis{l} = icc_intra_subject; % saving 1xn intra-subject icc coefficients into 1x61 cell (for all tracts)
    disp(fullfile(icc_mat_files(l).name(1:end-4)))
    
    %inter-subject variability
    if length(strfind(icc_mat_files(l).name(1:end-8), '_L') == 1)
        sum_tract = (sum(icc_mat.iccL)-1)/length(id); % -1 for the comparison to itself
    sum_tract = sum_tract';
    if size(var,1) > size(sum_tract,1)
        sum_tract = [sum_tract; zeros(size(var,1) - size(sum_tract,1), 1)];
    else
        var= [var; zeros(size(sum_tract,1) - size(var,1), size(var,2))];
    end
    var = [var sum_tract];
    
    elseif length(strfind(icc_mat_files(l).name(1:end-8), '_R') == 1)
        sum_tract = (sum(icc_mat.iccR)-1)/length(id);
    sum_tract = sum_tract';

    if size(var,1) > size(sum_tract,1)
        sum_tract = [sum_tract; zeros(size(var,1) - size(sum_tract,1), 1)];
    else
        var= [var; zeros(size(sum_tract,1) - size(var,1), size(var,2))];
    end
    var = [var sum_tract];
    else
        sum_tract = (sum(icc_mat.iccMatrix)-1)/length(id);
    sum_tract = sum_tract';

    if size(var,1) > size(sum_tract,1)
        sum_tract = [sum_tract; zeros(size(var,1) - size(sum_tract,1), 1)];
    else
        var= [var; zeros(size(sum_tract,1) - size(var,1), size(var,2))];
    end
    var = [var sum_tract];
    end
end


% dis_mat = [];
% for i = 1:length(dis)
%     data = cell2mat(dis{1,i})';
%     if size(dis_mat,1) > size(data,1)
%         data = [data; zeros(size(dis_mat,1) - size(data,1), 1)];
%     else
%         dis_mat= [dis_mat; zeros(size(data,1) - size(dis_mat,1), size(dis_mat,2))];
%     end
%     dis_mat = [dis_mat data];
% end
boxplot(var, 'Widths',0.7)
grid minor;

tractList61 = {'Anterior Commissure'; 'Anterior Corona Radiata Left';'Anterior Corona Radiata Right'; 'Anterior Limb Internal Capsule Left';'Anterior Limb Internal Capsule Right';'Body Corpus Callosum';...
            'Cingulum Cingulate Gyrus Left';'Cingulum Cingulate Gyrus Right'; 'Cingulum Hippocampal Left'; ...
            'Cingulum Hippocampal Right';'Cerebral Peduncle Left';'Cerebral Peduncle Right';...
            'Corticospinal Tract Left';'Corticospinal Tract Right';'Frontal Lobe Left';'Frontal Lobe Right';'Fornix Left';'Fornix Right';'Fornix Stria Terminalis Left';'Fornix Stria Terminalis Right';...
            'Genu Corpus Callosum';'Inferior Cerebellar Peduncle Left';'Inferior Cerebellar Peduncle Right'; ...
            'Inferior Fronto Occipital Fasciculus Left';'Inferior Fronto Occipital Fasciculus Right';'Inferior Longitudinal Fasciculus Left';'Inferior Longitudinal Fasciculus Right';...
            'Midbrain';'Middle Cerebellar Peduncle';'Medial Lemniscus Left';'Medial Lemniscus Right';'Occipital Lobe Left';'Occipital Lobe Right'; ...
            'Olfactory Radiation Left';'Olfactory Radiation Right';'Optic Tract';...
            'Posterior Corona Radiata Left';'Posterior Corona Radiata Right';'Pontine Crossing Tract';...
            'Posterior Limb Internal Capsule Left';'Posterior Limb Internal Capsule Right';'Parietal Lobe Left';'Parietal Lobe Right';...
            'Posterior Thalamic Radiation Left';'Posterior Thalamic Radiation Right';'Splenium Corpus Callosum';...
            'Superior Cerebellar Peduncle Left';'Superior Cerebellar Peduncle Right';'Superior Corona Radiata Left';'Superior Corona Radiata Right'; ...
            'Superior Fronto Occipital Fasciculus Left';'Superior Fronto Occipital Fasciculus Right';'Superior Longitudinal Fasciculus Left';'Superior Longitudinal Fasciculus Right';...
             'Sagittal Stratum Left';'Sagittal Stratum Right';'Tapetum Corpus Callosum';'Temporal Lobe Left';'Temporal Lobe Right';'Uncinate Fasciculus Left';'Uncinate Fasciculus Right'};
      

red  = [135 22 34]./255;
blue = [0 155 198]./255;

a = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(a,'tag');   % List the names of all the objects 
idx=strcmpi(t,'box');  % Find Box objects
boxes=a(idx);          % Get the children you need
set(boxes,'linewidth',1.5); % Set width
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',12)
set(findobj(gcf,'tag','Median'), 'linewidth',1.5, 'Color', blue);
set(findobj(gcf,'tag','Box'), 'Color', red);   
p = findobj(gcf,'tag','Outliers');
for iG = 1:length(p)
    p(iG).MarkerEdgeColor = red;
end
ylim([-.04 1.04])
% set(g,'Position', [1 1 1680 1050]);
title('Inter-Subject Variability for BLSA', 'FontSize', 16, 'FontWeight', 'Normal')
ylabel('Intraclass Correlation','FontSize', 16)
xticks(1:1:61)
xticklabels(tractList61);
xtickangle(45);
grid minor; 
     
         
% all_icc.date = num2str(datetime('today'));
%save('BLSA_Nov.mat', 'all_icc')


