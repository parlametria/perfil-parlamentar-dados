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

O arquivo `respostas.json` é a única coleção necessária.

```
mongoimport --db=voz-ativa --collection=respostas --file=respostas.json --jsonArray
```
