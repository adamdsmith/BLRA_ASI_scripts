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

if isfile(strcat(project,filesep,'S2_output.mat'))
    load(strcat(project,filesep,'S2_output'));
    fnames={files.name};
    nl=size(letters,2);
    for i = 1:nl
        letter_files(i).audiofile = letters{i}.audiofile;
    end
    [~, sortidx] = sort({letter_files.audiofile});
    letter_files = letter_files(sortidx);
    lidx=find(strcmp(fnames, letter_files(nl).audiofile));
    cc=letter_candidate_clusters(lidx); % current cluster
    cl=min(lidx+1, size(fnames,2)); % current letter within the current cluster; for now works only when there is a single cluster
else
    letters=[];
    nl=0;
    cc=1; % current cluster
    cl=1; % current letter within the current cluster;
end

% If you know approximately which letter candidate you like to start with,
% uncomment and enter it here:
%cl = 255;

make_plots=false;
new_letters=annotate_letters(project,audiofolder,P1,letter_candidates,letter_candidate_clusters,cluster_order,cc,cl,make_plots);

% consolidate with any existing annotated letters
letters=[letters new_letters];

% sort letters alphabetically by name
sort_letters = 0;
if sort_letters
    for z=1:size(letters,2);aaa{z,1}=letters{1,z}.name;end
    [aaa1, idx]=sort(aaa);
    letters=letters(idx);
end
save(strcat(project,filesep,'S2_output'),'letters');

% Run this after you've finalized your letters
fprintf('Plotting letters to files\n');
close all;
cfolder=strcat(project,filesep,'letters');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
for i=1:size(letters,2)
    [lfig, maxx]=show_letter(letters{i},P1);
    current_i=nl+i;
    print(strcat(cfolder,filesep,'Letter_',num2str(current_i),'.tiff'),'-dtiff');
end
close all;

