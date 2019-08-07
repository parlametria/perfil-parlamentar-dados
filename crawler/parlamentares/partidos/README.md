# Módulo Partidos

## Como exportar os dados de partidos políticos dos parlamentares

Para gerar o csv de com informações de partidos políticos dos parlamentares é necessário usar o script `export_partidos.R`

Para isso execute:

```
Rscript export_partidos.R -o <output_path>
```
Com os seguintes argumentos:
     * `-o <output_path>`: Caminho para o arquivo de saída do csv contendo os dados dos mandatos dos candidatos. O caminho default é "../raw_data/partidos.csv"
     
Após a execução do script o csv será gerado no caminho especificado.