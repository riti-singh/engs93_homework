%% engs 93 homework - part 1
% descriptive statistics and normal probability distributions
% dataset: engineering salaries 2021
%
% question 1: import and summarize the dataset
% question 2: calculate statistics and plot a normal distribution
% question 3: calculate probabilities using the normal distribution


clear;
clc;
close all;

%%question 1: import and explore dataset

% locate the repository relative to this script
script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);

% construct the dataset path
data_path = fullfile(project_root, 'data', ...
    'Engineering_Salaries_2021_10000.csv');

% make sure the dataset exists
assert(isfile(data_path), 'dataset not found');

% load the csv file as a matlab table
data = readtable(data_path);

% display the dataset summary
disp('question 1: dataset summary');
summary(data);

% calculate the number of observations and variables
num_observations = height(data);
num_variables = width(data);

fprintf('\nnumber of observations: %d\n', num_observations);
fprintf('number of variables: %d\n\n', num_variables);

% examine the range of every variable
% numerical variables have minimum and maximum values
% categorical variables are summarized by unique categories

variable_names = data.Properties.VariableNames;

for i = 1:num_variables

    variable_name = variable_names{i};
    column = data.(variable_name);

    fprintf('%s:\n', variable_name);

    if isnumeric(column)

        fprintf('  minimum: %.2f\n', min(column));
        fprintf('  maximum: %.2f\n', max(column));

    elseif isdatetime(column)

        fprintf('  earliest: %s\n', char(string(min(column))));
        fprintf('  latest: %s\n', char(string(max(column))));

    elseif strcmp(variable_name, 'submission_date')

        % handle dates if matlab imported them as text
        dates = datetime(string(column), ...
            'InputFormat', 'yyyy-MM-dd');

        fprintf('  earliest: %s\n', char(string(min(dates))));
        fprintf('  latest: %s\n', char(string(max(dates))));

    else

        % categorical variables do not have numerical ranges
        categories = unique(string(column));

        fprintf('  number of categories: %d\n', ...
            numel(categories));

    end

end


%% question 2: calculate descriptive statistics

% select two continuous variables
% variable 1: base salary in dollars
% variable 2: years of professional experience

salary = data.base_salary;
experience = data.years_of_experience;

% calculate sample means
salary_mean = mean(salary);
experience_mean = mean(experience);

% calculate sample standard deviations
% matlab uses the n-1 sample normalization by default
salary_std = std(salary);
experience_std = std(experience);

% display calculated statistics
fprintf('\nquestion 2: descriptive statistics\n');

fprintf('\nbase salary:\n');
fprintf('  mean: $%.2f\n', salary_mean);
fprintf('  standard deviation: $%.2f\n', salary_std);

fprintf('\nyears of experience:\n');
fprintf('  mean: %.2f years\n', experience_mean);
fprintf('  standard deviation: %.2f years\n', experience_std);


%% question 2: histogram and normal density curve

% construct a range of salary values for the normal curve
x = linspace(min(salary), max(salary), 1000);

% calculate the normal probability density function
% the formula uses the observed mean and standard deviation
normal_pdf = (1 / (salary_std * sqrt(2*pi))) .* ...
    exp(-0.5 * ((x - salary_mean) ./ salary_std).^2);

% create a histogram normalized as a probability density
figure;

histogram(salary, 40, ...
    'Normalization', 'pdf', ...
    'FaceAlpha', 0.6);

hold on;

% overlay the theoretical normal density curve
plot(x, normal_pdf, 'r-', 'LineWidth', 2);

% add figure labels
xlabel('base salary ($)');
ylabel('probability density');
title('distribution of engineering base salaries');

legend('observed salaries', 'fitted normal distribution', ...
    'Location', 'best');

grid on;
hold off;

% save the figure to the shared results directory
results_dir = fullfile(project_root, 'results', 'figures');

if ~isfolder(results_dir)
    mkdir(results_dir);
end

saveas(gcf, fullfile(results_dir, 'part1_salary_histogram.png'));


%% question 3: probability using the normal distribution

% choose a salary threshold within the observed range
salary_threshold = 150000;

% calculate the z-score for the threshold
z_score = (salary_threshold - salary_mean) / salary_std;

% compute the cumulative normal probability
% erf provides the normal cdf without requiring a toolbox
prob_less = 0.5 * (1 + erf(z_score / sqrt(2)));

% calculate the complementary probability
prob_greater = 1 - prob_less;

% calculate the observed proportion for comparison
observed_proportion = mean(salary < salary_threshold);

% display the results
fprintf('\nquestion 3: normal probability\n');

fprintf('\nsalary threshold: $%.2f\n', salary_threshold);
fprintf('z-score: %.4f\n', z_score);

fprintf('p(salary < $%.0f): %.4f\n', ...
    salary_threshold, prob_less);

fprintf('p(salary > $%.0f): %.4f\n', ...
    salary_threshold, prob_greater);

fprintf('observed proportion below threshold: %.4f\n', ...
    observed_proportion);

fprintf('\npart 1 analysis complete.\n');