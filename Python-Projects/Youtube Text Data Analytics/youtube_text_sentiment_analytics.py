"""
=============================================================================
YouTube Text Mining, Audience Sentiment & Virality Analytics Engine
Author: Sachin Sharma (Commercial Analytics Leader)
Description:
    Analyzes international YouTube trending telemetry and viewer comment streams.
    Applies NLP sentiment classification (TextBlob), extracts audience emoji
    reactions, evaluates engagement conversion rates (Likes/Comments per View),
    and measures the impact of title punctuation syntax on video virality.
=============================================================================
"""

import string
from collections import Counter
import pandas as pd
import numpy as np
from textblob import TextBlob
import emoji

def analyze_comment_sentiments(comments_series: pd.Series) -> pd.DataFrame:
    """Classifies audience comments into Positive, Neutral, or Negative sentiment."""
    results = []
    for comment in comments_series.dropna():
        text_str = str(comment)
        polarity = TextBlob(text_str).sentiment.polarity
        
        if polarity > 0.1:
            sentiment = "Positive"
        elif polarity < -0.1:
            sentiment = "Negative"
        else:
            sentiment = "Neutral"
            
        results.append({"comment_text": text_str, "polarity": polarity, "sentiment": sentiment})
        
    return pd.DataFrame(results)

def extract_audience_emojis(comments_series: pd.Series, top_n: int = 10) -> list:
    """Mines and counts unicode reaction emojis from comment text."""
    emojis_list = []
    for comment in comments_series.dropna():
        emojis_list.extend([c["emoji"] for c in emoji.emoji_list(str(comment))])
    return Counter(emojis_list).most_common(top_n)

def calculate_category_engagement(videos_df: pd.DataFrame) -> pd.DataFrame:
    """Calculates like and comment conversion percentages per view across categories."""
    df = videos_df.copy()
    df["like_rate_pct"] = (df["likes"] / df["views"]) * 100
    df["comment_rate_pct"] = (df["comment_count"] / df["views"]) * 100
    
    return (
        df.groupby("category")
        .agg(
            Avg_Views=("views", "mean"),
            Avg_Like_Rate_Pct=("like_rate_pct", "mean"),
            Avg_Comment_Rate_Pct=("comment_rate_pct", "mean"),
            Total_Trending_Videos=("video_id", "count")
        )
        .sort_values(by="Avg_Like_Rate_Pct", ascending=False)
        .reset_index()
    )

def evaluate_punctuation_virality(videos_df: pd.DataFrame) -> pd.DataFrame:
    """Tests correlation between title exclamation marks / punctuation and median views."""
    df = videos_df.copy()
    df["has_exclamation"] = df["title"].apply(lambda x: "With Exclamation (!)" if "!" in str(x) else "Standard Title")
    
    return (
        df.groupby("has_exclamation")
        .agg(
            Median_Views=("views", "median"),
            Mean_Views=("views", "mean"),
            Total_Videos=("video_id", "count")
        )
        .reset_index()
    )

if __name__ == "__main__":
    print("YouTube Text Mining & Audience Virality Engine loaded successfully.")
