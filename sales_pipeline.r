# ==========================================
# Sales Analytics using R
# ==========================================

# Synthetic dataset generated for demonstration purposes

# Load the tidyverse package
library(tidyverse)

# ==========================================
# 1. Generate customer data
# ==========================================

set.seed(123)

customers <- tibble(
  user_id = 1:500,
  country = sample(
    c("US", "UK", "DE", "IN", "CA", "AU"),
    500,
    replace = TRUE
  )
)

# ==========================================
# 2. Generate purchase data
# ==========================================

categories <- c(
  "Electronics",
  "Books",
  "Clothing",
  "Home & Kitchen",
  "Groceries",
  "Sports",
  "Beauty",
  "Toys",
  "Garden",
  "Furniture"
)

purchases <- tibble(
  purchase_id = 1:5000,

  user_id = sample(
    customers$user_id,
    5000,
    replace = TRUE
  ),

  purchase_date = sample(
    seq(
      as.Date("2025-01-01"),
      as.Date("2025-12-31"),
      by = "day"
    ),
    5000,
    replace = TRUE
  ),

  category = sample(
    categories,
    5000,
    replace = TRUE
  )
)

purchases <- purchases %>%
  mutate(
    amount = round(
      case_when(
        category == "Groceries" ~ runif(n(), 5, 150),
        category == "Books" ~ runif(n(), 10, 100),
        category == "Clothing" ~ runif(n(), 20, 200),
        category == "Beauty" ~ runif(n(), 10, 150),
        category == "Toys" ~ runif(n(), 10, 150),
        category == "Sports" ~ runif(n(), 20, 250),
        category == "Garden" ~ runif(n(), 20, 300),
        category == "Home & Kitchen" ~ runif(n(), 25, 350),
        category == "Electronics" ~ runif(n(), 50, 800),
        category == "Furniture" ~ runif(n(), 100, 1000)
      ),
      2
    )
  )

# ==========================================
# 3. Combine customer and purchase data
# ==========================================

sales <- purchases %>%
  left_join(
    customers,
    by = "user_id"
  )

# ==========================================
# 4. Data quality checks
# ==========================================

# Check for missing values
colSums(is.na(sales))

# Check for duplicate purchase IDs
sales %>%
  count(purchase_id) %>%
  filter(n > 1)

# Check for invalid purchase amounts
sales %>%
  filter(amount <= 0)

# Check for invalid customer references
sales %>%
  filter(!user_id %in% customers$user_id)

# ==========================================
# 5. Transform data
# ==========================================

sales <- sales %>%
  mutate(
    month = floor_date(purchase_date, "month")
  )

# ==========================================
# 6. Overall sales metrics
# ==========================================

overall_metrics <- sales %>%
  summarise(
    total_revenue = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount)
  )

# ==========================================
# 7. Revenue by category
# ==========================================

revenue_by_category <- sales %>%
  group_by(category) %>%
  summarise(
    total_revenue = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount),
    .groups = "drop"
  ) %>%
  mutate(
    revenue_percentage = total_revenue / sum(total_revenue) * 100
  ) %>%
  arrange(desc(total_revenue))

# ==========================================
# 8. Revenue by country
# ==========================================

revenue_by_country <- sales %>%
  group_by(country) %>%
  summarise(
    total_revenue = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount),
    .groups = "drop"
  ) %>%
  arrange(desc(total_revenue))

# ==========================================
# 9. Top customers by revenue
# ==========================================

top_customers <- sales %>%
  group_by(user_id, country) %>%
  summarise(
    total_spent = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount),
    .groups = "drop"
  ) %>%
  mutate(
    revenue_percentage = total_spent / sum(total_spent) * 100
  ) %>%
  arrange(desc(total_spent))

top_10_revenue_share <- top_customers %>%
  slice_head(n = 10) %>%
  summarise(
    top_10_revenue = sum(total_spent),
    revenue_percentage =
      top_10_revenue / overall_metrics$total_revenue * 100
  )

# ==========================================
# 10. Monthly revenue
# ==========================================

monthly_revenue <- sales %>%
  group_by(month) %>%
  summarise(
    total_revenue = sum(amount),
    number_of_purchases = n(),
    average_purchase = mean(amount),
    .groups = "drop"
  ) %>%
  arrange(month)

# ==========================================
# 11. Visualizations
# ==========================================

# Revenue by category

category_plot <- ggplot(
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

ggsave(
  "plots/revenue_by_category.png",
  category_plot,
  width = 8,
  height = 5
)

# Revenue by country

country_plot <- ggplot(
  revenue_by_country,
  aes(
    x = reorder(country, total_revenue),
    y = total_revenue
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Revenue by Country",
    x = "Country",
    y = "Revenue"
  )

ggsave(
  "plots/revenue_by_country.png",
  country_plot,
  width = 8,
  height = 5
)

# Monthly revenue trend

monthly_plot <- ggplot(
  monthly_revenue,
  aes(
    x = month,
    y = total_revenue
  )
) +
  geom_line() +
  geom_point() +
  labs(
    title = "Monthly Revenue Trend",
    x = "Month",
    y = "Revenue"
  )

ggsave(
  "plots/monthly_revenue.png",
  monthly_plot,
  width = 8,
  height = 5
)

# Top 10 customers

top_10_customers <- top_customers %>%
  slice_head(n = 10)

customer_plot <- ggplot(
  top_10_customers,
  aes(
    x = reorder(user_id, total_spent),
    y = total_spent
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 Customers by Revenue",
    x = "Customer ID",
    y = "Total Spent"
  )

ggsave(
  "plots/top_10_customers.png",
  customer_plot,
  width = 8,
  height = 5
)

# ==========================================
# 12. Export processed data
# ==========================================

write_csv(
  sales,
  "data/processed_sales.csv"
)