clc;          % Clear the command window
clear;        % Clear all variables
close all;    % Close all figure windows

% Get a list of all .mat files in the current folder that match the pattern
dir_name = '';
files = dir([dir_name, 'measurement_steps_all*.mat']);

% Initialize cell arrays to hold categorized filenames
fault_files = {};
normal_files = {};
prbs_files = {};

% Categorize files based on their suffix
for i = 1:length(files)
    filename = files(i).name;
    if contains(filename, '_FAULT')
        fault_files{end+1} = [dir_name, filename];
    elseif contains(filename, '_NORMAL')
        normal_files{end+1} = [dir_name, filename];
    elseif contains(filename, '_PRBS')
        prbs_files{end+1} = [dir_name, filename];
    end
end

% Plot data for each category
plot_data(fault_files, 'FAULT');
plot_data(normal_files, 'NORMAL');
plot_data(prbs_files, 'PRBS');

% Function to plot data
function plot_data(file_list, category)
    for i = 1:length(file_list)
        % Load the current file
        filename = file_list{i};
        data = load(filename);

        % Extract parts of the filename for the title
        [~, name, ~] = fileparts(filename);
        base_index = strfind(name, 'measurement_steps_all');
        
        if ~isempty(base_index)
            % Find the part after 'measurement_steps_all_'
            remaining_name = name(base_index + length('measurement_steps_all') + 1:end);
            underscores = strfind(remaining_name, '_'); % Find all underscores in the remaining part

            if length(underscores) >= 2
                % Extract date and suffix from the filename
                date_part = remaining_name(1:underscores(1)-1); % Date is before the first underscore
                title_suffix = remaining_name(underscores(1)+1:end); % Suffix is after the first underscore
            else
                date_part = 'Unknown Date'; % Fallback if underscores are missing or not in expected places
                title_suffix = remaining_name;
            end
        else
            date_part = 'Unknown Date'; % Fallback if 'measurement_steps_all' is not found
            title_suffix = name;
        end

        % Replace underscores with spaces in the title parts
        date_part = strrep(date_part, '_', ' ');
        title_suffix = strrep(title_suffix, '_', ' ');

        % Check if variables 'u' and 'x' exist in the loaded data
        if isfield(data, 'u') && isfield(data, 'x')
            % Create a new figure for each file
            figure;
            
            % Subplot for 'u'
            subplot(2, 1, 1);
            plot(data.u);
            title('Input Signal');  % Set subplot title for 'u'
            xlabel('Index');
            ylabel('u');
            
            % Subplot for 'x'
            subplot(2, 1, 2);
            plot(data.x);
            title('State Signals');  % Set subplot title for 'x'
            xlabel('Index');
            ylabel('x');
            
            % Add legend for 'x' subplot
            legend({'Hot Water Reservoir', 'System Output'}, 'Location', 'best');
            
            % Add a main title for the figure
            sgtitle([category, ' - ', date_part, ' - ', title_suffix]);
        else
            % Display a warning if 'u' or 'x' is missing in the current file
            warning(['Variables u or x not found in ', filename]);
        end
    end
end
