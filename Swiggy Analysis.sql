SHOW DATABASES;
USE SWIGGY;
SHOW TABLES;
DESCRIBE ORDERS;

ALTER TABLE ORDERS MODIFY COLUMN `DATE` DATE;
DESCRIBE ORDERS;

-- CUSTOMERS WHO HAVE NERVER ORDERED
SELECT U.USER_ID, U.`NAME`
FROM USERS U LEFT JOIN ORDERS O ON U.USER_ID = O.USER_ID 
GROUP BY U.USER_ID, U.`NAME`
HAVING COUNT(O.ORDER_ID) = 0;

-- AVERAGE PRICE PER DISH
SELECT MENU.F_ID, FOOD.F_NAME, AVG(MENU.PRICE)
FROM MENU LEFT JOIN FOOD ON MENU.F_ID = FOOD.F_ID
GROUP BY MENU.F_ID, FOOD.F_NAME; 

-- TOP RESTAURANT IN TERMS OF NO. OF ORDERS
SELECT O.R_ID, MONTHNAME(`DATE`) AS `MONTH`, R.R_NAME, COUNT(O.ORDER_ID)
FROM ORDERS O LEFT JOIN RESTAURANTS R ON O.R_ID = R.R_ID
GROUP BY O.R_ID, `MONTH`, R.R_NAME
ORDER BY `MONTH`, COUNT(O.ORDER_ID) DESC;

-- RESTAURANT WITH MONTHLY SALES > X FOR A GIVEN MONTH
SELECT MONTHNAME(O.`DATE`) AS `MONTH`, O.R_ID, R.R_NAME, SUM(O.AMOUNT) AS SALES
FROM ORDERS O LEFT JOIN RESTAURANTS R ON O.R_ID = R.R_ID
GROUP BY `MONTH`,O.R_ID, R.R_NAME
HAVING SALES > 900
ORDER BY `MONTH`
;

-- ALL ORDERS WITH ORDER DETAILS FOR A PARTICULAR CUSTOMER 
SELECT U.`NAME`, O.ORDER_ID, O.AMOUNT, O.`DATE`, F.F_NAME
FROM ORDERS O LEFT JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID LEFT JOIN USERS U ON U.USER_ID = O.USER_ID LEFT JOIN FOOD F ON F.F_ID= OD.F_ID
GROUP BY U.`NAME`, O.ORDER_ID, O.AMOUNT, O.`DATE`, F.F_NAME ;

-- RESTAURANT WITH MAX REPEATED CUSTOMERS
SELECT R.R_NAME, COUNT(O.USER_ID)
FROM RESTAURANTS R RIGHT JOIN ORDERS O ON O.R_ID = R.R_ID
GROUP BY R.R_NAME
ORDER BY COUNT(O.USER_ID) DESC
LIMIT 1;

-- MONTH OVER MONTH REVENUE
SELECT `MONTHNAME`, ((REVENUE - PREV) / PREV) * 100 AS MOM_GROWTH 
FROM (
    WITH SALES AS (
        SELECT 
            MONTHNAME(`DATE`) AS `MONTHNAME`, 
            SUM(AMOUNT) AS REVENUE , MONTH(`DATE`) AS `MONTH`
        FROM ORDERS
        GROUP BY `MONTHNAME`, `MONTH`
        ORDER BY `MONTH`
    )
    SELECT 
        `MONTHNAME`, 
        REVENUE, 
        LAG(REVENUE, 1) OVER(ORDER BY `MONTH`) AS PREV 
    FROM SALES
) T;

-- CUSTOMER FAVORITE FOOD
SELECT U.`NAME`, F.F_NAME , COUNT(F.F_NAME)
FROM USERS U RIGHT JOIN ORDERS O ON U.USER_ID = O.USER_ID LEFT JOIN ORDER_DETAILS OD ON OD.ORDER_ID = O.ORDER_ID LEFT JOIN FOOD F ON F.F_ID = OD.F_ID
GROUP BY U.`NAME`,F.F_NAME 
ORDER BY COUNT(F.F_NAME) DESC 
;