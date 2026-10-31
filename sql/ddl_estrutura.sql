-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES - VERSÃO OFFICIAL 1.6
-- SCRIPT DDL: CRIAÇÃO DA ESTRUTURA DO BANCO DE DADOS E CONSTRAINTS
-- ATENDE REQUISITOS DE INTEGRIDADE, 1FN, 2FN, 3FN E HEUSER (2009)
-- ============================================================================

 -- drop database merceariaLopes; -- Apaga o banco de dados e tudo que contém nele

CREATE DATABASE IF NOT EXISTS merceariaLopes;

USE merceariaLopes;

-- 1. TABELA CATEGORIA
CREATE TABLE IF NOT EXISTS  Categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL
);

-- 2. TABELA SUBCATEGORIA (1:N com Categoria - 2FN/3FN)
CREATE TABLE IF NOT EXISTS  Sub_Categoria (
    id_sub_categoria INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_sub_categoria VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria (id_categoria)
);

-- 3. TABELA ESTOQUE (Catálogo Geral de Preços e Saldo Agregado)
CREATE TABLE IF NOT EXISTS  Estoque (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_sub_categoria INT NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    qtd_estoque INT NOT NULL DEFAULT 0 CHECK (qtd_estoque >= 0),
    valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario >= 0),
    FOREIGN KEY (id_sub_categoria) REFERENCES Sub_Categoria(id_sub_categoria)
);

-- 4. TABELA LOCALIDADE (Isolamento de CEP - 3FN)
CREATE TABLE IF NOT EXISTS  Localidade (
    id_localidade INT AUTO_INCREMENT PRIMARY KEY,
    cep VARCHAR(10) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL
);

-- 5. TABELA PESSOA (Texto do CHECK alterado para maiúsculas)
CREATE TABLE IF NOT EXISTS  Pessoa (
    id_pessoa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    status_pessoa VARCHAR(10) NOT NULL DEFAULT 'ATIVO' CHECK (status_pessoa IN ('ATIVO', 'INATIVO'))
);

-- 6. TABELA PESSOA FÍSICA (Especialização com Extensão de Chave - Heuser, p. 159)
CREATE TABLE IF NOT EXISTS  Pessoa_Fisica (
    id_pessoa INT PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
);

-- 7. TABELA PESSOA JURÍDICA (Especialização - Heuser, p. 159)
CREATE TABLE IF NOT EXISTS  Pessoa_Juridica (
    id_pessoa INT PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
);

-- 8. TABELA TELEFONE PESSOA (Atributo Multivalorado - 1FN Heuser, p. 165)
CREATE TABLE IF NOT EXISTS  Telefone_Pessoa (
    id_pessoa INT NOT NULL,
    telefone VARCHAR(20) NOT NULL CHECK (telefone REGEXP '^[0-9]{10,11}$'),
    PRIMARY KEY (id_pessoa, telefone),
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
);

-- 9. TABELA EMAIL PESSOA (Atributo Multivalorado - 1FN com Validação REGEXP Real)
CREATE TABLE IF NOT EXISTS  Email_Pessoa (
    id_pessoa INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    PRIMARY KEY (id_pessoa, email),
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
    -- • ^[A-Za-z0-9._%+-]+: Garante que o início tenha apenas letras, números e símbolos permitidos antes do arroba.
	-- • @: Exige exatamente um arroba no meio.
	-- • [A-Za-z0-9.-]+: Exige o nome do domínio (ex: gmail, hotmail).
	-- • \\.: Exige obrigatoriamente um ponto final real após o domínio.
	-- • [A-Za-z]{2,}$: Garante que a extensão final (ex: com, br, edu) tenha no mínimo duas letras e nenhum caractere inválido.
);


-- 10. TABELA ENDEREÇO PESSOA (Cruzamento de Localidade e Morador - 3FN)
CREATE TABLE IF NOT EXISTS  Endereco_Pessoa (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    id_localidade INT NOT NULL,
    numero VARCHAR(10) NOT NULL,
    ponto_referencia VARCHAR(150),
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa),
    FOREIGN KEY (id_localidade) REFERENCES Localidade (id_localidade)
);

-- 11. TABELA CLIENTE (Papel de Pessoa Física)
CREATE TABLE IF NOT EXISTS  Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa_fisica INT NOT NULL UNIQUE,
    -- Altere o campo data_cadastro para pegar a data atual automaticamente
    data_cadastro DATE NOT NULL DEFAULT (CURDATE()),
    FOREIGN KEY (id_pessoa_fisica) REFERENCES Pessoa_Fisica(id_pessoa)
);

-- 12. TABELA FUNCIONÁRIO (Papel de Pessoa Física com Dados Administrativos)
CREATE TABLE IF NOT EXISTS  Funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa_fisica INT NOT NULL UNIQUE,
    ctps VARCHAR(20) NOT NULL,
    sexo VARCHAR(15) NOT NULL,
    rg VARCHAR(15) NOT NULL,
    nome_da_mae VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_pessoa_fisica) REFERENCES Pessoa_Fisica(id_pessoa)
);

-- 13. TABELA FORNECEDOR (Papel de Pessoa Jurídica)
CREATE TABLE IF NOT EXISTS  Fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa_juridica INT NOT NULL UNIQUE,
    razao_social VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_pessoa_juridica) REFERENCES Pessoa_Juridica(id_pessoa)
);


-- 14. TABELA FICHA DO CLIENTE (Texto do CHECK alterado para maiúsculas)
CREATE TABLE IF NOT EXISTS  Ficha_Do_Cliente (
    id_ficha_do_cliente INT AUTO_INCREMENT,
    id_cliente INT NOT NULL UNIQUE,
    limite_credito DECIMAL(10,2) NOT NULL DEFAULT 120.00 CHECK (limite_credito >= 0),
    saldo_devedor_atual DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (saldo_devedor_atual >= 0),
    -- Altere o campo data_abertura para pegar a data atual automaticamente
    data_abertura DATE NOT NULL DEFAULT (CURDATE()),
    situacao_credito VARCHAR(15) NOT NULL DEFAULT 'LIBERADO' CHECK (situacao_credito IN ('LIBERADO', 'BLOQUEADO')),
    PRIMARY KEY (id_ficha_do_cliente, id_cliente),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente)
);

-- 15. TABELA ENTREGA (Textos dos CHECKs alterados para maiúsculas)
CREATE TABLE IF NOT EXISTS  Entrega (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_fornecedor INT NOT NULL,
    num_nota_fiscal VARCHAR(30) NOT NULL,
    -- Quando a nota for registrada, grava o momento exato do recebimento
    data_recebimento DATE NOT NULL DEFAULT (CURDATE()),
	hora_recebimento TIME NOT NULL DEFAULT (CURTIME()),
    valor_total_nota DECIMAL(10,2) NOT NULL CHECK (valor_total_nota >= 0),
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('BOLETO BANCÁRIO', 'DÉBITO AUTOMÁTICO')),
    data_vencimento DATE NOT NULL, CHECK ( data_vencimento >= data_recebimento AND 
    (data_pagamento IS NULL OR data_pagamento >= data_recebimento)),
    status_entrega VARCHAR(20) NOT NULL CHECK (status_entrega IN ('APROVADO', 'COM AVARIA', 'DIVERGENTE')),
    status_liquidacao VARCHAR(15) NOT NULL DEFAULT 'A PAGAR' CHECK (status_liquidacao IN ('A PAGAR', 'PAGO', 'ATRASADO')),
    data_pagamento DATE NULL,
    valor_pago DECIMAL(10,2) NULL CHECK (valor_pago >= 0),
    UNIQUE (id_fornecedor, num_nota_fiscal),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor (id_fornecedor)
);


-- 16. TABELA PRODUTO (Texto do CHECK alterado para maiúsculas)
CREATE TABLE IF NOT EXISTS Produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_estoque INT NOT NULL,
    id_entrega INT NOT NULL,
    lote VARCHAR(30) NOT NULL,
    qtd_total INT NOT NULL CHECK (qtd_total >= 0),
    qtd_recusada INT NOT NULL DEFAULT 0 CHECK (qtd_recusada >= 0),
    qtd_disponivel INT NOT NULL CHECK (qtd_disponivel >= 0),
    dt_entrada_estoque DATE NOT NULL  DEFAULT (CURDATE()),
    data_validade DATE NOT NULL,
    data_fabricacao DATE NULL,
    status_produto VARCHAR(15) NOT NULL DEFAULT 'ATIVO' CHECK (status_produto IN ('ATIVO', 'INATIVO', 'DESCARTADO')),
    qtd_descartada INT NULL,
    data_descarte DATE NULL  DEFAULT (CURDATE()),
    FOREIGN KEY (id_estoque) REFERENCES Estoque (id_estoque),
    FOREIGN KEY (id_entrega) REFERENCES Entrega (id_entrega),
    CHECK (qtd_disponivel <= qtd_total),
    CHECK (data_fabricacao IS NULL OR data_validade >= data_fabricacao)
);

-- 17. TABELA VENDA (Textos dos CHECKs alterados para maiúsculas)
CREATE TABLE IF NOT EXISTS  Venda (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    id_cliente INT NULL,
    id_ficha_do_cliente INT NULL,
    data DATE NOT NULL  DEFAULT (CURDATE()),
    hora TIME NOT NULL  DEFAULT (CURTIME()),
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('DINHEIRO', 'PIX', 'CARTÃO DE DÉBITO', 'CARTÃO DE CRÉDITO', 'FIADO')),
    status_pagamento VARCHAR(15) NOT NULL CHECK (status_pagamento IN ('PAGO', 'PENDENTE')),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario (id_funcionario),
    FOREIGN KEY (id_ficha_do_cliente, id_cliente) REFERENCES Ficha_Do_Cliente (id_ficha_do_cliente, id_cliente)
);

-- 18. TABELA ITENS_VENDA (Linhas do Cupom - Associação N:N Histórica)
CREATE TABLE IF NOT EXISTS  Itens_Venda (
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario_aplicado DECIMAL(10,2) NOT NULL CHECK (preco_unitario_aplicado >= 0),
    desconto_aplicado DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (desconto_aplicado >= 0),
    valor_total DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (id_venda, id_produto),
    FOREIGN KEY (id_produto) REFERENCES Produto (id_produto),
    FOREIGN KEY (id_venda) REFERENCES Venda (id_venda),
    
    -- TRAVA NO NÍVEL DA TABELA: Agora o MySQL aceita ler todas as colunas perfeitamente!
    CONSTRAINT chk_calculo_venda_integro CHECK (valor_total = (quantidade * preco_unitario_aplicado) - desconto_aplicado)
);

-- 19. TABELA PAGAMENTO FIADO (Amortizações do Caderno Virtual - Fluxo de Caixa)
CREATE TABLE IF NOT EXISTS Pagamento_Fiado (
    id_quita_amortiza INT AUTO_INCREMENT PRIMARY KEY,
    id_ficha_do_cliente INT NOT NULL,
    id_cliente INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL CHECK (valor_pago > 0),
    data_pagamento DATE NOT NULL  DEFAULT (CURDATE()),
    FOREIGN KEY (id_ficha_do_cliente, id_cliente) REFERENCES Ficha_Do_Cliente (id_ficha_do_cliente, id_cliente)
);

-- 20. TABELA DEVOLUÇÃO OU TROCA DE CLIENTE
CREATE TABLE IF NOT EXISTS  Devolucao_Troca (
    id_devolucao INT AUTO_INCREMENT PRIMARY KEY,
    id_venda INT NOT NULL,
    data DATE NOT NULL DEFAULT (CURDATE()),
	hora TIME NOT NULL DEFAULT (CURTIME()),
    valor_diferenca DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_diferenca >= 0),
    valor_credito_gerado DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_credito_gerado >= 0),
    FOREIGN KEY (id_venda) REFERENCES Venda (id_venda)
);

-- 21. TABELA ITENS DEVOLVIDOS CLIENTE (Textos dos CHECKs alterados para maiúsculas)
CREATE TABLE IF NOT EXISTS  Itens_Devolvidos (
    id_devolucao INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    tipo_movimentacao_item VARCHAR(25) NOT NULL CHECK (tipo_movimentacao_item IN ('RETORNO AO ESTOQUE', 'DESCARTE/PERDA')),
    status_item VARCHAR(15) NOT NULL CHECK (status_item IN ('PERFEITO', 'AVARIADO', 'VENCIDO')),
    PRIMARY KEY (id_devolucao, id_produto),
    FOREIGN KEY (id_devolucao) REFERENCES Devolucao_Troca (id_devolucao),
    FOREIGN KEY (id_produto) REFERENCES Produto (id_produto)
);

-- 22. TABELA UTILIZA CRÉDITO (Associação N:N - Abatimento de Créditos Futuros)
CREATE TABLE IF NOT EXISTS  Utiliza_Credito (
    id_venda INT NOT NULL,
    id_devolucao INT NOT NULL,
    valor_utilizado DECIMAL(10,2) NOT NULL CHECK (valor_utilizado > 0),
    PRIMARY KEY (id_devolucao, id_venda),
    FOREIGN KEY (id_devolucao) REFERENCES Devolucao_Troca (id_devolucao),
    FOREIGN KEY (id_venda) REFERENCES Venda (id_venda)
);

-- 23. TABELA DEVOLUÇÃO AO FORNECEDOR (Texto do CHECK alterado para maiúsculas)
CREATE TABLE IF NOT EXISTS  Devolucao_Fornecedor (
    id_devolucao_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    data DATE NOT NULL DEFAULT (CURDATE()),
	hora TIME NOT NULL DEFAULT (CURTIME()),
    valor_estorno DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_estorno >= 0),
    forma_acerto VARCHAR(30) NOT NULL CHECK (forma_acerto IN ('ESTORNO', 'DESCONTO NA PRÓXIMA COMPRA', 'SUBSTITUIÇÃO'))
);
-- 24. TABELA ITENS DEVOLVIDOS AO FORNECEDOR
CREATE TABLE IF NOT EXISTS  Itens_Devolvidos_Fornecedor (
id_devolucao_fornecedor INT NOT NULL,
id_produto INT NOT NULL,
quantidade_devolvida INT NOT NULL CHECK (quantidade_devolvida > 0),
motivo_devolucao VARCHAR(100) NOT NULL,
PRIMARY KEY (id_devolucao_fornecedor, id_produto),
FOREIGN KEY (id_devolucao_fornecedor) REFERENCES Devolucao_Fornecedor (id_devolucao_fornecedor),
FOREIGN KEY (id_produto) REFERENCES Produto (id_produto)
);
-- 25. TABELA FECHAMENTO DE CAIXA (Auditoria Diária Contada vs Esperada - RN13)
CREATE TABLE IF NOT EXISTS  Fechamento_Caixa (
id_fechamento INT AUTO_INCREMENT PRIMARY KEY,
id_funcionario INT NOT NULL,
data_fechamento DATE NOT NULL UNIQUE DEFAULT (CURDATE()),
saldo_inicial DECIMAL(10,2) NOT NULL,
saldo_final DECIMAL(10,2) NOT NULL,
valor_contado_caixa DECIMAL(10,2) NOT NULL,
diferenca_apurada DECIMAL(10,2) NOT NULL,
FOREIGN KEY (id_funcionario) REFERENCES Funcionario (id_funcionario)
);
-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES
-- COMPONENTE DA ARQUITETURA: STORED FUNCTION (FUNÇÃO ARMAZENADA)
-- OBJETIVO: HIGIENIZAÇÃO, SANITIZAÇÃO E PADRONIZAÇÃO DE STRINGS
-- REGRA ACADÊMICA: ASSEGURAR A INTEGRIDADE DE DADOS NA TABELA ASCII PURA
-- ============================================================================
--
-- DESCRIÇÃO DE FUNCIONAMENTO:
-- Esta função intercepta qualquer string enviada pelo sistema ou inserida 
-- manualmente, aplicando três camadas consecutivas de tratamento:
--
-- 1ª CAMADA (CAIXA ALTA): Transforma todos os caracteres alfabéticos para 
--    maiúsculos utilizando a função nativa UPPER().
-- 2ª CAMADA (DESACENTUAÇÃO): Subsitui caracteres acentuados complexos da 
--    codificação UTF-8 por seus equivalentes sem acento na tabela ASCII básica.
-- 3ª CAMADA (PONTUAÇÃO): Remove caracteres de pontuação e delimitadores 
--    comuns (pontos, vírgulas, traços e barras) inseridos acidentalmente.
--
-- VANTAGENS ARQUITETURAIS:
-- * Evita registros duplicados gerados por divergência de acentuação (ex: JOSE / JOSÉ).
-- * Otimiza a indexação e a performance de buscas (Queries) no servidor.
-- * Desonera a camada de aplicação (software) da responsabilidade de limpeza.
-- ============================================================================

USE merceariaLopes;

DELIMITER $$

 -- DROP FUNCTION IF EXISTS fn_higienizar_texto; -- Apaga função para corrigir erro na memória

CREATE FUNCTION fn_higienizar_texto(texto VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE texto_limpo VARCHAR(255);
    
    -- ------------------------------------------------------------------------
    -- PASSO 1: PADRONIZAÇÃO EM CAIXA ALTA
    -- ------------------------------------------------------------------------
    SET texto_limpo = UPPER(texto);
    
    -- ------------------------------------------------------------------------
    -- PASSO 2: MAPEAMENTO E SUBSTITUIÇÃO DE CARACTERES ACENTUADOS E ESPECIAIS
    -- ------------------------------------------------------------------------
    SET texto_limpo = REPLACE(texto_limpo, 'Á', 'A');
    SET texto_limpo = REPLACE(texto_limpo, 'À', 'A');
    SET texto_limpo = REPLACE(texto_limpo, 'Â', 'A');
    SET texto_limpo = REPLACE(texto_limpo, 'Ã', 'A');
    SET texto_limpo = REPLACE(texto_limpo, 'É', 'E');
    SET texto_limpo = REPLACE(texto_limpo, 'È', 'E');
    SET texto_limpo = REPLACE(texto_limpo, 'Ê', 'E');
    SET texto_limpo = REPLACE(texto_limpo, 'Í', 'I');
    SET texto_limpo = REPLACE(texto_limpo, 'Ì', 'I');
    SET texto_limpo = REPLACE(texto_limpo, 'Ó', 'O');
    SET texto_limpo = REPLACE(texto_limpo, 'Ò', 'O');
    SET texto_limpo = REPLACE(texto_limpo, 'Ô', 'O');
    SET texto_limpo = REPLACE(texto_limpo, 'Õ', 'O');
    SET texto_limpo = REPLACE(texto_limpo, 'Ú', 'U');
    SET texto_limpo = REPLACE(texto_limpo, 'Ù', 'U');
    SET texto_limpo = REPLACE(texto_limpo, 'Û', 'U');
    SET texto_limpo = REPLACE(texto_limpo, 'Ç', 'C');
    
    -- ------------------------------------------------------------------------
    -- PASSO 3: REMOÇÃO DE PONTUAÇÕES IMPLÍCITAS (HIGIENIZAÇÃO DE MÁSCARAS)
    -- ------------------------------------------------------------------------
    SET texto_limpo = REPLACE(texto_limpo, '.', ''); 
    SET texto_limpo = REPLACE(texto_limpo, ',', '');
    SET texto_limpo = REPLACE(texto_limpo, '-', '');
    -- SET texto_limpo = REPLACE(texto_limpo, '/', '');
    
    -- RETORNO DA STRING TRATADA E HIGIENIZADA
    RETURN texto_limpo;
END$$

DELIMITER ;

-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES - AUTOMAÇÃO DE HIGIENIZAÇÃO (TRIGGERS)
-- APLICADO DIRETAMENTE SOBRE OS CAMPOS ALFANUMÉRICOS DO MODELO OFFICIAL 1.6
-- ============================================================================

DELIMITER $$

USE merceariaLopes;

DELIMITER $$

-- ============================================================================
-- TRIGGERS DE HIGIENIZAÇÃO: ACEITA COM OU SEM MÁSCARA (CPF)
-- ============================================================================
-- DROP TRIGGER IF EXISTS tg_audita_cpf_insert$$
CREATE TRIGGER tg_audita_cpf_insert BEFORE INSERT ON Pessoa_Fisica
FOR EACH ROW
BEGIN
    -- Remove tudo o que não for número (pontos, traços, espaços, letras)
    SET NEW.cpf = REGEXP_REPLACE(NEW.cpf, '[^0-9]', '');
    
    -- Valida se, após a limpeza, o documento possui os 11 dígitos obrigatórios
    IF LENGTH(NEW.cpf) <> 11 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O CPF deve conter exatamente 11 dígitos numéricos.';
    END IF;
END$$

-- DROP TRIGGER IF EXISTS tg_audita_cpf_update$$
CREATE TRIGGER tg_audita_cpf_update BEFORE UPDATE ON Pessoa_Fisica
FOR EACH ROW
BEGIN
    SET NEW.cpf = REGEXP_REPLACE(NEW.cpf, '[^0-9]', '');
    
    IF LENGTH(NEW.cpf) <> 11 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O CPF atualizado deve conter exatamente 11 dígitos numéricos.';
    END IF;
END$$

-- ============================================================================
-- TRIGGERS DE HIGIENIZAÇÃO: ACEITA COM OU SEM MÁSCARA (CNPJ)
-- ============================================================================
-- DROP TRIGGER IF EXISTS tg_audita_cnpj_insert$$
CREATE TRIGGER tg_audita_cnpj_insert BEFORE INSERT ON Pessoa_Juridica
FOR EACH ROW
BEGIN
    -- Remove tudo o que não for número (pontos, traços, barras, espaços, letras)
    SET NEW.cnpj = REGEXP_REPLACE(NEW.cnpj, '[^0-9]', '');
    
    -- Valida se, após a limpeza, o documento possui os 14 dígitos obrigatórios
    IF LENGTH(NEW.cnpj) <> 14 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O CNPJ deve conter exatamente 14 dígitos numéricos.';
    END IF;
END$$

-- DROP TRIGGER IF EXISTS tg_audita_cnpj_update$$
CREATE TRIGGER tg_audita_cnpj_update BEFORE UPDATE ON Pessoa_Juridica
FOR EACH ROW
BEGIN
    SET NEW.cnpj = REGEXP_REPLACE(NEW.cnpj, '[^0-9]', '');
    
    IF LENGTH(NEW.cnpj) <> 14 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O CNPJ atualizado deve conter exatamente 14 dígitos numéricos.';
    END IF;
END$$

DELIMITER ;
DELIMITER $$
-- 1. CATEGORIA
CREATE TRIGGER tg_categoria_insert BEFORE INSERT ON Categoria FOR EACH ROW 
BEGIN SET NEW.nome_categoria = fn_higienizar_texto(NEW.nome_categoria); END$$
CREATE TRIGGER tg_categoria_update BEFORE UPDATE ON Categoria FOR EACH ROW 
BEGIN SET NEW.nome_categoria = fn_higienizar_texto(NEW.nome_categoria); END$$

-- 2. SUBCATEGORIA
CREATE TRIGGER tg_subcategoria_insert BEFORE INSERT ON Sub_Categoria FOR EACH ROW 
BEGIN SET NEW.nome_sub_categoria = fn_higienizar_texto(NEW.nome_sub_categoria); END$$
CREATE TRIGGER tg_subcategoria_update BEFORE UPDATE ON Sub_Categoria FOR EACH ROW 
BEGIN SET NEW.nome_sub_categoria = fn_higienizar_texto(NEW.nome_sub_categoria); END$$

-- 3. ESTOQUE
CREATE TRIGGER tg_estoque_insert BEFORE INSERT ON Estoque FOR EACH ROW 
BEGIN SET NEW.descricao = fn_higienizar_texto(NEW.descricao); END$$
CREATE TRIGGER tg_estoque_update BEFORE UPDATE ON Estoque FOR EACH ROW 
BEGIN SET NEW.descricao = fn_higienizar_texto(NEW.descricao); END$$

-- 4. LOCALIDADE
CREATE TRIGGER tg_localidade_insert BEFORE INSERT ON Localidade FOR EACH ROW 
BEGIN 
    SET NEW.logradouro = fn_higienizar_texto(NEW.logradouro); 
    SET NEW.bairro = fn_higienizar_texto(NEW.bairro); 
    SET NEW.cidade = fn_higienizar_texto(NEW.cidade); 
    SET NEW.estado = fn_higienizar_texto(NEW.estado); 
END$$
CREATE TRIGGER tg_localidade_update BEFORE UPDATE ON Localidade FOR EACH ROW 
BEGIN 
    SET NEW.logradouro = fn_higienizar_texto(NEW.logradouro); 
    SET NEW.bairro = fn_higienizar_texto(NEW.bairro); 
    SET NEW.cidade = fn_higienizar_texto(NEW.cidade); 
    SET NEW.estado = fn_higienizar_texto(NEW.estado); 
END$$

-- 5. PESSOA
CREATE TRIGGER tg_pessoa_insert BEFORE INSERT ON Pessoa FOR EACH ROW 
BEGIN 
    SET NEW.nome = fn_higienizar_texto(NEW.nome); 
    SET NEW.status_pessoa = fn_higienizar_texto(NEW.status_pessoa); 
END$$
CREATE TRIGGER tg_pessoa_update BEFORE UPDATE ON Pessoa FOR EACH ROW 
BEGIN 
    SET NEW.nome = fn_higienizar_texto(NEW.nome); 
    SET NEW.status_pessoa = fn_higienizar_texto(NEW.status_pessoa); 
END$$

-- 10. ENDEREÇO PESSOA
CREATE TRIGGER tg_endereco_insert BEFORE INSERT ON Endereco_Pessoa FOR EACH ROW 
BEGIN SET NEW.ponto_referencia = fn_higienizar_texto(NEW.ponto_referencia); END$$
CREATE TRIGGER tg_endereco_update BEFORE UPDATE ON Endereco_Pessoa FOR EACH ROW 
BEGIN SET NEW.ponto_referencia = fn_higienizar_texto(NEW.ponto_referencia); END$$

-- 12. FUNCIONÁRIO
CREATE TRIGGER tg_funcionario_insert BEFORE INSERT ON Funcionario FOR EACH ROW 
BEGIN 
    SET NEW.ctps = fn_higienizar_texto(NEW.ctps); 
    SET NEW.sexo = fn_higienizar_texto(NEW.sexo); 
    SET NEW.rg = fn_higienizar_texto(NEW.rg); 
    SET NEW.nome_da_mae = fn_higienizar_texto(NEW.nome_da_mae); 
END$$
CREATE TRIGGER tg_funcionario_update BEFORE UPDATE ON Funcionario FOR EACH ROW 
BEGIN 
    SET NEW.ctps = fn_higienizar_texto(NEW.ctps); 
    SET NEW.sexo = fn_higienizar_texto(NEW.sexo); 
    SET NEW.rg = fn_higienizar_texto(NEW.rg); 
    SET NEW.nome_da_mae = fn_higienizar_texto(NEW.nome_da_mae); 
END$$
CREATE TRIGGER tg_impede_funcionario_duplicado BEFORE INSERT ON Funcionario
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Funcionario WHERE id_pessoa_fisica = NEW.id_pessoa_fisica) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aviso: Este funcionario ja esta cadastrado no sistema.';
    END IF;
END$$

-- 13. FORNECEDOR
CREATE TRIGGER tg_fornecedor_insert BEFORE INSERT ON Fornecedor FOR EACH ROW 
BEGIN 
    SET NEW.razao_social = fn_higienizar_texto(NEW.razao_social); 
END$$

CREATE TRIGGER tg_fornecedor_update BEFORE UPDATE ON Fornecedor FOR EACH ROW 
BEGIN 
    SET NEW.razao_social = fn_higienizar_texto(NEW.razao_social); 
END$$

-- ============================================================================
-- VALIDAÇÕES EXCLUSIVAS DA TABELA FORNECEDOR (HERANÇA E DUPLICIDADE)
-- ============================================================================

-- TRIGGER 1: Valida a herança (se é Pessoa Jurídica de fato)
CREATE TRIGGER tg_valida_fornecedor_heranca BEFORE INSERT ON Fornecedor
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Pessoa_Juridica WHERE id_pessoa = NEW.id_pessoa_juridica) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Aviso: Nao encontramos o CNPJ desta empresa. Para cadastrar um fornecedor, escolha uma empresa com CNPJ valido.';
    END IF;
END$$

-- TRIGGER 2: Impede cadastrar o mesmo fornecedor duas vezes
CREATE TRIGGER tg_impede_fornecedor_duplicado BEFORE INSERT ON Fornecedor
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Fornecedor WHERE id_pessoa_juridica = NEW.id_pessoa_juridica) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aviso: Este fornecedor ja esta cadastrado no sistema.';
    END IF;
END$$

-- ============================================================================
-- 14. FICHA DO CLIENTE
-- ============================================================================
CREATE TRIGGER tg_ficha_insert BEFORE INSERT ON Ficha_Do_Cliente FOR EACH ROW 
BEGIN
    SET NEW.situacao_credito = fn_higienizar_texto(NEW.situacao_credito);
END$$


CREATE TRIGGER tg_ficha_update BEFORE UPDATE ON Ficha_Do_Cliente FOR EACH ROW 
BEGIN
    SET NEW.situacao_credito = fn_higienizar_texto(NEW.situacao_credito);
END$$

-- ============================================================================
-- 15. ENTREGA
-- ============================================================================

CREATE TRIGGER tg_entrega_insert BEFORE INSERT ON Entrega FOR EACH ROW 
BEGIN 
    SET NEW.num_nota_fiscal   = fn_higienizar_texto(NEW.num_nota_fiscal); 
    SET NEW.forma_pagamento   = fn_higienizar_texto(NEW.forma_pagamento); 
    SET NEW.status_entrega    = fn_higienizar_texto(NEW.status_entrega); 
    SET NEW.status_liquidacao = fn_higienizar_texto(NEW.status_liquidacao); 
END$$



CREATE TRIGGER tg_entrega_update BEFORE UPDATE ON Entrega FOR EACH ROW 
BEGIN 
    SET NEW.num_nota_fiscal   = fn_higienizar_texto(NEW.num_nota_fiscal); 
    SET NEW.forma_pagamento   = fn_higienizar_texto(NEW.forma_pagamento); 
    SET NEW.status_entrega    = fn_higienizar_texto(NEW.status_entrega); 
    SET NEW.status_liquidacao = fn_higienizar_texto(NEW.status_liquidacao); 
END$$



-- 16. PRODUTO
CREATE TRIGGER tg_produto_insert BEFORE INSERT ON Produto FOR EACH ROW 
BEGIN 
    SET NEW.lote = fn_higienizar_texto(NEW.lote); 
    SET NEW.status_produto = fn_higienizar_texto(NEW.status_produto); 
END$$
CREATE TRIGGER tg_produto_update BEFORE UPDATE ON Produto FOR EACH ROW 
BEGIN 
    SET NEW.lote = fn_higienizar_texto(NEW.lote); 
    SET NEW.status_produto = fn_higienizar_texto(NEW.status_produto); 
END$$

-- 17. VENDA
CREATE TRIGGER tg_venda_insert BEFORE INSERT ON Venda FOR EACH ROW 
BEGIN 
    SET NEW.forma_pagamento = fn_higienizar_texto(NEW.forma_pagamento); 
    SET NEW.status_pagamento = fn_higienizar_texto(NEW.status_pagamento); 
END$$
CREATE TRIGGER tg_venda_update BEFORE UPDATE ON Venda FOR EACH ROW 
BEGIN 
    SET NEW.forma_pagamento = fn_higienizar_texto(NEW.forma_pagamento); 
    SET NEW.status_pagamento = fn_higienizar_texto(NEW.status_pagamento); 
END$$
CREATE TRIGGER tg_valida_venda_fiado BEFORE INSERT ON Venda
FOR EACH ROW
BEGIN
    -- Se a forma de pagamento for FIADO, o cliente e a ficha são obrigatórios
    IF NEW.forma_pagamento = 'FIADO' AND (NEW.id_cliente IS NULL OR NEW.id_ficha_do_cliente IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aviso: Para vender no FIADO, e obrigatorio escolher um cliente com cadastro ou criar um cadastro antes da venda.';
    END IF;
END$$

-- 21. ITENS DEVOLVIDOS CLIENTE
CREATE TRIGGER tg_itens_devolvidos_insert BEFORE INSERT ON Itens_Devolvidos FOR EACH ROW 
BEGIN 
    SET NEW.tipo_movimentacao_item = fn_higienizar_texto(NEW.tipo_movimentacao_item); 
    SET NEW.status_item = fn_higienizar_texto(NEW.status_item); 
END$$
CREATE TRIGGER tg_itens_devolvidos_update BEFORE UPDATE ON Itens_Devolvidos FOR EACH ROW 
BEGIN 
    SET NEW.tipo_movimentacao_item = fn_higienizar_texto(NEW.tipo_movimentacao_item); 
    SET NEW.status_item = fn_higienizar_texto(NEW.status_item); 
END$$

-- 23. DEVOLUÇÃO AO FORNECEDOR
CREATE TRIGGER tg_dev_fornecedor_insert BEFORE INSERT ON Devolucao_Fornecedor FOR EACH ROW 
BEGIN SET NEW.forma_acerto = fn_higienizar_texto(NEW.forma_acerto); END$$
CREATE TRIGGER tg_dev_fornecedor_update BEFORE UPDATE ON Devolucao_Fornecedor FOR EACH ROW 
BEGIN SET NEW.forma_acerto = fn_higienizar_texto(NEW.forma_acerto); END$$

-- 24. ITENS DEVOLVIDOS AO FORNECEDOR
CREATE TRIGGER tg_itens_dev_fornecedor_insert BEFORE INSERT ON Itens_Devolvidos_Fornecedor FOR EACH ROW 
BEGIN SET NEW.motivo_devolucao = fn_higienizar_texto(NEW.motivo_devolucao); END$$
CREATE TRIGGER tg_itens_dev_fornecedor_update BEFORE UPDATE ON Itens_Devolvidos_Fornecedor FOR EACH ROW 
BEGIN SET NEW.motivo_devolucao = fn_higienizar_texto(NEW.motivo_devolucao); END$$

-- ============================================================================
-- COMPLEMENTO DE TRIGGERS: HIGIENIZAÇÃO DO CAMPO NÚMERO RESIDENCIAL
-- ============================================================================
CREATE TRIGGER tg_endereco_pessoa_num_insert BEFORE INSERT ON Endereco_Pessoa FOR EACH ROW 
BEGIN SET NEW.numero = fn_higienizar_texto(NEW.numero); END$$

CREATE TRIGGER tg_endereco_pessoa_num_update BEFORE UPDATE ON Endereco_Pessoa FOR EACH ROW 
BEGIN SET NEW.numero = fn_higienizar_texto(NEW.numero); END$$

DELIMITER ;














