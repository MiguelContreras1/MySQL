# SELECT Y FROM
SELECT * FROM players.players_description;

USE players;

# seleccionar todas las columnas de una tabla
SELECT * FROM `players_description`;
SELECT * FROM players_description;

# seleccionar solamente algunas columnas
SELECT Playerid, FirstName, LastName FROM players_description;
SELECT `Playerid`, `FirstName`, `LastName`, `Age`, `Value_eur`
FROM `players_description`;

# WHERE

# seleccionar jugadores con ecavtamente 30 años
SELECT `FirstName`,`LastName`, `Age` 
FROM `players_description`
WHERE `Age` = 30;

# GROUP BY

# seleccionar para cada nacionalidad sui máximo valor de mercado para jugadores cuya edad sea menor de 25 años
SELECT `Nationality`, MAX(`Value_eur`)
FROM `players_description`
WHERE `Age`<25
GROUP BY `Nationality`;

# seleccionar para cada nacionalidad sui máximo valor de mercado para jugadores cuya edad sea menor de 25 añosy muestre edad y nombres
SELECT Nationality, MAX(Value_eur) FROM players_description WHERE Age<25 GROUP BY Nationality;

# AND

# seleccionar a nombres de jugadores de Argentina y que sean menores de 30 años
SELECT `FirstName`, `LastName`, `Nationality`, `Age`
FROM `players_description`
WHERE `Nationality` = 'ARG' 
AND `Age`<30;

# seleccionar a nombres de jugadores con nacionalidad diferente a Argentina y que sean menores de 30 años
SELECT `FirstName`, `LastName`, `Nationality`, `Age`
FROM `players_description`
WHERE `Nationality` != 'ARG' 
AND `Age`<30;

# seleccionar a nombres de jugadores con nacionalidad diferente a Argentina y que sean menores de 30 años
SELECT `FirstName`, `LastName`, `Nationality`, `Age`
FROM `players_description`
WHERE `Nationality` <> 'ARG' 
AND `Age`<30;

# seleccionar jugadores que hayan nacido después de 1990
SELECT `FirstName`, `LastName`, `BirthDate`
FROM `players_description`
WHERE `BirthDate`>'1990-12-31';

# seleccionar jugadores que hayan nacido después de 1990 y sean de Brasil
SELECT `FirstName`, `LastName`, `BirthDate`
FROM `players_description`
WHERE `BirthDate`>'1990-12-31' AND `Nationality` = 'BRA';

# SUM

# suma de los valores de mercado por cada posición de jugador
SELECT `Team_Position`, SUM(`Value_eur`)
FROM `players_description`
GROUP BY `Team_Position`;

# muestra cuanto cuesta la plantilla de cada club, basado en el sueldo
SELECT `Club`, SUM(`Wage_eur`)
FROM `players_description`
GROUP BY `Club`;

# COUNT

# contabilizar el total de registros de la tabla (hay 299 jugadores)
SELECT COUNT(*) FROM `players_description`;

SELECT COUNT(1) 
FROM `players_description`;

# contabilizar cuántos futbolistas son mayores a 30 años (hay 91 jugadores)
SELECT COUNT(`Playerid`) FROM `players_description`
WHERE `Age`>30;

# contabilizar cuántos futbolistas son mayores a 25 años (hay 226 jugadores)
SELECT COUNT(`Playerid`) 
FROM `players_description`
WHERE `Age`>25;

# contabilizar cuántos futbolistas hay por cada nacionalidad
SELECT `Nationality`, COUNT(*) 
FROM `players_description`
GROUP BY `Nationality`;

# contabilizar cuántos futbolistas hay por cada nacionalidad cuyo sueldo sea mayor a 200 (establecido en miles)
SELECT `Nationality`, COUNT(*) 
FROM `players_description`
WHERE `Wage_eur`>200
GROUP BY `Nationality`;

# contabilizar cuántos futbolistas hay por cada nacionalidad cuyo sueldo sea mayor a 50 (establecido en miles)
SELECT `Nationality`, COUNT(*) 
FROM `players_description`
WHERE `Wage_eur`>50
GROUP BY `Nationality`;

# AND

# seleccionar el apellido de los jugadores que son menores de 30 años y su posición es CB 
SELECT`LastName`, `Age`, `Team_Position`
FROM`players_description`
WHERE `Age`<30
AND`Team_Position`='CB';

# futbolistas franceses cuyo vayor es mayor a 20 millones
SELECT `FirstName`,`LastName`,`Nationality`,`Value_eur`
FROM`players_description`
WHERE `Nationality`='FRA'
AND`Value_eur`>20;

# futbolistas franceses cuyo vayor es menor a 20 millones
SELECT `FirstName`,`LastName`,`Nationality`,`Value_eur`
FROM`players_description`
WHERE `Nationality`='FRA'
AND`Value_eur`<20;

# IN 

# seleccionar todos los campos de la tabla pero solo de ARG, BRA y FRA 
SELECT *
FROM `players_description`
WHERE`Nationality`
IN ('ARG', 'BRA', 'FRA');

# seleccionar todos los campos de la tabla pero solo de jugadores de club Real Madrid y Liverpool 
SELECT *
FROM `players_description`
WHERE`Club`
IN ('Real Madrid CF','Liverpool');

# seleccionar todos los campos de la tabla pero solo de jugadores con edades de 22, 25 y 30 (no necesitan entrecomillas)
SELECT *
FROM `players_description`
WHERE`Age`
IN (22,25,30);

# ORDER BY

# ordenar de forma ascendente la edad 
SELECT`FirstName`, `LastName`, `Age`
FROM`players_description`
ORDER BY `Age` ASC;

# ordenar de forma descendente la edad 
SELECT`FirstName`, `LastName`, `Age`
FROM`players_description`
ORDER BY `Age` DESC;

# ordenar de forma descendente los promedios de edad por club
SELECT `Club`, AVG(`Age`)
FROM `players_description`
GROUP BY `Club`
ORDER BY AVG(`Age`) DESC;

# ordenar de forma ascendente los promedios de altura por nacionalidad, pero solamente para jugadores mayores de 28
SELECT `Nationality`, AVG(`Height`)
FROM `players_description`
WHERE `Age`>28
GROUP BY `Nationality`
ORDER BY AVG(`Height`) ASC;

# GROUP BY

# seleccione la máxima edad por cada club
SELECT `Club`, MAX(`Age`)
FROM `players_description`
GROUP BY `Club`;

# seleccionar los mínimos valores del mercado por nacionalidad
SELECT `Nationality`, MIN(`Value_eur`)
FROM `players_description`
GROUP BY `Nationality`;

# seleccionar por club cuál es la altura máxima para cada uno
SELECT `Team_Position`, MAX(`Height`)
FROM `players_description`
GROUP BY `Team_Position`;

# HAVING

# seleccionar para cada nacionalidad solamente las edades promedio mayores a 28 años ordenados de forma ascendente 
SELECT `Nationality`, AVG(`Age`)
FROM `players_description`
GROUP BY `Nationality`
HAVING AVG(`Age`) > 28
ORDER BY AVG (`Age`) ASC;

# promedio de valor de mercado por nacionalidad de jugadores nacidos en ARG, BRA, ESP, FRA y que prom de valor de mercado esté por encima de 40
SELECT `Nationality`, AVG(`Value_eur`)
FROM `players_description`
WHERE `Nationality` IN ('ARG', 'BRA', 'ESP', 'FRA')
GROUP BY `Nationality`
HAVING AVG(`Value_eur`) > 40;

# DISTINCT

# seleccionar cuáles son los nombres de clubs de manera única
SELECT DISTINCT `Club`
FROM `players_description`;

# ver el númro de jugadores que tiene cada club
SELECT DISTINCT `Club`, COUNT(*)
FROM `players_description`
GROUP BY `Club`
ORDER BY COUNT(*) DESC;

# mostrar las nacionalidades únicas y la cantidad de registros de cada una
SELECT DISTINCT `Nationality`, COUNT(*)
FROM `players_description`
GROUP BY `Nationality`
ORDER BY COUNT(*) DESC;

# CREATE TEMPORARY TABLE

USE importar;
SELECT * FROM `bank`;

# crear tabla temporal con los campos age, job, marital, education
CREATE TEMPORARY TABLE temporal_tabla
SELECT `age`,`job`,`marital`,`education`
FROM `bank`;

# seleccionar la tabla temporal que creé
SELECT * FROM temporal_tabla;

# crear tabla temporal temp_tabla2 seleccionanmdo age, job, marital, education unicamente edad mayor a 25 y educación terciaria y desconocida
CREATE TEMPORARY TABLE temp_tabla2
SELECT `age`,`job`,`marital`,`education`
FROM `bank`
WHERE `age`>25 AND `education` IN ('tertiary', 'unknown');

# seleccionar la tabla temporal que creé
SELECT * FROM temp_tabla2;




