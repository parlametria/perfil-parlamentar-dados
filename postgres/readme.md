# Sobre os Dados
- raw-data: contém os csvs que foram obtidos através dos jsons de Candidatos, perguntas, proposições e votações.
- data: contém os csvs que irão ser carregados no banco de dados. Estes csvs são resultado do tratamento utilizando o script `process-data-lib.R`, que possui como entrada os csvs disponíveis no diretório raw-data. Mais detalhes sobre como gerar os dados do diretório `data` no [tópico final](#como-realizar-o-tratamento-dos-dados) deste README.

# Como iniciar o banco de dados local

## Usando docker + Postgres

Com o [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) e o [docker-compose](https://docs.docker.com/compose/install/) instalados na sua máquina execute (no mesmo diretório deste readme):

```
docker-compose up
```

Crie as tabelas
```
docker-compose exec db psql -U postgres -d vozativa -1 -f /scripts/create-table-bd-vozativa.sql
```

Importe os dados
```
docker-compose exec db psql -U postgres -d vozativa -1 -f /scripts/import-csv-bd-vozativa.sql
```

Você será capaz de acessar o banco via psql através do comando:
```
psql -h localhost -U postgres --dbname vozativa
```

A senha padrão local é: `secret`

### Como mudar a senha

Desfaça o que foi feito no tópico anterior
```
docker-compose down --volumes
```

crie um arquivo .env no mesmo diretório do arquivo `docker-compose.yml` com o seguinte conteúdo

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
psql --username <seu-user> --dbname <seu-database> < create-table-bd-vozativa.sql
```
4. O próximo passo é importar os CSV's para o banco local. Você pode fazer isso individualmente para cada CSV ou executar um script para fazer isso automaticamente (Escolha um dos dois):

- 4.1 Método Individual
```
psql --username <seu-user> --dbname <seu-database> -c "\copy <nome-tabela> FROM '<caminho-para-csv>' DELIMITER ',' CSV HEADER;"
```

Para o csv de Temas que está no diretório `./final/`,  considerando o local deste readme, o comando seria
```
psql --username <seu-user> --dbname <seu-database> -c "\copy <nome-tabela> FROM '<caminho-para-csv>' DELIMITER ',' CSV HEADER;"
```

- 4.2 Método automático (com script)

Primeiro gere o script de importação usando Rscript `import-data.R`

Exemplo:
```
Rscript import-data.R -f final/ -o import-csv-bd-vozativa.sql
```

-f: define o diretório que contém os CSV's.
-o: define o arquivo de saída com o script .sql que poderá ser executado para importação dos dados.

Por fim execute o arquivo criado com o seguinte comando:

```
psql --username <seu-user --dbname <seu-database> < import-csv-bd-vozativa.sql
```

Obs: Substitua import-csv-bd-vozativa.sql pelo nome do arquivo gerado pelo Rscript executado anteriormente caso você tenha alterado.

# Como realizar o tratamento dos dados

Como falado no início deste README, os dados presentes no diretório `data` são os que contém a versão mais atual das tabelas que devem ser criadas no banco. Para atualizá-los é preciso executar as funções que transformam e tratam os "dados brutos" contidos em `raw-data`. Portanto, se os dados em `raw-data` mudarem então faz-se necessário que a atualização dos dados em `data` também deverá ocorrer. Para isto, siga os passos.

Todas as funções que tratam os dados de forma individual estão presentes no arquivo `process-data-lib.R`. Para executá-las de uma só vez utilize o script helper criado para este fim, fazendo:

```
Rscript trata-dados-bd.R
```

# Deploy no Heroku [deprecated]

## Criar dump local

pg_dump -U postgres vozativa > voz-ativa.dump -Fc 

## Upload para s3 e criar url do aws
fazer upload do dump no s3 e depois criar a url com o comando:

aws s3 presign s3://fotoscandidatos2018/voz-ativa.dump

## Upload no heroku

heroku pg:backups:restore 'aws-link' DATABASE_URL --app voz-ativa
