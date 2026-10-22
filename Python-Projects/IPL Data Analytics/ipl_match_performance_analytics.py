"""
=============================================================================
IPL Match Strategy & Player Performance Analytics Engine
Author: Sachin Sharma (Commercial Analytics Leader)
Description:
    Processes 12+ seasons of IPL historical match-play and ball-by-ball records.
    Analyzes toss decision trends, measures toss-to-win conversion bias, tracks
    franchise championship dominance, and computes contextual batting strike 
    rates across match phases (Powerplay vs. Death Overs).
=============================================================================
"""

import pandas as pd
import numpy as np

def analyze_toss_impact(matches_df: pd.DataFrame) -> dict:
    """Calculates win probabilities conditioned on toss outcome."""
    df = matches_df.copy()
    df["toss_win_game_win"] = df["toss_winner"] == df["winner"]
    
    total_matches = len(df)
    toss_and_game_wins = df["toss_win_game_win"].sum()
    toss_win_rate_pct = (toss_and_game_wins / total_matches) * 100
    
    decision_win_rate = (
        df.groupby("toss_decision")
        .apply(lambda g: (g["toss_winner"] == g["winner"]).mean() * 100, include_groups=False)
        .to_dict()
    )
    
    return {
        "Total_Matches_Analyzed": total_matches,
        "Toss_Winner_Game_Win_Pct": round(toss_win_rate_pct, 2),
        "Win_Pct_By_Decision": {k: round(v, 2) for k, v in decision_win_rate.items()}
    }

def analyze_franchise_dominance(matches_df: pd.DataFrame, top_n: int = 8) -> pd.DataFrame:
    """Computes total match victories and win percentages across franchises."""
    df = matches_df.copy()
    total_played = df["team1"].value_counts().add(df["team2"].value_counts(), fill_value=0)
    total_won = df["winner"].value_counts()
    
    leaderboard = pd.DataFrame({"Matches_Played": total_played, "Matches_Won": total_won}).dropna()
    leaderboard["Win_Percentage"] = (leaderboard["Matches_Won"] / leaderboard["Matches_Played"]) * 100
    return leaderboard.sort_values(by="Matches_Won", ascending=False).head(top_n).reset_index()

def calculate_death_overs_efficiency(ball_by_ball_df: pd.DataFrame, min_balls: int = 300) -> pd.DataFrame:
    """Calculates batting strike rate and boundary percentage in overs 16-20."""
    death_overs = ball_by_ball_df[ball_by_ball_df["over"] >= 15].copy()
    death_overs["is_boundary"] = death_overs["batsman_runs"].isin([4, 6]).astype(int)
    
    stats = (
        death_overs.groupby("batsman")
        .agg(
            Total_Runs=("batsman_runs", "sum"),
            Total_Balls=("ball", "count"),
            Boundaries_Hit=("is_boundary", "sum")
        )
        .reset_index()
    )
    
    stats = stats[stats["Total_Balls"] >= min_balls].copy()
    stats["Strike_Rate"] = (stats["Total_Runs"] / stats["Total_Balls"]) * 100
    stats["Boundary_Pct"] = (stats["Boundaries_Hit"] / stats["Total_Balls"]) * 100
    
    return stats.sort_values(by="Strike_Rate", ascending=False).reset_index(drop=True)

if __name__ == "__main__":
    print("IPL Match Strategy & Performance Analytics Engine loaded successfully.")
