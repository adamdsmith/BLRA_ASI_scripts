clearvars -except project;

if exist('project','var')
    disp(['Current project directory: ',project])
else
    error('You have not defined the variable "project". Please do so and re-run this script.')
end

load(strcat(project,filesep,'S3b_output')); %'letters_with_models, no KKD0 added yet'

letter_names = {};
nl = size(letters_with_models, 2);
for i = 1:nl
    letter_names{i} = letters_with_models{i}.name;
end

to_copy = find(~cellfun(@isempty,regexp(letter_names, '^KKD_KKD')));

kkds = letters_with_models(to_copy);
nkkd = size(kkds, 2);
for i = 1:nkkd
    kkds{i}.name = regexprep(kkds{i}.name, '^KKD_KKD', 'KKD0_KKD');
end

letters_with_models = [letters_with_models, kkds];

save(strcat(project,filesep,'S3b_output'),'letters_with_models');
