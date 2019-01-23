# Atualizar dados da pasta csv
1. Transforme os jsons (candidatos, perguntas, proposições e votações) das pastas de dados e da pasta de congresso em csv
2. Utilize o script de tratamento de dados tratamento_dados.R para modificar as tabelas para inserção das mesmas no banco  

## Preparando banco local 

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

## Criar dump local

pg_dump -U postgres vozativa > voz-ativa.dump -Fc 

## Upload para s3 e criar url do aws
fazer upload do dump no s3 e depois criar a url com o comando:

aws s3 presign s3://fotoscandidatos2018/voz-ativa.dump

## Upload no heroku

heroku pg:backups:restore 'aws-link' DATABASE_URL --app voz-ativa

