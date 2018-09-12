# vozativa-monkey-ui

Coletor de respostas do Survey Monkey que alimenta o Voz Ativa.

## Dependências

* Python 3.5.x
* MongoDB


## Instruções

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




