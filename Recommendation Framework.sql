;WITH Product_Segments AS
(
    SELECT
        product_id,
        product_name,
        category,
        price,
        CASE
            WHEN price < 50 THEN 'Low'
            WHEN price < 100 THEN 'Avg'
            WHEN price < 150 THEN 'High'
            ELSE 'Premium'
        END AS price_segment
    FROM products_data
),
Customer_Preferences AS
(
    SELECT DISTINCT
        O.customer_id,
        P.category,
        P.price_segment
    FROM orders_data AS O
    INNER JOIN Product_Segments AS P
        ON O.product_id = P.product_id
),
Product_Popularity AS
(
    SELECT
        product_id,
        COUNT(*) AS order_count
    FROM orders_data
    GROUP BY product_id
),
Candidate_Recommendations AS
(
    SELECT DISTINCT
        CP.customer_id,
        RP.product_id AS recommended_product_id,
        RP.product_name,
        RP.category,
        RP.price,
        RP.price_segment,
        COALESCE(PP.order_count, 0) AS order_count
    FROM Customer_Preferences AS CP
    INNER JOIN Product_Segments AS RP
        ON CP.category = RP.category
       AND CP.price_segment = RP.price_segment
    LEFT JOIN Product_Popularity AS PP
        ON RP.product_id = PP.product_id
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM orders_data AS Existing
        WHERE Existing.customer_id = CP.customer_id
          AND Existing.product_id = RP.product_id
    )
),
Ranked_Recommendations AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_count DESC,
                price ASC,
                recommended_product_id
        ) AS recommendation_rank
    FROM Candidate_Recommendations
)
SELECT
    customer_id,
    recommendation_rank,
    recommended_product_id,
    product_name,
    category,
    price,
    price_segment,
    order_count
FROM Ranked_Recommendations
WHERE recommendation_rank <= 3
ORDER BY
    customer_id,
    recommendation_rank;















