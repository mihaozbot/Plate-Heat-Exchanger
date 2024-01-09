# Plate Heat Exchanger Model Repository

This repository contains models for simulating a plate heat exchanger. The models are written in MATLAB 2023a and are designed to help researchers and engineers better understand and predict the behavior of plate heat exchangers under various conditions.

## Directory Structure

- **MISO_model**: Contains the Multiple Input Single Output (MISO) model for the plate heat exchanger.
- **SISO_model**: Contains the Single Input Single Output (SISO) model, including a fuzzy model.
- **SISO_drift**: Houses the drift model which simulates simple drifting characteristics for the SISO model.
- **Simple_example**: Provides a straightforward example to demonstrate the use and effectiveness of the models.

## Key Features

- **MISO Model**: Enables users to simulate the plate heat exchanger behavior with multiple inputs affecting a single output.
- **SISO Model**: A simple model that considers a single input and predicts its impact on a single output. Additionally, this folder contains a fuzzy model to enhance the prediction capabilities.
- **Drift Simulation**: Helps in understanding the drifting characteristics of the heat exchanger over time.
- **Fuzzy Model**: The SISO model incorporates a fuzzy logic-based model, enhancing its prediction capabilities, especially in non-linear scenarios.

## Reference Paper

The SISO model is based on the following paper:

> I. Škrjanc and D. Matko, ‘Predictive functional control based on fuzzy model for heat-exchanger pilot plant’, IEEE Transactions on Fuzzy Systems, vol. 8, no. 6, pp. 705–712, Dec. 2000, [doi: 10.1109/91.890329](https://doi.org/10.1109/91.890329).

## Getting Started

Open the MATLAB `.m` files and run them in MATLAB 2023a or later.

## Requirements

- MATLAB 2023a or later.

## Contribution

Feel free to fork the repository and submit pull requests for any enhancements, bug fixes, or other contributions. Please ensure that your code is well-documented.

## License

This project is licensed under the MIT License. 
