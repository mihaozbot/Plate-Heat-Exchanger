clc;
clear;
close all;

% Directory containing the .mat files
dir_name = ''; % Adjust as necessary

% Get files matching the first pattern
files_steps = dir(fullfile(dir_name, '**', 'measurement_steps_*.mat'));

% Get files matching the second pattern
files_FRLS = dir(fullfile(dir_name, '**', 'measurement_FRLS_*.mat'));

% Combine both file lists
files = [files_steps; files_FRLS];

% Initialize a cell array to store the steady-state means for each file
steady_state_data = {};

if 1
    % Loop through each file
    for i = 1:length(files)
        % Construct the full file path
        filename = fullfile(files(i).folder, files(i).name);

        % Load the file
        data = load(filename);

        % Verify presence of 'u' and 'x'
        if isfield(data, 'u') && isfield(data, 'x')
            u_data = data.u(2:end); % Assume first sample might be initialization and skip it
            x_data = data.x(2:end, 2); % Focus on the second output signal x(2)

            % **Remove zero input values**
            non_zero_indices = u_data ~= 0;
            u_data = u_data(non_zero_indices);  % Keep only non-zero inputs
            x_data = x_data(non_zero_indices);  % Adjust corresponding outputs

            % Check if scaling parameters are present in the data
            if isfield(data, 'u_max') && isfield(data, 'u_min') && ...
                    isfield(data, 'uu_max') && isfield(data, 'uu_min')

                % Extract scaling parameters
                u_max = data.u_max;
                u_min = data.u_min;
                uu_max = data.uu_max;
                uu_min = data.uu_min;

                % Rescale the u_data to the new range (uu_min to uu_max)
                u_data = (u_data - u_min) / (u_max - u_min) * (uu_max - uu_min) + uu_min;

                % Display a message indicating rescaling was applied
                fprintf('Rescaling applied to file: %s\n', filename);
            end

            % Find steps in u_data (changes in the value)
            steps = find(diff(u_data) ~= 0);
            steps = [1; steps+1; length(u_data)+1]; % Include the first index and end index

            % Prepare to collect averages and variance data
            u_averages = [];
            y_averages = [];

            % Dictionary to collect y values by unique u values
            u_to_y_vals = containers.Map('KeyType', 'double', 'ValueType', 'any');

            % Set the rounding precision
            precision = 1e-2; % Rounds to two decimal places

            % Loop over each step, except the last index which is just an end marker
            for j = 1:length(steps)-1
                % Determine the current step indices
                current_step_indices = steps(j):steps(j+1)-1;

                % Compute indices for the second half of the current step
                half_step_index = floor(length(current_step_indices)/2);
                second_half_indices = current_step_indices(half_step_index+1:end);

                % Compute the average of y for the second half of the current step
                if ~isempty(second_half_indices)
                    % Compute averages and round to avoid precision issues
                    u_avg = round(mean(u_data(second_half_indices)) / precision) * precision;

                    % Skip if u_avg is zero
                    if u_avg == 0
                        continue;
                    end

                    y_avg = mean(x_data(second_half_indices));

                    % Store results
                    u_averages = [u_averages, u_avg];
                    y_averages = [y_averages, y_avg];

                    % Aggregate y values by rounded u_avg
                    if isKey(u_to_y_vals, u_avg)
                        u_to_y_vals(u_avg) = [u_to_y_vals(u_avg), y_avg];
                    else
                        u_to_y_vals(u_avg) = [y_avg];
                    end
                end
            end

            % Calculate mean and variance for each unique u value
            means = [];
            variances = [];
            unique_u_averages = cell2mat(keys(u_to_y_vals));  % Convert keys (u values) to an array

            for k = 1:length(unique_u_averages)
                y_vals = u_to_y_vals(unique_u_averages(k));  % Get all y values for this unique u
                mean_val = mean(y_vals);  % Calculate mean for this unique u
                variance_val = var(y_vals);  % Calculate variance for this unique u
                means = [means, mean_val];
                variances = [variances, variance_val];
            end

            % Store the steady-state data for later use, using the means for unique u values
            steady_state_data{i}.filename = files(i).name;
            steady_state_data{i}.u_averages = unique_u_averages;  % Store unique u values
            steady_state_data{i}.y_averages = means;  % Store the means for the corresponding y values
            steady_state_data{i}.variances = variances;  % Store the variances for the corresponding y values

            % Debugging: print out the contents of the map to verify
            disp('Contents of u_to_y_vals after rounding:');
            for key_idx = 1:length(unique_u_averages)
                disp(['u = ', num2str(unique_u_averages(key_idx)), ': y values = ', mat2str(u_to_y_vals(unique_u_averages(key_idx)))]);
            end

        else
            warning(['Variables u or x not found in ', filename]);
        end
    end

    save('steady_state_data.mat', 'steady_state_data');
end

load('steady_state_data.mat');

% Define the reference files
reference_files = {
    'measurement_steps_all_2022_06_11_17_30_NORMAL.mat', ... % Staircase
    'measurement_steps_all_2022_06_16_21_40_PRBS.mat', ... % PRBS
    ['measurement_FRLS_all_2022_02_21_14_55.mat'] % DoE
};
%['measurement_FRLS_all_2022_02_20_02_02.mat'] % DoE

% Initialize a struct to store the best matches
best_matches = struct();

% Loop through each reference file
for r = 1:length(reference_files)
    reference_filename = reference_files{r};

    % Find the reference steady-state data
    reference_data = [];
    for i = 1:length(steady_state_data)
        if contains(steady_state_data{i}.filename, reference_filename)
            reference_data = steady_state_data{i};

            % **Special case for the FRLS dataset**: Remove the first input/output
            if contains(reference_filename, 'FRLS.mat')
                reference_data.u_averages = reference_data.u_averages(2:end);
                reference_data.y_averages = reference_data.y_averages(2:end);
            end
            break;
        end
    end

    % Check if reference data was found
    if isempty(reference_data)
        error(['Reference file steady-state data not found: ', reference_filename]);
    end

    % Initialize variables for tracking the best match
    best_match_filename = '';
    smallest_error = inf;
    best_u_averages = [];
    best_y_averages = [];

    for i = 1:length(steady_state_data)
        % Check the full path of the file using the 'files' array
        file_path = fullfile(files(i).folder, files(i).name);

        % Ensure we're only checking files inside the "Staircase_up" directory
        if ~contains(file_path, 'Staircase_up')
            continue;
        end

        % Get the steady-state data of the current file
        u_averages = steady_state_data{i}.u_averages;
        y_averages = steady_state_data{i}.y_averages;

        % **Filter condition**: Only include signals where the maximum input u_averages > 1.7
        %if all(u_averages <= 1.7)
        %    continue;
        %end

        % Find the minimum length for comparison (truncate or interpolate)
        min_length = min(length(reference_data.u_averages), length(u_averages));

        % If lengths are not the same, truncate or interpolate the longer one
        if length(reference_data.u_averages) > min_length
            ref_u_averages = reference_data.u_averages(1:min_length);
            ref_y_averages = reference_data.y_averages(1:min_length);
        else
            ref_u_averages = interp1(1:length(reference_data.u_averages), reference_data.u_averages, linspace(1, length(reference_data.u_averages), min_length));
            ref_y_averages = interp1(1:length(reference_data.y_averages), reference_data.y_averages, linspace(1, length(reference_data.y_averages), min_length));
        end

        if length(u_averages) > min_length
            u_averages = u_averages(1:min_length);
            y_averages = y_averages(1:min_length);
        else
            u_averages = interp1(1:length(u_averages), u_averages, linspace(1, length(u_averages), min_length));
            y_averages = interp1(1:length(y_averages), y_averages, linspace(1, length(y_averages), min_length));
        end

        % Compute the Mean Squared Error (MSE) for both input (u) and output (y)
        mse_u = mean((ref_u_averages - u_averages).^2);
        mse_y = mean((ref_y_averages - y_averages).^2);
        total_error = mse_u + mse_y;

        % Update the best match if the current file has a smaller error
        if total_error < smallest_error
            smallest_error = total_error;
            best_match_filename = steady_state_data{i}.filename;
            best_u_averages = u_averages;
            best_y_averages = y_averages;
        end
    end

    % Store the best match for this reference file
    best_matches(r).reference_filename = reference_filename;
    best_matches(r).best_match_filename = best_match_filename;
    best_matches(r).smallest_error = smallest_error;
    best_matches(r).best_u_averages = best_u_averages;
    best_matches(r).best_y_averages = best_y_averages;

    % Display the best match result
    if ~isempty(best_match_filename)
        fprintf('Best match for %s found: %s\n', reference_filename, best_match_filename);
        fprintf('Smallest error: %.4f\n', smallest_error);
    else
        fprintf('No suitable match found for %s.\n', reference_filename);
    end
end

% Visualize the best match for each reference file
for r = 1:length(best_matches)
    % Find the correct reference data for this plot
    reference_filename = best_matches(r).reference_filename;
    
    % Find the corresponding reference data again for plotting
    reference_data = [];
    for i = 1:length(steady_state_data)
        if contains(steady_state_data{i}.filename, reference_filename)
            reference_data = steady_state_data{i};  % This contains the steady-state averages
            break;
        end
    end
    
    % Determine the shortened dataset name for the title
    if contains(reference_filename, 'NORMAL')
        dataset_name = 'STAIRCASE';
    elseif contains(reference_filename, 'PRBS')
        dataset_name = 'PRBS';
    elseif contains(reference_filename, 'FRLS')
        dataset_name = 'DOE';
    else
        dataset_name = 'UNKNOWN';  % Fallback for any other datasets
    end
    
    % Ensure we have valid reference data before plotting
    if ~isempty(reference_data) && ~isempty(best_matches(r).best_match_filename)
        figure;
        
        % Replace underscores with spaces for better readability in the legend
        formatted_reference_name = strrep(reference_filename, '_', ' ');
        formatted_best_match_name = strrep(best_matches(r).best_match_filename, '_', ' ');
        
        % Plot the steady-state points for the reference data (connect dots for clarity)
        plot(reference_data.u_averages, reference_data.y_averages, 'b-o', 'LineWidth', 1.5, 'DisplayName', formatted_reference_name);
        hold on;
        
        % Plot the actual steady-state points for the best match data (without interpolation)
        plot(best_matches(r).best_u_averages, best_matches(r).best_y_averages, 'r-o', 'LineWidth', 1.5, 'DisplayName', formatted_best_match_name);
        
        % Retrieve the raw signal data for the reference file (not the steady-state data)
        reference_file_index = find(strcmp({files.name}, reference_filename));
        raw_reference_data = load(fullfile(files(reference_file_index).folder, files(reference_file_index).name));
        
        % Plot the original unconnected raw samples from the reference file in light blue
        if isfield(raw_reference_data, 'u') && isfield(raw_reference_data, 'x')
            u_raw_ref = raw_reference_data.u(2:end);  % Skipping first sample
            y_raw_ref = raw_reference_data.x(2:end, 2);  % Assuming x(2) is the signal of interest
            
            %scatter(u_raw_ref, y_raw_ref, 50, 'c.', 'DisplayName', 'Reference Raw Samples');
        end
        
        % Retrieve the raw signal data for the best match (not the steady-state data)
        best_match_file_index = find(strcmp({files.name}, best_matches(r).best_match_filename));
        raw_best_match_data = load(fullfile(files(best_match_file_index).folder, files(best_match_file_index).name));
        
        % Plot the original unconnected raw samples from the best match in green
        if isfield(raw_best_match_data, 'u') && isfield(raw_best_match_data, 'x')
            u_raw = raw_best_match_data.u(2:end);  % Skipping first sample
            y_raw = raw_best_match_data.x(2:end, 2);  % Assuming x(2) is the signal of interest
            
            scatter(u_raw, y_raw, 50, 'g', 'DisplayName', 'Best Match Raw Samples');
        end
        
        xlabel('Steady-State Input $u$', 'Interpreter', 'latex');
        ylabel('Steady-State Output $y$', 'Interpreter', 'latex');
        
        % Format the title with the shortened dataset name (STAIRCASE, PRBS, DOE)
        title(['Steady-State Comparison for ', dataset_name], 'Interpreter', 'latex');
        
        % Show the legend with full dataset names
        legend('show', 'Location', 'best');
        grid on;
    else
        fprintf('No valid reference or match found for %s.\n', reference_filename);
    end
end
