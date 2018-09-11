# vozativa-monkey-ui

Coletor de respostas do Survey Monkey que alimenta o Voz Ativa.

## Dependências

* Python 3.5.x
* MongoDB


## Instruções

### 1 Baixando as respostas

Configure o arquivo `keys.py` com as credenciais do Survey Monkey e rode o script:

```
main.py
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


