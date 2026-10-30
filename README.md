
🏢 1. Caracterização da Empresa e Justificativa

A Mercearia Lopes é um comércio varejista de bairro que atende à comunidade local exclusivamente por meio de vendas físicas diretas no balcão. Este projeto visa modernizar e automatizar os processos operacionais, eliminando o controle em cadernos manuais e notas fiscais desorganizadas para mitigar riscos de produtos vencidos nas prateleiras e inadimplência no fiado.

📂 2. Navegação Estruturada do Repositório

Para acessar os arquivos originais e scripts criados pela equipe, navegue pelas pastas abaixo:
• docs/diagramas/: Contém as capturas oficiais do DER v1.6 na notação Peter Chen Purista.
• sql/ddl_estrutura.sql: Script físico de criação das tabelas e restrições de integridade.
• sql/dml_massa_dados.sql: Arquivo de inserção da massa de dados coerente para testes operacionais.
• sql/consultas_gerenciais.sql: Queries de inteligência de negócios (BI) e relatórios de fluxo de caixa.

🛠️ 3. Documentação Completa do Projeto (Clique nas setas para expandir)

📋 Requisitos do Sistema (RF e RNF)

Requisitos Funcionais (RF) 

• RF01: Cadastrar pessoas, separando clientes e funcionários (PF) de fornecedores (PJ).
• RF02: Abrir uma única ficha de fiado por cliente.
• RF03: Bloquear vendas no fiado se o saldo devedor somado à compra atual ultrapassar R$ 120,00.
• RF04: Registrar múltiplos pagamentos (amortizações) para uma mesma ficha de fiado.
• RF05: Dar baixa automática nas quantidades do lote e do estoque ao finalizar uma venda.
• RF06: Registrar múltiplos produtos em uma única entrega de fornecedor vinculada à Nota Fiscal.
• RF07: Exigir cupom fiscal para qualquer processo de troca ou devolução de clientes, sem exceções.
• RF08: Registrar os pagamentos e prazos das obrigações com fornecedores (Contas a Pagar).
• RF09: Gerar e controlar créditos de troca para uso em compras futuras.
• RF10: Permitir vendas anônimas (sem cadastro de cliente) nas modalidades à vista.
• RF11: Aplicar automaticamente 10% de desconto em itens com menos de 30 dias de validade.
• RF12: Registrar o fechamento diário do caixa avaliando o valor esperado contra o valor contado.

Requisitos Não Funcionais (RNF) [1]

• RNF01 (Segurança de Acesso): Controle por dois perfis de usuário (Proprietário com acesso total e Funcionário limitado a operações de caixa e consultas operacionais autorizadas de balcão).
• RNF02 (Integridade Histórica): Proibir a exclusão física de registros com movimentações. O sistema utiliza um campo de status (Ativo/Inativo) para desativar cadastros e preservar o histórico do negócio.
⚖️ Regras de Negócio Consolidadas (RN)
• RN01: O horário de funcionamento é das 8h às 22h, de domingo a domingo.
• RN02: O proprietário e o funcionário auxiliar de confiança possuem chaves para abertura e fechamento físico.
• RN03: O estoque é vistoriado diariamente. Lotes vencidos são baixados com status 'Descartado'.
• RN04: Produtos nos últimos 30 dias de validade recebem 10% de desconto, congelado na linha da venda.
• RN05: O limite do fiado é de R$ 120,00. Se bloqueada por estourar o limite, a ficha só libera para novas compras após a quitação integral da dívida (saldo igual a zero).
• RN06: Toda e qualquer venda deve ser registrada cronologicamente, independente da forma de pagamento.
• RN07: Trocas e devoluções exigem obrigatoriamente o cupom fiscal. Sem localização da venda, a operação é recusada.
• RN08: Itens devolvidos com avaria ou vencidos são descartados; itens em perfeito estado retornam ao estoque.
• RN09: O recebimento de mercadorias gera uma obrigação "A Pagar" com valor faturado, vencimento e forma de pagamento.
• RN10: O fluxo de caixa segue a equação: Saldo Inicial + Entradas Efetivas - Saídas Efetivas = Saldo Final. Venda fiada não gera entrada imediata de caixa.
• RN11: O cadastro do cliente só é obrigatório para compras na modalidade fiado.
• RN12: O crédito gerado em trocas não gera reembolso em dinheiro e fica identificado pela devolução de origem. Pode ser fracionado ou somado em vendas futuras por clientes cadastrados ou não.
• RN13: Todo cadastro de pessoa exige, no mínimo, um número de telefone com DDD.
🔄 Histórico de Evolução da Modelagem (v1.0 vs v1.6)

O que foi alterado	Como era (1ª entrega)	Como ficou (versão 1.6)	Por que alteramos
Origem da Dívida	A ficha tinha saldo, mas nenhuma venda se ligava a ela.	Criado o relacionamento gera_debito (Venda amarra o id_ficha_do_cliente).	Crítico: Permitir reconstruir e auditar o saldo a partir das vendas fiadas reais.
Ciclo do Estoque	Produto e Estoque tinham dados sobrepostos e confusos.	Estoque é o item da prateleira (preço e descrição). Produto é o lote físico recebido (validade e lote).	Permitir recebimentos repetidos com validades diferentes sem sobrescrever dados.
Venda Fiada e Caixa	O fluxo misturava a venda com o recebimento do dinheiro no mesmo ato.	Processos separados: Venda gera o débito (sem caixa). Pagamento_Fiado reduz o débito e entra no caixa.	Venda fiada não é entrada imediata de dinheiro; correção do fluxo de caixa.
Entregas Repetidas	Relacionamento direto Fornecedor-Produto, sem distinguir notas sucessivas.	Entrega virou entidade própria (Nota Fiscal única por fornecedor), gerando lotes em Produto.	Crítico: Distinguir notas fiscais e entregas diferentes do mesmo fornecedor e produto.
Herança de Pessoa	Pessoa_Fisica e Pessoa_Juridica tinham IDs próprios e isolados.	Especializações herdam o id_pessoa como PK e FK simultâneas.	Alinhamento com a boa prática técnica de Heuser (2009): evitar chaves duplicadas para a mesma pessoa.			

🔀 Processo Formal de Normalização Relacional

I. Primeira Forma Normal (1FN) — Eliminação de Atributos Multivalorados 

• Problema: A tabela original de pessoas unia vários telefones e e-mails em campos de texto únicos, violando a atomicidade e gerando grupos repetitivos.
• Correção: Criação das tabelas satélites Telefone_Pessoa e Email_Pessoa utilizando chaves primárias compostas unidas à chave de origem id_pessoa.

II. Segunda Forma Normal (2FN) — Eliminação de Dependências Parciais 

• Problema: Dados textuais de catálogo (descricao_produto) e preço de gôndola estavam na tabela de linhas de venda, dependendo apenas do código do item e não da chave composta total.
• Correção: Isolamento do catálogo estável na tabela Estoque. Na tabela associativa Itens_Venda, o preço praticado e o desconto passam a depender da chave composta total (id_venda, id_produto), congelando o histórico da transação.

III. Terceira Forma Normal (3FN) — Eliminação de Dependências Transitivas 

• Problema: A tabela de endereços continha atributos geográficos (rua, bairro, cidade) que dependiam diretamente do CEP, e não do ID identificador do endereço do morador, criando anomalias de atualização transitiva.
• Correção: Isolamento da inteligência de CEPs na tabela externa Localidade, deixando na tabela Endereco_Pessoa apenas as variáveis exclusivas da residência (numero e ponto_referencia).
📊 Indicadores Estratégicos de BI e Potencial para IA

Visão de Business Intelligence (BI)

• Curva de Giro Mensal: Agrupamento de vendas por volume para identificar os 10 produtos mais comercializados, apoiando negociações de custos com fornecedores locais e mitigando rupturas.
• Picos Operacionais: Média quantitativa de cupons fiscais emitidos e agrupados por dias da semana para a correta organização das escalas de funcionários no balcão.
• Sazonalidade do Crédito: Cruzamento de vendas no fiado contra pagamentos de amortização ao longo dos meses para prever riscos de caixa e inadimplência.
