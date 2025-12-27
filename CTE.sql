USE SalesDB;

/*
	Step1: Find the total sales per customer. (Standalone CTE)
	Step2: Find the last order date per customer. (Standalone CTE)
	Step3: Rank customers based on total sales per customer. (Nested CTE)
	Step4: Segment customers based on their total sales. (Nested CTE)
*/
-- Step1
WITH CTE_Total_Sales AS (
	SELECT
		CustomerID,
		SUM(Sales) AS TotalSales
	FROM
		Sales.Orders
	GROUP BY
		CustomerID
)
-- Step2
, CTE_Last_Order AS (
	SELECT
		CustomerID,
		MAX(OrderDate) LastOrder
	FROM
		Sales.Orders
	GROUP BY
		CustomerID
)
-- Step3
, CTE_Rank_Customer AS (
	SELECT
		CustomerID,
		TotalSales,
		RANK() OVER(ORDER BY TotalSales DESC) AS CustomerRank
	FROM
		CTE_Total_Sales
)
-- Step4
, CTE_Segment_Customer AS (
	SELECT
		CustomerID,
		TotalSales,
		CASE
			WHEN TotalSales > 100 THEN 'High'
			WHEN TotalSales > 80 THEN 'Medium'
			ELSE 'Low'
		END CustomerSegments

	FROM
		CTE_Total_Sales
)
-- Main Query
SELECT
	C.CustomerID,
	C.FirstName,
	C.LastName,
	CTS.TotalSales,
	CTL.LastOrder,
	CTR.CustomerRank,
	CTE.CustomerSegments
FROM
	Sales.Customers C
LEFT JOIN
	CTE_Total_Sales CTS
ON
	C.CustomerID = CTS.CustomerID
LEFT JOIN
	CTE_Last_Order CTL
ON
	C.CustomerID = CTL.CustomerID
LEFT JOIN
	CTE_Rank_Customer CTR
ON
	C.CustomerID = CTR.CustomerID
LEFT JOIN
	CTE_Segment_Customer CTE
ON
	C.CustomerID = CTE.CustomerID;

-- Generate a sequance of numbers from 1 to 20. (Recursive CTE)
WITH Series AS (
	SELECT 1 AS StarterNumber
	UNION ALL
	SELECT StarterNumber + 1
	FROM Series
	WHERE StarterNumber < 20
)
-- Main Query
SELECT * FROM Series;

-- Show the employee hierarchy by displaying each employees`s level within the organization. (Recursive CTE)
WITH CTE_Emp_Heirarchy AS (
	SELECT
		EmployeeID,
		FirstName,
		ManagerID,
		1 AS Level
	FROM
		Sales.Employees
	WHERE
		ManagerID IS NULL
	UNION ALL
	SELECT
		E.EmployeeID,
		E.FirstName,
		E.ManagerID,
		Level + 1
	FROM
		Sales.Employees AS E
	INNER JOIN
		CTE_Emp_Heirarchy AS CEH
	ON
		E.ManagerID = CEH.EmployeeID
)
SELECT * FROM CTE_Emp_Heirarchy
