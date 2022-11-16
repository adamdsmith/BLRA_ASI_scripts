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
load(strcat(project,filesep,'S5_output')); %'species_with_models'

cfolder=strcat(project,filesep,'species_model_validations');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end

for i=1:length(species_with_models)
    close all;
    disp(['VALIDATION OF THE SPECIES ' species_with_models{i}.name]);
    yval=generate_validation_data(audiofolder,files,P1,species_with_models{i},0.5,3,50); 
    save(strcat(cfolder,filesep,species_with_models{i}.name),'yval');
end
