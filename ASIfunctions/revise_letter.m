function rev_letters=revise_letter(project,audiofolder,P1,letters,name)

rev_letters={};

if isnumeric(name)
    i = name
else
    nl=size(letters,2);
    for i = 1:nl
        letter_names(i).name = letters{i}.name;
    end
    
    all_names = {letter_names.name};
    i = find(ismember(all_names, name));
    
    if size(i, 2) > 1
        warning('Multiple matches; tread carefully!');
        warning(strcat('Associated entries in LETTERS: (', num2str(i), ')'));
    end
end

letter=letters{i};
cl=i;
nl=0;

cont=true;
while cont
    [fig, maxx]=show_letter(letter,P1);
    if P1.playsound
        sound_to_play=extract_sound_to_play(audiofolder,P1,letter.audiofile,letter.box,true);
        play(sound_to_play);
        res=input(['L' num2str(nl+1) ': [r1/r2/r3]/[p/n]/[e]: '],'s');
        stop(sound_to_play);
    else
        res=input(['L' num2str(nl+1) ': [r1/r2/r3]/[p/n]/[e]: '],'s');
    end
    if res=='e'
        cont=false;
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
        rev_letters{nl}.name=letter.name;
        rev_letters{nl}.audiofile=letter.audiofile;
        rev_letters{nl}.audiofolder=letter.audiofolder;
        rev_letters{nl}.reference_audiofile=letter.reference_audiofile;
        rev_letters{nl}.reference_audiofolder=letter.reference_audiofolder;
        rev_letters{nl}.box=letter.box;
    end
end

