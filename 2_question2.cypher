//2. Most RET Driver?

MATCH (d:Driver)-[r:FINISHED]->(g:GrandPrix)
RETURN d.name as Driver,
       COUNT(r.position) as Races, 
       SUM(CASE r.position WHEN "RET" THEN 1 ELSE 0 END) as Retirements
ORDER BY Retirements DESC
LIMIT 5