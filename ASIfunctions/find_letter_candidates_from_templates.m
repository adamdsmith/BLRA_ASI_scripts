function [letter_candidates]=find_letter_candidates_from_templates(audiofolder,files,P1,P2,n,template_audiofolder,templates)

nr=size(files,1);
letter_candidates={};
nt=size(templates,2);

for i=1:nt
    filename=templates{i}.audiofile;
    box=templates{i}.box;
    x1=box(1);
    x2=box(2);
    y1=box(3);
    y2=box(4);
    
    full_filename=strcat(template_audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    Ttemplatedata{i}=data(y1:y2,x1:x2);
    Tbox{i}=box;
end

repl=0;
while repl<n
    recording=randsample(nr,1);
    filename=files(recording,:);
    full_filename=strcat(audiofolder,filesep,filename.name);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    
    if sum(isnan(data(:)))==0
        for i=1:nt
            x1=Tbox{i}(1);
            x2=Tbox{i}(2);
            y1=Tbox{i}(3);
            y2=Tbox{i}(4);
            correl=compute_correlations(data, Ttemplatedata{i}, [y1 y2], P1.tolerance);
            [ma, poy]=max(correl);
            [ma, pox]=max(ma);
            if and(repl<n,ma>P2.correlation_threshold)
                repl=repl+1;
                shift=poy(pox)-P1.tolerance-1;
                dx=x2-x1+1;
                dx=min(P2.dx_max,max(dx,P2.dx_min));
                ox1=max(1,pox-round(dx/2));
                ox2=min(ox1+dx-1,size(data,2));
                dy=y2-y1;
                dy=min(P2.dy_max,max(dy,P2.dy_min));
                oy1=y1+shift;
                oy1=min(P2.y_max,max(oy1,P2.y_min));
                oy2=oy1+dy;
                oy2=min(P2.y_max,max(oy2,P2.y_min));
                letter_candidates{repl}.name=['letter_candidate_' num2str(repl,'%04.f') '. template: ' templates{i}.name];
                letter_candidates{repl}.audiofile=filename.name;
                letter_candidates{repl}.audiofolder=audiofolder;
                letter_candidates{repl}.box=[ox1 ox2 oy1 oy2];
                letter_candidates{repl}.reference_audiofile=templates{i}.audiofile;
                letter_candidates{repl}.reference_audiofolder=template_audiofolder;
            end
        end
    end
end

