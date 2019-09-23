#!/bin/bash

echo "Downloading data"
for ano in 2018; do 
	echo "Fetching year $ano"
	curl -o bem_candidato_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/bem_candidato/bem_candidato_${ano}.zip
  unzip -j bem_candidato_${ano}.zip bem_candidato_2018_BRASIL.csv -d .
  rm bem_candidato_${ano}.zip

  curl -o consulta_cand_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_${ano}.zip
  unzip -j consulta_cand_${ano}.zip consulta_cand_2018_BRASIL.csv -d .
  rm consulta_cand_${ano}.zip
  
done