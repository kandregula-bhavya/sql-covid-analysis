# COVID-19 Data Analysis using SQL

## 📌 Project Overview

This project explores and analyzes COVID-19 data to understand global trends in infections, deaths, and vaccination progress. The analysis is performed using SQL, focusing on deriving meaningful insights from large-scale real-world data.

---

## 🎯 Objectives

* Analyze COVID-19 infection and death trends across countries
* Evaluate the impact of vaccination on death rates
* Identify peak infection waves and high-risk regions
* Build analytical queries using advanced SQL techniques

---

## 📊 Dataset Source

The dataset is obtained from **Our World in Data**:

https://covid.ourworldindata.org/data/owid-covid-data.csv

> Note: The dataset is large and is not included in this repository. Please download it from the link above.

---

## 🛠 Tools & Technologies

* MySQL
* MySQL Workbench
* SQL

---

## 📂 Project Structure

```
sql-covid-analysis/
│
├── sql/
│   └── covid_analysis.sql
│
└── README.md
```

---

## 🔍 Key Analysis Performed

### 🟢 Basic Analysis

* Total cases and deaths by country
* Daily infection trends
* Country-wise comparisons

### 🟡 Intermediate Analysis

* Death rate calculation
* Continent-level aggregation
* Infection rate per population

### 🔵 Advanced Analysis

* Join operations between deaths and vaccination datasets
* Rolling vaccination metrics using window functions
* Peak infection wave detection
* Vaccination vs death rate analysis

---

## 💡 Advanced SQL Concepts Used

* Common Table Expressions (CTE)
* Window Functions (SUM OVER, RANK)
* Joins (INNER JOIN on multiple conditions)
* Aggregations (GROUP BY, MAX, SUM)
* Case Statements
* Query Optimization techniques

---

## 📈 Key Insights

* Countries with higher vaccination rates tend to show lower death percentages
* COVID-19 waves varied significantly across regions and time periods
* Vaccination rollout speed differed widely between countries
* Peak infection periods highlight differences in outbreak severity

---

## 🚀 Key Learnings

* Handling large datasets using SQL
* Writing optimized queries for performance
* Applying analytical thinking to real-world data
* Debugging and improving query efficiency

---

## 📌 Future Improvements

* Build interactive dashboard using Tableau or Power BI
* Perform advanced analysis using Python (Pandas, Matplotlib)
* Extend project with machine learning models

---

## 👤 Author

Bhavya Kandregula
