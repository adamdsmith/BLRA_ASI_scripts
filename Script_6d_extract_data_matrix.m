RC = 0;
clearvars -except RC project;
RC = RC + 1;
rng(RC);

if exist('project','var')
 disp(['Current project directory: ',project])
else
 error('You have not defined the variable "project". Please do so and re-run this script.')    
end

utilize_manual_classifications = true;
%set to false if you don't want to replace probabilities with actual
%classifications

load(strcat(project,'\project_parameters')); %'audiofolder','files','P1','P2','P3', 'P4'
load(strcat(project,'\S6_output')); %'species with models'
ns=size(species_with_models,2);

Y=[];
fid=fopen(strcat(project,'\Y.csv'),'w');
for fsp=1:ns
    species=species_with_models{fsp};
    fprintf(fid,'%s',species.name);
    if fsp<ns
        fprintf(fid,'%s',',');
    end
    pr=species.probabilities;
    pr=pr(:,3);
    cl=species.classification;
    y=pr;
    if utilize_manual_classifications 
        y(cl==1)=1;
        y(cl==0)=0;
    end
    Y=[Y y];
end
fprintf(fid,'\n');
ny=size(Y,1);
for i=1:ny
    for fsp=1:ns
        fprintf(fid,'%3.2f',Y(i,fsp));
            if fsp<ns
        fprintf(fid,'%s',',');
    end
    end
    fprintf(fid,'\n');
end
fclose(fid);
