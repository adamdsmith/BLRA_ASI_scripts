function [species_names letter_ids]=extract_species_names_from_letters(letters,level)

species_names={};
letter_ids={};
nl=size(letters,2);
for i=1:nl
    name=letters{i}.name;
    po=strfind(name,'_');
    if length(po)>=1
        spname{i}=name(1:po(level)-1);
    else
        spname{i}=name;
    end
end

sps=unique(spname);
nsp=size(sps,2);

for i=1:nsp
    species_names{i}=sps{i};
    focal=[];
    for j=1:nl
        if strcmp(species_names{i},spname(j));
            focal=[focal j];
        end
    end
    letter_ids{i}=focal;
end
