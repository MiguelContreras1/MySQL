# RETO 
CREATE DATABASE Mi_Reto;
USE Mi_Reto;

# IMPORTAR DATOS DEL CSV
# (me paro en Tables, clik derecho, selecciono Table Data Import Wizard y selecciono el excel)
# actualizar schemas

USE Mi_Reto;
SELECT * FROM `athlete_events`;

-- 1. ¿Cuántos juegos olímpicos se han celebrado?
SELECT COUNT(DISTINCT Year) 
AS Total_Juegos 
FROM `athlete_events`;

-- 2. Enumerar todos los juegos olímpicos celebrados hasta ahora
SELECT DISTINCT `Games` 
FROM `athlete_events`;

-- 3. Número total de naciones que participaron en cada juego
SELECT `Games`, COUNT(DISTINCT `NOC`) 
AS Num_paisesxJO 
FROM `athlete_events`
GROUP BY `Games`;

-- 4. ¿En qué año se vio el mayor número de países participando en los JO?
(SELECT `Year`, COUNT(DISTINCT `NOC`) AS NumeroPaisesMax
FROM `athlete_events`
GROUP BY `Year` 
ORDER BY NumeroPaisesMax DESC
LIMIT 1)
UNION
(SELECT `Year`, COUNT(DISTINCT `NOC`) AS NumeroPaisesMin
FROM `athlete_events`
GROUP BY `Year`
ORDER BY NumeroPaisesMin ASC
LIMIT 1);

-- 5. ¿Qué nación ha participado en todos los JO?
SELECT * FROM `athlete_events`;
SELECT COUNT(DISTINCT `Year`) FROM `athlete_events`;

SELECT `NOC`, COUNT(DISTINCT `Year`) AS Num_Participaciones
FROM `athlete_events`
GROUP BY `NOC`
HAVING Num_Participaciones = (SELECT COUNT(DISTINCT `Year`) FROM `athlete_events`);

-- 6. Deporte que se jugó en todas las olimpiadas de verano
CREATE TEMPORARY TABLE t1 (SELECT COUNT(DISTINCT `Games`) AS total_juegos_verano
FROM `athlete_events`
WHERE `Season` = 'Summer'
ORDER BY `Games`);

SELECT * FROM t1;

CREATE TEMPORARY TABLE t3 (SELECT sport, COUNT(`Games`) AS Num_juegos
FROM (SELECT DISTINCT `Sport`, `Games` FROM `athlete_events`
WHERE `Season` = 'Summer'
ORDER BY `Games`) AS X
GROUP BY `Sport`);

SELECT * FROM t3;

SELECT t3.`Sport`, t3.Num_juegos FROM t3
INNER JOIN t1
ON t3.Num_juegos = t1.total_juegos_verano;

-- 7. Identifique el deporte que se jugó en todos los juegos de verano
SELECT COUNT(DISTINCT `Year`)
FROM `athlete_events`
WHERE `Season` = 'Summer';

SELECT DISTINCT `Sport`, COUNT(DISTINCT `Year`)
FROM `athlete_events`
WHERE `Season` = 'Summer'
GROUP BY `Sport`
HAVING COUNT(DISTINCT `Year`) = (SELECT COUNT(DISTINCT `Year`)
									FROM `athlete_events`
									WHERE `Season` = 'Summer');

-- 8. Obtener el número total de deportes jugados en cada JO
SELECT * FROM `athlete_events`;

SELECT `Games`, COUNT(DISTINCT `Sport`) AS Total_Juegos
FROM `athlete_events`
GROUP BY `Games`;

-- 9. Encuentra la porción de atletas masculinos y femeninos que praticiparon en todos los JO
SELECT `Year`, 
		COUNT(*) AS TotalCount,
        SUM(CASE WHEN `Sex` = 'M' THEN 1 ELSE 0 END) AS MaleCount,
        SUM(CASE WHEN `Sex` = 'F' THEN 1 ELSE 0 END) AS FemaleCount
        FROM `athlete_events`
		GROUP BY `Year`;

SELECT `Year`,
		ROUND(MaleCount/TotalCount,2) AS Male_proportion,
        ROUND(FemaleCount/TotalCount,2) AS Female_Proportion
FROM (
SELECT `Year`, 
		COUNT(*) AS TotalCount,
        SUM(CASE WHEN `Sex` = 'M' THEN 1 ELSE 0 END) AS MaleCount,
        SUM(CASE WHEN `Sex` = 'F' THEN 1 ELSE 0 END) AS FemaleCount
        FROM `athlete_events`
		GROUP BY `Year`) AS sq1
ORDER BY `Year`;

-- 10. Busque los 5 mejores atletas que han ganado medalla de oro
CREATE TEMPORARY TABLE s1(
SELECT`Name`, COUNT(*) AS Total_medalla_oro 
FROM `athlete_events`
WHERE `Medal` = 'Gold'
GROUP BY `Name`
ORDER BY Total_medalla_oro DESC);

SELECT * FROM s1;

SELECT *
FROM (SELECT s1.*,
		DENSE_RANK () OVER (ORDER BY s1.Total_medalla_oro DESC) AS DRK
FROM s1) AS ranked
WHERE DRK<=5;


-- 11. Obten los 5 mejores atletas que han ganado la mayoría de las medallas (oro/plata/bronce)
SELECT 
	`Name`,
    SUM(CASE WHEN `Medal` = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN `Medal` = 'Silver' THEN 1 ELSE 0 END) AS Silver, 
	SUM(CASE WHEN `Medal` = 'Bronze' THEN 1 ELSE 0 END) AS Bronze, 
	COUNT(*) AS Total_medals
FROM `athlete_events`
WHERE `Medal` IN ('Gold', 'Silver', 'Bronze')
GROUP BY `Name`
ORDER BY Total_medals DESC
LIMIT 5; 

-- 12. Obtener los 5 países más exitosos de los JO
SELECT 
	`Team` AS Country,
	SUM(CASE WHEN `Medal` = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN `Medal` = 'Silver' THEN 1 ELSE 0 END) AS Silver, 
	SUM(CASE WHEN `Medal` = 'Bronze' THEN 1 ELSE 0 END) AS Bronze, 
	COUNT(*) AS Total_medals
FROM `athlete_events`
WHERE `Medal` IN ('Gold', 'Silver', 'Bronze')
GROUP BY `Team`
ORDER BY Total_medals DESC
LIMIT 5; 

-- 13. Enumerar el número total de medallas de oro, plata y bronce ganadas por cada país
SELECT 
	`Team` AS Country,
	SUM(CASE WHEN `Medal` = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN `Medal` = 'Silver' THEN 1 ELSE 0 END) AS Silver, 
	SUM(CASE WHEN `Medal` = 'Bronze' THEN 1 ELSE 0 END) AS Bronze, 
	COUNT(*) AS Total_medals
FROM `athlete_events`
WHERE `Medal` IN ('Gold', 'Silver', 'Bronze')
GROUP BY `Team`
ORDER BY Country;

-- 14. Enumera el número total de medallas de oro, plata y bronce ganadas por cada país en relación con cada JO
SELECT 
	`Team` AS Country,
    `Year` AS Olimpic_year,
	SUM(CASE WHEN `Medal` = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN `Medal` = 'Silver' THEN 1 ELSE 0 END) AS Silver, 
	SUM(CASE WHEN `Medal` = 'Bronze' THEN 1 ELSE 0 END) AS Bronze 
FROM `athlete_events`
WHERE `Medal` IN ('Gold', 'Silver', 'Bronze')
GROUP BY `Team`, `Year`
ORDER BY Country, Olimpic_year;
    
-- 15. Identificar qué país ganó la mayoría de las edallas de oro, plata y bronce en cada JO
SELECT 
	`Year`,
    `Team` AS Winning_Country,
    `Medal`,
    COUNT(*) AS Medal_Count,
    CASE
		WHEN `Medal` = 'Gold' THEN 'Gold'
		WHEN `Medal` = 'Silver' THEN 'Silver'
		WHEN `Medal` = 'Bronze' THEN 'Bronze'
        END AS Medal_type
FROM `athlete_events`
WHERE `Medal` IN ('Gold', 'Silver', 'Bronze')
GROUP BY `Year`, Winning_Country, `Medal`;

SELECT 
	`Year`,
    Medal_type,
    Winning_Country,
    Medal_Count,
    RANK() OVER (PARTITION BY `Year`, Medal_type ORDER BY Medal_Count DESC) AS Country_Rank 
FROM (			SELECT 
				`Year`,
				`Team` AS Winning_Country,
				`Medal`,
				COUNT(*) AS Medal_Count,
				CASE
					WHEN `Medal` = 'Gold' THEN 'Gold'
					WHEN `Medal` = 'Silver' THEN 'Silver'
					WHEN `Medal` = 'Bronze' THEN 'Bronze'
					END AS Medal_type
			FROM `athlete_events`
			WHERE `Medal` IN ('Gold', 'Silver', 'Bronze')
			GROUP BY `Year`, Winning_Country, `Medal`) AS MedalsCount;

SELECT
	`Year` AS Olympic_Year,
    Medal_type,
    Winning_Country,
    Medal_Count
FROM (
			SELECT 
				`Year`,
				Medal_type,
				Winning_Country,
				Medal_Count,
				RANK() OVER (PARTITION BY `Year`, Medal_type ORDER BY Medal_Count DESC) AS Country_Rank 
			FROM (			SELECT 
							`Year`,
							`Team` AS Winning_Country,
							`Medal`,
							COUNT(*) AS Medal_Count,
							CASE
								WHEN `Medal` = 'Gold' THEN 'Gold'
								WHEN `Medal` = 'Silver' THEN 'Silver'
								WHEN `Medal` = 'Bronze' THEN 'Bronze'
								END AS Medal_type
						FROM `athlete_events`
						WHERE `Medal` IN ('Gold', 'Silver', 'Bronze')
						GROUP BY `Year`, Winning_Country, `Medal`) AS MedalsCount) AS RankedMedals
		WHERE Country_Rank = 1;

   -- 16. ¿En qué deportes/eventos India ha ganado la mayor cantidad de medallas?
   SELECT `Sport`, `Event`,
		SUM(CASE WHEN `Medal`='Gold' THEN 1 ELSE 0 END) AS Gold,
        SUM(CASE WHEN `Medal`='Silver' THEN 1 ELSE 0 END) AS Silver,
        SUM(CASE WHEN `Medal`='Bronze' THEN 1 ELSE 0 END) AS Bronze
   FROM `athlete_events`
   WHERE `Team` =  'India' AND `Medal` IN ('Gold', 'Silver', 'Bronze')
   GROUP BY `Sport`, `Event`
   ORDER BY Gold DESC, Silver DESC, Bronze DESC;
   
   -- 17. Desglosa todos los JO en los que la India ganó medallas en hockey y cuántas medallas ganó en cada uno de ellos
   SELECT 
		`Year` AS Olympic_Year,
        COUNT(*) AS Total_Medals,
		SUM(CASE WHEN `Medal`='Gold' THEN 1 ELSE 0 END) AS Gold,
        SUM(CASE WHEN `Medal`='Silver' THEN 1 ELSE 0 END) AS Silver,
        SUM(CASE WHEN `Medal`='Bronze' THEN 1 ELSE 0 END) AS Bronze
   FROM `athlete_events`
   WHERE `Team` =  'India' AND `Medal` IN ('Gold', 'Silver', 'Bronze') AND `Sport` = 'Hockey'
   GROUP BY `Year`
   ORDER BY Olympic_Year;


    
    
    
    
















