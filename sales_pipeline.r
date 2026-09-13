# Load the tidyverse package
library(tidyverse)

# tibble: modern version of R's df

# Create users table
users <- tibble(
  user_id = c(101, 102, 103, 104, 105), # c(): combine function
  name = c("Alice", "Bob", "Eve", "John", "Charles"),
  country = c("US", "UK", "DE", "US", "UK")
)

# Create purchases table
purchases <- tibble(
  purchase_id = 1:7,
  # Number from 1 to 7, inclusive;
  # equivalent to purchase_id = c(1, 2, 3, 4, 5, 6, 7)
  user_id = c(103, 102, 104, 102, 101, 101, 103),
  amount = c(25.00, 30.00, 10.50, 22.50, 10.20, 50.00, 80.00),
  category = c("Electronics", "Books", "Garden", "Electronics", "Garden",
               "Groceries", "Electronics")
)

# Combine the tables to create a sales table
# %>% is called the pipe.
# It means: Take the thing on the left and pass it to the function on the right.
sales <- purchases %>%
  left_join(users, by = "user_id")

# Calculate total revenue
# summarise() is used when we want to reduce many rows into a summary value.
total_revenue <- sales %>%
  summarise(
    total_revenue = sum(amount)
  )

# Calculate the number of purchases
# n() counts the number of rows in the current data.
total_purchases <- sales %>%
  summarise(
    number_of_purchases = n()
  )

# Calculate average purchase value
average_purchase <- sales %>%
  summarise(
    average_purchase = mean(amount)
  )

# Compute revenue by category
revenue_by_category <- sales %>%
  group_by(category) %>%
  summarise(
    total_revenue = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount)
  ) %>%
  arrange(desc(total_revenue))

# Compute revenue by country
revenue_by_country <- sales %>%
  group_by(country) %>%
  summarise(
    total_revenue = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount)
  ) %>%
  arrange(desc(total_revenue))

# Customer Analysis - to figure out who is the highest valued customer
customer_summary <- sales %>%
  group_by(user_id, name, country) %>%
  summarise(
    total_spend = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount),
    .groups = "drop"
  ) %>%
  arrange(desc(total_spend))

# Add a new column to sales table
# mutate() is used to create or modify columns.
sales <- sales %>%
  mutate(
    revenue_percentage = amount / sum(amount) * 100
  )

# Check for missing(na) values
colSums(is.na(sales))

# Check for duplicate Purchase IDs
sales %>% 
  count(purchase_id) %>%
  filter(n > 1)

# Check invalid amount
sales %>%
  filter(amount <= 0)

# Use ggplot2
# reorder() - instead of random/alphabetical ordering,
# the categories are ordered based on their revenue
# geom_col() - Represent the data using columns/bars.
# coord_flip() - This swaps the X and Y axes.
# labs() - add labels
ggplot(
  revenue_by_category,
  aes(
    x = reorder(category, total_revenue),
    y = total_revenue
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Revenue by Category",
    x = "Category",
    y = "Revenue"
  )

# Save the graph generated
ggsave("plots/revenue_by_category.png",
  width = 8,
  height = 5
)

# Export processed data
dir.create("data", showWarnings = FALSE)
write_csv(
  sales,
  "data/processed_sales.csv"
)