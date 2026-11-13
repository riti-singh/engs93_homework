
%% ENGS 93 Homework - Part 2
% Confidence Intervals and Hypothesis Testing
% Dataset: Engineering Salaries 2021
%
% This analysis applies statistical inference to the annual base
% salaries reported in the engineering salaries dataset.
%
% Question 1 examines Normality and the adequacy of the sample size.
% Question 2 constructs 95% and 75% confidence intervals.
% Question 3 evaluates a hypothesis about the population mean salary.
% Optional Question 4 compares the large-sample z-test with a t-test.

clear;
clc;
close all;


%% Data Preparation
%
% We continue using annual base salary as the selected continuous
% variable so that the results are consistent with Part 1.
%
% The sample mean and standard deviation provide the foundation for
% the confidence intervals and hypothesis test that follow.


% the script location is used to locate the shared dataset.
script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);

data_path = fullfile(project_root, 'data', ...
    'Engineering_Salaries_2021_10000.csv');

% the analysis cannot proceed without the source data.
assert(isfile(data_path), ...
    'The salary dataset was not found in the data directory.');

% readtable imports the csv file and preserves column headers.
data = readtable(data_path);

% annual base salary is the variable of interest in this analysis.
salary = data.base_salary;

% non-finite salary observations would invalidate the statistical
% calculations, so they are excluded before proceeding.
salary = salary(isfinite(salary));
salary = salary(:);

% the sample statistics are reused throughout the assignment.
n = length(salary);
salary_mean = mean(salary);
salary_std = std(salary);

% the standard error describes the estimated variability of the
% sample mean under repeated sampling.
standard_error = salary_std / sqrt(n);

fprintf('Part 2: Statistical Inference\n');
fprintf('Sample size: %d\n', n);
fprintf('Sample mean: $%.2f\n', salary_mean);
fprintf('Sample standard deviation: $%.2f\n', salary_std);
fprintf('Standard error: $%.2f\n', standard_error);


%% Question 1: Normality and the Sample Size
%
% We examine whether annual base salary is approximately Normally
% distributed using two graphical methods: a normalized histogram
% with a fitted Normal density curve and a Normal Q-Q plot.
%
% The histogram compares the empirical distribution with the shape
% expected under Normality. The Q-Q plot compares observed salary
% quantiles with theoretical Normal quantiles.
%
% If the data were approximately Normally distributed, the histogram
% would be relatively symmetric and bell-shaped, and the Q-Q plot
% points would follow a straight reference line.


%% Question 1: Histogram with Normal Density
%
% The histogram is normalized as a probability density, allowing
% it to be compared directly with the fitted Normal distribution.
%
% The Normal curve uses the observed sample mean and standard
% deviation rather than assuming predetermined parameters.


% a finely spaced vector produces a smooth theoretical density.
x = linspace(min(salary), max(salary), 1000);

% the density formula represents a normal distribution with
% mean equal to salary_mean and standard deviation salary_std.
normal_pdf = (1 / (salary_std * sqrt(2*pi))) .* ...
    exp(-0.5 * ((x - salary_mean) ./ salary_std).^2);

% the first figure compares the empirical salary distribution
% against the normal approximation.
fig_hist = figure('Color', 'w');

histogram(salary, 40, ...
    'Normalization', 'pdf', ...
    'FaceAlpha', 0.6);

hold on;

plot(x, normal_pdf, 'r-', 'LineWidth', 2);

xlabel('Base salary ($)');
ylabel('Probability density');
title('Figure 1. Base Salary Distribution and Normal Density');

legend('Observed salary distribution', ...
    'Fitted Normal distribution', ...
    'Location', 'best');

grid on;
hold off;


%% Question 1: Normal Q-Q Plot
%
% The Normal Q-Q plot offers a complementary view of the salary
% distribution by comparing observed and theoretical quantiles.
%
% A straight-line pattern would support approximate Normality.
% Systematic curvature or departures from the reference line,
% particularly in the upper and lower tails, suggest that the
% observed distribution differs from the Normal model.


% salary values are ordered before comparison with the
% theoretical quantiles of the fitted normal distribution.
sorted_salary = sort(salary);

% plotting probabilities assign a cumulative position to each
% ordered observation without using values of exactly zero or one.
probabilities = ((1:n)' - 0.5) / n;

% the inverse error function gives normal quantiles without
% relying on the statistics and machine learning toolbox.
theoretical_quantiles = salary_mean + salary_std * ...
    sqrt(2) .* erfinv(2 * probabilities - 1);

% each point compares one observed salary quantile with its
% theoretical counterpart under the normal approximation.
fig_qq = figure('Color', 'w');

plot(theoretical_quantiles, sorted_salary, '.', ...
    'MarkerSize', 6);

hold on;

% the diagonal is the expected relationship when observed
% quantiles match the fitted theoretical normal quantiles.
reference_min = min(theoretical_quantiles);
reference_max = max(theoretical_quantiles);

plot([reference_min reference_max], ...
    [reference_min reference_max], ...
    'r-', 'LineWidth', 2);

xlabel('Theoretical Normal quantiles ($)');
ylabel('Observed salary quantiles ($)');
title('Figure 2. Normal Q-Q Plot of Base Salary');

legend('Observed quantiles', ...
    'Normal reference line', ...
    'Location', 'best');

grid on;
hold off;


%% Question 1: Interpretation
%
% The sample contains 10,000 salary observations. The histogram
% indicates that annual base salary is positively skewed, with
% a longer right tail caused by relatively high salary values.
%
% The observed distribution is therefore not perfectly symmetric
% or bell-shaped. The Q-Q plot also exhibits systematic deviations
% from the Normal reference line, particularly in the tails,
% supporting the conclusion that individual salaries are not
% approximately Normally distributed across their full range.
%
% Nevertheless, the sample size is sufficiently large for the
% Central Limit Theorem to be relevant. Under appropriate
% independence and finite-variance assumptions, the sampling
% distribution of the mean approaches a Normal distribution
% as the sample size increases.
%
% Consequently, a large-sample z approximation can reasonably be
% used for confidence intervals and hypothesis tests about the mean,
% even though individual salary observations are not Normally
% distributed.
%
% This conclusion assumes that the observations are sufficiently
% independent and that the sample reasonably represents the
% population of interest. A large sample does not correct for
% systematic selection bias or dependence among observations.


%% Question 2: Confidence Intervals for the Mean
%
% We construct both a 95% and a 75% confidence interval for the
% population mean engineering base salary.
%
% The confidence interval is calculated as the sample mean plus
% or minus a critical z-value multiplied by the standard error.
%
% Because the population standard deviation is unknown, we use
% the sample standard deviation as an estimate. The large sample
% size supports the use of this Normal approximation.
%
% The two intervals illustrate the relationship between confidence
% level and precision. A higher confidence level requires a wider
% interval, assuming the same sample and estimator.


% the inverse error function yields the two-sided critical
% normal values for the selected confidence levels.
z_95 = sqrt(2) * erfinv(0.95);
z_75 = sqrt(2) * erfinv(0.75);

% each margin of error depends on the selected confidence
% level and the standard error of the sample mean.
margin_95 = z_95 * standard_error;
margin_75 = z_75 * standard_error;

% the interval endpoints are centered on the same sample mean.
ci_95 = [salary_mean - margin_95, ...
         salary_mean + margin_95];

ci_75 = [salary_mean - margin_75, ...
         salary_mean + margin_75];

fprintf('\nQuestion 2: Confidence Intervals\n');

fprintf('\n95%% confidence interval:\n');
fprintf('  lower bound: $%.2f\n', ci_95(1));
fprintf('  upper bound: $%.2f\n', ci_95(2));
fprintf('  margin of error: $%.2f\n', margin_95);

fprintf('\n75%% confidence interval:\n');
fprintf('  lower bound: $%.2f\n', ci_75(1));
fprintf('  upper bound: $%.2f\n', ci_75(2));
fprintf('  margin of error: $%.2f\n', margin_75);


%% Question 2: Interpretation
%
% The 95% confidence interval for the population mean base salary
% extends from approximately $134,394.59 to $136,753.81.
%
% The 75% confidence interval extends from approximately
% $134,881.86 to $136,266.54.
%
% Both intervals are centered on the sample mean of $135,574.20.
% The 95% interval is wider because higher confidence requires
% a larger margin of error.
%
% These confidence intervals estimate the population mean rather
% than the values of individual engineering salaries.
%
% Under repeated sampling, the procedure used to construct a 95%
% confidence interval would contain the true population mean
% approximately 95% of the time. Similarly, the 75% interval
% procedure would contain the true mean approximately 75% of
% the time, assuming the statistical conditions are satisfied.
%
% The relatively narrow intervals reflect the precision associated
% with the large sample size. However, this precision does not
% eliminate potential bias in the dataset or guarantee that the
% findings generalize to all engineering professionals.


%% Question 3: Hypothesis Test for the Population Mean
%
% We test whether the population mean engineering base salary
% differs from a selected reference value of $130,000.
%
% This is a two-sided hypothesis test because we are interested
% in deviations both above and below the hypothesized mean.
%
% The null hypothesis is H0: mu = $130,000.
% The alternative hypothesis is HA: mu ~= $130,000.
%
% We use a significance level of alpha = 0.05.
%
% The value of $130,000 is an illustrative benchmark selected
% for this exercise, rather than a verified external population
% average.
%
% We use a large-sample z-statistic based on the sample mean,
% hypothesized population mean, and estimated standard error.


% the hypothesized mean provides the reference value against
% which the observed sample mean is tested.
mu_0 = 130000;

% alpha sets the maximum type i error probability for the
% decision rule under the usual testing assumptions.
alpha = 0.05;

% the z-statistic measures the observed difference from the
% null mean in units of the estimated standard error.
z_stat = (salary_mean - mu_0) / standard_error;

% for a two-sided test, both extreme positive and negative
% deviations contribute to the p-value.
%
% the complementary error function provides a stable calculation
% of the two-sided normal tail probability.
p_value = erfc(abs(z_stat) / sqrt(2));

% a p-value below alpha leads to rejection of the null hypothesis.
reject_null = p_value < alpha;

fprintf('\nQuestion 3: Hypothesis Test\n');

fprintf('Null mean: $%.2f\n', mu_0);
fprintf('Sample mean: $%.2f\n', salary_mean);
fprintf('Z-statistic: %.4f\n', z_stat);
fprintf('Two-sided p-value: %.6g\n', p_value);
fprintf('Significance level: %.2f\n', alpha);

if reject_null
    fprintf('Decision: Reject the null hypothesis.\n');
else
    fprintf('Decision: Fail to reject the null hypothesis.\n');
end


%% Question 3: Interpretation
%
% The observed z-statistic is approximately 9.2617, with a
% two-sided p-value of approximately 2.01 x 10^(-20).
%
% Since the p-value is much smaller than the significance
% level of 0.05, we reject the null hypothesis that the
% population mean engineering base salary equals $130,000.
%
% The observed sample mean of $135,574.20 is higher than
% the hypothesized value by $5,574.20.
%
% Under the assumptions of the test, the results provide
% strong statistical evidence that the population mean
% differs from $130,000.
%
% However, statistical significance does not necessarily
% imply practical significance. With a sample containing
% 10,000 observations, even a difference that is relatively
% modest compared with the overall salary variability can
% produce a very small p-value.
%
% The interpretation also depends on the representativeness
% and independence of the salary observations. The hypothesis
% test does not establish that the mean of every engineering
% population differs from the selected benchmark.


%% Optional Question 4: One-Sample T-Test Comparison
%
% The assignment also offers an optional comparison between the
% manually calculated z-test and a one-sample t-test.
%
% The t-test is appropriate when the population standard deviation
% is unknown and the sample standard deviation is used to estimate
% the standard error.
%
% The t-statistic has the same numerical form as the large-sample
% z-statistic in this example, but it is evaluated using a
% t-distribution with n-1 degrees of freedom.
%
% For a sample of this size, the t-distribution is extremely close
% to the standard Normal distribution. We therefore expect both
% tests to produce similar p-values and the same hypothesis decision.


% the optional comparison requires matlab's statistics and
% machine learning toolbox, which provides the ttest function.
if exist('ttest', 'file') == 2

    % the t-test uses the same null mean and significance level
    % as the large-sample z-test above.
    [h_t, p_t, ci_t, stats_t] = ttest(salary, mu_0, ...
        'Alpha', alpha, 'Tail', 'both');

    fprintf('\nOptional Question 4: T-Test Comparison\n');

    fprintf('T-statistic: %.4f\n', stats_t.tstat);
    fprintf('Degrees of freedom: %d\n', stats_t.df);
    fprintf('T-test p-value: %.6g\n', p_t);

    fprintf('95%% t confidence interval: [$%.2f, $%.2f]\n', ...
        ci_t(1), ci_t(2));

    if h_t == 1
        fprintf('T-test decision: Reject H0.\n');
    else
        fprintf('T-test decision: Fail to reject H0.\n');
    end

    fprintf('\nT-Test Interpretation:\n');
    fprintf(['The t-statistic and z-statistic are numerically ' ...
        'identical here because both use the same estimated ' ...
        'standard error. Their p-values differ slightly because ' ...
        'the reference distributions are different. With %d ' ...
        'observations, the tests lead to the same decision.\n'], n);

else

    % the required questions remain complete even without the
    % optional statistics toolbox functionality.
    fprintf('\nOptional t-test not run: toolbox unavailable.\n');

end


%% Figure Export
%
% The histogram and Q-Q plot are saved to the shared results
% directory so that they can be included in the final report.


% the shared figure directory is located relative to the script.
results_dir = fullfile(project_root, 'results', 'figures');

if ~isfolder(results_dir)
    mkdir(results_dir);
end

% figure handles ensure that the correct plots are exported,
% even if additional figures are created during analysis.
saveas(fig_hist, ...
    fullfile(results_dir, 'part2_salary_histogram.png'));

saveas(fig_qq, ...
    fullfile(results_dir, 'part2_salary_qqplot.png'));


%% Part 2: Conclusion
%
% Part 2 applied statistical inference to annual base salaries
% in the Engineering Salaries 2021 dataset.
%
% Although individual salary observations are positively skewed
% and not Normally distributed across their full range, the
% large sample size supports approximate Normal inference
% about the population mean under suitable assumptions.
%
% The confidence intervals estimate the population mean with
% different levels of confidence, illustrating the tradeoff
% between interval width and confidence level.
%
% The hypothesis test provides strong statistical evidence
% that the population mean differs from the selected
% benchmark of $130,000.
%
% These findings demonstrate how descriptive statistics,
% sampling distributions, and statistical inference can be
% combined to investigate an engineering dataset.

fprintf('\nPart 2 analysis complete.\n');
