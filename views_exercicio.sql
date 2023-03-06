USE MASTER
GO
DROP DATABASE IF EXISTS views_exercicio
GO
CREATE DATABASE views_exercicio
GO
USE views_exercicio
GO

CREATE TABLE motoristas (
	codigo			INT			NOT NULL	UNIQUE,
	nome			VARCHAR(40) NOT NULL,
	naturalidade	VARCHAR(40) NOT NULL,

	PRIMARY KEY(codigo)
);
GO

CREATE TABLE onibus (
	placa		CHAR(7)			NOT NULL	UNIQUE,
	marca		VARCHAR(15)		NOT NULL,
	ano			INT				NOT NULL,
	descricao	VARCHAR(20)		NOT NULL,

	PRIMARY KEY(placa)
);
GO

CREATE TABLE viagens (
	codigo				INT			NOT NULL	UNIQUE,
	onibus_placa		CHAR(7)		NOT NULL,
	motorista_codigo	INT			NOT NULL,
	hora_saida			INT CHECK 
	(hora_saida >= 0 AND hora_saida <= 23)	   NOT NULL,
	hora_chegada		INT CHECK 
	(hora_chegada >= 0 AND hora_chegada <= 23) NOT NULL,
	partida				VARCHAR(40) NOT NULL,
	destino				VARCHAR(40) NOT NULL,

	PRIMARY KEY(codigo),
	FOREIGN KEY(onibus_placa) REFERENCES onibus(placa),
	FOREIGN KEY(motorista_codigo) REFERENCES motoristas(codigo)
);
GO

INSERT INTO motoristas(codigo, nome, naturalidade) 
VALUES
(12341, 'Julio Cesar', 'São Paulo'),
(12342, 'Mario Carmo', 'Americana'),
(12343, 'Lucio Castro', 'Campinas'),
(12344, 'André Figueiredo', 'São Paulo'),
(12345, 'Luiz Carlos', 'São Paulo'),
(12346, 'Carlos Roberto', 'Campinas'),
(12347, 'João Paulo', 'São Paulo');
GO

INSERT INTO onibus (placa, marca, ano, descricao) 
VALUES
('adf0965', 'Mercedes', 2009, 'Leito'),
('bhg7654', 'Mercedes', 2012, 'Sem Banheiro'),
('dtr2093', 'Mercedes', 2017, 'Ar Condicionado'),
('gui7625', 'Volvo', 2014, 'Ar Condicionado'),
('jhy9425', 'Volvo', 2018, 'Leito'),
('lmk7485', 'Mercedes', 2015, 'Ar Condicionado'),
('aqw2374', 'Volvo', 2014, 'Leito');
GO

INSERT INTO viagens (codigo, onibus_placa, motorista_codigo, hora_saida, hora_chegada, partida, destino) 
VALUES
(101, 'adf0965', 12343, 10, 12, 'São Paulo', 'Campinas'),
(102, 'gui7625', 12341, 7, 12, 'São Paulo', 'Araraquara'),
(103, 'bhg7654', 12345, 14, 22, 'São Paulo', 'Rio de Janeiro'),
(104, 'dtr2093', 12344, 18, 21, 'São Paulo', 'Sorocaba'),
(105, 'aqw2374', 12342, 11, 17, 'São Paulo', 'Ribeirão Preto'),
(106, 'jhy9425', 12347, 10, 19, 'São Paulo', 'São José do Rio Preto'),
(107, 'lmk7485', 12346, 13, 20, 'São Paulo', 'Curitiba'),
(108, 'adf0965', 12343, 14, 16, 'Campinas', 'São Paulo'),
(109, 'gui7625', 12341, 14, 19, 'Araraquara', 'São Paulo'),
(110, 'bhg7654', 12345, 0, 8, 'Rio de Janeiro', 'São Paulo'),
(111, 'dtr2093', 12344, 22, 1, 'Sorocaba', 'São Paulo'),
(112, 'aqw2374', 12342, 19, 5, 'Ribeirão Preto', 'São Paulo'),
(113, 'jhy9425', 12347, 22, 7, 'São José do Rio Preto', 'São Paulo'),
(114, 'lmk7485', 12346, 0, 7, 'Curitiba', 'São Paulo');
GO

/* 1) Criar um Union das tabelas Motorista e ônibus, 
com as colunas ID (Código e Placa) e Nome (Nome e Marca) */

SELECT CAST(motoristas.codigo AS VARCHAR(10)) AS Codigo, 
			SUBSTRING(UPPER(onibus.placa),1,3)+' - '+
			SUBSTRING(onibus.placa,4,4) AS Placa, 
			motoristas.nome AS Nome, onibus.marca AS Marca
FROM motoristas 
INNER JOIN viagens ON motoristas.codigo = viagens.motorista_codigo
INNER JOIN onibus ON viagens.onibus_placa = onibus.placa
UNION
SELECT CAST(motoristas.codigo AS VARCHAR(10)) AS Codigo,
			SUBSTRING(UPPER(onibus.placa),1,3)+' - '+
			SUBSTRING(onibus.placa,4,4) AS Placa, 
			motoristas.nome AS Nome, onibus.marca AS Marca
FROM onibus
INNER JOIN viagens ON onibus.placa = viagens.onibus_placa
INNER JOIN motoristas ON viagens.motorista_codigo = motoristas.codigo;
GO

/* 2) Criar uma View (Chamada v_motorista_onibus) do Union acima */														

CREATE VIEW v_motorista_onibus AS 
SELECT CAST(motoristas.codigo AS VARCHAR(10)) AS Codigo,
			SUBSTRING(UPPER(onibus.placa),1,3)+' - '+
			SUBSTRING(onibus.placa,4,4) AS Placa, 
			motoristas.nome AS Nome, onibus.marca AS Marca
FROM motoristas 
INNER JOIN viagens ON motoristas.codigo = viagens.motorista_codigo
INNER JOIN onibus ON viagens.onibus_placa = onibus.placa
UNION
SELECT CAST(motoristas.codigo AS VARCHAR(10)) AS Codigo, 
			SUBSTRING(UPPER(onibus.placa),1,3)+' - '+
			SUBSTRING(onibus.placa,4,4) AS Placa, 
			motoristas.nome AS Nome, onibus.marca AS Marca
FROM onibus
INNER JOIN viagens ON onibus.placa = viagens.onibus_placa
INNER JOIN motoristas ON viagens.motorista_codigo = motoristas.codigo;
GO

SELECT * FROM v_motorista_onibus
GO

/* 3) Criar uma View (Chamada v_descricao_onibus) 
que mostre o Código da Viagem, o Nome do motorista, 
a placa do ônibus (Formato XXX-0000), a Marca do ônibus, 
o Ano do ônibus e a descrição do onibus	*/

CREATE VIEW v_descricao_onibus AS
SELECT viagens.codigo AS Codigo, motoristas.nome AS Nome, 
	   SUBSTRING(UPPER(onibus.placa),1,3)+' - '+
	   SUBSTRING(onibus.placa,4,4) AS Placa,
	   onibus.marca AS Marca, onibus.ano AS Ano, onibus.descricao AS Descricao
FROM viagens 
INNER JOIN onibus ON viagens.onibus_placa = onibus.placa
INNER JOIN motoristas ON viagens.motorista_codigo = motoristas.codigo
WHERE viagens.codigo = '';
GO

SELECT * FROM v_descricao_onibus
GO

/* 	4) Criar uma View (Chamada v_descricao_viagem) que mostre 
o Código da viagem, a placa do ônibus(Formato XXX-0000), 
a Hora da Saída da viagem (Formato HH:00), a Hora da Chegada 
da viagem (Formato HH:00), partida e destino */

CREATE VIEW v_descricao_viagem AS
SELECT viagens.codigo AS Codigo, 
	   SUBSTRING(UPPER(onibus.placa),1,3)+' - '+
	   SUBSTRING(onibus.placa,4,4) AS Placa,
	   CONVERT(VARCHAR(5), DATEADD(HOUR, hora_saida, 0), 108) AS Saida,
	   CONVERT(VARCHAR(5), DATEADD(HOUR, hora_chegada, 0), 108) AS Chegada,
	   viagens.partida AS Partida, viagens.destino AS Destino
FROM viagens
INNER JOIN onibus ON viagens.onibus_placa = onibus.placa
WHERE viagens.codigo = '';
GO

SELECT * FROM v_descricao_viagem
GO