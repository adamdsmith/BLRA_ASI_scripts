function [letter_candidate_clusters,cluster_order]=cluster_letter_candidates(letter_candidate_correlations,max_clusters)

cormatrix=(letter_candidate_correlations+letter_candidate_correlations')/2;
dist=1-cormatrix;
if size(dist,1)==1
    letter_candidate_clusters=[1];
else
Z = linkage(dist);
letter_candidate_clusters = cluster(Z,'maxclust',max_clusters);
end

nc=length(unique(letter_candidate_clusters));
ncm=zeros(nc,1);
for i=1:nc
    ncm(i)=length(find(letter_candidate_clusters==i));
end
[~, cluster_order]=sort(ncm);
cluster_order=flipud(cluster_order);
