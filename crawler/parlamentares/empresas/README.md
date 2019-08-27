## Módulo de empresas exportadoras segundo o Ministério da Economia

Este módulo é responsável por tratar os dados de empresas exportadoras segundo o Ministério da Economia.

http://www.mdic.gov.br/index.php/comercio-exterior/estatisticas-de-comercio-exterior/empresas-brasileiras-exportadoras-e-importadoras

A função `process_empresas_exportadoras` presente no arquivo `process_empresas_exportadoras.R` descompacta e trata os dados presente no arquivo exportadoras.zip. O retorno da função é o dataframe concatenado de todos os anos de 1997 até 2019.

Os dados brutos que são usados como input para a função `process_empresas_exportadoras` pode ser baixado [aqui](https://drive.google.com/file/d/1m47jEmClrxSyCQLh1jMqmkAEjfuLyJ9Y/view?usp=sharing). Salve o arquivo no mesmo diretório deste README e então a função poderá ser executada.