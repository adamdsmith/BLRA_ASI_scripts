function [fig, maxx] = show_audiofile(audiofolder,filename,P1,plottitle)

full_filename=strcat(audiofolder,filesep,filename);
[audio,fs]=audioread(full_filename);
ldata=audio_to_image(audio,fs,P1);
maxx=size(ldata,2);

hold off;
imagesc(ldata); axis xy; colorbar();
ay1=1;
ay2=size(ldata,1);
nice3freqticks([ay1 ay2], P1);
ylabel('Hz')
title(plottitle);
fig=gcf;
