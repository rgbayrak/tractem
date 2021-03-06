clear all;
clc;

% % Loading the data from multiple directories
exDir              = '/share4/bayrakrg/tractEM/postprocessing/metric_analysis/label/mhd';
matDir = fullfile(exDir, 'human_mhd_mat/HCP/uncinate_fasciculus');  % directory names are as follows -> subject_rater
rep_dir            = '/share4/bayrakrg/tractEM/postprocessing/metric_analysis/tract/*';
rep_matDir = fullfile(rep_dir, 'human_*_mat/HCP');  % directory names are as follows -> subject_rater


% load the directories of icc coefficients and their corresponding name files
hd_mat_files = dir(fullfile([matDir, '/*seed1_temp_hdL.mat']));
hdmean_mat_files = dir(fullfile([matDir, '/*seed1_temp_hdmeanL.mat']));
modHausdd_mat_files = dir(fullfile([matDir, '/*seed1_temp_modHausddL.mat']));
hd90_mat_files = dir(fullfile([matDir, '/*seed1_temp_hd90L.mat']));
name_mat_files = dir(fullfile([matDir, '/*seed1_nameMe.mat']));

icc_mat_filesL = dir(fullfile([rep_matDir, '/unc_L_icc.mat']));

l = 1;
hd_mat = load(fullfile(hd_mat_files(l).folder, hd_mat_files(l).name));
hdmean_mat = load(fullfile(hdmean_mat_files(l).folder, hdmean_mat_files(l).name));
modHausdd_mat = load(fullfile(modHausdd_mat_files(l).folder, modHausdd_mat_files(l).name));
hd90_mat = load(fullfile(hd90_mat_files(l).folder, hd90_mat_files(l).name));
name_mat = load(fullfile(name_mat_files(l).folder, name_mat_files(l).name));
name_mat = struct2cell(name_mat);
name_mat = name_mat{1,1};

icc_matL = load(fullfile(icc_mat_filesL(l).folder, icc_mat_filesL(l).name));

% grab the subject id numbers
id = {};
name = {};
for p = 1:length(name_mat)
    parts = strsplit(name_mat(p), '_');

    if length(parts) == 1
        name{p} = 'NaN';
    elseif length(parts) == 4
        name{p} = [parts{1}  '_2']; % rater names  
        id{p} = parts{3};
    else 
        name{p} = [parts{2}]; %
        id{p} = parts{1}; % subject ids
    end
end

% create masks
uni_id = unique(id);
uni_name = unique(name);

for d = 1:length(uni_id)
    
    mask_id = strcmp(id,uni_id(d)); 
    if sum(mask_id(:)) > 1
        icc_mat_temp = struct2cell(icc_matL); 
        icc_mat_temp = icc_mat_temp{1,1};
        icc_mat_temp = icc_mat_temp(mask_id, mask_id);
        idx = triu(true(size(icc_mat_temp,1)), 1);  % since it is a matrix, we only grab the upper half      
        temp_icc_mat_intra_subject{d, 1} = icc_mat_temp(idx)';
        icc_mat_intra_subject{d, 1} = temp_icc_mat_intra_subject{d, 1}(1);
        
        hd_mat_temp = struct2cell(hd_mat); 
        hd_mat_temp = hd_mat_temp{1,1};
        hd_mat_temp = hd_mat_temp(mask_id, mask_id);
        temp_icc_mat_intra_subject{d, 2} = hd_mat_temp(idx)';
        icc_mat_intra_subject{d, 2} = temp_icc_mat_intra_subject{d, 2}(1);
        
        hdmean_mat_temp = struct2cell(hdmean_mat); 
        hdmean_mat_temp = hdmean_mat_temp{1,1};
        hdmean_mat_temp = hdmean_mat_temp(mask_id, mask_id);
        temp_icc_mat_intra_subject{d, 3} = hdmean_mat_temp(idx)';
        icc_mat_intra_subject{d, 3} = temp_icc_mat_intra_subject{d, 3}(1);
        
        modHausdd_mat_temp = struct2cell(modHausdd_mat); 
        modHausdd_mat_temp = modHausdd_mat_temp{1,1};
        modHausdd_mat_temp = modHausdd_mat_temp(mask_id, mask_id);
        temp_icc_mat_intra_subject{d, 4} = modHausdd_mat_temp(idx)';
        icc_mat_intra_subject{d, 4} = temp_icc_mat_intra_subject{d, 4}(1);
        
        hd90_mat_temp = struct2cell(hd90_mat); 
        hd90_mat_temp = hd90_mat_temp{1,1};
        hd90_mat_temp = hd90_mat_temp(mask_id, mask_id);
        temp_icc_mat_intra_subject{d, 5} = hd90_mat_temp(idx)';
        icc_mat_intra_subject{d, 5} = temp_icc_mat_intra_subject{d, 5}(1);

    end 
end

scatter([icc_mat_intra_subject{:, 4}], [icc_mat_intra_subject{:, 1}])
grid minor;
xlabel('modHausdorff distance(mm)');
ylabel('ICC');
ylim([0 1])
title('unc L seed label')


% save('/share4/bayrakrg/tractEM/postprocessing/metric_analysis/label/mhd/icc_seed1_L_mhd.mat', 'icc_mat_intra_subject')


