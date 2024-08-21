# CREAR LA BASE DE DATOS PARA EL ENTORNO DE TRABAJO CON LA BASE kin_security
CREATE DATABASE kin_security;
USE kin_security;

# IMPORTAR DATOS DEL CSV
# (me paro en Tables, clik derecho, selecciono Table Data Import Wizard y selecciono los excel un por uno clientes, productos, score_crediticio, transacciones )
# actualizar schemas

USE kin_security;

# LLAVES PRIMARIAS
# crear llave primaria en customerId en clientes
ALTER TABLE `kin_security`.`clientes` 
CHANGE COLUMN `customerId` `customerId` INT NOT NULL ,
ADD PRIMARY KEY (`customerId`);

# crear llave primaria en customerId en productos y cambiar nombre a customerId
ALTER TABLE `kin_security`.`productos` 
CHANGE COLUMN `CustomerId` `customerId` INT NOT NULL ,
ADD PRIMARY KEY (`customerId`);

# crear llave primaria en customerId en score_crediticio y cambiar nombre a customerId
ALTER TABLE `kin_security`.`score_crediticio` 
CHANGE COLUMN `ï»¿CustomerId` `customerId` INT NOT NULL ,
ADD PRIMARY KEY (`customerId`);

# crear llave primaria en customerId en transacciones y cambiar nombre a customerId
ALTER TABLE `kin_security`.`transacciones` 
CHANGE COLUMN `ï»¿CustomerId` `customerId` INT NOT NULL ,
ADD PRIMARY KEY (`customerId`);

# inspecciono las bases
SELECT * FROM `clientes`;
SELECT * FROM `productos`;
SELECT * FROM `score_crediticio`;
SELECT * FROM `transacciones`;

# ver las columnas de las bases
SHOW COLUMNS FROM `clientes`;
SHOW COLUMNS FROM `productos`;
SHOW COLUMNS FROM `score_crediticio`;
SHOW COLUMNS FROM `transacciones`;

## INNER JOIN ##

# unir tablas clientes y productos en una sola tabla
SELECT  `clientes`.`customerId`, `clientes`.`surname`, `clientes`.`geography`,
		`clientes`.`gender`, `clientes`.`HasCrCard`, `clientes`.`isActiveMember`,
        `clientes`.`estimatedSalary`, `clientes`.`application_date`, 
        `clientes`.`exit_date`, `clientes`.`birth_date`, ## campos de la tabla clientes
         `productos`.`Products` ## campo de la tabla productos
FROM `clientes`
INNER JOIN `productos`
ON `clientes`.`customerId` = `productos`.`customerId`;

# unir 3 tablas clientes, productos y score_crediticio
SELECT  `clientes`.`customerId`, `clientes`.`surname`, `clientes`.`geography`,
		`clientes`.`gender`, `clientes`.`HasCrCard`, `clientes`.`isActiveMember`,
        `clientes`.`estimatedSalary`, `clientes`.`application_date`, 
        `clientes`.`exit_date`, `clientes`.`birth_date`, ## campos de la tabla clientes
         `productos`.`Products`, ## campo de la tabla productos
         `score_crediticio`.`Score` ## campo de la tabla score_crediticio
FROM `clientes`
INNER JOIN `productos`
ON `clientes`.`customerId` = `productos`.`customerId`

INNER JOIN `score_crediticio`
ON `clientes`.`customerId` = `score_crediticio`.`customerId`; 

# SUBCONSULTAS O SUBSELECT
USE `kin_security`;

# seleccionar los apellidos y geography cuyos sueldos sean mayores a 240 mil
SELECT *
FROM `clientes`;

SELECT `estimatedSalary`
FROM `clientes`
WHERE `estimatedSalary` > 240000;

# hago la subconsulta
SELECT `surname`, `geography`, `estimatedSalary`
FROM `clientes`
WHERE `estimatedSalary` IN (SELECT `estimatedSalary`
							FROM `clientes`
							WHERE `estimatedSalary` > 240000);

# seleccionar geograph y estimatesSalary solo para los regisros que sean mayores al salario máx de Fracia
SELECT MAX(`estimatedSalary`) AS MAXIMO_SALARIO
FROM`clientes` 
WHERE `geography` = 'France'; # el salario máx en Francia es de 248729.97

# ahora selecciono solo los que sean mayores al maximo_salario de Francia con subconsulta
SELECT `geography`, `estimatedSalary`
FROM `clientes`
WHERE `estimatedSalary` >= (SELECT MAX(`estimatedSalary`) AS MAXIMO_SALARIO
							FROM`clientes` 
							WHERE `geography` = 'France'); # el salario máx en Francia es de 248729.97

# seleccionar países cuyos sueldos sean mayores a la media de cada uno de los mismos
SELECT `geography`, AVG(`estimatedSalary`) AS MEDIA_SALARIO
FROM `clientes`
WHERE `geography` IS NOT NULL
GROUP BY `geography`; # esto agrupa cada uno de los países y calcula su promedio. Esto se usa de subconsulta

# ahora lo mismo sin comas
SELECT geography, AVG(estimatedSalary) AS MEDIA_SALARIO
FROM clientes
WHERE geography IS NOT NULL
GROUP BY geography; 

# unión de dos tablas
SELECT c.geography AS paisTabla_c, c.estimatedSalary AS SalarioTabla_c,
		t.geography AS paisTabla_t, MEDIA_SALARIO
FROM `clientes` AS c
INNER JOIN (SELECT `geography`, AVG(`estimatedSalary`) AS MEDIA_SALARIO
			FROM `clientes`
			WHERE `geography` IS NOT NULL
			GROUP BY `geography`) AS t
ON c.geography = t.geography
WHERE c.estimatedSalary >= MEDIA_SALARIO; # saca los salarios que son máyores a los salarios medios de cada país

# lista de productos que tenga un mayor número de clientes que el del producto b. Primero establecer la cantidad de productos de b
# trabajo con tablas de clientes y productos
SELECT * FROM `clientes`;
SELECT * FROM `productos`;

# cuántos clientes han consumido el producto B
 SELECT COUNT(clientes.customerId) AS Clientes_Producto_B
 FROM clientes INNER JOIN productos
 ON clientes.customerId = productos.customerId
 WHERE productos.Products = 'Product B'; # ESTE NO DA

# xxxxxxxx cuenta los productos que tienen mayor valor que 125, que es el valor que debería dar en la subconsulta anterior
SELECT `productos`.`Products`, COUNT(`productos`.`Products`)
FROM `clientes` INNER JOIN `productos`
ON `clientes`.`customerId` = `productos`.`customerId`
GROUP BY `productos`.`Products`
HAVING COUNT(`productos`.`Products`) > (SELECT COUNT(`clientes`.`customerId`) AS Clientes_Producto_B
										FROM `clientes` INNER JOIN `productos`
                                        ON `clientes`.`customerId` = `productos`.`customerId`
                                        WHERE `productos`.`Products` = 'Product B'); # ESTE NO DA
                                        
# CASE
# colocar el apellido la primera en mayúscula y las demás en minúscula
SELECT `surname`, `geography`,
CASE
	WHEN `geography` = 'Germany' THEN CONCAT('Mi Apellido es: ', CONCAT(LEFT(`surname`,1),LOWER(SUBSTRING(`surname`,2))),' soy de nacionalidad: Alemania')
	WHEN `geography` = 'France' THEN CONCAT('Mi Apellido es: ', CONCAT(LEFT(`surname`,1),LOWER(SUBSTRING(`surname`,2))),' soy de nacionalidad: Francesa')
    WHEN `geography` = 'Italy' THEN CONCAT('Mi Apellido es: ', CONCAT(LEFT(`surname`,1),LOWER(SUBSTRING(`surname`,2))),' soy de nacionalidad: Italiana')
	WHEN `geography` IS NULL THEN 'No hay información'
    ELSE CONCAT('Mi Apellido es: ', CONCAT(LEFT(`surname`,1),LOWER(SUBSTRING(`surname`,2))),' soy de nacionalidad: Española')
END AS Mi_presentacion
FROM `clientes`; # salen algunos errores en los valores nulos

# a qué generación pertenece cada registro según su edad
-- 1. Generación niños posguerra (1930-1948)
-- 2. Baby Boomers (1949-1968)
-- 3. Generación X (1969-1980)
-- 4. Los Millennials (1981-1996)
-- 5. Generación Z (1997-2012)
SELECT * FROM `clientes`;

SELECT `surname`, `birth_date`,
CASE 
	WHEN YEAR(`birth_date`)>= 1930 AND YEAR(`birth_date`)<= 1948 THEN 'Generación Posguerra'
    WHEN YEAR(`birth_date`)>= 1949 AND YEAR(`birth_date`)<= 1968 THEN 'Baby Boomers'
	WHEN YEAR(`birth_date`)>= 1969 AND YEAR(`birth_date`)<= 1980 THEN 'Generación X'
	WHEN YEAR(`birth_date`)>= 1981 AND YEAR(`birth_date`)<= 1996 THEN 'Los Millennials'
	WHEN YEAR(`birth_date`)>= 1997 AND YEAR(`birth_date`)<= 2012 THEN 'Generación Z'
	ELSE 'No hay información'
END AS Generación
FROM `clientes`;

# ver cuál generación es la que tiene más en la tabla de clientes, cantidad de registros por generación
SELECT
CASE 
	WHEN YEAR(`birth_date`)>= 1930 AND YEAR(`birth_date`)<= 1948 THEN 'Generación Posguerra'
    WHEN YEAR(`birth_date`)>= 1949 AND YEAR(`birth_date`)<= 1968 THEN 'Baby Boomers'
	WHEN YEAR(`birth_date`)>= 1969 AND YEAR(`birth_date`)<= 1980 THEN 'Generación X'
	WHEN YEAR(`birth_date`)>= 1981 AND YEAR(`birth_date`)<= 1996 THEN 'Los Millennials'
	WHEN YEAR(`birth_date`)>= 1997 AND YEAR(`birth_date`)<= 2012 THEN 'Generación Z'
	ELSE 'No hay información'
END AS Generación, COUNT(*) AS Cantidad_X_Generación
FROM `clientes`
GROUP BY Generación
ORDER BY Cantidad_X_Generación DESC;

# clasificar cada registro de acuerdo a su score crediticio
-- Rango de Puntaje crediticio
-- 300 a 579 : Deficiente
-- 580 a 669 : Razonable
-- 670 a 739 : Bueno
-- 740 A 799 : Muy Bueno
-- 800 a 950 : Excepcional

SELECT * FROM `clientes`;
SELECT * FROM `score_crediticio`;

SELECT `clientes`.`surname`, `score_crediticio`.`Score`,
CASE 
	WHEN `score_crediticio`.`Score`<=579 AND `score_crediticio`.`Score`>=300 THEN 'Deficiente'
    WHEN `score_crediticio`.`Score`<=669 AND `score_crediticio`.`Score`>=580 THEN 'Razonable'
	WHEN `score_crediticio`.`Score`<=739 AND `score_crediticio`.`Score`>=670 THEN 'Bueno'
	WHEN `score_crediticio`.`Score`<=799 AND `score_crediticio`.`Score`>=740 THEN 'Muy Bueno'
	WHEN `score_crediticio`.`Score`<=950 AND `score_crediticio`.`Score`>=800 THEN 'Excepcional'
	WHEN `score_crediticio`.`Score` IS NULL OR `score_crediticio`.`Score`<=0 THEN 'Sin Calificación'
END AS Calificacion_score
FROM `clientes`
INNER JOIN `score_crediticio`
ON `clientes`.`customerId` = `score_crediticio`.`customerId`
ORDER BY `score_crediticio`.`Score` DESC; 

# contar cada una de las calificaciones obtenidas anteriormente
SELECT
CASE 
	WHEN `score_crediticio`.`Score`<=579 AND `score_crediticio`.`Score`>=300 THEN 'Deficiente'
    WHEN `score_crediticio`.`Score`<=669 AND `score_crediticio`.`Score`>=580 THEN 'Razonable'
	WHEN `score_crediticio`.`Score`<=739 AND `score_crediticio`.`Score`>=670 THEN 'Bueno'
	WHEN `score_crediticio`.`Score`<=799 AND `score_crediticio`.`Score`>=740 THEN 'Muy Bueno'
	WHEN `score_crediticio`.`Score`<=950 AND `score_crediticio`.`Score`>=800 THEN 'Excepcional'
	WHEN `score_crediticio`.`Score` IS NULL OR `score_crediticio`.`Score`<=0 THEN 'Sin Calificación'
END AS Calificacion_score, COUNT(*) AS cantidad_clasificacion
FROM `clientes`
INNER JOIN `score_crediticio`
ON `clientes`.`customerId` = `score_crediticio`.`customerId`
GROUP BY Calificacion_score
ORDER BY cantidad_clasificacion DESC; 

# cantidad de clasificación a nivel de países
SELECT `clientes`.`geography`,
CASE 
	WHEN `score_crediticio`.`Score`<=579 AND `score_crediticio`.`Score`>=300 THEN 'Deficiente'
    WHEN `score_crediticio`.`Score`<=669 AND `score_crediticio`.`Score`>=580 THEN 'Razonable'
	WHEN `score_crediticio`.`Score`<=739 AND `score_crediticio`.`Score`>=670 THEN 'Bueno'
	WHEN `score_crediticio`.`Score`<=799 AND `score_crediticio`.`Score`>=740 THEN 'Muy Bueno'
	WHEN `score_crediticio`.`Score`<=950 AND `score_crediticio`.`Score`>=800 THEN 'Excepcional'
	WHEN `score_crediticio`.`Score` IS NULL OR `score_crediticio`.`Score`<=0 THEN 'Sin Calificación'
END AS Calificacion_score, COUNT(*) AS cantidad_clasificacion
FROM `clientes`
INNER JOIN `score_crediticio`
ON `clientes`.`customerId` = `score_crediticio`.`customerId`
WHERE `clientes`.`geography` IS NOT NULL
GROUP BY Calificacion_score, `clientes`.`geography`
ORDER BY `clientes`.`geography` DESC; 




