function [fig, box2, maxx] = show_letter_audiofile(audiofolder,letter,file,P1,plottitle)

filename=letter.audiofile;
letter_audiofolder=letter.audiofolder;
box=letter.box;
x1=box(1);
x2=box(2);
y1=box(3);
y2=box(4);

full_filename=strcat(letter_audiofolder,filesep,filename);
[audio,fs]=audioread(full_filename);
ldata=audio_to_image(audio,fs,P1);
letterdata=ldata(y1:y2,x1:x2);

full_filename=strcat(audiofolder,filesep,file);
[audio,fs]=audioread(full_filename);
data=audio_to_image(audio,fs,P1);

dx=x2-x1;
maxx=size(data,2);
maxcor=0;
if max(var(letterdata))>10^(-15)
    correl=compute_correlations(data, letterdata, [y1 y2], P1.tolerance);
    [ma, poy]=max(correl);
    [maxcor, pox]=max(ma);
    shift=poy(pox)-P1.tolerance-1;
    ox1=max(1,pox-ceil(dx/2));
    ox2=min(maxx,pox+ceil(dx/2));
else
    ma=0;
    shift=0;
    ox1=x1;
    ox2=x2;
end

subplot(3,1,1);
hold off
ax1=max(x1-10,1);
ax2=min(x2+10,maxx);
ay1=max(y1-10,1);
ay2=min(y2+10,P1.high-P1.low+1);
ma=max(letterdata(:));
datashow=ldata(ay1:ay2,ax1:ax2)/ma;
datashow=min(datashow,1);
imagesc([ax1 ax2],[ay1 ay2], datashow); axis xy; colorbar();
nice3freqticks([ay1 ay2], P1);
ylabel('Hz')
re=rectangle('Position',[x1 y1 x2-x1 y2-y1]);
re.EdgeColor = 'w';
title(letter.name,'interpreter','none')

subplot(3,1,2);
hold off
ax1=max(ox1-10,1);
ax2=min(ox2+10,maxx);
oy1=max(y1+shift,1);
oy2=min(y2+shift,P1.high-P1.low+1);
box2=[ax1 ax2 oy1 oy2];
ma=max(max(data(oy1:oy2,ox1:ox2)));
datashow=data(ay1:ay2,ax1:ax2)/ma;
datashow=min(datashow,1);
imagesc([ax1 ax2],[ay1 ay2],datashow); axis xy; colorbar();
nice3freqticks([ay1 ay2], P1);
ylabel('Hz')
re=rectangle('Position',[ox1 oy1 ox2-ox1 oy2-oy1]);
re.EdgeColor = 'w';
title(strcat('best match (',num2str(maxcor),')'));

subplot(3,1,3);
hold off;
yy1=max(1,y1-P1.tolerance);
yy2=min(size(data,1),y2+P1.tolerance);
ma=max(max(data(yy1:yy2,1:size(data,2))));
showdata=min(data/ma,1);
imagesc(showdata); axis xy; colorbar();
ay1=1;
ay2=size(showdata,1);
nice3freqticks([ay1 ay2], P1);
ylabel('Hz')
re=rectangle('Position',[ox1 y1 ox2-ox1 y2-y1]);
re.EdgeColor = 'w';
title(plottitle);
fig=gcf;
