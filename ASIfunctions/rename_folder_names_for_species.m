function [new_species]=rename_folder_names_for_species(species,new_audiofolder,new_reference_audiofolder)

new_species=species;
ns=size(new_species,2);
for i=1:ns
    new_species{i}.letters=rename_folder_names_for_letters(species{i}.letters,new_audiofolder,new_reference_audiofolder);
end
