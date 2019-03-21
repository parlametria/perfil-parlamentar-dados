# Sobre os Dados
- data: contém os csvs que irão ser carregados no banco de dados. Estes csvs são resultado do tratamento utilizando o script `analyzer_data_bd.R`, que possui como entrada os csvs disponíveis no diretório raw-data (presente no diretório crawler neste repositório). Mais detalhes sobre como gerar os dados do diretório `data` no [tópico final](#como-realizar-o-tratamento-dos-dados) deste README.

# Como iniciar o banco de dados local

Se você já iniciou o banco uma vez basta fazer:

```
docker-compose up
```

Caso contrário siga as instruções a seguir.

## Configurando docker + Postgres

Com o [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) e o [docker-compose](https://docs.docker.com/compose/install/) instalados na sua máquina execute (no mesmo diretório deste readme):

```
docker-compose up
```

Crie as tabelas
```
docker-compose exec db psql -U postgres -d vozativa -1 -f scripts/create_table_bd_vozativa.sql
```

Importe os dados
```
docker-compose exec db psql -U postgres -d vozativa -1 -f scripts/import_csv_bd_vozativa.sql
```

Você será capaz de acessar o banco via psql através do comando:
```
psql -h localhost -U postgres --dbname vozativa
```

A senha padrão local é: `secret`

**A partir de agora será possível acessar e utilizar o banco de dados Postgres para desenvolvimento da aplicação Voz Ativa.**

Outras informações como mudança de senha, uso do banco sem docker, atualização dos dados para outros ambientes (que não permitem a exclusão dos dados) podem ser obtidas no restante deste readme.

### Como mudar a senha

Desfaça o que foi feito no tópico anterior
```
docker-compose down --volumes
```

Crie o arquivo `.env` no mesmo diretório do arquivo `docker-compose.yml` com o seguinte conteúdo

```
POSTGRES_PASSWORD=suasenhasupersecreta
```

Substitua _suasenhasupersecreta_ por uma senha de sua preferência.

Agora volte para o tópico [Usando docker + Postgres](#usando-docker-+-postgres) e repita os procedimentos e tudo deverá funcionar.

#### Comandos úteis

Para visualizar que containers estão executando
```
docker ps
```

Para parar a execução de um container
```
docker kill <id>
```

Para forçar regerar a imagem
```
docker-compose up --build
```

Se você não quiser usar o docker, a alternativa é preparar o banco local como mostrado a seguir.

## Alternativa sem Docker - instalando Postgres localmente

1. Instale o [PostgreSQL](https://www.postgresql.org/download/).
2. Caso for da sua preferência crie um usuário e um database. Você precisará dessas informações. Mais pode ser lido [aqui](https://www.digitalocean.com/community/tutorials/como-instalar-e-utilizar-o-postgresql-no-ubuntu-16-04-pt).
Obs: Se certifique que você consegue acessar o database via linha de comando. ```psql --username <seu-user> --dbname <seu-database>```
3. Crie as tabelas no database usando o seguinte comando:
```
psql --username <seu-user> --dbname <seu-database> < scripts/create_table_bd_vozativa.sql
```
4. O próximo passo é importar os CSV's para o banco local. Você pode fazer isso individualmente para cada CSV ou executar um script para fazer isso automaticamente (Escolha um dos dois):

- 4.1 Método Individual
```
psql --username <seu-user> --dbname <seu-database> -c "\copy <nome-tabela> FROM '<caminho-para-csv>' DELIMITER ',' CSV HEADER;"
```

Para o csv de Temas que está no diretório `./data/`,  considerando o local deste readme, o comando seria
```
psql --username <seu-user> --dbname <seu-database> -c "\copy <nome-tabela> FROM '<caminho-para-csv>' DELIMITER ',' CSV HEADER;"
```

- 4.2 Método automático (com script)

Primeiro gere o script de importação usando Rscript `create_script_import.R`

Exemplo:
```
Rscript create_script_import.R -f data/ -o scripts/import_csv_bd_vozativa.sql
```

-f: define o diretório que contém os CSV's já tratados para inserção no BD.
-o: define o arquivo de saída com o script .sql que poderá ser executado para importação dos dados.

Por fim execute o arquivo criado com o seguinte comando:

```
psql --username <seu-user> --dbname <seu-database> < scripts/import_csv_bd_vozativa.sql
```

Obs: Substitua import_csv_bd_vozativa.sql pelo nome do arquivo gerado pelo Rscript executado anteriormente caso você tenha alterado.

# Como realizar o tratamento/atualização dos dados para o banco de dados

Como falado no início deste README, os dados presentes no diretório `data` são os que contém a versão mais atual das tabelas que devem ser criadas e importadas no BD. Para atualizá-los é preciso executar as funções que transformam e tratam os "dados brutos" contidos em `crawler/raw_data` (caminho relativo a raiz desse repositório). Portanto, se os dados em `crawler/raw_data` mudarem então faz-se necessário que a atualização dos dados em `data` também deverá ocorrer. Para isto, siga os passos.

Todas as funções que tratam os dados de forma individual estão presentes no arquivo `analyzer_data_bd.R`. Para executá-las de uma só vez utilize o script helper criado para este fim, fazendo:

Obs: Só realize este tratamento caso os dados brutos tenham sido alterados. Caso contrário, a versão mais atual dos dados prontos para o BD já estará em `data`.

```
Rscript export_dados_tratados_bd.R
```

# Como atualizar os dados desde o início

**1. Tudo começa com a tabela de proposições**

O dado presente em `crawler/raw-data/tabela_votacoes.csv` contém a lista de proposições e informações sobre o tema da proposição, apelido da proposição, descrição e o id da votação mais importante.

Todas as proposições contidas neste arquivo *tabela_votacoes.csv* são consideradas as atualmente disponíveis e ativas na plataforma Voz Ativa. Logo, se é preciso editar o texto de uma proposição, excluir proposições ou adicionar novas é preciso inicialmente editar este arquivo.

**2. Atualize os votos**

Qualquer alteração de adição ou remoção de proposições na tabela de proposições envolve também a atualização dos dados de votos dos parlamentares para a votação mais importante atrelada a proposição. Para atualizar os votos execute o script *fetcher_votos.R* no módulo de votações. Mais informações sobre a execução desse script podem ser obtidas no readme presente em `crawler/votacoes/readme.md`

```
Rscript fetcher_votos.R
```

**3. Atualize a lista de candidatos**

No módulo de candidatos (`crawler/candidatos`) execute o script *export_info_candidatos_2018.R* para salvar os dados de candidatos a Deputado Federal nas eleições de 2018.

```
Rscript export_info_candidatos_2018.R
```

**4. Atualize os dados de comissões**

No módulo de Comissões (`crawler/parlamentares/comissoes`) execute o script *export_comissoes.R* para salvar os dados de comissões e de suas composições.

```
Rscript export_comissoes.R
```

**5. Tratamento dos dados para o banco de dados**

Com a execução dos passos 1, 2 e 3, os arquivos *tabela_votacoes.csv*, *votacoes.csv* e *candidatos.csv* presentes em `crawler/raw-data/` estarão atualizados de acordo com a nova lista de proposições ativas no Voz Ativa.

Agora é preciso que esses dados sejam alterados para o formato utilizado no banco de dados do Voz Ativa. Para tal processamento basta executar o script *export_dados_tratados_bd.R* presente em `bd/`:

```
Rscript export_dados_tratados_bd.R
```

**Certifique-se que o diretório atual é o `bd/`.**

**6. Atualização do Banco de dados**

5.1 Alteração das Tabelas

Caso já exista um banco de dados executando e você não quer se desfazer dele, será preciso atualizar o schema de dados para a versão atual. Para isto execute (**certifique-se que o diretório atual é o `bd/`.**):

```
psql -h <host> -U <seu-user> -d <seu-database> < scripts/alter_table_vozativa.sql 
```

5.1 Alteração dos Dados

Agora atualize os dados presentes nas tabelas do banco de forma individual executando os seguintes comandos(**certifique-se que o diretório atual é o `bd/`.**):

```
psql -h <host> -U <seu-user> -d <seu-database> < scripts/migrations/migration_temas.sql 
```

```
psql -h <host> -U <seu-user> -d <seu-database> < scripts/migrations/migration_proposicoes.sql 
```

```
psql -h <host> -U <seu-user> -d <seu-database> < scripts/migrations/migration_votacoes.sql 
```

```
psql -h <host> -U <seu-user> -d <seu-database> < scripts/migrations/migration_candidatos.sql 
```

```
psql -h <host> -U <seu-user> -d <seu-database> < scripts/migrations/migration_comissoes.sql 
```

```
psql -h <host> -U <seu-user> -d <seu-database> < scripts/migrations/migration_composicao_comissoes.sql 
```

Caso nenhum erro ocorra, fica garantido que as tabelas agora foram atualizadas com os dados corretos.
