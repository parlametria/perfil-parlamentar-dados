## Dados do módulo empresas

- **empresas_doadores.csv**: lista de empresas cujo sócio foi doador para campanha de algum parlamentar em exercício nas eleições de 2018. O identificador do parlamentar que recebeu a doação é a coluna id do dataset. O total doado está na coluna valor_receita. Perceba que existem repetições desse valor para cada CNPJ associado ao doador, todavia a doação pode ter acontecido apenas uma única vez. A replicação existe pois o doador participa como sócio em mais do que uma empresa (CNPJ). Cada observação do dataset é uma empresa cujo sócio indicado doou para um deputado nas eleições de 2018, o valor doado é indicado e pode estar repetido (para cada empresa que o doador é sócio).

- **empresas_doadores_2014.csv**: é o equivalente a descrição anterior, no entanto se refere às eleições de 2014.

- **empresas_doadores_agricolas.csv**: lista de empresas **agrícolas** cujo sócio foi doador para campanha de algum parlamentar em exercício nas eleições de 2018. O identificador do parlamentar que recebeu a doação é a coluna id do dataset. O total doado está na coluna valor_receita. Perceba que existem repetições desse valor para cada CNPJ associado ao doador, todavia a doação pode ter acontecido apenas uma única vez. A replicação existe pois o doador participa como sócio em mais do que uma empresa (CNPJ). Cada observação do dataset é uma empresa cujo sócio indicado doou para um deputado nas eleições de 2018, o valor doado é indicado e pode estar repetido (para cada empresa que o doador é sócio). A classificação de empresas agrícola é feita mediante ao CNAE da empresa. Há também a informações se a empresa é exportadora ou não.

- **empresas_doadores_agricolas_2014.csv**: é o equivalente a descrição anterior, no entanto se refere às eleições de 2014.

- **empresas_doadores_agricolas_raw.csv**: Lista de empresas agrícolas associadas a sócios que doaram para parlamentares durante as eleições.

- **empresas_gerais_doadores_2018.csv**: lista de empresas cujo sócio doou para parlamentares durante as eleições de 2018. Nenhum filtro foi aplicado para classificação das empresas, portanto todos os CNAEs foram considerados. Uma CNPJ pode estar repetido no conjunto de dados se o mesmo tiver mais de um CNAE, para cada CNAE uma nova linha é criada para a empresa.

- **empresas_gerais_doadores_2014.csv**: é o equivalente a descrição anterior, no entanto se refere às eleições de 2014. 

- **empresas_gerais_parlamentares_2018.csv**: Lista de empresas que possuem como sócio um parlamentar atualmente em exercício. Cada observação se refere a um CNAE da empresas que possui o parlamentar como sócio.

- **empresas_info_2018.csv**: lista de empresas que possuem ligações com deputados em 2018 e seus repectivos CNAEs.

- **empresas_parlamentares_agricolas.csv**: lista de empresas **agrícolas** que possuem como sócio algum parlamentar atualmente em exercício. A classificação de empresas agrícolas é feita através do CNAE da empresa na Receita Federal.

- **empresas_parlamentares.csv**: lista de empresas que possuem como sócio algum parlamentar atualmente em exercício.

- **somente_empresas_agricolas_2014.csv**: Lista de empresas **agrícolas** que doaram para campanha nas eleições de 2014 de parlamentares atualmente em exerício (eleitos em 2018).

- **somente_empresas_gerais_2014.csv**: Lista de empresas que doaram para campanha nas eleições de 2014 de parlamentres atualmente em exerício (eleitos em 2018).

- **somente_empresas_gerais_doadoras_2014.csv**: Lista de empresas que doaram para campanha nas eleições de 2014 de parlamentres atualmente em exerício (eleitos em 2018) com informações de qual deputado recebeu a doação dessas empresas.


Os dados brutos utilizados nesse módulo (foram usados para dar origem aos datasets suprecitados) foram processados pelo [Brasil.io](Brasil.io). Também utilizamos a api [Minha Receita](https://github.com/cuducos/minha-receita) feita por Cuducos.