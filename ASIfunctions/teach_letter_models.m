function [letters_with_models]=teach_letter_models(audiofolder,files,P1,P4,letters_with_models,letters,letter_predictors,cletter)

style=1; %1: automatic; 2: manual; 3: repeat 
fig1=figure;
fig2=figure;
nlm=size(letters_with_models,2);
nt=size(files,1);
old=0;
for i=1:nlm
    if strcmp(letters{cletter}.name,letters_with_models{i}.name)
        old=i;
    end
end
if old==0
    current=nlm+1;
    letters_with_models{current}.name=letters{cletter}.name;
    letters_with_models{current}.audiofile=letters{cletter}.audiofile;
    letters_with_models{current}.audiofolder=letters{cletter}.audiofolder;
    letters_with_models{current}.reference_audiofile=letters{cletter}.reference_audiofile;
    letters_with_models{current}.reference_audiofolder=letters{cletter}.reference_audiofolder;
    letters_with_models{current}.box=letters{cletter}.box;
    letters_with_models{current}.predictors=letter_predictors{cletter};
    letters_with_models{current}.classification=nan(nt,1);
    letters_with_models{current}.beta=[0 0]';
else
    current=old;
end

letter_with_model=letters_with_models{current};

box=letter_with_model.box;

predictors=letter_with_model.predictors;
cors=predictors(:,1);
y=letter_with_model.classification;
beta=letter_with_model.beta;

contT=true;
while contT
    figure(fig1);
    fig1=show_letter_model(letter_with_model,P1,[]);
    
    one=y==1;
    zer=y==0;
    ny=sum(one)+sum(zer);
    
    if style==1
        if ny<10
            targetcor=1-(ny/10);
        elseif sum(one)<4
            targetcor=1;
        elseif sum(zer)<4
            targetcor=0;
        else
            xx=0:0.01:1;
            gxx=glmval(beta,xx,'probit',1);
            [mi, zz]=min(abs(gxx-unifrnd(0,1)));
            targetcor=xx(zz);
        end
        dict=abs(cors-targetcor);
        dict(~isnan(y))=NaN;
        [mi, j]=min(dict);
    end
    if style==2
        box=extract_box_from_model(fig1,2,1,2,maxx);
        x1=box(1);
        x2=box(2);
        targetcor=(x1+x2)/2;
        dict=abs(cors-targetcor);
        dict(~isnan(y))=NaN;
        [mi, j]=min(dict);
    end
    if style==3
        if counter==1
            box=extract_box_from_model(fig1,2,1,2,maxx);
            x1=box(1);
            x2=box(2);
            targetcor=(x1+x2)/2;
            dict=abs(cors-targetcor);
            dict(~or(y==0,y==1))=NaN;
            [tgdist, tgdistindex]=sort(dict);
        end
        j=tgdistindex(counter);
        counter=counter+1;
    end      
    figure(fig1);
    fig1=show_letter_model(letter_with_model,P1,[j]);
    
    figure(fig2);
    [fig2, box2, maxx]=show_letter_audiofile(audiofolder,letter_with_model,files(j).name,P1,['Current classification: ' num2str(y(j))]);
    sound_to_play=extract_sound_to_play(audiofolder,P1,files(j).name,box2,true);
    play(sound_to_play);
    cont=true;
    while cont
        commandwindow;
        res=input(['[p1/p2/p3]/[0/1/-1]/[a/m/r]/[t]/[n]/[e]: '],'s');
        stop(sound_to_play);
        if strcmp(res,'a')
            style=1;
            cont=false;
        end        
        if strcmp(res,'m')
            style=2;
            cont=false;
        end
        if strcmp(res,'r')
            style=3;
            cont=false;
            counter=1;
        end        
        if strcmp(res,'p1')
            sound_to_play=extract_sound_to_play(audiofolder,P1,letter_with_model.audiofile,letter_with_model.box,true);
            play(sound_to_play);
        end
        if strcmp(res,'p2')
            sound_to_play=extract_sound_to_play(audiofolder,P1,files(j).name,box2,true);
            play(sound_to_play);
        end
        if strcmp(res,'p3')
            pbox=extract_box_from_image(fig2,3,1,3,P1,maxx);
            sound_to_play=extract_sound_to_play(audiofolder,P1,files(j).name,pbox,true);
            play(sound_to_play);
        end
        if strcmp(res,'-1')
            y(j)=-1;
            cont=false;
        end
        if strcmp(res,'1')
            y(j)=1;
            cont=false;
        end
        if strcmp(res,'t')
            disp(['Current audio file: ',files(j).name]);
        end
        if strcmp(res,'0')
            y(j)=0;
            cont=false;
        end
        if strcmp(res,'n')
          cont=false;
        end
        if strcmp(res,'e')
            cont=false;
            contT=false;
        end
    end
    sel=or(y==0,y==1);
    cors1=cors(sel);
    yy1=y(sel);
    one=y==1;
    zer=y==0;
    prix=[0 0 1 1]';
    priy=[0 1 0 1]';
    priw=P4.prior_letter*[1 1 1 1]';
    yy2=[yy1; priy];
    w2=[ones(sum(sel),1); priw];
    cors2=[cors1; prix];
    warning('off');
    beta=glmfit(cors2,yy2,'binomial','link','probit','weights',w2);
    warning('on');
    letter_with_model.classification=y;
    letter_with_model.beta=beta;    
end
letters_with_models{current}=letter_with_model;

