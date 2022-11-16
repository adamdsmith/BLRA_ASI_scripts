function [new_species_with_predictions] = fit_previous_species_model(previous_species_model, species, P4)

y = previous_species_model.classification;
species_predictors = previous_species_model.predictors(:, previous_species_model.selected_predictors);

% First, get predictors from previous model to reconstruct final model
predA = species_predictors(:, 1);
predB = species_predictors(:, 2);

% Now, fit the model and extract parameter estimates
sel = or(y==0, y==1);
pred1A = predA(sel);
pred1B = predB(sel);
yy1 = y(sel);
one = yy1 == 1;
zer = yy1 == 0;
% Drop priors
% prix=[0 0 1 1]';
% priy=[0 1 0 1]';
% priw = P4.prior_species * [1 1 1 1]';
yy2 = yy1; % [yy1; priy];
w2 = [ones(sum(sel), 1)]; % [ones(sum(sel), 1); priw];
pred2A = pred1A; % [pred1A; prix];
pred2B = pred1B; % [pred1B; prix];
warning('off');
bA = glmfit(pred2A, yy2, 'binomial', 'link', 'probit', 'weights', w2);
bB = glmfit(pred2B, yy2, 'binomial', 'link', 'probit', 'weights', w2);
bAB = glmfit([pred2A pred2B pred2A.*pred2B], yy2, 'binomial', 'link', 'probit', 'weights', w2);
warning('on');

% Get predictors from new files and use the above model fit to generate
% predicted probabilities
new_species_predictors = species.predictors(:, previous_species_model.selected_predictors);
predA = new_species_predictors(:, 1);
predB = new_species_predictors(:, 2);
pA = glmval(bA, predA, 'probit', 1);
pB = glmval(bB, predB, 'probit', 1);
pAB = glmval(bAB, [predA predB predA.*predB], 'probit', 1);

new_species_with_predictions = species;
new_species_with_predictions.probabilities = [pA pB pAB];
