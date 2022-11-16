function [raw_species_predictors]=compute_raw_species_predictors(audiofolder,files,P1,P4,letters_with_models,selection,Tletterdata,Tbox,Tbeta)

nth=length(P4.thresholds);
nt=length(selection);
nl=size(letters_with_models,2);

if nargin < 7
    for i=1:nl
        letter_with_model=letters_with_models{i};
        filename=letter_with_model.audiofile;
        box=letter_with_model.box;
        x1=box(1);
        x2=box(2);
        y1=box(3);
        y2=box(4);
        
        full_filename=strcat(audiofolder,filesep,filename);
        [audio,fs]=audioread(full_filename);
        data=audio_to_image(audio,fs,P1);
        Tletterdata{i}=data(y1:y2,x1:x2);
        Tbox{i}=box;
        Tbeta{i}=letter_with_model.beta;
    end
end

raw_species_predictors=zeros(nt,(nth+1)*nl+P4.n_autocorrelation);
for tt=1:nt
    t=selection(tt);
    filename=files(t).name;
    full_filename=strcat(audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    A=zeros(nl*nth,size(data,2));
    maxpr=zeros(1,nl);
    if ~isnan(max(data(:)))
        for i=1:nl
            box=Tbox{i};
            beta=Tbeta{i};
            x1=box(1);
            x2=box(2);
            y1=box(3);
            y2=box(4);
            correl=compute_correlations(data, Tletterdata{i}, [y1 y2], P1.tolerance);
            ma=max(correl);
            pr=glmval(beta,ma,'probit',1);
            for j=1:nth
                A(nth*(i-1)+j,:)=pr>P4.thresholds(j);
            end
            maxpr(i)=max(pr);
        end
    end
    prevA=mean(A');
    suA=sum(A);
    nsu=size(suA,2);
    if and(sum(suA)>0,var(suA)>0)
        acfA=autocorr(suA,nsu-1);
        acfA=acfA(2:end);
    else
        acfA=zeros(1,nsu-1);
    end
    ti=round(logspace(log10(1),log10(nsu-1),P4.n_autocorrelation+1));
    aacfA=zeros(1,P4.n_autocorrelation);
    for i=2:P4.n_autocorrelation+1
        aacfA(i-1)=mean(acfA(1:ti(i)));
    end
    raw_species_predictors(tt,:)=[maxpr prevA aacfA];
end