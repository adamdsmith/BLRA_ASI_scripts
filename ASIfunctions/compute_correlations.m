function [correl] = compute_correlations(data,letter,yrange,tolerance)

qy=[max(1,yrange(1)-tolerance) min(size(data,1),yrange(2)+tolerance)];
if size(data,2) < size(letter,2)
    letter=letter(:,1:size(data,2));
end    

stozero=data(qy(1):qy(2),:);
stozero(isnan(stozero))=0;
c2=normxcorr2(letter,stozero);
i1=max(1, yrange(2)-qy(1)-tolerance+1);
i2=min(size(c2,1), yrange(2)-qy(1)+tolerance+1);
foo=round(size(letter,2)/2);
if i1==i2
    correl=c2(i1,foo:foo+size(data,2)-1);
else
    correl=c2(i1:i2,foo:foo+size(data,2)-1);
end




