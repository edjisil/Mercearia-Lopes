-- ============================================================================
-- PROJETO INTEGRADOR: MERCEARIA LOPES - VERSÃO OFFICIAL 1.6
-- SCRIPT DQL: CONSULTAS GERENCIAIS DE BI E AUDITORIA DE CAIXA (CORRIGIDO)
-- ============================================================================
USE merceariaLopes;

-- ============================================================================
-- PARTE 1: AS 3 CONSULTAS DE INTELIGÊNCIA DE NEGÓCIOS (BI) DO PROJETO
-- ============================================================================

-- QUERY BI 1: Quais produtos costumam ter maior demanda de vendas no histórico?
SELECT 
    E.id_estoque AS 'Código do Item',
    E.descricao AS 'Descrição do Produto',
    SUM(IV.quantidade) AS 'Quantidade Total Vendida',
    SUM(IV.valor_total) AS 'Faturamento Total (R$)'
FROM Itens_Venda IV
INNER JOIN Produto P ON IV.id_produto = P.id_produto
INNER JOIN Estoque E ON P.id_estoque = E.id_estoque
INNER JOIN Venda V ON IV.id_venda = V.id_venda
GROUP BY E.id_estoque, E.descricao
ORDER BY SUM(IV.quantidade) DESC;

-- QUERY BI 2: Quais os picos de clientes e vendas por dia da semana?
SELECT 
    CASE DiadasemanaNumero
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Segunda-feira'
        WHEN 3 THEN 'Terça-feira'
        WHEN 4 THEN 'Quarta-feira'
        WHEN 5 THEN 'Quinta-feira'
        WHEN 6 THEN 'Sexta-feira'
        WHEN 7 THEN 'Sábado'
    END AS 'Dia da Semana',
    Total_Cupons AS 'Total de Cupons Emitidos',
    Volume_Itens AS 'Volume de Itens Saídos'
FROM (
    SELECT 
        DAYOFWEEK(V.data) AS DiadasemanaNumero,
        COUNT(DISTINCT V.id_venda) AS Total_Cupons,
        SUM(IV.quantidade) AS Volume_Itens
    FROM Venda V
    INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
    GROUP BY DAYOFWEEK(V.data)
) AS SubqueryAgrupada
ORDER BY DiadasemanaNumero;

-- QUERY BI 3: Em quais meses a venda fiada costuma ser mais frequente?
SELECT 
    MONTH(V.data) AS 'Mês',
    YEAR(V.data) AS 'Ano',
    COUNT(V.id_venda) AS 'Qtd Vendas no Fiado',
    SUM(IV.valor_total) AS 'Total Faturado no Fiado (R$)'
FROM Venda V
INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
WHERE V.forma_pagamento = 'FIADO' -- CORRIGIDO: Caixa alta para casar com a higienização
GROUP BY MONTH(V.data), YEAR(V.data)
ORDER BY YEAR(V.data) DESC, MONTH(V.data) DESC;

-- ============================================================================
-- PARTE 2: CONSULTAS DE AUDITORIA FINANCEIRA E FLUXO DE CAIXA (REQUISITO CRÍTICO)
-- ============================================================================

-- QUERY 4: Composição Detalhada e Origem da Dívida por Cliente (Cenário 1)
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
    WHERE V.forma_pagamento <> 'FIADO' -- CORRIGIDO: Caixa alta
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
    WHERE status_liquidacao = 'PAGO' AND data_pagamento IS NOT NULL -- CORRIGIDO: Caixa alta
    GROUP BY data_pagamento
) AS Movimentacoes
GROUP BY Movimentacoes.Data_Movimento
ORDER BY Movimentacoes.Data_Movimento DESC;

-- ============================================================================
-- PARTE 3: EXPANSÃO DE CONSULTAS DE AUDITORIA, PERFORMANCE E RISCO COMERCIAL
-- ============================================================================

-- QUERY BI 6: Relatório de Risco e Alerta de Validade Crítica (Próximos 30 dias)
SELECT 
    E.descricao AS 'Produto',
    P.lote AS 'Lote',
    P.qtd_disponivel AS 'Qtd em Gôndola',
    P.data_validade AS 'Data de Vencimento',
    DATEDIFF(P.data_validade, CURDATE()) AS 'Dias Restantes', -- CORRIGIDO: Dinâmico com a data atual
    CASE 
        WHEN DATEDIFF(P.data_validade, CURDATE()) <= 7 THEN 'CRÍTICO: Recolher ou Liquidar'
        WHEN DATEDIFF(P.data_validade, CURDATE()) <= 30 THEN 'ATENÇÃO: Ofertar no Balcão'
        ELSE 'Normal'
    END AS 'Status do Risco'
FROM Produto P
INNER JOIN Estoque E ON P.id_estoque = E.id_estoque
WHERE P.status_produto = 'ATIVO' AND P.qtd_disponivel > 0
ORDER BY P.data_validade ASC;

-- QUERY BI 7: Curva ABC e Ranking Financeiro de Clientes (Faturamento Efetivo)
SELECT 
    PE.nome AS 'Nome do Cliente',
    COUNT(DISTINCT V.id_venda) AS 'Total de Compras Realizadas',
    SUM(IV.valor_total) AS 'Total Gasto Acumulado (R$)',
    ROUND(AVG(IV.valor_total), 2) AS 'Ticket Médio por Cupom (R$)'
FROM Venda V
INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
INNER JOIN Cliente C ON V.id_cliente = C.id_cliente
INNER JOIN Pessoa PE ON C.id_pessoa_fisica = PE.id_pessoa
GROUP BY PE.nome
ORDER BY SUM(IV.valor_total) DESC;

-- QUERY BI 8: Auditoria Financeira de Quebras de Estoque, Descartes e Avarias
SELECT 
    'Descarte por Vencimento (Loja)' AS 'Tipo de Ocorrência',
    E.descricao AS 'Item Afetado',
    P.qtd_descartada AS 'Quantidade Perdia',
    (P.qtd_descartada * E.valor_unitario) AS 'Prejuízo Estimado (R$)'
FROM Produto P
INNER JOIN Estoque E ON P.id_estoque = E.id_estoque
WHERE P.qtd_descartada > 0
UNION ALL
SELECT 
    'Avaria no Recebimento (Fornecedor)' AS 'Tipo de Ocorrência',
    E.descricao AS 'Item Afetado',
    IDF.quantidade_devolvida AS 'Quantidade Perdia',
    (IDF.quantidade_devolvida * E.valor_unitario) AS 'Prejuízo Estimado (R$)'
FROM Itens_Devolvidos_Fornecedor IDF
INNER JOIN Produto P ON IDF.id_produto = P.id_produto
INNER JOIN Estoque E ON P.id_estoque = E.id_estoque;

-- QUERY BI 9: Desempenho Estatístico de Vendas por Período Horário (Gargalo de Caixa)
SELECT 
    CONCAT(Hora_Base, ':00 as ', Hora_Base + 1, ':00') AS 'Intervalo de Tempo',
    Total_Atendimentos AS 'Volume de Atendimentos',
    Itens_Passados AS 'Itens Passados no Caixa',
    Volume_Financeiro AS 'Volume Financeiro Movimentado (R$)'
FROM (
    SELECT 
        HOUR(V.hora) AS Hora_Base,
        COUNT(DISTINCT V.id_venda) AS Total_Atendimentos,
        SUM(IV.quantidade) AS Itens_Passados,
        SUM(IV.valor_total) AS Volume_Financeiro
    FROM Venda V
    INNER JOIN Itens_Venda IV ON V.id_venda = IV.id_venda
    GROUP BY HOUR(V.hora)
) AS SubqueryHorario
ORDER BY Volume_Financeiro DESC;

-- QUERY BI 10: Extrato Consolidado de Saúde Fiscal e Logística de Fornecedores
SELECT 
    PE.nome AS 'Razão Social / Distribuidor',
    COUNT(E.id_entrega) AS 'Total de Notas Emitidas',
    SUM(E.valor_total_nota) AS 'Montante Global Transacionado (R$)',
    SUM(CASE WHEN E.status_liquidacao = 'A PAGAR' THEN E.valor_total_nota ELSE 0.00 END) AS 'Dívida Ativa com Fornecedor (R$)',
    SUM(CASE WHEN E.status_entrega = 'DIVERGENTE' OR E.status_entrega = 'COM AVARIA' THEN 1 ELSE 0 END) AS 'Nº de Entregas com Problema'
FROM Entrega E
INNER JOIN Fornecedor F ON E.id_fornecedor = F.id_fornecedor
INNER JOIN Pessoa_Juridica PJ ON F.id_pessoa_juridica = PJ.id_pessoa
INNER JOIN Pessoa PE ON PJ.id_pessoa = PE.id_pessoa
GROUP BY PE.nome
ORDER BY SUM(E.valor_total_nota) DESC;
