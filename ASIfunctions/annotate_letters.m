function letters=annotate_letters(project,audiofolder,P1,letter_candidates,letter_candidate_clusters,cluster_order,cc,cl,make_plots)

letters={};
nc=length(cluster_order);
list=find(letter_candidate_clusters==cluster_order(cc));
cl=min(cl,length(list));
i=list(cl);
letter=letter_candidates{i};
nl=0;

cont=true;
while cont
    fprintf(['Number of letters annotated in this session: ' num2str(size(letters,2)) '.\n']);
    fprintf(['Cluster: ' num2str(cc) '/' num2str(nc) '. Letter candidate: ',num2str(cl) '/' num2str(length(list)) '.\n']);
    if and(cl==length(list),cc==nc)
        fprintf('NOTE: this is the last letter candidate.\n');
    end
    [fig, maxx]=show_letter(letter,P1);
    if P1.playsound
        sound_to_play=extract_sound_to_play(audiofolder,P1,letter.audiofile,letter.box,true);
        play(sound_to_play);
        res=input(['L' num2str(nl+1) ': [r1/r2/r3]/[p/n]/[pc/nc]/[l]/[annotation]/[e]: '],'s');
        stop(sound_to_play);
    else
        res=input(['L' num2str(nl+1) ': [r1/r2/r3]/[p/n]/[pc/nc]/[l]/[annotation]/[e]: '],'s');
    end
    if res=='e'
        cont=false;
    end
    if strcmp(res,'l')
        disp(sprintf('Current letters:'));
        if size(letters,2)>0
            for i=1:size(letters,2)
                disp(sprintf(letters{i}.name));
            end
        end
    end
    if strcmp(res,'r1')
        letter.box=extract_box_from_image(fig,3,1,1,P1,maxx);
    end
    if strcmp(res,'r2')
        letter.box=extract_box_from_image(fig,3,1,2,P1,maxx);
    end
    if strcmp(res,'r3')
        letter.box=extract_box_from_image(fig,3,1,3,P1,maxx);
    end
    if size(res,2)>3
        nl=nl+1;
        letter.name=res;
        letters{nl}.name=letter.name;
        letters{nl}.audiofile=letter.audiofile;
        letters{nl}.audiofolder=letter.audiofolder;
        letters{nl}.reference_audiofile=letter.reference_audiofile;
        letters{nl}.reference_audiofolder=letter.reference_audiofolder;
        letters{nl}.box=letter.box;
        
        if make_plots
            fprintf('Plotting letter to file\n');
            cfolder=strcat(project,filesep,'letters');
            if not(7==exist(cfolder,'dir'))
                mkdir(cfolder);
            end
            close all;
            
            [lfig, maxx]=show_letter(letters(nl,:),P1);
            print(strcat(cfolder,filesep,'Letter_',num2str(nl),'.tiff'),'-dtiff');
            close all;
        end
        % uncomment to advance to next candidate after building letter
        %res='n'; 
    end
    if strcmp(res,'p')
        if cl>1
            cl=cl-1;
        else
            if cc>1
                cc=cc-1;
                list=find(letter_candidate_clusters==cluster_order(cc));
                cl=length(list);
            end
        end
        list=find(letter_candidate_clusters==cluster_order(cc));
        i=list(cl);
        letter=letter_candidates{i};
    end
    if strcmp(res,'pc')
        if cc>1
            cc=cc-1;
            cl=1;
        end
        list=find(letter_candidate_clusters==cluster_order(cc));
        i=list(cl);
        letter=letter_candidates{i};
    end
    if strcmp(res,'n')
        if cl<length(list)
            cl=cl+1;
        else
            if cc<nc
                cc=cc+1;
                cl=1;
            end
        end
        list=find(letter_candidate_clusters==cluster_order(cc));
        i=list(cl);
        letter=letter_candidates{i};
    end
    if strcmp(res,'nc')
        if cc<nc
            cc=cc+1;
            cl=1;
        end
        list=find(letter_candidate_clusters==cluster_order(cc));
        i=list(cl);
        letter=letter_candidates{i};
    end
end

