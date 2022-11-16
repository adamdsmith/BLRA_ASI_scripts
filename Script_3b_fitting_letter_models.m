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
load(strcat(project,filesep,'S3a_output')); %'letters', 'letter_predictors'
if isfile(strcat(project,filesep,'S2_output.mat'))
    load(strcat(project,filesep,'S2_output'));
nl=size(letters,2);
for cletter=1:nl 
    close all;
    letters_with_models=teach_letter_models(audiofolder,files,P1,P4,letters_with_models,letters,letter_predictors,cletter);
    save(strcat(project,filesep,'S3b_output'),'letters_with_models');
end

close all;
cfolder=strcat(project,filesep,'letter_models');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
for i=1:size(letters_with_models,2)
    lfig=show_letter_model(letters_with_models{i},P1,[]);
    print(strcat(cfolder,filesep,'Letter_',num2str(i),'.tiff'),'-dtiff');
end
close all;

