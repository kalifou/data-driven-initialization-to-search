#!/bin/bash/

rm summary.GA.rand.36.log
rm summary.EA.rand.36.log
rm summary.AgingEvol.rand.36.log

rm summary.GA.rand.108.log
rm summary.EA.rand.108.log
rm summary.AgingEvol.rand.108.log


rm summary.GA.centroids.36.log
rm summary.EA.centroids.36.log
rm summary.AgingEvol.centroids.36.log

rm summary.GA.centroids.108.log
rm summary.EA.centroids.108.log
rm summary.AgingEvol.centroids.108.log


rm summary.GA.lhs.36.log
rm summary.EA.lhs.36.log
rm summary.AgingEvol.lhs.36.log

rm summary.GA.lhs.108.log
rm summary.EA.lhs.108.log
rm summary.AgingEvol.lhs.108.log

rm summary.RS.rand.36.log
rm summary.RS.rand.108.log



rm log.GA.rand.36.log
rm log.EA.rand.36.log
rm log.AgingEvol.rand.36.log

rm log.GA.rand.108.log
rm log.EA.rand.108.log
rm log.AgingEvol.rand.108.log


rm log.GA.centroids.36.log
rm log.EA.centroids.36.log
rm log.AgingEvol.centroids.36.log

rm log.GA.centroids.108.log
rm log.EA.centroids.108.log
rm log.AgingEvol.centroids.108.log


rm log.GA.lhs.36.log
rm log.EA.lhs.36.log
rm log.AgingEvol.lhs.36.log

rm log.GA.lhs.108.log
rm log.EA.lhs.108.log
rm log.AgingEvol.lhs.108.log

rm log.RS.rand.36.log
rm log.RS.rand.108.log


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



############ Aging Evol





for f in AgingEvol.rand.36*
do 
    tail -n 1 "$f" >> summary.AgingEvol.rand.36.log
    tail -n 2002 "$f" | head -n 2000 >> log.AgingEvol.rand.36.log
done

for f in AgingEvol.rand.108*
do 
    tail -n 1 "$f" >> summary.AgingEvol.rand.108.log
    tail -n 2002 "$f" | head -n 2000 >> log.AgingEvol.rand.108.log
done




for f in AgingEvol.centroids.36*
do 
    tail -n 1 "$f" >> summary.AgingEvol.centroids.36.log
    tail -n 2002 "$f" | head -n 2000 >> log.AgingEvol.centroids.36.log
done

for f in AgingEvol.centroids.108*
do 
    tail -n 1 "$f" >> summary.AgingEvol.centroids.108.log
    tail -n 2002 "$f" | head -n 2000 >> log.AgingEvol.centroids.108.log
done


for f in AgingEvol.lhs.36*
do 
    tail -n 1 "$f" >> summary.AgingEvol.lhs.36.log
    tail -n 2002 "$f" | head -n 2000 >> log.AgingEvol.lhs.36.log
done

for f in AgingEvol.lhs.108*
do 
    tail -n 1 "$f" >> summary.AgingEvol.lhs.108.log
    tail -n 2002 "$f" | head -n 2000 >> log.AgingEvol.lhs.108.log
done


############## LHS init


for f in GA.lhs.36*
do 
    tail -n 1 "$f" >> summary.GA.lhs.36.log
    tail -n 107 "$f" | head -n 105 >> log.GA.lhs.36.log
done

for f in EA.lhs.36*
do 
    tail -n 1 "$f" >> summary.EA.lhs.36.log
    tail -n 107 "$f" | head -n 105 >> log.EA.lhs.36.log
done

for f in GA.lhs.108*
do 
    tail -n 1 "$f" >> summary.GA.lhs.108.log
    tail -n 107 "$f" | head -n 105 >> log.GA.lhs.108.log
done

for f in EA.lhs.108*
do 
    tail -n 1 "$f" >> summary.EA.lhs.108.log
    tail -n 107 "$f" | head -n 105 >> log.EA.lhs.108.log
done

############### Random Search



for f in RS.rand.36*
do 
    tail -n 1 "$f" >> summary.RS.rand.36.log
done

for f in RS.rand.108*
do 
    tail -n 1 "$f" >> summary.RS.rand.108.log
done

