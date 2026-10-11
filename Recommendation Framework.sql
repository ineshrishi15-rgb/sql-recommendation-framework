SELECT TOP 1 * FROM user_data
SELECT TOP 1 * FROM products_data
SELECT TOP 1 * FROM orders_data

--RECOMMENDATION FRAMEWORK Based on Category
WITH ORDER_CAT
AS
(SELECT A.*,B.category FROM orders_data AS A
INNER JOIN products_data AS B
ON A.product_id = B.product_id)
--WHERE A.customer_id = 'C_006') --AND A.product_id = 'Product_A')

SELECT DISTINCT C.Customer_Id, D.product_id AS Recommended_Products,D.product_name FROM ORDER_CAT AS C
INNER JOIN products_data AS D
ON C.Category = D.category
WHERE C.PRODUCT_ID != D.product_id


--RECOMMENDATION FRAMEWORK Based on PRICE


SELECT * FROM orders_data AS A
INNER JOIN products_data AS B
ON A.amount_paid = B.price
WHERE A.customer_id = 'C_006'AND A.product_id = 'Product_A'


WITH Order_Seg
AS
(SELECT *,
CASE
    WHEN amount_paid <50 THEN 'Low'
    WHEN amount_paid <100 THEN 'Avg'
    WHEN amount_paid <150 THEN 'High'
    ELSE 'Premium'
    END AS Order_Seg_Price
FROM orders_data AS A),
Prod_Seg
AS
(SELECT *,
CASE
    WHEN price <50 THEN 'Low'
    WHEN price <100 THEN 'Avg'
    WHEN price <150 THEN 'High'
    ELSE 'Premium'
    END AS Product_Seg_Price
FROM products_data AS B)

SELECT DISTINCT A.customer_id,B.product_id AS Recommended_Products, B.product_name
FROM Order_Seg AS A
INNER JOIN Prod_Seg AS B
ON A.Order_Seg_Price = B.Product_Seg_Price
WHERE A.product_id!=B.product_id 
--AND  A.customer_id ='C_006' --AND A.Order_Seg_Price = 'Low' AND A.product_id = 'Product_F'


-- RECOMMENDATION FRAMEWORK:
-- BASED ON CATEGORY AND PRICE

WITH Purchased_Products AS (
    SELECT DISTINCT
        O.customer_id,
        P.product_id AS purchased_product_id,
        P.category,
        CASE
            WHEN P.price < 50 THEN 'Low'
            WHEN P.price < 100 THEN 'Avg'
            WHEN P.price < 150 THEN 'High'
            ELSE 'Premium'
        END AS price_segment
    FROM orders_data AS O
    INNER JOIN products_data AS P
        ON O.product_id = P.product_id
),
Product_Segments AS (
    SELECT
        product_id,
        product_name,
        category,
        CASE
            WHEN price < 50 THEN 'Low'
            WHEN price < 100 THEN 'Avg'
            WHEN price < 150 THEN 'High'
            ELSE 'Premium'
        END AS price_segment
    FROM products_data
)
SELECT DISTINCT
    PP.customer_id,
    PS.product_id AS recommended_product_id,
    PS.product_name,
    PS.category,
    PS.price_segment
FROM Purchased_Products AS PP
INNER JOIN Product_Segments AS PS
    ON PP.category = PS.category
    AND PP.price_segment = PS.price_segment
WHERE PP.purchased_product_id <> PS.product_id
ORDER BY PP.customer_id, PS.product_name;




















