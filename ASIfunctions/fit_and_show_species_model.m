function [fig, new_species_with_model]=fit_and_show_species_model(P4,species_with_model,highlight)

species_predictors=species_with_model.predictors;
y=species_with_model.classification;
selected_predictors=species_with_model.selected_predictors;

species_predictors=species_predictors(:,selected_predictors);
predA=species_predictors(:,1);
predB=species_predictors(:,2);

mipredA=min(predA);
mapredA=max(predA);
mipredB=min(predB);
mapredB=max(predB);

xxA=mipredA:(mapredA-mipredA)/20:mapredA;
xxB=mipredB:(mapredB-mipredB)/20:mapredB;
nA=length(xxA);
nB=length(xxB);
tmpA=repmat(xxA,nB,1);
tmpB=repmat(xxB,1,nA);
xxAB=[tmpA(:) tmpB(:)];

sel=or(y==0,y==1);
pred1A=predA(sel);
pred1B=predB(sel);
yy1=y(sel);
one=yy1==1;
zer=yy1==0;
prix=[0 0 1 1]';
priy=[0 1 0 1]';
priw=P4.prior_species*[1 1 1 1]';
yy2=[yy1; priy];
w2=[ones(sum(sel),1); priw];
pred2A=[pred1A; prix];
pred2B=[pred1B; prix];
warning('off');
bA=glmfit(pred2A,yy2,'binomial','link','probit','weights',w2);
bB=glmfit(pred2B,yy2,'binomial','link','probit','weights',w2);
bAB=glmfit([pred2A pred2B pred2A.*pred2B],yy2,'binomial','link','probit','weights',w2);
warning('on');

subplot(3,1,1);
hold off
gxxA=glmval(bA,xxA,'probit',1);
plot(xxA,gxxA,'black');
hold on
if sum(one)>0
scatter (pred1A(one),yy1(one)+unifrnd(-0.1,0,sum(one),1),'black','filled');
end
if sum(zer)>0
scatter (pred1A(zer),yy1(zer)+unifrnd(0,0.1,sum(zer),1),'r','filled');
end
ylim([0 1]);

pA=glmval(bA,predA,'probit',1);
R2T=mean(pA(y==1))-mean(pA(y==0));
R2A=sum(pA.*pA)/sum(pA)-sum(pA.*(1-pA))/sum(1-pA);
title(['R2T = ',num2str(R2T) '. R2A = ',num2str(R2A)]);

subplot(3,1,2);
hold off
gxxB=glmval(bB,xxB,'probit',1);
plot(xxB,gxxB,'black');
hold on
if sum(one)>0
    scatter (pred1B(one),yy1(one)+unifrnd(-0.1,0,sum(one),1),'black','filled');
end
if sum(zer)>0
    scatter (pred1B(zer),yy1(zer)+unifrnd(0,0.1,sum(zer),1),'r','filled');
end
ylim([0 1]);

pB=glmval(bB,predB,'probit',1);
R2T=mean(pB(y==1))-mean(pB(y==0));
R2A=sum(pB.*pB)/sum(pB)-sum(pB.*(1-pB))/sum(1-pB);
title(['R2T = ',num2str(R2T) '. R2A = ',num2str(R2A)]);

subplot(3,1,3);
hold off
gxxAB=glmval(bAB,[xxAB(:,1) xxAB(:,2) xxAB(:,1).*xxAB(:,2)],'probit',1);
pAB=glmval(bAB,[predA predB predA.*predB],'probit',1);
scatter(predA(:),predB(:),10,pAB); colorbar();
hold on;
scatter(predA(y==1),predB(y==1),'black','f');
scatter(predA(y==0),predB(y==0),'red','f');
scatter(predA(highlight),predB(highlight),'g','f');
xlim([min(xxA) max(xxA)]);
ylim([min(xxB) max(xxB)]);
contour(xxA,xxB,reshape(gxxAB,nA,nB),[0 0.01 0.02 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 0.98 0.99 1],'ShowText','on'); colorbar();

R2T=mean(pAB(y==1))-mean(pAB(y==0));
R2A=sum(pAB.*pAB)/sum(pAB)-sum(pAB.*(1-pAB))/sum(1-pAB);
title(['R2T = ',num2str(R2T) '. R2A = ',num2str(R2A)]);
fig=gcf;
new_species_with_model=species_with_model;
new_species_with_model.probabilities=[pA pB pAB];
