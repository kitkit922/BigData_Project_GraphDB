//1. best engine?

MATCH (e:Engine)<-[r1:HAS]-(c:Constructor)<-[r2:BELONGS_TO]-(d:Driver)-[r3:FINISHED]->(g:GrandPrix)
RETURN e.name as Constructor,SUM(r3.points) as Points
ORDER BY SUM(r3.points) DESC