set -e

query=$1 # fasta file
output=$2 # output filename
gilist=$3 # gi list of the organism to search against

module load blast/2.7.1

blastn -db nt -gilist ${gilist} -query ${query} -max_hsps 5 -out ${output} -outfmt 10
