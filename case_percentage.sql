USE Meng_test

UPDATE t3
SET stat = 'cancel' WHERE stat = 'cancle'

SELECT *
FROM t3
order by request_at


SELECT
	request_at, 
	SUM(CASE stat WHEN 'cancel' THEN ct ELSE 0 END)/CAST(SUM(ct) AS FLOAT) AS cancel_rate
FROM t3
GROUP BY request_at
ORDER BY request_at

SELECT *
FROM 
(
	SELECT request_at, stat, ct,
	RANK() OVER(PARTITION BY stat ORDER BY ct DESC) as rk
	FROM t3
	) t
WHERE rk = 1
