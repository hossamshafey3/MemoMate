#!/usr/bin/env python3
"""
screening_analytics_viz.py - MemoMate

A custom data visualization system for the 4 screening steps:
  1. Behavioral Check (Binary Scatter Plot)
  2. Lifestyle (Binary Scatter Plot + Continuous Timeline)
  3. Medical History (Binary Scatter Plot)
  4. Vitals & Labs (Binary Scatter Plot + Continuous Timelines)

This script transforms historical patient health-check datasets (either parsed
from input JSON files or auto-generated mock datasets spanning 7 checks)
and renders four beautifully styled figures matching the white and deep-purple
theme context of the MemoMate application.

Theme Palette:
  - White background with clean layouts
  - Subtle low-opacity deep-purple gridlines (#800080)
  - Crimson Red for Yes/Risk present (#D32F2F)
  - Emerald Green for No/Safe status (#388E3C)
  - Accent Deep Purple (#800080) for continuous lines, headers, and highlights

Binary Features Only:
  - Screen 1: Memory Complaints, Behavioral Problems, Confusion,
              Disorientation, Personality Changes, Difficulty Completing Tasks,
              Forgetfulness
  - Screen 2: Smoking (binary only; Alcohol, Physical Activity, Diet, Sleep
              are plotted as continuous line charts)
  - Screen 3: Family History of Alzheimer's, Cardiovascular Disease,
              Diabetes, Depression, Head Injury
  - Screen 4: Hypertension (binary only; BMI, BP, Cholesterol are continuous)

X-axis: Check Sequence 1–7 for all charts
Color Coding for Binary Features:
  Yes (True / On / 1.0) → Crimson Red 🔴 (#D32F2F)
  No  (False / Off / 0.0) → Emerald Green 🟢 (#388E3C)
"""

import os
import json
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime, timedelta

# --- Theme Configuration Constants ---
COLOR_PRIMARY_PURPLE = '#800080'    # Deep Purple
COLOR_SECONDARY_PURPLE = '#E0B0FF'  # Light Purple Accent
COLOR_RISK_RED = '#D32F2F'          # Crimson Red for Yes (symptom present)
COLOR_SAFE_GREEN = '#388E3C'        # Emerald Green for No (normal/clear)
COLOR_WHITE = '#FFFFFF'
COLOR_LIGHT_GREY = '#F9F9FB'
COLOR_TEXT_DARK = '#2E2E3E'
COLOR_TEXT_MUTED = '#757585'
COLOR_GRID = '#800080'              # Subtle gridline base

def setup_matplotlib_style():
    """Configures global Matplotlib styles to match the professional brand theme."""
    plt.rcParams['font.sans-serif'] = 'Arial'
    plt.rcParams['font.family'] = 'sans-serif'
    plt.rcParams['text.color'] = COLOR_TEXT_DARK
    plt.rcParams['axes.labelcolor'] = COLOR_TEXT_DARK
    plt.rcParams['xtick.color'] = COLOR_TEXT_MUTED
    plt.rcParams['ytick.color'] = COLOR_TEXT_MUTED
    plt.rcParams['axes.facecolor'] = COLOR_WHITE
    plt.rcParams['figure.facecolor'] = COLOR_WHITE
    plt.rcParams['grid.color'] = COLOR_GRID
    plt.rcParams['grid.alpha'] = 0.08
    plt.rcParams['grid.linestyle'] = '--'
    plt.rcParams['grid.linewidth'] = 0.8
    plt.rcParams['axes.edgecolor'] = COLOR_SECONDARY_PURPLE
    plt.rcParams['axes.linewidth'] = 1.0

def generate_mock_data():
    """
    Generates a highly realistic mock dataset representing 7 checkups
    for testing, transformation, and visualization.
    """
    # 7 checkups sequence
    check_ids = list(range(1, 8))
    
    # Timeline spanning last few weeks
    base_date = datetime.now() - timedelta(days=21)
    dates = [base_date + timedelta(days=3 * i) for i in range(7)]
    dates_str = [d.strftime('%Y-%m-%d %H:%M:%S') for d in dates]
    
    data = []
    
    # Seed for reproducibility
    np.random.seed(42)
    
    # State evolution for realistic patient history (some complaints reducing or increasing)
    for i in check_ids:
        # Check index (1 to 7)
        idx = i - 1
        
        # Screen 1: Behavioral Check (Binary Yes/No)
        # Complains fluctuate, showing some progress or persistent issues
        memory_complaints = 1 if idx in [0, 1, 2, 4, 6] else 0
        behavioral_problems = 1 if idx in [1, 2] else 0
        confusion = 1 if idx in [0, 2, 3] else 0
        disorientation = 1 if idx in [2] else 0
        personality_changes = 0 # stays clear
        difficulty_tasks = 1 if idx in [0, 1, 3] else 0
        forgetfulness = 1 if idx in [0, 1, 2, 4, 5, 6] else 0
        
        # Screen 2: Lifestyle
        smoking = 1 if idx in [0, 1, 2] else 0 # Stopped smoking after check 3!
        alcohol = max(0.0, 4.0 - 0.5 * idx + np.random.normal(0, 0.2)) # decreasing trend
        physical_activity = min(10.0, 2.0 + 1.0 * idx + np.random.normal(0, 0.3)) # increasing exercise
        diet_quality = min(10.0, 5.0 + 0.6 * idx + np.random.normal(0, 0.2)) # improving diet
        sleep_quality = min(10.0, 4.0 + 0.8 * idx + np.random.normal(0, 0.4)) # improving sleep
        
        # Screen 3: Medical History (Stays relatively constant, but can change or fluctuate in checks)
        family_history = 1 # Alzheimer's in family
        cardiovascular = 0
        diabetes = 1
        depression = 1 if idx in [0, 1, 2, 3] else 0 # Recovered from depressive symptoms
        head_injury = 0
        
        # Screen 4: Vitals & Labs
        hypertension = 1 if idx in [0, 1, 2, 4] else 0 # Well-controlled hypertension later
        bmi = 28.5 - 0.2 * idx + np.random.normal(0, 0.1) # steady healthy weight loss
        systolic_bp = 142 - 3.5 * idx + np.random.normal(0, 2.0) # normalising blood pressure
        diastolic_bp = 88 - 2.0 * idx + np.random.normal(0, 1.5)
        chol_total = 240 - 8 * idx + np.random.normal(0, 3.0)
        chol_ldl = 155 - 6 * idx + np.random.normal(0, 2.5)
        chol_hdl = 42 + 1.2 * idx + np.random.normal(0, 0.8)
        chol_trig = 180 - 10 * idx + np.random.normal(0, 4.0)

        record = {
            "id": f"check_{i}",
            "createdAt": dates_str[idx],
            "checkIndex": i,
            "features": {
                # Behavioral Check
                "MemoryComplaints": memory_complaints,
                "BehavioralProblems": behavioral_problems,
                "Confusion": confusion,
                "Disorientation": disorientation,
                "PersonalityChanges": personality_changes,
                "DifficultyCompletingTasks": difficulty_tasks,
                "Forgetfulness": forgetfulness,
                
                # Lifestyle
                "Smoking": smoking,
                "AlcoholConsumption": alcohol,
                "PhysicalActivity": physical_activity,
                "DietQuality": diet_quality,
                "SleepQuality": sleep_quality,
                
                # Medical History
                "FamilyHistoryAlzheimers": family_history,
                "CardiovascularDisease": cardiovascular,
                "Diabetes": diabetes,
                "Depression": depression,
                "HeadInjury": head_injury,
                
                # Vitals & Labs
                "Hypertension": hypertension,
                "BMI": bmi,
                "SystolicBP": systolic_bp,
                "DiastolicBP": diastolic_bp,
                "CholesterolTotal": chol_total,
                "CholesterolLDL": chol_ldl,
                "CholesterolHDL": chol_hdl,
                "CholesterolTriglycerides": chol_trig
            }
        }
        data.append(record)
        
    return data

def parse_patient_checks_json(json_file_path):
    """
    Parses a patient checks JSON file of 32-feature checks.
    Fallback to generating mock data if file not found or corrupted.
    """
    if not json_file_path or not os.path.exists(json_file_path):
        print(f"[*] JSON input file not found or not provided. Generating 7 mock checkups instead.")
        return generate_mock_data()
        
    try:
        with open(json_file_path, 'r', encoding='utf-8') as f:
            raw_data = json.load(f)
            
        # Standardise list structure
        if isinstance(raw_data, dict):
            checks = raw_data.get('data', raw_data.get('checks', raw_data.get('results', [])))
        elif isinstance(raw_data, list):
            checks = raw_data
        else:
            checks = []
            
        if not checks:
            print("[!] Empty checks list in JSON. Using generated mock data.")
            return generate_mock_data()
            
        # Ensure they are sorted by date ascending
        def parse_date(x):
            raw = x.get('createdAt') or x.get('created_at') or x.get('date') or ''
            try:
                return datetime.strptime(raw.split('.')[0], '%Y-%m-%dT%H:%M:%S')
            except Exception:
                try:
                    return datetime.strptime(raw, '%Y-%m-%d %H:%M:%S')
                except Exception:
                    return datetime.now()
                    
        checks.sort(key=parse_date)
        
        # Take the last 7 checks to represent the standard 1:7 sequence
        recent_checks = checks[-7:] if len(checks) > 7 else checks
        
        # Attach tracking index (1 to N)
        for idx, check in enumerate(recent_checks):
            check['checkIndex'] = idx + 1
            
        return recent_checks
    except Exception as e:
        print(f"[!] Error parsing JSON file: {e}. Falling back to generated mock data.")
        return generate_mock_data()

def transform_to_dataframe(checks_data):
    """Transforms raw nested API-like list data into a flat, clean Pandas DataFrame."""
    flat_records = []
    for check in checks_data:
        idx = check.get('checkIndex', 1)
        created_at_str = check.get('createdAt') or check.get('created_at') or ''
        
        # Extract features dictionary
        features = check.get('features', {})
        if not features:
            # Fallback to scanning flat keys in check
            features = {k: v for k, v in check.items() if k not in ['id', 'createdAt', 'created_at', 'date', 'checkIndex']}
            
        record = {
            'checkIndex': idx,
            'createdAt': created_at_str,
            # Behavioral Check
            'MemoryComplaints': float(features.get('MemoryComplaints', 0)),
            'BehavioralProblems': float(features.get('BehavioralProblems', 0)),
            'Confusion': float(features.get('Confusion', 0)),
            'Disorientation': float(features.get('Disorientation', 0)),
            'PersonalityChanges': float(features.get('PersonalityChanges', 0)),
            'DifficultyCompletingTasks': float(features.get('DifficultyCompletingTasks', 0)),
            'Forgetfulness': float(features.get('Forgetfulness', 0)),
            
            # Lifestyle
            'Smoking': float(features.get('Smoking', 0)),
            'AlcoholConsumption': float(features.get('AlcoholConsumption', 0)),
            'PhysicalActivity': float(features.get('PhysicalActivity', 0)),
            'DietQuality': float(features.get('DietQuality', 0)),
            'SleepQuality': float(features.get('SleepQuality', 0)),
            
            # Medical History
            'FamilyHistoryAlzheimers': float(features.get('FamilyHistoryAlzheimers', 0)),
            'CardiovascularDisease': float(features.get('CardiovascularDisease', 0)),
            'Diabetes': float(features.get('Diabetes', 0)),
            'Depression': float(features.get('Depression', 0)),
            'HeadInjury': float(features.get('HeadInjury', 0)),
            
            # Vitals & Labs
            'Hypertension': float(features.get('Hypertension', 0)),
            'BMI': float(features.get('BMI', 0)),
            'SystolicBP': float(features.get('SystolicBP', 0)),
            'DiastolicBP': float(features.get('DiastolicBP', 0)),
            'CholesterolTotal': float(features.get('CholesterolTotal', 0)),
            'CholesterolLDL': float(features.get('CholesterolLDL', 0)),
            'CholesterolHDL': float(features.get('CholesterolHDL', 0)),
            'CholesterolTriglycerides': float(features.get('CholesterolTriglycerides', 0))
        }
        flat_records.append(record)
        
    return pd.DataFrame(flat_records)

# ==============================================================================
#  SCATTER PLOT UTILITIES (COLOR-CODING ENGINE)
# ==============================================================================

def draw_binary_scatter(ax, df, features_mapping, xlabel='Check Sequence (1 → 7)'):
    """
    Draws a highly readable binary scatter plot on a given matplotlib axes.
    - Y-axis: Categorical binary feature names clearly displayed.
    - X-axis: 1:7 sequence index.
    - Color Coding:
        - 1.0 (Yes / True / On) -> Crimson Red 🔴 (#D32F2F)
        - 0.0 (No / False / Off) -> Emerald Green 🟢 (#388E3C)
    """
    # X axis coordinates (1 to 7 sequence)
    x_vals = df['checkIndex'].values
    
    # We plot each feature as a distinct line index on the Y-axis
    for y_idx, (feature_key, feature_name) in enumerate(features_mapping.items()):
        y_vals = np.full_like(x_vals, y_idx, dtype=float)
        values = df[feature_key].values
        
        # Color coding mask
        yes_mask = (values == 1.0)
        no_mask = (values == 0.0)
        
        # Scatter points for Yes (Crimson Red)
        if np.any(yes_mask):
            ax.scatter(
                x_vals[yes_mask], y_vals[yes_mask],
                color=COLOR_RISK_RED, s=280, marker='o',
                edgecolors=COLOR_WHITE, linewidths=1.5,
                label='Risk Present (Yes)' if y_idx == 0 else "",
                zorder=3
            )
            
        # Scatter points for No (Emerald Green)
        if np.any(no_mask):
            ax.scatter(
                x_vals[no_mask], y_vals[no_mask],
                color=COLOR_SAFE_GREEN, s=280, marker='o',
                edgecolors=COLOR_WHITE, linewidths=1.5,
                label='Normal Status (No)' if y_idx == 0 else "",
                zorder=3
            )

    # Style axes
    ax.set_yticks(range(len(features_mapping)))
    ax.set_yticklabels(list(features_mapping.values()), fontsize=11, fontweight='500')
    ax.set_ylim(-0.6, len(features_mapping) - 0.4)
    
    ax.set_xticks(range(1, 8))
    ax.set_xlim(0.5, 7.5)
    ax.set_xlabel(xlabel, fontsize=11, labelpad=8, fontweight='500')
    
    # Background grid & styling
    ax.grid(True, zorder=1)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color(COLOR_SECONDARY_PURPLE)
    ax.spines['bottom'].set_color(COLOR_SECONDARY_PURPLE)

# ==============================================================================
#  SCREEN 1: BEHAVIORAL CHECK (BINARY SCATTER)
# ==============================================================================

def plot_screen_1_behavioral_check(df, output_path):
    """Renders behavioral check binary scatter plot."""
    features = {
        "MemoryComplaints": "Memory Complaints",
        "BehavioralProblems": "Behavioral Problems",
        "Confusion": "Confusion",
        "Disorientation": "Disorientation",
        "PersonalityChanges": "Personality Changes",
        "DifficultyCompletingTasks": "Difficulty Completing Tasks",
        "Forgetfulness": "Forgetfulness"
    }
    
    fig, ax = plt.subplots(figsize=(10, 6.5))
    fig.patch.set_facecolor(COLOR_WHITE)
    
    # Main Header
    fig.suptitle("Screen 1: Behavioral Check Progression", fontsize=15, color=COLOR_PRIMARY_PURPLE, fontweight='bold', y=0.96)
    ax.set_title("Progression tracking of cognitive and behavioral indicators across the last 7 checks", fontsize=11, color=COLOR_TEXT_MUTED, pad=12)
    
    draw_binary_scatter(ax, df, features)
    
    # Legend handling
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_RISK_RED, markersize=14, markeredgecolor='w', label='Risk/Symptom Present (Yes)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_SAFE_GREEN, markersize=14, markeredgecolor='w', label='Normal/Clear Status (No)')
    ]
    ax.legend(handles=legend_elements, loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=2, frameon=True, facecolor=COLOR_LIGHT_GREY, edgecolor=COLOR_SECONDARY_PURPLE)
    
    plt.tight_layout()
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[+] Screen 1: Behavioral Check plot saved to -> {output_path}")

# ==============================================================================
#  SCREEN 2: LIFESTYLE (BINARY SCATTER + CONTINUOUS TIMELINES)
# ==============================================================================

def plot_screen_2_lifestyle(df, output_path):
    """Renders Lifestyle screen: Smoking (Binary) + 4 Continuous Parameters on Standard Scales."""
    fig, (ax_top, ax_bot) = plt.subplots(2, 1, figsize=(10, 8.5), gridspec_kw={'height_ratios': [1, 3.5]})
    fig.patch.set_facecolor(COLOR_WHITE)
    
    fig.suptitle("Screen 2: Lifestyle Analytics", fontsize=15, color=COLOR_PRIMARY_PURPLE, fontweight='bold', y=0.97)
    
    # 1. Top Subplot: Smoking (Binary Switch)
    ax_top.set_title("Smoking Habit Switch Timeline", fontsize=11, color=COLOR_PRIMARY_PURPLE, fontweight='600', loc='left', pad=6)
    draw_binary_scatter(ax_top, df, {"Smoking": "Smoking Habit"}, xlabel="")
    ax_top.set_xticklabels([])  # Hide x ticks for top plot
    
    # Legend for Smoking
    from matplotlib.lines import Line2D
    smoking_legend = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_RISK_RED, markersize=12, label='Smoking (Yes)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_SAFE_GREEN, markersize=12, label='Non-Smoking (No)')
    ]
    ax_top.legend(handles=smoking_legend, loc='center left', bbox_to_anchor=(1.02, 0.5), frameon=True, edgecolor=COLOR_SECONDARY_PURPLE, fontsize=9)

    # 2. Bottom Subplot: Lifestyle Continuous Indicators
    ax_bot.set_title("Continuous Lifestyle Indicators (Standard 0-10 Scale)", fontsize=11, color=COLOR_PRIMARY_PURPLE, fontweight='600', loc='left', pad=10)
    
    x_vals = df['checkIndex'].values
    
    # Plot curves with modern colors matching the deep-purple palette context
    colors = ['#800080', '#6A5ACD', '#9370DB', '#BA55D3'] # deep purple, slate blue, medium purple, orchid
    markers = ['o', 's', '^', 'd']
    
    ax_bot.plot(x_vals, df['AlcoholConsumption'], color=colors[0], marker=markers[0], markersize=8, linewidth=2.5, label='Alcohol Consumption (Liters/wk)')
    ax_bot.plot(x_vals, df['PhysicalActivity'], color=colors[1], marker=markers[1], markersize=8, linewidth=2.5, label='Physical Activity (Hours/wk)')
    ax_bot.plot(x_vals, df['DietQuality'], color=colors[2], marker=markers[2], markersize=8, linewidth=2.5, label='Diet Quality Index (0-10)')
    ax_bot.plot(x_vals, df['SleepQuality'], color=colors[3], marker=markers[3], markersize=8, linewidth=2.5, label='Sleep Quality Index (0-10)')
    
    ax_bot.set_ylabel("Numerical Score / Scale", fontsize=11, fontweight='500')
    ax_bot.set_xlabel("Check Sequence (1 → 7)", fontsize=11, labelpad=8, fontweight='500')
    ax_bot.set_ylim(-0.5, 11.5)
    ax_bot.set_yticks(range(0, 13, 2))
    ax_bot.set_xticks(range(1, 8))
    ax_bot.set_xlim(0.5, 7.5)
    
    ax_bot.grid(True, zorder=1)
    ax_bot.spines['top'].set_visible(False)
    ax_bot.spines['right'].set_visible(False)
    ax_bot.spines['left'].set_color(COLOR_SECONDARY_PURPLE)
    ax_bot.spines['bottom'].set_color(COLOR_SECONDARY_PURPLE)
    
    # Legend
    ax_bot.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=2, frameon=True, facecolor=COLOR_LIGHT_GREY, edgecolor=COLOR_SECONDARY_PURPLE)
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[+] Screen 2: Lifestyle plot saved to -> {output_path}")

# ==============================================================================
#  SCREEN 3: MEDICAL HISTORY (BINARY SCATTER)
# ==============================================================================

def plot_screen_3_medical_history(df, output_path):
    """Renders Medical History binary scatter plot."""
    features = {
        "FamilyHistoryAlzheimers": "Family History of Alzheimer's",
        "CardiovascularDisease": "Cardiovascular Disease",
        "Diabetes": "Diabetes Status",
        "Depression": "Depression Status",
        "HeadInjury": "Head Injury History"
    }
    
    fig, ax = plt.subplots(figsize=(10, 6.2))
    fig.patch.set_facecolor(COLOR_WHITE)
    
    fig.suptitle("Screen 3: Medical History Overview", fontsize=15, color=COLOR_PRIMARY_PURPLE, fontweight='bold', y=0.96)
    ax.set_title("Timeline tracking of pre-existing conditions and risks across the last 7 checks", fontsize=11, color=COLOR_TEXT_MUTED, pad=12)
    
    draw_binary_scatter(ax, df, features)
    
    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_RISK_RED, markersize=14, markeredgecolor='w', label='Risk/Condition Present (Yes)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_SAFE_GREEN, markersize=14, markeredgecolor='w', label='Normal/Absent Status (No)')
    ]
    ax.legend(handles=legend_elements, loc='upper center', bbox_to_anchor=(0.5, -0.16), ncol=2, frameon=True, facecolor=COLOR_LIGHT_GREY, edgecolor=COLOR_SECONDARY_PURPLE)
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[+] Screen 3: Medical History plot saved to -> {output_path}")

# ==============================================================================
#  SCREEN 4: VITALS & LABS (BINARY SCATTER + MULTIPLE CONTINUOUS SCALES)
# ==============================================================================

def plot_screen_4_vitals_labs(df, output_path):
    """Renders Vitals & Labs: Hypertension (Binary) + BMI/BP/Cholesterol on Standard Scales."""
    fig = plt.figure(figsize=(12, 9.5))
    fig.patch.set_facecolor(COLOR_WHITE)
    
    fig.suptitle("Screen 4: Vitals & Labs Analytics", fontsize=16, color=COLOR_PRIMARY_PURPLE, fontweight='bold', y=0.97)
    
    # Subplot Layout: 
    # Row 1 (Top full-width): Hypertension Scatter
    # Row 2: BMI (Left), BP (Center), Cholesterol (Right)
    
    gs = fig.add_gridspec(2, 3, height_ratios=[1, 3.5])
    
    # 1. Top Subplot: Hypertension (Binary)
    ax_top = fig.add_subplot(gs[0, :])
    ax_top.set_title("Hypertension Diagnosis Timeline", fontsize=11, color=COLOR_PRIMARY_PURPLE, fontweight='600', loc='left', pad=6)
    draw_binary_scatter(ax_top, df, {"Hypertension": "Hypertension"}, xlabel="")
    ax_top.set_xticklabels([])
    
    # Legend for Hypertension
    from matplotlib.lines import Line2D
    ht_legend = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_RISK_RED, markersize=11, label='Hypertension (Yes)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor=COLOR_SAFE_GREEN, markersize=11, label='Normal BP (No)')
    ]
    ax_top.legend(handles=ht_legend, loc='center left', bbox_to_anchor=(1.01, 0.5), frameon=True, edgecolor=COLOR_SECONDARY_PURPLE, fontsize=9)

    x_vals = df['checkIndex'].values

    # 2. Bottom-Left Subplot: BMI (Standard scale 15 - 40)
    ax_bmi = fig.add_subplot(gs[1, 0])
    ax_bmi.set_title("BMI Trend", fontsize=11, color=COLOR_PRIMARY_PURPLE, fontweight='600', loc='left')
    ax_bmi.plot(x_vals, df['BMI'], color='#800080', marker='o', markersize=6, linewidth=2, label='BMI')
    ax_bmi.set_ylabel("BMI (kg/m²)", fontsize=10)
    ax_bmi.set_ylim(15.0, 40.0)
    ax_bmi.set_yticks(range(15, 45, 5))
    # Fill normal range (18.5 - 24.9) in subtle light green
    ax_bmi.axhspan(18.5, 24.9, color='#E8F5E9', alpha=0.5, label='Normal Range')
    ax_bmi.legend(loc='lower left', fontsize=8)

    # 3. Bottom-Center Subplot: Blood Pressure (Systolic & Diastolic, standard scale 50 - 170)
    ax_bp = fig.add_subplot(gs[1, 1])
    ax_bp.set_title("Blood Pressure Progression", fontsize=11, color=COLOR_PRIMARY_PURPLE, fontweight='600', loc='left')
    ax_bp.plot(x_vals, df['SystolicBP'], color='#D32F2F', marker='^', markersize=6, linewidth=2, label='Systolic (mmHg)')
    ax_bp.plot(x_vals, df['DiastolicBP'], color='#1976D2', marker='v', markersize=6, linewidth=2, label='Diastolic (mmHg)')
    ax_bp.set_ylabel("BP (mmHg)", fontsize=10)
    ax_bp.set_ylim(50.0, 170.0)
    ax_bp.set_yticks(range(50, 180, 20))
    ax_bp.legend(loc='lower left', fontsize=8)

    # 4. Bottom-Right Subplot: Cholesterol Panels (Total, LDL, HDL, Triglycerides, standard scale 0 - 320)
    ax_chol = fig.add_subplot(gs[1, 2])
    ax_chol.set_title("Cholesterol & Lipids Panel", fontsize=11, color=COLOR_PRIMARY_PURPLE, fontweight='600', loc='left')
    ax_chol.plot(x_vals, df['CholesterolTotal'], color='#311B92', marker='o', markersize=5, linewidth=1.8, label='Total')
    ax_chol.plot(x_vals, df['CholesterolLDL'], color='#E64A19', marker='s', markersize=5, linewidth=1.8, label='LDL')
    ax_chol.plot(x_vals, df['CholesterolHDL'], color='#388E3C', marker='d', markersize=5, linewidth=1.8, label='HDL')
    ax_chol.plot(x_vals, df['CholesterolTriglycerides'], color='#F57C00', marker='x', markersize=5, linewidth=1.8, label='Triglycerides')
    ax_chol.set_ylabel("Lipids level (mg/dL)", fontsize=10)
    ax_chol.set_ylim(0.0, 320.0)
    ax_chol.set_yticks(range(0, 350, 50))
    ax_chol.legend(loc='upper right', fontsize=8, ncol=2)

    # Styling of the three bottom subplots
    for ax in [ax_bmi, ax_bp, ax_chol]:
        ax.set_xlabel("Check Sequence (1 → 7)", fontsize=10, labelpad=6)
        ax.set_xticks(range(1, 8))
        ax.set_xlim(0.5, 7.5)
        ax.grid(True, zorder=1)
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['left'].set_color(COLOR_SECONDARY_PURPLE)
        ax.spines['bottom'].set_color(COLOR_SECONDARY_PURPLE)

    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[+] Screen 4: Vitals & Labs plot saved to -> {output_path}")

# ==============================================================================
#  MAIN EXECUTION PIPELINE
# ==============================================================================

def main():
    parser = argparse.ArgumentParser(description="MemoMate Screening Steps Data Visualization System.")
    parser.add_argument("--json", type=str, default="", help="Path to patient checks JSON file (optional).")
    parser.add_argument("--outdir", type=str, default="analytics_outputs", help="Directory where generated plots are saved.")
    
    args = parser.parse_args()
    
    # Setup styling config
    setup_matplotlib_style()
    
    # 1. Extract and transform dataset
    print("[*] Extracting and transforming dataset...")
    checks_data = parse_patient_checks_json(args.json)
    df = transform_to_dataframe(checks_data)
    
    print(f"[+] Successfully loaded {len(df)} checkup records. Preparing rendering...")
    
    # Ensure output directory exists
    os.makedirs(args.outdir, exist_ok=True)
    
    # 2. Render each of the 4 screens
    # Screen 1: Behavioral Check Scatter
    plot_screen_1_behavioral_check(
        df, os.path.join(args.outdir, "behavioral_check_scatter.png")
    )
    
    # Screen 2: Lifestyle Scatter + Lines
    plot_screen_2_lifestyle(
        df, os.path.join(args.outdir, "lifestyle_analytics.png")
    )
    
    # Screen 3: Medical History Scatter
    plot_screen_3_medical_history(
        df, os.path.join(args.outdir, "medical_history_scatter.png")
    )
    
    # Screen 4: Vitals & Labs Scatter + Lines
    plot_screen_4_vitals_labs(
        df, os.path.join(args.outdir, "vitals_labs_analytics.png")
    )
    
    print(f"\n[+] SUCCESS! All 4 screening step visualizations are rendered successfully under -> '{args.outdir}/'")

if __name__ == "__main__":
    main()
