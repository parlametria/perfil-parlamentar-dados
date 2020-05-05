# Dados usados pelo Perfil Parlamentar

Este documento tem o objetivo de apresentar informações iniciais sobre os dados processados pelo Perfil Parlamentar e usados na aplicação [perfil.parlametria.org](perfil.parlametria.org). 

Todos os CSV's aqui descritos fazem parte 

## Descrição dos CSV's

- **[aderencia.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/aderencia.csv)**: CSV com informações sobre como os parlamentares seguiram a orientação de seus partidos (ou do Governo (id = 0)) nas votações nominais realizadas em plenário e capturadas pelo Perfil Parlamentar.

- **[atividades_economicas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/atividades_economicas.csv)**: CSV com lista das atividades econômicas (CNAE's) e seus respectivos ID's.

- **[atividades_economicas_empresas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/atividades_economicas_empresas.csv)**: CSV com ligação entre empresas (CNPJs) e atividades econômicas (id_atividade_economica). A Atividade econômica das empresas são os CNAE's (primário e secundários) nas quais as empresas podem atuar.

- **[comissoes.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/comissoes.csv)**: CSV com a lista de comissões permanentes capturadas e usadas pelo Perfil Parlamentar. Apresenta informações das comissões na Câmara e no Senado.

- **[composicao_comissoes.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/composicao_comissoes.csv)**: CSV com a composição das comissões permanentes na Câmara e no Senado. Apresenta a lista de parlamentares e seus respectivos cargos nas comissões.

- **[empresas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/empresas.csv)**: CSV com informação das Razões Sociais das empresas (cnpj) que possuem parlamentares como sócios ou que possuem sócios que doaram para parlamentares durante as eleições de 2018.

- **[empresas_parlamentares.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/empresas_parlamentares.csv)**: CSV com informação da ligação entre os parlamentares e as empresas nas quais o parlamentar é sócio.

- **[investimento_partidario.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/investimento_partidario.csv)**: CSV com informações do total investido por um partido em uma determinada UF nas eleições de 2018. Contém informação da esfera (câmara, senado) e da quantidade de candidatos que o partido aplicou dinheiro na campanha.

- **[investimento_partidario_parlamentar.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/investimento_partidario_parlamentar.csv)**: CSV com lista de parlamentares e informações de quanto o partido investiu na campanha eleitoral de 2018 desses parlamentares.

- **[liderancas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/liderancas.csv)**: CSV com lista de lideranças de partidos e bloco partidários na Câmara e no Senado.

- **[ligacoes_economicas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/ligacoes_economicas.csv)**: CSV com ligação entre parlamentar e setor econômico através das doações de sócios de empresas desses setores econômicos na campanha eleitoral de 2018.

- **[mandatos.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/mandatos.csv)**: CSV com o histório de mandatos dos parlamentares nas casas legislativas (Câmara e Senado). 

- **[orientacoes.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/orientacoes.csv)**: CSV com as orientações dos partidos e do Governo nas votações nominais realizadas em plenário e monitoradas pelo Perfil Parlamentar.

- **[parlamentares.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/parlamentares.csv)**: CSV com lista de parlamentares da legislatura 55 e 56 com informações detalhadas do parlamentar. Cada linha deste CSV é um parlamentar identificado pela coluna id_parlamentar_voz. **id_parlamentar_voz** é uma coluna formada pela concatenação do id da casa (1 para câmara, 2 para senado) e o id externo do parlamentar na respectiva casa (este id externo é capturado das APIs da Câmara e do Senado).

- **[partidos.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/partidos.csv)**: CSV com lista de partidos dos parlamentares analisado no Perfil Parlamentar. Contém o id do partido e a sigla do mesmo.

- **[perfil_mais.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/perfil_mais.csv)**: CSV com índices calculados para o parlamentar. Os índices envolvem o peso político (peso_politico) do parlamentar que considera o nível de influência política do parlamentar no Congresso considerando: liderança em partidos, cargos em comissões, cargos na mesa, mandatos, investimento do partido durante a eleição.

- **[proposicoes.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/proposicoes.csv)**: CSV com lista de proposições analisadas pelo Perfil Parlamentar.

- **[proposicoes_temas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/proposicoes_temas.csv)**: CSV com a relação entre proposições e seus respectivos temas no Perfil. Uma proposição pode estar associada a mais de um tema.

- **[temas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/temas.csv)**: CSV com lista de temas analisados pelo Perfil Parlamentar.

- **[votacoes.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/votacoes.csv)**: CSV com a lista de votações nominais de plenário monitoradas pelo perfil. Contém informações específicas da votação como o objeto e o horário de votação.

- **[votos.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/votos.csv)**: CSV com todos os votos dos parlamentares nas votações nominais realizadas em plenário e monitoradas pelo Perfil.

### CSV's deprecated

- **[candidatos.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/candidatos.csv)**: (deprecated) CSV com candidatos ao Congresso Nacional em 2018. Este CSV não é mais usado pela aplicação.

- **[perguntas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/perguntas.csv)**: (deprecated) CSV com informações das perguntas feitas no questionário do Perfil Parlamentar. Hoje não é mais usado pela aplicação.

- **[respostas.csv](https://github.com/parlametria/perfil-parlamentar-dados/blob/master/bd/data/respostas.csv)**: (deprecated) CSV com informações das respostas feitas com relação as perguntas do questionário do Perfil Parlamentar. Hoje não é mais usado pela aplicação.


## Contribua

Estes foram os dados principais gerados pelos repositórios do projeto Perfil Parlamentar. Outros CSVs presentes no respositório, não descritos nesse documentos, tratam-se de dados intermediários, que são usados no fluxo de processamento dos dados do Perfil Parlamentar (adicionar link para o site).

[Contribuições](https://github.com/parlametria/perfil-parlamentar-dados) a esta documentação são bem-vindas! 

