#Creamos la database

CREATE DATABASE sprint_4;

USE sprint_4;

CREATE TABLE transactions(
	id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(15),
    business_id VARCHAR(15),
    timestamp TIMESTAMP,
    amount DECIMAL (10,2),
    declined TINYINT (1),
    product_ids VARCHAR(50),
    user_id INT,
    lat FLOAT,
    longitude FLOAT
    );

#Importamos a la tabla transactions
LOAD DATA
INFILE 'transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;
    
SELECT * FROM transactions;

CREATE TABLE products (
	id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL (10,2),
    colour VARCHAR(15),
    weight FLOAT,
    warehouse_id VARCHAR(15)
    );

#Importamos a la tabla products
LOAD DATA
INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SELECT * FROM products;

CREATE TABLE users (
	id INT PRIMARY KEY,
    name VARCHAR (50),
    surname VARCHAR (50),
    phone VARCHAR (150),
    email VARCHAR (150),
    birth_date VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(50),
    address VARCHAR(150)
    );
      
#Importamos a la tabla users
LOAD DATA
INFILE 'users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 ROWS;

LOAD DATA
INFILE 'users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 ROWS;

LOAD DATA
INFILE 'users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 ROWS;

SELECT * FROM users;

CREATE TABLE credit_cards (
	id varchar(45) NOT NULL,
    user_id INT,
	iban varchar(45),
	pan varchar(45),
	pin char(4) DEFAULT NULL,
	cvv char(3) DEFAULT NULL,
	track1 varchar (150),
	track2 varchar(150),
	expiring_date date,
	PRIMARY KEY (id)
);

#Importamos a la tabla credit_cards
LOAD DATA
INFILE 'credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ","
IGNORE 1 ROWS;

SELECT * FROM credit_cards;

CREATE TABLE companies (
	company_id VARCHAR(45) PRIMARY KEY,
	company_name VARCHAR(255),
	phone VARCHAR(15),
	email VARCHAR(100),
	country VARCHAR(100),
	website VARCHAR(255)
    );
    
#Importamos a la tabla companies
LOAD DATA
INFILE 'companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ","
IGNORE 1 ROWS;

SELECT * FROM companies;

CREATE TABLE transactions_products (
	transaction_id VARCHAR(255),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
    );
    
LOAD DATA
INFILE 'transactions_products.csv'
INTO TABLE transactions_products
FIELDS TERMINATED BY ";"
IGNORE 1 ROWS;

SELECT * FROM transactions_products;

#a continuación, creamos las FK en la tabla de hechos, referenciando las PK de las respectivas dimensiones
ALTER TABLE transactions
ADD CONSTRAINT
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

ALTER TABLE transactions
ADD CONSTRAINT
FOREIGN KEY (business_id) REFERENCES companies(company_id);

ALTER TABLE transactions
ADD CONSTRAINT
FOREIGN KEY (user_id) REFERENCES users(id);

#eliminamos la columna "product_ids" ya que la hemos reemplazado por la tabla de unión "transactions_products"
ALTER TABLE transactions
DROP COLUMN product_ids;

SHOW COLUMNS FROM transactions;

SELECT * FROM transactions;

# Exercici 1: Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT CONCAT(name, " ", surname) AS full_name
FROM users
WHERE id IN (
	SELECT user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(*) > 30);

# Exercici 2: Mostra la mitjana de la suma de transaccions per IBAN de les targetes de crèdit en la companyia Donec Ltd. utilitzant almenys 2 taules.

#cuántos IBAN tiene esta empresa?

SELECT DISTINCT cc.iban
FROM credit_cards cc
JOIN transactions t
	ON cc.id = t.card_id
JOIN companies co
	ON co.company_id = t.business_id
WHERE company_name = "Donec Ltd";

#como solo tiene un IBAN, no hace falta agrupar por esta variable.

SELECT 
	ROUND(AVG(t.amount),2) AS avg_amount
FROM transactions t
JOIN companies co
	ON co.company_id = t.business_id
WHERE company_name = "Donec Ltd";


# Nivell 2

# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades:

CREATE TABLE active_credit_cards (
	id VARCHAR(45),
	status VARCHAR(45),
    PRIMARY KEY (id),
    FOREIGN KEY (id) references credit_cards(id)
    );

INSERT INTO active_credit_cards
-- creamos una primera CTE table para saber cuál es el número de transacciones de cada card_id
WITH count_transactions AS (
	SELECT card_id, COUNT(*) AS numTransactions
    FROM transactions
	GROUP BY card_id),
-- creamos otra CTE table donde generamos un ranking para cada card_id, ordenando por timestamp para saber cuáles fueron las últimas transacciones;
-- además, hacemos un conteo acumulado (running total) de la columna "declined" que utilizaremos en el CASE statement
general_ranking AS (
	SELECT *, 
		ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY TIMESTAMP DESC) AS ranking,
        SUM(declined) OVER(PARTITION BY card_id ORDER BY TIMESTAMP DESC) AS running_total
	FROM transactions)

SELECT c.card_id,
	CASE WHEN 
    -- si el id tiene 3 o más transacciones, y en el ranking 3 tenemos un total acumulado de 3, entonces las últimas 3 transacciones fueron declined
	(c.numTransactions >= 3 AND g.ranking = 3 AND g.running_total = 3) THEN "inactive" 
    WHEN 
	-- si el id tiene 2 transacciones, y en el ranking 2 tenemos un total acumulado de 2, entonces ambas transacciones fueron rechazadas
    (c.numTransactions = 2 AND g.ranking = 2 AND g.running_total = 2) THEN "inactive"
    WHEN 
	-- si el id tiene 1 transacción, y el total acumulado es 1, la transacción fue rechazada
    (c.numTransactions = 1 AND g.running_total = 1) THEN "inactive"
    ELSE "active"
    END AS status
FROM count_transactions c
JOIN general_ranking g
	ON c.card_id = g.card_id
WHERE g.ranking = 3 -- de los IDs con 3 o más transacciones, solo queremos el ranking "3" de cada id
OR (g.ranking = 2 AND c.numTransactions = 2) -- de los IDs con 2 transacciones, solo queremos el ranking "2" de cada id
OR (c.numTransactions = 1) -- IDs con 1 transacción
;

SELECT * FROM active_credit_cards;

                   
# Exercici 1: Quantes targetes estan actives?

SELECT COUNT(*) as active_cards
FROM active_credit_cards
WHERE status = "active";

# Nivell 3

# Exercici 1: Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT 
	p.id AS product_id, 
    p.product_name,
    p.price,
    p.colour,
    COUNT(tp.transaction_id) AS sales
FROM products p
LEFT JOIN transactions_products tp -- usamos LEFT JOIN para que aquellos productos que no se vendieron aparezcan en los resultados con un "0"
	ON p.id = tp.product_id
GROUP BY p.id, p.product_name, p.price, p.colour
ORDER BY sales DESC, p.price DESC;

# Chequeamos si el user_id de users es igual al user_id de credit_cards

SELECT u.id AS users_userID, t.user_id AS transactions_userID, c.user_id AS creditcards_userID 
FROM users u
JOIN transactions t
	ON u.id = t.user_id
JOIN credit_cards c 
	ON c.id = t.card_id;
    
# como vimos que no, cambiaremos el nombre del campo a pedido del cliente:

ALTER TABLE credit_cards
RENAME COLUMN user_id TO userID_NeedsReview;

SHOW COLUMNS FROM credit_cards;