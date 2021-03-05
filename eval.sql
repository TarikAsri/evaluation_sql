-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- - - - - - - - - - - - E V A L U A T I O N - S Q L   - - - - - - - - - -
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

-- ↓ ↓ ↓ A REALISER A PARTIR DE LA BASE AFPA-GESCOM, VOICI LE LIEN: ↓ ↓ ↓
-- https://ncode.amorce.org/ressources/Pool/D2WM_HB/BDD_Requetes/scripts/afpa_gescom_2020_08_20.sql

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- - - - - - - - - - - - - - - V I E W S : - - - - - - - - - - - - - - - -
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
-- Créez une vue qui affiche le catalogue produits. L'id, la référence et le nom des produits, ainsi que l'id et le nom de la catégorie doivent apparaître.

CREATE VIEW catalogue AS 
SELECT pro_id, pro_ref, pro_name, cat_id, cat_name
FROM products
JOIN categories on products.pro_cat_id = categories.cat_id
ORDER BY pro_id;

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- - - - - - - - - - S T O R E D - P R O C E D U R E S : - - - - - - - - - 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Créez la procédure stockée facture qui permet d'afficher les informations nécessaires à une facture en fonction d'un numéro de commande. Cette procédure doit sortir le montant total de la commande. Pensez à vous renseigner sur les informations légales que doit comporter une facture.

-- Information that needs to be included: 
-- • ORDER ID
-- • Product ID
-- • Product Reference and Description
-- • Price /UNIT
-- • Ordered Quantity 
-- • Order Total
-- • Date of Order
-- • Customer ID
-- • Discounts

DELIMITER |
CREATE PROCEDURE show_facture(IN order_id INT)
BEGIN

	SELECT
	ode_ord_id AS `Order ID`, 
	ode_pro_id AS `Product ID`, 
    pro_ref AS `Product Reference`,
    pro_name AS `Product Name`,
    pro_desc AS `Description`,
	ode_unit_price AS `Price p/Unit`,
	ode_quantity AS `Quantity ordered`, 
	sum(ode_unit_price*ode_quantity) AS `Total`,
    ode_discount AS `Discounts`,
	ord_order_date AS `Order Date`, 
	ord_cus_id AS `Customer ID`,
    concat(cus_lastname, cus_firstname) AS `Customer Name`
	FROM orders_details
	JOIN orders ON ode_ord_id = ord_id
	JOIN products on ode_pro_id = pro_id
    JOIN customers on ord_cus_id = cus_id
	WHERE ord_id = order_id;

END |

DELIMITER ;

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- - - - - - - - - - - - - - T R I G G E R S : - - - - - - - - - - - - - - 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Présentez le déclencheur after_products_update demandé dans la phase 2 de la séance sur les déclencheurs.

use gescom;
CREATE table commander_articles (
    `codart` INT NOT NULL primary key,
    `qte` INT NOT NULL index,
    `date` datetime NOT NULL default now()
    
);
-- - - - - - - - - - - - - - - - - - - - - - - - -
--DELIMITER |                                    -
--CREATE TRIGGER after_products_update           -   
--AFTER UPDATE ON products                       -
--FOR EACH ROW                                   -
--BEGIN                                          -
--    IF                                         -
--        products.pro_stock_alert < 5           -
--    THEN                                       -
--        INSERT INTO commander_articles VALUES  -
--END |                                          -
--DELIMITER ;                                    -
-- - - - - - - - - - - - - - - - - - - - - - - - -

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- - - - - - - - - - - - T R A N S A C T I O N S : - - - - - - - - - - - -
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
-- Amity HANAH, Manageuse au sein du magasin d'Arras, vient de prendre sa retraite. Il a été décidé, après de nombreuses tractations, de confier son poste au pépiniériste le plus ancien en poste dans ce magasin. Ce dernier voit alors son salaire augmenter de 5% et ses anciens collègues pépiniéristes passent sous sa direction.

-- Ecrire la transaction permettant d'acter tous ces changements en base des données.

-- 1. La base de données ne contient actuellement que des employés en postes. Il a été choisi de garder en base une liste des anciens collaborateurs de l'entreprise parti en retraite. Il va donc vous falloir ajouter une ligne dans la table posts pour référencer les employés à la retraite.

-- 2. Décrire les opérations qui seront à réaliser sur la table posts.

-- 3. Ecrire les requêtes correspondant à ces opéarations.

-- 4. Ecrire la transaction.


-- 1/Créer une ligne 'employés retraités' dans la table "POSTS"
insert into posts(pos_libelle)
values('Retraité');

-- 2/Sortir le Magasin d'Arras et aussi uniquement les employés de ce magasin "d'Arras"
START TRANSACTION;
SET @idshop = (select sho_id from shops where sho_city = 'Arras');
SET @idretraite = (select pos_id from posts where pos_libelle = 'Retraité');

-- 3/Modifier la fiche de 'HANNAH' dans la table 'Employees"
update employees set emp_pos_id = @idretraite where emp_lastname = 'HANNAH' AND  emp_firstname = 'Amity'AND emp_sho_id = @idshop;

-- 4/Faire une requête pour sortir la liste avec l'ID des employés "Pépinieristes" dans la Table Posts
SELECT pos_id FROM posts WHERE pos_libelle = 'Pépinieriste';

-- 5/Nouvelle Requête avec SELECT(sortant tous les employés ayant pour poste Pépiniériste) à Arras
SELECT emp_id FROM employees
JOIN posts
ON emp_pos_id = pos_id
WHERE pos_libelle = 'Pépiniériste' 
and emp_sho_id = @idshop;

-- 6/Trouver l'ancien Pépiniériste(avec date d'entrée en Entreprise "Emp_enter_date) en utilisant la fontion "MIN"
SET @id_new_manager = (SELECT emp_id
FROM employees 
JOIN posts ON emp_pos_id = posts.pos_id
WHERE pos_libelle = 'Pépiniériste' AND emp_sho_id = @idshop
ORDER BY emp_enter_date
limit 1);
-- sinon avec MIN
SET @id_new_manager = (SELECT MIN(emp_enter_date)
FROM employees 
JOIN posts ON emp_pos_id = posts.pos_id
WHERE pos_libelle = 'Pépiniériste' AND emp_sho_id = @idshop;

-- 7/Recuperer ensuite cet ID(de l'ancien pépiniériste qui deviendra le nouveau Manager<à la place d'Hannah'), modifier sa fiche Emp_Salary en faisant un Update(Salaire X 1.05)
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
SET @idshop = (select sho_id from shops where sho_city = 'Arras'); -- ville Arras

SET @id_new_manager = (SELECT emp_id -- id du monsieur que sera le nouveau manager
FROM employees 
JOIN posts ON emp_pos_id = posts.pos_id
WHERE pos_libelle = 'Pépiniériste' AND emp_sho_id = @idshop
ORDER BY emp_enter_date
limit 1);

SET @post_id_manager = (SELECT pos_id -- id du poste manager
FROM posts 
WHERE pos_libelle LIKE '%Manage%'
limit 1);

UPDATE employees
SET 
emp_salary = (emp_salary*1.05), -- if you want you can do 2 separate UPDATES and skip this one, but you will need the next query
emp_pos_id = @post_id_manager -- affecter le nouveau id "comme manager"
WHERE emp_id = @id_new_manager;
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
-- if we end up updating his role without his salary, then this query is for the salary alone ↓
SET @idshop = (select sho_id from shops where sho_city = 'Arras'); -- ville Arras

SELECT @idshop;

SET @id_new_manager = (SELECT emp_id -- id du monsieur que sera le nouveau manager
FROM employees 
WHERE emp_firstname = 'Dorian');

SELECT @id_new_manager;

UPDATE employees
set emp_salary = (emp_salary*1.05)
where emp_id = @id_new_manager;

-- 8/Update de nouveau sur tous les pépiniéristes pour mettre en valeur de la Rubrique "Emp_Superior" l'ID de leur nouveau Manager

SET @les_pepinieristes = (SELECT pos_id
FROM posts
WHERE pos_libelle = 'Pépinieriste');

SET @id_new_manager = (SELECT emp_id -- id du monsieur que sera le nouveau manager
FROM employees 
WHERE emp_firstname = 'Dorian');

UPDATE employees
SET 
emp_superior_id = @id_new_manager
WHERE emp_pos_id = @les_pepinieristes;
-- to verify
SELECT *
FROM employees
JOIN posts
ON pos_id = emp_pos_id
WHERE emp_superior_id = 10;






