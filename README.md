# Perfil Parlamentar Dados

Este repositório contém os módulos de processamento de dados usados pela aplicação [Perfil Parlamentar](perfil.parlametria.org/).

Usamos docker para gerenciar e facilitar a execução dos serviços usados pela aplicação. Portanto, recomendamos fortemente sua instalação:

Instale o [**Docker**](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) e o [**docker-compose**](https://docs.docker.com/compose/install/).

Este repositório contém dois serviços principais:
- **Serviço R (r-updater)**: serviço com código R com módulos para recuperação e processamento dos dados do poder legislativo e gerenciamento da atualização do banco de dados
- **Banco de dados Perfil (db-perfil)**: serviço que levanta um banco local com os dados necessários para o Perfil Parlamentar.

# Como iniciar o banco de dados local?

No terminal, vá para o diretório **bd**: ```cd bd/```

Com o [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) e o [docker-compose](https://docs.docker.com/compose/install/) instalados na sua máquina execute:

```sh
docker-compose up --build
```

Crie as tabelas e importe os dados
```sh
make create
```

Se preferir é possível executar separadamente
1. Crie as tabelas
```sh
docker-compose exec db psql -U postgres -d vozativa -1 -f scripts/create_table_bd_vozativa.sql
```

2. Importe os dados
```sh
docker-compose exec db psql -U postgres -d vozativa -1 -f scripts/import_csv_bd_vozativa.sql
```

<br>
Você será capaz de acessar o banco via psql (se tiver instalado na sua máquina) através do comando:

```sh
psql -h localhost -U postgres -d vozativa
```

A senha padrão local é: `secret`

Ou ainda via container

```sh
docker exec -it postgres psql -h localhost -U postgres -d vozativa
```

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

## Atualização de dados

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
PASSWORD=secret
PGHOST=<host>
PGUSER=<user>
PGDATABASE=<database>
PGPASSWORD=<password>
APP_SECRET=<app-secret-voz-ativa-bot>
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

#### Atualização automática

O r-updater já vem configurado com um job que executa todas as terças às 7 horas da manhã no horário de Recife. Para alterar este horário configure o comando crontab presente no Dockerfile neste mesmo diretório.

## Sobre a arquitetura docker

Optamos neste projeto por separar os serviços (R e Postgres) em duas arquiteturas. Vamos começar pela mais simples

### **Postgres**
Neste módulo criamos um docker-compose que levanta um serviço baseado na imagem **postgres:11.1-alpine**, o container em execução terá o nome **postgres** e terá mapeado os volumes dos diretórios ./data e ./scripts (dentro de **./bd**), também criará um volume específico para persistência do banco de dados (*postgres_data*). Para acessar o container é possível executar:

```sh
docker exec -it postgres bash
```

Então você estará dentro do container postgres.

### **r-updater**

Neste módulo o Dockerfile presente na raiz do repositório contém a instalação das dependências necessárias para execução do processamente do dados. Quaisquer novos pacotes que devem ser instalados devem constar nesse arquivo que monta a imagem baseada em **rocker/tidyverse:3.6.1**.

Outro Dockerfile importante é o de servidor de logs (presente no diretório **bd/server**). O Servidor de logs é baseado no node/express e disponibiliza os logs das migrações realizadas no Banco de dados usando o módulo de gerenciamento de migrações do **r-updater**.

**Lembrete:** sempre que um novo pacote for adicionado como dependência no projeto o mesmo deve ser adicionado como passo na construção da imagem presente no Dockerfile na raiz desse repositório.

O docker-compose na raiz desse repositório orquestra os dois serviços supracitados: r-updater e servidor de logs. Ele também mapeia o código do repositório como volume montado no r-updater. Ou seja, qualquer mudança no código já refletirá dentro do container.

Para acessar o container do servidor de logs:

```
docker exec -it log-server bash
```

Para acessar o container do r-updater:

```
docker exec -it r-updater bash
```

Executar algum script do crawler: 

```
docker exec -it r-updater sh -c "cd /app/crawler && Rscript <caminho para o script pertencente ao diretório crawler>"
```

O repositório está aberto a contribuições :)
Também é bem útil você nos apontar sugestões, críticas ou bugs! Fale com a gente por meio das [issues no Github](https://github.com/parlametria/perfil-parlamentar-dados/issues).
