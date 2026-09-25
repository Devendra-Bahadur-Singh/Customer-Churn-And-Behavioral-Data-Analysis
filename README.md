# Customer Churn & Behavioral Data Analysis (CAB Analysis)

![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-1.5+-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-3.5+-11557C?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

An end-to-end data engineering and behavioral analytics project executing customer retention modeling, drop-off decay quantification, and churn threshold identification on $1.06\text{M+}$ transactional records from the **UCI Online Retail II** dataset.

---

## 📊 Analytics Dashboard Preview

![Customer Churn & Behavioral Analytics Dashboard](Outputs/Visualizations/churn_cohort_dashboard.png)

> 🔗 **Vector Interactive / Print View:**  
> [📄 Click to View or Download the High-Resolution PDF Dashboard](Outputs/Visualizations/churn_cohort_dashboard.pdf)

---

## 🎯 Executive Summary & Key Findings

1. **The Month-1 Retention Cliff (78.0% Churn Velocity):**  
   The churn velocity analysis proves that the steepest drop-off occurs immediately between initial purchase ($T_0$) and Month 1 ($T_1$). Retention collapses by **78.0%** in the first period, stabilizing into a baseline repeat range of **15%–30%** in subsequent months.
2. **The 30-Day Inactivity Threshold:**  
   Order sequence interval analysis reveals that **55.2%** of all repeat purchases ($25.9\% + 11.3\% + 18.0\%$) occur within **30 days** of a previous order.
3. **Behavioral Drop-off Impact:**  
   Once a customer remains inactive past **30 days**, re-engagement probability sharply declines into fragmented, low-probability buckets ($\le 19.2\%$), proving that **30 days** is the operational threshold for automated retention interventions.

---

## 🏗 System Architecture & Pipeline Design

```
+-----------------------------------------------------------------------------------+
|                            LAYER 1: SQL DATA PIPELINE                             |
|                                (cab_script.sql)                                   |
|                                                                                   |
|  [raw_online_retail]  --> [fact_cleaned_transactions] --> [fact_customer_orders]  |
|                                                                  |                |
|                                                                  v                |
|  [fact_customer_summary] <-------------------- [fact_customer_order_intervals]    |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                      LAYER 2: PYTHON ANALYTICAL ENGINE                            |
|                            (cab_python_script.py)                                 |
|                                                                                   |
|     * Cohort Retention Matrix (Period-over-Period)                                |
|     * Churn Velocity Calculation ($\Delta R = R_t - R_{t-1}$)                    |
|     * Inactivity Binning & Re-purchase Probability                                |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                      LAYER 3: VISUALIZATION & OUTPUTS                             |
|                        (Outputs/Visualizations/)                                  |
|                                                                                   |
|     * Cohort Retention Heatmap                                                    |
|     * Churn Velocity Delta Bar Chart                                              |
|     * 30-Day Inactivity Cliff Distribution                                        |
+-----------------------------------------------------------------------------------+
```

---

## 📂 Repository Structure

```text
CAB_Analysis/
├── Source/
│   └── online_retail.csv               # Raw UCI Transactional Dataset (1.06M+ records)
├── Outputs/
│   ├── Data/
│   │   ├── churn_velocity.csv          # Retention drop-off delta metrics per month
│   │   ├── cohort_retention_matrix.csv # Full monthly retention matrix percentages
│   │   └── inactivity_decay.csv        # Days-since-last-order bin probabilities
│   └── Visualizations/
│       ├── churn_cohort_dashboard.pdf  # Publication-grade PDF vector dashboard
│       └── churn_cohort_dashboard.png  # Dashboard preview raster image
├── cab_python_script.py                # Python Pandas analytical engine & Matplotlib generator
├── cab_script.sql                      # SQL ETL pipeline, schema definitions, CTEs & window functions
├── fact_cleaned_transactions.csv       # Exported clean transaction line-items
├── fact_customer_order_interval.csv    # Sequential customer order gap calculations
├── fact_customer_orders.csv            # Order-level aggregated transaction headers
└── fact_customer_summary.csv           # Final customer-level summary & 30-day churn flags
```

---

## 🗄 Data Model & Layer 1 SQL Tables

The database layer (`uci_db`) processes raw text transactions into normalized fact tables:

| Fact Table Name | Granularity | Key Transformations / Filters Applied |
| :--- | :--- | :--- |
| **`fact_cleaned_transactions`** | Line Item | Filters missing `CustomerID`, price $\le 0$, and admin stock codes (`POST`, `D`, `M`, etc.). Calculates `LineTotal = Quantity * UnitPrice`. |
| **`fact_customer_orders`** | Order Header | Aggregates line items by `CustomerID` and `InvoiceNo`. Excludes cancellations (`InvoiceNo LIKE 'C%'`). |
| **`fact_customer_order_intervals`** | Customer Order Sequence | Employs CTEs and Window Functions: `MIN() OVER()`, `LAG() OVER()`, and `DATEDIFF()` to measure purchase gaps (`DaysSinceLastOrder`). |
| **`fact_customer_summary`** | Customer | Aggregates lifecycle metrics: `FirstPurchaseDate`, `LastPurchaseDate`, `TotalOrders`, `RecencyDays`, and the 30-day churn flag (`IsChurned30`). |

---

## 🐍 Layer 2 Python Analytics

The Python engine loads the structured SQL layer via `SQLAlchemy` and performs analytical aggregations:

1. **Cohort Retention Matrix (`df_cohort_matrix`):**  
   Maps user acquisition months ($T_0$) to subsequent active order months ($T_n$), computing retention rate ratios:
   $$\text{Retention Rate}_{c, i} = \frac{\text{Active Customers}_{c, i}}{\text{Base Cohort Size}_{c, 0}}$$

2. **Retention Drop Decay / Churn Velocity (`df_churn_velocity`):**  
   Measures month-over-month retention degradation velocity across cohorts:
   $$\Delta R_t = R_{t-1} - R_t$$

3. **Inactivity Decay Analysis (`df_inactivity_decay`):**  
   Bins purchase gaps into ranges ($0\text{--}7$, $8\text{--}14$, $15\text{--}30$, $31\text{--}60$, $61\text{--}90$, $90+$ days) to establish re-engagement probabilities.

---

## 🚀 How to Run & Reproduce

### Prerequisites
* **Database:** MySQL 8.0+
* **Environment:** Python 3.9+
* **Python Packages:** `pandas`, `numpy`, `matplotlib`, `seaborn`, `sqlalchemy`, `pymysql`

### Step 1: Clone the Repository
```bash
git clone https://github.com/Devendra-Bahadur-Singh/Customer-Churn-And-Behavioral-Data-Analysis.git
cd Retail-Customer-RFM-Analysis
```

### Step 2: Database Setup & SQL Pipeline
1. Place `online_retail.csv` inside the `Source/` folder.
2. Open MySQL Workbench or CLI and run `cab_script.sql`:
   ```bash
   mysql -u root -p < cab_script.sql
   ```
3. This creates the database `uci_db`, imports the raw CSV, and builds all 4 fact tables.

### Step 3: Run Python Engine & Visualizations
1. Update database credentials in `cab_python_script.py`:
   ```python
   engine = create_engine('mysql+pymysql://username:password@localhost/uci_db')
   ```
2. Execute the script:
   ```bash
   python cab_python_script.py
   ```
3. Processed CSVs will be populated in `Outputs/Data/`, and dashboard files will save to `Outputs/Visualizations/`.

---

## 💡 Business Recommendations

* **Early Onboarding Trigger (Days 1–14):**  
  Given the **78.0%** Month-1 churn drop, execute automated welcome sequences and initial re-order incentives within 14 days of first purchase.
* **Win-Back Campaign Threshold (Day 21):**  
  Deploy targeted promotional messaging at **Day 21** to capture users before crossing the critical **30-day inactivity cliff**.

## 👤 Author

**Devendra Bahadur Singh**  
Github: [@devendra.bahadur.singh](https://github.com/Devendra-Bahadur-Singh)
Linkedin: [@devendra.bahadur.singh](https://www.linkedin.com/in/devendra-bahadur-singh-31133a3a8)