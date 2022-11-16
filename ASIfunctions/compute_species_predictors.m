function [species_predictors]=compute_species_predictors(species,P4)

species_predictors=species.raw_predictors;
np=size(species_predictors,2);
tentative_y=species.tentative_y;
nl=size(species.letters,2);
nth=length(P4.thresholds);
for j=1:(nl*(nth+1))
    species_predictors(:,j)=norminv(0.98*species_predictors(:,j)+0.01);
end
if nl==1
    Lmax=species_predictors(:,1);
else
    Lmax=max(species_predictors(:,1:nl)')';
end
for j=1:np
    pol = polyfit(Lmax,species_predictors(:,j),1);
    species_predictors(:,j)=species_predictors(:,j)-polyval(pol,Lmax);
end

for j=1:np
    species_predictors(:,j)=species_predictors(:,j)-mean(species_predictors(:,j));
    va=var(species_predictors(:,j));
    if va>0
        species_predictors(:,j)= species_predictors(:,j)/sqrt(va);
    end
end
[~,species_predictors]=pca(species_predictors);

for repl=1:2
    %make mean zero for PCAi (i=1,...) as a function of Lmax
    for j=1:size(species_predictors,2)
        pol = polyfit(Lmax,species_predictors(:,j),10);
        species_predictors(:,j)=species_predictors(:,j)-polyval(pol,Lmax);
    end
    
    %shrink outliers
    for j=1:size(species_predictors,2)
        me=mean(species_predictors(:,j));
        sd=sqrt(var(species_predictors(:,j)));
        di=(species_predictors(:,j)-me)/sd;
        for i=1:size(species_predictors,1)
            if abs(di(i))>1
                species_predictors(i,j)=me+(abs(di(i)).^(0.5)).*sign(di(i))*sd;
            end
        end
        sd=sqrt(var(species_predictors(:,j)));
        species_predictors(:,j)=species_predictors(:,j)/sd;
    end
end

for j=1:size(species_predictors,2)
    if mean(species_predictors(tentative_y==1,j))<mean(species_predictors(tentative_y==0,j))
        species_predictors(:,j)=-species_predictors(:,j);
    end
end

species_predictors=[Lmax species_predictors];
