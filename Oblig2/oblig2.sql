--Oppgave 2

--a)
SELECT navn FROM Planet
WHERE stjerne = 'Proxima Centauri';

--b)
SELECT DISTINCT oppdaget FROM Planet
WHERE stjerne = 'TRAPPIST-1' OR stjerne = 'Kepler-154';

--c)
SELECT COUNT(*) FROM Planet
WHERE masse is NULL;

--d)
SELECT navn, masse FROM Planet
WHERE oppdaget = 2020 AND masse > (SELECT AVG(masse) FROM Planet);

--e)
SELECT MAX(oppdaget)-MIN(oppdaget) FROM Planet;

--Oppgave 3

--a)
SELECT navn
FROM Planet as p INNER JOIN Materie as m ON (p.navn = m.planet)
WHERE m.molekyl = 'H2O';
        
--b)
SELECT p.navn
FROM Planet AS p 
INNER JOIN Stjerne AS s ON (p.stjerne = s.navn)
INNER JOIN Materie AS m ON (p.navn = m.planet)
WHERE s.avstand < s.masse*12 AND m.molekyl LIKE '%H%';

--c)
SELECT p.navn FROM Planet as p
INNER JOIN Stjerne AS s ON (p.stjerne = s.navn)
WHERE p.masse > 10 AND s.avstand < 50;

--Oppgave 4

/*
The convenience of the NATURAl JION clause is that it uses an implicit join clause based
on the common column between the two tables. In this example, Nils tries to use the NATURAL JOIN on the tables Planet and Stjerne, which have the common columns "navn" and "masse". The problem with both "navn" and "masse" is that they do not refer to two equal columns with name "navn" and "masse". When the two columns are not equal, the join between them does not make any sense, but the NATURAL JOIN uses them anyways, which results in an empty result sett. 
*/

--Oppgave 5

--a)
INSERT INTO Stjerne
VALUES ('Sola', 0, 1);

--b)
INSERT INTO Planet
VALUES ('Jorda', 0.003146, NULL, 'Sola');


--Oppgave 6

CREATE TABLE Observasjon (
	observasjons_id int PRIMARY KEY, 
	tidspunkt timestamp NOT NULL, 
	planet text NOT NULL REFERENCES Planet (navn), 
	kommentar text
);








