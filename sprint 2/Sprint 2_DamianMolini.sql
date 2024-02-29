SELECT * FROM transaction;
SELECT * FROM company;

#Nivell 1

#Exercici 1: Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id
    FROM company
    WHERE country = "Germany");
    
#Exercici 2: Màrqueting està preparant alguns informes de tancaments de gestió, 
#et demanen que els passis un llistat de les empreses que han realitzat transaccions 
#per una suma superior a la mitjana de totes les transaccions.

SELECT company_name
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE amount > (
	SELECT AVG(amount)
    FROM transaction);
    
#Exercici 3: El departament de comptabilitat va perdre la informació de les transaccions realitzades per una empresa, 
#però no recorden el seu nom, només recorden que el seu nom iniciava amb la lletra c. Com els pots ajudar? 
#Comenta-ho acompanyant-ho de la informació de les transaccions.

SELECT company_name, transaction.*
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE company_name LIKE "C%";

#Exercici 4: Van eliminar del sistema les empreses que no tenen transaccions registrades, lliura el llistat d'aquestes empreses.
SELECT company_name
FROM company
WHERE id NOT IN (
	SELECT company_id
    FROM transaction
    WHERE declined = 0);
    
# Nivell 2
# Exercici 1: En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
# per a fer competència a la companyia 'Non Institute'. Per a això, et demanen la llista de totes les 
# transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

SELECT * 
FROM transaction
JOIN company
	ON transaction.company_id = company.id
WHERE country = (
	SELECT country
    FROM company
    WHERE company_name = "Non Institute");

# Exercici 2: El departament de comptabilitat necessita que trobis l'empresa que ha realitzat la transacció de major suma en la base de dades.

SELECT company_name
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


SELECT 
	country, 
	COUNT(transaction.id) AS num_transactions, 
    (SELECT ROUND(AVG(count_transactions),0) AS avg_transactions
	FROM (
		SELECT company_id, COUNT(*) AS count_transactions
		FROM transaction
		WHERE declined = 0
		GROUP BY company_id) sub ) AS avg_transactions 
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
HAVING num_transactions > (
	SELECT ROUND(AVG(count_transactions),0)
	FROM (
		SELECT company_id, COUNT(*) AS count_transactions
		FROM transaction
		WHERE declined = 0
		GROUP BY company_id) count
	);
    
SELECT 
	country, 
    ROUND(AVG(amount),2) AS avg_amount,
    (SELECT ROUND(AVG(avg_transactions),2)
	FROM (SELECT 
			country, 
            AVG(amount) AS avg_transactions
		FROM transaction
		JOIN company
			ON company.id = transaction.company_id
		WHERE declined = 0
		GROUP BY country) AVG) AS avg_amount_by_country    
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
HAVING avg_amount > (
	SELECT AVG(avg_transactions)
	FROM (SELECT 
			country, 
            AVG(amount) AS avg_transactions
		FROM transaction
		JOIN company
			ON company.id = transaction.company_id
		WHERE declined = 0
		GROUP BY country) AVG
	);
    
SELECT country, 
	AVG(amount) AS avg_amount, 
    (SELECT AVG(amount)
	FROM transaction
	WHERE declined = 0) AS avg_general
FROM company
JOIN transaction
	ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
HAVING AVG(amount) > (
	SELECT AVG(amount)
	FROM transaction
	WHERE declined = 0);
    
# Exercici 2: Necessitem optimitzar l'assignació dels recursos i dependrà de la 
# capacitat operativa que es requereixi, per la qual cosa et demanen la informació 
# sobre la quantitat de transaccions que realitzen les empreses, però el departament 
# de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.


SELECT 
	company_name,
    CASE WHEN count_of_transactions > 4 THEN "More than 4 transactions"
    WHEN count_of_transactions <= 4 THEN "4 or less transactions"
    END AS "num_of_transactions"
FROM (SELECT 
	company_name, 
	COUNT(transaction.id) AS count_of_transactions
	FROM company
	JOIN transaction
		ON company.id = transaction.company_id
	WHERE declined = 0
	GROUP BY company_name) count_per_company;


