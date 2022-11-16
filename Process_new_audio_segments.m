RC = 0;
clearvars -except RC;
RC = RC + 1;
rng(RC);

%%%%%% OBJECTS TO DEFINE UP FRONT %%%%%%
% Set the root project path
project = 'Z:\Private\asmith\BLRA_ASI';

% spp_to_process: What Black Rail vocalization types ("species") to process?
% One of: KKD0, KKD, CHURT, GRR, IKIK
spp_to_process = "KKD0"; 

% out_dir: directory name for storing generated interim and final products
out_dir = '_TEST_species_predictors';
out_path = strcat(project, filesep, out_dir)

% n_cores: how many cores to use during processing?
% may have to set up Matlab parallel pool as well
n_cores = 8;

%new_audio_dir: path to new, segmented (1-min) *.wav files
new_audio_dir = 'Z:\Private\asmith\BLRA_ASI\KKD2';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%STEP 0 OUTPUT
% Path to the input parameters we used
load('Z:\Private\asmith\BLRA_ASI\input_parameters'); %'P1','P2','P3','P4'

% STEP 3B OUTPUT
% Path to the our identified letters and their associated letter models
load('Z:\Private\asmith\BLRA_ASI\S3b_output'); %'letters_with_models'

% PRE-CALCULTED BLRA LETTER FEATURES (from `compute_raw_species_predictors`)
% Path to specs for 1932 processed letters to be used for constructing raw
% species predictors
load('Z:\Private\asmith\BLRA_ASI\processed_BLRA_letters'); %Tletterdata, Tbox, Tbeta 

addpath('ASIfunctions');

files = dir([new_audio_dir, filesep, '*.wav']);

% Pick 24 random hours in 1 min segments
keep = files;
files = files(randperm(length(files), 24 * 60));

nl = size(letters_with_models, 2);

[species_names, letter_ids] = extract_species_names_from_letters(letters_with_models, 1);

species = {};

poss_species = {'CHURT' 'GRR' 'IKIK' 'KKD' 'KKD0'};
i = find(strcmp(poss_species, spp_to_process));

species.name = species_names{i};
species.file = string({files.name})';
letters = {};
for j = 1:length(letter_ids{i})
    letter_with_model = letters_with_models{letter_ids{i}(j)};
    letters{j}.name = letter_with_model.name;
    letters{j}.audiofile = letter_with_model.audiofile;
    letters{j}.box = letter_with_model.box;
end
species.letters = letters;

if not(7 == exist(out_path, 'dir'))
    mkdir(out_dir);
end

nt = size(files, 1);

disp(['Processing ', species.name]);
selection = 1:nt;

% Assign files to multiple cores, as necessary
set = ceil(selection * n_cores / length(selection));
for j = 1:n_cores
    Tselection{j} = find(set == j);
    RES{j} = {};
end

tic;
parfor (j = 1:n_cores, n_cores)
    raw_species_predictors = ...
        compute_raw_species_predictors(new_audio_dir, files, P1, P4, ...
        letters_with_models(letter_ids{i}), ...
        Tselection{j}, Tletterdata(letter_ids{i}), ...
        Tbox(letter_ids{i}), Tbeta(letter_ids{i}));
    RES{j} = raw_species_predictors;
end
toc;

raw_species_predictors=[];
for j = 1:n_cores
    raw_species_predictors = [raw_species_predictors; RES{j}];
end
species.raw_predictors = raw_species_predictors;
% This doesn't really seem relevant to new files since we're not them to
% build species models, but we provide to satisfy the necessary functions
species.tentative_y = nan(nt, 1);
close all;
imagesc(raw_species_predictors); colorbar();
print(strcat(out_path, filesep, 'raw_predictors_', species.name, '.tiff'), '-dtiff');
save(strcat(out_path, filesep, 'S4a_output_', species.name), 'species', '-v7.3');

% STEP 4B
species_predictors = compute_species_predictors(species, P4);
species.predictors = species_predictors;
close all;
fig = show_species_predictors(species, 4);
print(strcat(out_path, filesep, 'species_predictors_', species.name, '.tiff'), '-dtiff');
save(strcat(out_path, filesep, 'S4b_output_', species.name), 'species', '-v7.3');

% STEP 6
% We have to use an existing constructed and validated model to generate 
% predicted probabilities for our new files based on the predictors 
% calculated above. 
% Path to the our constructed and validated species (BLRA vocalization) models
load('Z:\Private\asmith\BLRA_ASI\S6_output'); %'species_with_models'
prev_spp_model = species_with_models{i};
new_spp_with_preds = fit_previous_species_model(prev_spp_model, species, P4);
output = rmfield(new_spp_with_preds, {'name', 'letters', 'raw_predictors', ...
                                      'predictors', 'tentative_y'});
output.BLRA = nan(nt, 1);
output.mic_short = nan(nt, 1);
writetable(struct2table(output), strcat(out_path, filesep, species.name, '_probabilities.xlsx'));