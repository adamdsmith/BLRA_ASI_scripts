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

load(strcat(project,filesep,'project_parameters')); 
load(strcat(project,filesep,'S4a_output')); 

nsp=size(species,2);

cfolder=strcat(project,filesep,'species_predictors');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end

tic;
for i=1:nsp
    species_predictors=compute_species_predictors(species{i},P4);
    species{i}.predictors=species_predictors;
    close all;
    fig=show_species_predictors(species{i},4);
    print(strcat(cfolder,filesep,species{i}.name,'.tiff'),'-dtiff');
end
save(strcat(project,filesep,'S4b_output'),'species','-v7.3');
toc;
