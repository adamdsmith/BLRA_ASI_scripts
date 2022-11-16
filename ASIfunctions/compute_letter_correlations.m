function [letter_correlations]=compute_letter_correlations(audiofolder,P1,letters,selection)

nsel=length(selection);
nl=size(letters,2);
letter_correlations=zeros(nsel,nl);

for ii=1:nsel
    i=selection(ii);
    filename=letters{i}.audiofile;
    box=letters{i}.box;
    x1=box(1);
    x2=box(2);
    y1=box(3);
    y2=box(4);
    
    full_filename=strcat(audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    letterdata=data(y1:y2,x1:x2);
    if not(isnan(sum(letterdata(:))))
        
        for j=1:nl
            filename=letters{j}.audiofile;
            boxj=letters{j}.box;
            x1j=boxj(1);
            x2j=boxj(2);
            y1j=boxj(3);
            y2j=boxj(4);
            may1=max(y1,y1j);
            shared=intersect(y1:y2,max(1,y1j-P1.tolerance):min(P1.high,y2j+P1.tolerance));
            overlap=length(shared)/(y2-y1+1);
            if overlap>0
                full_filename=strcat(audiofolder,filesep,filename);
                [audio,fs]=audioread(full_filename);
                data=audio_to_image(audio,fs,P1);
                dx=x2-x1+1;
                test=data(:,max(1,x1j-dx):min(x2j+dx,size(data,2)));
                if not(isnan(sum(test(:))))
                    correl=compute_correlations(test, letterdata, [y1 y2], P1.tolerance);
                    letter_correlations(ii,j)=max(max(correl))*overlap;
                end
            end
        end
    end
end

