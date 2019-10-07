#!/bin/bash

echo "Downloading data..."

mkdir ../../../raw_data/dados_tse/
cd ../../raw_data/dados_tse/

for ano in 2018; do 
	echo "Fetching year $ano"
  curl -o prestacao_de_contas_eleitorais_candidatos_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/prestacao_contas/prestacao_de_contas_eleitorais_candidatos_${ano}.zip
  unzip -j prestacao_de_contas_eleitorais_candidatos_2018.zip receitas_candidatos_2018_BRASIL.csv -d .
  zip -r receitas_candidatos_${ano}_BRASIL.csv.zip receitas_candidatos_${ano}_BRASIL.csv
  rm prestacao_de_contas_eleitorais_candidatos_${ano}.zip
  rm receitas_candidatos_${ano}_BRASIL.csv
  
  curl -o consulta_cand_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_${ano}.zip
  unzip -j consulta_cand_${ano}.zip consulta_cand_${ano}_BRASIL.csv -d .
  zip -r consulta_cand_${ano}_BRASIL.csv.zip consulta_cand_${ano}_BRASIL.csv
  rm consulta_cand_${ano}.zip
  rm consulta_cand_${ano}_BRASIL.csv
  

done

for ano in 2014; do
	echo "Fetching year $ano"
	curl -o prestacao_de_contas_eleitorais_candidatos_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/prestacao_contas/prestacao_final_${ano}.zip
  unzip -j prestacao_de_contas_eleitorais_candidatos_${ano}.zip receitas_candidatos_${ano}_brasil.txt -d .
  zip -r receitas_candidatos_${ano}_brasil.txt.zip receitas_candidatos_${ano}_brasil.txt
  rm prestacao_de_contas_eleitorais_candidatos_${ano}.zip
  rm receitas_candidatos_${ano}_brasil.txt

  curl -o consulta_cand_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_${ano}.zip
  unzip -j consulta_cand_${ano}.zip consulta_cand_${ano}_BRASIL.csv -d .
  zip -r consulta_cand_${ano}_BRASIL.csv.zip consulta_cand_${ano}_BRASIL.csv
  rm consulta_cand_${ano}.zip
  rm consulta_cand_${ano}_BRASIL.csv

done