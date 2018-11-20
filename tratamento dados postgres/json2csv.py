import csv, json

fileInput = "../dados/respostas_novo.json"
fileOutput = "./csv/respostas_completo.csv"
inputFile = open(fileInput) #open json file
outputFile = open(fileOutput, 'w') #load csv file
data = json.load(inputFile) #load json content
inputFile.close() #close the input file
output = csv.writer(outputFile) #create a csv.write
output.writerow(data[0].keys())  # header row
for row in data:
    output.writerow(row.values()) #values row
