#!/bin/bash/

rm summary.GA.rand.36.log
rm summary.EA.rand.36.log
rm summary.GA.rand.108.log
rm summary.EA.rand.108.log

rm summary.GA.centroids.36.log
rm summary.EA.centroids.36.log
rm summary.GA.centroids.108.log
rm summary.EA.centroids.108.log

rm log.GA.rand.36.log
rm log.EA.rand.36.log
rm log.GA.rand.108.log
rm log.EA.rand.108.log

rm log.GA.centroids.36.log
rm log.EA.centroids.36.log
rm log.GA.centroids.108.log
rm log.EA.centroids.108.log


for f in GA.rand.36*
do 
    tail -n 1 "$f" >> summary.GA.rand.36.log
    tail -n 107 "$f" | head -n 105 >> log.GA.rand.36.log
done

for f in EA.rand.36*
do 
    tail -n 1 "$f" >> summary.EA.rand.36.log
    tail -n 107 "$f" | head -n 105 >> log.EA.rand.36.log
done

for f in GA.rand.108*
do 
    tail -n 1 "$f" >> summary.GA.rand.108.log
    tail -n 107 "$f" | head -n 105 >> log.GA.rand.108.log
done

for f in EA.rand.108*
do 
    tail -n 1 "$f" >> summary.EA.rand.108.log
    tail -n 107 "$f" | head -n 105 >> log.EA.rand.108.log
done




for f in GA.centroids.36*
do 
    tail -n 1 "$f" >> summary.GA.centroids.36.log
    tail -n 107 "$f" | head -n 105 >> log.GA.centroids.36.log
done

for f in EA.centroids.36*
do 
    tail -n 1 "$f" >> summary.EA.centroids.36.log
    tail -n 107 "$f" | head -n 105 >> log.EA.centroids.36.log
done

for f in GA.centroids.108*
do 
    tail -n 1 "$f" >> summary.GA.centroids.108.log
    tail -n 107 "$f" | head -n 105 >> log.GA.centroids.108.log
done

for f in EA.centroids.108*
do 
    tail -n 1 "$f" >> summary.EA.centroids.108.log
    tail -n 107 "$f" | head -n 105 >> log.EA.centroids.108.log
done

