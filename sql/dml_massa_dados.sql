-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES - VERSÃO OFFICIAL 1.6
-- SCRIPT DML: POPULAÇÃO HISTÓRICA COMPLETA E VALIDAÇÃO DE CENÁRIOS
-- BLINDADO CONTRA ERRO 1452 ATRAVÉS DE TRAVAS DE SESSÃO RELACIONAIS
-- ============================================================================

USE merceariaLopes;

-- DESATIVAR CONSTRAINTS TEMPORARIAMENTE PARA LIMPEZA E CARGA SEGURA DO ZERO
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Utiliza_Credito;
TRUNCATE TABLE Itens_Devolvidos_Fornecedor;
TRUNCATE TABLE Devolucao_Fornecedor;
TRUNCATE TABLE Itens_Devolvidos;
TRUNCATE TABLE Devolucao_Troca;
TRUNCATE TABLE Itens_Venda;
TRUNCATE TABLE Venda;
TRUNCATE TABLE Produto;
TRUNCATE TABLE Entrega;
TRUNCATE TABLE Pagamento_Fiado;
TRUNCATE TABLE Ficha_Do_Cliente;
TRUNCATE TABLE Cliente;
TRUNCATE TABLE Funcionario;
TRUNCATE TABLE Fornecedor;
TRUNCATE TABLE Estoque;
TRUNCATE TABLE Sub_Categoria;
TRUNCATE TABLE Categoria;
TRUNCATE TABLE Endereco_Pessoa;
TRUNCATE TABLE Email_Pessoa;
TRUNCATE TABLE Telefone_Pessoa;
TRUNCATE TABLE Pessoa_Juridica;
TRUNCATE TABLE Pessoa_Fisica;
TRUNCATE TABLE Fechamento_Caixa;
TRUNCATE TABLE Localidade;
TRUNCATE TABLE Pessoa;

-- REATIVAR VERIFICAÇÃO PARA GARANTIR QUE A CARGA RESPEITE AS REGRAS DA APLICACAO
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 1. CADASTROS DE INFRAESTRUTURA COMERCIAL, GEOGRÁFICA E CATÁLOGOS
-- ============================================================================

INSERT INTO Categoria (id_categoria, nome_categoria) VALUES 
(1, 'Alimentos Básicos'),
(2, 'Bebidas'),
(3, 'Hortifrúti');

INSERT INTO Sub_Categoria (id_sub_categoria, id_categoria, nome_sub_categoria) VALUES 
(1, 1, 'Laticínios'),
(2, 1, 'Mercearia Seca'),
(3, 2, 'Refrigerantes');

INSERT INTO Estoque (id_estoque, id_sub_categoria, descricao, qtd_estoque, valor_unitario) VALUES 
(1, 1, 'Leite Integral Caixinha 1L', 149, 5.00), -- Atualizado com saldos consolidados pós-testes
(2, 2, 'Arroz Tipo 1 Agulhinha 5kg', 18, 30.00),
(3, 3, 'Refrigerante de Cola 2L', 48, 9.00);

-- Correção do erro 1054: Alinhamento de 'city' para 'cidade'
INSERT INTO Localidade (id_localidade, cep, logradouro, bairro, cidade, estado) VALUES  
(1, '08410-000', 'Avenida Laranjeiras', 'Guaianases', 'São Paulo', 'SP'), 
(2, '08420-110', 'Rua das Flores', 'Cidade Tiradentes', 'São Paulo', 'SP');


-- ============================================================================
-- 2. CADASTRO DE PESSOAS, ENTIDADES DE PAPEL E BIOGRAFIAS (CORREÇÃO DE COLUNA)
-- ============================================================================

INSERT INTO Pessoa (id_pessoa, nome, status_pessoa) VALUES 
(1, 'Carlos Lopes (Dono)', 'Ativo'),
(2, 'Renan Lopes (Auxiliar)', 'Ativo'),
(3, 'Marcos Souza (Vizinho)', 'Ativo'),
(4, 'Ana Silva (Moradora)', 'Ativo'),
(5, 'Distribuidora Laticínios Vale S/A', 'Ativo');

INSERT INTO Pessoa_Fisica (id_pessoa, cpf) VALUES 
(1, '111.111.111-11'),
(2, '222.222.222-22'),
(3, '333.333.333-33'),
(4, '444.444.444-44');

INSERT INTO Pessoa_Juridica (id_pessoa, cnpj) VALUES 
(5, '55.555.555/0001-55');

-- Correção da coluna 'telefone' (Alinhado com a DDL oficial)
INSERT INTO Telefone_Pessoa (id_pessoa, telefone) VALUES 
(1, '11911111111'),
(2, '11922222222'),
(3, '11933333333'),
(4, '11944444444');

INSERT INTO Email_Pessoa (id_pessoa, email) VALUES 
(1, 'carlos@lopes.com');

INSERT INTO Endereco_Pessoa (id_pessoa, id_localidade, numero, ponto_referencia) VALUES 
(3, 1, '150', 'Próximo à Padaria'),
(4, 2, '45A', 'Frente à praça');

INSERT INTO Funcionario (id_funcionario, id_pessoa_fisica, ctps, sexo, rg, nome_da_mae) VALUES 
(1, 2, '12345-SP', 'Masculino', '12.345.678-9', 'Maria Lopes');

INSERT INTO Cliente (id_cliente, id_pessoa_fisica, data_cadastro) VALUES 
(1, 3, '2026-10-01'),
(2, 4, '2026-10-02');

INSERT INTO Fornecedor (id_fornecedor, id_pessoa_juridica, razao_social) VALUES 
(1, 5, 'Distribuidora Laticínios Vale S/A');

INSERT INTO Ficha_Do_Cliente (id_ficha_do_cliente, id_cliente, limite_credito, saldo_devedor_atual, data_abertura, situacao_credito) VALUES 
(1, 1, 120.00, 41.20, '2026-10-10', 'Bloqueado'); -- Inicia bloqueado refletindo o teste do cenário 2

-- ============================================================================
-- 3. MOVIMENTAÇÕES DE ENTRADA (CENÁRIO 3 E 4: CORREÇÃO DE CONTAGEM DE COLUNAS)
-- ============================================================================

INSERT INTO Entrega (id_entrega, id_fornecedor, num_nota_fiscal, data_recebimento, hora_recebimento, valor_total_nota, forma_pagamento, data_vencimento, status_entrega, status_liquidacao, data_pagamento, valor_pago) VALUES 
(1, 1, 'NF-1001', '2026-10-05', '09:00:00', 500.00, 'Boleto bancário', '2026-10-20', 'Aprovado', 'Pago', '2026-10-18', 500.00),
(2, 1, 'NF-1002', '2026-10-06', '10:15:00', 300.00, 'Boleto bancário', '2026-10-25', 'Aprovado', 'A Pagar', NULL, NULL),
-- Correção do erro 1136: Alinhamento exato de colunas/valores para NF-1003 paid on act
(3, 1, 'NF-1003', '2026-10-06', '11:00:00', 600.00, 'Débito automático', '2026-10-06', 'Aprovado', 'Pago', '2026-10-06', 600.00);

-- Vinculação estrita de Lotes (Produtos) às Notas Fiscais existentes
INSERT INTO Produto (id_produto, id_estoque, id_entrega, lote, qtd_total, qtd_recusada, qtd_disponivel, dt_entrada_estoque, data_validade, data_fabricacao, status_produto) VALUES 
(1, 1, 1, 'LOTE-L1', 100, 0, 91, '2026-10-05', '2026-11-30', '2026-10-01', 'Ativo'),
(2, 1, 2, 'LOTE-L2', 60, 0, 60, '2026-10-06', '2026-12-15', '2026-10-02', 'Ativo'),
(3, 2, 3, 'LOTE-A1', 20, 0, 18, '2026-10-06', '2027-10-06', '2026-09-20', 'Ativo'),
(4, 3, 3, 'LOTE-R1', 50, 0, 48, '2026-10-06', '2026-11-15', '2026-09-25', 'Ativo');

-- ============================================================================
-- 4. HISTÓRICO DE TRANSAÇÕES COMERCIAIS E DEVOLUÇÕES (CENÁRIOS 1, 5 E 6)
-- ============================================================================

INSERT INTO Venda (id_venda, id_funcionario, id_cliente, id_ficha_do_cliente, data, hora, forma_pagamento, status_pagamento) VALUES 
(101, 1, 1, 1, '2026-10-10', '14:30:00', 'Fiado', 'Pendente'),
(102, 1, 1, 1, '2026-10-11', '10:00:00', 'Fiado', 'Pendente'),
(103, 1, 2, NULL, '2026-10-07', '16:00:00', 'Dinheiro', 'Pago'),
(104, 1, 2, NULL, '2026-10-22', '09:30:00', 'Dinheiro', 'Pago'),
(105, 1, NULL, NULL, '2026-10-12', '18:20:00', 'Pix', 'Pago'),
(106, 1, NULL, NULL, '2026-10-13', '11:10:00', 'Cartão de crédito', 'Pago');

INSERT INTO Itens_Venda (id_venda, id_produto, quantidade, preco_unitario_aplicado, desconto_aplicado, valor_total) VALUES 
(101, 1, 8, 5.00, 0.00, 40.00),
(102, 4, 2, 9.00, 1.80, 16.20), -- Desconto de validade congelado na venda 102
(103, 3, 1, 30.00, 0.00, 30.00),
(104, 3, 1, 30.00, 0.00, 30.00),
(104, 1, 1, 5.00, 0.00, 5.00),
(105, 1, 10, 5.00, 0.00, 50.00),
(106, 3, 2, 30.00, 0.00, 60.00);

INSERT INTO Pagamento_Fiado (id_quita_amortiza, id_ficha_do_cliente, id_cliente, valor_pago, data_pagamento) VALUES 
(1, 1, 1, 15.00, '2026-10-12');

INSERT INTO Devolucao_Troca (id_devolucao, id_venda, data, hora, valor_diferenca, valor_credito_gerado) VALUES 
(1, 103, '2026-10-15', '11:00:00', 0.00, 30.00);

INSERT INTO Itens_Devolvidos (id_devolucao, id_produto, quantidade, tipo_movimentacao_item, status_item) VALUES 
(1, 3, 1, 'Retorno ao Estoque', 'Perfeito');

INSERT INTO Utiliza_Credito (id_venda, id_devolucao, valor_utilizado) VALUES 
(104, 1, 30.00);

-- ============================================================================
-- 5. CONFERÊNCIA DIÁRIA E BALANÇO FINANCEIRO (CENÁRIO 7)
-- ============================================================================

INSERT INTO Fechamento_Caixa (id_fechamento, id_funcionario, data_fechamento, saldo_inicial, saldo_final, valor_contado_caixa, diferenca_apurada) VALUES 
(1, 1, '2026-10-12', 800.00, 815.00, 810.00, -5.00);
