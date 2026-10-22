"""
=============================================================================
S&P 500 Time Series Technical Stock & Portfolio Risk Engine
Author: Sachin Sharma (Commercial Analytics Leader)
Description:
    Analyzes historical equity time series data across major tech equities 
    (AAPL, MSFT, AMZN, GOOGL). Calculates rolling Simple Moving Averages 
    (10, 20, 50 SMA), daily return distributions, risk volatility (std dev),
    cross-asset correlation matrices, and normalized cumulative growth.
=============================================================================
"""

import pandas as pd
import numpy as np

def calculate_moving_averages(df: pd.DataFrame, windows: list = [10, 20, 50]) -> pd.DataFrame:
    """Calculates rolling simple moving averages for technical trend identification."""
    res = df.copy()
    for w in windows:
        res[f"MA_{w}"] = res["close"].rolling(window=w).mean()
    return res

def calculate_daily_returns_and_risk(df: pd.DataFrame) -> dict:
    """Calculates daily percentage return series and key risk metrics (volatility, Sharpe proxy)."""
    returns = df["close"].pct_change().dropna()
    daily_volatility = returns.std()
    annualized_volatility = daily_volatility * np.sqrt(252)
    mean_daily_return = returns.mean()
    annualized_return = mean_daily_return * 252
    
    return {
        "Daily_Volatility_Pct": round(daily_volatility * 100, 2),
        "Annualized_Volatility_Pct": round(annualized_volatility * 100, 2),
        "Annualized_Return_Pct": round(annualized_return * 100, 2),
        "Sharpe_Ratio_Proxy": round(annualized_return / annualized_volatility, 2) if annualized_volatility > 0 else 0
    }

def calculate_portfolio_correlations(stock_dfs: dict) -> tuple:
    """Computes cross-asset price correlation and daily return correlation matrices."""
    closing_prices = pd.DataFrame({sym: df["close"] for sym, df in stock_dfs.items()})
    daily_returns = pd.DataFrame({sym: df["close"].pct_change() for sym, df in stock_dfs.items()}).dropna()
    
    price_corr = closing_prices.corr()
    return_corr = daily_returns.corr()
    
    return price_corr, return_corr

def compute_normalized_growth(stock_dfs: dict, base: float = 100.0) -> pd.DataFrame:
    """Normalizes multiple assets to a common starting base for comparative performance."""
    growth_dict = {}
    for sym, df in stock_dfs.items():
        growth_dict[sym] = (df["close"] / df["close"].iloc[0]) * base
    return pd.DataFrame(growth_dict)

if __name__ == "__main__":
    print("S&P 500 Technical Time Series & Risk Analytics Engine loaded successfully.")
