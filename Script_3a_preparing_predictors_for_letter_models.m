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

nt=size(files,1);

load(strcat(project,filesep,'S2_output')); %letters

tic;
selection=1:nt;
letter_predictors=compute_letter_predictors(audiofolder,files,P1,letters,selection);

save(strcat(project,filesep,'S3a_output'),'letters','letter_predictors');
toc;
