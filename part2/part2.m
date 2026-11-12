
%% engs 93 homework - part 2
% confidence intervals and hypothesis testing
% dataset: engineering salaries 2021

clear;
clc;
close all;

%% load the dataset

% locate the repository relative to this script
script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);

% construct the dataset path
data_path = fullfile(project_root, 'data', ...
    'Engineering_Salaries_2021_10000.csv');

% import the dataset
data = readtable(data_path);

% select base salary as the continuous variable
salary = data.base_salary;

% exclude any missing or non-finite salary observations
salary = salary(isfinite(salary));

% calculate sample statistics
n = length(salary);
salary_mean = mean(salary);
salary_std = std(salary);
standard_error = salary_std / sqrt(n);

fprintf('part 2: statistical inference\n');
fprintf('sample size: %d\n', n);
fprintf('sample mean: $%.2f\n', salary_mean);
fprintf('sample standard deviation: $%.2f\n', salary_std);
fprintf('standard error: $%.2f\n', standard_error);


%% question 1: examine normality

% create a range of values for the normal density curve
x = linspace(min(salary), max(salary), 1000);

% calculate the fitted normal density
normal_pdf = (1 / (salary_std * sqrt(2*pi))) .* ...
    exp(-0.5 * ((x - salary_mean) ./ salary_std).^2);

% plot the normalized salary histogram
figure;

histogram(salary, 40, ...
    'Normalization', 'pdf', ...
    'FaceAlpha', 0.6);

hold on;

% overlay the fitted normal distribution
plot(x, normal_pdf, 'r-', 'LineWidth', 2);

xlabel('base salary ($)');
ylabel('probability density');
title('base salary distribution with normal density');

legend('observed salaries', 'fitted normal distribution', ...
    'Location', 'best');

grid on;
hold off;


%% question 1: normal q-q plot

% sort observed salary values from smallest to largest
sorted_salary = sort(salary);

% calculate plotting probabilities for each observation
probabilities = ((1:n)' - 0.5) / n;

% calculate expected quantiles of the fitted normal distribution
% erfinv is used to avoid requiring the statistics toolbox
theoretical_quantiles = salary_mean + salary_std * ...
    sqrt(2) .* erfinv(2 * probabilities - 1);

% create the q-q plot
figure;

plot(theoretical_quantiles, sorted_salary, '.', ...
    'MarkerSize', 6);

hold on;

% add the reference line representing perfect normality
reference_min = min(theoretical_quantiles);
reference_max = max(theoretical_quantiles);

plot([reference_min reference_max], ...
    [reference_min reference_max], ...
    'r-', 'LineWidth', 2);

xlabel('theoretical normal quantiles ($)');
ylabel('observed salary quantiles ($)');
title('normal q-q plot of base salary');

legend('observed quantiles', 'normal reference line', ...
    'Location', 'best');

grid on;
hold off;


%% question 2: confidence intervals for the mean

% calculate critical z-values for 95% and 75% confidence
% z = sqrt(2) * erfinv(confidence_level)

z_95 = sqrt(2) * erfinv(0.95);
z_75 = sqrt(2) * erfinv(0.75);

% calculate margins of error
margin_95 = z_95 * standard_error;
margin_75 = z_75 * standard_error;

% calculate lower and upper confidence bounds
ci_95 = [salary_mean - margin_95, ...
         salary_mean + margin_95];

ci_75 = [salary_mean - margin_75, ...
         salary_mean + margin_75];

% display confidence intervals
fprintf('\nquestion 2: confidence intervals\n');

fprintf('\n95%% confidence interval:\n');
fprintf('lower bound: $%.2f\n', ci_95(1));
fprintf('upper bound: $%.2f\n', ci_95(2));

fprintf('\n75%% confidence interval:\n');
fprintf('lower bound: $%.2f\n', ci_75(1));
fprintf('upper bound: $%.2f\n', ci_75(2));


%% question 3: hypothesis test for mean salary

% define the null hypothesis
% h0: population mean salary equals $130,000
% ha: population mean salary differs from $130,000

mu_0 = 130000;

% choose a significance level of 0.05
alpha = 0.05;

% calculate the observed z-statistic
z_stat = (salary_mean - mu_0) / standard_error;

% calculate the two-sided p-value
% standard normal cdf: 0.5 * (1 + erf(z/sqrt(2)))
p_value = 2 * 0.5 * erfc(abs(z_stat) / sqrt(2));

% compare the p-value with the significance level
reject_null = p_value < alpha;

% display hypothesis test results
fprintf('\nquestion 3: hypothesis testing\n');

fprintf('null hypothesis mean: $%.2f\n', mu_0);
fprintf('sample mean: $%.2f\n', salary_mean);
fprintf('z-statistic: %.4f\n', z_stat);
fprintf('p-value: %.6g\n', p_value);
fprintf('significance level: %.2f\n', alpha);

if reject_null
    fprintf('decision: reject the null hypothesis\n');
else
    fprintf('decision: fail to reject the null hypothesis\n');
end


%% save figures

% define the figure output directory
results_dir = fullfile(project_root, 'results', 'figures');

% create the directory if it does not exist
if ~isfolder(results_dir)
    mkdir(results_dir);
end

% note: save figures by their figure numbers
saveas(figure(1), ...
    fullfile(results_dir, 'part2_salary_histogram.png'));

saveas(figure(2), ...
    fullfile(results_dir, 'part2_salary_qqplot.png'));

fprintf('\npart 2 analysis complete.\n');
