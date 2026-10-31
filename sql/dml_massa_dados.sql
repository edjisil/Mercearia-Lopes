-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES - VERSÃO OFFICIAL 1.6
-- SCRIPT DML: CARGA DE DADOS UNIFICADA, ORDENADA E HOMOLOGADA
-- BLINDADO CONTRA ERRO 1452 ATRAVÉS DE SEQUENCIAMENTO GENEALÓGICO
-- ============================================================================
USE merceariaLopes;

-- ----------------------------------------------------------------------------
-- PASSO 1: RESET TOTAL DO AMBIENTE (DESLIGA TRAVAS E LIMPA MEMÓRIA)
-- ----------------------------------------------------------------------------
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
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- PASSO 2: CATEGORIAS E SUBCATEGORIAS (TODAS JUNTAS)
-- ----------------------------------------------------------------------------
INSERT INTO Categoria (id_categoria, nome_categoria) VALUES 
(1, 'Alimentos Básicos'),
(2, 'Bebidas'),
(3, 'Hortifrúti'),
(4, 'Açougue & Embutidos'),
(5, 'Padaria e Confeitaria');

INSERT INTO Sub_Categoria (id_sub_categoria, id_categoria, nome_sub_categoria) VALUES 
(1, 1, 'Laticínios'),
(2, 1, 'Mercearia Seca'),
(3, 2, 'Refrigerantes'),
(4, 4, 'Carnes Bovinas (Filé)'),
(5, 5, 'Pães e Salgados');

-- ----------------------------------------------------------------------------
-- PASSO 3: ESTOQUE / CATÁLOGO DE PRODUTOS
-- ----------------------------------------------------------------------------
INSERT INTO Estoque (id_estoque, id_sub_categoria, descricao, qtd_estoque, valor_unitario) VALUES 
(1, 1, 'Leite Integral Caixinha 1L', 149, 5.00), 
(2, 2, 'Arroz Tipo 1 Agulhinha 5kg', 18, 30.00),
(3, 3, 'Refrigerante de Cola 2L', 48, 9.00),
(4, 4, 'Contra Filé Bovino Peça kg', 25, 42.90), 
(5, 5, 'Pão de Forma Tradicional 400g', 30, 7.50),
(6, 3, 'Guaraná Antarctica Pet 2L', 60, 8.50);

-- ----------------------------------------------------------------------------
-- PASSO 4: INFRAESTRUTURA GEOGRÁFICA
-- ----------------------------------------------------------------------------
INSERT INTO Localidade (id_localidade, cep, logradouro, bairro, cidade, estado) VALUES  
(1, '08410-000', 'Avenida Laranjeiras', 'Guaianases', 'São Paulo', 'SP'), 
(2, '08420-110', 'Rua das Flores', 'Cidade Tiradentes', 'São Paulo', 'SP'),
(3, '08430-220', 'Rua São João, travessa B.', 'Vila Sônia', 'São Paulo', 'SP');

-- ----------------------------------------------------------------------------
-- PASSO 5: CADASTRO DE PESSOAS (RAIZ DA HERANÇA)
-- ----------------------------------------------------------------------------
INSERT INTO Pessoa (id_pessoa, nome, status_pessoa) VALUES 
(1, 'Carlos Lopes (Dono)', 'ATIVO'),
(2, 'Renan Lopes (Auxiliar)', 'ATIVO'),
(3, 'Marcos Souza (Vizinho)', 'ATIVO'),
(4, 'Ana Silva (Moradora)', 'ATIVO'),
(5, 'Distribuidora Laticínios Vale S/A', 'ATIVO'),
(6, 'Lúcia de Souza Araújo', 'ATIVO'),
(7, 'Marcos da Silva Júnior.', 'ATIVO'),
(8, 'Antônio P. Rodrigues', 'INATIVO'),
(9, 'Frigorífico Boi Gordo Ltda.', 'ATIVO');

-- ----------------------------------------------------------------------------
-- PASSO 6: ESPECIALIZAÇÕES DE PESSOA (FÍSICA / JURÍDICA)
-- ----------------------------------------------------------------------------
INSERT INTO Pessoa_Fisica (id_pessoa, cpf) VALUES 
(1, '111.111.111-11'),
(2, '222.222.222-22'),
(3, '333.333.333-33'),
(4, '444.444.444-44'),
(6, '666.666.666-66'),
(7, '777.777.777-77'),
(8, '888.888.888-88');

INSERT INTO Pessoa_Juridica (id_pessoa, cnpj) VALUES 
(5, '55.555.555/0001-55'),
(9, '99.999.999/0001-99');

-- ----------------------------------------------------------------------------
-- PASSO 7: CONTATOS E ENDEREÇOS
-- ----------------------------------------------------------------------------
INSERT INTO Telefone_Pessoa (id_pessoa, telefone) VALUES 
(1, '11911111111'),
(2, '11922222222'),
(3, '11933333333'),
(4, '11944444444'),
(6, '11966666666'),
(7, '11977777777'),
(8, '11988888888');

INSERT INTO Email_Pessoa (id_pessoa, email) VALUES 
(1, 'carlos@lopes.com'),
(6, 'lucia.araujo@provedor.com.br'),
(7, 'junior_silva@email.com');

INSERT INTO Endereco_Pessoa (id_pessoa, id_localidade, numero, ponto_referencia) VALUES 
(3, 1, '150', 'Próximo à Padaria'),
(4, 2, '45A', 'Frente à praça'),
(6, 3, 'S/N.', 'Frente ao Açougue do Zé.'),
(7, 3, '12-A', 'Próximo à igreja matriz.');

-- ----------------------------------------------------------------------------
-- PASSO 8: PAPÉIS E REGRAS FINANCEIRAS DE CLIENTES/FORNECEDORES
-- ----------------------------------------------------------------------------
INSERT INTO Funcionario (id_funcionario, id_pessoa_fisica, ctps, sexo, rg, nome_da_mae) VALUES 
(1, 2, '12345-SP', 'Masculino', '12.345.678-9', 'Maria Lopes'),
(2, 8, '67890-SP', 'Masculino', '23.456.789-0', 'Antônia Rodrigues');

INSERT INTO Cliente (id_cliente, id_pessoa_fisica) VALUES 
(1, 3),
(2, 4),
(3, 6),
(4, 7);

INSERT INTO Fornecedor (id_fornecedor, id_pessoa_juridica, razao_social) VALUES 
(1, 5, 'Distribuidora Laticínios Vale S/A'),
(2, 9, 'Frigorífico Boi Gordo Ltda.');

INSERT INTO Ficha_Do_Cliente (id_ficha_do_cliente, id_cliente, limite_credito, saldo_devedor_atual, situacao_credito) VALUES 
(1, 1, 120.00, 41.20, 'BLOQUEADO'),
(2, 3, 200.00, 0.00, 'LIBERADO');

-- ----------------------------------------------------------------------------
-- PASSO 9: MOVIMENTAÇÕES DE ENTRADA (NOTAS FISCAIS DE FORNECEDORES)
-- ----------------------------------------------------------------------------
INSERT INTO Entrega (id_entrega, id_fornecedor, num_nota_fiscal, data_recebimento, hora_recebimento, valor_total_nota, forma_pagamento, data_vencimento, status_entrega, status_liquidacao, data_pagamento, valor_pago) VALUES 
(1, 1, 'NF-1001', '2026-10-05', '09:00:00', 500.00, 'BOLETO BANCÁRIO', '2026-10-20', 'APROVADO', 'PAGO', '2026-10-18', 500.00),
(2, 1, 'NF-1002', '2026-10-06', '10:15:00', 300.00, 'BOLETO BANCÁRIO', '2026-10-25', 'APROVADO', 'A PAGAR', NULL, NULL),
(3, 1, 'NF-1003', '2026-10-06', '11:00:00', 600.00, 'DÉBITO AUTOMÁTICO', '2026-10-06', 'APROVADO', 'PAGO', '2026-10-06', 600.00),
(4, 2, 'NF-2022.', '2026-10-15', '07:30:00', 1072.50, 'BOLETO BANCÁRIO', '2026-11-15', 'APROVADO', 'A PAGAR', NULL, NULL);

-- ----------------------------------------------------------------------------
-- PASSO 10: PRODUTOS FÍSICOS (LOTES)
-- ----------------------------------------------------------------------------
INSERT INTO Produto (id_produto, id_estoque, id_entrega, lote, qtd_total, qtd_recusada, qtd_disponivel, dt_entrada_estoque, data_validade, data_fabricacao, status_produto) VALUES 
(1, 1, 1, 'LOTE-L1', 100, 0, 91, '2026-10-05', '2026-11-30', '2026-10-01', 'ATIVO'),
(2, 1, 2, 'LOTE-L2', 60, 0, 60, '2026-10-06', '2026-12-15', '2026-10-02', 'ATIVO'),
(3, 2, 3, 'LOTE-A1', 20, 0, 18, '2026-10-06', '2027-10-06', '2026-09-20', 'ATIVO'),
(4, 3, 3, 'LOTE-R1', 50, 0, 48, '2026-10-06', '2026-11-15', '2026-09-25', 'ATIVO'),
(5, 4, 4, 'LOTE-BOI-01', 25, 0, 25, '2026-10-15', '2026-10-30', '2026-10-14', 'ATIVO');

-- ----------------------------------------------------------------------------
-- PASSO 11: HISTÓRICO DE VENDAS (CUPONS FISCAIS)
-- ----------------------------------------------------------------------------
INSERT INTO Venda (id_venda, id_funcionario, id_cliente, id_ficha_do_cliente, forma_pagamento, status_pagamento) VALUES 
(101, 1, 1, 1, 'FIADO', 'PENDENTE'),
(102, 1, 1, 1, 'FIADO', 'PENDENTE'),
(103, 1, 2, NULL, 'DINHEIRO', 'PAGO'),
(104, 1, 2, NULL, 'DINHEIRO', 'PAGO'),
(105, 1, NULL, NULL, 'PIX', 'PAGO'),
(106, 1, NULL, NULL, 'CARTÃO DE CRÉDITO', 'PAGO'),
(107, 1, 3, 2, 'CARTÃO DE CRÉDITO', 'PAGO');

-- ----------------------------------------------------------------------------
-- PASSO 12: ITENS DOS CUPONS E FLUXOS FINANCEIROS DE AMORTIZAÇÃO
-- ----------------------------------------------------------------------------
INSERT INTO Itens_Venda (id_venda, id_produto, quantidade, preco_unitario_aplicado, desconto_aplicado, valor_total) VALUES 
(101, 1, 8, 5.00, 0.00, 40.00),
(102, 4, 2, 9.00, 1.80, 16.20), 
(103, 3, 1, 30.00, 0.00, 30.00),
(104, 3, 1, 30.00, 0.00, 30.00),
(104, 1, 1, 5.00, 0.00, 5.00),
(105, 1, 10, 5.00, 0.00, 50.00),
(106, 3, 2, 30.00, 0.00, 60.00),
(107, 5, 2, 42.90, 0.00, 85.80);

INSERT INTO Pagamento_Fiado (id_quita_amortiza, id_ficha_do_cliente, id_cliente, valor_pago) VALUES 
(1, 1, 1, 15.00);

-- ----------------------------------------------------------------------------
-- PASSO 13: DEVOLUÇÕES, CRÉDITOS E CONFERÊNCIA DE OPERAÇÕES
-- ----------------------------------------------------------------------------
INSERT INTO Devolucao_Troca (id_devolucao, id_venda, valor_diferenca, valor_credito_gerado) VALUES 
(1, 103, 0.00, 30.00),
(2, 107, 0.00, 85.80);

INSERT INTO Itens_Devolvidos (id_devolucao, id_produto, quantidade, tipo_movimentacao_item, status_item) VALUES 
(1, 3, 1, 'RETORNO AO ESTOQUE', 'PERFEITO'),
(2, 5, 2, 'DESCARTE/PERDA', 'AVARIADO');

INSERT INTO Utiliza_Credito (id_venda, id_devolucao, valor_utilizado) VALUES 
(104, 1, 30.00);

INSERT INTO Fechamento_Caixa (id_fechamento, id_funcionario, saldo_inicial, saldo_final, valor_contado_caixa, diferenca_apurada) VALUES 
(1, 1, 800.00, 815.00, 810.00, -5.00);

UPDATE Produto
SET qtd_disponivel = qtd_disponivel - 2,
status_produto = 'DESCARTADO',
qtd_descartada = 2,
data_descarte = CURDATE()
WHERE id_produto = 1;
UPDATE Estoque SET qtd_estoque = qtd_estoque - 2 WHERE id_estoque = 1;
INSERT INTO Devolucao_Fornecedor (id_devolucao_fornecedor, valor_estorno, forma_acerto) VALUES
(1, 25.00, 'DESCONTO NA PRÓXIMA COMPRA');
INSERT INTO Itens_Devolvidos_Fornecedor (id_devolucao_fornecedor, id_produto, quantidade_devolvida, motivo_devolucao) VALUES
(1, 2, 5, 'Caixas amassadas e vazando no recebimento');
UPDATE Produto SET qtd_disponivel = qtd_disponivel - 5 WHERE id_produto = 2;
UPDATE Estoque SET qtd_estoque = qtd_estoque - 5 WHERE id_estoque = 1;
