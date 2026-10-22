"""
=============================================================================
E-Commerce Commercial Sales Analytics & Market Basket Engine
Author: Sachin Sharma (Commercial Analytics Leader)
Description:
    Processes 180K+ multi-city transactional records. Performs seasonal revenue
    aggregation, price elasticity diagnostics, peak conversion window discovery,
    and combinatorial Market Basket Analysis for bundle cross-selling.
=============================================================================
"""

import os
from collections import Counter
from itertools import combinations
import pandas as pd
import numpy as np

def clean_sales_data(df: pd.DataFrame) -> pd.DataFrame:
    """Cleans null records, strips invalid headers, and casts data types."""
    df = df.dropna(how="all").copy()
    df = df[df["Order Date"].str[0:2] != "Or"]
    
    df["Quantity Ordered"] = pd.to_numeric(df["Quantity Ordered"])
    df["Price Each"] = pd.to_numeric(df["Price Each"])
    df["Sales"] = df["Quantity Ordered"] * df["Price Each"]
    df["Order Date"] = pd.to_datetime(df["Order Date"], format="%m/%d/%y %H:%M")
    df["Month"] = df["Order Date"].dt.month
    df["Hour"] = df["Order Date"].dt.hour
    
    def extract_city(address):
        parts = address.split(",")
        city = parts[1].strip()
        state = parts[2].split(" ")[1].strip()
        return f"{city} ({state})"
    
    df["City"] = df["Purchase Address"].apply(extract_city)
    return df

def analyze_monthly_performance(df: pd.DataFrame) -> pd.DataFrame:
    """Calculates total revenue and units ordered per month."""
    return df.groupby("Month").agg(
        Total_Revenue=("Sales", "sum"),
        Total_Units=("Quantity Ordered", "sum"),
        Total_Orders=("Order ID", "nunique")
    ).reset_index()

def analyze_city_revenue(df: pd.DataFrame) -> pd.DataFrame:
    """Calculates regional commercial contributions across metropolitan areas."""
    return df.groupby("City")["Sales"].sum().sort_values(ascending=False).reset_index()

def analyze_market_basket(df: pd.DataFrame, top_n: int = 10) -> list:
    """Performs pair combinatorial association to uncover frequently co-purchased bundles."""
    multi_orders = df[df["Order ID"].duplicated(keep=False)]
    grouped_orders = multi_orders.groupby("Order ID")["Product"].apply(lambda x: ",".join(x))
    
    basket_counter = Counter()
    for row in grouped_orders:
        items = sorted(row.split(","))
        basket_counter.update(Counter(combinations(items, 2)))
        
    return basket_counter.most_common(top_n)

if __name__ == "__main__":
    print("E-Commerce Commercial Sales Analytics Engine loaded successfully.")
