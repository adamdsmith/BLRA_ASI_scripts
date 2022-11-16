function [yval]=generate_validation_data(audiofolder,files,P1,species_with_model,threshold,col,n)

tfig=figure;

y=species_with_model.classification;
probabilities=species_with_model.probabilities;
p=probabilities(:,col);
yval=nan(size(species_with_model.classification,1),1);
candidateOnes=find(and(isnan(y),p>threshold));
candidateZeros=find(and(isnan(y),p<threshold));
candidateOnes=randsample(candidateOnes,min(n,length(candidateOnes)));
candidateZeros=randsample(candidateZeros,min(n,length(candidateZeros)));
validationFiles=[candidateOnes; candidateZeros];
n1=length(validationFiles);
validationFiles=randsample(validationFiles,n1);
for j=1:n1
    vj=validationFiles(j);
    filename=files(vj).name;
    cont=true;
    so=false;
	
	% Open file in Audacity; may need to modify audacity path
    filepath=audioinfo(fullfile(audiofolder,filesep,filename));
    filepath=filepath.Filename;
    %audacitypath='"C:\Program Files (x86)\Audacity\audacity.exe"';
    audacitypath='"C:\Users\adsmith\My_Programs\Audacity\audacity.exe"';
    audacitycmd=strcat(audacitypath, " ", filepath, " &");
    system(audacitycmd);
	
    while cont
        figure(tfig);
        [tfig, maxx]=show_audiofile(audiofolder,filename,P1,['file number ' num2str(j)]);
        commandwindow;
        res=input('[p]/[0/1/-1]/[x]: ','s');
        if so
            stop(sound_to_play);
            so=false;
        end
        if strcmp(res,'-1')
            yval(vj)=-1;
            cont=false;
        end
        if strcmp(res,'1')
            yval(vj)=1;
            cont=false;
        end
        if strcmp(res,'0')
            yval(vj)=0;
            cont=false;
        end
        if strcmp(res,'x')
            cont=false;
        end
        if strcmp(res,'p')
            box=extract_box_from_image(tfig,1,1,1,P1,maxx);
            sound_to_play = extract_sound_to_play(audiofolder,P1,filename,box,true);
            play(sound_to_play);
            so = true;
        end
    end
    if strcmp(res,'x')
        break;
    end
end
