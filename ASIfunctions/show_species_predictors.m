function [fig]=show_species_predictors(species,n)

tentative_y=species.tentative_y;
species_predictors=species.predictors;

p1=1;
for p2=2:(n+1)
    subplot(2,ceil((n-1)/2),p2-1)
    hold off;
    scatter(species_predictors(:,p1),species_predictors(:,p2));
    hold on;
    scatter(species_predictors(tentative_y==1,p1),species_predictors(tentative_y==1,p2),'black','f');
    scatter(species_predictors(tentative_y==0,p1),species_predictors(tentative_y==0,p2),'red','f');
    xlabel(['Lmax']);
    ylabel(['Combined predictor ',num2str(p2-1)]);
end
fig=gcf;
