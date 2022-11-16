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

nsets=26; %how many cores/divisions of data to use for parallel computing

load(strcat(project,filesep,'S2_output'));

tic;
selection=1:nt;
set=ceil(selection*nsets/length(selection));
for i=1:nsets
    Tselection{i}=find(set==i);
    RES{i}={};
end
parfor (i=1:nsets,nsets)
    letter_predictors=compute_letter_predictors(audiofolder,files,P1,letters,Tselection{i});
    RES{i}=letter_predictors;
end
for i=1:size(letters,2)
    pred=[];
    for j=1:nsets
        tmp=RES{j};
        pred=[pred; tmp{i}];
    end
    letter_predictors{i}=pred;
end
save(strcat(project,filesep,'S3a_output'),'letters','letter_predictors');
toc;
