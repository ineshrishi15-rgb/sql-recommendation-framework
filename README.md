# SQL Product Recommendation Framework

## Project Overview

This project uses Microsoft SQL Server to build a product recommendation framework based on customers' previous purchases. It explores category-based recommendations, price-segment recommendations, and a combined approach that ranks suitable products using historical popularity.

## Business Problem

Businesses can use purchase history to identify products that may interest existing customers. This project demonstrates how SQL can turn transactional data into relevant product suggestions while excluding items customers have already purchased.

## Dataset

The project uses three tables:

- `orders_data` — customer purchase records
- `products_data` — product details, categories, and prices
- `user_data` — customer information

The dataset contains 180 order records, 30 products, and 110 customer records. These figures describe the supplied dataset, not a real company's overall customer base.

## Tools and SQL Concepts

- Microsoft SQL Server and SQL Server Management Studio (SSMS)
- `SELECT`, filtering, and sorting
- `INNER JOIN` and `LEFT JOIN`
- Common Table Expressions (CTEs)
- `CASE` expressions for price segmentation
- Aggregation with `COUNT`
- `NOT EXISTS` to exclude previously purchased products
- `ROW_NUMBER()` to rank recommendations

## Recommendation Methods

### 1. Category-Based Recommendations
Suggests products from categories a customer has previously purchased from, excluding products already purchased.

### 2. Price-Segment Recommendations
Groups products into Low, Avg, High, and Premium price bands and identifies alternatives within the relevant segment.

### 3. Combined Recommendations
Combines category and price-segment matching, excludes previously purchased products, and ranks candidate products by historical order frequency. The final query returns up to three recommendations per customer.

## Business Value

This framework demonstrates how SQL can support product discovery, cross-selling, and customer-focused marketing. A production system would require further testing and more advanced personalization.

## Limitations

- The dataset is limited in size and may not represent real-world shopping behaviour.
- Popularity is measured using order-record frequency, not necessarily units sold.
- Recommendations are based on category, price, and popularity rather than a trained machine-learning model.
- No live recommendation system or business impact experiment is implemented.
- Results depend on the accuracy and structure of the supplied data.

## Future Improvements

- Add customer-level purchase frequency and recency analysis.
- Compare recommendation methods using defined evaluation metrics.
- Add sample output tables and visualizations.
- Test recommendation coverage and relevance.
- Explore collaborative filtering or other personalization techniques.

## Author

**Inesh Rishi**
