-- ACTIVIDAD 1: Total gastado por cada cliente
SELECT s.customer_id, SUM(m.price) AS total_gastado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- ACTIVIDAD 2: ¿Cuántos días ha visitado cada cliente?
SELECT customer_id, COUNT(DISTINCT order_date) AS dias_visitados
FROM sales
GROUP BY customer_id;

-- ACTIVIDAD 3: Primer artículo comprado por cada cliente
SELECT customer_id, product_name
FROM (
    SELECT s.customer_id, s.order_date, m.product_name,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
) AS primeros
WHERE rn = 1;

-- ACTIVIDAD 4: Artículo más comprado en el menú
SELECT m.product_name, COUNT(*) AS total_ventas
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_ventas DESC
LIMIT 1;

-- ACTIVIDAD 5: Artículo más popular para cada cliente
SELECT customer_id, product_name, total
FROM (
    SELECT s.customer_id, m.product_name, COUNT(*) AS total,
	RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rk
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
) AS populares
WHERE rk = 1;

-- ACTIVIDAD 6: Primer artículo comprado después de ser miembro
SELECT customer_id, product_name
FROM (
    SELECT s.customer_id, s.order_date, m.product_name,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM sales s
    JOIN members mem ON s.customer_id = mem.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date
) AS primeras_compras
WHERE rn = 1;

-- ACTIVIDAD 7: Artículo comprado justo antes de ser miembro
SELECT customer_id, product_name
FROM (
    SELECT s.customer_id, s.order_date, m.product_name,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rn
    FROM sales s
    JOIN members mem ON s.customer_id = mem.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
) AS antes_de_miembro
WHERE rn = 1;

-- ACTIVIDAD 8: Total artículos y gasto antes de ser miembro
SELECT s.customer_id, COUNT(*) AS total_articulos, SUM(m.price) AS total_gastado
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

-- ACTIVIDAD 9: Puntos por cliente después de ser miembro
SELECT s.customer_id, SUM(
	CASE 
		WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
		ELSE m.price * 10
	END
    ) AS total_puntos
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date >= mem.join_date
GROUP BY s.customer_id;

-- ACTIVIDAD 10: Puntos para A y B a fines de enero con bonos
SELECT s.customer_id, SUM(
	CASE
		WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN
		CASE 
			WHEN m.product_name = 'sushi' THEN m.price * 10 * 4
			ELSE m.price * 10 * 2
		END
		ELSE
		CASE 
			WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
			ELSE m.price * 10
		END
	END
    ) AS puntos_enero
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date >= mem.join_date
  AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id;

-- ACTIVIDAD 11: Puntos de A y B a finales de enero con suposiciones
SELECT sales.customer_id,
SUM(
  CASE
    -- En la semana de ingreso
    WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY) THEN
      CASE
        WHEN product_name = 'sushi' THEN price * 10 * 4  -- Doble por ser sushi + doble por semana 1
        ELSE price * 10 * 2                              -- Doble por semana 1
      END
    -- Después de la semana de ingreso
    ELSE
      CASE
        WHEN product_name = 'sushi' THEN price * 10 * 2  -- Solo doble por ser sushi
        ELSE price * 10                                  -- Normal
      END
  END
) AS puntos_enero
FROM sales
JOIN members ON sales.customer_id = members.customer_id
JOIN menu ON sales.product_id = menu.product_id
WHERE order_date >= join_date
  AND order_date <= '2021-01-31'
  AND sales.customer_id IN ('A', 'B')
GROUP BY sales.customer_id;
