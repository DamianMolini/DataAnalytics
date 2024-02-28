#Nivell 1
#Exercici 2: Has d'obtenir el nom, email i país de cada companyia, ordena les dades en funció del nom de les companyies.

SELECT 
	company_name,
    email,
    country
FROM company
ORDER BY 1;
	
#Exercici 3: Des de la secció de màrqueting et sol·liciten que els passis un llistat dels països que estan fent compres.

SELECT DISTINCT country
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0;

#Exercici 4: Des de màrqueting també volen saber des de quants països es realitzen les compres.

SELECT COUNT(DISTINCT country) AS NumCountries
FROM company
INNER JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0;

#Exercici 5: El teu cap identifica un error amb la companyia que té aneu 'b-2354'. 
# Per tant, et sol·licita que li indiquis el país i nom de companyia d'aquest aneu.

SELECT 
	country,
    company_name
FROM company
WHERE id = "b-2354";

#Exercici 6 A més, el teu cap et sol·licita que indiquis quina és la companyia amb major despesa mitjana?

SELECT 
	company_name, 
    ROUND(AVG(amount),2) AS avg_expense
FROM transaction
JOIN company
	ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY 2 DESC
LIMIT 1;


#Nivell 2

#Exercici 1 El teu cap està redactant un informe de tancament de l'any i et sol·licita que li enviïs informació rellevant per al document. 
# Per a això et sol·licita verificar si en la base de dades existeixen companyies amb identificadors (aneu) duplicats.

SELECT 
	c1.id, 
    c1.company_name AS company_1, 
    c2.company_name AS company_2
FROM company c1, company c2
WHERE c1.company_name != c2.company_name
AND c1.id = c2.id;

#Exercici 2 En quin dia es van realitzar les cinc vendes més costoses? Mostra la data de la transacció i la sumatòria de la quantitat de diners.

SELECT
	DATE(timestamp) AS date,
    SUM(amount) as total_amount
FROM transaction
WHERE declined = 0
GROUP BY date
ORDER BY 2 DESC
LIMIT 5;

#Exercici 3 En quin dia es van realitzar les cinc vendes de menor valor? Mostra la data de la transacció i la sumatòria de la quantitat de diners.
SELECT
	DATE(timestamp) AS date,
    SUM(amount) as total_amount
FROM transaction
WHERE declined = 0
GROUP BY date
ORDER BY 2
LIMIT 5;

#Exercici 4 Quina és la mitjana de despesa per país? Presenta els resultats ordenats de major a menor mitjà

SELECT 
	country,
    ROUND(AVG(amount),2) AS avg_expense
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
ORDER BY 2 DESC;


# Nivell 3

#Exercici 1 Presenta el nom, telèfon i país de les companyies, juntament amb la quantitat total gastada, 
# d'aquelles que van realitzar transaccions amb una despesa compresa entre 100 i 200 euros. Ordena els resultats de major a menor quantitat gastada.
    
SELECT 
	company_name,
    phone,
    country,
    SUM(amount) AS total_expense
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE amount BETWEEN 100 AND 200
AND declined = 0
GROUP BY company_name, phone, country
ORDER BY 4 DESC;

#Exercici 2 Indica el nom de les companyies que van fer compres el 16 de març del 2022, 28 de febrer del 2022 i 13 de febrer del 2022.

SELECT DISTINCT company_name
FROM company
JOIN transaction
	ON company.id =  transaction.company_id
WHERE DATE(timestamp) IN ("2022-03-16", "2022-02-28", "2022-02-13")
AND declined = 0;