#!/bin/bash

cd ./analyses/phylogenetic_correlation/host

for f in $(tail -n +2 ../../../data/metadata.csv|awk -F";" '{print $1}'|sort -u); do var=$(grep "${f};" ../../../data/metadata.csv|awk -F";" '{print $8}'); sed -i '' "s/${f}_/${var}_/g" host.pairwise.all.dist; done

for f in $(tail -n +2 ../../../data/metadata.csv|awk -F";" '{print $1}'|sort -u); do var=$(grep "${f};" ../../../data/metadata.csv|awk -F";" '{print $8}'); sed -i '' "s/_${f}/_${var}/g" host.pairwise.all.dist; done

(echo -e "ID,V1,V2,host_dist,sym_dist,symbiont,species" && paste -d "," <(tail -n +2 host.pairwise.all.dist) <(tail -n +2 host.pairwise.all.dist|awk -F"," '{print $1}'|awk -F"_" '{ if ($1 == $2) { print "same"; } else { print "different"; } }')) > host.pairwise.all.dist.species

for f in $(grep same host.pairwise.all.dist.species|awk -F"_" '{print $1}'|sort -u); do for i in $(grep $f host.pairwise.all.dist.species|awk -F"," '{print $6}'|sort -u|grep -v unifrac); do if [[ $(grep same host.pairwise.all.dist.species|grep $f|grep "${i},"|awk -F"," '{print $2}'|sort -u|wc -l) -gt 2 ]] ; then (echo 'ID,V1,V2,host_dist,sym_dist,symbiont,species' && grep same host.pairwise.all.dist.species|grep $f|grep "${i},") > ${f}_${i}; fi; done; done

for f in *_*; do ../../../scripts/mantel_host-vs-symbiont.R --symbiont ${f##*_} --input ${f} --output ${f}_mantel_out; done

for f in $(tail -n +2 host.pairwise.all.dist.species|awk -F"," '{print $6}'|sort -u|grep -v unifrac); do if [[ $(grep -w $f host.pairwise.all.dist.species|awk -F"," '{print $2}'|sort -u|wc -l) -gt 2 ]]; then (echo 'ID,V1,V2,host_dist,sym_dist,symbiont,species' && grep -w $f host.pairwise.all.dist.species) > overall_$f; fi; done

for f in overall_*; do ../../../scripts/mantel_host-vs-symbiont.R --symbiont ${f##*_} --input ${f}  --output ${f}_mantel_out; done

for f in *mantel_out; do paste <(echo -e "host\n${f%%_*}") <(cat $f) > tmp && mv tmp $f; done

(head -n 1 overall_Spiro1_mantel_out &&  for f in $(ls *mantel_out); do tail -n +2 ${f}; done) > mantel_combined