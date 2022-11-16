function [box] = extract_box_from_image(fig,panels1,panels2,sub,P1,maxx)

figure(fig);
if max(panels1,panels2)>1
    subplot(panels1,panels2,sub);
end
tmp=wait(imrect);
x1=max(1,round(tmp(1)));
x2=min(maxx,round(tmp(1)+tmp(3)));
y1=max(1,round(tmp(2)));
y2=min(P1.high-P1.low+1, round(tmp(2)+tmp(4)));
box=[x1 x2 y1 y2];
