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

### Usando nosso Makefile

Inicie o serviço do bando de dados:

```
make up
```

Crie as tabelas e importe os dados:

```
make create
```

Você será capaz de acessar o banco via psql através do comando:
```
psql -h localhost -U postgres -d vozativa
```

A senha padrão local é: `secret`

Mais comandos e informações em: `make help`

### Usando manualmente os comandos do docker-compose

Inicie o serviço do banco de dados:

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
psql -h localhost -U postgres -d vozativa
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