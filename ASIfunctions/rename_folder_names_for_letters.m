function [new_letters]=rename_folder_names_for_letters(letters,new_audiofolder,new_reference_audiofolder)

new_letters=letters;
nl=size(new_letters,2);
for i=1:nl
    if ~strcmp('',new_audiofolder)
        new_letters{i}.audiofolder=new_audiofolder;
    end
    if ~strcmp('',new_reference_audiofolder)
        new_letters{i}.reference_audiofolder=new_reference_audiofolder;
    end
end
