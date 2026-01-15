# Impact and Reliability Analysis Scripts - Complete Guide

**Comprehensive documentation for baseline-endline impact evaluation and data quality assessment**

> **See Also**: [ANALYSIS_GUIDE.md](../../../ANALYSIS_GUIDE.md) in project root for detailed methodology, interpretation, and scientific references.

---

## Overview

This analysis system provides **production-ready, modular Stata scripts** for two core objectives in longitudinal impact evaluation studies:

1. **Impact Analysis**: Measure intervention effectiveness by comparing baseline vs endline outcomes
2. **Reliability Analysis**: Assess data quality by comparing endline vs backcheck measurements
3. **Participant Tracking**: Validate longitudinal linkage using probabilistic record matching

### Key Features

- **Modular Design**: 6 focused scripts vs. single 1870-line monolithic file
- **Central Configuration**: Single source of truth (`00_setup_config.do`)
- **Flexible Execution**: Run individually or via master script with switches
- **Production Quality**: Comprehensive error handling, logging, validation
- **IPA Best Practices**: Follows IPA data quality standards throughout

---

## Quick Start

### Run Everything

```stata
do scripts/do/impact/00_run_all.do
```

### Run Specific Analyses

```stata
do scripts/do/impact/00_setup_config.do          // Configuration (required first)
do scripts/do/impact/03_impact_analysis.do       // Impact analysis
do scripts/do/impact/04_reliability_analysis.do  // Reliability analysis
do scripts/do/impact/05_enumerator_effects.do    // Enumerator effects
do scripts/do/impact/06_participant_tracking.do  // Tracking validation
```

---

## File Structure

```
scripts/do/impact/
├── README.md                   # This guide
├── 00_setup_config.do          # Central configuration
├── 00_run_all.do               # Master script with control switches
├── 01_load_explore.do          # [Optional] Data exploration
├── 02_merge_datasets.do        # [Optional] Dataset merging
├── 03_impact_analysis.do       # Baseline vs Endline impact
├── 04_reliability_analysis.do  # Endline vs Backcheck reliability
├── 05_enumerator_effects.do    # Enumerator/time effects
└── 06_participant_tracking.do  # Probabilistic record linkage
```

---

## Detailed Script Descriptions

### 00_setup_config.do - Central Configuration

**Purpose**: Single source of truth for all paths, variables, and parameters

**Customization Required**:

```stata
// Lines 40-50: File paths
cd "C:\Users\YourName\YourProject"
global baseline "${project_path}/data/raw/baseline.dta"
global endline "${project_path}/data/raw/endline.dta"

// Lines 85-98: Outcome variables
global anthro_outcomes "weight1 height1 muac1"
global idela_outcomes "literacy numeracy motor"

// Lines 111-170: Variable labels
local label_weight1 "Child weight measurement 1 (kg)"
```

**Runtime**: < 1 minute

---

### 03_impact_analysis.do - Impact Assessment

**Purpose**: Quantify intervention impact using paired comparisons

**Statistical Methods**:

- Paired t-tests (significance testing)
- Cohen's d effect sizes (magnitude assessment)
- 95% confidence intervals
- Before-after visualizations

**Effect Size Interpretation**:

- |d| ≥ 0.8: Large effect
- 0.5 ≤ |d| < 0.8: Medium effect
- 0.2 ≤ |d| < 0.5: Small effect
- |d| < 0.2: Negligible

**Outputs**:

- `${tables}/impact_analysis_results.xlsx` - Complete metrics table
- `${figures}/*_beforeafter_*.png` - Box plots and mean plots

**Runtime**: 5-15 minutes

---

### 04_reliability_analysis.do - Quality Assessment

**Purpose**: Assess measurement reliability and data quality

**Statistical Methods**:

- **Bland-Altman Analysis**: Bias and limits of agreement
- **ICC**: Intraclass Correlation Coefficient
- **MAD/MAPE**: Mean absolute differences and percentage errors
- **Quality Flags**: WHO threshold-based flagging

**ICC Interpretation**:

- ICC ≥ 0.90: Excellent reliability
- 0.75 ≤ ICC < 0.90: Good reliability
- 0.50 ≤ ICC < 0.75: Moderate reliability
- ICC < 0.50: Poor reliability (action required)

**WHO Thresholds**:

- Weight: ±0.1 kg (100g)
- Height: ±0.5 cm (5mm)
- MUAC: ±0.5 cm (5mm)

**Outputs**:

- `${tables}/reliability_analysis_results.xlsx` - Reliability metrics
- `${tables}/flagged_observations.xlsx` - Quality control list
- `${figures}/*_bland_altman.png` - Agreement plots
- `${data_processed}/merged_analysis_data_flag.dta` - Dataset with flags

**Runtime**: 5-20 minutes

---

### 05_enumerator_effects.do - Performance Analysis

**Purpose**: Identify enumerator and time effects on measurement reliability

**Statistical Method**: Multiple Linear Regression

```
abs_diff = β₀ + β₁·enum_id + β₂·time_diff + ε
```

**Interpretation**:

- Positive β₁: Enumerator has lower reliability
- Negative β₁: Enumerator has higher reliability
- Stars: *** p<0.01, ** p<0.05, * p<0.10

**Outputs**:

- `${tables}/enumerator_effects_regression.xlsx` - Coefficients with stars
- `${tables}/enumerator_effects_summary.xlsx` - Per-enumerator statistics

**Runtime**: 2-10 minutes

---

### 06_participant_tracking.do - Tracking Validation

**Purpose**: Validate longitudinal participant tracking using multi-level probabilistic matching

This is the most sophisticated component. See [Detailed Participant Tracking Methodology](#detailed-participant-tracking-methodology) below.

**Runtime**: 3-10 minutes

---

## Detailed Participant Tracking Methodology

### Overview

The participant tracking system **validates the quality of longitudinal data linkage** between baseline and endline surveys. Unlike simple ID-based merging, this approach:

1. **Does NOT assume childid is correct** - validates it instead
2. Uses **multiple independent sources of evidence**
3. Creates a **0-100 confidence score** for each match
4. Flags **potential tracking errors** for manual review
5. Provides **detailed diagnostics** for each observation

This is critical because:

- Data entry errors in childid can create false links
- Missing childid values need alternative validation
- Quality documentation requires confidence assessment
- Attrition analysis needs true vs. false attrition distinction

### Theoretical Foundation

The system implements **hierarchical probabilistic record linkage**, a statistical method for matching records across datasets when no perfect unique identifier exists. This approach:

- Assigns **weights** to different matching criteria based on discriminating power
- Combines **multiple weak identifiers** into strong overall evidence
- Handles **missing data** and **partial matches** gracefully
- Produces **probabilistic confidence scores** rather than binary yes/no

**Key References**:

- Fellegi, I. P., & Sunter, A. B. (1969). *A Theory for Record Linkage*. Journal of the American Statistical Association, 64(328), 1183-1210.
- Jaro, M. A. (1989). *Advances in Record-Linkage Methodology*. Journal of the American Statistical Association, 84(406), 414-420.

### Six-Level Matching Hierarchy

#### LEVEL 1: Administrative Location Match (10 points)

**Rationale**: Geographic consistency provides weak but useful evidence. Children typically remain in the same administrative region unless household moves.

**Method**: Exact string matching on administrative variables

**Variables Checked** (in order):

1. `region` - Highest administrative unit
2. `district` - Mid-level administrative unit
3. `school` - School name (if applicable)
4. `schoolid` - School identifier (if applicable)

**Scoring Logic**:

```stata
admin_match = 1 if ANY of the following match:
  - region_bl == region_el  (AND both non-missing)
  - district_bl == district_el  (AND both non-missing)
  - school_bl == school_el  (AND both non-missing)
  - schoolid_bl == schoolid_el  (AND both non-missing)

match_score += 10 if admin_match == 1
```

**Why 10 points?**

- Administrative location is relatively weak evidence (households can move)
- But provides useful context when combined with other evidence
- In practice, ~70-90% of children stay in same admin area

**Limitations**:

- Cannot distinguish between children in same admin area
- Boundary changes or reclassifications can cause false negatives

---

#### LEVEL 2: Household/School ID Match (20 points)

**Rationale**: Household ID is a stronger identifier than admin location, as it's more specific and stable.

**Method**: Exact matching on household/school identifier

**Variables Checked**:

- `hhid` - Household identifier
- Alternative: Any household-level unique ID in your data

**Scoring Logic**:

```stata
household_match = 1 if:
  - hhid_bl == hhid_el  (AND both non-missing)

match_score += 20 if household_match == 1
```

**Why 20 points?**

- Household ID is more specific than admin location
- Relatively stable over survey rounds
- Strong evidence of correct match when combined with other criteria

**Special Considerations**:

- Household splits (children moving to new household) will fail this check
- This is correct behavior - we want to flag these for review
- If household composition is known to change frequently, reduce weight

---

#### LEVEL 3: Child Name Match (30 points - HIGHEST WEIGHT)

**Rationale**: Child's name is the most distinctive individual identifier available. Given name within a local context is often unique enough for reliable matching.

**Method**: Multi-stage string matching with preprocessing

**Stage 1: Name Standardization**

```stata
// Convert to uppercase (case-insensitive matching)
childname_clean = UPPER(childname)

// Trim leading/trailing spaces
childname_clean = TRIM(childname_clean)

// Remove multiple internal spaces
childname_clean = ITRIM(childname_clean)

// Remove common punctuation that varies by data entry style
childname_clean = REMOVE(".", ",", "-", "'")
```

**Why standardize?**

- Data entry inconsistencies: "John", "JOHN", "john" are same person
- Spacing variations: "Mary Jane", "Mary  Jane" are same person
- Punctuation styles: "O'Brien", "OBrien", "O Brien" are same person

**Stage 2: Exact Matching (30 points)**

```stata
childname_match = 1.0 if:
  - childname_bl_clean == childname_el_clean (exact string match)
  - Both names non-missing

match_score += 30 * 1.0 = 30 points
```

**Stage 3: Partial Matching (15 points)**

If exact match fails, try partial match:

```stata
childname_match = 0.5 if:
  - substr(childname_bl_clean, 1, 5) == substr(childname_el_clean, 1, 5)
    (first 5 characters match)
  - Both names at least 5 characters long
  - Both names non-missing

match_score += 30 * 0.5 = 15 points
```

**Why first 5 characters?**

- Captures most of given name (e.g., "JOHN" → "JOHN", "MARIA" → "MARIA")
- Tolerates common variations:
  - Nicknames: "Elizabeth" vs "Elizabeth Ann" → "ELIZA" matches
  - Spelling errors: "Muhammad" vs "Muhammed" → "MUHAM" matches
  - Missing surname: "John Smith" vs "John" → "JOHN " matches
- Balance between false positives and false negatives

**Examples**:

| Baseline | Endline | Match Type | Points | Explanation |
|----------|---------|------------|--------|-------------|
| "John Smith" | "John Smith" | Exact | 30 | Perfect match |
| "María García" | "MARIA GARCIA" | Exact | 30 | Case/accent differences standardized |
| "John Smith" | "John S." | Partial | 15 | "JOHN " matches |
| "Muhammad Ali" | "Muhammed Ali" | Partial | 15 | "MUHAM" matches (spelling variation) |
| "Mary" | "Maria" | No match | 0 | "MARY " ≠ "MARIA" |
| "Bob" | "Robert" | No match | 0 | Too short, no match on first 5 |

**Why 30 points (highest weight)?**

- Names are most distinctive individual characteristic
- Within local geographic context, names are highly discriminating
- Most reliable identifier when available
- Justifies highest weight in the system

**Limitations**:

- Does not handle:
  - Soundex/phonetic matching (could be added)
  - Transposed names (could be added with Levenshtein distance)
  - Multiple names with same first 5 characters
- These are intentional trade-offs for simplicity and transparency

---

#### LEVEL 4: Age Consistency (15 points)

**Rationale**: A child's age should progress predictably based on time between surveys. Biological constraint provides powerful validation.

**Method**: Two-step validation against survey timing

**Step 1: Calculate Expected Age Increase**

```stata
// Calculate time between surveys (in years)
time_gap_years = (subdate_el - subdate_bl) / 365.25

// Calculate actual age change
age_diff = child_age_el - child_age_bl
```

**Step 2: Strict Age Consistency (15 points)**

```stata
age_consistent = 1.0 if:
  - |age_diff - time_gap_years| <= 1.0 year
  - Both ages non-missing
  - Survey dates non-missing

match_score += 15 * 1.0 = 15 points
```

**Example**: If surveys 18 months apart (1.5 years):

- Child aged 5.0 years at baseline
- Expected age at endline: 6.5 years (±1 year tolerance)
- Acceptable range: 5.5 to 7.5 years
- If endline age is 6.3 years → PASS (within ±1 year)
- If endline age is 8.0 years → FAIL (outside tolerance)

**Step 3: Lenient Age Consistency (7.5 points)**

If strict check fails, apply lenient criteria:

```stata
age_consistent = 0.5 if:
  - age_diff >= 0  (age increased or stayed same)
  - age_diff <= 3  (not more than 3 years increase)
  - Both ages non-missing

match_score += 15 * 0.5 = 7.5 points
```

**Example Cases**:

| Baseline Age | Endline Age | Time Gap | age_diff | Status | Points | Explanation |
|--------------|-------------|----------|----------|--------|--------|-------------|
| 5.0 | 6.5 | 1.5 yr | 1.5 | Strict pass | 15 | Perfect alignment |
| 5.0 | 6.3 | 1.5 yr | 1.3 | Strict pass | 15 | Within ±1 year |
| 5.0 | 8.0 | 1.5 yr | 3.0 | Lenient pass | 7.5 | Large but plausible |
| 5.0 | 7.8 | 1.5 yr | 2.8 | Lenient pass | 7.5 | Large but plausible |
| 5.0 | 4.5 | 1.5 yr | -0.5 | FAIL | 0 | Age decreased (impossible) |
| 5.0 | 9.0 | 1.5 yr | 4.0 | FAIL | 0 | Implausibly large increase |

**Why ±1 year tolerance for strict matching?**

- Ages often rounded to nearest year
- Survey dates may be approximate
- Biological age vs. reported age discrepancies
- Birthday timing relative to survey

**Why 3-year maximum for lenient matching?**

- Allows for:
  - Rounding errors (reported ages often rounded)
  - Baseline age underestimation (common in low-literacy contexts)
  - Survey gap measurement errors
- Excludes:
  - Clear data entry errors (5 years → 15 years)
  - Wrong child matched

**Why 15 points?**

- Age is strong biological constraint
- Highly informative when combined with other evidence
- Less weight than name (can be reported imprecisely in many contexts)

**Special Considerations**:

- In contexts where ages are commonly unknown/estimated, consider reducing weight
- For very young children (<2 years), ages often reported in months - convert first
- For older children (>12 years), ages more stable but migration more common

---

#### LEVEL 5: Gender Consistency (10 points)

**Rationale**: Gender should never change across survey rounds. This is a hard biological constraint.

**Method**: Exact matching on gender variable

**Scoring Logic**:

```stata
gender_consistent = 1 if:
  - gender_bl == gender_el  (exact match)
  - Both non-missing

match_score += 10 if gender_consistent == 1
```

**Why only 10 points?**

- While perfect when available, gender has low discriminating power
- Only 2 possible values (Male/Female) in most contexts
- ~50% of random pairs would match by chance
- Valuable as validation but not identification

**Important Note**: Gender mismatch is a **strong negative indicator**:

- If gender differs, likely wrong child (unless data entry error)
- Gender mismatch should trigger manual review even if other criteria match
- This is captured in tracking_issue flagging

**Special Considerations**:

- Ensure consistent coding: "Male"/"Female" vs. 1/2 vs. "M"/"F"
- Missing gender in one wave doesn't count as mismatch (common)
- Gender-neutral names in some cultures increase importance of this check

---

#### LEVEL 6: Caregiver Match (15 points)

**Rationale**: Primary caregiver name provides household-level validation. Caregiver stability indicates stable household composition.

**Method**: Three-tier matching accounting for expected changes

**Tier 1: Exact Caregiver Match (15 points)**

```stata
caregiver_match = 1.0 if:
  - caregiver_bl_clean == caregiver_el_clean  (exact match)
  - Both non-missing

match_score += 15 * 1.0 = 15 points
```

**Tier 2: Documented Caregiver Change (7.5 points)**

If exact match fails but caregiver change is documented:

```stata
caregiver_match = 0.5 if:
  - care_change == 1  (documented change in caregiver)
  - From separate caregiver survey module

match_score += 15 * 0.5 = 7.5 points
```

**Why give points for documented change?**

- Caregiver changes are expected and documented events
- The fact that a change was documented correctly is evidence of good tracking
- Prevents penalizing correct matches where caregiver legitimately changed
- Common scenarios: death, separation, child sent to relatives

**Tier 3: No Match (0 points)**

```stata
caregiver_match = 0 if:
  - Names don't match
  - No documented caregiver change

match_score += 15 * 0 = 0 points
```

**Example Cases**:

| Scenario | Baseline CG | Endline CG | care_change | Match | Points | Explanation |
|----------|-------------|------------|-------------|-------|--------|-------------|
| Stable family | "Mary Johnson" | "Mary Johnson" | 0 | 1.0 | 15 | Same caregiver |
| Expected change | "Mary Johnson" | "Susan Johnson" | 1 | 0.5 | 7.5 | Change documented |
| Possible error | "Mary Johnson" | "Susan Johnson" | 0 | 0.0 | 0 | Undocumented change |
| Marriage | "Mary Smith" | "Mary Jones" | 1 | 0.5 | 7.5 | Name change documented |

**Why 15 points?**

- Caregivers relatively stable in most contexts
- Household-level validation complements child-level name matching
- More stable than child's age (no biological progression)
- Less stable than child's name (caregivers can change)

**Special Considerations**:

- Caregiver data quality often lower than child data (not primary subject)
- Missing caregiver name doesn't count against match
- Multiple caregiver names (mother, father, guardian) - prioritize biological mother if available
- In orphan/vulnerable children contexts, expect higher caregiver turnover

---

### GPS Distance Validation

**Purpose**: Independent geographic validation of participant location

Unlike the 6 hierarchical levels above (which contribute to match_score), GPS validation is a **supplementary check** that doesn't add points but flags potential issues.

**Method**: Great-Circle Distance Calculation (Haversine Formula)

The **Haversine formula** calculates the shortest distance between two points on a sphere (Earth) given their latitude and longitude:

```
d = 2R × arcsin(√[sin²(Δφ/2) + cos(φ₁)cos(φ₂)sin²(Δλ/2)])

where:
  R  = Earth's radius (6,371,000 meters)
  φ₁, φ₂ = latitude of point 1 and point 2 (in radians)
  λ₁, λ₂ = longitude of point 1 and point 2 (in radians)
  Δφ = φ₂ - φ₁
  Δλ = λ₂ - λ₁
```

**Implementation**:

```stata
distance_meters = 2 * 6371000 *
    asin(sqrt(
        sin((radians(latitude_el) - radians(latitude_bl)) / 2)^2 +
        cos(radians(latitude_bl)) * cos(radians(latitude_el)) *
        sin((radians(longitude_el) - radians(longitude_bl)) / 2)^2
    ))
```

**Why Haversine over Euclidean distance?**

- Accounts for Earth's curvature
- Accurate for all distances (Euclidean fails at large distances)
- Standard in geographic information systems

**Multi-Threshold Flagging**:

Rather than a single binary flag, creates multiple threshold flags:

| Threshold | Flag Variable | Interpretation | Typical Cause |
|-----------|---------------|----------------|---------------|
| **50 meters** | `gps_flag_50m` | Very close, likely same compound | GPS precision limits, small moves within compound |
| **100 meters** | `gps_flag_100m` | Close, likely same community | GPS drift, minor household moves |
| **200 meters** | `gps_flag_200m` | Moderate distance | Household move within village, GPS errors |
| **500 meters** | `gps_flag_500m` | Large distance | Household moved to different village, GPS errors |

**Interpretation Guidelines**:

**< 50m**:

- **Interpretation**: Essentially same location
- **Action**: No concern
- **Note**: GPS accuracy typically ±10-50m depending on device and conditions

**50-100m**:

- **Interpretation**: Acceptable variance
- **Action**: No action needed unless other match criteria weak
- **Possible causes**: GPS drift, different spot in same compound, upgraded GPS device

**100-200m**:

- **Interpretation**: Potentially concerning
- **Action**: Review if combined with weak match_score (<60)
- **Possible causes**: Minor household move, systematic GPS error, different GPS device

**200-500m**:

- **Interpretation**: Concerning
- **Action**: Review case
- **Possible causes**: Household moved within area, GPS location error, wrong household

**> 500m**:

- **Interpretation**: High concern
- **Action**: Flag for manual verification
- **Possible causes**: Household migrated, major GPS error, wrong household visited

**Context Matters**:

- **Urban settings**: Lower thresholds (households close together, 50-100m meaningful)
- **Rural settings**: Higher thresholds (households far apart, 200-500m more acceptable)
- **Nomadic/mobile populations**: Very high thresholds or disable GPS check

**Limitations of GPS Validation**:

- GPS coordinates may be missing (device issues, privacy concerns)
- Accuracy varies by device and conditions (tree cover, urban canyons)
- Genuine household moves will fail this check (correct behavior)
- Cannot distinguish between GPS error and household move without other evidence

**Integration with Match Score**:

```
Large GPS distance (>200m) + Low match score (<60) = High priority review
Large GPS distance (>200m) + High match score (>80) = Likely household moved
Small GPS distance (<100m) + Low match score (<60) = Likely data quality issue in other variables
```

---

### Overall Match Score Calculation

**Final Score Formula**:

```
match_score =
    10 × admin_match +                    // 0-10 points
    20 × household_match +                // 0-20 points
    30 × childname_match +                // 0-30 points
    15 × age_consistent +                 // 0-15 points
    10 × gender_consistent +              // 0-10 points
    15 × caregiver_match                  // 0-15 points

Range: 0-100 points
```

**Tracking Status Categories**:

| Score Range | Status | Interpretation | Recommended Action |
|-------------|--------|----------------|-------------------|
| **80-100** | High confidence match | Strong evidence across multiple criteria | Accept match, proceed with analysis |
| **60-79** | Good match | Likely correct, some criteria missing/weak | Accept with documentation of which criteria met |
| **40-59** | Moderate match | Uncertain, mixed evidence | **Manual review recommended** |
| **20-39** | Weak match | Questionable, few criteria met | **Investigate thoroughly** before accepting |
| **0-19** | Very weak/No match | Strong evidence of mismatch or all data missing | **Consider excluding** or extensive manual review |

**Example Match Scenarios**:

**Scenario 1: Perfect Match (Score = 100)**

```
Admin location: ✓ (10 pts)  - Same district
Household ID:   ✓ (20 pts)  - hhid matches
Child name:     ✓ (30 pts)  - "MARIA LOPEZ" = "MARIA LOPEZ"
Age:            ✓ (15 pts)  - 5.0 yr → 6.5 yr, gap = 1.5 yr
Gender:         ✓ (10 pts)  - Female = Female
Caregiver:      ✓ (15 pts)  - "ROSA LOPEZ" = "ROSA LOPEZ"
GPS:            45m         - Same compound
-------------------------
Total: 100 points → High confidence match
```

**Scenario 2: Good Match Despite Missing Data (Score = 70)**

```
Admin location: ✓ (10 pts)  - Same region
Household ID:   ✗ (0 pts)   - hhid missing in baseline
Child name:     ✓ (30 pts)  - "JOHN SMITH" = "JOHN SMITH"
Age:            ✓ (15 pts)  - 7.2 yr → 8.8 yr, gap = 1.6 yr
Gender:         ✓ (10 pts)  - Male = Male
Caregiver:      ✗ (0 pts)   - Name missing in endline
GPS:            N/A         - GPS not collected
-------------------------
Total: 70 points → Good match
```

**Scenario 3: Moderate - Needs Review (Score = 45)**

```
Admin location: ✓ (10 pts)  - Same district
Household ID:   ✗ (0 pts)   - Different hhid
Child name:     ~ (15 pts)  - "MUHAMMED ALI" vs "MUHAMMED" (partial)
Age:            ~ (7.5 pts) - 6.0 yr → 8.5 yr, gap = 1.5 yr (large but plausible)
Gender:         ✓ (10 pts)  - Male = Male
Caregiver:      ✗ (0 pts)   - "FATIMA ALI" vs "AISHA ALI" (no care_change)
GPS:            350m        - Moderate distance
-------------------------
Total: 47.5 points → Moderate match - REVIEW
Issues: Different household, partial name, age suspicious, caregiver changed
Action: Manual verification needed
```

**Scenario 4: Weak - Likely Mismatch (Score = 25)**

```
Admin location: ✓ (10 pts)  - Same region (but large region)
Household ID:   ✗ (0 pts)   - Different hhid
Child name:     ✗ (0 pts)   - "MARY JOHNSON" vs "SUSAN WILLIAMS"
Age:            ~ (7.5 pts) - 5.0 yr → 7.0 yr, gap = 1.2 yr (plausible)
Gender:         ✗ (0 pts)   - Female → Male (MISMATCH!)
Caregiver:      ✗ (0 pts)   - Different names
GPS:            750m        - Large distance
-------------------------
Total: 27.5 points → Weak match
Issues: Gender mismatch is red flag, no name match, large GPS distance
Action: Likely wrong child - exclude from analysis
```

---

### Tracking Issues Identification

The system automatically flags five types of tracking issues:

#### 1. Low Confidence Despite childid

**Criteria**: `match_score < 60` AND `childid exists and matched`

**Meaning**: The childid linked the records, but other validation criteria suggest mismatch

**Possible Causes**:

- Data entry error in childid
- Child ID copied from wrong child
- Systematic ID errors (e.g., leading zeros dropped)

**Example**:

```
childid: "12345" (both waves)
Name: "JOHN" vs "MARY"
Gender: Male vs Female
Age: 5→12 (implausible 7-year jump)
→ Flag: childid likely incorrect despite exact match
```

#### 2. Child Name Mismatch

**Criteria**: `childname_match < 0.5` AND other data present

**Meaning**: Names don't match at all (not even first 5 characters)

**Possible Causes**:

- Different child surveyed
- Major spelling error
- Name changed (rare but possible: adoption, cultural practices)
- Nickname vs. formal name

**Action**: Review both records manually

#### 3. Age Inconsistency

**Criteria**: `age_consistent < 0.5` AND ages available

**Meaning**: Age didn't progress as expected given survey timing

**Possible Causes**:

- Baseline age underestimated
- Endline age overestimated
- Wrong child surveyed
- Data entry error in age or date

**Example**:

```
Baseline: Age 5, Date 2020-01-15
Endline: Age 4, Date 2021-06-20
→ Age decreased (impossible)
```

#### 4. Gender Mismatch

**Criteria**: `gender_consistent == 0` AND both genders non-missing

**Meaning**: Gender changed across waves (impossible biologically)

**Possible Causes**:

- Different child surveyed (most likely)
- Data entry error in gender field
- Miscoding of gender variable

**Note**: This is a **hard constraint violation** - should always trigger review

#### 5. Large GPS Location Change

**Criteria**: `distance_meters > 200` meters

**Meaning**: Significant geographic distance between baseline and endline

**Possible Causes**:

- Household moved (genuine)
- GPS error at one or both waves
- Wrong household visited in endline
- Different household member surveyed

**Context-Dependent**: 200m may be acceptable in rural areas but concerning in urban

---

### Practical Usage Examples

#### Example 1: Standard Analysis Workflow

```stata
// Step 1: Run tracking validation
do scripts/do/impact/00_setup_config.do
do scripts/do/impact/06_participant_tracking.do

// Step 2: Review tracking results
use "${tables}/participant_tracking_validation.xlsx", clear

// Step 3: Examine distribution of match scores
histogram match_score, width(10) ///
    xtitle("Match Score") ytitle("Frequency") ///
    title("Distribution of Tracking Match Scores")

// Step 4: List high-priority review cases
list childid match_score tracking_issue ///
    if match_score < 60 | tracking_issue != "", ///
    clean noobs

// Step 5: Export for manual review
preserve
    keep if match_score < 60 | tracking_issue != ""
    export excel using "manual_review_cases.xlsx", firstrow(variables) replace
restore

// Step 6: Decide on thresholds for analysis
// Option A: Conservative (only high confidence)
keep if match_score >= 80

// Option B: Moderate (good or better)
keep if match_score >= 60

// Option C: Include all, add match_score as control variable
// (no filtering, but document in analysis)
```

#### Example 2: Investigating Low Match Scores

```stata
// Load tracking data
use "${data_processed}/merged_analysis_data_tracked.dta", clear

// Examine which criteria are causing low scores
tabstat admin_match household_match childname_match ///
        age_consistent gender_consistent caregiver_match ///
        if match_score < 60, ///
        stat(mean n) col(stat)

// Example output interpretation:
// If admin_match = 90% but childname_match = 10%
// → Name data quality is the issue, not geography

// Check for systematic patterns
table tracking_status region, stat(freq)
// Are low scores clustered in certain regions?

table tracking_status enum_id_el, stat(freq)
// Are low scores clustered by enumerator?
```

#### Example 3: GPS Distance Analysis

```stata
// Examine GPS distance distribution
use "${data_processed}/merged_analysis_data_tracked.dta", clear

histogram distance_meters if distance_meters < 1000, ///
    width(50) ///
    xtitle("GPS Distance (meters)") ///
    title("Distribution of GPS Distances (< 1km shown)")

// Compare match scores by GPS distance category
gen gps_category = ""
replace gps_category = "< 50m" if distance_meters < 50
replace gps_category = "50-100m" if distance_meters >= 50 & distance_meters < 100
replace gps_category = "100-200m" if distance_meters >= 100 & distance_meters < 200
replace gps_category = "> 200m" if distance_meters >= 200

tabstat match_score, by(gps_category) stat(mean n) col(stat)

// Example interpretation:
// If mean match_score is high even for >200m category
// → Likely genuine household moves rather than GPS errors
```

#### Example 4: Attrition Analysis with Tracking Data

```stata
// True vs. False Attrition
use "${data_processed}/merged_analysis_data_tracked.dta", clear

// Define attrition categories
gen attrition_type = ""
replace attrition_type = "Not attrition" if in_baseline == 1 & in_endline == 1
replace attrition_type = "True attrition" if in_baseline == 1 & in_endline == 0
replace attrition_type = "Possible false attrition" if in_baseline == 1 & in_endline == 0 & ///
                                                         match_score < 60 & match_score != .

// Tracking scores for "found" participants
table attrition_type tracking_status, stat(freq)

// This reveals whether apparent attrition might actually be tracking failures
```

---

### Customization Options

#### Adjust Point Weights

If your context differs, edit `06_participant_tracking.do`:

```stata
// Lines 193, 213, 255, 284, 312, 336 - Change point allocations
replace match_score = match_score + 10 if admin_match == 1       // Change 10
replace match_score = match_score + 20 if household_match == 1   // Change 20
replace match_score = match_score + (30 * childname_match)       // Change 30
replace match_score = match_score + (15 * age_consistent)        // Change 15
replace match_score = match_score + 10 if gender_consistent == 1 // Change 10
replace match_score = match_score + (15 * caregiver_match)       // Change 15
```

**When to adjust**:

- **Increase name weight (30→40)** if names very distinctive in your context
- **Decrease caregiver weight (15→10)** if caregiver changes very common
- **Increase household_id weight (20→30)** if household IDs very reliable
- **Decrease age weight (15→10)** if ages commonly unknown/unreliable

#### Modify Name Matching Threshold

```stata
// Line 246 - Change from 5 to different value
substr(childname_bl_clean, 1, 5) == substr(childname_el_clean, 1, 5)
//                            ^change this number

// Options:
// 3: Very lenient (many false positives)
// 4: Lenient
// 5: Standard (recommended)
// 6-7: Strict (may miss valid matches)
```

#### Adjust GPS Thresholds

Edit `00_setup_config.do` Lines 188-191:

```stata
// Urban context (strict)
global gps_threshold_low 25      // vs default 50
global gps_threshold_medium 50   // vs default 100
global gps_threshold_high 100    // vs default 200

// Rural context (lenient)
global gps_threshold_low 100     // vs default 50
global gps_threshold_medium 200  // vs default 100
global gps_threshold_high 500    // vs default 200
```

#### Add Custom Matching Criteria

To add a new matching level, insert in `06_participant_tracking.do` after Line 340:

```stata
/*--- LEVEL 7: YOUR CUSTOM CRITERION (XX POINTS) ---*/
di _n "LEVEL 7: Your Custom Criterion"

gen your_match = 0
// Your matching logic here
// ...

replace match_score = match_score + XX if your_match == 1
label variable your_match "Description of your match"
```

**Examples of custom criteria**:

- Phone number matching (if collected)
- Biometric data (fingerprint, photo matching)
- Unique ID number (national ID, birth certificate)
- Father's name (if distinctive)
- Special identifying features

---

## Statistical Methods

### Impact Analysis

**Paired T-Test**:

```
t = (mean_diff - 0) / (SD_diff / √n)
```

**Cohen's d**:

```
d = (Mean_el - Mean_bl) / SD_bl
```

**Interpretation**: Small (0.2), Medium (0.5), Large (0.8)

### Reliability Analysis

**Bland-Altman**:

```
Bias = Mean(Endline - Backcheck)
LoA = Bias ± 1.96 × SD_diff
```

**ICC (Intraclass Correlation)**:

```
ICC = (MS_between - MS_within) / (MS_between + MS_within)
```

**Interpretation**: Poor (<0.50), Moderate (0.50-0.75), Good (0.75-0.90), Excellent (≥0.90)

---

## Quality Standards

### WHO Anthro Thresholds

- Weight: ±0.1 kg
- Height: ±0.5 cm
- MUAC: ±0.5 cm

### IPA Backcheck Standards

- Coverage: 5-10% of main survey
- Timing: Within 1-7 days
- Acceptable flagging: <5% excellent, 5-10% acceptable, >10% concerning

---

## Customization Guide

### Essential (Required)

1. **File Paths** (`00_setup_config.do` Lines 40-50)
2. **Outcome Variables** (Lines 85-98)
3. **Variable Labels** (Lines 111-170)

### Optional

4. **Thresholds** (Lines 183-214)
5. **Tracking Weights** (`06_participant_tracking.do` Lines 193-336)
6. **GPS Thresholds** (`00_setup_config.do` Lines 188-191)

---

## Output Files

```
outputs/
├── tables/
│   ├── impact_analysis_results.xlsx
│   ├── reliability_analysis_results.xlsx
│   ├── enumerator_effects_regression.xlsx
│   ├── participant_tracking_validation.xlsx
│   ├── flagged_observations.xlsx
│   └── tracking_issues.xlsx
├── figures/
│   ├── *_beforeafter_boxplot.png
│   ├── *_bland_altman.png
│   └── *_scatter_agreement.png
└── logs/
    └── [timestamped logs]
```

---

## Troubleshooting

### Common Issues

1. **"File not found"**: Check paths in `00_setup_config.do`
2. **"Variable not found"**: Update variable lists in config
3. **"No numeric pairs"**: Variables may be string - check types
4. **Low match scores**: Review name data quality, consider adjusting weights

See full troubleshooting section in script comments.

---

## References

### Methodological

- Cohen, J. (1988). Statistical power analysis. Erlbaum.
- Bland & Altman (1986). Statistical methods for assessing agreement. Lancet, 327(8476), 307-310.
- Fellegi & Sunter (1969). A Theory for Record Linkage. JASA, 64(328), 1183-1210.

### Quality Standards

- WHO (2006). Child Growth Standards Training Course.
- IPA (2015). Data Quality Assurance Guidelines.

### Technical

- Stata manuals: `help [command]`
- IPA: <https://www.poverty-action.org/researchers/research-resources>

---

**Version**: 1.0
**Last Updated**: January 2026
**Stata Version**: 16+
**Author**: [Your name/team]

For detailed methodology and interpretation, see: [ANALYSIS_GUIDE.md](../../../ANALYSIS_GUIDE.md)

---

*End of README*
