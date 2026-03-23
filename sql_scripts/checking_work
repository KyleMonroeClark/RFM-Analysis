--Checking my work to make sure that receency, monetary, and frequency are associated with the correct rankings

SELECT * FROM `rfm-321.sales.rfm_metrics`
ORDER BY f_rank;


SELECT * FROM `rfm-321.sales.rfm_metrics`
ORDER BY m_rank;


SELECT * FROM `rfm-321.sales.rfm_metrics`
ORDER BY r_rank;


--Checking the deciles
SELECT * FROM `rfm-321.sales.rfm_scores`;


--Checking the totals, 4 customers with a perfect score, first glance looks moderately like a normal distribution, mode at the "moderate" segment

SELECT * FROM `rfm-321.sales.rfm_total_scores`
ORDER BY rfm_total_score DESC;


--22 Champions, 7 Inactive
SELECT rfm_segment, COUNT(*) FROM `rfm-321.sales.rfm_segments_final`
GROUP BY rfm_segment;
