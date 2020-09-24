# Módulo de coautorias

Este módulo é responsável pela geração dos nodes e das edges que criam a rede de coautorias para um conjunto de anos e um tema da Câmara selecionado. Alguns dados já processados podem ser encontrados nesta pasta [aqui](https://drive.google.com/drive/folders/1uRsKBQb7vhlRy7mSor9LQcE3Dp1PhGsV?usp=sharing).

A função que gera esses dados está no arquivo `generate_coautorias.R` e é executada da seguinte forma:

```
nodes_edges <- generate_coautorias(anos, tema, parlamentares_datapath)
```

- Com os seguintes parâmetros:
  - `anos`: Lista com os anos de interesse. O valor default é uma lista com os anos 2019 e 2020;

  - `tema`: Tema de interesse das proposições **na Câmara** que se deseja criar a rede. O valor default é 'Meio Ambiente';

  - `parlamentares_datapath`: Caminho para o dataframe de parlamentares. Se nenhum valor for passado, será considerado o csv que está em `crawler/raw_data/parlamentares.csv`.