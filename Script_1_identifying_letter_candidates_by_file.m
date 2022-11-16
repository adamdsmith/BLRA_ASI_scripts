RC = 0;
clearvars -except RC project;
RC = RC + 1;
rng(RC);

addpath('ASIfunctions')

if exist('project','var')
    disp(['Current project directory: ',project])
else
    error('You have not defined the variable "project". Please do so and re-run this script.')
end

load(strcat(project,filesep,'project_parameters')); %'audiofolder','files','P1','P2','P3','P4'
find_match_from_same_file=true;

fprintf('Finding letter candidates\n');
tic;
letter_candidates=find_letter_candidates_by_file(audiofolder,files,P1,P2,find_match_from_same_file);
toc;

fprintf('Plotting letter candidates\n');
cfolder=strcat(project,filesep,'letter_candidates');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
close all;
for i=1:size(letter_candidates,2)
    [lfig, maxx]=show_letter(letter_candidates{i},P1);
    print(strcat(cfolder,filesep,'candidate_',num2str(i),'.tiff'),'-dtiff');
end
close all;

letter_candidate_clusters=ones(size(letter_candidates,2),1);
cluster_order=[1];
letter_candidate_correlations=eye(size(letter_candidates,2));
fprintf('Saving letter candidates\n');
save(strcat(project,filesep,'S1_output'),'letter_candidates','letter_candidate_correlations','letter_candidate_clusters','cluster_order');
