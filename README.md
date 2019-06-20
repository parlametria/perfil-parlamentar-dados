# vozativa-monkey-ui

Coletor de respostas do Survey Monkey que alimenta o Voz Ativa.

# Como iniciar o banco de dados local

Se você já iniciou o banco uma vez basta fazer:

```
docker-compose up
```

Caso contrário siga as instruções a seguir.

## Usando docker + Postgres

No terminal, vá para o diretório **bd**: ```cd bd/```

Com o [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) e o [docker-compose](https://docs.docker.com/compose/install/) instalados na sua máquina execute:

```
docker-compose up --build
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

A partir de agora será possível acessar e utilizar o banco de dados Postgres.

### Como mudar a senha

Desfaça o que foi feito no tópico anterior
```
docker-compose down --volumes
```

Crie o arquivo `.env` no mesmo diretório (/bd) do arquivo `docker-compose.yml` com o seguinte conteúdo

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

## Atualização de dados (heroku)

Para atualização dos dados de forma automatizada, tanto no heroku como localmente, é possível utilizar o docker e scripts de migração criados para este fim. Portanto, se você deseja atualizar os dados do Voz Ativa, seja para adição ou remoção de proposições e atualização do status de parlamentares basta seguir os seguintes passos:

### Instale o docker e docker-compose

- [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce)
- [docker-compose](https://docs.docker.com/compose/install/) 

### Execute o **r-updater**

O **r-updater** é o nosso serviço criado para o fim de obter os dados e atualizá-los no banco de dados do Voz Ativa.

O R-updater exige que algumas variáveis de ambiente estejam disponíveis:
      
| Variável  |  Informações |
|---|---|
| PASSWORD | Exigência da imagem rocker/tidyverse:3.4.4 (pode ser qualquer valor)  |
|  PGHOST |  Endereço do Host do Banco Postgres (o valor é postgres quando se tratar do banco local) |
| PGUSER  | Username do Banco Postgres (o valor é postgres quando se tratar do banco local) |
| PGDATABASE  | Nome do database do Banco Postgres (o valor é vozativa quando se tratar do banco local) |
| PGPASSWORD  | Senha do Banco Postgres (o valor pode ser secret quando se tratar do banco local) |
| APP_SECRET  | Valor do endpoint para envio das mensagens de log para o bot do Voz Ativa no Telegram |


Para configurar essas variáveis de ambiente execute os seguintes passos:

1. Crie um arquivo .env na raiz desse repositório
2. Preencha o arquivo .env com o seguinte conteúdo:

```
R_PASSWORD=secret
POSTGRES_HOST=<host>
POSTGRES_USER=<user>
POSTGRES_DATABASE=<database>
POSTGRES_PASSWORD=<password>
BOT_SECRET=<app-secret-voz-ativa-bot>
```

O docker-compose ficará responsável por interpretar essas variáveis de ambiente.

Após essa configuração basta iniciar o serviço executando (na raiz desse repositório):

```
docker-compose up
```

Pronto! O r-updater já está disponível para utilização. 

### Comandos de atualização

O r-updater provê dois serviços de atualização.

#### Atualização dos dados

Este serviço executa o crawler que obtem os dados do Voz Ativa de diferentes fontes. Para executá-lo basta:

```
docker exec -it r-updater sh -c "Rscript bd/update_data.R"
```
Obs: Esse script apenas atualiza os dados em csv e NÃO executa nenhuma operação no banco de dados.

#### Atualização do banco de dados

Para atualizar efetivamente os dados no Banco Postgres basta executar:

```
docker exec -it r-updater sh -c "cd /app/bd && Rscript update_bd.R"
```

Pronto! A migração foi realizada com sucesso!
