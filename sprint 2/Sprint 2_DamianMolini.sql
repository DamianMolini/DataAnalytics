SELECT * FROM transaction;
SELECT * FROM company;

#Nivell 1

#Exercici 1: Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT *
FROM transaction
WHERE declined = 0
AND company_id IN (
	SELECT id
    FROM company
    WHERE country = "Germany");
    
#Exercici 2: Màrqueting està preparant alguns informes de tancaments de gestió, 
#et demanen que els passis un llistat de les empreses que han realitzat transaccions 
#per una suma superior a la mitjana de totes les transaccions.

SELECT company_name
FROM company
WHERE id IN (
	SELECT company_id
    FROM transaction
    WHERE declined = 0
    AND amount > (
		SELECT AVG(amount)
        FROM transaction
        WHERE declined = 0
        )
	);
    
#Exercici 3: El departament de comptabilitat va perdre la informació de les transaccions realitzades per una empresa, 
#però no recorden el seu nom, només recorden que el seu nom iniciava amb la lletra c. Com els pots ajudar? 
#Comenta-ho acompanyant-ho de la informació de les transaccions.

SELECT company_name, transaction.*
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE company_name LIKE "C%";

#Exercici 4: Van eliminar del sistema les empreses que no tenen transaccions registrades, lliura el llistat d'aquestes empreses.

#Opción A: 

SELECT c.company_name
FROM company c
LEFT JOIN transaction t
	ON c.id = t.company_id
WHERE t.company_id IS NULL
AND declined = 0;

#Opción B:

SELECT company_name
FROM company
WHERE NOT EXISTS (
	SELECT *
    FROM transaction
    WHERE transaction.company_id = company.id 
    AND declined = 0);
    

    
# Nivell 2
# Exercici 1: En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
# per a fer competència a la companyia 'Non Institute'. Per a això, et demanen la llista de totes les 
# transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

SELECT 
	transaction.id AS transaction_id,
    amount,
    company_name,
    country
FROM transaction
JOIN company
	ON transaction.company_id = company.id
WHERE declined = 0
AND country = (
	SELECT country
    FROM company
    WHERE company_name = "Non Institute")
AND company_name != "Non Institute";

# Exercici 2: El departament de comptabilitat necessita que trobis l'empresa que ha realitzat la transacció de major suma en la base de dades.

SELECT 
	company_name,
	amount
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE amount = (
	SELECT MAX(amount)
    FROM transaction
    WHERE declined = 0);

#Nivell 3

# Exercici 1: S'estan establint els objectius de l'empresa per al següent trimestre, 
# per la qual cosa necessiten una base sòlida per a avaluar el rendiment i mesurar l'èxit en els diferents mercats. 
# Per a això, necessiten el llistat dels països la mitjana de transaccions dels quals sigui superior a la mitjana general.


# Opción A: Monto de las transacciones

SELECT 
	country, 
	ROUND(AVG(amount),2) AS avg_amount, 
    (SELECT ROUND(AVG(amount),2)
	FROM transaction
	WHERE declined = 0) AS avg_general
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
HAVING avg_amount > (
	SELECT AVG(amount)
	FROM transaction
	WHERE declined = 0);

# Opción B: Número de transacciones

SELECT 
	country,
    avg_transactions
FROM (
	SELECT 
		country, 
        ROUND(AVG(transactions_per_country1),0) AS avg_transactions
	FROM (
		SELECT 
			country, 
			COUNT(transaction.id) AS transactions_per_country1
		FROM company
		JOIN transaction
			ON company.id = transaction.company_id
		WHERE declined = 0
		GROUP BY country
        ) count_per_country1
	GROUP BY country
    ) average_per_country
WHERE avg_transactions > (
	SELECT ROUND(AVG(transactions_per_country2),0)
	FROM (
		SELECT 
			country, 
			COUNT(transaction.id) AS transactions_per_country2
		FROM company
		JOIN transaction
			ON company.id = transaction.company_id
		WHERE declined = 0
		GROUP BY country
        ) count_per_country2
	);  

   
# Exercici 2: Necessitem optimitzar l'assignació dels recursos i dependrà de la 
# capacitat operativa que es requereixi, per la qual cosa et demanen la informació 
# sobre la quantitat de transaccions que realitzen les empreses, però el departament 
# de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.


SELECT 
	company_name,
    count_of_transactions,
    CASE WHEN count_of_transactions > 4 THEN "More than 4 transactions"
    ELSE "4 or less transactions"
    END AS "transactions_detail"
FROM (
	SELECT 
		company_name, 
		COUNT(transaction.id) AS count_of_transactions
	FROM company
	JOIN transaction
		ON company.id = transaction.company_id
	WHERE declined = 0
	GROUP BY company_name
    ) count_per_company;


