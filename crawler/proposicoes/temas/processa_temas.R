library(here)
library(tidyverse)

if(!require(optparse)){	
        install.packages("optparse")	
        library(optparse)	
}

option_list <- list(	
        make_option(c("-o", "--output"), 	
                    type="character", 	
                    default=here::here("crawler/proposicoes/temas/"), 	
                    help="diretório de saída [default= %default]", 	
                    metavar="character")	
)	

opt_parser <- OptionParser(option_list=option_list)	

opt <- parse_args(opt_parser)	

output <- opt$output

temas <- data.frame(id_tema = c(0, 1, 2, 3, 5, seq(6, 59, 1), 99),
                    tema = c("Meio Ambiente"
                             ,"Direitos Humanos"
                             ,"Integridade e Transparência"
                             ,"Agenda Nacional"
                             ,"Educação"
                             ,"Administração Pública"                                        
                             ,"Direito Penal e Processual Penal"                             
                             ,"Trabalho e Emprego"                                           
                             ,"Processo Legislativo e Atuação Parlamentar"                   
                             ,"Finanças Públicas e Orçamento"                                
                             ,"Economia"                                                     
                             ,"Defesa e Segurança"                                           
                             ,"Relações Internacionais e Comércio Exterior"                  
                             ,"Política, Partidos e Eleições"                                
                             ,"Indústria, Comércio e Serviços"                               
                             ,"Viação, Transporte e Mobilidade"                              
                             ,"Estrutura Fundiária"                                          
                             ,"Meio Ambiente e Desenvolvimento Sustentável"                  
                             ,"Previdência e Assistência Social"                             
                             ,"Direitos Humanos e Minorias"                                  
                             ,"Energia, Recursos Hídricos e Minerais"                        
                             ,"Direito Civil e Processual Civil"                             
                             ,"Saúde"                                                        
                             ,"Comunicações"                                                 
                             ,"Esporte e Lazer"                                              
                             ,"Arte, Cultura e Religião"                                     
                             ,"Direito e Defesa do Consumidor"                               
                             ,"Cidades e Desenvolvimento Urbano"                             
                             ,"Ciência, Tecnologia e Inovação"                                                                           
                             ,"Defesa do Consumidor"                                         
                             ,"Indústria, Comércio e Serviço"                                
                             ,"Servidores Públicos"                                          
                             ,"Planejamento e Orçamento"                                     
                             ,"Direito Eleitoral e Partidos Políticos"                       
                             ,"Tributação"                                                   
                             ,"Administração Pública: Órgãos Públicos"                       
                             ,"Previdência Social"                                           
                             ,"Política Econômica e Sistema Financeiro"                      
                             ,"Processo Legislativo"                                         
                             ,"Segurança Pública"                                            
                             ,"Desenvolvimento Regional"                                     
                             ,"Organização Político-administrativa do Estado"                
                             ,"Família, Proteção a Crianças, Adolescentes, Mulheres e Idosos"
                             ,"Assistência Social"                                           
                             ,"Licitação e Contratos"                                        
                             ,"Desenvolvimento Social e Combate à Fome"                      
                             ,"Política Urbana"                                              
                             ,"Turismo"                                                      
                             ,"Agricultura, Pecuária e Abastecimento"                        
                             ,"Crédito Extraordinário"                                       
                             ,"Arte e Cultura"                                               
                             ,"Recursos Hídricos"                                            
                             ,"Ciência, Tecnologia e Informática"                            
                             ,"Direito Comercial e Econômico"                                
                             ,"Viação e Transportes"                                         
                             ,"Coronavírus (Covid-19)"                                       
                             ,"Desporto e Lazer"                                             
                             ,"Trânsito"                                                     
                             ,"Minas e Energia"
                             ,"Geral"), 
                    slug = c("meio-ambiente"
                             ,"direitos-humanos"
                             ,"integridade-e-transparencia"
                             ,"agenda-nacional"
                             ,"educacao"
                             ,"administracao-publica"
                             ,"direito-penal-e-processual-penal"
                             ,"trabalho-e-emprego"
                             ,"processo-legislativo-e-atuacao-parlamentar"
                             ,"financas-publicas-e-orcamento"
                             ,"economia"
                             ,"defesa-e-seguranca"
                             ,"relacoes-internacionais-e-comercio-exterior"
                             ,"politica,partidos-e-eleicoes"
                             ,"industria,comercio-e-servicos"
                             ,"viacao,transporte-e-mobilidade"
                             ,"estrutura-fundiaria"
                             ,"meio-ambiente-e-desenvolvimento-sustentavel"
                             ,"previdencia-e-assistencia-social"
                             ,"direitos-humanos-e-minorias"
                             ,"energia,recursos-hidricos-e-minerais"
                             ,"direito-civil-e-processual-civil"
                             ,"saude"
                             ,"comunicacoes"
                             ,"esporte-e-lazer"
                             ,"arte,cultura-e-religiao"
                             ,"direito-e-defesa-do-consumidor"
                             ,"cidades-e-desenvolvimento-urbano"
                             ,"ciencia,tecnologia-e-inovacao"
                             ,"defesa-do-consumidor"
                             ,"industria,comercio-e-servico"
                             ,"servidores-publicos"
                             ,"planejamento-e-orcamento"
                             ,"direito-eleitoral-e-partidos-politicos"
                             ,"tributacao"
                             ,"administracao-publica:-orgaos-publicos"
                             ,"previdencia-social"
                             ,"politica-economica-e-sistema-financeiro"
                             ,"processo-legislativo"
                             ,"seguranca-publica"
                             ,"desenvolvimento-regional"
                             ,"organizacao-politico-administrativa-do-estado"
                             ,"familia,protecao-a-criancas,adolescentes,mulheres-e-idosos"
                             ,"assistencia-social"
                             ,"licitacao-e-contratos"
                             ,"desenvolvimento-social-e-combate-à-fome"
                             ,"politica-urbana"
                             ,"turismo"
                             ,"agricultura,pecuaria-e-abastecimento"
                             ,"credito-extraordinario"
                             ,"arte-e-cultura"
                             ,"recursos-hidricos"
                             ,"ciencia,tecnologia-e-informatica"
                             ,"direito-comercial-e-economico"
                             ,"viacao-e-transportes"
                             ,"coronavirus-(covid-19)"
                             ,"desporto-e-lazer"
                             ,"transito"
                             ,"minas-e-energia"
                             ,"geral"),
                    ativo = c(1, 1, 1, 1, 1, rep(0, 55)),
                    stringsAsFactors = FALSE)

write_csv(temas, paste0(output, "temas.csv"))