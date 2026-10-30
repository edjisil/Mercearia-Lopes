
-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES - VERSÃO OFFICIAL 1.6
-- SCRIPT DQL: CONSULTAS GERENCIAIS DE BI E AUDITORIA DE CAIXA
-- ============================================================================

USE merceariaLopes;

-- ============================================================================
-- PARTE 1: AS 3 CONSULTAS DE INTELIGÊNCIA DE NEGÓCIOS (BI) DO PROJETO
-- ============================================================================

-- QUERY BI 1: Quais produtos costumam ter maior demanda de vendas no mês?
-- Propósito: Responder ao gráfico de barras do Top 10 itens para planejamento de compras.
SELECT 
    E.id_estoque AS 'Código do Item',
    E.descricao AS 'Descrição do Produto',
    SUM(IV.quantidade) AS 'Quantidade Total Vendida',
    SUM(IV.valor_total) AS 'Faturamento Total (R$)'
FROM Itens_Venda IV
INNER JOIN Produto P ON IV.id_produto = P.id_produto
INNER JOIN Estoque E ON P.id_estoque = E.id_estoque
INNER JOIN Venda V ON IV.id_venda = V.id_venda
WHERE MONTH(V.data) = 10 AND YEAR(V.data) = 2026
GROUP BY E.id_estoque, E.descricao
ORDER BY SUM(IV.quantidade) DESC;

-- QUERY BI 2: Quais os picos de clientes e vendas por dia da semana?
-- Propósito: Responder ao gráfico de colunas para otimização de escalas de funcionários.
SELECT 
    CASE DAYOFWEEK(V.data)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Segunda-feira'
        WHEN 3 THEN 'Terça-feira'
        WHEN 4 THEN 'Quarta-feira'
        WHEN 5 THEN 'Quinta-feira'
        WHEN 6 THEN 'Sexta-feira'
        WHEN 7 THEN 'Sábado'
    END AS 'Dia da Semana',
    COUNT(DISTINCT V.id_venda) AS 'Total de Cupons Emitidos',
    SUM(IV.quantidade) AS 'Volume de Itens Saídos'
FROM Venda V
INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
GROUP BY DAYOFWEEK(V.data), V.data
ORDER BY DAYOFWEEK(V.data);

-- QUERY BI 3: Em quais meses a venda fiada costuma ser mais frequente?
-- Propósito: Monitorar a flutuação do caderno virtual e risco de capital de giro.
SELECT 
    MONTH(V.data) AS 'Mês',
    YEAR(V.data) AS 'Ano',
    COUNT(V.id_venda) AS 'Qtd Vendas no Fiado',
    SUM(IV.valor_total) AS 'Total Faturado no Fiado (R$)'
FROM Venda V
INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
WHERE V.forma_pagamento = 'Fiado'
GROUP BY MONTH(V.data), YEAR(V.data)
ORDER BY YEAR(V.data) DESC, MONTH(V.data) DESC;

-- ============================================================================
-- PARTE 2: CONSULTAS DE AUDITORIA FINANCEIRA E FLUXO DE CAIXA (REQUISITO CRÍTICO)
-- ============================================================================

-- QUERY 4: Composição Detalhada e Origem da Dívida por Cliente (Cenário 1)
-- Propósito: Provar para o professor que o saldo da Ficha pode ser reconstruído do zero.
SELECT 
    PE.nome AS 'Cliente',
    F.id_ficha_do_cliente AS 'Nº Caderneta',
    V.id_venda AS 'Nº Cupom Fiscal',
    V.data AS 'Data da Compra',
    SUM(IV.valor_total) AS 'Valor da Venda (R$)'
FROM Ficha_Do_Cliente F
INNER JOIN Cliente C ON F.id_cliente = C.id_cliente
INNER JOIN Pessoa PE ON C.id_pessoa_fisica = PE.id_pessoa
INNER JOIN Venda V ON V.id_ficha_do_cliente = F.id_ficha_do_cliente
INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
WHERE F.id_ficha_do_cliente = 1
GROUP BY PE.nome, F.id_ficha_do_cliente, V.id_venda, V.data;

-- QUERY 5: Demonstrativo de Fluxo de Caixa Diário por Período (RN10)
-- Propósito: Apurar Entradas Reais (À vista + Fiado Pago) vs Saídas Reais (Fornecedores Pagos).
SELECT 
    Movimentacoes.Data_Movimento,
    SUM(Movimentacoes.Entrada) AS 'Total Entradas Efetivas (R$)',
    SUM(Movimentacoes.Saida) AS 'Total Saídas Efetivas (R$)',
    (SUM(Movimentacoes.Entrada) - SUM(Movimentacoes.Saida)) AS 'Resultado Líquido do Dia (R$)'
FROM (
    -- 1. Entradas por Vendas Pagas no Ato (Dinheiro, Pix, Cartões)
    SELECT V.data AS Data_Movimento, SUM(IV.valor_total) AS Entrada, 0.00 AS Saida
    FROM Venda V
    INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
    WHERE V.forma_pagamento <> 'Fiado'
    GROUP BY V.data
    
    UNION ALL
    
    -- 2. Entradas por Recebimento Posterior de Fiado (Amortizações)
    SELECT data_pagamento AS Data_Movimento, SUM(valor_pago) AS Entrada, 0.00 AS Saida
    FROM Pagamento_Fiado
    GROUP BY data_pagamento
    
    UNION ALL
    
    -- 3. Saídas por Pagamentos Efetivos de Notas Fiscais a Fornecedores
    SELECT data_pagamento AS Data_Movimento, 0.00 AS Entrada, SUM(valor_pago) AS Saida
    FROM Entrega
    WHERE status_liquidacao = 'Pago' AND data_pagamento IS NOT NULL
    GROUP BY data_pagamento
) AS Movimentacoes
GROUP BY Movimentacoes.Data_Movimento
ORDER BY Movimentacoes.Data_Movimento DESC;


