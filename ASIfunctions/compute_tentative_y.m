function [tentative_y]=compute_tentative_y(letters_with_models)
nl=size(letters_with_models,2);
nt=size(letters_with_models{1}.classification,1);
tentative_y=nan(nt,1);
for i=1:nl
    y=letters_with_models{i}.classification;
    one=y==1;
    tentative_y(one)=1;
    zero=and(y==0,not(tentative_y==1));
    tentative_y(zero)=0;
end
