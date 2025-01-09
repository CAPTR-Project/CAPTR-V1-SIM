import re
import pandas as pd
import matplotlib.pyplot as plt

# Function to parse the log file
def parse_log(file_path):
    # Define regex patterns
    gyro_pattern = r'Gyroscope:\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)'
    orientation_pattern = r'Orientation:\s+yaw:\s+(-?\d+\.\d+)\s+pitch:\s+(-?\d+\.\d+)\s+roll:\s+(-?\d+\.\d+)'
    
    attitude_output_pattern = r'Attitude Output:\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)'
    rate_output_pattern = r'Rate Output:\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)'

    # Initialize lists
    gyro_data = []
    orientation_data = []
    attitude_output_data = []
    rate_output_data = []

    # Read and parse the file
    with open(file_path, 'r') as file:
        for line in file:
            gyro_match = re.search(gyro_pattern, line)
            orientation_match = re.search(orientation_pattern, line)
            attitude_output_match = re.search(attitude_output_pattern, line)
            rate_output_match = re.search(rate_output_pattern, line)

            if gyro_match:
                gyro_data.append([float(val) for val in gyro_match.groups()])
            if orientation_match:
                orientation_data.append([float(val) for val in orientation_match.groups()])
            if attitude_output_match:
                attitude_output_data.append([float(val) for val in attitude_output_match.groups()])
            if rate_output_match:
                rate_output_data.append([float(val) for val in rate_output_match.groups()])

    # Align lengths
    min_length = min(len(gyro_data), len(orientation_data), len(attitude_output_data), len(rate_output_data))

    # Create a DataFrame
    data = pd.DataFrame({
        "Gyro_Yaw": [row[2] for row in gyro_data[:min_length]],
        "Orientation_Yaw": [row[0] for row in orientation_data[:min_length]],
        "Attitude_Yaw": [row[0] for row in attitude_output_data[:min_length]],
        "Rate_Yaw": [row[0] for row in rate_output_data[:min_length]]
    })

    return data

# Function to calculate errors
def calculate_errors(data):
    data['Rate_Error'] = data['Gyro_Yaw'] - data['Rate_Yaw']
    data['Attitude_Error'] = -data['Orientation_Yaw']
    return data

# Function to plot data
def plot_data(data, start, end, title):
    plt.figure(figsize=(10, 6))
    #plt.plot(data.index[start:end], data['Gyro_Yaw'][start:end], label='Gyro Yaw')
    #plt.plot(data.index[start:end], data['Rate_Yaw'][start:end], label='Rate Yaw (Command)')
    #plt.plot(data.index[start:end], data['Rate_Error'][start:end], label='Rate Error', linestyle='--')
    plt.plot(data.index[start:end], data['Orientation_Yaw'][start:end], label='Attitude_Yaw')
    plt.plot(data.index[start:end], data['Attitude_Yaw'][start:end], label='Attitude Yaw (Command)')
    plt.plot(data.index[start:end], data['Attitude_Error'][start:end], label='Attitude Error', linestyle='--')

    plt.title(title)
    plt.xlabel('Time (Index)')
    plt.ylabel('Yaw (rad/s or rad)')
    plt.legend()
    plt.grid()
    plt.show()

# Main script
if __name__ == "__main__":
    # File path to the log file
    file_path = "analysis/static1.log"  # Replace with your log file path

    # Parse the log file
    data = parse_log(file_path)
    # Calculate errors
    data = calculate_errors(data)

    # Plot the full data
    #plot_data(data, 0, len(data), "Yaw Axis Data and Errors (Full Range)")
    # Plot zoomed-in range 1750 to 1950
    plot_data(data, 1750, 1950, "Yaw Axis Data and Errors")
