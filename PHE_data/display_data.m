clc;          % Clear the command window
clear;        % Clear all variables
close all;    % Close all figure windows

% Get a list of all .mat files in the current folder and all subfolders
dir_name = ''; % Start from the current directory
files = dir(fullfile(dir_name, '**', 'measurement_steps_*.mat')); % Recursive search

% Loop through each file and plot data
for i = 1:length(files)
    % Construct the full file path
    filename = fullfile(files(i).folder, files(i).name);
    
    % Load the current file
    data = load(filename);

    % Extract parts of the filename for the title
    [~, name, ~] = fileparts(filename);

    % Replace underscores with spaces in the title parts
    title_name = strrep(name, '_', ' ');

    % Check if variables 'u' and 'x' exist in the loaded data
    if isfield(data, 'u') && isfield(data, 'x')
        % Remove the first sample from 'u' and 'x'
        u_data = data.u(2:end);
        x_data = data.x(2:end,:);

        % Create a new figure for each file
        figure;
        
        % Subplot for 'u'
        subplot(2, 1, 1);
        plot(u_data);
        title('Input Signal');  % Set subplot title for 'u'
        xlabel('Index');
        ylabel('u');
        
        % Subplot for 'x'
        subplot(2, 1, 2);
        plot(x_data);
        title('State Signals');  % Set subplot title for 'x'
        xlabel('Index');
        ylabel('x');
        
        % Add legend for 'x' subplot
        legend({'Hot Water Reservoir', 'System Output'}, 'Location', 'best');
        
        % Add a main title for the figure
        sgtitle(title_name);
    else
        % Display a warning if 'u' or 'x' is missing in the current file
        warning(['Variables u or x not found in ', filename]);
    end
end
