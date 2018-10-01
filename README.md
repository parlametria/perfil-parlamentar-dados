# vozativa-monkey-ui

Coletor de respostas do Survey Monkey que alimenta o Voz Ativa.

## Dependências

- Python 3.5.x
- MongoDB
- pymongo
- R

## Instruções para o Survey Monkey

### 1 Baixando as respostas e povoando mlab de validação

Configure o arquivo `keys.py` com as credenciais do Survey Monkey e rode o script:

```
main.py
```

### 2 Povoando o banco de dados local

Os arquivos `respostas_novo.json` e `candidatos.json` são necessários.

```
mongoimport --db=voz-ativa --collection=respostas --file=respostas_novo.json --jsonArray

mongoimport --db=voz-ativa --collection=candidatos --file=candidatos.json --jsonArray
```

## Instruções para pegar votos dos candidatos à reeleição

Entre na pasta `congresso` pelo terminal e execute o _script_ `pega_votacoes_candidatos_reeleicao.R`.

```
cd congresso
./pega_votacoes_candidatos_reeleicao.R
```

O script demora alguns minutos para ser executado e o arquivo gerado será o `votacoes.csv` dentro da pasta congresso.

Após isso execute os scripts:

```
cd congresso
escreve_json_vot.py 
cd ..
votacoes2db.py
```
Para atualizar o banco de dados das votações dos projetos de lei.