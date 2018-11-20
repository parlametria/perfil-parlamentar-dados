# Criar banco local 

1. Criar banco vozativa com o usuário postgres local e executar o script de tratamento de dados para criar as tabelas em csv 
2. Depois usar o script create-table-import.sql para criar as tabelas e importar os csvs no banco local

# Criar dump local

pg_dump -U postgres vozativa > voz-ativa.dump -Fc 

# Upload para s3 e criar url do aws

aws s3 presign s3://fotoscandidatos2018/voz-ativa.dump

# Upload no heroku

heroku pg:backups:restore 'aws-link' DATABASE_URL --app voz-ativa

