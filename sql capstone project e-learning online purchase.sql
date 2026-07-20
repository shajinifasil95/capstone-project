CREATE DATABASE onlinelearning;
USE onlinelearning;


CREATE TABLE learners(
 learner_id INT PRIMARY KEY,
 full_name VARCHAR(100) NOT NULL,
 country VARCHAR(50) NOT NULL
);

CREATE TABLE courses (
course_id INT PRIMARY KEY,
course_name VARCHAR(100) NOT NULL,
category VARCHAR(50) NOT NULL,
unit_price DECIMAL (10,2) NOT NULL
);

CREATE TABLE purchases(
purchase_id INT PRIMARY KEY,
learner_id INT,
course_id INT,
quantity INT NOT NULL,
purchase_date DATE,
FOREIGN KEY (learner_id) REFERENCES learners (learner_id),
FOREIGN KEY  (course_id) REFERENCES courses (course_id)
);

INSERT INTO learners VALUES
(101,'John Smith','USA'),
(102,'Emma Wilson','Canada'),
(103,'David Brown','India'),
(104,'Sophia Johnson','UK'),
(105,'Michael Lee','Australia');

INSERT INTO courses VALUES
(201,'SQL for Beginners','Data Analytics',120.00),
(202,'Python Programming','Programming',180.00),
(203,'Power BI Dashboard','Business Intelligence',200.00),
(204,'Machine Learning','Artificial Intelligence',300.00),
(205,'AWS Cloud Basics','Cloud Computing',250.00);

INSERT INTO purchases VALUES
(1,101,201,1,'2025-01-05'),
(2,102,202,2,'2025-01-15'),
(3,103,203,1,'2025-02-10'),
(4,104,204,1,'2025-02-20'),
(5,105,205,2,'2025-03-08'),
(6,101,203,1,'2025-03-15'),
(7,102,204,1,'2025-04-01'),
(8,103,201,3,'2025-04-18');


SELECT* FROM learners;
SELECT * FROM courses;
SELECT * FROM purchases;
TRUNCATE TABLE courses;
TRUNCATE TABLE learners;
TRUNCATE TABLE purchases;

-- INNER JOIN
SELECT
    l.full_name AS Learner_Name,
    c.course_name AS Course_Name,
    c.category AS Category,
    p.quantity AS Quantity,
    FORMAT(c.unit_price * p.quantity,2) AS Total_Amount,
    p.purchase_date AS Purchase_Date
FROM purchases p
INNER JOIN learners l
ON p.learner_id = l.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
ORDER BY (c.unit_price * p.quantity) DESC;

-- LEFT JOIN
SELECT
    l.full_name AS Learner_Name,
    c.course_name AS Course_Name,
    c.category AS Category,
    p.quantity AS Quantity,
    FORMAT(IFNULL(c.unit_price * p.quantity,0),2) AS Total_Amount,
    p.purchase_date AS Purchase_Date
FROM learners l
LEFT JOIN purchases p
ON l.learner_id = p.learner_id
LEFT JOIN courses c
ON p.course_id = c.course_id
ORDER BY (c.unit_price * p.quantity) DESC;

-- RIGHT JOIN
SELECT
    l.full_name AS Learner_Name,
    c.course_name AS Course_Name,
    c.category AS Category,
    p.quantity AS Quantity,
    FORMAT(IFNULL(c.unit_price * p.quantity,0),2) AS Total_Amount,
    p.purchase_date AS Purchase_Date
FROM purchases p
RIGHT JOIN courses c
ON p.course_id = c.course_id
LEFT JOIN learners l
ON p.learner_id = l.learner_id
ORDER BY (c.unit_price * p.quantity) DESC;

-- analytical queries
-- Display each learner’s total spending with their country.


-- Find the top 3 most purchased courses by quantity.
SELECT
    c.course_name,
    SUM(p.quantity) AS Total_Quantity
FROM courses c
JOIN purchases p
ON c.course_id = p.course_id
GROUP BY
    c.course_name
ORDER BY Total_Quantity DESC
LIMIT 3;


-- Show Each Category's Total Revenue and Number of Unique Learners
SELECT
    c.category,
    FORMAT(SUM(c.unit_price * p.quantity),2) AS Total_Revenue,
    COUNT(DISTINCT p.learner_id) AS Unique_Learners
FROM courses c
JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.category
ORDER BY SUM(c.unit_price * p.quantity) DESC;

-- List Learners Who Purchased from More Than One Category
SELECT
    l.full_name,
    COUNT(DISTINCT c.category) AS Categories_Purchased
FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id
GROUP BY
    l.full_name
HAVING COUNT(DISTINCT c.category) > 1;

SELECT
    country,
    COUNT(*) AS Learners
FROM learners
GROUP BY country;

-- Identify Courses Never Purchased
SELECT
    l.learner_id,
    l.full_name,
    SUM(c.unit_price * p.quantity) AS Total_Spending
FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id
GROUP BY
    l.learner_id,
    l.full_name
HAVING SUM(c.unit_price * p.quantity) >
(
    SELECT AVG(TotalSpent)
    FROM
    (
        SELECT
            SUM(c2.unit_price * p2.quantity) AS TotalSpent
        FROM purchases p2
        JOIN courses c2
        ON p2.course_id = c2.course_id
        GROUP BY p2.learner_id
    ) AS AvgTable
);

-- Display courses whose price is higher than any course in the ‘Beginner’ category.
SELECT
    course_name,
    category,
    unit_price
FROM courses
WHERE unit_price >
(
    SELECT MAX(unit_price)
    FROM courses
    WHERE category = 'Beginner'
);

SELECT
    country,
    COUNT(*) AS Learners
FROM learners
GROUP BY country;


--  Find learners who spent more than the average spending in their country.
SELECT
    l.learner_id,
    l.full_name,
    l.country,
    SUM(c.unit_price * p.quantity) AS Total_Spending
FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id
GROUP BY
    l.learner_id,
    l.full_name,
    l.country
HAVING SUM(c.unit_price * p.quantity) >
(
    SELECT AVG(country_spending)
    FROM
    (
        SELECT
            l2.country,
            l2.learner_id,
            SUM(c2.unit_price * p2.quantity) AS country_spending
        FROM learners l2
        JOIN purchases p2
        ON l2.learner_id = p2.learner_id
        JOIN courses c2
        ON p2.course_id = c2.course_id
        WHERE l2.country = l.country
        GROUP BY
            l2.country,
            l2.learner_id
    ) AS CountryAvg
);

-- case expression
SELECT
    l.learner_id,
    l.full_name,
    l.country,
    SUM(c.unit_price * p.quantity) AS Total_Spending,

    CASE
        WHEN SUM(c.unit_price * p.quantity) > 15000 THEN 'High Value'
        WHEN SUM(c.unit_price * p.quantity) BETWEEN 8000 AND 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Learner_Category

FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id

GROUP BY
    l.learner_id,
    l.full_name,
    l.country

ORDER BY Total_Spending DESC;

SELECT
    c.course_id,
    c.course_name,
    c.category,
    COALESCE(COUNT(p.purchase_id), 0) AS Purchase_Count
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
GROUP BY
    c.course_id,
    c.course_name,
    c.category;

CREATE VIEW category_performance_view AS
SELECT
    c.category,

    SUM(c.unit_price * p.quantity) AS Total_Revenue,

    COUNT(p.purchase_id) AS Number_of_Purchases,

    ROUND(
        AVG(c.unit_price * p.quantity),
        2
    ) AS Average_Revenue_Per_Purchase

FROM courses c
JOIN purchases p
ON c.course_id = p.course_id

GROUP BY c.category;


SELECT * FROM category_performance_view;







