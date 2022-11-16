function sound_to_play = extract_sound_to_play(audiofolder,P1,filename,box,filt)

x1=box(1);
x2=box(2);
y1=box(3);
y2=box(4);
full_filename=strcat(audiofolder,filesep,filename);
[audio,fs]=audioread(full_filename);
if filt
    wn=[max(P1.low+y1-1,2) min(P1.low+y2-1,P1.wlen/2 -2)]/(P1.wlen/2);
    [b,aa]=butter(6,wn);
    af=filter(b,aa,audio);
else
    af=audio;
end
if P1.playsound
w=P1.wdif*(fs/P1.fs);
sound_to_play = audioplayer(af(round(w*x1):round(w*x2)),fs);
end
 
