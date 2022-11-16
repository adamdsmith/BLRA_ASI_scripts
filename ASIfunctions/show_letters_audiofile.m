function [fig, maxx] = show_letters_audiofile(audiofolder,filename,P1,fspecies,plottitle)

full_filename=strcat(audiofolder,filesep,filename);
[audio,fs]=audioread(full_filename);
data=audio_to_image(audio,fs,P1);
maxx=size(data,2);

letters=fspecies.letters;
nl=size(letters,2);
ay2=1;
ay1=P1.high-P1.low+1;
for i=1:nl
    filename=letters{i}.audiofile;
    %letter_audiofolder=letters{i}.audiofolder;
    letter_audiofolder=audiofolder;
    box=letters{i}.box;
    x1=box(1);
    x2=box(2);
    y1=box(3);
    y2=box(4);
    ay1=max(1,min(ay1,y1-P1.tolerance));
    ay2=min(P1.high-P1.low+1,max(ay2,y2+P1.tolerance));
    full_filename=strcat(letter_audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    letterdata=audio_to_image(audio,fs,P1);
    letterdata=letterdata(y1:y2,x1:x2);
    correl=compute_correlations(data, letterdata, [y1 y2], P1.tolerance);
    [ma, poy]=max(correl);
    [~, pox]=max(ma);
    shift=poy(pox)-P1.tolerance-1;
    dx=x2-x1+1;
    ox1=max(1,pox-ceil(dx/2));
    ox2=min(size(data,2),pox+ceil(dx/2));
    Tbox{i}=[ox1 ox2 y1+shift y2+shift];
end

ma=max(max(data(ay1:ay2,:)));
datashow=data/ma;
datashow=min(datashow,1);
imagesc(datashow); axis xy; colorbar();
ay1=1;
ay2=size(datashow,1);
nice3freqticks([ay1 ay2], P1);
ylabel('Hz')

for i=1:nl
    box=Tbox{i};
    x1=box(1);
    x2=box(2);
    y1=box(3);
    y2=box(4);
    re=rectangle('Position',[x1 y1 x2-x1 y2-y1]);
    re.EdgeColor = 'w';
end
title(plottitle);
fig=gcf;
