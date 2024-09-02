# Plate Heat Exchanger Model Repository

This repository contains models for simulating a plate heat exchanger. The models are written in MATLAB 2023a and are designed to help researchers and engineers better understand and predict the behavior of plate heat exchangers under various conditions.

## Reference Paper

An explanation of the models and their identification is available here:

> M. Ožbot, E. Lughofer and I. Škrjanc, "Evolving Neuro-Fuzzy Systems-Based Design of Experiments in Process Identification," in IEEE Transactions on Fuzzy Systems, vol. 31, no. 6, pp. 1995-2005, June 2023, doi: 10.1109/TFUZZ.2022.3216992.

Please cite this.

## Directory Structure

- **MISO_model**: Contains the Multiple Input Single Output (MISO) model for the plate heat exchanger.
- **SISO_model**: Contains the Single Input Single Output (SISO) model, including a fuzzy model.
- **SISO_drift**: Houses the drift model which simulates simple drifting characteristics for the SISO model.
- **Simple_example**: Provides a straightforward example to demonstrate the use and effectiveness of the models.
- **PHE_data**: Contains real-world datasets under various conditions.

## Datasets in `PHE_data`

The `PHE_data` directory includes various `.mat` files containing real measurement data from actual plate heat exchanger operations:

- **measurement_steps_*.mat**: These datasets provide real data under different operational conditions, allowing for realistic simulation and validation of the models.

## Key Features

- **MISO Model**: Enables users to simulate the plate heat exchanger behavior with multiple inputs affecting a single output.
- **SISO Model**: A simple model that considers a single input and predicts its impact on a single output. Additionally, this folder contains a fuzzy model to enhance prediction capabilities.
- **Drift Simulation**: Helps in understanding the drifting characteristics of the heat exchanger over time.
- **Fuzzy Model**: The SISO model incorporates a fuzzy logic-based model, enhancing its prediction capabilities, especially in non-linear scenarios.
- **Real-World Data**: Real measurement data under normal operation for system identification and different fault conditions for fault detection.

## Requirements

- Created in MATLAB 2023a, might not work in older versions.

## Contribution

Feel free to fork the repository and submit pull requests for any enhancements, bug fixes, or other contributions. Please ensure that your code is well-documented.

## License

This project is licensed under the MIT License.
