inlets = 1;
outlets = 2;

let grid, inputData = []; 
let rows = 50, cols = 50, inputDim = 10, learningRate = 0.1, neighborhoodRadius = 5, iterations = 1000;

const analysisDict = new Dict("sampAnalysis");
const coordsDict = new Dict("sampCoords");
const coordsDictLayer1 = new Dict("sampCoordsLayer");
const analysisDictLayer1 = new Dict("sampAnalysisLayer");
const pathsDict = new Dict("sourcePaths");
const coordIndexDict = new Dict("sampCoordsCell");
const coordIndexDictLayer = new Dict("sampCoordsCellLayer");

// Main function to run everything with a single bang
this.runSOM = (numRows, numCols, numIterations, neighborhood) => {
    initSOM(inputDim, numRows, numCols);
    loadInputDataFromDict(analysisDict);
    trainSOM(numIterations, learningRate, neighborhood);
    plotSamplesOnMap(analysisDict, coordsDict);
    buildCoordIndexDict(coordsDict, coordIndexDict);
    post("SOM process complete.\n");
};

this.runSOMLayer = (numRows, numCols, numIterations, neighborhood, targetX, targetY) => {
    // Step 1: Retrieve indices at the current cell coordinates
    const coordKey = `${targetX}-${targetY}`;
    const indicesAtCell = coordIndexDict.get(coordKey);
    analysisDictLayer1.clear();
    coordsDictLayer1.clear();
    coordIndexDictLayer.clear();

    if (!Array.isArray(indicesAtCell) || indicesAtCell.length === 0) {
        return post("Error: No indices found at the specified cell coordinates.\n");
    }

    // Step 2: Load analysis data for the selected indices into sampAnalysis-1
    indicesAtCell.forEach(index => {
        const analysisData = analysisDict.get(index);
        if (Array.isArray(analysisData)) {
            analysisDictLayer1.set(index, analysisData);
        } else {
            post(`Warning: No analysis data found for index ${index}.\n`);
        }
    });

    // Step 3: Initialize the new SOM layer and plot
    initSOM(inputDim, numRows, numCols);
    loadInputDataFromDict(analysisDictLayer1);
    trainSOM(numIterations, learningRate, neighborhood);
    plotSamplesOnMap(analysisDictLayer1, coordsDictLayer1);
    buildCoordIndexDict(coordsDictLayer1, coordIndexDictLayer);
	// Step: Resolve any overlaps in coordsDictLayer1
    post("SOM layer process complete.\n");
};

// Initialize the SOM grid with random weights
this.initSOM = (inputDimension, numRows, numCols) => {
    rows = numRows;
    cols = numCols;
    inputDim = inputDimension;
    grid = Array.from({ length: rows }, () =>
        Array.from({ length: cols }, () => ({
            weights: Array.from({ length: inputDim }, () => Math.random())
        }))
    );
    post(`SOM Initialized with dimensions: ${numRows} x ${numCols} and input size: ${inputDim}\n`);
};

// Load input data from the dictionary
this.loadInputDataFromDict = (dict) => {
    const keys = dict.getkeys();
    inputData = keys ? keys.map(key => dict.get(key)).filter(Array.isArray) : [];
    post(`Loaded input data with ${inputData.length} entries from dict.\n`);
};

// Train the SOM
this.trainSOM = (numIterations, lr, neighborhood) => {
    if (inputData.length === 0) return post("Error: No input data available for training.\n");

    learningRate = lr;
    neighborhoodRadius = neighborhood;
    iterations = numIterations;

    for (let i = 0; i < iterations; i++) {
        const randomInput = inputData[Math.floor(Math.random() * inputData.length)];
        const bmu = findBMU(randomInput);
        updateWeights(bmu, randomInput);
        learningRate *= 0.99;
        neighborhoodRadius *= 0.99;
    }

    post("Training complete.\n");
};

// Find the Best Matching Unit (BMU) for a given input vector
this.findBMU = (inputVector) => {
    let minDistance = Infinity, bmu = { row: 0, col: 0 };

    for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
            const dist = euclideanDistance(inputVector, grid[r][c].weights);
            if (dist < minDistance) [minDistance, bmu] = [dist, { row: r, col: c }];
        }
    }
    return bmu;
};

// Update the weights of the BMU and its neighbors
this.updateWeights = (bmu, inputVector) => {
    grid.forEach((row, r) => row.forEach((neuron, c) => {
        const distanceToBMU = Math.hypot(r - bmu.row, c - bmu.col);
        if (distanceToBMU <= neighborhoodRadius) {
            neuron.weights = neuron.weights.map((w, d) => w + learningRate * (inputVector[d] - w));
        }
    }));
};

// Calculate Euclidean distance between two vectors
this.euclideanDistance = (vec1, vec2) => Math.sqrt(vec1.reduce((sum, v, i) => sum + (v - vec2[i]) ** 2, 0));

// Plot sample positions on the SOM map and store them in sampCoords dict
this.plotSamplesOnMap = (dict, coordDict) => {
    const keys = dict.getkeys();
    if (!keys) return post("Error: No data in the dictionary.\n");

    keys.forEach(key => {
        const featureVector = getFeatureVectorFromDict(dict, key);
        if (!featureVector) return;

        const bmu = findBMU(featureVector);
        const keyInt = parseInt(key, 10);
        if (!isNaN(keyInt)) {
            coordDict.set(key, [bmu.row, bmu.col]);
            outlet(0, [bmu.row, bmu.col], 1);
        }
    });

    post("Sample coordinates stored in dictionary.\n");
};

// Utility to get feature vector and convert to floats
this.getFeatureVectorFromDict = (dict, key) => {
    const featureVector = dict.get(key);
    if (!featureVector) return post(`Error: No data found for key ${key}\n`);

    return Array.isArray(featureVector)
        ? featureVector.map(parseFloat)
        : (post(`Error: Feature vector for key ${key} is not an array.\n`), null);
};

// Utility to build the reverse lookup dictionary
this.buildCoordIndexDict = (readFrom, writeTo) => {
    const keys = readFrom.getkeys();
    if (!keys) return post("Error: No keys found in coordsDict.\n");

    keys.forEach(key => {
        const coords = readFrom.get(key);
        if (coords) {
            const coordKey = `${coords[0]}-${coords[1]}`;
            const existingKeys = writeTo.get(coordKey) || [];
            if (Array.isArray(existingKeys)) {
                writeTo.set(coordKey, [...existingKeys, key]);
            } else {
                writeTo.set(coordKey, [key]);
            }
        }
    });
    post("Coordinate index dictionary built successfully.\n");
};

// Function to retrieve sample indices from a specific coordinate
this.getKeyFromCoords = (targetX, targetY) => {
    const coordKey = `${targetX}-${targetY}`;
    const result = coordIndexDict.get(coordKey);
    outlet(1, Array.isArray(result) ? result : result ? [result] : 0);
};

// Function to retrieve sample indices from a specific coordinate
this.getKeyFromCoordsLayer = (targetX, targetY) => {
    const coordKey = `${targetX}-${targetY}`;
    const result = coordIndexDictLayer.get(coordKey);
    outlet(1, Array.isArray(result) ? result : result ? [result] : 0);
};

//______________________
// Dictionaries holding metadata
const directoryFilterDict = new Dict("directoryFilter"); // Maps index to path
const durationFilterDict = new Dict("durationFilter"); // Maps index to duration in seconds
const dateFilterDict = new Dict("dateFilter"); // Maps index to creation date
const extensionFilterDict = new Dict("extensionFilter"); // Maps index to file extension

// Dictionary for storing filtered results
const filteredResults = new Dict("filteredResults"); // Stores indices that meet filter criteria

// Cached array for all indices (initially empty)
let cachedIndices = [];

// Function to load and verify indices
function loadCachedIndices() {
    cachedIndices = coordsDict.getkeys();
    
    // Check if cachedIndices is an array and proceed if valid
    if (Array.isArray(cachedIndices)) {
        post(`Loaded ${cachedIndices.length} indices into cache.`);
    } else {
        post("Error: cachedIndices is not an iterable object.");
        post("coordsDict contents:", coordsDict);
        cachedIndices = []; // Initialize as empty array if there's an error
    }
}

// Schedule the loading function to run after a 500 ms delay
var loadTask = new Task(loadCachedIndices, this);
loadTask.schedule(500); // Schedule `loadCachedIndices` to execute once after 500 ms

// State object to manage active filtering and criteria
const filterState = {
    activeIndices: [], // Initialize with an empty array for simplicity
    criteria: {
        directory: null,
        duration: null,
        date: null,
        extension: null
    },
    isActive: {
        directory: false,
        duration: false,
        date: false,
        extension: false
    }
};

// Toggle filter functions
this.toggleDirectoryFilter = (directoryValue, isActive) => {
    filterState.isActive.directory = !!isActive;
    filterState.criteria.directory = isActive ? directoryValue : null;

    updateFilteredIndices();
    post(`Path filter is now ${filterState.isActive.directory ? 'active' : 'inactive'}.`);

    if (!isActive && areAllFiltersInactive()) {
        resetFilterState();
    }
};

this.toggleDurationFilter = (durationValue, isActive) => {
    filterState.isActive.duration = !!isActive;
    filterState.criteria.duration = isActive ? durationValue : null;

    updateFilteredIndices();
    post(`Duration filter is now ${filterState.isActive.duration ? 'active' : 'inactive'}.`);

    if (!isActive && areAllFiltersInactive()) {
        resetFilterState();
    }
};

this.toggleDateFilter = (dateValue, isActive) => {
    filterState.isActive.date = !!isActive;
    filterState.criteria.date = isActive ? dateValue : null;

    updateFilteredIndices();
    post(`Date filter is now ${filterState.isActive.date ? 'active' : 'inactive'}.`);

    if (!isActive && areAllFiltersInactive()) {
        resetFilterState();
    }
};

this.toggleExtensionFilter = (extensionValue, isActive) => {
    filterState.isActive.extension = !!isActive;
    filterState.criteria.extension = isActive ? extensionValue.toLowerCase() : null;

    updateFilteredIndices();
    post(`Extension filter is now ${filterState.isActive.extension ? 'active' : 'inactive'}.`);

    if (!isActive && areAllFiltersInactive()) {
        resetFilterState();
    }
};

function areAllFiltersInactive() {
    return !filterState.isActive.directory && !filterState.isActive.duration &&
           !filterState.isActive.date && !filterState.isActive.extension;
}

function resetFilterState() {
    // Clear out previous data
    extensionDict = {};
    otherFilterDicts = {}; // Include other filter dictionaries as needed
    filterState.activeIndices = []; // Clear active indices
    filteredResults.clear(); // Clear filtered results in Max dictionary
}

this.updateFilteredIndices = () => {
    // Start with all cached indices (create a shallow copy)
    let filteredIndices = [...cachedIndices];

    // Apply filters only if they are active and have criteria
    if (filterState.isActive.directory && filterState.criteria.directory) {
        filteredIndices = filteredIndices.filter(index => 
            directoryFilterDict.get(index) == filterState.criteria.directory
        );
    }

    if (filterState.isActive.duration && filterState.criteria.duration) {
        filteredIndices = filteredIndices.filter(index => 
            durationFilterDict.get(index) == filterState.criteria.duration
        );
    }

    if (filterState.isActive.date && filterState.criteria.date) {
        filteredIndices = filteredIndices.filter(index => 
            dateFilterDict.get(index) == filterState.criteria.date
        );
    }

    if (filterState.isActive.extension && filterState.criteria.extension) {
        filteredIndices = filteredIndices.filter(index => 
            extensionFilterDict.get(index) == filterState.criteria.extension
        );
    }

    // Update active indices with filtered results
    filterState.activeIndices = filteredIndices.length > 0 ? filteredIndices : [];
    outputFilteredResults(filterState.activeIndices);
};

this.outputFilteredResults = (filteredIndices) => {
    filteredResults.clear(); // Clear previous results

    if (!filteredIndices || filteredIndices.length == 0) {
        post("No matching results found for the current filters.\n");
        return; // Early exit if no matches
    }

    filteredIndices.forEach(index => {
        const coords = coordsDict.get(index);
        if (coords) {
            const filterStatus = filterState.isActive.directory || filterState.isActive.duration || filterState.isActive.date || filterState.isActive.extension;
            outlet(0, coords, filterStatus ? 2 : 1);

            // Store the index in filteredResults dictionary
            filteredResults.set(index, coords);
        } else {
            post(`Warning: No coordinates found for index ${index}\n`);
        }
    });

    post(`Filtered results: ${filteredIndices.length} matches found.\n`);
};
