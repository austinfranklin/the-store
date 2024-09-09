inlets = 1;
outlets = 1;

var grid; // SOM grid
var inputData = []; // Input feature vectors
var rows = 100; // Number of rows in SOM grid
var cols = 100; // Number of cols in SOM grid
var inputDim = 4; // Dimension of the input
var learningRate = 0.1;
var neighborhoodRadius = 5;
var iterations = 1500;
var dictObj; // Dictionary
var dictName = "sampAnalysis"; // Name of your dict object in Max

// Initialize the SOM grid with random weights
function initSOM(inputDimension, numRows, numCols) {
    rows = numRows;
    cols = numCols;
    inputDim = inputDimension;
    
    // Create grid
    grid = [];
    for (var r = 0; r < rows; r++) {
        grid[r] = [];
        for (var c = 0; c < cols; c++) {
            // Initialize each neuron's weights to small random values
            var weights = [];
            for (var d = 0; d < inputDim; d++) {
                weights.push(Math.random());
            }
            grid[r][c] = {weights: weights};
        }
    }
    
    post("SOM Initialized with dimensions: " + numRows + " x " + numCols + " and input size: " + inputDim + "\n");
}

// Load data from a Max dict
function loadInputDataFromDict(dictName) {
    dictObj = new Dict(dictName); // Create a Dict object in JavaScript
    var keys = dictObj.getkeys(); // Get all keys from the dict

    if (keys != null) {
        inputData = []; // Clear previous data
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var featureVector = dictObj.get(key); // Get the feature vector for each key

            // Ensure the featureVector is an array before adding it
            if (Array.isArray(featureVector)) {
                inputData.push(featureVector); // Store the feature vector in inputData array
            } else {
                post("Error: Feature vector for key " + key + " is not an array.\n");
            }
        }

        post("Loaded input data with " + inputData.length + " entries from dict.\n");
    } else {
        post("Error: No keys found in dict.\n");
    }
}

// Train the SOM
function trainSOM(numIterations, lr, neighborhood) {
    learningRate = lr;
    neighborhoodRadius = neighborhood;
    iterations = numIterations;

    for (var i = 0; i < iterations; i++) {
        // Pick a random input vector
        var randomInput = inputData[Math.floor(Math.random() * inputData.length)];

        // Find the best matching unit (BMU)
        var bmu = findBMU(randomInput);

        // Update the BMU and its neighbors
        updateWeights(bmu, randomInput);

        // Optionally, decrease the learning rate and neighborhood size over time
        learningRate *= 0.99;
        neighborhoodRadius *= 0.99;
    }
    
    post("Training complete.\n");
}

// Find the Best Matching Unit (BMU) for a given input vector
function findBMU(inputVector) {
    var bmu = {row: 0, col: 0};
    var minDistance = Infinity;

    for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
            var neuron = grid[r][c];
            var dist = euclideanDistance(inputVector, neuron.weights);

            if (dist < minDistance) {
                minDistance = dist;
                bmu = {row: r, col: c};
            }
        }
    }
    return bmu;
}

// Update the weights of the BMU and its neighboring neurons
function updateWeights(bmu, inputVector) {
    for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
            var neuron = grid[r][c];
            var distanceToBMU = Math.sqrt(Math.pow(r - bmu.row, 2) + Math.pow(c - bmu.col, 2));

            // Update the neuron if it is within the neighborhood radius
            if (distanceToBMU <= neighborhoodRadius) {
                for (var d = 0; d < inputDim; d++) {
                    // Update weight based on the input and learning rate
                    neuron.weights[d] += learningRate * (inputVector[d] - neuron.weights[d]);
                }
            }
        }
    }
}

// Calculate Euclidean distance between two vectors
function euclideanDistance(vec1, vec2) {
    var sum = 0;
    for (var i = 0; i < vec1.length; i++) {
        sum += Math.pow(vec1[i] - vec2[i], 2);
    }
    return Math.sqrt(sum);
}

// Get all keys from a Max dict
function getAllKeysFromDict(dictName) {
    dictObj = new Dict(dictName);
    var keys = dictObj.getkeys();

    // Ensure keys are returned as an array
    if (typeof keys === "string") {
        keys = [keys];
    }

    return keys || [];
}

// Get feature vector from dict and parse it to floats
function getFeatureVectorFromDict(dictName, key) {
    var dictObj = new Dict(dictName);
    var featureVector = dictObj.get(key); // Retrieve the feature vector by key

    if (!featureVector) {
        post("Error: No data found for key " + key + "\n");
        return null;
    }

    // Convert string to array if needed
    if (typeof featureVector === "string") {
        featureVector = featureVector.split(" ");
    }

    // Convert each string value in the array to a float
    for (var i = 0; i < featureVector.length; i++) {
        featureVector[i] = parseFloat(featureVector[i]);
        if (isNaN(featureVector[i])) {
            post("Warning: Unable to convert " + featureVector[i] + " to float.\n");
        }
    }

    return featureVector; // Now an array of floats
}

// Plot sample positions on the SOM map
function plotSamplesOnMap(dictName) {
    var keys = getAllKeysFromDict(dictName);

    if (!keys || keys.length === 0) {
        post("Error: No data in the dictionary.\n");
        return;
    }

    // Array to hold the BMU positions for plotting
    var bmuPositions = [];

    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        var featureVector = getFeatureVectorFromDict(dictName, key);

        if (featureVector) {
            var bmu = findBMU(featureVector);
            var keyAsInt = parseInt(key, 10);

            if (!isNaN(keyAsInt)) {
                bmuPositions.push({ key: keyAsInt, row: bmu.row, col: bmu.col });
            } else {
                post("Warning: Key '" + key + "' could not be converted to an integer.\n");
            }
        }
    }

    for (var j = 0; j < bmuPositions.length; j++) {
        var pos = bmuPositions[j];
        outlet(0, [pos.row, pos.col, 1]); // Output the BMU position and sample key
    }
}

function getPositionInMap(dictName, key) {
    // Get the feature vector for the given key
    var featureVector = getFeatureVectorFromDict(dictName, key);

    if (featureVector) {
        // Find the Best Matching Unit (BMU) on the SOM grid
        var bmu = findBMU(featureVector);

        // Output the BMU position (row, col)
        outlet(0, [bmu.row, bmu.col]);  // Output the row and column to Max
    }
}
