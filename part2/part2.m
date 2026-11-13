
%% ENGS 93 Homework - Part 2
% Confidence Intervals and Hypothesis Testing
% Dataset: Engineering Salaries 2021

clear;
clc;
close all;




% the repository root is specified explicitly because matlab's
% publishing process may execute scripts from a temporary directory.
project_root = '/Users/ritisingh/Desktop/engs93_homework';

% the dataset is stored in the repository's shared data directory.
data_path = fullfile(project_root, 'data', ...
    'Engineering_Salaries_2021_10000.csv');

% the dataset must be present before the statistical analysis can run.
assert(isfile(data_path), ...
    'The salary dataset was not found in the data directory.');

% the csv file is imported as a matlab table with its original headers.
data = readtable(data_path);

% annual base salary is the continuous variable used in this analysis.
salary = data.base_salary;

% non-finite observations are excluded to prevent invalid calculations.
salary = salary(isfinite(salary));
salary = salary(:);

% the sample size, mean, and standard deviation describe the data.
n = length(salary);
salary_mean = mean(salary);
salary_std = std(salary);

% the estimated standard error describes the sampling variability
% of the mean under appropriate independence assumptions.
standard_error = salary_std / sqrt(n);

% the relevant sample statistics are shown before the analysis.
fprintf('\nPART 2: SAMPLE STATISTICS\n');
fprintf('Observations: %d\n', n);
fprintf('Mean base salary: $%.2f\n', salary_mean);
fprintf('Sample standard deviation: $%.2f\n', salary_std);
fprintf('Estimated standard error: $%.2f\n', standard_error);


% the salary values are distributed across a smooth vector so that
% the theoretical normal density can be evaluated continuously.
x = linspace(min(salary), max(salary), 1000);

% the normal density uses the observed sample mean and standard
% deviation rather than a predetermined population distribution.
normal_pdf = (1 / (salary_std * sqrt(2*pi))) .* ...
    exp(-0.5 * ((x - salary_mean) ./ salary_std).^2);

% a white figure and axes background improve readability when the
% graph is included in a published pdf or printed report.
fig_hist = figure('Color', 'w', ...
    'Position', [100, 100, 850, 500]);

ax_hist = axes('Parent', fig_hist);
set(ax_hist, 'Color', 'w', ...
    'XColor', 'k', 'YColor', 'k', ...
    'FontSize', 11);

% probability-density normalization makes the histogram comparable
% to the fitted normal probability density function.
histogram(ax_hist, salary, 40, ...
    'Normalization', 'pdf', ...
    'FaceColor', [0.25, 0.45, 0.70], ...
    'FaceAlpha', 0.75, ...
    'EdgeColor', 'w');

hold(ax_hist, 'on');

% the fitted normal curve illustrates how closely a symmetric
% theoretical distribution represents the observed salary values.
plot(ax_hist, x, normal_pdf, ...
    'Color', [0.80, 0.20, 0.20], ...
    'LineWidth', 2.2);

xlabel(ax_hist, 'Annual base salary ($)');
ylabel(ax_hist, 'Probability density');
title(ax_hist, ...
    'Figure 1. Distribution of Engineering Base Salaries');

legend(ax_hist, ...
    'Observed salary distribution', ...
    'Fitted Normal distribution', ...
    'Location', 'northeast');

% the displayed axis focuses on the central portion of the salary
% distribution. all observations remain in the statistical analysis.
xlim(ax_hist, [0, 400000]);

grid(ax_hist, 'on');
ax_hist.GridAlpha = 0.15;

hold(ax_hist, 'off');

% the image is saved directly without reopening the figure later.
results_dir = fullfile(project_root, 'results', 'figures');

if ~isfolder(results_dir)
    mkdir(results_dir);
end

exportgraphics(fig_hist, ...
    fullfile(results_dir, 'part2_salary_histogram.png'), ...
    'Resolution', 300);


% the empirical salary quantiles are obtained by ordering the
% observations from smallest to largest.
sorted_salary = sort(salary);

% plotting positions associate each ordered observation with
% a cumulative probability between zero and one.
probabilities = ((1:n)' - 0.5) / n;

% the inverse normal distribution is calculated using erfinv,
% avoiding a dependency on the statistics toolbox.
theoretical_quantiles = salary_mean + salary_std * ...
    sqrt(2) .* erfinv(2 * probabilities - 1);

% the q-q plot uses the same visual styling as the histogram.
fig_qq = figure('Color', 'w', ...
    'Position', [100, 100, 850, 500]);

ax_qq = axes('Parent', fig_qq);
set(ax_qq, 'Color', 'w', ...
    'XColor', 'k', 'YColor', 'k', ...
    'FontSize', 11);

% every point compares an observed salary quantile against the
% corresponding theoretical quantile under the fitted normal model.
plot(ax_qq, theoretical_quantiles, sorted_salary, '.', ...
    'Color', [0.25, 0.45, 0.70], ...
    'MarkerSize', 7);

hold(ax_qq, 'on');

% the diagonal reference line represents equality between observed
% and theoretical quantiles on the same salary scale.
reference_min = min(theoretical_quantiles);
reference_max = max(theoretical_quantiles);

plot(ax_qq, ...
    [reference_min reference_max], ...
    [reference_min reference_max], ...
    'Color', [0.80, 0.20, 0.20], ...
    'LineWidth', 2);

xlabel(ax_qq, 'Theoretical Normal quantiles ($)');
ylabel(ax_qq, 'Observed salary quantiles ($)');
title(ax_qq, 'Figure 2. Normal Q-Q Plot of Base Salary');

legend(ax_qq, ...
    'Observed quantiles', ...
    'Normal reference line', ...
    'Location', 'northwest');

grid(ax_qq, 'on');
ax_qq.GridAlpha = 0.15;

hold(ax_qq, 'off');

% the second figure is also saved at publication quality.
exportgraphics(fig_qq, ...
    fullfile(results_dir, 'part2_salary_qqplot.png'), ...
    'Resolution', 300);



% the two-sided critical values correspond to the central
% 95% and 75% areas of the standard normal distribution.
z_95 = sqrt(2) * erfinv(0.95);
z_75 = sqrt(2) * erfinv(0.75);

% the confidence interval margins account for the estimated
% sampling variability of the sample mean.
margin_95 = z_95 * standard_error;
margin_75 = z_75 * standard_error;

% both intervals are centered on the same observed sample mean.
ci_95 = [salary_mean - margin_95, ...
         salary_mean + margin_95];

ci_75 = [salary_mean - margin_75, ...
         salary_mean + margin_75];

fprintf('\nQUESTION 2: CONFIDENCE INTERVALS\n');

fprintf('95%% confidence interval: $%.2f to $%.2f\n', ...
    ci_95(1), ci_95(2));

fprintf('95%% margin of error: $%.2f\n', margin_95);

fprintf('\n75%% confidence interval: $%.2f to $%.2f\n', ...
    ci_75(1), ci_75(2));

fprintf('75%% margin of error: $%.2f\n', margin_75);


% the selected benchmark is illustrative rather than an externally
% verified average salary for the engineering population.
mu_0 = 130000;

% the significance level determines the rejection threshold
% for the statistical decision.
alpha = 0.05;

% the observed z-statistic measures the standardized difference
% between the sample mean and the hypothesized population mean.
z_stat = (salary_mean - mu_0) / standard_error;

% the complementary error function evaluates the two-sided
% standard normal tail probability without a statistics toolbox.
p_value = erfc(abs(z_stat) / sqrt(2));

% the null hypothesis is rejected when the p-value is below alpha.
reject_null = p_value < alpha;

fprintf('\nQUESTION 3: HYPOTHESIS TEST\n');

fprintf('Null hypothesis: mean salary = $%.2f\n', mu_0);
fprintf('Alternative: mean salary differs from $%.2f\n', mu_0);
fprintf('Observed sample mean: $%.2f\n', salary_mean);
fprintf('Z-statistic: %.4f\n', z_stat);
fprintf('Two-sided p-value: %.6g\n', p_value);
fprintf('Significance level: %.2f\n', alpha);

if reject_null
    fprintf('Decision: Reject the null hypothesis.\n');
else
    fprintf('Decision: Fail to reject the null hypothesis.\n');
end

fprintf('\nPart 2 analysis complete.\n');
