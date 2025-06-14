--SQL Retail Sales Analysis - Project 1

-- Create Table
CREATE TABLE retail_sales
			(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,	
				customer_id INT,	
				gender VARCHAR(15),	
				age INT,
				category VARCHAR(20),	
				quantiy INT,	
				price_per_unit FLOAT,	
				cogs FLOAT,	
				total_sale FLOAT
			);

--Determining how many transactions each customer made
SELECT customer_id, COUNT(customer_id) AS transactions FROM retail_sales GROUP BY customer_id ORDER BY transactions DESC;

-- Data cleaning
--Selecting all the rows that have a NULL value
SELECT * FROM retail_sales 
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--Deleting rows with NULL values
DELETE FROM retail_sales WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;


-- Data Exploration
--How many sales we have
SELECT COUNT(*) AS total_num_sales FROM retail_sales;

--How many unique customers do we have (number)
SELECT COUNT(DISTINCT customer_id) AS "Number of Customers" FROM retail_sales;

--How many unique categories do we have (list of categories)
SELECT DISTINCT category AS "Categories" FROM retail_sales;


-- Data Analysis & Business Key Problems and Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


--Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * 
FROM retail_sales 
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
SELECT * 
FROM retail_sales 
WHERE 
	category = 'Clothing' 
	AND 
	quantity >= 4
	AND 
	EXTRACT(YEAR FROM sale_date) = 2022 
	AND 
	EXTRACT(MONTH FROM sale_date) = 11;

--Different ways to get the month and date
SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND quantity >= 4
AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND quantity >= 4 AND
DATE_PART('year', sale_date) = 2022 AND DATE_PART('month', sale_date) = 11;


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT 
	category, 
	SUM(total_sale) AS "Total Sales",
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY "Total Sales" DESC;



-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(age), 1) AS average_age
FROM retail_sales
WHERE category = 'Beauty';


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * 
FROM retail_sales
WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transactions_id) AS num_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT year, month, average_sale
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		ROUND(AVG(total_sale)::numeric, 2) AS average_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY ROUND(AVG(total_sale)::numeric, 2) DESC) as rank
	FROM retail_sales
	GROUP BY year, month
	ORDER BY year, average_sale DESC
) as table1
WHERE rank = 1;


-- This shows every month in every year
SELECT 
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	ROUND(AVG(total_sale)::numeric, 2) AS average_sale
FROM retail_sales
GROUP BY year, month
ORDER BY average_sale DESC;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
SELECT 
	customer_id, 
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT 
	category, 
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
SELECT shift, COUNT(*) AS num_of_orders
FROM
(
	SELECT sale_time,
		CASE 
			WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) > 12 AND EXTRACT(HOUR FROM sale_time) < 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
	ORDER BY sale_time
)
GROUP BY shift;

--Using a CTE (common table expression) to define the temporary results of the different shifts
WITH hourly_sale
AS
(
	SELECT sale_time,
		CASE 
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
	ORDER BY sale_time
)
SELECT 
	shift, 
	COUNT(*) AS num_of_orders
FROM hourly_sale
GROUP BY shift;


--End of project 
	