/* Query 1- query used for first insight*/
WITH all_cat AS(
	SELECT c.name AS film_category, 
		COUNT(rental_id)AS overall_rental_count, 
		RANK()OVER(ORDER BY COUNT(rental_id)DESC)AS overall_category_rental_count
	FROM film f
	LEFT JOIN film_category fc ON f.film_id=fc.film_id
	LEFT JOIN category c ON fc.category_id=c.category_id
	LEFT JOIN inventory i ON f.film_id=i.film_id
	LEFT JOIN rental r ON i.inventory_id=r.inventory_id
	GROUP BY c.name
)

SELECT a.film_category AS film_category, 
	overall_rental_count,
	overall_category_rental_count,
	b.film_category AS family_friendly_film_category, 
	family_friendly_category_rental_count
FROM all_cat a
LEFT JOIN 
	(SELECT c.name AS film_category, 
		RANK()OVER(ORDER BY COUNT(rental_id)DESC)AS family_friendly_category_rental_count
	FROM film f
	LEFT JOIN film_category fc ON f.film_id=fc.film_id
	LEFT JOIN category c ON fc.category_id=c.category_id
	LEFT JOIN inventory i ON f.film_id=i.film_id
	LEFT JOIN rental r ON i.inventory_id=r.inventory_id
	GROUP BY c.name
	HAVING c.name IN('Animation','Children','Classics','Comedy','Family','Music')
	)AS b
ON a.film_category=b.film_category;


/* Query 2- query used for second insight*/
SELECT DISTINCT film_category, 
	quartile, 
	COUNT(film_id)AS film_count
FROM(
	SELECT f.film_id AS film_id,
		c.name AS film_category,
		NTILE(4)OVER(ORDER BY length)AS quartile
	FROM film f
	LEFT JOIN film_category fc ON f.film_id=fc.film_id
	LEFT JOIN category c ON fc.category_id=c.category_id
	WHERE c.name IN('Animation','Children','Classics','Comedy','Family','Music')
	)AS t
GROUP BY film_category, quartile
ORDER BY film_category, quartile;


/* Query 3- query used for third insight*/
SELECT TO_CHAR(rental_date,'YYYY-MM')AS year_month, 
	sf.store_id AS store_id, 
	COUNT(r.rental_id)AS rental_count
FROM rental r
LEFT JOIN staff sf ON r.staff_id=sf.staff_id
LEFT JOIN store s ON sf.store_id=s.store_id
GROUP BY year_month,sf.store_id
ORDER BY year_month;



/* Query 4- query used for fourth insight*/
SELECT c.customer_id AS customer_id, 
	CONCAT(c.first_name,' ',c.last_name)AS full_name,
	TO_CHAR(payment_date,'YYYY')AS year,
	TO_CHAR(payment_date,'MM')AS month, 
	COUNT(payment_id)AS payment_count,
	SUM(amount)AS payment_amount
FROM payment p
JOIN customer c ON p.customer_id=c.customer_id
GROUP BY c.customer_id, full_name,year, month
HAVING c.customer_id IN (SELECT customer_id 
				FROM (SELECT c.customer_id AS customer_id,
						SUM(amount)AS payment_amount
					FROM customer c
	                   		LEFT JOIN payment p ON c.customer_id=p.customer_id
	                   		GROUP BY c.customer_id
	                   		ORDER BY payment_amount DESC
	                   		LIMIT 5)
				AS t1)
ORDER BY full_name,year,month;

