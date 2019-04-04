# Módulo Deputados Federais

## Como exportar somente os dados dos deputados federais

Para gerar o csv de com informações de deputados é necessário usar o script `export_deputados.R`

Para isso execute:

```
Rscript export_deputados.R
```

Neste caso o caminho de saída default utilizado é `../../raw_data/deputados.csv`. Caso você queira alterar o caminho para a saída do arquivo, utilize o seguinte comando:

```
Rscript export_deputados.R -o ./output.csv
```

Troque `./output.csv` por um caminho da sua preferência.

Após a execução do script o csv será gerado no caminho especificado.