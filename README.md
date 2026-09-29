## 13 a 14. Modelos Conceituais e Capturas do DER

### 📒 Bloco 1: Controle do Caderno de Fiado e Vendas (Lado Esquerdo Superior)
![Controle de Fiado e Vendas](imagens/01_esquerdo_superior.png)
*   **Descrição do Bloco:** Gerencia a rotina do fiado e a abertura de cupons. O `cliente` conecta-se à `Ficha_do_Cliente` na cardinalidade (0,N), indicando que acumula fichas antigas pagas no histórico, respeitando o limite de R\$ 120,00 na atual. A ficha conecta-se ao `Pagamento_Fiado` como (1,N) para permitir amortizações parciais. A `Venda` (cabeçalho) conecta-se a `itens_venda` como (1,N), funcionando como a abertura de itens do cupom fiscal.

### 📦 Bloco 2: Estrutura do Estoque e Devoluções de Clientes (Lado Direito Superior)
![Estoque e Devoluções de Clientes](imagens/02_direito_superior.png)
*   **Descrição do Bloco:** Controla o saldo de mercadorias e o pós-venda. A entidade associativa `itens_venda` conecta-se ao `Estoque` para realizar a baixa automática das quantidades de balcão. Caso o cliente solicite uma troca, o processo gera um registro em `devolucao_troca` (cabeçalho) que se divide em `itens_devolvidos` (corpo) para atualizar o saldo físico real do `Estoque` (especificando quantidades e defeitos).

### 👥 Bloco 3: Gestão de Pessoas, Papéis e Fornecedores (Lado Esquerdo Inferior)
![Gestão de Pessoas e Fornecedores](imagens/03_esquerdo_inferior.png)
*   **Descrição do Bloco:** Organiza a base cadastral da mercearia. A entidade pai `Pessoa` guarda os dados de contato e endereço. Dela nascem as heranças de `Pessoa_Fisica` e `Pessoa_Juridica`. Usamos o modelo tradicional de Peter Chen com relacionamentos 1:1 (`compra como`, `atua como` e `fornece como`) para definir os papéis de `cliente`, `Funcionario` e `Fornecedor`, garantindo a função de cada um no sistema.

### 🚚 Bloco 4: Hierarquia de Produtos e Abastecimento (Lado Direito Inferior)
![Hierarquia de Produtos e Abastecimento](imagens/04_direito_inferior.png)
*   **Descrição do Bloco:** Controla as compras e a classificação das mercadorias. O `Fornecedor` e o `Produto` conectam-se através da entidade associativa `Fornece - entrega` para registrar as Notas Fiscais e abastecer o `Estoque`. Os produtos são classificados de forma organizada: o `Estoque` conecta-se à `Sub_categoria` (`Contem`), e a `Sub_categoria` conecta-se à `Categoria` (`tem`), deixando o inventário perfeito.
