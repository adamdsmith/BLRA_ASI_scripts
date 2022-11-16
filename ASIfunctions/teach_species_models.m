function [new_species_with_model]=teach_species_models(audiofolder,files,P1,P4,species_with_model)

style=1; %1: automatic; 2: manual; 3: repeat 
mfig=figure;
tfig=figure;
new_species_with_model=species_with_model;
species_predictors=new_species_with_model.predictors;
selected_predictors=new_species_with_model.selected_predictors;
species_predictors=species_predictors(:,selected_predictors);
predA=species_predictors(:,1);
predB=species_predictors(:,2);
mipredA=min(predA);
mapredA=max(predA);
mipredB=min(predB);
mapredB=max(predB);
deA=mapredA-mipredA;
deB=mapredB-mipredB;

maxx=audioinfo(fullfile(audiofolder,filesep,files(1).name));
maxx=P1.fs*maxx.Duration;
contT=true;
while contT
    figure(mfig); % Figure 1: model fit
    [mfig, new_species_with_model]=fit_and_show_species_model(P4,new_species_with_model,[]);
    y=new_species_with_model.classification;
    probabilities=new_species_with_model.probabilities;
    pAB=probabilities(:,3);
    one=y==1;
    zer=y==0;
    ny=sum(one)+sum(zer);
    if style==1
        if ny<=10
            disp(['Training ' num2str(ny+1) ' out of ' num2str(11) ' data points for panel 1.']);
            targetpred=mapredA-(mapredA-mipredA)*ny/10;
            [mi, j]=min(abs(predA-targetpred)-10^5*isnan(y));
        elseif ny<=21
            disp(['Training ' num2str(ny-10) ' out of ' num2str(11) ' data points for panel 2.']);
            targetpred=mapredB-(mapredB-mipredB)*(ny-10)/10;
            [mi, j]=min(abs(predB-targetpred)-10^5*isnan(y));
        else
            disp(['Adaptive training data point ' num2str(ny-21) '.']);
              [mi, j]=min(abs(pAB-unifrnd(0,1))-10^5*isnan(y));
        end
    end
    if style==2
        box=extract_box_from_model(mfig,3,1,3,maxx);
        x1=box(1);
        x2=box(2);
        y1=box(3);
        y2=box(4);
        xx=(x1+x2)/2;
        yy=(y1+y2)/2;        
        [mi, j]=min(sqrt(((predA-xx)/deA).^2+((predB-yy)/deB).^2)-10^5*isnan(y));
        disp(['Manual data point ' num2str(ny-21) '.']);
    end
    if style==3
        if counter==1
            box=extract_box_from_model(mfig,3,1,3,maxx);
            x1=box(1);
            x2=box(2);
            y1=box(3);
            y2=box(4);
            xx=(x1+x2)/2;
            yy=(y1+y2)/2;
            tgdist=sqrt(((predA-xx)/deA).^2+((predB-yy)/deB).^2)+10^5*isnan(y);
            [~, tgdistindex]=sort(tgdist);
            disp('Review classification.');
        end
        j=tgdistindex(counter);
        counter=counter+1;
    end
    [mfig, new_species_with_model]=fit_and_show_species_model(P4,new_species_with_model,[j]);
    
    filename=files(j).name;
    cont=true;
    so=false;
    while cont
        figure(tfig); % Figure 2
        [tfig, maxx]=show_letters_audiofile(audiofolder,filename,P1,new_species_with_model,['Current classification: ' num2str(y(j))]);
        
        % Open file in Audacity; may need to modify audacity path
        filepath=audioinfo(fullfile(audiofolder,filesep,filename));
        filepath=filepath.Filename;
        % We like audacity to help here; change path accordingly
        audacitypath='"C:\Program Files (x86)\Audacity\audacity.exe"';
        audacitycmd=strcat(audacitypath, " ", filepath, " &");
        system(audacitycmd);

        commandwindow;
        res=input('[p]/[0/1/-1]/[a/m/r]/[t]/[n]/[e]: ','s');
        if so
            stop(sound_to_play);
            so=false;
        end
        if strcmp(res,'n')
          cont=false;
        end
        if strcmp(res,'a')
            style=1;
            cont=false;
        end
        if strcmp(res,'m')
            style=2;
            cont=false;
        end
        if strcmp(res,'t')
            disp(['Current audio file: ',files(j).name]);
        end
        if strcmp(res,'r')
            style=3;
            cont=false;
            counter=1;
        end
        if strcmp(res,'-1')
            y(j)=-1;
            cont=false;
        end
        if strcmp(res,'1')
            y(j)=1;
            cont=false;
        end
        if strcmp(res,'0')
            y(j)=0;
            cont=false;
        end
        if strcmp(res,'e')
            cont=false;
            contT=false;
        end
        if strcmp(res,'p')
            box=extract_box_from_image(tfig,1,1,1,P1,maxx);
            sound_to_play = extract_sound_to_play(audiofolder,P1,filename,box,true);
            play(sound_to_play);
            so = true;
        end
    end
    new_species_with_model.classification=y;
end
