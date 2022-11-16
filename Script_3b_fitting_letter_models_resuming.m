RC = 0;
clearvars -except RC project;
RC = RC + 1;
rng(RC);

%addpath('ASIfunctions');

% Do you want to create image files of models at the end of this session?
create_plots=false;

if exist('project','var')
    disp(['Current project directory: ',project])
else
    error('You have not defined the variable "project". Please do so and re-run this script.')
end

load(strcat(project,filesep,'project_parameters')); %'audiofolder','files','P1','P2','P3','P4'
load(strcat(project,filesep,'S3a_output')); %'letters', 'letter_predictors'
nl=size(letters,2);

if isfile(strcat(project,filesep,'S3b_output.mat'))
    load(strcat(project,filesep,'S3b_output')); %'letters_with_models'
end

% Enter either the number or name of the letter you wish to start with here:
%cl = 255; % If a letter number (between 1 and nl)
cl = "KKD_KD_16"; % If a letter name

if isnumeric(cl)
    cl = cl;
else
    for i = 1:nl
        letter_names(i).name = letters{i}.name;
    end
    all_names = {letter_names.name};
    cl = find(ismember(all_names, cl));
    if size(cl, 2) > 1
        warning('Multiple matches; tread carefully!');
        warning(strcat('Associated entries in LETTERS: (', num2str(cl), ')'));
    end
end

for cletter=cl:nl 
    close all;
    letters_with_models=teach_letter_models(audiofolder,files,P1,P4,letters_with_models,letters,letter_predictors,cletter);
    save(strcat(project,filesep,'S3b_output'),'letters_with_models');
    commandwindow;
    cont=input(['Continue to next letter? [y]/[n]: '],'s');
    if strcmp(cont,'n')
        break
    end
end

if create_plots
    close all;
    cfolder=strcat(project,filesep,'letter_models');
    if not(7==exist(cfolder,'dir'))
        mkdir(cfolder);
    end
    for i=1:size(letters_with_models,2)
        lfig=show_letter_model(letters_with_models{i},P1,[]);
        print(strcat(cfolder,filesep,'Letter_',num2str(i),'.tiff'),'-dtiff');
    end
end
    
close all;
