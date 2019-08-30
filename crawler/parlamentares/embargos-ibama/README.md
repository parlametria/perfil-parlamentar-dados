## Módulo de Embargos do IBAMA

Este módulo é responsável por tratar os dados de embargos sancionados pelo IBAMA nos últimos anos.

Os dados foram baixados do site do IBAMA e estão disponíveis para download

https://servicos.ibama.gov.br/ctf/publico/areasembargadas/ConsultaPublicaAreasEmbargadas.php

Para obter as informações tratadas de todos os embargos sancionados pelo IBAMA é possível utilizar a função presente em:

```
process_embargos.R
```

Para exportar os dados de deputados em exercício que possuem embargos no IBAMA execute o arquivo de exportação destes dados fazendo:

```
Rscript export_embargos.R
```
