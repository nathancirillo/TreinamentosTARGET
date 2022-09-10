-- populando a tabela UnidadeFederacao
INSERT INTO UnidadeFederacao(Nome,Sigla)
SELECT DISTINCT DESCRICAO,UF FROM Excel ORDER BY Descricao


-- populando a tabela Cidade
INSERT INTO Cidade(Nome, IdUnidadeFederacao)
SELECT DISTINCT	
	Ex.Cidade,
	UF.Id
FROM EXCEL Ex
INNER JOIN UnidadeFederacao UF
ON Ex.UF = UF.Sigla


--deixando o nome da cidade em mai�sculo
declare @temporaria as table
(
	nome varchar(100),
	unidadeFederacao int 
)

insert into @temporaria(nome, unidadeFederacao)
select upper(nome),IdUnidadeFederacao from Cidade

delete from  Cidade 
DBCC CHECKIDENT('[Cidade]', RESEED, 0)

insert into Cidade(Nome,IdUnidadeFederacao)
select nome,unidadeFederacao from @temporaria

-- usando o group by para mostrar o n�mero de clientes por estado
-- having similar ao where por�m usado para fun��es de agrega��o
-- � poss�vel usar o having e o where na mesma consulta, por�m deve saber o momento
-- where faz a pesquisa antes de agrupar; j� o having faz depois do agrupamento
select
	descricao as Estado,
	count(*) as Qtd_clientes
from
Excel
	where uf in ('MG','SP')
	group by (descricao)
	order by count(*)

select * from cliente
select * from excel


-- populando a tabela de clientes
insert into cliente(nome,cnpj,endereco,bairro,idcidade,datacadastro)
select distinct
	E.nome,
	E.cnpj,
	E.endereco,
	E.bairro,
	C.Id,
	E.data_cadastro
from
	Excel E
inner join cidade C 
ON E.cidade = C.nome
WHERE E.data_cadastro is not null and E.data_cadastro <> 'NULL'

SET DATEFORMAT YMD


-- visualiza��o do excel com dados sem redund�ncia e tratados
SELECT 
	Cli.Nome, 
	Cli.Cnpj, 
	Cli.Endereco,
	Cli.Bairro, 
	Cid.Nome, 
	Uf.Sigla, 
	Uf.Nome,
	Cli.DataCadastro
FROM 
	Cliente Cli
INNER JOIN Cidade Cid ON Cli.IdCidade = Cid.Id
INNER JOIN UnidadeFederacao Uf ON Cid.IdUnidadeFederacao = Uf.Id 

SELECT * FROM ClienteTelefone


-- usando UNION para juntar consultas
-- UNION - traz tudo o que voc� imaginar se tiver duplicados ele traz
-- UNION ALL - ele tamb�m junta mas traz os sem duplicidades (como se tivesse o DISTINCT)
-- populando a tabela de clientetelefone
INSERT INTO ClienteTelefone(IdCliente, IdTipoTelefone, Numero)
select CLI.ID, 1 as TipoTelefone, telefone1 from Excel EXE
inner join Cliente CLI ON EXE.Nome = CLI.Nome AND EXE.Cnpj = CLI.CNPJ
WHERE EXE.TELEFONE1 IS NOT NULL AND EXE.TELEFONE1 <> 'NULL'
UNION
select CLI.ID, 2, telefone2 from Excel EXE
inner join Cliente CLI ON EXE.Nome = CLI.Nome AND EXE.Cnpj = CLI.CNPJ
WHERE EXE.TELEFONE2 IS NOT NULL AND EXE.TELEFONE2 <> 'NULL'
UNION
select CLI.ID, 3, fax from Excel EXE
inner join Cliente CLI ON EXE.Nome = CLI.Nome AND EXE.Cnpj = CLI.CNPJ
WHERE EXE.FAX IS NOT NULL AND EXE.FAX <> 'NULL'


-- GETDATE() -> traz a hora exata que o comando foi executado no servidor
-- DATENAME() -> traz o nome sobre a parte da data 
-- DATEPART() -> traz o n�mero que representa a parte da data especificada
-- MONTH() e YEAR() -> faz a mesma coisa do DATEPART(), por�m funciona nas vers�es mais novas do SQL
-- DATEDIFF() -> permite trazer a diferen�a entre duas datas
-- DATEADD() -> permite adicionar tempo a uma data especificada
-- EOMONTH() -> retorna o �ltimo dia do m�s da data especificada
SELECT GETDATE(); 

SELECT 
	DataCadastro,
	DATENAME(MONTH,DataCadastro) AS DateName,
	DATEPART(MONTH, DataCadastro) AS DatePart, 
	MONTH(DataCadastro) AS Month,
	YEAR(DataCadastro) AS Year,
	DATEDIFF(DAY,DataCadastro,GETDATE()) AS DateDiff, 
	DATEADD(MONTH,1,GETDATE()) AS DateAdd, 
	EOMONTH(DataCadastro) AS EoMonth
FROM CLIENTE
WHERE
	YEAR(DataCadastro) = 1999 AND
	MONTH(DataCadastro) = 7


-- Convers�es de dados usando CAST E CONVERT
-- Simula um tipo de dado em outro tipo de dado. Veja o exemplo abaixo desconsiderando as horas da data
SELECT * FROM Cliente WHERE CAST(DataCadastro AS DATE) = '1999-07-07'

--Formatos diferentes para serem usados no CONVERT. 
SELECT CONVERT(VARCHAR, GETDATE(),101) AS '101' 
SELECT CONVERT(VARCHAR, GETDATE(),102) AS '102'
SELECT CONVERT(VARCHAR, GETDATE(),103) AS '103'
SELECT CONVERT(VARCHAR, GETDATE(),104) AS '104'
SELECT CONVERT(VARCHAR, GETDATE(),105) AS '105'
SELECT CONVERT(VARCHAR, GETDATE(),106) AS '106'
SELECT CONVERT(VARCHAR, GETDATE(),107) AS '107'
SELECT CONVERT(VARCHAR, GETDATE(),108) AS '108'
SELECT CONVERT(VARCHAR, GETDATE(),109) AS '109'
SELECT CONVERT(VARCHAR, GETDATE(),110) AS '110'
SELECT CONVERT(VARCHAR, GETDATE(),111) AS '111'
SELECT CONVERT(VARCHAR, GETDATE(),112) AS '112'
SELECT CONVERT(VARCHAR, GETDATE(),113) AS '113'
SELECT CONVERT(VARCHAR, GETDATE(),114) AS '114'
SELECT CONVERT(VARCHAR, GETDATE(),115) AS '115'
SELECT CONVERT(VARCHAR, GETDATE(),116) AS '116'
SELECT CONVERT(VARCHAR, GETDATE(),117) AS '117'
SELECT CONVERT(VARCHAR, GETDATE(),118) AS '118'
SELECT CONVERT(VARCHAR, GETDATE(),119) AS '119'
SELECT CONVERT(VARCHAR, GETDATE(),120) AS '120'
SELECT CONVERT(VARCHAR, GETDATE(),121) AS '121'
SELECT CONVERT(VARCHAR, GETDATE(),122) AS '122'
SELECT CONVERT(VARCHAR, GETDATE(),123) AS '123'
SELECT CONVERT(VARCHAR, GETDATE(),124) AS '124'

-- pesquisando entre inverlos de datas
-- o ideal � sempre eliminar as horas para tratar somente as datas
SELECT 
	*
FROM 
	Cliente
WHERE CONVERT(VARCHAR,DataCadastro,112) >= '19990101' AND
	  CONVERT(VARCHAR,DataCadastro,112) <= '20020101'


-- INSTRU��O CASE...WHEN EM CONSULTAS
-- evitar esse tipo de coisa em consultas pesadas, pois usa muita mem�ria
-- uma forma de ser interessante � trabalhar com tabelas tempor�rias ao inv�s
SELECT 
	Numero,
	CASE 
		WHEN IdTipoTelefone = 1 THEN 'Telefone Comercial'
		WHEN IdTipoTelefone = 2 THEN 'Telefone Residencial'
		WHEN IdTipoTelefone = 3 THEN 'Telefone Celular'
		ELSE 'N�o Identificado'
	END AS TipoTelefone
FROM ClienteTelefone

-- obtendo o mesmo resultado usando uma tabela tempor�ria
-- isso ajuda demais ao trabalhar com progra��o de procedure
DECLARE @TableTemp TABLE(idTpTelefone int, telefone varchar(50))
INSERT INTO @TableTemp values(1, 'Telefone Comercial')
INSERT INTO @TableTemp values(2, 'Telefone Residencial')
INSERT INTO @TableTemp values(3, 'Telefone Celular')

SELECT
	CT.Numero,
	TMP.telefone
FROM
ClienteTelefone CT
INNER JOIN @TableTemp TMP ON CT.IdTipoTelefone = TMP.idTpTelefone 


-- contagem de cadastro de clientes por ano 
-- uma forma mais tranquila para se fazer isso � atrav�s da subconsulta
-- existem duas formas de subconsulta: dentro do pr�prio select ou como tabela

-- sem subconsulta: 
SELECT
	YEAR(DataCadastro),
	COUNT(YEAR(DataCadastro)) AS Qtd
FROM Cliente
	GROUP BY YEAR(DataCadastro)

-- subconsulta como tabela: 
SELECT Tabela.Ano, COUNT(Ano) FROM 
(
SELECT
	YEAR(DataCadastro) AS Ano,
	CLI.Nome
FROM Cliente CLI
INNER JOIN Cidade CID ON CLI.IdCidade = CID.Id
INNER JOIN UnidadeFederacao UF ON CID.IdUnidadeFederacao = UF.Id
WHERE UF.Sigla = 'SP'
) AS Tabela
GROUP BY Tabela.Ano

-- outro exemplo de subselect
SELECT 
	CLI.Id,
	CLI.Nome,
	(SELECT TOP 1 Numero FROM ClienteTelefone WHERE IdTipoTelefone = 1 AND ClienteTelefone.IdCliente = CLI.Id) AS TelefoneResidencial,
	(SELECT TOP 1 Numero FROM ClienteTelefone WHERE IdTipoTelefone = 2 AND ClienteTelefone.IdCliente = CLI.Id) AS TelefoneComercial,
	(SELECT TOP 1 Numero FROM ClienteTelefone WHERE IdTipoTelefone = 3 AND ClienteTelefone.IdCliente = CLI.Id) AS TelefoneCelular
FROM CLIENTE CLI


-- VIEW: comando de dados para armazenar dados complexos
-- evita ter que ficar escrevendo o comando toda vez. Ele fica salvo
CREATE OR ALTER VIEW vw_ClientesMinasSaoPaulo
AS
SELECT 	
	CLI.Nome As NomeCliente,
	CLI.Endereco,
	CLI.Bairro,
	CID.Nome As NomeCidade,
	UF.Sigla,
	UF.Nome As Estado,	
	(SELECT TOP 1 Numero FROM ClienteTelefone WHERE IdTipoTelefone = 1 AND ClienteTelefone.IdCliente = CLI.Id) AS TelefoneResidencial,
	(SELECT TOP 1 Numero FROM ClienteTelefone WHERE IdTipoTelefone = 2 AND ClienteTelefone.IdCliente = CLI.Id) AS TelefoneComercial,
	(SELECT TOP 1 Numero FROM ClienteTelefone WHERE IdTipoTelefone = 3 AND ClienteTelefone.IdCliente = CLI.Id) AS TelefoneCelular
FROM CLIENTE CLI
INNER JOIN Cidade CID ON CLI.IdCidade = CID.Id
INNER JOIN UnidadeFederacao UF ON CID.IdUnidadeFederacao = UF.Id
WHERE (UF.Sigla = 'SP' OR UF.Sigla = 'MG')

-- consultando uma VIEW
SELECT * FROM vw_ClientesMinasSaoPaulo

-- dropando uma VIEW
DROP VIEW vw_ClientesMinasSaoPaulo


-- PROCEDURES: s�o procedimentos que executam v�rios comandos
-- eles realizam c�lculos, m�dias, alteram dados. Em geral s�o peda�os de c�digo com l�gica no banco de dados 
-- conta a quantidade de datas de cadastro n�o nulas de acordo com o estado que foi passado por par�metro

CREATE OR ALTER PROCEDURE sp_CalculoDeDatas
	@UF VARCHAR(2)
AS
DECLARE @Contador INT 
DECLARE @Data DATETIME 
SET @Contador = 0
DECLARE C CURSOR FOR
SELECT DATACADASTRO FROM Cliente C
INNER JOIN Cidade CID ON C.IdCidade = Cid.Id
INNER JOIN UnidadeFederacao UF ON Cid.IdUnidadeFederacao = UF.Id
WHERE UF.Sigla = @UF
OPEN C
FETCH NEXT FROM C INTO @Data 
WHILE @@fetch_status <> -1 
BEGIN
	IF @Data IS NOT NULL
	BEGIN
		SET @Contador = @Contador + 1
	END
	FETCH NEXT FROM C INTO @Data
END
CLOSE C
DEALLOCATE C

SELECT @Contador as Total 

GO

EXEC sp_CalculoDeDatas 'SP'

--conferindo se os valores est�o batendo, pois todas as datas n�o s�o nulas
SELECT COUNT(C.ID) FROM CLIENTE C
INNER JOIN CIDADE CD ON C.IdCidade = CD.Id
INNER JOIN UnidadeFederacao UF ON CD.IdUnidadeFederacao = UF.Id
WHERE UF.Sigla = 'SP' AND
	  C.DataCadastro IS NOT NULL


-- FUNCTIONS: s�o uma esp�cie de PROCEDURES, por�m sempre tem um retorno
-- s�o usadas geralmente para coisas mais simples
-- fun��es geralmente s�o de consulta 
-- para modificar dados deve-ser usar procedimentos
CREATE OR ALTER FUNCTION fn_GetAnoMes(@data datetime)
returns VARCHAR(20)
AS
BEGIN
	DECLARE @AnoMes VARCHAR(20)
	SET @AnoMes = LEFT(CONVERT(VARCHAR,@data,112),6)
	RETURN @AnoMes
END

-- Usando a fun��o
SELECT DataCadastro, dbo.fn_GetAnoMes(DataCadastro)AS AnoMes FROM Cliente