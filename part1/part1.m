
%% ENGS 93 Homework - Part 1
% Descriptive Statistics and Normal Probability Distributions
% Dataset: Engineering Salaries 2021

clear;
clc;
close all;

%

project_root = pwd;

% the parent directory is used when matlab starts inside part1.
if strcmp(string(project_root), string(fullfile( ...
        '/Users/ritisingh/Desktop/engs93_homework', 'part1')))
    project_root = fileparts(project_root);
end

% the dataset is stored in a shared folder at the repository root.
data_path = fullfile(project_root, 'data', ...
    'Engineering_Salaries_2021_10000.csv');

% this check prevents analysis from continuing with a missing dataset.
assert(isfile(data_path), ...
    'The salary dataset was not found in the data directory.');

% readtable preserves the csv column headers as table variable names.
data = readtable(data_path);

% matlab's summary function gives an overview of the dataset.
disp('Question 1: Dataset Summary');
summary(data);

% the table dimensions correspond to observations and variables.
num_observations = height(data);
num_variables = width(data);

fprintf('\nNumber of observations: %d\n', num_observations);
fprintf('Number of variables: %d\n', num_variables);



% the original variable names allow each column to be inspected
% without manually specifying all eighteen variables.
variable_names = data.Properties.VariableNames;

for i = 1:num_variables

    variable_name = variable_names{i};
    column = data.(variable_name);

    fprintf('\n%s:\n', variable_name);

    if strcmp(variable_name, 'submission_date')

        % the date column may be imported as text or as datetime.
        if ~isdatetime(column)
            dates = datetime(string(column), ...
                'InputFormat', 'yyyy-MM-dd');
        else
            dates = column;
        end

        fprintf('  earliest date: %s\n', ...
            char(string(min(dates))));
        fprintf('  latest date: %s\n', ...
            char(string(max(dates))));

    elseif isnumeric(column)

        % only finite observations contribute to numerical ranges.
        valid_values = column(isfinite(column));

        if ~isempty(valid_values)
            fprintf('  minimum: %.2f\n', min(valid_values));
            fprintf('  maximum: %.2f\n', max(valid_values));
        else
            fprintf('  no valid numerical observations\n');
        end

    else

        % unique labels describe the categories present in the data.
        category_names = unique(string(column));
        category_names = category_names( ...
            ~ismissing(category_names));

        fprintf('  number of categories: %d\n', ...
            numel(category_names));

        % a short preview keeps the published report readable.
        preview_count = min(numel(category_names), 10);

        for j = 1:preview_count
            fprintf('    %s\n', char(category_names(j)));
        end

        if numel(category_names) > preview_count
            fprintf('    %d additional categories\n', ...
                numel(category_names) - preview_count);
        end

    end
end


% the two selected variables are stored separately for clarity.
salary = data.base_salary;
experience = data.years_of_experience;

% non-finite observations are excluded from the calculations.
salary = salary(isfinite(salary));
experience = experience(isfinite(experience));

% the mean summarizes the central value of each numerical variable.
salary_mean = mean(salary);
experience_mean = mean(experience);

% matlab's default std function uses n-1 in the denominator,
% producing the usual sample standard deviation.
salary_std = std(salary);
experience_std = std(experience);

fprintf('\nQuestion 2: Descriptive Statistics\n');

fprintf('\nBase salary:\n');
fprintf('  mean: $%.2f\n', salary_mean);
fprintf('  standard deviation: $%.2f\n', salary_std);

fprintf('\nYears of experience:\n');
fprintf('  mean: %.4f years\n', experience_mean);
fprintf('  standard deviation: %.4f years\n', experience_std);


% a finely spaced salary vector produces a smooth density curve.
x = linspace(min(salary), max(salary), 1000);

% the normal density is evaluated using the estimated sample
% parameters rather than assuming a theoretical mean or variance.
normal_pdf = (1 / (salary_std * sqrt(2*pi))) .* ...
    exp(-0.5 * ((x - salary_mean) ./ salary_std).^2);

% the histogram is normalized to probability density so its
% scale matches the fitted normal density.
fig_salary = figure('Color', 'w');

histogram(salary, 40, ...
    'Normalization', 'pdf', ...
    'FaceAlpha', 0.6);

hold on;

% the red curve represents the fitted normal distribution.
plot(x, normal_pdf, 'r-', 'LineWidth', 2);

xlabel('Base salary ($)');
ylabel('Probability density');
title('Figure 1. Engineering Base Salary Distribution');

legend('Observed salary distribution', ...
    'Fitted Normal distribution', ...
    'Location', 'best');

grid on;
hold off;



% the output path is shared across the project.
results_dir = fullfile(project_root, 'results', 'figures');

if ~isfolder(results_dir)
    mkdir(results_dir);
end

saveas(fig_salary, ...
    fullfile(results_dir, 'part1_salary_histogram.png'));



% the salary threshold is an illustrative value within the
% observed range of the dataset.
salary_threshold = 150000;

% the z-score expresses the threshold relative to the mean
% and standard deviation of the fitted normal distribution.
z_score = (salary_threshold - salary_mean) / salary_std;

% the error function evaluates the normal cumulative probability
% without requiring the statistics and machine learning toolbox.
prob_less = 0.5 * (1 + erf(z_score / sqrt(2)));

% the complement gives the probability above the threshold.
prob_greater = 1 - prob_less;

% the empirical proportion provides a comparison against the
% observed dataset rather than the fitted normal model.
observed_proportion = mean(salary < salary_threshold);

fprintf('\nQuestion 3: Normal Probability\n');

fprintf('Salary threshold: $%.2f\n', salary_threshold);
fprintf('Z-score: %.4f\n', z_score);

fprintf('P(salary < $%.0f): %.4f\n', ...
    salary_threshold, prob_less);

fprintf('P(salary > $%.0f): %.4f\n', ...
    salary_threshold, prob_greater);

fprintf('Observed proportion below threshold: %.4f\n', ...
    observed_proportion);



% the experience threshold is selected within the observed range.
experience_threshold = 10;

% the standardized experience value is relative to its own
% estimated mean and sample standard deviation.
experience_z = (experience_threshold - experience_mean) ...
    / experience_std;

% the fitted normal probability is evaluated at ten years.
experience_prob_less = 0.5 * ...
    (1 + erf(experience_z / sqrt(2)));

% the observed fraction provides an empirical comparison.
experience_observed = mean(experience < experience_threshold);

fprintf('\nAdditional experience probability:\n');

fprintf('P(experience < %.0f years): %.4f\n', ...
    experience_threshold, experience_prob_less);

fprintf('Observed proportion: %.4f\n', experience_observed);


fprintf('\nPart 1 analysis complete.\n');
