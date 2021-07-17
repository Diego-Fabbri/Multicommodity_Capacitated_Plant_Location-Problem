#Set your own working directory
setwd("C:/Users/diego/Documents/R/Projects/GitHub_Projects/Optimization/Multicommodity Capacitated Plant Location Problem")

# Import lpSolve package
library(lpSolve)

#Import required packages
library(dplyr)
library(ROI)
library(ROI.plugin.symphony)
library(ompr)
library(ompr.roi)

#Set numbers of potential location
n <- 5

#Set number of customers
m <- 8

#Set number of products
P <- 2

#Set number of working days
w_days <- 300

#Set transportation cost [$/dist*n_products]
c <- 0.3

#Set cost c_1ij 
c1 <- matrix(c( 0,  49.41,   72,   173.01,   24.75,   69.6,   86.4,   82.35,
               76.95, 0.00, 37.44,  100.74,   34.65,   63.6,   79.2,   69.54,
               142.5,  47.58,     0,  148.92,   99.00,   16.8,  80.00,  102.48,
               225.15, 84.18, 97.92,    0.00,    92.4,  111.6,   62.4,   80.52,
               42.75,  38.43,   86.4, 122.64,    0.00,   45.6,  60.00,  102.48),
               nrow = n,byrow = TRUE)

#Set cost c_2ij 
c2 <- matrix(c(0.00, 50.22, 46.50, 116.13, 39.15, 20.88, 43.20, 71.55,
               25.92, 0.00, 24.18, 67.62, 54.81, 19.08, 39.60, 60.42,
               48.00, 48.36, 0.00, 99.96, 156.60, 5.04, 90.00, 89.04,
               75.84, 85.56, 63.24, 0.00, 146.16, 33.48, 31.20, 69.96,
               14.40, 39.06, 55.80, 82.32, 0.00, 13.68, 30.00, 89.04),
                nrow = n,byrow = TRUE)

#Set fixed costs
CF <- c(150000, 145000, 180000, 175000, 190000)

for(i in 1:n){
  CF[i] <- CF[i]/w_days
}

#Set demands
d <- matrix(c(9.5, 6.1, 4.8, 7.3, 5.5, 4.00, 8.00, 6.1,
              3.2, 6.2, 3.1, 4.9, 8.7,  1.2, 4.00, 5.3),
              nrow = 2, byrow = TRUE)

#Set capacities
cap <- c(60, 42, 58, 41, 60)

#Check feasibility condition
total_demand <- sum(d)
total_capacity <- sum(cap)

if(total_demand <= total_capacity){
  condition <- TRUE
} else{ condition <- FALSE}

#Build Model
if(condition == TRUE){
  
  Model <- MIPModel() %>%
    add_variable(x[p,i,j],p = 1:P, i = 1:n, j = 1:m, type = "continuous", lb=0) %>% #define variables
    add_variable(y[i], i = 1:n , type = "binary") %>%
    set_objective(expr = sum_expr(y[i]*CF[i], i = 1:n) + 
                         sum_expr(x[1,i,j]*c1[i,j], i = 1:n, j = 1:m) +
                         sum_expr(x[2,i,j]*c2[i,j], i = 1:n, j = 1:m),
                  sense = "min") %>% #define objective
    add_constraint(sum_expr(x[p,i,j],i = 1:n) == 1,p = 1:P, j = 1:m) %>% #define constraints
    add_constraint(sum_expr(x[p,i,j]*d[p,j],p = 1:P, j = 1:m) <= y[i]*cap[i], i = 1:n) %>%
    solve_model(with_ROI(solver = "symphony", verbosity = 1))
  
  #Model summary
  ##Status
  print(paste("Model status is:", Model$status))
  
  ##Objective Function
  print(paste("Objective value:", objective_value(Model)))
  
  ##Variables
  for (r in 1:n) {
    tmp_y <- get_solution(Model, y[i]) %>%
      filter(variable == "y", i == r) %>%
      select(value)
    
    
    if(tmp_y !=0) {print(paste("--->y[", r , "] =", tmp_y))}
  }
  for(k in 1:P)
  for (r in 1:n) {
    for(c in 1:m){
      tmp <- get_solution(Model, x[p,i,j]) %>%
        filter(variable == "x", i == r, j == c, p == k) %>%
        select(value)
      
      
      if(tmp !=0) {print(paste("--->x[",k,",", r,",",c, "] =", tmp))}
    }
  }
  
} else {print(paste("Feasibility Condition does not hold")) }




