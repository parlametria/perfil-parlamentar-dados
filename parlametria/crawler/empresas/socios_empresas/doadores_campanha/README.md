## Doadores de campanhas que são empresas agrícolas ou sócios de empresas agrícolas
### Uso 
Para baixar as informações de doadores de campanhas eleitorais dos parlamentares, utilize a função `process_socios_empresas_agricolas_doadores(ano, doadores_folderpath, socios_folderpath)`, que se encontra no arquivo `analyzer_socios_empresas_doadores_campanha.R`.

O resultado é uma lista contendo 1 ou 2 dataframes: os doadores que são sócios de empresas agrícolas, caso o parâmetro ano seja maior que 2014. Quando o ano de eleição for menor ou igual a 2014, os dados de empresas agrícolas que doaram também serão retornados.
