%% ENGS 93 Homework Part 4
% Independent variable 1: years_of_experience
% Independent variable 2: base_salary
% Dependent variable    : total_annual_compensation
%
% Gemini helped with regression syntax

%% Reset
clc;
close all;

%% Question 1
% Select a continuous variable from your data whose value you would like to use as a dependent
% variable. Does your dependent variable appear to be normally distributed? If not, can you think of a
% transformation that would help you see the relationship between the dependent and independent variable
% better? In either case, apply a transformation of your choice to the dependent variable and describe its
% distribution.
%
% It does not look normal. The bulk of the values are on the left side. I
% will try a log transformation to try to normalize it.
%
% That looks much closer to a normal distribution.

annual_comp = data.total_annual_compensation;
annual_comp_transformed = log(annual_comp);

figure;
tiledlayout(1,2);

nexttile;
histogram(annual_comp);
title('Annual Compensation');
xlabel('Total Annual Compensation');
ylabel('Frequency');

nexttile;
histogram(annual_comp_transformed);
title('Transformed Annual Compensation');
xlabel('log(Compensation)');
ylabel('Frequency');

%% Question 2
% Create scatterplots between your dependent variable and both independent variables. Then do
% the same for your transformed dependent variable and each independent variable. Calculate the correlations
% for each plot. What conclusions do you draw about each of these plotted relationships? Are there any outliers?
% Which (if any) relationships appear to be approximately linear? Which relationships appear to be stronger, and
% which weaker? Do you see any potential issues with applying linear regression to any of these relationships?
%
% It looks the total annual comp vs base salary untransformed and transformed plots appear to be approximately
% linear ish. The other relationships don't look significant. And the correlation coefficient is highest for
% the annual comp transformed vs base salary plot, though the untransformed
% one is a close second. I think the untransformed one is more linear as
% the log one looks curved and like the best fit would not be a straight
% line.

yearsExperience = data.years_of_experience;
baseSalary = data.base_salary;

figure;
tiledlayout(2,2);

nexttile;
scatter(yearsExperience, annual_comp);
xlabel('Years of Experience');
ylabel('Total Annual Compensation');
title('Compensation vs. Experience');

R = corrcoef(yearsExperience, annual_comp);
correlation_value = R(1,2);
fprintf("Correlation yearsExperience vs annual_comp: %.3f\n", correlation_value);

nexttile;
scatter(baseSalary, annual_comp);
xlabel('Base Salary');
ylabel('Total Annual Compensation');
title('Compensation vs. Base Salary');

R = corrcoef(baseSalary, annual_comp);
correlation_value = R(1,2);
fprintf("Correlation baseSalary vs annual_comp: %.3f\n", correlation_value);

nexttile;
scatter(yearsExperience, annual_comp_transformed);
xlabel('Years of Experience');
ylabel('Squared Compensation');
title('Transformed Compensation vs. Experience');

R = corrcoef(yearsExperience, annual_comp_transformed);
correlation_value = R(1,2);
fprintf("Correlation yearsExperience vs annual_comp_transformed: %.3f\n", correlation_value);

nexttile;
scatter(baseSalary, annual_comp_transformed);
xlabel('Base Salary');
ylabel('Squared Compensation');
title('Transformed Compensation vs. Base Salary');

R = corrcoef(baseSalary, annual_comp_transformed);
correlation_value = R(1,2);
fprintf("Correlation baseSalary vs annual_comp_transformed: %.3f\n", correlation_value);

%% Question 3
% Chose either your transformed or untransformed dependent variable (based on which fits the
% assumptions of linear regression better), and one of your independent variables, and fit a regression line. What
% is the estimated slope and intercept? Choose a particular value of your independent variable and predict the
% value of the dependent variable value (in its original units!) for that independent variable value. Next, put the
% results of your regression model in an object called model1.lm. Plot the relationship between your chosen
% dependent and independent variable, and add your fitted line to the plot.
%
% It looks like a good fit for the low end. At some point the data does
% stay linear but it looks like the slope gets smaller. But there are far
% fewer data points past there, so I don't think the fit in that range is
% super reliable anyway.

p = polyfit(baseSalary, annual_comp, 1);

slopeBaseSalary = p(1);
interceptBaseSalary = p(2);

% Predict for the mean base salary
chosenBaseSalary = mean(baseSalary);
predictedCompensationBaseSalary = polyval(p, chosenBaseSalary);

fprintf("Slope: %d\n", slopeBaseSalary);
fprintf("Intercept: %d\n", interceptBaseSalary);


chosen_ind = 150000;
fprintf("Chosen value: %d baseSalary\n", chosen_ind);
fprintf("Predicted dependent value: %.0f totalComp\n", slopeBaseSalary * chosen_ind + interceptBaseSalary);

% Generate points for a line of best fit
baseSalaryFit = linspace(min(baseSalary), max(baseSalary), 100)';
compensationFit = polyval(p, baseSalaryFit);

figure;
scatter(baseSalary, annual_comp, 'filled');
hold on;
plot(baseSalaryFit, compensationFit, 'r-', 'LineWidth', 2);
xlabel('Base Salary');
ylabel('Total Annual Compensation');
title('Total Compensation vs. Base Salary');
legend('Data', 'Regression line', 'Location', 'best');
grid on;

ax = gca;
ax.XAxis.Exponent = 0;
xtickformat('%.0f')
ax.YAxis.Exponent = 0;
ytickformat('%.0f')