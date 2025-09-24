USE classicmodels;

-- ACTIVIDAD 1
-- Ejercicio 1: Contactos de oficina
SELECT officeCode, phone
FROM offices;

-- Ejercicio 2: Detectives de correo electrónico
SELECT employeeNumber, firstName, lastName, email
FROM employees
WHERE email LIKE '%.es';

-- Ejercicio 3: Estado de confusión
SELECT customerNumber, customerName, state
FROM customers
WHERE state IS NULL;

-- Ejercicio 4: Grandes gastadores
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE amount > 20000;

-- Ejercicio 5: Grandes gastadores de 2005
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE amount > 20000 AND YEAR(paymentDate) = 2005;

-- Ejercicio 6: Detalles distintos
SELECT DISTINCT productCode
FROM orderdetails;

-- Ejercicio 7: Estadísticas globales de compradores
SELECT country, COUNT(*) AS total_clientes
FROM customers
GROUP BY country
ORDER BY total_clientes DESC;

-- ACTIVIDAD 2
-- 1. Descripción de línea de producto más larga
SELECT productLine, LENGTH(textDescription) AS longitud
FROM productlines
ORDER BY longitud DESC
LIMIT 1;

-- 2. Recuento de clientes por oficina
SELECT e.officeCode, COUNT(DISTINCT c.customerNumber) AS total_clientes
FROM customers c
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY e.officeCode
ORDER BY total_clientes DESC;

-- 3. Día de mayores ventas de automóviles
SELECT 
    DAYNAME(o.orderDate) AS dia_semana,
    COUNT(*) AS total_ventas
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE p.productLine LIKE '%Car%'  -- puede ser 'Classic Cars', 'Vintage Cars', etc.
GROUP BY dia_semana
ORDER BY total_ventas DESC
LIMIT 1;

-- 4. Corrección de datos territoriales faltantes
SELECT 
    officeCode,
    city,
    territory,
    CASE 
        WHEN territory = 'NA' THEN 'USA'
        ELSE territory
    END AS territorio_corregido
FROM offices;

-- 5. Estadísticas de empleados de la familia Patterson
SELECT 
    YEAR(o.orderDate) AS año,
    MONTH(o.orderDate) AS mes,
    ROUND(AVG(od.quantityOrdered * od.priceEach), 2) AS monto_promedio_carrito,
    SUM(od.quantityOrdered) AS total_articulos
FROM customers c
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE e.lastName = 'Patterson'
  AND YEAR(o.orderDate) IN (2004, 2005)
GROUP BY año, mes
ORDER BY año, mes;


-- ACTIVIDAD 3
-- 1. Análisis de compras anuales usando subconsultas correlacionadas
SELECT 
  YEAR(o.orderDate) AS año,
  MONTH(o.orderDate) AS mes,
  ROUND(AVG(od.quantityOrdered * od.priceEach), 2) AS monto_promedio_carrito,
  SUM(od.quantityOrdered) AS total_articulos
FROM customers c
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE e.lastName = 'Patterson'
  AND YEAR(o.orderDate) IN (2004, 2005)
GROUP BY año, mes
ORDER BY año, mes;


-- 2. Oficinas con empleados que atienden a clientes sin estado
SELECT DISTINCT o.officeCode, o.city, o.territory
FROM offices o
WHERE o.officeCode IN (
  SELECT DISTINCT e.officeCode
  FROM employees e
  JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
  WHERE c.state IS NULL
);