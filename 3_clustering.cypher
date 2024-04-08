// Question: Cluster constructor based on the total points.

// K-Means Clustering
// ref: 
// https://neo4j.com/docs/graph-data-science/current/algorithms/kmeans/

// (c: Custructor)

// 1-init total_point
MATCH (c:Constructor)
 SET c.total_point = [0.0]
RETURN c

// 2-Sum and update points
MATCH ()<-[r:FINISHED]- (d:Driver) -[:BELONGS_TO]-> (c:Constructor)
WITH c, toFloat(SUM(r.points)) AS total_point
 SET c.total_point = [total_point]
RETURN c

// 3--Drop Graph
CALL gds.graph.drop('Constructor') YIELD graphName

// 3-Create Graph
CALL gds.graph.project(
  'Constructor',
  {
    Constructor: {
      properties: 'total_point'
    }
  },
  '*'
)

// 4-k-mean clustering
CALL gds.kmeans.stream(
  'Constructor', 
  {
    nodeProperty: 'total_point',
    k: 3,
    randomSeed: 42
  }
)
YIELD nodeId, communityId
RETURN
  communityId,
  gds.util.asNode(nodeId).team AS Team, 
  toFloat(gds.util.asNode(nodeId).total_point[0]) AS Points
ORDER BY Points DESC
