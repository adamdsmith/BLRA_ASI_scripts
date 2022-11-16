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
nl=size(letters_with_models,2);

nsets=26; %how many cores/divisions of data to use for parallel computing

[species_names, letter_ids]=extract_species_names_from_letters(letters_with_models,1);

% you can also manually define species names and which letters they consist of
% species_names{1}='Otus_otus';
% letter_ids{1}=[1 2];

species={};
nsp=size(species_names,2);

for i=1:nsp
    species{i}.name=species_names{i};
    letters={};
    for j=1:length(letter_ids{i})
        letter_with_model=letters_with_models{letter_ids{i}(j)};
        letters{j}.name=letter_with_model.name;
        letters{j}.audiofile=letter_with_model.audiofile;
        letters{j}.box=letter_with_model.box;
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
    selection=1:nt;
    set=ceil(selection*nsets/length(selection));
    for j=1:nsets
        Tselection{j}=find(set==j);
        RES{j}={};
    end
    parfor (j=1:nsets,nsets)
        raw_species_predictors=compute_raw_species_predictors(audiofolder,files,P1,P4,letters_with_models(letter_ids{i}),Tselection{j});
        RES{j}=raw_species_predictors;
    end
    raw_species_predictors=[];
    for j=1:nsets
        raw_species_predictors=[raw_species_predictors; RES{j}];
    end
    species{i}.raw_predictors=raw_species_predictors;
    tentative_y=compute_tentative_y(letters_with_models(letter_ids{i}));
    species{i}.tentative_y=tentative_y;
    
    close all;
    imagesc(raw_species_predictors); colorbar();
    print(strcat(cfolder,filesep,'raw_predictors_',species{i}.name,'.tiff'),'-dtiff');
    
end
save(strcat(project,filesep,'S4a_output'),'species','-v7.3');
toc;
