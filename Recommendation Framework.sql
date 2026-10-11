-- 1. Preview the tables

SELECT TOP 1 * FROM user_data
SELECT TOP 1 * FROM products_data
SELECT TOP 1 * FROM orders_data


-- 2. CATEGORY-BASED RECOMMENDATIONS
;WITH ORDER_CAT AS
(
    SELECT
        A.customer_id,
        A.product_id,
        B.category
    FROM orders_data AS A
    INNER JOIN products_data AS B
        ON A.product_id = B.product_id
)
SELECT DISTINCT
    C.customer_id,
    D.product_id AS Recommended_Product_ID,
    D.product_name
FROM ORDER_CAT AS C
INNER JOIN products_data AS D
    ON C.category = D.category
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders_data AS Existing
    WHERE Existing.customer_id = C.customer_id
      AND Existing.product_id = D.product_id
);


-- 3. PRICE-BASED RECOMMENDATIONS
;WITH Order_Seg AS
(
    SELECT
        A.customer_id,
        A.product_id,
        B.price AS purchased_product_price,
        CASE
            WHEN B.price < 50 THEN 'Low'
            WHEN B.price < 100 THEN 'Avg'
            WHEN B.price < 150 THEN 'High'
            ELSE 'Premium'
        END AS Order_Seg_Price
    FROM orders_data AS A
    INNER JOIN products_data AS B
        ON A.product_id = B.product_id
),
Prod_Seg AS
(
    SELECT
        product_id,
        product_name,
        price,
        CASE
            WHEN price < 50 THEN 'Low'
            WHEN price < 100 THEN 'Avg'
            WHEN price < 150 THEN 'High'
            ELSE 'Premium'
        END AS Product_Seg_Price
    FROM products_data
)
SELECT DISTINCT
    A.customer_id,
    B.product_id AS Recommended_Product_ID,
    B.product_name,
    B.price
FROM Order_Seg AS A
INNER JOIN Prod_Seg AS B
    ON A.Order_Seg_Price = B.Product_Seg_Price
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders_data AS Existing
    WHERE Existing.customer_id = A.customer_id
      AND Existing.product_id = B.product_id
);


-- 4. COMBINED CATEGORY + PRICE RECOMMENDATIONS
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
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY order_count DESC, price ASC,
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
ORDER BY customer_id, recommendation_rank;





















