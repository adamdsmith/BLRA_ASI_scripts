
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
	nl=size(letters,2);
else
    error('Cannot find S2_output. Have you used Script 2 to create letters yet?')
end

% Pick the letter you want to revise
name = 'KKD_KKD_381.'; 
% name = 126;

new_letters=revise_letter(project,audiofolder,P1,letters,name);
if size(new_letters,2) > 0
    fprintf('Plotting revised letter to file\n');
else
    fprintf('No new letters created\n');
end
close all;
cfolder=strcat(project,filesep,'letters');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
for i=1:size(new_letters,2)
    [lfig, maxx]=show_letter(new_letters{i},P1);
    current_i=nl+i;
    print(strcat(cfolder,filesep,'Letter_',num2str(current_i),'.tiff'),'-dtiff');
end
close all;

% consolidate with any existing annotated letters
letters=[letters new_letters];

% sort letters?
sort_letters = 0;
if sort_letters
    for z=1:size(letters,2);aaa{z,1}=letters{1,z}.name;end
    [aaa1, idx]=sort(aaa);
    letters=letters(idx);
end

save(strcat(project,filesep,'S2_output'),'letters');

