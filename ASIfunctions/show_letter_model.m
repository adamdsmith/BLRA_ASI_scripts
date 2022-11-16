function fig = show_letter_model(letter_with_model,P1,highlight)

name=letter_with_model.name;

predictors=letter_with_model.predictors;
y=letter_with_model.classification;
beta=letter_with_model.beta;

cors=predictors(:,1);
stops=0.1:0.05:1;
estops=[-1 stops];
props=zeros(1,length(stops));
for i=1:length(stops)
    props(i)=sum(and(cors>estops(i),cors<=estops(i+1)));
end
lprops=log10(props+10^(-1));
subplot(2,1,1);
hold off;
plot(stops,lprops,'black');
ylim([-1 ceil(max(lprops))]);
yticks([-1 0 1 2 3 4 5 6]);
yticklabels([0 1 10 100 1000 10000 100000 1000000]);
titL=['Letter: ' name];
title(titL,'interpreter','none');

subplot(2,1,2);
hold off;
sel=or(y==0,y==1);
cors1=cors(sel);
yy1=y(sel);
one=yy1==1;
zer=yy1==0;
micor=0;
macor=1;
xx=micor:(macor-micor)/100:macor;
gxx=glmval(beta,xx,'probit',1);
plot(xx,gxx,'black');
hold on
scatter (cors1(one),yy1(one)+unifrnd(-0.05,0,sum(one),1),'black','filled');
scatter (cors1(zer),yy1(zer)+unifrnd(0,0.05,sum(zer),1),'r','filled');
highlightsel=intersect(highlight,find(sel));
scatter (cors(highlightsel),0.05+0.95*y(highlightsel),'g','filled');

ylim([0 1]);
xlim([0 1])
fig=gcf;
