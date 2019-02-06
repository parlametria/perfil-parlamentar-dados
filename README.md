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

A partir de agora será possível acessar e utilizar o banco de dados Postgres.

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
