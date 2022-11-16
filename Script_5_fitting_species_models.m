RC = 0;
clearvars -except RC project;
RC = RC + 1;
rng(RC);

addpath('ASIfunctions');

if exist('project','var')
    disp(['Current project directory: ',project])
else
    error('You have not defined the variable "project". Please do so and re-run this script.')
end

load(strcat(project,filesep,'project_parameters')); %'audiofolder','files','P1','P2','P3', 'P4'
load(strcat(project,filesep,'S4b_output')); %'species'

cfolder=strcat(project,filesep,'species_models');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end

nt=size(files,1);
species_with_models={};
nsp=size(species,2);
for i=1:nsp
    species_with_models{i}=species{i};
    species_with_models{i}.classification=nan(nt,1);
    species_with_models{i}.selected_predictors=[1 2];
    species_with_models{i}.probabilities=[];
end

% if necessary, load previously trained species models by removing the comment mark (%) from the next line
% load(strcat(project,filesep,'S5_output'));

for i=1:nsp
    species_with_model=species_with_models{i};
    disp(['CURRENT SPECIES: ' species_with_model.name]);
    close all;
    species_with_model=teach_species_models(audiofolder,files,P1,P4,species_with_model);
    species_with_models{i}=species_with_model;
    save(strcat(project,filesep,'S5_output'),'species_with_models','-v7.3');
end

close all;
for i=1:nsp
    [mfig, ~]=fit_and_show_species_model(P4,species_with_models{i},[]);
    %set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 12]);
    print(strcat(cfolder,filesep,species_with_models{i}.name,'.tiff'),'-dtiff');
end

