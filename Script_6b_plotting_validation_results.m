RC = 0;
clearvars -except RC project;
RC = RC + 1;
rng(RC);

addpath('ASIfunctions');

if exist('project','var')
    disp(['Current project directory: ',project])
else
    error('You have not defined the variable "project". Please do so and re-run this script.')
end

load(strcat(project,filesep,'S5_output')); %'species_with_models'

valthresh=[0.5,0.9]; % User sets the target thresholds, up to five threshold values.

cfolder=strcat(project,filesep,'species_model_validations');
nsp=length(species_with_models);
close all;
figure;
hold on
title('ASI performance for validation data')
coltag={'red','black','blue','green','magenta'};
for z=1:size(valthresh,2)
    AllPrecision=[];
    AllRecall=[];
%    for i=1:nsp
    for i=5 %KKD0 only
        species_with_model=species_with_models{i};
        load(strcat(cfolder,filesep,species_with_model.name)); %yval
        probabilities=species_with_model.probabilities;
        % p=probabilities(:,3);
        p=probabilities(:,1); % We use only MPCA1
        rows=find(or(yval==0,yval==1));
        p1=p(rows);
        yval1=yval(rows);
        class1=p1>valthresh(z);
        precision=sum(yval1(class1))/sum(class1);
        recall=sum(yval1(class1))/sum(yval1);
        AllPrecision=[AllPrecision; precision];
        AllRecall=[AllRecall; recall];
    end
    xlswrite(strcat(project,filesep,'species_model_validations',filesep,'Precision_ASI_Threshold_',strrep(num2str(valthresh(z)),'.',''),'.xls'),AllPrecision);
    xlswrite(strcat(project,filesep,'species_model_validations',filesep,'Recall_ASI_Threshold_',strrep(num2str(valthresh(z)),'.',''),'.xls'),AllRecall);
    eps=0.05;
    AllPrecision=AllPrecision+eps*(rand(size(AllPrecision))-0.5);
    AllRecall=AllRecall+eps*(rand(size(AllRecall))-0.5);
    scatter(AllPrecision(:,1),AllRecall(:,1),coltag{z},'filled')
end
xlabel('Precision');
ylabel('Recall');
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
plot([0.5 0.5],[-0.05 1.05],'--k')
hold off

fig=gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 3]; % set proportions for the fig
print(strcat(project,filesep,'species_model_validations',filesep,'Validation_results.tiff'),'-dtiff')

