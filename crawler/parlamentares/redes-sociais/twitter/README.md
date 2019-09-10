## Twitter Parlamentares

Este módulo é responsável por capturar e processar dados de tweets de parlamentares do Congresso Nacional

Primeiro configure as credenciais de acesso a API do twitter. 
Para isto crie um arquivo no mesmo diretório deste readme com o nome `config.yml` e o seguinte conteúdo

```
default:
 consumer_key: "<consumer_key>"
 consumer_secret: "<consumer_secret>"
 access_token: "<access_token>"
 access_secret: "<access_secret>"
```

Substitua os valores entre aspas pelas credenciais corretas.

A função que recupera os últimos tweets dos deputados federais em exercício é `process_tweets_deputados` presente em `analyzer_twitter.R`. Esta função recupera os últimos 1000 tweets dos deputados que possuem conta no twitter.

Se preferir execute o arquivo que exporta esses dados de twitter.

```
Rscript export_tweets_parlamentares.R
```