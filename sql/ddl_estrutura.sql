-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES - VERSÃO OFFICIAL 1.6
-- SCRIPT DDL: CRIAÇÃO DA ESTRUTURA DO BANCO DE DADOS E CONSTRAINTS
-- ATENDE REQUISITOS DE INTEGRIDADE, 1FN, 2FN, 3FN E HEUSER (2009)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS merceariaLopes;
USE merceariaLopes;

-- 1. TABELA CATEGORIA
CREATE TABLE Categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL
);

-- 2. TABELA SUBCATEGORIA (1:N com Categoria - 2FN/3FN)
CREATE TABLE Sub_Categoria (
    id_sub_categoria INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_sub_categoria VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria (id_categoria)
);

-- 3. TABELA ESTOQUE (Catálogo Geral de Preços e Saldo Agregado)
CREATE TABLE Estoque (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_sub_categoria INT NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    qtd_estoque INT NOT NULL DEFAULT 0 CHECK (qtd_estoque >= 0),
    valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario >= 0),
    FOREIGN KEY (id_sub_categoria) REFERENCES Sub_Categoria(id_sub_categoria)
);

-- 4. TABELA LOCALIDADE (Isolamento de CEP - 3FN)
CREATE TABLE Localidade (
    id_localidade INT AUTO_INCREMENT PRIMARY KEY,
    cep VARCHAR(10) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL
);

-- 5. TABELA PESSOA (Entidade Genérica - Herança Total Heuser, p. 55)
CREATE TABLE Pessoa (
    id_pessoa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    status_pessoa VARCHAR(10) NOT NULL DEFAULT 'Ativo' CHECK (status_pessoa IN ('Ativo', 'Inativo'))
);

-- 6. TABELA PESSOA FÍSICA (Especialização com Extensão de Chave - Heuser, p. 159)
CREATE TABLE Pessoa_Fisica (
    id_pessoa INT PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
);

-- 7. TABELA PESSOA JURÍDICA (Especialização - Heuser, p. 159)
CREATE TABLE Pessoa_Juridica (
    id_pessoa INT PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
);

-- 8. TABELA TELEFONE PESSOA (Atributo Multivalorado - 1FN Heuser, p. 165)
CREATE TABLE Telefone_Pessoa (
    id_pessoa INT NOT NULL,
    telefone VARCHAR(20) NOT NULL CHECK (telefone REGEXP '^[0-9]{10,11}$'),
    PRIMARY KEY (id_pessoa, telefone),
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
);

-- 9. TABELA EMAIL PESSOA (Atributo Multivalorado - 1FN)
CREATE TABLE Email_Pessoa (
    id_pessoa INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%@%.%'),
    PRIMARY KEY (id_pessoa, email),
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa)
);

-- 10. TABELA ENDEREÇO PESSOA (Cruzamento de Localidade e Morador - 3FN)
CREATE TABLE Endereco_Pessoa (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    id_localidade INT NOT NULL,
    numero VARCHAR(10) NOT NULL,
    ponto_referencia VARCHAR(150),
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa (id_pessoa),
    FOREIGN KEY (id_localidade) REFERENCES Localidade (id_localidade)
);

-- 11. TABELA CLIENTE (Papel de Pessoa Física)
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa_fisica INT NOT NULL UNIQUE,
    data_cadastro DATE NOT NULL,
    FOREIGN KEY (id_pessoa_fisica) REFERENCES Pessoa_Fisica(id_pessoa)
);

-- 12. TABELA FUNCIONÁRIO (Papel de Pessoa Física com Dados Administrativos)
CREATE TABLE Funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa_fisica INT NOT NULL UNIQUE,
    ctps VARCHAR(20) NOT NULL,
    sexo VARCHAR(15) NOT NULL,
    rg VARCHAR(15) NOT NULL,
    nome_da_mae VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_pessoa_fisica) REFERENCES Pessoa_Fisica(id_pessoa)
);

-- 13. TABELA FORNECEDOR (Papel de Pessoa Jurídica)
CREATE TABLE Fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa_juridica INT NOT NULL UNIQUE,
    razao_social VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_pessoa_juridica) REFERENCES Pessoa_Juridica(id_pessoa)
);

-- 14. TABELA FICHA DO CLIENTE (Controle Virtual do Caderno de Fiado - RN05)
CREATE TABLE Ficha_Do_Cliente (
    id_ficha_do_cliente INT AUTO_INCREMENT,
    id_cliente INT NOT NULL UNIQUE,
    limite_credito DECIMAL(10,2) NOT NULL DEFAULT 120.00 CHECK (limite_credito >= 0),
    saldo_devedor_atual DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (saldo_devedor_atual >= 0),
    data_abertura DATE NOT NULL,
    situacao_credito VARCHAR(15) NOT NULL DEFAULT 'Liberado' CHECK (situacao_credito IN ('Liberado', 'Bloqueado')),
    PRIMARY KEY (id_ficha_do_cliente, id_cliente),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente)
);

-- 15. TABELA ENTREGA (Cabeçalho Financeiro / Notas Fiscais - 2FN Contas a Pagar)
CREATE TABLE Entrega (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_fornecedor INT NOT NULL,
    num_nota_fiscal VARCHAR(30) NOT NULL,
    data_recebimento DATE NOT NULL,
    hora_recebimento TIME NOT NULL,
    valor_total_nota DECIMAL(10,2) NOT NULL CHECK (valor_total_nota >= 0),
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('Boleto bancário', 'Débito automático')),
    data_vencimento DATE NOT NULL,
    status_entrega VARCHAR(20) NOT NULL CHECK (status_entrega IN ('Aprovado', 'Com Avaria', 'Divergente')),
    status_liquidacao VARCHAR(15) NOT NULL DEFAULT 'A Pagar' CHECK (status_liquidacao IN ('A Pagar', 'Pago', 'Atrasado')),
    data_pagamento DATE NULL,
    valor_pago DECIMAL(10,2) NULL CHECK (valor_pago >= 0),
    UNIQUE (id_fornecedor, num_nota_fiscal),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor (id_fornecedor)
);

-- 16. TABELA PRODUTO (Granularidade Física por Lote / Validade - RN03/RN04)
CREATE TABLE Produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_estoque INT NOT NULL,
    id_entrega INT NOT NULL,
    lote VARCHAR(30) NOT NULL,
    qtd_total INT NOT NULL CHECK (qtd_total >= 0),
    qtd_recusada INT NOT NULL DEFAULT 0 CHECK (qtd_recusada >= 0),
    qtd_disponivel INT NOT NULL CHECK (qtd_disponivel >= 0),
    dt_entrada_estoque DATE NOT NULL,
    data_validade DATE NOT NULL,
    data_fabricacao DATE NULL,
    status_produto VARCHAR(15) NOT NULL DEFAULT 'Ativo' CHECK (status_produto IN ('Ativo', 'Inativo', 'Descartado')),
    qtd_descartada INT NULL,
    data_descarte DATE NULL,
    FOREIGN KEY (id_estoque) REFERENCES Estoque (id_estoque),
    FOREIGN KEY (id_entrega) REFERENCES Entrega (id_entrega),
    CHECK (qtd_disponivel <= qtd_total),
    CHECK (data_fabricacao IS NULL OR data_validade >= data_fabricacao)
);

-- 17. TABELA VENDA (Cabeçalho do Cupom Fiscal - Separação Estatutária do Fiado)
CREATE TABLE Venda (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    id_cliente INT NULL,
    id_ficha_do_cliente INT NULL,
    data DATE NOT NULL,
    hora TIME NOT NULL,
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('Dinheiro', 'Pix', 'Cartão de débito', 'Cartão de crédito', 'Fiado')),
    status_pagamento VARCHAR(15) NOT NULL CHECK (status_pagamento IN ('Pago', 'Pendente')),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario (id_funcionario),
    FOREIGN KEY (id_ficha_do_cliente, id_cliente) REFERENCES Ficha_Do_Cliente (id_ficha_do_cliente, id_cliente)
);

-- 18. TABELA ITENS_VENDA (Linhas do Cupom - Associação N:N Histórica)
CREATE TABLE Itens_Venda (
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario_aplicado DECIMAL(10,2) NOT NULL CHECK (preco_unitario_aplicado >= 0),
    desconto_aplicado DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (desconto_aplicado >= 0),
    valor_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_venda, id_produto),
    FOREIGN KEY (id_produto) REFERENCES Produto (id_produto),
    FOREIGN KEY (id_venda) REFERENCES Venda (id_venda)
);

-- 19. TABELA PAGAMENTO FIADO (Amortizações do Caderno Virtual - Fluxo de Caixa)
CREATE TABLE Pagamento_Fiado (
    id_quita_amortiza INT AUTO_INCREMENT PRIMARY KEY,
    id_ficha_do_cliente INT NOT NULL,
    id_cliente INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL CHECK (valor_pago > 0),
    data_pagamento DATE NOT NULL,
    FOREIGN KEY (id_ficha_do_cliente, id_cliente) REFERENCES Ficha_Do_Cliente (id_ficha_do_cliente, id_cliente)
);

-- 20. TABELA DEVOLUÇÃO OU TROCA DE CLIENTE
CREATE TABLE Devolucao_Troca (
    id_devolucao INT AUTO_INCREMENT PRIMARY KEY,
    id_venda INT NOT NULL,
    data DATE NOT NULL,
    hora TIME NOT NULL,
    valor_diferenca DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_diferenca >= 0),
    valor_credito_gerado DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_credito_gerado >= 0),
    FOREIGN KEY (id_venda) REFERENCES Venda (id_venda)
);

-- 21. TABELA ITENS DEVOLVIDOS CLIENTE (Controle de Perda vs Retorno à Gôndola)
CREATE TABLE Itens_Devolvidos (
    id_devolucao INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    tipo_movimentacao_item VARCHAR(25) NOT NULL CHECK (tipo_movimentacao_item IN ('Retorno ao Estoque', 'Descarte/Perda')),
    status_item VARCHAR(15) NOT NULL CHECK (status_item IN ('Perfeito', 'Avariado', 'Vencido')),
    PRIMARY KEY (id_devolucao, id_produto),
    FOREIGN KEY (id_devolucao) REFERENCES Devolucao_Troca (id_devolucao),
    FOREIGN KEY (id_produto) REFERENCES Produto (id_produto)
);

-- 22. TABELA UTILIZA CRÉDITO (Associação N:N - Abatimento de Créditos Futuros)
CREATE TABLE Utiliza_Credito (
    id_venda INT NOT NULL,
    id_devolucao INT NOT NULL,
    valor_utilizado DECIMAL(10,2) NOT NULL CHECK (valor_utilizado > 0),
    PRIMARY KEY (id_devolucao, id_venda),
    FOREIGN KEY (id_devolucao) REFERENCES Devolucao_Troca (id_devolucao),
FOREIGN KEY (id_venda) REFERENCES Venda (id_venda)
);
-- 23. TABELA DEVOLUÇÃO AO FORNECEDOR (Controle Jurídico de Avarias de Fábrica)
CREATE TABLE Devolucao_Fornecedor (
id_devolucao_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
data DATE NOT NULL,
hora TIME NOT NULL,
valor_estorno DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_estorno >= 0),
forma_acerto VARCHAR(30) NOT NULL CHECK (forma_acerto IN ('Estorno', 'Desconto na próxima compra', 'Substituição'))
);
-- 24. TABELA ITENS DEVOLVIDOS AO FORNECEDOR
CREATE TABLE Itens_Devolvidos_Fornecedor (
id_devolucao_fornecedor INT NOT NULL,
id_produto INT NOT NULL,
quantidade_devolvida INT NOT NULL CHECK (quantidade_devolvida > 0),
motivo_devolucao VARCHAR(100) NOT NULL,
PRIMARY KEY (id_devolucao_fornecedor, id_produto),
FOREIGN KEY (id_devolucao_fornecedor) REFERENCES Devolucao_Fornecedor (id_devolucao_fornecedor),
foreign key (id_produto) REFERENCES Produto (id_produto)
);
-- 25. TABELA FECHAMENTO DE CAIXA (Auditoria Diária Contada vs Esperada - RN13)
CREATE TABLE Fechamento_Caixa (
id_fechamento INT AUTO_INCREMENT PRIMARY KEY,
id_funcionario INT NOT NULL,
data_fechamento DATE NOT NULL UNIQUE,
saldo_inicial DECIMAL(10,2) NOT NULL,
saldo_final DECIMAL(10,2) NOT NULL,
valor_contado_caixa DECIMAL(10,2) NOT NULL,
diferenca_apurada DECIMAL(10,2) NOT NULL,
FOREIGN KEY (id_funcionario) REFERENCES Funcionario (id_funcionario)
);
