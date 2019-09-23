## Propriedades rurais de Parlamentares

Este módulo recupera e processa dados de propriedades rurais declaradas pelos deputados federais ao TSE nas eleições de 2018.

O módulo é composto por rotinas descritas abaixo:

1. Baixar dados do TSE
```
./fetcher_patrimonio_tse.sh
```

Dois arquivos serão baixados. O primeiro "bem_candidato_2018_BRASIL.csv" é a lista de todos os bens declarados pelos candidatos nas eleições de 2018. O segundo "consulta_cand_2018_BRASIL.csv" contém informações de todos os candidatos das eleições de 2018.

2. Processar dados de propriedades Rurais
```
process_propriedades_rurais.R
```

Classificamos as propriedades rurais e retornamos o dataframe através da função presente neste arquivo

3. Processar dados das propriedades rurais dos deputados em exercício.

```
analyzer_propriedades_rurais.R
```

Processa os dados de propriedades rurais dos deputados atualmente em exercício.

4. Exportação dos dados

```
Rscript export_propriedades_rurais.R
```

Rotina responsável pode exportar os dados das propriedades rurais dos deputados atualmente em exercício.


Obs: Para atualizar os dados é necessário executar as rotinas descritas no passo 1 e 4 apenas.