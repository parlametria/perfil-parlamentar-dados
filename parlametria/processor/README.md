## Processor

### Submódulo Indíce de ativismo ambiental
Este submódulo é responsável por cruzar os dados de parlamentares que possuem algum ativismo ambiental, segundo diversos critérios que envolvem participação em frentes progressistas e ruralistas, número de proposições feitas sobre meio ambiente e de requerimentos de informação relacionados à agricultura e meio ambiente, sua adêrencia ao meio ambiente e o quão a favor do meio ambiente cada parlamentar discursa.

O arquivo `processor_indice_ativismo_ambiental.R` é o responsável por conter as funções que cruzam e disponibilizam esses dados.

### Submódulo Influência Parlamentar
Este submódulo é responsável por cruzar dados relacionados a atuação do parlamentar em sua casa de exercício. Agrupa um conjunto de informações sobre o parlamentar e suas relações para contruir um índice de influência parlamentar.

O arquivo `processor_influencia_parlamentar.R` é o responsável por conter as funções que cruzam e disponibilizam esses dados.

### Submódulo Indíce de vínculo com o Agro
Este submódulo é responsável por cruzar os dados de parlamentares relacionados ao Agronegócio segundo diversos critérios que envolvem posse de propriedades rurais, presença em sociedade de empresas agrícolas, porcentagem de doações recebidas do setor durante a campanha eleitoral, dentre outras.

O arquivo `processor_indice_vinculo_agro.R` é o responsável por conter as funções que cruzam e disponibilizam esses dados.

### Submódulo Informações Básicas dos parlamentares
Este submódulo é responsável por coletar informações básicas dos parlamentares atualmente em exercício.

### Submódulo Grupos Parlametria
Este submódulo é responsável por cruzar informações de todos os submódulos acima citados para consolidar as informações sobre deputados. Também classifica os deputados em grupos de acordos com seus índices.
