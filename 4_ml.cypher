// Question: Whether a relationship exists between a driver and a constructor.
// (d:Driver)-[r:BELONGS_TO]->(c:Constructor)
// ref:
// https://neo4j.com/docs/graph-data-science/current/getting-started/ml-pipeline/

// 1-Drop ml graph
// CALL gds.graph.drop('graph_belongs') YIELD graphName

// 1-Create ml graph
CALL gds.graph.project(
  'graph_belongs',
  ['Driver', 'Constructor'],
  {
    BELONGS_TO: {
      orientation: 'UNDIRECTED'
    }
  }
)

// 2-Drop pipeline
// CALL gds.pipeline.drop('pip_belongs') YIELD pipelineName;

// 2-Create pipline
// Create the pipeline and add it to the pipeline catalog.
CALL gds.beta.pipeline.linkPrediction.create('pip_belongs');

// 3-embedding and add a new node property
CALL gds.beta.pipeline.linkPrediction.addNodeProperty(
  'pip_belongs', 
  'fastRP', 
  {
    mutateProperty: 'embedding',
    embeddingDimension: 256,
    randomSeed: 42
  }
)

// 4-Add Features
// Add the link features (only age here) and a feature type (cosine here).
CALL gds.beta.pipeline.linkPrediction.addFeature(
  'pip_belongs',
  'cosine',
  {
    nodeProperties: ['embedding']
  }
);

// 5-Split train-test
// 	Configure the train-test split and the number of folds for cross-validation.
CALL gds.beta.pipeline.linkPrediction.configureSplit(
  'pip_belongs',
  {
    testFraction: 0.25,
    trainFraction: 0.6,
    validationFolds: 3
  }
);

// 6-Add a model
// Add a model candidate (a logistic regression with no further configuration here).
// CALL gds.beta.pipeline.linkPrediction.addLogisticRegression('pip_belongs');


CALL gds.alpha.pipeline.linkPrediction.addMLP('pip_belongs');
// 7-Create and Train a model
CALL gds.beta.pipeline.linkPrediction.train(
    // 	Name of the projected graph to use for training.
    'graph_belongs',
    {
        pipeline: 'pip_belongs',   // 	Name of the configured pipeline.
        modelName: 'model_belongs',  // Name of the model to train.
        targetRelationshipType: 'BELONGS_TO', // Name of the relationship to train the model on.
        metrics: ['AUCPR']     // Metrics used to evaluate the models (AUCPR here).
    }
)
YIELD modelInfo
RETURN
    modelInfo.bestParameters AS winningModel,       // Parameters of the best performing model returned by the training process.
    modelInfo.metrics.AUCPR.train.avg AS avgTrainScore,         // Evaluated metrics (here for AUCPR) of the best performing model returned by the training process.
    modelInfo.metrics.AUCPR.validation.avg AS avgValidationScore,
    modelInfo.metrics.AUCPR.outerTrain AS outerTrainScore,
    modelInfo.metrics.AUCPR.test AS testScore

// 7-Drop a model
// CALL gds.model.drop('model_belongs') YIELD modelName      

// 7-Create and Train a model
CALL gds.beta.pipeline.linkPrediction.train(
    // 	Name of the projected graph to use for training.
    'graph_belongs',
    {
        pipeline: 'pip_belongs',   // 	Name of the configured pipeline.
        modelName: 'model_belongs',  // Name of the model to train.
        targetRelationshipType: 'BELONGS_TO', // Name of the relationship to train the model on.
        metrics: ['AUCPR']     // Metrics used to evaluate the models (AUCPR here).
    }
)
YIELD modelInfo
RETURN
    modelInfo.bestParameters AS winningModel,       // Parameters of the best performing model returned by the training process.
    modelInfo.metrics.AUCPR.train.avg AS avgTrainScore,         // Evaluated metrics (here for AUCPR) of the best performing model returned by the training process.
    modelInfo.metrics.AUCPR.validation.avg AS avgValidationScore,
    modelInfo.metrics.AUCPR.outerTrain AS outerTrainScore,
    modelInfo.metrics.AUCPR.test AS testScore

// 8-Predict
// Run the prediction in stream mode (return the predicted links as query results).
CALL gds.beta.pipeline.linkPrediction.predict.stream(
    // Name of the projected graph to run the prediction on.
    'graph_belongs',
    {
        modelName: 'model_belongs',     // 	Name of the model to use for prediction.
        topN: 5     // 	Maximum number of predicted relationships to output.
    }
)
YIELD node1, node2, probability
RETURN
    gds.util.asNode(node1).name AS node1,
    gds.util.asNode(node2).name AS node2,
    probability
ORDER BY probability DESC, node1

// https://community.neo4j.com/t/using-neo4j-for-heterogeneous-nodes-link-prediction/67069/1
//  Neo4j for Heterogeneous nodes link prediction.