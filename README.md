# Multicommodity Capacitated Plant Location Problem (MCPL)

A **Mixed Integer Linear Programming (MILP)** model for the **Multicommodity Capacitated Plant Location Problem**, implemented in **two parallel versions**: an **R script** using the [`ompr`](https://dirkschumacher.github.io/ompr/) framework with the SYMPHONY solver, and a **Microsoft Excel macro workbook** (`.xlsm`).

## Overview

The Multicommodity Capacitated Plant Location Problem (MCPL) is a strategic facility location problem in Operations Research. A company must decide **which potential plant sites to open** and **how to allocate customer demand** across the opened sites — for multiple products simultaneously — minimizing the total cost of fixed site opening and product transportation.

Unlike simpler location models, the MCPL handles multiple products jointly with a shared capacity at each site. Customer demand can be **fractionally split** across multiple sites (each supplying a portion of the total requirement), which increases flexibility but also the model's complexity.

## Repository Contents

| File | Description |
|---|---|
| `Multicommodity Capacitated Plant Location Problem.R` | R script implementing and solving the MCPL via `ompr` and SYMPHONY |
| `Multicommodity_Capacitated_Plant_Location_Problem.xlsm` | Excel macro-enabled workbook with the same model solved via the built-in Solver |
| `CPL_Math_Model_and_Notations.pdf` | Mathematical formulation of the problem (in Italian) |

## Mathematical Formulation

### Sets

- $V_1$ = set of potential plant sites (index $i$)
- $V_2$ = set of customers to serve (index $j$)
- $P$ = set of products (index $p$)
- $A = \{(i,j) : i \in V_1,\ j \in V_2\}$ = set of supply arcs

### Parameters

- $d_{pj}$ = demand for product $p$ at customer $j$; $\forall\, p \in P,\ j \in V_2$
- $f_i$ = daily fixed cost of opening site $i$ (annual cost $/$ working days); $\forall\, i \in V_1$
- $q_i$ = capacity of site $i$ (total units across all products); $\forall\, i \in V_1$
- $c$ = unit transportation cost per product unit per distance unit
- $c_{pij}$ = cost to supply the full demand $d_{pj}$ from site $i$ to customer $j$:

$$
c_{pij} = 2 \cdot c \cdot \text{dist}_{ij} \cdot d_{pj} \qquad \forall\, p \in P,\ (i,j) \in A
$$

> The factor 2 accounts for both the outbound and return trip.

### Feasibility Condition

The problem admits a feasible solution only when total capacity covers total demand:

$$
\displaystyle \sum_{p \in P} \sum_{j \in V_2} d_{pj} \le \sum_{i \in V_1} q_i
$$

### Variables

- $x_{pij}$ = fraction of demand $d_{pj}$ supplied by site $i$ to customer $j$ for product $p$; $0 \le x_{pij} \le 1$

$$
y_i = \begin{cases} 1 & \text{if site } i \in V_1 \text{ is opened} \\ 0 & \text{otherwise} \end{cases}
$$

### Objective Function

**(1)** — Minimize total cost: fixed opening costs + transportation costs

$$
\displaystyle \min \sum_{i \in V_1} f_i \cdot y_i + \sum_{p \in P} \sum_{(i,j) \in A} c_{pij} \cdot x_{pij}
$$

### Constraints

**(2)** — Demand coverage: for each product and customer, the total fraction supplied across all sites must equal 1

$$
\displaystyle \sum_{i \in V_1} x_{pij} = 1 \qquad \forall\, p \in P,\ \forall\, j \in V_2
$$

**(3)** — Capacity: the total demand served by each site (across all products and customers) cannot exceed its capacity, and a site can only serve customers if it is opened

$$
\displaystyle \sum_{p \in P} \sum_{j \in V_2} d_{pj} \cdot x_{pij} \le q_i \cdot y_i \qquad \forall\, i \in V_1
$$

**(4)** — Non-negative fractional allocation

$$
x_{pij} \ge 0 \qquad \forall\, p \in P,\ (i,j) \in A
$$

**(5)** — Binary site opening decision

$$
y_i \in \{0,1\} \qquad \forall\, i \in V_1
$$

> **Note on fractional allocation:** $x_{pij}$ represents a fraction in $[0,1]$, not a quantity. A value of $x_{pij} = 0.4$ means that 40% of customer $j$'s demand for product $p$ is supplied by site $i$. This allows demand to be split across multiple open sites, which distinguishes the MCPL from the classic (single-commodity, binary) Capacitated Plant Location Problem.

A copy of this formulation is also available as a standalone PDF in this repository (written in Italian).

## Example Instance

The script and workbook share a hardcoded instance with **5 potential sites**, **8 customers**, and **2 products**:

**Site parameters:**

| Site $i$ | Fixed cost (annual) | Daily fixed cost $f_i$ | Capacity $q_i$ |
|:---:|---:|---:|---:|
| 1 | 150,000 | 500.00 | 60 |
| 2 | 145,000 | 483.33 | 42 |
| 3 | 180,000 | 600.00 | 58 |
| 4 | 175,000 | 583.33 | 41 |
| 5 | 190,000 | 633.33 | 60 |
| **Total** | | | **261** |

**Customer demands:**

| | Customer 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | **Total** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **Product 1** | 9.5 | 6.1 | 4.8 | 7.3 | 5.5 | 4.0 | 8.0 | 6.1 | 51.3 |
| **Product 2** | 3.2 | 6.2 | 3.1 | 4.9 | 8.7 | 1.2 | 4.0 | 5.3 | 36.6 |
| **Combined** | | | | | | | | | **87.9** |

- **Transportation cost**: $c = 0.30$ per unit of product per unit of distance (round trip × 2)
- **Working days**: 300 per year (used to amortize fixed costs)
- **Feasibility**: total demand (87.9) $\ll$ total capacity (261) ✓

## Requirements

**R version:**

```r
install.packages(c("lpSolve", "dplyr", "ROI", "ROI.plugin.symphony", "ompr", "ompr.roi"))
```

**Excel version:**

- Microsoft Excel with the built-in **Solver Add-in** enabled (`Data → Solver`)
- The `.xlsm` file contains VBA macros — macros must be enabled when opening the file

## Usage

**R script:**

1. Clone or download this repository.
2. Open `Multicommodity Capacitated Plant Location Problem.R` in R or RStudio.
3. Update the `setwd()` path at the top of the script to match your local directory.
4. Run the script. It will:
   - Check the feasibility condition (total capacity ≥ total demand)
   - Build and solve the model using `ompr` and SYMPHONY
   - Print the solver status, optimal total cost, opened sites $y[i] = 1$, and fractional allocations $x[p,i,j] > 0$

**Excel workbook:**

1. Open `Multicommodity_Capacitated_Plant_Location_Problem.xlsm` in Microsoft Excel and enable macros.
2. Run the embedded VBA macro to invoke the Solver and populate the solution directly in the spreadsheet.

## Output

The R script prints:

- **Model status** — whether an optimal solution was found
- **Objective value** — the minimum total daily cost (fixed + transportation)
- **$y[i]$ variables** — which sites are opened
- **$x[p,i,j]$ variables** — for each product, the fractional supply flows from each open site to each customer
