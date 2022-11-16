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
load(strcat(project,filesep,'S1_output'));

letters=[];

cc=1; % current cluster
cl=1; % current letter within the current cluster;
new_letters=annotate_letters(project,audiofolder,P1,letter_candidates,letter_candidate_clusters,cluster_order,cc,cl,false);

% add newly annotated letters to
letters=[letters new_letters];

fprintf('Plotting letters to files\n');
close all;
cfolder=strcat(project,filesep,'letters');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
for i=1:size(letters,2)
    [lfig, maxx]=show_letter(letters{i},P1);
    print(strcat(cfolder,filesep,'Letter_',num2str(i),'.tiff'),'-dtiff');
end
close all;

% sort letters
for z=1:size(letters,2);aaa{z,1}=letters{1,z}.name;end
[aaa1, idx]=sort(aaa);
letters=letters(idx);


save(strcat(project,filesep,'S2_output'),'letters');

