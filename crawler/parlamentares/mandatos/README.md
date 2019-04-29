# Módulo Mandatos

## Como exportar os dados de mandatos dos parlamentares

Para gerar o csv de com informações de mandatos dos parlamentares é necessário usar o script `export_mandatos.R`

Para isso execute:

```
Rscript export_mandatos.R -i <input_path> -o <output_path>
```
Com os seguintes argumentos:
     * `-i <input_path>`: Caminho para o arquivo csv contendo os dados dos parlamentares. O caminho default é "../raw_data/parlamentares.csv"
     * `-o <output_path>`: Caminho para o arquivo de saída do csv contendo os dados dos mandatos dos candidatos. O caminho default é "../raw_data/mandatos.csv"
     
Após a execução do script o csv será gerado no caminho especificado.