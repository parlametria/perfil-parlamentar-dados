# Atualizar dados da pasta csv
1. Transforme os jsons (candidatos, perguntas, proposições e votações) das pastas de dados e da pasta de congresso em csv
2. Utilize o script de tratamento de dados tratamento_dados.R para modificar as tabelas para inserção das mesmas no banco  

# Criar banco local 

1. Criar banco vozativa com o usuário postgres local 
2. Depois usar o script create-table-import.sql para criar as tabelas e importar os csvs no banco local

# Criar dump local

pg_dump -U postgres vozativa > voz-ativa.dump -Fc 

# Upload para s3 e criar url do aws
fazer upload do dump no s3 e depois criar a url com o comando:

aws s3 presign s3://fotoscandidatos2018/voz-ativa.dump

# Upload no heroku

heroku pg:backups:restore 'aws-link' DATABASE_URL --app voz-ativa

