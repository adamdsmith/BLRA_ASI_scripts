function [y] = nice3freqticks(yindexlimits, P1)
% convert to frequency
ymin=(yindexlimits(1) + P1.low -1) * P1.fs/P1.wlen;
ymax=(yindexlimits(2) + P1.low -1) * P1.fs/P1.wlen;
yc=(ymin+ymax)/2;

m=floor(log10(ymax-ymin));
r=10^(m-1);
if (ymax-ymin)>60*r
    r=10*r;
elseif (ymax-ymin)>30*r
    r=5*r;
end
ryc=round(yc/r)*r;
ry1=round((ymin+yc)/2/r)*r;
ry2=ryc+(ryc-ry1);

y=[ry1 ryc ry2];
ypos=y*P1.wlen/P1.fs - P1.low +1;

yticks(ypos)
yticklabels(y)
