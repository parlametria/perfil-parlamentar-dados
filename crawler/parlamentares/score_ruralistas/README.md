# Módulo Índice de Vínculo Econômico com o Agronegócio

## Como exportar os dados que descrevem um índice de Vínculo Econômico com o agronegócio

Para gerar o csv é necessário usar o script `export_score_ambientalista.R`

Para isso execute:

```
Rscript export_ambientalista.R -o <output_path>
```
Com os seguintes argumentos:
     * `-o <output_path>`: Caminho para o arquivo de saída do csv. O caminho default é "../raw_data/indice_vinculo_economico_agro.csv"
     
Após a execução do script o csv será gerado no caminho especificado.
