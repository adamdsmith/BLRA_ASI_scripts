RC = 0;
clearvars -except RC project;
RC = RC + 1;
rng(RC);

%addpath('ASIfunctions');

if exist('project','var')
    disp(['Current project directory: ',project])
else
    error('You have not defined the variable "project". Please do so and re-run this script.')
end

load(strcat(project,filesep,'project_parameters')); %'audiofolder','files','P1','P2','P3','P4'
load(strcat(project,filesep,'S3b_output')); %'letters_with_models'

letters=letters_with_models;

[species_names, letter_ids]=extract_species_names_from_letters(letters_with_models,1);
nsp=size(species_names,2);

% you can also manually define species names and which letters they consist of
% species_names{raw 1}='Otus_otus';
% letter_ids{1}=[1 2];

disp(['LETTERS WITHIN SPECIES CLASSES:']);
for i=1:nsp
    disp(['SPECIES ' num2str(i) ': ' species_names{i}]);
    for j=1:length(letter_ids{i})
        lid=letter_ids{i}(j);
        disp(['   LETTER ' num2str(j) ': ' letters{lid}.name]);
    end
end

species={};
for i=1:nsp
    species{i}.name=species_names{i};
    letters={};
    for j=1:length(letter_ids{i})
        letter_with_model=letters_with_models{letter_ids{i}(j)};
        letters{j}.name=letter_with_model.name;
        letters{j}.audiofile=letter_with_model.audiofile;
        letters{j}.box=letter_with_model.box;
        letters{j}.audiofolder=letter_with_model.audiofolder;
        letters{j}.reference_audiofolder=letter_with_model.reference_audiofolder;
        letters{j}.reference_audiofile=letter_with_model.reference_audiofile;
    end
    species{i}.letters=letters;
end

cfolder=strcat(project,filesep,'species_predictors');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end

tic;
nt=size(files,1);
for i=1:nsp
    disp(['Processing species ',num2str(i),' / ',num2str(nsp),' : ',species{i}.name]);
    tic;
    selection=1:nt;
    raw_species_predictors=compute_raw_species_predictors(audiofolder,files,P1,P4,letters_with_models(letter_ids{i}),selection);
    species{i}.raw_predictors=raw_species_predictors;
    tentative_y=compute_tentative_y(letters_with_models(letter_ids{i}));
    species{i}.tentative_y=tentative_y;
    toc;
    close all;
    imagesc(raw_species_predictors); colorbar();
    print(strcat(cfolder,filesep,'raw_predictors_',species{i}.name,'.tiff'),'-dtiff');
    save(strcat(project,filesep,'S4a_output'),'species','-v7.3');
end
toc;

for i=1:nsp
    raw_species_predictors=species{i}.raw_predictors;
    close all;
    imagesc(raw_species_predictors); colorbar();
    print(strcat(cfolder,filesep,'raw_predictors_',species{i}.name,'.tiff'),'-dtiff');
end
toc;
