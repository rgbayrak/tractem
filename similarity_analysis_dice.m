%% This script is for similarity analysis between tract densities
% Author: roza.g.bayrak@vanderbilt.edu

close all;
clear all;
clc;


% BLSA
exDir              = '/home-local/bayrakrg/Dropbox*VUMC*/complete_HCP_subjects';
subjectDir = fullfile(exDir, '*');  % directory names are as follows -> subject_rater
subDir = fullfile(subjectDir, '*');  % tract names are defined as published

abbList = {'ac'; 'acr'; 'aic'; 'bcc'; 'cp'; 'cgc'; 'cgh'; 'cst'; 'fx'; 'fxst'; 'fl'; 'gcc'; 'icp'; 'ifo'; 'ilf'; 'ml'; 'm'; 'mcp'; 'ol'; 'olfr'; ...
            'opt'; 'pl'; 'pct'; 'pcr'; 'pic'; 'ptr'; 'ss'; 'scc'; 'scp'; 'scr'; 'sfo'; 'slf'; 'tap'; 'tl'; 'unc'};
trackList = {'Anterior Commissure'; 'Anterior Corona Radiata'; 'Anterior Limb Internal Capsule';'Body Corpus Callosum';'Cerebral Peduncle';'Cingulum Cingulate Gyrus'; ...
            'Cingulum Hippocampal';'Corticospinal Tract';'Fornix';'Fornix Stria Terminalis';'Frontal Lobe';'Genu Corpus Callosum';'Inferior Cerebellar Peduncle'; ...
            'Inferior Fronto Occipital Fasciculus';'Inferior Longitudinal Fasciculus';'Medial Lemniscus';'Midbrain';'Middle Cerebellar Peduncle';'Occipital Lobe'; ...
            'Olfactory Radiation';'Optic Tract';'Parietal Lobe';'Pontine Crossing Tract';'Posterior Corona Radiata';'Posteriorlimb Internal Capsule'; ...
            'Posterior Thalamic Radiation';'Sagittal Stratum';'Splenium Corpus Callosum';'Superior Cerebellar Peduncle';'Superior Corona Radiata'; ...
            'Superior Fronto Occipital Fasciculus';'Superior Longitudinal Fasciculus';'Tapetum Corpus Callosum';'Temporal Lobe';'Uncinate Fasciculus'};
        
        
% % OVERLAP BASED METRICS
% Dice Coefficient --------------------------------------------------------------------------------------------------------------------

threshold = 0.05;

for l = 1:length(abbList)
    % get track folders and do analysis on them
    densityDir = dir(fullfile(subDir, [abbList{l} '_*density.nii.gz'])); % not every folder has separate density files (left & right)
    
    if length(strfind(densityDir(1).name,'_')) == 1
        d = length(densityDir);
        density = load_density(densityDir);
        [nameMe, diceMatrix] = dice(densityDir, density, threshold, d);
        save(['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_mat/' abbList{l} '_dice.mat'], 'diceMatrix', 'nameMe');           
        save(['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_mat/' abbList{l} '_nameMe'], 'nameMe');
       
%         % load the dice mat files, it is a struct
%         temp = load([abbList{l}, '_dice.mat']);
%         % plot histogram of the 
%         histogram(temp.diceMatrix)
%         title([trackList{l} ' Same Subject Histogram'])
        
        

        figure(1);   
        imagesc(diceMatrix)
        title(['Dice Similarity Cross-Correlation Matrix for ' trackList{l} ' Across Raters'], 'FontSize', 10); % set title
        colormap; % set the colorscheme
        xticks((1:d))
        nameMe = strrep(nameMe,"_"," ");
        xticklabels(nameMe);
        yticks((1:d))
        yticklabels(nameMe);
        xtickangle(45)
        colorbar;

        textStrings = num2str(diceMatrix(:), '%0.2f');       % Create strings from the matrix values
        textStrings = strtrim(cellstr(textStrings));  % Remove any space padding
        [x, y] = meshgrid(1:length(densityDir));  % Create x and y coordinates for the strings
        hStrings = text(x(:), y(:), textStrings(:), ...  % Plot the strings
                        'HorizontalAlignment', 'center');

        set(figure(1),'Position', [1 1 1680 1050]);
        name = densityDir(1).name(1:end-15);
            saveas(figure(1),['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_Dice_corrected/' 'dice_' name '.jpg']); 
        close all;
        disp([abbList{l} ' has been processed!'])

    elseif length(strfind(densityDir(1).name,'_')) == 2
        if length(strfind(densityDir(1).name,'_L')) == 1
            densityLDir = dir(fullfile(subDir, [abbList{l} '_L_density.nii.gz'])); % not every folder has separate density files (left & right)
            dl = length(densityLDir);
            densityL = load_density(densityLDir);
            [nameMe, diceL] = dice(densityLDir, densityL, threshold, dl);
            save(['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_mat/' abbList{l} '_L_dice.mat'], 'diceL', 'nameMe');           
            save(['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_mat/' abbList{l} '_L_nameMe'], 'nameMe');

            figure(2);   
            imagesc(diceL)
            title(['Dice Similarity Cross-Correlation Matrix for ' trackList{l} ' Left Across Raters'], 'FontSize', 10); % set title
            colormap; % set the colorscheme
            xticks((1:dl))
            nameMe = strrep(nameMe,"_"," ");
            xticklabels(nameMe);
            yticks((1:dl))
            yticklabels(nameMe);
            xtickangle(45)
            colorbar;

            textStrings = num2str(diceL(:), '%0.2f');       % Create strings from the matrix values
            textStrings = strtrim(cellstr(textStrings));  % Remove any space padding
            [x, y] = meshgrid(1:length(densityLDir));  % Create x and y coordinates for the strings
            hStrings = text(x(:), y(:), textStrings(:), ...  % Plot the strings
                            'HorizontalAlignment', 'center');

            set(figure(2),'Position', [1 1 1680 1050]);
            name = densityDir(1).name(1:end-15);
            saveas(figure(2),['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_Dice_corrected/' 'dice_' name '.jpg']); 
            close all;
            disp([abbList{l} '_R has been processed!'])
        end

        if length(strfind(densityDir(2).name,'_R')) == 1
            densityRDir = dir(fullfile(subDir, [abbList{l} '_R_density.nii.gz'])); % not every folder has separate density files (left & right)
            dr = length(densityRDir);
            densityR = load_density(densityRDir);
            [nameMe, diceR] = dice(densityRDir, densityR, threshold, dr);
            save(['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_mat/' abbList{l} '_R_dice.mat'], 'diceR', 'nameMe');
            save(['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_mat/' abbList{l} '_R_nameMe'], 'nameMe');
            

            figure(3);   
            imagesc(diceR)
            title(['Dice Similarity Cross-Correlation Matrix for ' trackList{l} ' Right Across Raters'], 'FontSize', 10); % set title
            colormap; % set the colorscheme
            xticks((1:dr))
            nameMe = strrep(nameMe,"_"," ");
            xticklabels(nameMe);
            yticks((1:dr))
            yticklabels(nameMe);
            xtickangle(45)
            colorbar;

            textStrings = num2str(diceR(:), '%0.2f');       % Create strings from the matrix values
            textStrings = strtrim(cellstr(textStrings));  % Remove any space padding
            [x, y] = meshgrid(1:length(densityRDir));  % Create x and y coordinates for the strings
            hStrings = text(x(:), y(:), textStrings(:), ...  % Plot the strings
                            'HorizontalAlignment', 'center');

            set(figure(3),'Position', [1 1 1680 1050]);
            name = densityDir(2).name(1:end-15);
            saveas(figure(3),['/home-local/bayrakrg/Dropbox (VUMC)/HCP/HCP_Dice_corrected/' 'dice_' name '.jpg']); 
            close all;
            disp([abbList{l} '_L has been processed!'])
        end
    end
end