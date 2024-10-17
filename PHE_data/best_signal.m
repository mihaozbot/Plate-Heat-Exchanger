% Initialize a cell array to store the steady-state means for each file
steady_state_data = {};

% Loop through each file
for i = 1:length(files)
    % Construct the full file path
    filename = fullfile(files(i).folder, files(i).name);

    % Load the file
    data = load(filename);

    % Verify presence of 'u' and 'x'
    if isfield(data, 'u') && isfield(data, 'x')
        u_data = data.u(2:end); % Skip the first sample
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
        steady_state_indices = [];  % **Store indices used in steady-state calculations**

        % Dictionary to collect y values by unique u values
        u_to_y_vals = containers.Map('KeyType', 'double', 'ValueType', 'any');

        % Set the rounding precision
        precision = 1e-2; % Rounds to two decimal places

        % Loop over each step
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

                % Store indices used for steady-state calculations
                steady_state_indices = [steady_state_indices; second_half_indices'];

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

        % Store the steady-state data for later use, including indices
        steady_state_data{i}.filename = files(i).name;
        steady_state_data{i}.u_averages = unique_u_averages;  % Store unique u values
        steady_state_data{i}.y_averages = means;  % Store the means for the corresponding y values
        steady_state_data{i}.variances = variances;  % Store the variances for the corresponding y values
        steady_state_data{i}.steady_state_indices = steady_state_indices;  % **Store indices**

    else
        warning(['Variables u or x not found in ', filename]);
    end
end

% Save the steady_state_data for later use
save('steady_state_data.mat', 'steady_state_data');


