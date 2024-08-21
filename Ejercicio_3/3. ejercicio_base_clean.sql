-- LIMPIEZA DE DATOS

CREATE DATABASE IF NOT EXISTS clean;

USE `clean`;

# ver los 10 primeros de cada columna
SELECT * FROM `limpieza` LIMIT 10;limpieza

# crear un store procedure / procedimiento almacenado para guardar pasos
DELIMITER // 
CREATE PROCEDURE limp()
BEGIN
	SELECT * FROM `limpieza`;
END //
DELIMITER ;

# llamo al procedimiento
CALL limp();

# renombrar las columnas que tienen caracteres especiales. Poner Id_emp
ALTER TABLE `limpieza` 
CHANGE COLUMN `ï»¿Id?empleado`
Id_emp VARCHAR (20)
NULL;

CALL limp();

# renombrar y poner Gender
ALTER TABLE `limpieza` 
CHANGE COLUMN `gÃ©nero`
Gender VARCHAR (20)
NULL;

CALL limp();

# identificar duplicados, con group by y having
SELECT `Id_emp`, COUNT(*) AS cantidad_duplicados
FROM `limpieza`
GROUP BY `Id_emp`
HAVING COUNT(*) > 1; 

# contar número de registros duplicados con subconsulta
SELECT COUNT(*) AS cantidad_duplicados
FROM (
SELECT `Id_emp`, COUNT(*) AS cantidad_duplicados
FROM `limpieza`
GROUP BY `Id_emp`
HAVING COUNT(*) > 1)
AS subquery; 

# eliminar duplicados (renombrar tabla, luego crear tabla temporal sin duplicados)
RENAME TABLE `limpieza` TO conduplicados;

CREATE TEMPORARY TABLE Temp_limpieza AS
SELECT DISTINCT * FROM `conduplicados`;

SELECT COUNT(*) AS original
FROM `conduplicados`; 

SELECT COUNT(*) AS original
FROM Temp_limpieza;

# dejar la tabla solamente con los valores únicos (convertir la temporal en permanente)
CREATE TABLE `limpieza` AS SELECT *
FROM Temp_limpieza;

CALL limp();

# eliminar tabla conduplicados
DROP TABLE `conduplicados`;

# desactivar el modo seguro para poder hacer las modificaciones
SET SQL_SAFE_UPDATES = 0;

CALL limp();

# renombrar columna apellido star_date
ALTER TABLE `limpieza` 
CHANGE COLUMN `Apellido` Last_name VARCHAR (50) NULL;

CALL limp();

# renombrar columna star_date
ALTER TABLE `limpieza` 
CHANGE COLUMN `star_date` start_date VARCHAR (50) NULL;

CALL limp();

# ver propiedades de la tabla
DESCRIBE `limpieza`;

# ajustar las columnas que tienen formato texto
CALL limp();
# eliminar los espacios de los nombres con trim 
SELECT `Name`
FROM `limpieza`
WHERE LENGTH(`Name`) - LENGTH(TRIM(`Name`)) > 0;

SELECT `Name`, TRIM(`Name`) AS `Name`
FROM `limpieza`
WHERE LENGTH(`Name`) - LENGTH(TRIM(`Name`)) > 0;

# modificamos definitivamente la tabla en el nombre
UPDATE `limpieza` SET `Name` = TRIM(`Name`)
WHERE LENGTH(`Name`) - LENGTH(TRIM(`Name`)) > 0;
CALL limp();

# eliminar los espacios de los apellidos con trim 
SELECT `Last_name`
FROM `limpieza`
WHERE LENGTH(`Last_name`) - LENGTH(TRIM(`Last_name`)) > 0;

SELECT `Last_name`, TRIM(`Last_name`) AS `Last_name`
FROM `limpieza`
WHERE LENGTH(`Last_name`) - LENGTH(TRIM(`Last_name`)) > 0;

# modificamos definitivamente la tabla en el apellido
UPDATE `limpieza` SET `Last_name` = TRIM(`Last_name`)
WHERE LENGTH(`Last_name`) - LENGTH(TRIM(`Last_name`)) > 0;
CALL limp();

# borrar espacios extra en medio de dos palabras
UPDATE `limpieza` SET `area` = REPLACE(`area`, ' ', '      ');
CALL limp();

SELECT `area`
FROM `limpieza`
WHERE `area` REGEXP '\\s(2,)'; # este no sale

# quito los espacios extra de columna area (reemplazando la expresión regular)
SELECT `area`, TRIM(regexp_replace(`area`, '\\s+',' '))
AS ensayo
FROM `limpieza`;

# actualizo la tabla de manera definitiva
UPDATE `limpieza`
SET `area` = TRIM(regexp_replace(`area`, '\\s+',' '));
CALL limp();

# buscar y reeplazar hombre por male y mujer por female
SELECT `Gender`,
CASE
	WHEN `Gender` = 'hombre' THEN 'male'
	WHEN `Gender` = 'mujer' THEN 'female'
    ELSE 'other'
END AS gender1
FROM `limpieza`;

# actualizo la tabla
UPDATE `limpieza` 
SET `Gender` = CASE
	WHEN `Gender` = 'hombre' THEN 'male'
	WHEN `Gender` = 'mujer' THEN 'female'
    ELSE 'other'
END; 
CALL limp();

# type es el tipo de contrato del empledo (0 es hibrido, 1 es remoto son valores enteros -int-)
DESCRIBE `limpieza`;

# cambiar el type de tipo int por tipo text
ALTER TABLE `limpieza` 
MODIFY COLUMN TYPE text;
DESCRIBE `limpieza`;

# hago el cambio usando el case (primero el ensayo y luego la actualizacón)
SELECT `TYPE`,
CASE
	WHEN `TYPE` = 1 THEN 'Remote'
    WHEN `TYPE` = 0 THEN 'Hybrid'
    ELSE 'Other'
END AS ejemplo
FROM `limpieza`;

# actualización
UPDATE `limpieza` 
SET TYPE = CASE
	WHEN `TYPE` = 1 THEN 'Remote'
    WHEN `TYPE` = 0 THEN 'Hybrid'
    ELSE 'Other'
END;
CALL limp();

# dar formato de número a un texto (reemplazar el signo $ por un vacío y cambiar el separador de la coma por un vacío) con funciones anidadas
SELECT `salary`, 
CAST(TRIM(REPLACE(REPLACE(`salary`, '$',''), ',', '')) AS DECIMAL (15, 2)) 
AS `salary`
FROM `limpieza`; 

# actualizo la tabla con el nuevo salary sin $ ni separador de miles ,
UPDATE `limpieza`
SET `salary` = CAST(TRIM(REPLACE(REPLACE(`salary`, '$',''), ',', '')) AS DECIMAL (15, 2)); 
CALL limp();

# modifico el tipo de dato de la columna salary, para que no sea texto sino número
ALTER TABLE `limpieza`
MODIFY COLUMN `salary` INT NULL;
DESCRIBE `limpieza`;

# ajustar los formato de fechas para birth_date, start_date, finish_date
# ajustar formato fechas (birth_date)
# ver cómo están escritas las de birth_date
SELECT `birth_date`
FROM `limpieza`; # está dia/mes/año. Debo cambiarlo a año/mes/día
 
SELECT `birth_date`, CASE
	WHEN `birth_date` LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(`birth_date`, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN `birth_date` LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(`birth_date`, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END AS new_birth_date
FROM `limpieza`;

# actualizo la tabla con el nuevo formato fecha
UPDATE `limpieza`
SET `birth_date` = CASE
	WHEN `birth_date` LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(`birth_date`, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN `birth_date` LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(`birth_date`, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END; 
DESCRIBE `limpieza`;
CALL limp();

# modifico el formato de text a fecha
ALTER TABLE `limpieza`
MODIFY COLUMN `birth_date` DATE;
DESCRIBE `limpieza`;

# ajustar formato fechas (start_date)
# ver cómo están escritas las de start_date
SELECT `start_date`
FROM `limpieza`; # está dia/mes/año. Debo cambiarlo a año/mes/día
 
SELECT `start_date`, CASE
	WHEN `start_date` LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(`start_date`, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN `start_date` LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(`start_date`, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END AS new_start_date
FROM `limpieza`;

# actualizo la tabla con el nuevo formato fecha
UPDATE `limpieza`
SET `start_date` = CASE
	WHEN `start_date` LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(`start_date`, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN `start_date` LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(`start_date`, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END; 
DESCRIBE `limpieza`;
CALL limp();

# modifico el formato de text a fecha
ALTER TABLE `limpieza`
MODIFY COLUMN `start_date` DATE;
DESCRIBE `limpieza`;

# ajustar formato fechas (finish_date)
# ver cómo están escritas las de finish_date
SELECT `finish_date`
FROM `limpieza`; # está dia/mes/año. Debo cambiarlo a año/mes/día
 
 -- # "ensayos" hacer consultas de como quedarían los datos si queremos ensayar diversos cambios.
# convierte el valor en objeto de fecha (timestamp)
SELECT `finish_date`, str_to_date(`finish_date`, '%Y-%m-%d %H:%i:%s') AS fecha 
FROM `limpieza`;

# objeto en formato de fecha, luego da formato en el deseado '%Y-%m-%d %H:'
SELECT `finish_date`, date_format(str_to_date(`finish_date`, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha 
FROM `limpieza`;
# separar solo la fecha
SELECT `finish_date`, str_to_date(`finish_date`, '%Y-%m-%d') AS fd 
FROM `limpieza`; 

# separar solo la hora no funciona
SELECT `finish_date`, str_to_date(`finish_date`, '%H:%i:%s') AS hour_stamp 
FROM `limpieza`; 

# separar solo la hora(marca de tiempo)
SELECT `finish_date`, date_format(`finish_date`, '%H:%i:%s') AS hour_stamp 
FROM `limpieza`;

# Diviendo los elementos de la hora
SELECT `finish_date`,
    date_format(`finish_date`, '%H') AS hora,
    date_format(`finish_date`, '%i') AS minutos,
    date_format(`finish_date`, '%s') AS segundos,
    date_format(`finish_date`, '%H:%i:%s') AS hour_stamp
FROM `limpieza`;

# actualizaciones de fecha en la tabla
# hago copia de seguridad de finish_date
ALTER TABLE `limpieza` 
ADD COLUMN date_backup TEXT; -- Agregar columna respaldo

# copiar datos de finish_date a date_backup
UPDATE `limpieza` 
SET date_backup = `finish_date`; -- Copiar los datos de finish_date a a la columna respaldo
CALL limp();

# Actualizar la fecha a marca de tiempo: (TIMESTAMP ; DATETIME)
 Select `finish_date`, str_to_date(`finish_date`, '%Y-%m-%d %H:%i:%s UTC')  AS formato 
 FROM `limpieza`; -- (UTC)
 
# Diferencia entre timestamp y datetime
-- timestamp (YYYY-MM-DD HH:MM:SS) - desde: 01 enero 1970 a las 00:00:00 UTC , hasta milesimas de segundo
-- datetime desde año 1000 a 9999 - no tiene en cuenta la zona horaria , hasta segundos. */

# actualizo la tabla
UPDATE limpieza
SET `finish_date` = str_to_date(`finish_date`, '%Y-%m-%d %H:%i:%s UTC') 
WHERE `finish_date` <> '';
CALL limp();
 
# separar finish_date en una columna fecha y otra columna la hora. Creo las columnas en blanco
ALTER TABLE `limpieza`
	ADD COLUMN fecha DATE,
    ADD COLUMN hora TIME;
CALL limp();
DESCRIBE `limpieza`;

# desactivar el modo seguro para poder hacer las modificaciones (otra vez porque al cerrar y abrir toca)
SET SQL_SAFE_UPDATES = 0;

# agrego los datos a las columnas
UPDATE `limpieza`
SET fecha = DATE(`finish_date`),
	hora = TIME(`finish_date`)
WHERE `finish_date` IS NOT NULL AND `finish_date` <> '';
CALL limp();

# poner valores nulos en donde está en blanco en la columna finish_date
UPDATE `limpieza`
SET `finish_date` = NULL
WHERE `finish_date` = '';
CALL limp();
 
 # actualizo la propiedad de la tabla
 ALTER TABLE `limpieza`
 MODIFY COLUMN `finish_date` DATETIME;
 DESCRIBE `limpieza`;
 
# hacer cálculos con fechas
# calcular la edad de los empleados con su fecha de nacimiento (agrego una columna para los datos de edad)
ALTER TABLE `limpieza`
ADD COLUMN age INT;
CALL limp();

SELECT `Name`, `birth_date`, `start_date`, TIMESTAMPDIFF(year, birth_date, start_date) AS edad_de_ingreso
FROM `limpieza`;

# meto los resultados en la columna que agregué
UPDATE `limpieza`
SET `age` = TIMESTAMPDIFF(year, birth_date, CURDATE());
CALL limp();

# veo el nombre del empleado, la fecha de nacimiento y la edad
SELECT `Name`, `Last_name`, `birth_date`, `age`
FROM `limpieza`;
 
# crear columna nueva a partir de datos disponibles
# crear un correo electrónico que sea el primer nombre del empleado, raya al piso, las dos primeras letras del apellido y @consulting.com
SELECT CONCAT(SUBSTRING_INDEX(`Name`, ' ', 1), '_', SUBSTRING(`Last_name`, 1, 2), '.', SUBSTRING(`TYPE`, 1 , 1), '@consulting.com') AS email 
FROM `limpieza`;

# adicionar la columna de email a la tabla
ALTER TABLE `limpieza`
ADD COLUMN email VARCHAR(100);
CALL limp();

# relleno la columna con el email que creé antes
UPDATE `limpieza`
SET email = CONCAT(SUBSTRING_INDEX(`Name`, ' ', 1), '_', SUBSTRING(`Last_name`, 1, 2), '.', SUBSTRING(`TYPE`, 1 , 1), '@consulting.com');
CALL limp();

# crear y exportar datos definitivos
# selecciono solamente las columnas que quiero y las ordeno por nombre del área y el apellido
SELECT `Id_emp`, `Name`, `Last_name`,`age`, `Gender`, `area`, `salary`, `email`, `finish_date` 
FROM `limpieza`
WHERE `finish_date` <= CURDATE() OR `finish_date` IS NULL
ORDER BY `area`, `Last_name`;

# contabilizar la cantidad de empleados que hay por área
SELECT `area`, COUNT(*) AS cantidad_empleados 
FROM `limpieza`
GROUP BY `area`
ORDER BY cantidad_empleados DESC;

# exportar: voy al disket y le doy guardar en csv



 
 
 
 