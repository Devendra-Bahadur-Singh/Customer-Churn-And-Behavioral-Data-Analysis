# Importing necessary packages
import os
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sqlalchemy import create_engine

# DATABASE CONNECTION & DATA LOADING
engine = create_engine('mysql+pymysql://root:12345678asdfghjk@localhost:3306/uci_db')

# df_order_intervals
df_order_intervals = pd.read_sql(
    'SELECT * FROM fact_customer_order_intervals', 
    con=engine, 
    parse_dates=['OrderDate', 'CohortDate']
)

# df_customer_summary
df_customer_summary = pd.read_sql(
    'SELECT * FROM fact_customer_summary', 
    con=engine, 
    parse_dates=['FirstPurchaseDate', 'LastPurchaseDate']
)


# Analysis with PANDAS

# 1. df_cohort_matrix
df_order_intervals['CohortMonth'] = df_order_intervals['CohortDate'].dt.to_period('M')
df_order_intervals['OrderMonth'] = df_order_intervals['OrderDate'].dt.to_period('M')

df_order_intervals['CohortIndex'] = (
    (df_order_intervals['OrderMonth'].dt.year - df_order_intervals['CohortMonth'].dt.year) * 12
    + (df_order_intervals['OrderMonth'].dt.month - df_order_intervals['CohortMonth'].dt.month)
)

cohort_counts = (
    df_order_intervals.groupby(['CohortMonth', 'CohortIndex'])['CustomerID']
    .nunique()
    .reset_index()
)

cohort_pivot = cohort_counts.pivot(index='CohortMonth', columns='CohortIndex', values='CustomerID')
cohort_size = cohort_pivot.iloc[:, 0]
df_cohort_matrix = cohort_pivot.divide(cohort_size, axis=0)
df_cohort_matrix.index = df_cohort_matrix.index.astype(str)

# 2. df_churn_velocity
avg_retention = df_cohort_matrix.mean(axis=0)
df_churn_velocity = pd.DataFrame({
    'CohortIndex': avg_retention.index,
    'AverageRetention': avg_retention.values,
    'RetentionDropDelta': avg_retention.diff() * -1
}).dropna()

# 3. df_inactivity_decay
intervals = df_order_intervals.dropna(subset=['DaysSinceLastOrder']).copy()
bins = [-1, 7, 14, 30, 60, 90, np.inf]
labels = ['0-7 Days', '8-14 Days', '15-30 Days', '31-60 Days', '61-90 Days', '90+ Days']
intervals['InactivityBin'] = pd.cut(intervals['DaysSinceLastOrder'], bins=bins, labels=labels)

bin_counts = intervals['InactivityBin'].value_counts().sort_index()
df_inactivity_decay = pd.DataFrame({
    'InactivityBin': labels,
    'OrderCount': [bin_counts.get(lbl, 0) for lbl in labels]
})
df_inactivity_decay['ReturnProbability'] = (
    df_inactivity_decay['OrderCount'] / df_inactivity_decay['OrderCount'].sum()
)


# Visualizations with MATPLOTLIB
plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')
fig = plt.figure(figsize=(20, 12))

# 1. Heatmap
ax1 = fig.add_subplot(2, 2, 1)
sns.heatmap(df_cohort_matrix, annot=True, fmt='.0%', cmap='YlGnBu', ax=ax1, cbar=False, annot_kws={'size': 8})
ax1.set_title('Customer Retention Matrix by Cohort Month', fontsize=12, fontweight='bold')
ax1.set_xlabel('Cohort Index (Months Since First Purchase)')
ax1.set_ylabel('Cohort Month')

# 2. Churn Velocity
ax2 = fig.add_subplot(2, 2, 2)
ax2.bar(df_churn_velocity['CohortIndex'].astype(str), df_churn_velocity['RetentionDropDelta'] * 100, color='crimson', alpha=0.8)
ax2.set_title('Churn Velocity (Retention Drop-off Delta per Month)', fontsize=12, fontweight='bold')
ax2.set_xlabel('Cohort Index (Month Step)')
ax2.set_ylabel('Retention Drop Percentage (%)')

for bar in ax2.patches:
    height = bar.get_height()
    ax2.annotate(f"{height:.1f}%", (bar.get_x() + bar.get_width() / 2, height), ha='center', va='bottom', fontsize=9)

# 3. Inactivity Bins
ax3 = fig.add_subplot(2, 2, (3, 4))
colors = ['forestgreen', 'mediumseagreen', 'goldenrod', 'crimson', 'darkred', 'black']
bars = ax3.bar(df_inactivity_decay['InactivityBin'], df_inactivity_decay['ReturnProbability'] * 100, color=colors, edgecolor='black')
ax3.axvline(2.5, color='red', linestyle='--', linewidth=2, label='30-Day Inactivity Threshold')
ax3.set_title('Re-engagement Distribution vs. Days Inactive (Proving the 30-Day Cliff)', fontsize=13, fontweight='bold')
ax3.set_xlabel('Inactivity Interval (Days Since Previous Order)')
ax3.set_ylabel('Share of Total Re-orders (%)')
ax3.legend(loc='upper right')

for bar in bars:
    yval = bar.get_height()
    ax3.text(bar.get_x() + bar.get_width() / 2, yval + 0.5, f"{yval:.1f}%", ha='center', va='bottom', fontweight='bold')

plt.tight_layout()


# Exporting visualizations locally
# Create export directory structure if it doesn't exist
output_dir = Path("Outputs")
data_dir = output_dir / "Data"
plots_dir = output_dir / "Visualizations"

data_dir.mkdir(parents=True, exist_ok=True)
plots_dir.mkdir(parents=True, exist_ok=True)

# 1. Exporting DataFrames to CSV
df_cohort_matrix.to_csv(data_dir / "cohort_retention_matrix.csv", index=True)  # CohortMonth index preserved
df_churn_velocity.to_csv(data_dir / "churn_velocity.csv", index=False)
df_inactivity_decay.to_csv(data_dir / "inactivity_decay.csv", index=False)


# 2. Exporting visualizations to high-resolution PNG
fig.savefig(plots_dir / "churn_cohort_dashboard.png", dpi=300, bbox_inches='tight')

# 3. Exporting visualizations to PDF
fig.savefig(plots_dir / "churn_cohort_dashboard.pdf", bbox_inches='tight')

print(f"Successfully saved files to: {output_dir.resolve()}")

# Displaying plot
plt.show()