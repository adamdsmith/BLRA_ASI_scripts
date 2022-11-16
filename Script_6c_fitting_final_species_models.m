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
cfolder2=strcat(project,filesep,'final_species_models');
if not(7==exist(cfolder2,'dir'))
    mkdir(cfolder2);
end

nsp=length(species_with_models);
for i=1:nsp
    species_with_model=species_with_models{i};
    load(strcat(cfolder,filesep,species_with_model.name)); %yval
    y=species_with_model.classification;
    y(yval==0)=0;
    y(yval==1)=1;
    species_with_model.classification=y;
    [mfig, species_with_model]=fit_and_show_species_model(P4,species_with_model,[]);
    %set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 12]);
    print(strcat(cfolder2,filesep,species_with_model.name,'.tiff'),'-dtiff');
    species_with_models{i}=species_with_model;
end
save(strcat(project,filesep,'S6_output'),'species_with_models','-v7.3');

