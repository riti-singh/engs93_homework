%% ENGS 93 Homework - Part 3
% Source: Engineering_Salaries_2021_10000.csv, base_salary column.
% AI credit: ChatGPT helped with MATLAB syntax and code organization.
% From the project root, run: run('part3/part3.m')
% Keep part3/ and data/ together in the project root.

script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);
data_path = fullfile(project_root, 'data', 'Engineering_Salaries_2021_10000.csv');
data = readtable(data_path);
salary = data.base_salary;

%% Question 1: One-sided test and Type I error
% H0: mu <= 130000. Ha: mu > 130000.
% Calculate alpha at mu = 130000, the boundary of H0.
n = 50;
mu0 = 130000;
critical_mean = 144000;
s = std(salary);
se = s / sqrt(n);
z_critical = (critical_mean - mu0) / se;
normal_upper_tail = @(z) 0.5 * erfc(z / sqrt(2));
alpha = normal_upper_tail(z_critical);

fprintf('Planning SD: $%.2f\n', s);
fprintf('Standard error: $%.2f\n', se);
fprintf('Critical z: %.5f\n', z_critical);
fprintf('Type I error: %.6f (%.4f%%)\n\n', alpha, 100 * alpha);

%% Question 2: Plot the null distribution of the sample mean in MATLAB
% Under the normal approximation, sample means have mean mu0 and SD se.
% Simulate directly from that distribution for the histogram overlay.
previous_rng = rng;
rng(93, 'twister');
simulated_means = mu0 + se * randn(50000, 1);
rng(previous_rng);

x = linspace(mu0 - 8*se, mu0 + 8*se, 1000);
tail = linspace(critical_mean, x(end), 300);
null_pdf = @(value) exp(-0.5 * ((value - mu0) / se).^2) / (se * sqrt(2*pi));

fig = figure('Color', 'w', 'Position', [100 100 960 520]);
ax = axes(fig, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
hold(ax, 'on');
bars = histogram(ax, simulated_means, linspace(x(1), x(end), 65), ...
    'Normalization', 'pdf', 'FaceColor', [0.79, 0.86, 0.93], ...
    'FaceAlpha', 1, 'EdgeColor', 'w');
shade = fill(ax, [tail(1), tail, tail(end)], [0, null_pdf(tail), 0], ...
    [1, 0.72, 0.72], 'EdgeColor', 'none');
curve = plot(ax, x, null_pdf(x), 'Color', [0.11, 0.26, 0.45], 'LineWidth', 2);
y_top = 1.12 * max(null_pdf(mu0), max(bars.Values));
cutoff = plot(ax, [critical_mean critical_mean], [0 y_top], ...
    'Color', [0.77, 0.13, 0.15], 'LineWidth', 1.7);
xlim(ax, [x(1), x(end)]);
ylim(ax, [0, y_top]);
xticks(ax, 80000:20000:180000);
xticklabels(ax, {'$80k', '$100k', '$120k', '$140k', '$160k', '$180k'});
xlabel(ax, 'Sample mean base salary ($)');
ylabel(ax, 'Probability density');
title(ax, 'Null distribution of the sample mean (n = 50)', 'Color', 'k');
legend(ax, [bars, curve, cutoff, shade], ...
    {'Simulated sample means', 'Null density', 'Reject above $144,000', ...
     sprintf('Type I error = %.2f%%', 100 * alpha)}, ...
    'Location', 'northwest', 'Color', 'w', 'TextColor', 'k');
grid(ax, 'on');
hold(ax, 'off');

results_dir = fullfile(project_root, 'results', 'figures');
if ~isfolder(results_dir)
    mkdir(results_dir);
end
figure_path = fullfile(results_dir, 'part3_null_distribution.png');
exportgraphics(ax, figure_path, 'Resolution', 300, 'BackgroundColor', 'white');

%% Question 3: Compare power at mu = $150,000
mu1 = 150000;
d = (mu1 - mu0) / s;
normal_power = normal_upper_tail((critical_mean - mu1) / se);

% Use the noncentral t distribution for the one-sample t-test.
% For a positive t, the upper central-t tail is
% 0.5 * betainc(df/(df+t^2), df/2, 1/2).
df = n - 1;
beta_quantile = betaincinv(2 * alpha, df/2, 0.5);
t_critical = sqrt(df * (1 / beta_quantile - 1));
noncentrality = sqrt(n) * d;

% A noncentral t is (Z + noncentrality) / sqrt(V/df),
% with Z standard normal and V independent chi-square(df).
% Average the conditional upper tail over V. This uses base MATLAB.
chi_square_pdf = @(v) exp((df/2 - 1) .* log(v) - v/2 ...
    - (df/2) * log(2) - gammaln(df/2));
power_integrand = @(v) normal_upper_tail(t_critical .* sqrt(v/df) ...
    - noncentrality) .* chi_square_pdf(v);
t_power = integral(power_integrand, 0, Inf, 'AbsTol', 1e-10);

fprintf('Effect size d: %.6f\n', d);
fprintf('Fixed-cutoff normal power: %.2f%%\n', 100 * normal_power);
fprintf('One-sample t-test power: %.2f%%\n', 100 * t_power);
