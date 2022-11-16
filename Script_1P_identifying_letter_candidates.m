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
nl=10000; %number of letter candidates to find
from_templates=false;
find_match_from_same_file=true;
make_clustering=true;
nsets=24; %how many cores/divisions of data to use for parallel computing

fprintf('Finding letter candidates\n');
tic;
if from_templates
    %set the beginning of the path to your ASI folder
    template_project='....\ASI\project\templates';
    load(strcat(template_project,filesep,'S2_output'));
    templates=letters;
    %set the beginning of the path to your ASI folder
    template_audiofolder='...\ASI\audiofiles\templates';    
    for i=1:nl
        RES{i}={};
    end
    parfor (i=1:nl,nsets)
        letter_candidates=find_letter_candidates_from_templates(audiofolder,files,P1,P2,1,template_audiofolder,templates);
        RES{i}=letter_candidates;
    end
    for i=1:nl
        letter_candidates{i}=RES{i}{1};
    end
    for i=1:nl
        name=letter_candidates{i}.name;
        letter_candidates{i}.name=[name(1:17) num2str(i,'%04.f') name(22:end)];
    end
else
    for i=1:nl
        RES{i}={};
    end
    parfor (i=1:nl,nsets)
        letter_candidates=find_letter_candidates(audiofolder,files,P1,P2,1,find_match_from_same_file);
        RES{i}=letter_candidates;
    end
    letter_candidates={};
    for i=1:nl
        letter_candidates{i}=RES{i}{1};
    end
end
for i=1:nl
    letter_candidates{i}.name=['letter_candidate_' num2str(i,'%04.f')];
end
toc;

fprintf('Plotting letter candidates\n');
cfolder=strcat(project,filesep,'letter_candidates');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
close all;
for i=1:nl
    [lfig, maxx]=show_letter(letter_candidates{i},P1);
    print(strcat(cfolder,filesep,'candidate_',num2str(i),'.tiff'),'-dtiff');
end
close all;

fprintf('Refining letter candidates\n');
tic;
for i=1:nl
    RES{i}={};
end
parfor (i=1:nl,nsets)
    RES{i}=refine_letter_candidates(audiofolder,letter_candidates(i),P1,P2,P3);
end
letter_candidates={};
for i=1:nl
    letter_candidates{i}=RES{i}{1};
end
toc;

fprintf('Plotting refined_letter candidates\n');
cfolder=strcat(project,filesep,'refined_letter_candidates');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
close all;
for i=1:size(letter_candidates,2)
    [lfig, maxx]=show_letter(letter_candidates{i},P1);
    print(strcat(cfolder,filesep,'candidate_',num2str(i),'.tiff'),'-dtiff');
end
close all;

fprintf('Clustering letter candidates\n');
tic;
if make_clustering
    selection=1:nl;
    set=ceil(selection*nsets/length(selection));
    for i=1:nsets
        Tselection{i}=find(set==i);
        RES{i}={};
    end
    parfor (i=1:nsets,nsets)
        RES{i}=compute_letter_correlations(audiofolder,P1,letter_candidates,Tselection{i});
    end
    letter_candidate_correlations=[];
    for i=1:nsets
        letter_candidate_correlations=[letter_candidate_correlations; RES{i}];
    end
    [letter_candidate_clusters,cluster_order]=cluster_letter_candidates(letter_candidate_correlations,round(nl/2));
else
    letter_candidate_clusters=ones(nl,1);
    cluster_order=[1];
    letter_candidate_correlations=eye(nl);
end
toc;

fprintf('Plotting clustered letter candidates\n');
close all;
cfolder=strcat(project,filesep,'letter_candidates_in_clusters');
if not(7==exist(cfolder,'dir'))
    mkdir(cfolder);
end
ncl=length(cluster_order);
for cl=1:ncl
    cfig=figure;
    lfig=figure;
    clx=cluster_order(cl);
    selected_letter_candidates=letter_candidates(find(letter_candidate_clusters==clx));
    figure(cfig);
    cfig=show_letters(selected_letter_candidates,P1,9);
    print(strcat(cfolder,filesep,'cluster_',num2str(cl),'.tiff'),'-dtiff');
    cfolder2=strcat(cfolder,filesep,'cluster_',num2str(cl));
    if not(7==exist(cfolder2,'dir'))
        mkdir(cfolder2);
    end
    for i=1:size(selected_letter_candidates,1)
        figure(lfig);
        [lfig, maxx]=show_letter(selected_letter_candidates{i},P1);
        print(strcat(cfolder2,filesep,'candidate_',num2str(i),'.tiff'),'-dtiff');
    end
    close all;
end

fprintf('Saving letter candidates\n');
save(strcat(project,filesep,'S1_output'),'letter_candidates','letter_candidate_correlations','letter_candidate_clusters','cluster_order');

