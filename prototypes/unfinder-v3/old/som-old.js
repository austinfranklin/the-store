inlets = 1;
outlets = 2;

var grid; // SOM grid
var inputData = []; // Input feature vectors
var rows = 100; // Number of rows in SOM grid
var cols = 100; // Number of cols in SOM grid
var inputDim = 4; // Dimension of the input
var learningRate = 0.1;
var neighborhoodRadius = 5;
var iterations = 1500;
var dictName = "sampAnalysis"; // Default dict name
var sampCoordsDictName = "sampCoords"; // Default dict for coordinates

// Main function to run everything with a single bang
function runSOM(inputDimension, numRows, numCols, numIterations, lr, neighborhood, dictName, outputDictName) {
    initSOM(inputDimension, numRows, numCols);
    loadInputDataFromDict(dictName);
    trainSOM(numIterations, lr, neighborhood, dictName);
    
    // Use the specified dictionary name for storing coordinates, or the default if none is provided
    if (outputDictName !== undefined && outputDictName !== "") {
        sampCoordsDictName = outputDictName;
    }
    
    plotSamplesOnMap(dictName, sampCoordsDictName);
    post("SOM process complete.\n");
}

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

// Load input data from the dictionary
function loadInputDataFromDict(dictName) {
    var dictObj = new Dict(dictName);
    var keys = dictObj.getkeys();

    if (keys != null) {
        inputData = [];  // Clear previous data
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var featureVector = dictObj.get(key);

            if (Array.isArray(featureVector)) {
                inputData.push(featureVector);
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
function trainSOM(numIterations, lr, neighborhood, dictName) {
    learningRate = lr;
    neighborhoodRadius = neighborhood;
    iterations = numIterations;

    if (inputData.length === 0) {
        post("Error: No input data available for training. Please check the dictionary.\n");
        return;
    }

    for (var i = 0; i < iterations; i++) {
        // Pick a random input vector
        var randomInput = inputData[Math.floor(Math.random() * inputData.length)];

        // Find the Best Matching Unit (BMU)
        var bmu = findBMU(randomInput);

        // Update the BMU and its neighbors
        updateWeights(bmu, randomInput);

        // Decay learning rate and neighborhood radius
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

// Update the weights of the BMU and its neighbors
function updateWeights(bmu, inputVector) {
    for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
            var neuron = grid[r][c];
            var distanceToBMU = Math.sqrt(Math.pow(r - bmu.row, 2) + Math.pow(c - bmu.col, 2));

            // Update the neuron if it is within the neighborhood radius
            if (distanceToBMU <= neighborhoodRadius) {
                for (var d = 0; d < inputDim; d++) {
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

// Plot sample positions on the SOM map and store them in sampCoords dict
function plotSamplesOnMap(dictName, sampCoordsDictName) {
    var keys = getAllKeysFromDict(dictName);
    var sampCoordsDict = new Dict(sampCoordsDictName);

    if (!keys || keys.length === 0) {
        post("Error: No data in the dictionary.\n");
        return;
    }

    var bmuPositions = [];

    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        var featureVector = getFeatureVectorFromDict(dictName, key);

        if (featureVector) {
            var bmu = findBMU(featureVector);
            var keyAsInt = parseInt(key, 10);

            if (!isNaN(keyAsInt)) {
                bmuPositions.push({ key: keyAsInt, row: bmu.row, col: bmu.col });
                sampCoordsDict.set(key, [bmu.row, bmu.col]);
            } else {
                post("Warning: Key '" + key + "' could not be converted to an integer.\n");
            }
        }
    }

    for (var j = 0; j < bmuPositions.length; j++) {
        var pos = bmuPositions[j];
        outlet(0, [pos.row, pos.col]);
    }

    post("Sample coordinates stored in " + sampCoordsDictName + " dictionary.\n");
}

// Utility to get all keys from a dict
function getAllKeysFromDict(dictName) {
    var dictObj = new Dict(dictName);
    var keys = dictObj.getkeys();
    if (typeof keys === "string") {
        keys = [keys];
    }
    return keys || [];
}

// Utility to get feature vector and convert to floats
function getFeatureVectorFromDict(dictName, key) {
    var dictObj = new Dict(dictName);
    var featureVector = dictObj.get(key);

    if (!featureVector) {
        post("Error: No data found for key " + key + "\n");
        return null;
    }

    if (typeof featureVector === "string") {
        featureVector = featureVector.split(" ");
    }

    for (var i = 0; i < featureVector.length; i++) {
        featureVector[i] = parseFloat(featureVector[i]);
        if (isNaN(featureVector[i])) {
            post("Warning: Unable to convert " + featureVector[i] + " to float.\n");
        }
    }

    return featureVector;
}

function getCellAndMatchingIndices(coords, newCoords, analysis, newAnalysis, sampleIndex) {
    // Initialize the dictionaries for sampCoords, sampAnalysis, sampNodeCoords, and sampNodeAnalysis
    var sampCoordsDict = new Dict(coords);
    var sampAnalysisDict = new Dict(analysis);
    var sampNodeCoordsDict = new Dict(newCoords); // To store coordinates of selected samples
    var sampNodeAnalysisDict = new Dict(newAnalysis); // To store feature vectors of selected samples

    // Get the cell coordinates for the given sample index
    var cellCoords = sampCoordsDict.get(sampleIndex);

    if (!cellCoords) {
        post("Error: No coordinates found for sample index " + sampleIndex + "\n");
        return;
    }

    var row = cellCoords[0];
    var col = cellCoords[1];

    // Find all sample indices with the same coordinates
    var matchingIndices = [];

    // Iterate over all keys in the sampCoords dictionary
    var keys = sampCoordsDict.getkeys();
    for (var i = 0; i < keys.length; i++) {
        var key = parseInt(keys[i], 10);  // Make sure the key is an integer
        var coords = sampCoordsDict.get(key);

        // Check if the coordinates match
        if (coords && coords[0] === row && coords[1] === col) {
            matchingIndices.push(key); // Collect the indices
        }
    }

    // Prepare the output in a format suitable for Max
    var output = [row, col];
    if (matchingIndices.length > 0) {
        output = output.concat(matchingIndices);
    }

    // Output the row, column, and list of matching indices
    //, output);  // Send the output to the Max outlet

    // Store the selected sample indices and their corresponding data in sampNodeCoords and sampNodeAnalysis
    for (var j = 0; j < matchingIndices.length; j++) {
        var matchIndex = matchingIndices[j];
        var matchCoords = sampCoordsDict.get(matchIndex);

        // Ensure matchCoords is valid
        if (matchCoords) {
            // Store the coordinates of the matching index in sampNodeCoords
            sampNodeCoordsDict.set(matchIndex, matchCoords);
        } else {
            post("Warning: No coordinates found for index " + matchIndex + "\n");
        }

        // Retrieve and store the feature vector of the matching index in sampNodeAnalysis
        var featureVector = sampAnalysisDict.get(matchIndex);

        // Ensure featureVector is valid
        if (featureVector) {
            sampNodeAnalysisDict.set(matchIndex, featureVector);
        } else {
            post("Warning: No feature vector found for index " + matchIndex + "\n");
        }
    }

    // Write changes to newCoords and newAnalysis
    sampNodeCoordsDict.export_json(newCoords);  // This ensures data is written to the new dict
    sampNodeAnalysisDict.export_json(newAnalysis);

    post("Matching sample indices and corresponding data stored in sampNodeCoords and sampNodeAnalysis dictionaries.\n");
}

// Get the indices of a file using its location on the SOM map (X and Y)
var coordIndexDict = new Dict("sampCoordsCell"); // A dictionary that will store the reverse lookup
var sampCoordsDict = new Dict("sampCoords");

// Preprocess the original coordinates dictionary and build the reverse lookup
function buildCoordIndexDict() {
    var keys = sampCoordsDict.getkeys();
    if (!keys || keys.length === 0) {
        post("Error: No keys found in sampCoords dictionary.\n");
        return;
    }

    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        var coords = sampCoordsDict.get(key);

        if (coords) {
            var coordKey = coords[0] + "-" + coords[1]; // Create a unique key for the coordinates
            coordIndexDict.set(coordKey, key); // Store the key in the reverse lookup dict
        }
    }

    post("Coordinate index dictionary built.\n");
}

function getKeyFromCoords(targetX, targetY) {
    var coordKey = targetX + "-" + targetY; // Generate the key for the coordinates
    var result = coordIndexDict.get(coordKey);

    if (result) {
        outlet(1, result);
    } else {
        post("Error: No matching key found for coordinates (" + targetX + ", " + targetY + ").\n");
        return null;
    }
}

// Get all indices for a file in the same directory and print their coordinates
function getIndicesByPath(dictName, targetPath, coordsDictName) {
    var sourcePathsDict = new Dict(dictName);  // Initialize the source paths dictionary
    var sampCoordsDict = new Dict(coordsDictName);  // Initialize the coordinates dictionary
    var keys = sourcePathsDict.getkeys();  // Get all keys (indices)

    if (!keys) {
        post("Error: The dictionary is empty or does not exist.\n");
        return;
    }

    var matchingIndices = [];  // Array to store matching indices

    // Iterate through each key (index)
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        var fullPathArray = sourcePathsDict.get(key);  // Get the file path array for this key

        // Ensure the fullPathArray is valid and non-empty
        if (Array.isArray(fullPathArray) && fullPathArray.length > 0) {
            var fullPath = fullPathArray[0];  // Access the first element (the actual path)

            // Check if the fullPath contains the target path at the beginning
            if (fullPath.indexOf(targetPath) === 0) {
                matchingIndices.push(key);  // If the path starts with the target, store the index
            }
        } else {
            post("Warning: Invalid or empty path array at index " + key + "\n");
        }
    }

    // Output the matching indices and their coordinates
    if (matchingIndices.length > 0) {
        post("Found matching indices: " + matchingIndices.join(", ") + "\n");

        // Iterate over the matching indices to print their coordinates
        for (var j = 0; j < matchingIndices.length; j++) {
            var index = matchingIndices[j];
            var coords = sampCoordsDict.get(index);  // Get the coordinates for this index

            if (coords) {
                post("Index " + index + " has coordinates: " + coords + "\n");
            } else {
                post("Warning: No coordinates found for index " + index + "\n");
            }
        }
        return matchingIndices;
    } else {
        post("No matching indices found for path: " + targetPath + "\n");
        return [];
    }
}

