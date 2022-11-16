function [box] = extract_box_from_model(fig,panels1,panels2,sub,maxx)

figure(fig);
if max(panels1,panels2)>1
    subplot(panels1,panels2,sub);
end
tmp=wait(imrect);
x1=tmp(1);
x2=min(maxx,tmp(1)+tmp(3));
y1=tmp(2);
y2=tmp(2)+tmp(4);
box=[x1 x2 y1 y2];
