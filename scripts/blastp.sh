set -e

query=$1 # fasta file
output=$2 # output filename
entrez_query=$3 # Entrez query to restrict search. See: https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=BlastHelp#entrez_query

module load blast/2.7.1

blastp -db refseq_protein -query ${query} -remote -entrez_query ${entrez_query} -evalue 1e-20 -out ${output}  # -outfmt 10
