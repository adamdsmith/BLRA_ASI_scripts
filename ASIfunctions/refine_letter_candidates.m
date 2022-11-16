function [refined_letter_candidates]=refine_letter_candidates(audiofolder,letter_candidates,P1,P2,P3)

nl=size(letter_candidates,2);

refined_letter_candidates=letter_candidates;
for i=1:nl
    filename=letter_candidates{i}.audiofile;
    box=letter_candidates{i}.box;
    x1=box(1);
    x2=box(2);
    y1=box(3);
    y2=box(4);
    
    full_filename=strcat(audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    letterdata=data(y1:y2,x1:x2);
    bestscore=0;
    for repl=0:P3.n_refine
        ls=size(letterdata);
        dy=ls(1);
        dx=ls(2);
        centre=letterdata(round(0.15*ls(1)):round(0.85*ls(1)),round(0.15*ls(2)):round(0.85*ls(2)));
        prop = sum(centre(:))/sum(letterdata(:));
        if var(letterdata(:))>10^(-15)
            correl=compute_correlations(data, letterdata, [y1 y2], P1.tolerance);
            [ma , ~]=max(correl);
            ma(x1:x2)=0;
            [maxcor , ~]=max(ma);
        else
            maxcor=0;
        end
        quality = [maxcor prop dx dy];
        score = 10*(quality(1)>0.9) + 5*quality(1) + 50*quality(2) + (quality(3)/20)+(quality(4)/20);
        if score>bestscore
            refined_letter_candidates{i}.box=[x1 x2 y1 y2];
            bestscore=score;
        end
        if repl<P3.n_refine
            cont = true;
            box=letter_candidates{i}.box;
            while cont
                x1=box(1)+unidrnd(2*P3.x_shift+1)-P3.x_shift-1;
                x2=box(2)+unidrnd(2*P3.x_shift+1)-P3.x_shift-1;
                y1=box(3)+unidrnd(2*P3.y_shift+1)-P3.y_shift-1;
                y2=box(4)+unidrnd(2*P3.y_shift+1)-P3.y_shift-1;
                cont = false;
                if y2-y1<P2.dy_min cont=true; end
                if y2-y1>P2.dy_max cont=true; end
                if x2-x1<P2.dx_min cont=true; end
                if x2-x1>P2.dx_max cont=true; end
                if x1<1 cont=true; end
                if x2>size(data,2) cont=true; end
                if y1<1 cont=true; end
                if y2>(P1.high-P1.low+1) cont=true; end
            end
            letterdata=data(y1:y2,x1:x2);
        end
    end
end
    
