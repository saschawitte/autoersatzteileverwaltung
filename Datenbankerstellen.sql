USE master;
GO

/*** ERSTELLUNG DATABASE [Autoersatzteile]  ***/
IF NOT EXISTS(SELECT * FROM sys.databases WHERE [name] = 'Autoersatzteile')
    CREATE DATABASE Autoersatzteile;
GO

USE Autoersatzteile;
GO
/*** Erstellung die Basistabellen   ***/

--löschen der alten Tabellen
DROP TABLE IF EXISTS autoteile; -- muss als erstes gelöscht werden wegen der FOREIGN KEYS
DROP TABLE IF EXISTS fahrzeugin;
DROP TABLE IF EXISTS kategorie;
DROP TABLE IF EXISTS hersteller;
GO

--Erstellung der Basistabelle

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'autoteile' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE')
BEGIN
	CREATE TABLE autoteile (
				_id INT IDENTITY(1,1) NOT NULL,
				ersatzteilname NVARCHAR(125),
				herstelleridentnr NVARCHAR(40),
				hersteller_auto_id INT NOT NULL,
				hersteller_ersatzteil_id INT NOT NULL,
				kategorie_id INT NOT NULL,
				zeitstempel DATE Default(GETDATE()),            
				fahrzeugin_id INT NOT NULL,
				nachzubestellen BIT Default(0),
				interneartikelnr INT NOT NULL,
				lagerbestand SMALLINT Default(0),
				CONSTRAINT PK_autoteile PRIMARY KEY (_id),
				CONSTRAINT UQ_inarti UNIQUE (interneartikelnr)
	);
END;
GO
--Erstellen der ausgelagerten Tabellen

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'kategorie' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE')
BEGIN
CREATE TABLE kategorie (
	_id INT IDENTITY(1,1) NOT NULL, 
	kategorie NVARCHAR(73),
	CONSTRAINT PK_kategorie PRIMARY KEY (_id)
);
END;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'fahrzeugin' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE')
BEGIN
CREATE TABLE fahrzeugin (
	_id INT IDENTITY (1,1) NOT NULL,
	fahrzeugin VARCHAR(11)						
	CONSTRAINT PK_fahrzeugin PRIMARY KEY (_id)
);
END;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'hersteller' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE')
BEGIN
CREATE TABLE hersteller (
	_id INT IDENTITY (1,1) NOT NULL,
	hersteller NVARCHAR (125),
	CONSTRAINT PK_hersteller PRIMARY KEY (_id)
);
END;
GO


--Erstellung der FOREIGN KEYS

ALTER TABLE autoteile 
	 ADD 
	 CONSTRAINT		FK_autoteile_fahrzeugin				FOREIGN KEY (fahrzeugin_id)				REFERENCES fahrzeugin(_id),
	 CONSTRAINT		FK_autoteile_hersteller_auto		FOREIGN KEY (hersteller_auto_id)		REFERENCES hersteller(_id),
	 CONSTRAINT		FK_autoteile_hersteller_ersatzteil  FOREIGN KEY (hersteller_ersatzteil_id)	REFERENCES hersteller(_id),
	 CONSTRAINT		FK_autoteile_kategorie				FOREIGN KEY (kategorie_id)				REFERENCES kategorie(_id)
;
GO



/*** Einfügen der Testdatensätze ***/

-- Beispielwerte in Tabelle [hersteller]

SET IDENTITY_INSERT hersteller ON;
INSERT INTO hersteller (_id, hersteller)
	   VALUES (1,'Volkswagen AG'), (2,'BMW AG'), (3,'Mercedes-Benz'), (4,'AUDI AG'), (5, 'BOSCH'), (6, 'MICHELIN'), (7, 'CASTROL'), (8, 'HELLA');
SET IDENTITY_INSERT hersteller OFF;


-- Beispielwerte in Tabelle [fahrzeugin]

SET IDENTITY_INSERT fahrzeugin ON;
INSERT INTO fahrzeugin (_id, fahrzeugin) 
	   VALUES (1,'WVWZZZ1JZ3W'), (2,'WBACJ974AFK'), (3,'WDB1690071J'), (4,'WAUZZZ8DZ8W');
SET IDENTITY_INSERT fahrzeugin OFF;


-- Beispielwerte in Tabelle [kategorie]

SET IDENTITY_INSERT kategorie ON;
INSERT INTO kategorie (_id, kategorie)
	   VALUES (1,'Batterien'), (2,'Bremsanlage'), (3,'Elektrik'), (4,'Filter'), (5,'Klimaanlage'), (6,'Lenkung'), (7,'Motor'), (8,'Öle'), (9,'Reifen'), (10,'Zünd-/Glühanlage'), (11,'Zübehör');
SET IDENTITY_INSERT kategorie OFF;


-- Beispielwerte in Tabelle [autoteile]

INSERT INTO autoteile (ersatzteilname, herstelleridentnr, hersteller_auto_id, hersteller_ersatzteil_id, kategorie_id, zeitstempel, fahrzeugin_id, nachzubestellen, interneartikelnr, lagerbestand)
	   VALUES 
	   ('Starterbatterie S3 70Ah', '0 092 S30 080', 1, 5, 1, '2019-05-22', 1, 1, '100000001', 12),
	   ('5W-40 Magnatec C3(5L)', '14F9D0', 2, 7, 8, '2019-05-20', 2, 0, '100000002', 5),
	   ('Lukas'' Sommerreifen Primacy3', 'S 205/55 R16 91V TL P3', 3, 6, 9, '2019-05-19', 3, 1, '100000003', 36),
	   ('Flachsicherung 40A', '2270-3360', 4, 8, 3, '2019-05-21', 4, 1, '100000004', 27)
;


/*** Erstellung Sicht [Autoteileuebersicht]   ***/

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Autoteileuebersicht' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'VIEW')
BEGIN
DROP VIEW Autoteileuebersicht;
END;
GO


CREATE OR ALTER VIEW [Autoteileuebersicht]
AS  
SELECT	interneartikelnr		AS [Interne Artikelnummer], 
		ersatzteilname			AS Ersatzteilname, 
		kategorie				AS Kategorie, 
		lagerbestand			AS Lagerbestand, 
		nachzubestellen			AS Nachbestellt,
		herstelleridentnr		AS [Hersteller-ID], 
		fahrzeugin				AS [Fahrzeugidentifizierungsnummer (FIN)]
FROM autoteile 
INNER JOIN fahrzeugin ON autoteile.fahrzeugin_ID = fahrzeugin._id
INNER JOIN hersteller ON autoteile.hersteller_auto_id = hersteller._id
INNER JOIN kategorie ON autoteile.kategorie_ID = kategorie._id;
;
GO

/***  Fehler- oder Warnmeldung an einen Benutzer zurückgeben (Trigger für die Sicht [Autoteileuebersicht]) ***/

DROP TRIGGER IF EXISTS Autoteileuebersicht_trigg;
GO


CREATE OR ALTER TRIGGER Autoteileuebersicht_trigg ON Autoteileuebersicht
INSTEAD OF INSERT, UPDATE, DELETE AS
BEGIN
	RAISERROR ('Änderungen jeglicher Art sind nicht gestattet', 0, 1);
	-- Schweregrade [0-9] von Datenbankfehlern: https://msdn.microsoft.com/de-de/library/ms164086.aspx 
	-- ``Informationsmeldungen, die Statusinformationen zurückgeben oder Fehler melden, die nicht schwerwiegend sind. Datenbank-Engine löst keine Systemfehler mit Schweregraden zwischen 0 und 9 aus.``--
END;
GO


/*	Sicht "Verwaltung" erstellen um unsere Tabelle zu verwalten:
	-Erstellung neuer Zeilen
	-Updaten von Zeilen
	-Löschen von Zeilen
*/

--Überprüfen ob die Sicht "Verwaltung" exisitiert.

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Verwaltung' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'VIEW')
BEGIN
DROP VIEW Verwaltung;
END;
GO


CREATE OR ALTER VIEW Verwaltung AS
SELECT 
	ersatzteilname AS [Name],
	k.kategorie AS Ersatzteilkategorie,
	herstelleridentnr  AS [Hersteller Ersatzteil ID],
	ha.hersteller AS Autohersteller,
	he.hersteller AS Ersatzteilhersteller,
	zeitstempel AS [Datum der letzten Bestellung],
	f.fahrzeugin AS Fahrzeugidentifizierungsnummer,
	nachzubestellen AS [Lagerartikel (JA/NEIN)],
	interneartikelnr AS Interneartikelnummer,
	lagerbestand AS Lagerbestand

--LEFT JOINS damit auch NULL-Werte angezeigt werden

FROM autoteile a
LEFT JOIN fahrzeugin f ON a.fahrzeugin_id = f._id
LEFT JOIN hersteller ha ON a.hersteller_auto_id = ha._id
LEFT JOIN hersteller he ON a.hersteller_ersatzteil_id = he._id
LEFT JOIN kategorie	k ON a.kategorie_id = k._id
;
GO




/*** TRIGGER für SICHT 'Verwaltung'   ***/

DROP TRIGGER IF EXISTS VerwaltungSicht_IDU; 
GO

--Erstellung eines Multi-Triggers für die Sicht "Verwaltung"
--Ermöglicht: INSERT-, DELETE- und UPDATE-Befehle

CREATE OR ALTER TRIGGER VerwaltungSicht_IDU ON Verwaltung
INSTEAD OF INSERT, DELETE, UPDATE 
AS BEGIN
--INSERT in den Basistabellen
INSERT INTO hersteller (hersteller) SELECT DISTINCT i.Autohersteller FROM inserted i WHERE i.Autohersteller NOT IN (SELECT h.hersteller FROM hersteller h);
INSERT INTO hersteller (hersteller) SELECT DISTINCT i.Ersatzteilhersteller FROM inserted i WHERE i.Ersatzteilhersteller NOT IN (SELECT h.hersteller FROM hersteller h);
INSERT INTO kategorie (kategorie) SELECT DISTINCT i.Ersatzteilkategorie FROM inserted i WHERE i.Ersatzteilkategorie NOT IN (SELECT k.kategorie FROM kategorie k);
INSERT INTO fahrzeugin (fahrzeugin) SELECT DISTINCT i.Fahrzeugidentifizierungsnummer FROM inserted i WHERE i.Fahrzeugidentifizierungsnummer NOT IN (SELECT f.fahrzeugin FROM fahrzeugin f)

	/* Entscheiden, ob es ein INSERT, UPDATE oder DELETE-Befehl war */
--------------------------------------------------------------------------------------------------------------

--Entscheidung UPDATE
IF (EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted))
BEGIN
	DECLARE @inserted AS TABLE (ID INT IDENTITY(1,1),
								ersatzteilname NVARCHAR(125),
								kategorie NVARCHAR(73),
								herstelleridentnr NVARCHAR(40),
								autohersteller NVARCHAR(125),
								ersatzteilhersteller NVARCHAR(125),
								zeitstempel DATE,
								fahrzeugin VARCHAR(11),
								nachzubestellen BIT,
								interneartikelnummer int,  
								lagerbestand smallint
);

	DECLARE @deleted AS TABLE (ID INT IDENTITY(1,1),
								internetartikelnummer INT
);


	--Schattentabelle inserted wird in die virtuelle @inserted kopiert
	INSERT INTO @inserted 
(ersatzteilname,kategorie,herstelleridentnr,autohersteller,ersatzteilhersteller,zeitstempel,fahrzeugin,nachzubestellen,interneartikelnummer, lagerbestand)
		SELECT 
[Name],Ersatzteilkategorie,[Hersteller Ersatzteil ID],Autohersteller,Ersatzteilhersteller,[Datum der letzten Bestellung],Fahrzeugidentifizierungsnummer,[Lagerartikel (JA/NEIN)],Interneartikelnummer,Lagerbestand  FROM inserted;
	INSERT INTO @deleted (internetartikelnummer) SELECT Interneartikelnummer FROM inserted;

	--Update Befehl
	UPDATE autoteile
		SET	hersteller_auto_id = ha._id,
			hersteller_ersatzteil_id = he._id,
			kategorie_id = k._id,
			fahrzeugin_id = f._id,
			ersatzteilname = i.ersatzteilname,
			herstelleridentnr = i.herstelleridentnr,
			interneartikelnr = i.interneartikelnummer,
			zeitstempel = i.zeitstempel,
			lagerbestand = i.lagerbestand,
			nachzubestellen = i.nachzubestellen
		FROM @inserted i
			LEFT JOIN fahrzeugin f ON i.fahrzeugin = f.fahrzeugin
			LEFT JOIN hersteller ha ON i.autohersteller = ha.hersteller
			LEFT JOIN hersteller he ON i.ersatzteilhersteller = he.hersteller
			LEFT JOIN kategorie	k ON i.kategorie = k.kategorie
		INNER JOIN @deleted d ON i.ID = d.ID
		WHERE autoteile.interneartikelnr = d.internetartikelnummer;
END; --IF insert + delete exist = update IF abfrage ende

--Insert entscheidung

ELSE IF (EXISTS(SELECT * FROM inserted))
BEGIN

--Helfer Tabelle @helper dient dazu die fortlaufende Internetartikelnummer automatisch zu setzen. Dafür wird mit folgendem Befehl die letzte Internetartikelnummer
--ausgesucht und die Werte aus dem Array entsprechend zugewiesen (@helper ID Wert)
--Befehl für den INSERT der Internenartikelnummer: "((SELECT Top(1) interneartikelnr FROM autoteile ORDER BY _id DESC) +@helper.ID)"
	DECLARE @helper AS TABLE (ID INT IDENTITY(1,1),
							ersatzteilname1 NVARCHAR(125),
							kategorie1 NVARCHAR(73),
							herstelleridentnr1 NVARCHAR(40),
							autohersteller1 NVARCHAR(125),
							ersatzteilhersteller1 NVARCHAR(125),
							zeitstempel1 DATE,
							fahrzeugin1 VARCHAR(11),
							nachzubestellen1 BIT,
							interneartikelnummer1 int,  
							lagerbestand1 smallint
);

	INSERT INTO @helper 
(ersatzteilname1,kategorie1,herstelleridentnr1,autohersteller1,ersatzteilhersteller1,zeitstempel1,fahrzeugin1,nachzubestellen1,interneartikelnummer1, lagerbestand1)
		SELECT 
[Name],Ersatzteilkategorie,[Hersteller Ersatzteil ID],Autohersteller,Ersatzteilhersteller,[Datum der letzten Bestellung],Fahrzeugidentifizierungsnummer,[Lagerartikel (JA/NEIN)],Interneartikelnummer,Lagerbestand  FROM inserted;

	--Zeigerschleife: 
	--für saubere internetartikelnummer1 zum joinen (es kann sonst zu komplikationen mit Duplikaten kommen wegen des UNIQUE Keys)
	DECLARE @ID INT;
	DECLARE @interneartikelnummer1 INT;
	DECLARE zeiger1 CURSOR FOR (SELECT ID, interneartikelnummer1 FROM @helper);
	OPEN zeiger1;
	--Start: UPDATE-Schleife 
	WHILE ( 1 = 1)
	BEGIN
		FETCH NEXT FROM zeiger1 INTO @ID, @interneartikelnummer1;

		IF (@@FETCH_STATUS <> 0) BREAK;
		UPDATE @helper SET interneartikelnummer1 = @id WHERE ID = @ID;
	END;
	CLOSE zeiger1;
	DEALLOCATE zeiger1;


	/*
	Insert in die autoteile Tabelle
	CASE SELECT-Statement: Falls die Tabelle leer ist 
	(z.B. durch Truncate oder versehentliches nutzen eines DELETE-Befehls ohne WHERE Klausel) 
	wird wieder der Startwert von einer Milliarde übergeben.	
	*/
	INSERT INTO autoteile 
	(ersatzteilname,herstelleridentnr,hersteller_auto_id,hersteller_ersatzteil_id,kategorie_id,zeitstempel,fahrzeugin_id,nachzubestellen,interneartikelnr,lagerbestand)
	SELECT 
	ersatzteilname1,herstelleridentnr1,ha._id,he._id,k._id,zeitstempel1, f._id, nachzubestellen1, 
	IIF ( (SELECT COUNT(*) FROM autoteile) <= 0, (1000000000+i.ID), ((SELECT Top(1) interneartikelnr FROM autoteile ORDER BY _id DESC) +i.ID))
	,lagerbestand1
	FROM @helper i
			LEFT JOIN fahrzeugin f ON i.fahrzeugin1 = f.fahrzeugin
			LEFT JOIN hersteller ha ON i.autohersteller1 = ha.hersteller
			LEFT JOIN hersteller he ON i.ersatzteilhersteller1 = he.hersteller
			LEFT JOIN kategorie	k ON i.kategorie1 = k.kategorie;
END; -- ende IF-INSERT

--DELETE entscheidung
ELSE IF (EXISTS(SELECT * FROM deleted))
BEGIN
	DELETE FROM autoteile WHERE interneartikelnr IN (SELECT Interneartikelnummer FROM deleted);
END; --Ende IF-DELETE

--Basistabellen aufräumen

DELETE FROM fahrzeugin WHERE _id NOT IN (SELECT fahrzeugin_id FROM autoteile);
DELETE FROM hersteller WHERE _id NOT IN (SELECT hersteller_auto_id FROM autoteile) AND _id NOT IN (SELECT hersteller_ersatzteil_id FROM autoteile);
DELETE FROM kategorie WHERE _id NOT IN (SELECT kategorie_id FROM autoteile);


END; -- Ende des Triggers
