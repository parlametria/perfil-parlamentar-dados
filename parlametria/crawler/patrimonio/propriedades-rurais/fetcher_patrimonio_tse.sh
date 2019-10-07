#!/bin/bash

echo "Downloading data"

mkdir ../../../raw_data/dados_tse/
cd ../../../raw_data/dados_tse/

for ano in 2018; do 
	echo "Fetching year $ano"
	curl -o bem_candidato_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/bem_candidato/bem_candidato_${ano}.zip
  unzip -j bem_candidato_${ano}.zip bem_candidato_${ano}_BRASIL.csv -d .
  zip -r bem_candidato_${ano}_BRASIL.csv.zip bem_candidato_${ano}_BRASIL.csv
  rm bem_candidato_${ano}.zip
  rm bem_candidato_${ano}_BRASIL.csv

  curl -o consulta_cand_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_${ano}.zip
  unzip -j consulta_cand_${ano}.zip consulta_cand_${ano}_BRASIL.csv -d .
  zip -r consulta_cand_${ano}_BRASIL.csv.zip consulta_cand_${ano}_BRASIL.csv
  rm consulta_cand_${ano}.zip
  rm consulta_cand_${ano}_BRASIL.csv
done