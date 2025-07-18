CREATE DATABASE capstone_project1;
SHOW DATABASES;
USE capstone_project1 ;
CREATE TABLE sales_analysis (
    invoice_id VARCHAR(30),
    branch VARCHAR(5),
    city VARCHAR(30),
    customer_type VARCHAR(30),
    gender VARCHAR(10),
    product_line VARCHAR(100),
    unit_price DECIMAL(10, 2),
    quantity INT,
    VAT FLOAT(6, 4),
    Total DECIMAL(10, 2),
    date DATE,
    time TIMESTAMP,
    payment_method DECIMAL(10, 2),
    cogs DECIMAL(10, 2),
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(10, 2),
    rating FLOAT(2, 1)
);

select * from Amazon ;

/* Task 2.1 addng a column time of the day */  
ALTER TABLE Amazon ADD COLUMN timeofday VARCHAR(10);
SET SQL_SAFE_UPDATES = 0;
UPDATE Amazon
SET timeofday = CASE
    WHEN TIME(time) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    WHEN TIME(time) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
    ELSE 'Unknown'
END;
/* Task 2.2 Adding a column dayname */
ALTER TABLE Amazon ADD COLUMN dayname VARCHAR(10);
UPDATE Amazon
SET dayname = DATE_FORMAT(date, '%a');
SELECT DISTINCT date FROM Amazon;
UPDATE Amazon
SET date = STR_TO_DATE(date, '%d-%m-%Y')
WHERE STR_TO_DATE(date, '%d-%m-%Y') IS NOT NULL;


/* Task 2.3 adding a column monthname*/
ALTER TABLE Amazon
ADD COLUMN monthname VARCHAR(3);

UPDATE Amazon
SET monthname = DATE_FORMAT(date, '%b');
SELECT monthname, 
       SUM(Total) AS total_sales, 
       SUM(Total) AS total_profit
FROM Amazon
GROUP BY monthname
ORDER BY total_sales DESC
LIMIT 0, 1000;

/* 1:What is the count of distinct cities in the dataset? */
SELECT COUNT(DISTINCT city) AS distinct_city_count
FROM Amazon;

/*2. For each branch, what is the corresponding city?*/
SELECT branch, GROUP_CONCAT(DISTINCT city ORDER BY city) AS cities
FROM Amazon
GROUP BY branch;


/*3. What is the count of distinct product lines in the dataset? */

SELECT COUNT(DISTINCT `Product line`) AS distinct_product_lines_count
FROM Amazon;  
use capstone_project1;

SELECT COUNT(DISTINCT `Product line`) AS distinct_product_lines FROM Amazon;

/* 4 Which payment method occurs most frequently? */
SELECT payment, COUNT(*) AS frequency
FROM Amazon
GROUP BY payment
ORDER BY frequency DESC
LIMIT 1;

/*5 ---Which product line has the highest sales? */

SELECT `Product line`, SUM(Total) AS total_sales 
FROM Amazon 
GROUP BY `Product line`
ORDER BY total_sales DESC 
LIMIT 1;

/* 6 How much revenue is generated each month?*/
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS month, 
    SUM(Total) AS total_revenue
FROM Amazon
GROUP BY month
ORDER BY month;
/*7 In which month did the cost of goods sold reach its peak? */
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS month,
    SUM(cogs) AS total_cogs
FROM Amazon
GROUP BY month
ORDER BY total_cogs DESC;

SELECT 
    monthname AS month,
    SUM(cogs) AS total_cogs
FROM Amazon
GROUP BY month
ORDER BY total_cogs DESC;

/* 8  Which product line generated the highest revenue?  */ 
SELECT 
    `Product line`, 
    SUM(Total) AS total_revenue
FROM Amazon
GROUP BY `Product line`
ORDER BY total_revenue DESC
LIMIT 1;


/* 9  In which city was the highest revenue recorded? */
SELECT 
    city, 
    SUM(Total) AS total_revenue
FROM Amazon
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

/* 10 . Which product line incurred the highest Value Added Tax? */
SELECT 
    `Product line`, 
    SUM(VAT) AS total_vat
FROM Amazon
GROUP BY `Product line`
ORDER BY total_vat DESC
LIMIT 1;

/* 11 -- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." */
select AVG(Total) from Amazon;                /* Average of TOTAL'322.96674900000005'*/

SELECT 
    `Product line`,
    SUM(Total) AS total_sales,
    CASE 
        WHEN SUM(Total) > (SELECT AVG(Total) FROM Amazon) THEN 'Good'
        ELSE 'Bad'
    END AS sales_category
FROM Amazon
GROUP BY `Product line`
ORDER BY total_sales DESC;

/* 12 -Identify the branch that exceeded the average number of products sold.--*/
/*select avg(quantity) as averagequantitysold from amazon;   '5.5100' */

SELECT 
    branch,
    SUM(quantity) AS total_quantity_sold
FROM Amazon
GROUP BY branch
HAVING total_quantity_sold > (SELECT AVG(quantity) FROM Amazon);

/*13----Which product line is most frequently associated with each gender?*/
WITH product_line_frequency AS (
    SELECT 
        gender,
        `Product line`,
        COUNT(*) AS frequency,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rn
    FROM Amazon
    GROUP BY gender, `Product line`
)
SELECT 
    gender,
    `Product line`,
    frequency
FROM product_line_frequency
WHERE rn = 1;

/*14 -Calculate the average rating for each product line.*/

 SELECT 
    `Product line`,
    AVG(rating) AS average_rating
FROM Amazon
GROUP BY `Product line`;



/*15 ---Count the sales occurrences for each time of day on every weekday.*/
SELECT 
    DAYNAME(date) AS weekday,
    CASE
        WHEN TIME(time) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN TIME(time) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
        ELSE 'Unknown'
    END AS time_of_day,
    COUNT(*) AS sales_occurrences
FROM Amazon
GROUP BY weekday, time_of_day
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
         FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening');

/*16------Identify the customer type contributing the highest revenue. */
SELECT 
    gender,
    SUM(Total) AS total_revenue
FROM Amazon
GROUP BY gender
ORDER BY total_revenue DESC
LIMIT 1;

/* 17 -------Determine the city with the highest VAT percentage.*/
SELECT 
    city,
    MAX(`Tax 5%`) AS highest_VAT_percentage
FROM Amazon
GROUP BY city
ORDER BY highest_VAT_percentage DESC
LIMIT 1;

/* 18 ----Identify the customer type with the highest VAT payments.*/
SELECT 
    `Customer type`, 
    SUM(`Tax 5%` * quantity) AS total_VAT_payments
FROM Amazon
GROUP BY `Customer type`
ORDER BY total_VAT_payments DESC
LIMIT 1;
describe Amazon;


/*19--What is the count of distinct customer types in the dataset? */
SELECT DISTINCT `Customer type` AS distinct_customer_types_count
FROM Amazon;

SELECT COUNT(DISTINCT `Customer type`) AS distinct_customer_types_count
FROM Amazon;






/*20--What is the count of distinct payment methods in the dataset? -----*/

SELECT DISTINCT payment AS distinct_payment_methods_count
FROM Amazon;
SELECT COUNT(DISTINCT payment) AS distinct_payment_methods_count
FROM Amazon;

/* 21 ---Which customer type occurs most frequently? */

SELECT `Customer type`, COUNT(*) AS frequency
FROM Amazon
GROUP BY `customer type`
ORDER BY frequency DESC
LIMIT 1;


/*22---Identify the customer type with the highest purchase frequency--- */
SELECT `Customer type`, COUNT(*) AS purchase_frequency
FROM Amazon
GROUP BY `Customer type`
ORDER BY purchase_frequency DESC
LIMIT 1;



/* 23---Determine the predominant gender among customers. */
SELECT gender, COUNT(*) AS gender_count
FROM Amazon
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 1;

/*24---Examine the distribution of genders within each branch.*/
SELECT branch, gender, COUNT(*) AS gender_count
FROM Amazon
GROUP BY branch, gender
ORDER BY branch, gender;

/*25---Identify the time of day when customers provide the most ratings */
SELECT TIME(time) AS rating_time, COUNT(*) AS rating_count
FROM Amazon
WHERE rating IS NOT NULL
GROUP BY rating_time
ORDER BY rating_count DESC
LIMIT 1;

/*26--Determine the time of day with the highest customer ratings for each branch.--*/
SELECT branch, TIME(time) AS rating_time, COUNT(*) AS rating_count
FROM Amazon
WHERE rating IS NOT NULL
GROUP BY branch, rating_time
ORDER BY branch, rating_count DESC;



/*27----Identify the day of the week with the highest average ratings.--*/

SELECT DAYNAME(date) AS day_of_week, AVG(rating) AS avg_rating
FROM Amazon
WHERE rating IS NOT NULL
GROUP BY day_of_week
ORDER BY avg_rating DESC
LIMIT 1;



/*28 ----Determine the day of the week with the highest average ratings for each branch.*/
SELECT branch, 
       DAYNAME(date) AS day_of_week, 
       AVG(rating) AS avg_rating
FROM Amazon
WHERE rating IS NOT NULL
GROUP BY branch, day_of_week
ORDER BY branch, avg_rating DESC;














