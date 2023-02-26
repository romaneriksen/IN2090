-- psql -h dbpg-ifi-kurs03 -U romanse -d fdb

-- Oppgave 1
SELECT concat(p.firstname,' ',p.lastname) as fullname, fc.filmcharacter
FROM person as p
INNER JOIN filmparticipation as fp ON (p.personid = fp.personid)
INNER JOIN film as f ON (f.filmid = fp.filmid)	
INNER JOIN filmcharacter as fc ON (fc.partid = fp.partid)
WHERE f.title = 'Star Wars' AND fp.parttype = 'cast'; 

-- Oppgave 2

SELECT country, count(filmid)
FROM filmcountry
GROUP BY country
ORDER BY count(filmid) DESC;

-- Oppgave 3
SELECT avg(CAST(time as INTEGER)), country
FROM runningtime
WHERE country IS NOT NULL AND time ~ '^\d+$' 
GROUP BY country
HAVING count(country) >= 200;

-- Opgave 4
SELECT f.title, count(fg.filmid) as numberofgenres
FROM filmgenre as fg 
INNER JOIN film as f ON (fg.filmid = f.filmid)
GROUP BY f.title, fg.filmid
ORDER BY count(fg.filmid) DESC, title ASC 
LIMIT 10;


-- Oppgave 5
WITH gc AS (
	SELECT fc.country as country, fg.genre as genre, count(fg.genre) as genrenrs
	FROM filmgenre as fg
	INNER JOIN filmcountry as fc ON (fg.filmid = fc.filmid)
	GROUP BY fc.country, fg.genre
	ORDER BY fc.country ASC
),
st AS (
	SELECT country, MAX(genrenrs) as mvgenre
	FROM gc
	GROUP BY country
),
r as (
	SELECT fc.country, count(fc.filmid) as moviecount, AVG(fr.rank) as avgrank
	FROM filmcountry as fc
	LEFT JOIN filmrating as fr ON (fc.filmid = fr.filmid)
	LEFT JOIN filmgenre as fg ON (fc.filmid = fg.filmid)
	GROUP BY fc.country
)
SELECT DISTINCT ON (gc.country) gc.country, r.moviecount, r.avgrank, gc.genre
FROM gc
LEFT JOIN st AS st ON (st.country = gc.country)
LEFT JOIN r as r ON (r.country = gc.country)
WHERE gc.genrenrs = st.mvgenre AND r.avgrank IS NOT NULL
GROUP BY gc.country, gc.genrenrs, gc.genre, r.moviecount, r.avgrank
;


-- Oppgave 6
with nfilms AS (
	SELECT fc.filmid, fi.filmtype, fc.country
	FROM filmcountry AS fc
	INNER JOIN filmitem AS fi ON (fc.filmid = fi.filmid)
	WHERE fi.filmtype = 'C' AND country = 'Norway'
),
pairs AS (
	SELECT p1.personid as person1, p2.personid as person2, nfilms.filmid, nfilms.country
	FROM filmparticipation AS p1 
	INNER JOIN filmparticipation AS p2 ON (p1.filmid = p2.filmid)
	INNER JOIN nfilms ON (nfilms.filmid = p1.filmid)
	WHERE p1.personid!= p2.personid
),
teller AS (
	SELECT p.person1, concat(p1.firstname,' ',p1.lastname) as name1, p.person2, concat(p2.firstname,' ',p2.lastname) as name2, count(p.filmid) as nr
	FROM pairs as p
	INNER JOIN person as p1 ON (p.person1 = p1.personid)
	INNER JOIN person as p2 ON (p.person2 = p2.personid)
	GROUP BY person1, person2, p1.firstname, p2.firstname, p1.lastname, p2.lastname
),
final AS (
	SELECT t1.name1, t1.name2, t1.nr
	FROM teller as t1
	JOIN teller as t2 ON (t1.nr = t2.nr) AND t1.person1 < t2.person1
	WHERE t1.nr >= 40
)
select * from final
;

-- Oppgave 7

SELECT DISTINCT ON (f.title, f.prodyear) f.title, f.prodyear
FROM filmdescription AS fd
LEFT JOIN film AS f ON (fd.filmid = f.filmid) 
LEFT JOIN filmgenre AS fg ON (fd.filmid = fg.filmid)
LEFT JOIN filmcountry AS fc ON (fd.filmid = fc.filmid)
WHERE (f.title LIKE '%Dark%' OR f.title LIKE '%Night%') AND (fg.genre = 'Horror' OR fc.country = 'Romania')
;

-- Oppgave 8

SELECT f.title, count(f.title)
FROM film AS f
LEFT JOIN filmparticipation as fp ON (f.filmid = fp.filmid)
WHERE f.prodyear >= 2010
GROUP BY f.title
HAVING count(f.title) <= 2
ORDER BY f.title ASC
;

-- Oppgave 9

With distinctfilms AS (
	SELECT DISTINCT ON (filmid) count(filmid) as films
	FROM filmgenre
	WHERE genre != 'Sci-Fi' AND genre != 'Horror'
	GROUP BY filmid
)
SELECT count(films)
FROM distinctfilms
;


-- Oppgave 10
WITH intfilms AS (
SELECT fi.filmid, fr.rank, fr.votes, fg.genre, f.title
FROM filmitem AS fi
LEFT JOIN filmrating AS fr ON (fi.filmid = fr.filmid)
LEFT JOIN filmgenre AS fg ON (fi.filmid = fg.filmid)
LEFT JOIN film AS f ON (fi.filmid = f.filmid)
WHERE filmtype = 'C' AND fr.rank >= 8 AND fr.votes >= 1000
ORDER BY fi.filmid, fr.rank DESC, fr.votes DESC
),
highrank AS (
SELECT if.filmid, if.rank, if.votes, if.title
FROM intfilms AS if
ORDER BY if.rank DESC, if.votes DESC
LIMIT 10
),
harrisonford AS (
SELECT if.filmid, p.firstname, p.lastname, if.title
FROM intfilms AS if
LEFT JOIN filmparticipation AS fp ON (if.filmid = fp.filmid)
RIGHT JOIN person AS p ON (fp.personid = p.personid)
WHERE p.firstname = 'Harrison' AND p.lastname = 'Ford'
),
comedyromance AS (
SELECT if.filmid, if.genre, if.title
FROM intfilms as if
WHERE if.genre = 'Comedy' OR if.genre = 'Romance'
),
finalmovies As (
select title, filmid from highrank
union
select title, filmid from harrisonford
union
select title,filmid from comedyromance
)
select fm.title, count(fl.language) as languages
from finalmovies as fm
left join filmlanguage as fl on (fm.filmid = fl.filmid)
group by fm.title
;
