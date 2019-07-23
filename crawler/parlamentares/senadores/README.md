# Módulo Senadores

## Como exportar somente os dados dos Senadores

Para gerar o csv de com informações de Senadores é necessário usar o script `export_senadores.R`

Para isso execute:

```
Rscript export_senadores.R
```

Neste caso o caminho de saída default utilizado é `crawler/raw_data/senadores.csv`. Caso você queira alterar o caminho para a saída do arquivo, utilize o seguinte comando:

```
Rscript export_deputados.R -o ./output.csv
```

Troque `./output.csv` por um caminho da sua preferência.

Após a execução do script o csv será gerado no caminho especificado.