CREATE DATABASE UDF
USE UDF

CREATE TABLE funcionario(
codigo					INT				NOT NULL,
nome					VARCHAR(255)	NOT NULL,
salario					DECIMAL(7, 2)	NOT NULL
PRIMARY KEY (codigo))

CREATE TABLE dependente(
codigo_dep				INT				NOT NULL,
codigo_funcionario		INT				NOT NULL,
nome_dependente			VARCHAR(255)	NOT NULL,
salario_dependente		DECIMAL(7, 2)	NOT NULL
PRIMARY KEY (codigo_dep),
FOREIGN KEY (codigo_funcionario) REFERENCES funcionario(codigo))

INSERT INTO funcionario VALUES
(1, 'Lain Iwakura', 100),
(2, 'Etho Slab', 200),
(3, 'Aoi Mukou', 300)

INSERT INTO dependente VALUES
(1, 1, 'Alice Miyuki', 10),
(2, 2, 'Bdubs Slab', 20),
(3, 2, 'Scar Slab', 30)

-- Function que Retorne uma tabela:
-- (Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)
CREATE FUNCTION fn_ex01A()
RETURNS @tabela TABLE(
nome_funcionario	VARCHAR(255),
nome_dependente		VARCHAR(255),
salario_funcionario	DECIMAL(7, 2),
salario_dependente	DECIMAL(7, 2)
)
BEGIN
	INSERT INTO @tabela
		SELECT f.nome, d.nome_dependente, f.salario, d.salario_dependente
		FROM funcionario f JOIN dependente d ON f.codigo = d.codigo_funcionario
	RETURN
END

SELECT * FROM fn_ex01A()

-- Scalar Function que Retorne a soma dos Salários dos
-- dependentes, mais a do funcionário.
CREATE FUNCTION fn_ex01B(@cod INT)
RETURNS DECIMAL(7, 2)
AS
BEGIN
	DECLARE @soma DECIMAL(7, 2),
			@salario_func DECIMAL(7, 2),
			@salario_deps DECIMAL(7, 2)

	IF (@cod > 0)
	BEGIN
		SET @salario_func = (SELECT salario FROM funcionario WHERE codigo = @cod)
		SET @salario_deps = (SELECT SUM(salario_dependente) FROM dependente WHERE codigo_funcionario = @cod)
		SET @soma = @salario_func + @salario_deps
	END
	RETURN @soma
END

SELECT dbo.fn_ex01B(2) AS soma_salarios

CREATE TABLE produtos(
codigo			INT				NOT NULL,
nome			VARCHAR(255)	NOT NULL,
valor_unitario	DECIMAL(7, 2)	NOT NULL,
qtd_estoque		INT				NOT NULL
PRIMARY KEY(codigo)
)

INSERT INTO produtos VALUES
(1, 'Maçã', 1.00, 2),
(2, 'Pera', 2.00, 4),
(3, 'Banana', 3.00, 6),
(4, 'Morango', 4.00, 8)

-- A partir da tabela Produtos, quantos produtos
-- estão com estoque abaixo de um valor de entrada
CREATE FUNCTION fn_ex02A(@qtd INT)
RETURNS INT
AS
BEGIN
	DECLARE @cont INT
	IF (@qtd > 0)
	BEGIN
		SET @cont = (SELECT COUNT(codigo) FROM produtos WHERE qtd_estoque < @qtd)
	END
	RETURN @cont
END
SELECT dbo.fn_ex02A(5) AS qtd_produtos

-- Uma tabela com o código, o nome e a quantidade dos produtos que estão com o estoque
-- abaixo de um valor de entrada
CREATE FUNCTION fn_ex02B(@qtd INT)
RETURNS @tabela TABLE(
codigo		INT				NOT NULL,
nome		VARCHAR(255)	NOT NULL,
quantidade	INT				NOT NULL
)
BEGIN
	IF (@qtd > 0)
	BEGIN
		INSERT INTO @tabela 
		SELECT codigo, nome, qtd_estoque FROM produtos WHERE qtd_estoque < @qtd
	END
	RETURN
END
SELECT * FROM fn_ex02B(5)

CREATE TABLE cliente(
codigo		INT				NOT NULL,
nome		VARCHAR(255)	NOT NULL
PRIMARY KEY(codigo)
)

CREATE TABLE produto(
codigo		INT				NOT NULL,
nome		VARCHAR(255)	NOT NULL,
valor		DECIMAL(7, 2)	NOT NULL
PRIMARY KEY(codigo)
)

CREATE TABLE item(
codigo		INT				NOT NULL,
codigo_cli	INT				NOT NULL,
codigo_pro	INT				NOT NULL,
quantidade	INT				NOT NULL,
data_compra	DATE			NOT NULL	DEFAULT(GETDATE())
PRIMARY KEY(codigo),
FOREIGN KEY(codigo_cli) REFERENCES cliente(codigo),
FOREIGN KEY(codigo_pro)	REFERENCES produto(codigo)
)

INSERT INTO cliente VALUES
(1, 'Madoka Kaname'),
(2, 'Homura Akemi')

INSERT INTO produto VALUES
(1, 'Maçã', 1.00),
(2, 'Pera', 2.00),
(3, 'Banana', 3.00),
(4, 'Morango', 4.00)

INSERT INTO item VALUES
(1, 1, 1, 1, GETDATE()),
(2, 1, 2, 2, GETDATE()),
(3, 2, 3, 3, GETDATE())

-- Retorne Nome do Cliente, Nome do Produto, Quantidade e Valor Total
CREATE FUNCTION fn_ex03()
RETURNS @tabela TABLE(
nome_cliente		VARCHAR(255),
nome_produto		VARCHAR(255),
quantidade			INT,
valor_total			DECIMAL(7, 2),
data_compra			DATE
)
BEGIN
	INSERT INTO @tabela
		SELECT c.nome, p.nome, i.quantidade, (i.quantidade * p.valor), i.data_compra
		FROM item i 
		JOIN cliente c ON c.codigo = i.codigo_cli
		JOIN produto p ON p.codigo = i.codigo_pro
	RETURN
END

SELECT * FROM fn_ex03()