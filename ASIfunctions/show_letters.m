function [fig]=show_letters(letter_candidates,P1,n)

nl=size(letter_candidates,2);
nl=min(nl,n);
rows=ceil(sqrt(nl));
cols=ceil(nl/rows);
for i=1:nl
    letter=letter_candidates{i};
    audiofolder=letter.audiofolder;
    filename=letter.audiofile;
    box=letter.box;
    x1=box(1);
    x2=box(2);
    y1=box(3);
    y2=box(4);
    full_filename=strcat(audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    letterdata=data(y1:y2,x1:x2);
    subplot(rows,cols,i);
    ax1=max(x1-10,1);
    ax2=min(x2+10,size(data,2));
    ay1=max(y1-10,1);
    ay2=min(y2+10,P1.high-P1.low+1);
    ma=max(letterdata(:));
    datashow=data(ay1:ay2,ax1:ax2)/ma;
    datashow=min(datashow,1);
    imagesc([ax1 ax2],[ay1 ay2], datashow); axis xy; 
    nice3freqticks([ay1 ay2], P1);
    
    if cols<3
        colorbar();
        ylabel('Hz');
    end
    re=rectangle('Position',[x1 y1 x2-x1 y2-y1]);
    re.EdgeColor = 'w';
    title(letter.name,'interpreter','none');
end
fig=gcf;


