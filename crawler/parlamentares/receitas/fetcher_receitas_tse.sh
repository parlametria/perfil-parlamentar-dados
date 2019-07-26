#!/bin/bash

echo "Downloading data"
for ano in 2018; do 
	echo "Fetching year $ano"
	curl -o prestacao_de_contas_eleitorais_candidatos_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/prestacao_contas/prestacao_de_contas_eleitorais_candidatos_${ano}.zip
  unzip -j prestacao_de_contas_eleitorais_candidatos_${ano}.zip receitas_candidatos_2018_BRASIL.csv -d .
  rm prestacao_de_contas_eleitorais_candidatos_${ano}.zip
done