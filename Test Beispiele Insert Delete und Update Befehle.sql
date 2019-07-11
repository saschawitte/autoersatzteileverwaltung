USE Autoersatzteile;
GO

SELECT * FROM autoteile;
GO
-------------------------------------
/*** Beispielwerte für Testen   ***/
--      Sicht [Verwaltung]       --
-------------------------------------

-- INSERT Befehle --

INSERT INTO Verwaltung
	([Name],Ersatzteilkategorie,[Hersteller Ersatzteil ID],Autohersteller,Ersatzteilhersteller,[Datum der letzten Bestellung],Fahrzeugidentifizierungsnummer,[Lagerartikel (JA/NEIN)],Interneartikelnummer,Lagerbestand)
		VALUES
			('Supreme SX 80Ah', 'Batterie', 'SX92 SFB30 08', 'Fiat', 'VARTA', '2008-02-21', 'IVI-1244987', 1,'',14),
			('Wintera S195', 'Reifen', 'W 195/55 R16 TL', 'Skoda', 'GoodYear', '1999-03-01', 'CVW-5825673', 1, '999', 7),
			('Glübirne hinten O-P21/5W', 'Leuchten', 'P21/5W', 'Ford', 'Osram', '1998-02-21', 'FVW-5472671', 0,'188811111',17),
			('Kupplung L120/90mm', 'Kupplung', 'LL''L120', 'Opel', 'Luk', '2005-08-11', 'DVW-1272678', 0,'22225555',5),
			('Bremslicht B300-5', 'Karosserie', 'BL-B300', 'Honda', 'Honda', '', 'JPW-3472612', 0,'888',53),
			('Ausrücklager RL ''Rück 3-armig', 'Kupplung', 'RL3_V', 'Kia', 'Valeo', '1983-12-09', 'KVP-5488691', 0,'123456789',31)
;

-- UPDATE Befehle --

UPDATE Verwaltung
SET Autohersteller = 'Toyota'
WHERE
Ersatzteilkategorie = 'Batterie';

UPDATE Verwaltung
SET Autohersteller = 'Honda', Ersatzteilhersteller = 'Valeo'
WHERE
[Lagerartikel (JA/NEIN)] = 1;

-- DELETE Befehle --

DELETE FROM Verwaltung
WHERE [Datum der letzten Bestellung] <= '2018-05-21';

DELETE FROM Verwaltung
WHERE Autohersteller = 'Ford';



SELECT * FROM Verwaltung


-------------------------------------
/*** Beispielwerte für Testen   ***/
--   Sicht [Autoteileubersicht]  --
-------------------------------------

-- INSERT Befehle --

INSERT INTO Autoteileuebersicht ([Interne Artikelnummer], Ersatzteilname, Kategorie, Lagerbestand, Nachbestellt, [Hersteller-ID], [Fahrzeugidentifizierungsnummer (FIN)])
	   VALUES ('', 'XYZ 23-987', '', '', '', '', 'DDJ-5678910');

INSERT INTO Autoteileuebersicht ([Interne Artikelnummer], Ersatzteilname, Kategorie, Lagerbestand, Nachbestellt, [Hersteller-ID], [Fahrzeugidentifizierungsnummer (FIN)])
	   VALUES ('100058965', '', '', '', 'nein', '', '');

-- UPDATE Befehle --

UPDATE Autoteileuebersicht SET Kategorie = 'Leuchte';

UPDATE Autoteileuebersicht SET Ersatzteilname = 'Rücklager 2-armig', [Hersteller-ID] = 'RL2-12345';

-- DELETE Befehle --

DELETE FROM Autoteileuebersicht WHERE Lagerbestand = 12;

DELETE FROM Autoteileuebersicht WHERE Lagerbestand >= 20;

SELECT * FROM Autoteileuebersicht;
