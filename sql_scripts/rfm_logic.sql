-- First I need to combine all the sales tables; I used the suffix to save me rewriting

CREATE OR REPLACE TABLE `rfm-321.sales.sales2025` AS
SELECT *
FROM `rfm-321.sales.sales2025*`
WHERE _TABLE_SUFFIX BETWEEN '01' AND '12';

--Now I need to calculate the frequency, recency, monetary, ranks. r,f,m
-- Combine views with CTEs
CREATE OR REPLACE VIEW `rfm-321.sales.rfm_metrics`
AS
WITH current_date AS (
  SELECT DATE('2026-03-22') as analysis_date --today's date
),
rfm AS (
  SELECT
    CustomerID,
    MAX(OrderDate) AS last_order_date,
    date_diff((SELECT analysis_date FROM current_date), MAX(OrderDate), DAY) AS recency,
    COUNT(*) AS frequency,
    SUM(OrderValue) AS monetary
  FROM `rfm-321.sales.sales2025`
  GROUP BY CustomerID
)
SELECT
  rfm.*,
  ROW_NUMBER() OVER(ORDER BY recency ASC) AS r_rank,
  row_number() OVER(ORDER BY frequency DESC) AS f_rank,
  row_number() OVER(ORDER BY monetary DESC) AS m_rank
FROM rfm;



-- Now that we have the rankings (10=best, 1 = worst), I need to assign deciles
CREATE OR REPLACE VIEW `rfm-321.sales.rfm_scores`
AS
SELECT
  *,
  NTILE(10) OVER(ORDER BY r_rank DESC) AS r_score,
  NTILE(10) OVER(ORDER BY f_rank DESC) AS f_score,
  NTILE(10) OVER(ORDER BY m_rank DESC) AS m_score
FROM `rfm-321.sales.rfm_metrics`;


--Last, Total Score
CREATE OR REPLACE VIEW `rfm-321.sales.rfm_total_scores`
AS
SELECT
  CustomerID,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  (r_score + f_score + m_score) AS rfm_total_score
FROM `rfm-321.sales.rfm_scores`
ORDER BY rfm_total_score DESC;


--Real last, Create Power BI ready rfm segments table, with names
CREATE OR REPLACE TABLE `rfm-321.sales.rfm_segments_final`
AS
SELECT
  CustomerID,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  rfm_total_score,
  CASE
    WHEN rfm_total_score >=28 THEN 'Champions'
    WHEN rfm_total_score >=24 THEN 'Elite'
    WHEN rfm_total_score >=20 THEN 'Potential Elite'
    WHEN rfm_total_score >=16 THEN 'Reliable'
    WHEN rfm_total_score >=12 THEN 'Moderate'
    WHEN rfm_total_score >=8 THEN 'Slipping'
    WHEN rfm_total_score >=4 THEN 'Disengaged'
    ELSE 'Inactive'
  END AS rfm_segment
FROM `rfm-321.sales.rfm_total_scores`
ORDER BY rfm_total_score DESC;


