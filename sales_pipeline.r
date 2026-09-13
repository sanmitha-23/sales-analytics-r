# load tidyverse package
library(tidyverse)

# tibble: modern version of R's df

# create users table
users <- tibble(
  user_id = c(101, 102, 103, 104, 105), # c(): combine function
  name = c("Alice", "Bob", "Eve", "John", "Charles"),
  country = c("US", "UK", "DE", "US", "UK")
)

# create purchases table
purchases <- tibble(
  purchase_id = 1:7,
  # Number from 1 to 7, inclusive;
  # equivalent to purchase_id = c(1, 2, 3, 4, 5, 6, 7)
  user_id = c(103, 102, 104, 102, 101, 101, 103),
  amount = c(25.00, 30.00, 10.50, 22.50, 10.20, 50.00, 80.00),
  category = c("Electronics", "Books", "Garden", "Electronics", "Garden",
               "Groceries", "Electronics")
)