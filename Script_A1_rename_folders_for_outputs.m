%set the beginnings of the paths to your ASI folders
folder = 'E:\BLRA_ASI\training_segments\';

%project='E:\BLRA_ASI';

new_audiofolder = folder;
new_reference_audiofolder=folder;
addpath('ASIfunctions');

load(strcat(project,filesep,'project_parameters')); %'audiofolder','files','P1','P2','P3', 'P4'
audiofolder=new_audiofolder;
nt=size(files,1);
for i = 1:nt
    files(i).folder=new_audiofolder;
end
save([project, filesep, 'project_parameters'],'audiofolder','files','P1','P2','P3','P4');

load(strcat(project,filesep,'S1_output'));
letter_candidates=rename_folder_names_for_letters(letter_candidates,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S1_output'),'letter_candidates','letter_candidate_correlations','letter_candidate_clusters','cluster_order');

load(strcat(project,filesep,'S2_output'));
letters=rename_folder_names_for_letters(letters,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S2_output'),'letters');

load(strcat(project,filesep,'S3a_output'));
letters=rename_folder_names_for_letters(letters,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S3a_output'),'letters','letter_predictors');

load(strcat(project,filesep,'S3b_output'));
letters_with_models=rename_folder_names_for_letters(letters_with_models,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S3b_output'),'letters_with_models');

load(strcat(project,filesep,'S4a_output'));
species=rename_folder_names_for_species(species,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S4a_output'),'species','-v7.3');

load(strcat(project,filesep,'S4b_output'));
species=rename_folder_names_for_species(species,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S4b_output'),'species','-v7.3');

load(strcat(project,filesep,'S5_output'));
species_with_models=rename_folder_names_for_species(species_with_models,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S5_output'),'species_with_models','-v7.3');

load(strcat(project,filesep,'S6_output'));
species_with_models=rename_folder_names_for_species(species_with_models,new_audiofolder,new_reference_audiofolder);
save(strcat(project,filesep,'S6_output'),'species_with_models','-v7.3');


