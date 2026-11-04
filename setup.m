%ENGS 93 Homework - Shared Env Setup
%Run this script before executing analysis

projectRoot = fileparts(mfilename('fullpath'));

addpath(fullfile(projectRoot, 'src'));

dataPath = fullfile(projectRoot, 'data', ...
    'Engineering_Salaries_2021_10000.csv');

resultsPath = fullfile(projectRoot, 'results', 'figures');

% Validate dataset
assert(isfile(dataPath), ...
    'Dataset missing. Add the CSV to the data folder.');


% results directory if needed
if ~isfolder(resultsPath)
    mkdir(resultsPath);
end

% dataset loading
data = readtable(dataPath);

% info display
fprintf('ENGS 93 Environment Ready\n');
fprintf('Observations: %d\n', height(data));
fprintf('Variables: %d\n', width(data));