## Módulo de empresas e sócios de empresas ligados a Parlamentares

Este módulo extrai, processa e retorna dados de empresas ligadas diretamente a parlamentares (como sócios), a doadores de campanha de parlamentares e também aquelas que doaram em campanhas até 2014. O módulo também permite classificar empresas como exportadoras ou não e é focado nas empresas cuja atividade é do ramo agrícola.

A função responsável pelo processamento dos dados é a `process_socios_empresas_agricolas`. A mesma pode retornar um dataframe com informações de **empresas agrícolas** associadas a deputados que são sócios das mesmas; ou um dataframe com informações de empresas agrícolas nas quais o sócio doou para a campanha de um deputado federal em exercício nas eleições de 2018; ou ainda dois dataframes com informações sendo um deles os sócios que doaram na campanha de 2014 para deputados que hoje estão em em exercício e o segundo deles empresas agrícolas (pessoas jurídicas) que doaram para a campanha destes mesmos deputados (até 2014 era permitida a doação de empresas).

### Uso 
Para baixar o csv com as informações dos parlamentares que são sócios de empresas agrícolas, utilize a função `process_socios_empresas_agricolas(ano = 2018, tipo = "parlamentares")` , que se encontra no arquivo `analyzer_empresas.R`.

Para baixar os csv's com as informações dos sócios que doaram para deputados em exercício e empresas que doaram para parlamentares em exercício (para o ano de 2014) utilize a função `process_socios_empresas_agricolas(ano = 2018, tipo = "doadores")` que se encontra no arquivo `analyzer_empresas.R`. O retorno desta função é uma lista que pode conter um dataframe (sócios de empresas que doaram para deputados) ou com dois dataframes (com sócios e com empresas doadoras de campanha).

### Dados necessários

Para recuperar as informações de sócios e doadores de empresas agrícolas é necessário fazer o download e configurar os seguintes passos:

1. Sócios de empresas segundo a Receita Federal do Brasil. Capturado e processado por [Turicas](https://github.com/turicas/socios-brasil); Salve o arquivo de [sócios](https://drive.google.com/open?id=1BYKgmFxSaJgT8JprVAI1AAsH6ZJTOBFo) em `raw_data/socio.csv.gz`
2. Configure a API com Dados da Receita Federal desenvolvida por [Cuducos](https://github.com/cuducos/minha-receita); 

### Empresas exportadoras

Este componente é responsável por tratar os dados de empresas exportadoras segundo o Ministério da Economia.

http://www.mdic.gov.br/index.php/comercio-exterior/estatisticas-de-comercio-exterior/empresas-brasileiras-exportadoras-e-importadoras

A função `process_empresas_exportadoras` presente no arquivo `process_empresas_exportadoras.R` descompacta e trata os dados presente no arquivo exportadoras.zip. O retorno da função é o dataframe concatenado de todos os anos de 1997 até 2019.

Os dados brutos que são usados como input para a função `process_empresas_exportadoras` pode ser baixado [aqui](https://drive.google.com/file/d/1m47jEmClrxSyCQLh1jMqmkAEjfuLyJ9Y/view?usp=sharing). Salve o arquivo no mesmo diretório deste README e então a função poderá ser executada.