function [letter_predictors]=compute_letter_predictors(audiofolder,files,P1,letters,selection)

nl=size(letters,2);
nt=length(selection);

for i=1:nl
    filename=letters{i}.audiofile;
    box=letters{i}.box;
    x1=box(1);
    x2=box(2);
    y1=box(3);
    y2=box(4);
    
    full_filename=strcat(audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    Tletterdata{i}=data(y1:y2,x1:x2);
    Tbox{i}=box;
end

Tbest=zeros(nt,nl);
Tx1=zeros(nt,nl);
Tx2=zeros(nt,nl);
Tshift=zeros(nt,nl);

for tt=1:nt
    t=selection(tt);
    filename=files(t).name;
    full_filename=strcat(audiofolder,filesep,filename);
    
    
    try
    aifo=audioinfo(full_filename);
    catch
    warning('Problem using audioinfo. Skipping file and assigning a value of NaN for predictor.');
    aifo.TotalSamples=0;
    end

    if (aifo.TotalSamples==0 || isempty(aifo.TotalSamples))
        mustskip=1;
    else
        mustskip=0;
        [audio,fs]=audioread(full_filename);
        try
        data=audio_to_image(audio,fs,P1);
        catch
        warning('Problem using audio_to_image. Skipping file and assigning a value of NaN for predictor.');
        mustskip=1;
        end
    end
    
    if ~isnan(max(data(:)))
        for i=1:nl
            if mustskip==0
                x1=Tbox{i}(1);
                x2=Tbox{i}(2);
                dx=x2-x1+1;
                y1=Tbox{i}(3);
                y2=Tbox{i}(4);
                try
                correl=compute_correlations(data, Tletterdata{i}, [y1 y2], P1.tolerance);
                catch
                Tbest(tt,i)=NaN;
                Tshift(tt,i)=NaN;
                Tx1(tt,i)=NaN;
                Tx2(tt,i)=NaN;
                continue
                end
                [ma, poy]=max(correl);
                [ma, pox]=max(ma);
                
                Tbest(tt,i)=ma;
                shift=poy(pox)-P1.tolerance-1;
                Tshift(tt,i)=shift;
                Tx1(tt,i)=max(1,pox-round(dx/2));
                Tx2(tt,i)=min(Tx1(tt,i)+dx-1,size(data,2));
            else
                Tbest(tt,i)=NaN;
                Tshift(tt,i)=NaN;
                Tx1(tt,i)=NaN;
                Tx2(tt,i)=NaN;
            end
        end
    end
end
for i=1:nl
    letter_predictors{i}=[Tbest(:,i) Tx1(:,i) Tx2(:,i) Tshift(:,i)];
end
