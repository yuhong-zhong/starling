import re
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def parse_tables(file_content):
    """Parse the tables from the file content into a structured format."""
    # extract the summary blocks
    param_blocks = re.split(r'Parameters:', file_content)[1:]
    print(param_blocks[1])
    all_data = []
    
    for block in param_blocks:
        # parameter values for each block
        param_line = block.split('\n')[0].strip()
        params = {}
        # match the keys and values
        param_parts = re.findall(r'(\w+)=(\d+\.?\d*|\{.*?\})', param_line)
        for key, value in param_parts:
            try:
                params[key] = float(value) if '.' in value else int(value)
            except ValueError:
                params[key] = value

        # find the actual block table.
        table_lines = block.split('\n')
        header_line_idx = next((i for i, line in enumerate(table_lines) if "L   Beamwidth" in line), -1)
        print(table_lines[3])
        print(header_line_idx)
        print(h)
        if header_line_idx == -1:
            continue
            
        # get table data.
        data_lines = table_lines[header_line_idx+1:]
        table_data = []
        
        for line in data_lines:
            line = line.strip()
            if not line:
                continue
                
            # regex to extract the table entries.
            values = re.findall(r'\s*(\d+)\s+(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+)\s+(\d+)\s+(\d+)', line)
            
            if values:
                values = values[0]
                row_data = {
                    'L': int(values[0]),
                    'Beamwidth': int(values[1]),
                    'QPS': float(values[2]),
                    'Mean_Latency': float(values[3]),
                    '99.9_Latency': float(values[4]),
                    'Mean_IOs': float(values[5]),
                    'CPU(s)': float(values[6]),
                    'B4_Load_In-Mem': int(values[7]),
                    'After_Load_Cache': int(values[8]),
                    'Peak_Mem(MB)': int(values[9])
                }
                
                # add all the data to this row.
                for key, value in params.items():
                    row_data[key] = value
                    
                table_data.append(row_data)
        
        all_data.extend(table_data)
    
    return pd.DataFrame(all_data)

def analyze_data(df):
    """Analyze the data and generate comparison metrics."""
    print(f"Total records: {len(df)}")
    print("\nAvailable parameter configurations:")
    
    # get unique parameter combinations
    param_cols = [col for col in df.columns if col not in ['L', 'Beamwidth', 'QPS', 'Mean_Latency', 
                                                          '99.9_Latency', 'Mean_IOs', 'CPU(s)', 
                                                          'B4_Load_In-Mem', 'After_Load_Cache', 'Peak_Mem(MB)']]
    
    config_df = df[param_cols].drop_duplicates()
    print(config_df)
    
    return df

def compare_metrics(df, metric, group_by='L', param_filter=None):
    """Compare a specific metric across different parameter configurations."""
    if param_filter:
        df = df.query(param_filter)
    
    pivot_df = df.pivot_table(
        index=group_by,
        columns=[col for col in df.columns if col not in 
                ['L', 'Beamwidth', 'QPS', 'Mean_Latency', '99.9_Latency', 'Mean_IOs', 
                 'CPU(s)', 'B4_Load_In-Mem', 'After_Load_Cache', 'Peak_Mem(MB)', group_by]],
        values=metric,
        aggfunc='mean'
    )
    
    return pivot_df

def plot_comparison(df, metric, group_by='L', param_filter=None, title=None):
    """Plot a comparison of metrics across parameter configurations."""
    if param_filter:
        df = df.query(param_filter)
    
    param_cols = [col for col in df.columns if col not in 
                 ['L', 'Beamwidth', 'QPS', 'Mean_Latency', '99.9_Latency', 'Mean_IOs', 
                  'CPU(s)', 'B4_Load_In-Mem', 'After_Load_Cache', 'Peak_Mem(MB)']]
    
    df['config'] = df.apply(
        lambda row: ', '.join([f"{col}={row[col]}" for col in param_cols]), 
        axis=1
    )
    
    plt.figure(figsize=(12, 6))
    sns.lineplot(x=group_by, y=metric, hue='config', data=df, marker='o')
    
    if title:
        plt.title(title)
    else:
        plt.title(f'{metric} vs {group_by} for Different Parameter Configurations')
    
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.tight_layout()
    
    return plt

def main(file_path):
    """Main function to run the analysis."""
    with open(file_path, 'r') as f:
        file_content = f.read()
    
    df = parse_tables(file_content)
    return
    
    df = analyze_data(df)
    print("\nComparing Mean Latency across parameter configurations:")
    mean_latency_comparison = compare_metrics(df, 'Mean_Latency')
    print(mean_latency_comparison)
    
    print("\nComparing 99.9 Latency across parameter configurations:")
    latency_99_comparison = compare_metrics(df, '99.9_Latency')
    print(latency_99_comparison)
    
    print("\nComparing Mean IOs across parameter configurations:")
    mean_ios_comparison = compare_metrics(df, 'Mean_IOs')
    print(mean_ios_comparison)
    
    # Plot comparisons
    plot_comparison(df, 'Mean_Latency')
    plt.savefig('mean_latency_comparison.png')
    
    plot_comparison(df, '99.9_Latency')
    plt.savefig('99_9_latency_comparison.png')
    
    plot_comparison(df, 'Mean_IOs')
    plt.savefig('mean_ios_comparison.png')
    
    print("\nAnalysis complete! Plots saved as PNG files.")
    
    return df

if __name__ == "__main__":
    # Replace with your file path
    file_path = "../indices/summary.log"
    df = main(file_path)
