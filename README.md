# vozativa-monkey-ui

Coletor de respostas do Survey Monkey que alimenta o Voz Ativa.

## Dependências

* Python 3.5.x
* MongoDB


## Instruções

### 1 Baixando as respostas

Configure o arquivo `keys.py` com as credenciais do Survey Monkey e depois rode os scripts abaixo, nesta ordem:

```
keys4answers2json.py
questions2json.py

monkey2json.py
```

### 2 Povoando o banco de dados

Os arquivos `respostas.json`, `candidatos.json` e `candidatos_slim.json` são necessários.

```
mongoimport --db=voz-ativa --collection=respostas --file=respostas.json --jsonArray

mongoimport --db=voz-ativa --collection=candidatos_extended --file=candidatos.json --jsonArray

mongoimport --db=voz-ativa --collection=candidatos --file=candidatos_slim.json --jsonArray
```

### 3 Povoando o mlab

```
mongoimport -h ds031822.mlab.com:31822 -d <bd> -c <collection> -u <user> -p <password> --file <input file>
```


