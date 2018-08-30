# vozativa-monkey-ui

Coletor de respostas do Survey Monkey que alimenta o Voz Ativa.

## Dependências

* Python 3.5.x
* MongoDB


## Instruções

### 1 Baixando as respostas

Configure o arquivo `keys.py` com as credenciais do Survey Monkey, rode os scripts da pasta tse nesta ordem:

```
request_file.py
cria_planilha_tratada.R
escreve_json.py

```
Tendo feito isso poderá ser realizada a requisição dos dados do survey monkey, seguindo esta ordem de scripts:

```
keys4answers2json.py
questions2json.py

monkey2json.py

```

### 2 Povoando o banco de dados

Os arquivos `respostas.json`, `candidatos.json` e `respostas_slim.json` são necessários.

```
mongoimport --db=voz-ativa --collection=respostas --file=respostas_slim.json --jsonArray

mongoimport --db=voz-ativa --collection=respostas_extended --file=respostas.json --jsonArray

mongoimport --db=voz-ativa --collection=candidatos --file=candidatos.json --jsonArray
```

### 3 Povoando o mlab

```
mongoimport -h ds031822.mlab.com:31822 -d <bd> -c <collection> -u <user> -p <password> --file <input file>

```


