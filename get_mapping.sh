mkdir hmp_mappings

wget -O hmp_mappings/ppAll_V13_map.txt http://www.hmpdacc.org/doc/ppAll_V13_map.txt

wget -O hmp_mappings/ppAll_V16_map.tsv http://www.hmpdacc.org/doc/ppAll_V35_map.txt

wget -O hmp_mappings/ppAll_V69_map.tsv http://www.hmpdacc.org/doc/ppAll_V69_map.txt

cat hmp_mappings/ppAll_V13_map.txt > hmp_mappings/unified_map.tsv

sed '1d' hmp_mappings/ppAll_V16_map.tsv  >> hmp_mappings/unified_map.tsv

sed '1d' hmp_mappings/ppAll_V69_map.tsv  >> hmp_mappings/unified_map.tsv

mkdir hmp_metaphlan

wget -O hmp_metaphlan/HMP.ab.txt.bz2 http://downloads.hmpdacc.org/data/HMSMCP/HMP.ab.txt.bz2

mkdir hmp_humann

wget -O hmp_humann/04b-mpm-cop-nul-nve-nul-nve.txt.bz2 http://downloads.hmpdacc.org/data/HMMRC/04b-mpm-cop-nul-nve-nul-nve.txt.bz2

wget -O hmp_humann/04b-mpt-cop-nul-nve-nul-nve.txt.bz2 http://downloads.hmpdacc.org/data/HMMRC/04b-mpt-cop-nul-nve-nul-nve.txt.bz2

bzip2 -d hmp_metaphlan/HMP.ab.txt.bz2

bzip2 -d hmp_humann/04b-mpm-cop-nul-nve-nul-nve.txt.bz2 

bzip2 -d hmp_humann/04b-mpt-cop-nul-nve-nul-nve.txt.bz2 

sed '1d' hmp_humann/04b-mpt-cop-nul-nve-nul-nve.txt | sed '2d' | sed '3d' | sed '5,6d' | sed '1,5!d' | cut -f2- | python requirements/Maaslin/exec/transpose.py > hmp_humann/humann-mappings.tsv

sed '1d' hmp_humann/04b-mpm-cop-nul-nve-nul-nve.txt | sed '2d' | sed '3d' | sed '5,6d' | sed '1,5!d' | cut -f2- | python requirements/Maaslin/exec/transpose.py >> hmp_humann/humann-mappings.tsv

awk '!x[$0]++' hmp_humann/humann-mappings.tsv > hmp_humann/humann-mappings_unique.tsv

# Check out the ipython notebooks for the next steps

awk '!x[$0]++' MetaphlanMapping.tsv > MetaphlanMapping_unique.tsv

awk '!x[$0]++' hmp_mappings/humann_full_map_raw.tsv > HumannMapping_unique.tsv

gzip hmp_mappings/humann_full_map_raw.tsv

cat MetaphlanMapping_unique.tsv >> Map_for_WGS.tsv

cat HumannMapping_unique.tsv >> Map_for_WGS.tsv

awk '!x[$0]++' Map_for_WGS.tsv > Map_for_WGS_unique.tsv

rm hmp_mappings/humann_full_map_raw.tsv.gz