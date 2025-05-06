mgraphics.init();
mgraphics.autofill = 0;
mgraphics.relative_coords = 0;

// ----- Config -----
inlets = 1;
outlets = 1;
autowatch = 1;

const coordsDict = new Dict("sampCoords"); // Dict with all samples and their respective coordinates
const layersDict = new Dict("sampCoordsCell"); // Dict with all samples on overlapping nodes
const playlist1Dict = new Dict("playlist1"); // Storage dict for slected files for music creation
let playlist1Index = 0; // Counter for indexing samples in playlist
const playlist2Dict = new Dict("playlist2"); // Storage dict for slected files for music creation
let playlist2Index = 0; // Counter for indexing samples in playlist

const pathsDict = new Dict("sourcePaths"); // Dict with all corresponding paths for samples
const namesDict = new Dict("sourceNames"); // Dict with all corresponding file names for samples
const analysisDict = new Dict("sampAnalysis"); // Dict with all corresponding spectral analysis for samples

// Storage
let path = null; // Selected file path (red dot)
let name = null; // Selected file name (red dot)
let directory = null; // Directory of path (with filename removed) (red dot)
let creationDate = null; // Date of path (red dot)
let analysisData = null; // Seleced file array of spectral data
let points = [];
let selectedNode = null;  // To track the selected node

// UI settings
const cellSize = 10; // Size of each cell on the grid
const cols = 50; // Columns (adjust based on your SOM)
const rows = 50; // Rows
const mapScaling = 0.9; // Scaling factor for SOM map

// Storage for tracking already drawn nodes (to avoid redundant drawing)
let drawnNodes = new Set();

// Paint function: draw only filtered results
let frameCount = 0;
function paint() {
    frameCount++;

    mgraphics.set_source_rgba(0.1, 0.1, 0.1, 1.0);
    mgraphics.rectangle(0, 0, mgraphics.size[0], mgraphics.size[1]);
    mgraphics.fill();

    let drawnNodes = new Set();
    let maxLayerCount = 1;

    // Compute max layer count using get()
    let layerKeys = layersDict.getkeys();
    for (var i = 0; i < layerKeys.length; i++) {
        var val = layersDict.get(layerKeys[i]);
        var arr = val && val.get ? val.get() : val;
        if (arr && arr.length > maxLayerCount) {
            maxLayerCount = arr.length;
        }
    }

    if (filterState.activeIndices.length !== 0) {
        filterState.activeIndices.forEach(function(index) {
            var pt = points[index];
            var coordsKey = pt[0] + "-" + pt[1];
            if (drawnNodes.has(coordsKey)) return;
            drawnNodes.add(coordsKey);

            var isSelected = selectedNode !== null &&
                             points[selectedNode][0] === pt[0] &&
                             points[selectedNode][1] === pt[1];

            var x = mapCoord(pt[1], cols) * mgraphics.size[0] / 2 * mapScaling + mgraphics.size[0] / 2;
            var y = mapCoord(pt[0], rows) * mgraphics.size[1] / 2 * mapScaling + mgraphics.size[1] / 2;

            if (isSelected) {
                var pulseRadius = 3 + Math.sin(frameCount * 0.2) * 2;
                mgraphics.set_source_rgba(1.0, 0.3, 0.3, 1.0);
                mgraphics.arc(x, y, pulseRadius, 0, Math.PI * 2);
                mgraphics.fill();
            } else {
                var val = layersDict.get(coordsKey);
                var layer = val && val.get ? val.get() : val;
                var count = (layer && layer.length) ? layer.length : 0;
                var t = count / 100; // maxLayerCount;

                // Gradient from blue to white via cyan
                var r = t > 0.5 ? (t - 0.5) * 2 : 0;
                var g = t;
                var b = t > 0.25 ? (t - 0.25) * 1 : 0;

                mgraphics.set_source_rgba(r, g, b, 1.0);
                mgraphics.arc(x, y, 3, 0, Math.PI * 2);
                mgraphics.fill();
            }
        });
    }

    mgraphics.redraw();
}

// Helper: map grid coords [0-cols] into [-1,1] normalized space
function mapCoord(pos, maxPos) {
    return (pos / (maxPos - 1)) * 2 - 1;
}

// Main bang: reload points and redraw
function bang() {
    post("bang() called\n"); // Debugging: Check when bang is triggered
    points = []; // Clear previous points
    drawnNodes.clear(); // Clear the set of drawn nodes

    const keys = coordsDict.getkeys();
    if (!keys || keys.length === 0) {
        post("No coordinates found in sampCoords.\n");
        return;
    }

    // Load points
    keys.forEach(key => {
        const coords = coordsDict.get(key);
        if (Array.isArray(coords) && coords.length >= 2) {
            points.push([coords[0], coords[1]]);
        }
    });

    post(`Loaded ${points.length} points from sampCoords.\n`);
    mgraphics.redraw(); // Ask Max to repaint after loading points
}

// Auto-repaint if window resizes etc.
function onresize(w, h) {
    post("onresize() called\n"); // Debugging: Check if resize is called
    mgraphics.redraw(); // Trigger redraw on resize
}

//----- Filtering
// Initialize metadata dictionaries
const directoryFilterDict = new Dict("directoryFilter");
const durationFilterDict = new Dict("durationFilter");
const dateFilterDict = new Dict("dateFilter");
const extensionFilterDict = new Dict("extensionFilter");
const sampAnalysis = new Dict("sampAnalysis");

const filteredResults = new Dict("filteredResults");
let cachedIndices = [];

// Load indices
function loadCachedIndices() {
    cachedIndices = coordsDict.getkeys();
    if (Array.isArray(cachedIndices)) {
        post(`Loaded ${cachedIndices.length} indices into cache.\n`);
    } else {
        post("Error: cachedIndices not iterable.\n");
        cachedIndices = [];
    }
}
var loadTask = new Task(loadCachedIndices, this);
loadTask.schedule(50);

// Filtering state
const filterState = {
    activeIndices: [],
    criteria: {
        directory: null,
        duration: null,
        date: null,
        extension: null,
        spectral: null
    },
    isActive: {
        directory: false,
        duration: false,
        date: false,
        extension: false,
        spectral: false
    }
};

// Filter setters
this.dir = (stateOrValue) => {
    if (stateOrValue === 'on') {
        filterState.isActive.directory = true;
        print('Directory filter is now active.\n');
    } else if (stateOrValue === 'off') {
        filterState.isActive.directory = false;
        print('Directory filter is now inactive.\n');
    } else {
        filterState.criteria.directory = directory;
        print("Directory path set to: " + directory);
    }
    updateFilteredIndices();
};


this.dur = (stateOrValue) => {
    if (stateOrValue === 'on') {
        filterState.isActive.duration = true;
        print('Duration filter is now active.\n');
    } else if (stateOrValue === 'off') {
        filterState.isActive.duration = false;
        print('Duration filter is now inactive.\n');
    } else {
        filterState.criteria.duration = stateOrValue;
        print("File Length: " + stateOrValue + " seconds.");
    }
    updateFilteredIndices();
};

this.date = (stateOrValue) => {
    if (stateOrValue === 'on') {
        filterState.isActive.date = true;
        print('Date filter is now active.\n');
    } else if (stateOrValue === 'off') {
        filterState.isActive.date = false;
        print('Date filter is now inactive.\n');
    } else {
        filterState.criteria.date = creationDate;
        print("File Date: " + creationDate);
    }
    updateFilteredIndices();
};

this.ext = (stateOrValue) => {
    if (stateOrValue === 'on') {
        filterState.isActive.extension = true;
        print('Extension filter is now active.\n');
    } else if (stateOrValue === 'off') {
        filterState.isActive.extension = false;
        print('Extension filter is now inactive.\n');
    } else {
        filterState.criteria.extension = stateOrValue;
        print("File Extension: " + stateOrValue);
    }
    updateFilteredIndices();
};

this.spec = (stateOrValue, searchValue, tolerance) => {
    if (stateOrValue === 'on') {
        filterState.isActive.spectral = true;
        print('Extension filter is now active.\n');
    } else if (stateOrValue === 'off') {
        filterState.isActive.spectral = false;
        print('Extension filter is now inactive.\n');
    } else {
        filterState.criteria.spectral = {stateOrValue, searchValue, tolerance};
        print("Spectral: " + stateOrValue + searchValue + tolerance);
    }
    updateFilteredIndices();
};

function updateFilteredIndices() {
    if (!cachedIndices || cachedIndices.length === 0) return;

    let filteredIndices = [...cachedIndices];

    // Directory filter
    if (filterState.isActive.directory && filterState.criteria.directory) {
        filteredIndices = filteredIndices.filter(function(index) {
            return directoryFilterDict.get(index) == filterState.criteria.directory;
        });
    }

    // Duration filter
    if (filterState.isActive.duration && filterState.criteria.duration) {
        filteredIndices = filteredIndices.filter(function(index) {
            return durationFilterDict.get(index) == filterState.criteria.duration;
        });
    }

    // Date filter
    if (filterState.isActive.date && filterState.criteria.date) {
        filteredIndices = filteredIndices.filter(function(index) {
            return dateFilterDict.get(index) == filterState.criteria.date;
        });
    }

    // Extension filter
    if (filterState.isActive.extension && filterState.criteria.extension) {
        filteredIndices = filteredIndices.filter(function(index) {
            return extensionFilterDict.get(index) == filterState.criteria.extension;
        });
    }

    // Spectral feature filter
    if (filterState.isActive.spectral && filterState.criteria.spectral) {
        const spectralCrit = filterState.criteria.spectral;
        const stateOrValue = spectralCrit.stateOrValue;
        const searchValue = spectralCrit.searchValue;
        const tolerance = spectralCrit.tolerance;

        filteredIndices = filteredIndices.filter(function(index) {
            const sampleData = sampAnalysis.get(index);
            if (Array.isArray(sampleData) && sampleData.length > stateOrValue) {
                const featureValue = sampleData[stateOrValue];
                return Math.abs(featureValue - searchValue) <= tolerance;
            }
            return false;
        });
    }

    // Store filtered list in filterState
    filterState.activeIndices = filteredIndices.length > 0 ? filteredIndices : [];

    // Log result
    print(`There are ${filterState.activeIndices.length} samples selected through filtering.\n`);

    // Update result dictionary
    filteredResults.clear();
    for (let i = 0; i < filterState.activeIndices.length; i++) {
        const idx = filterState.activeIndices[i];
        filteredResults.set(idx, 1);
    }

    // Trigger visual update
    mgraphics.redraw();
}

// Function that sets path, directory, and date inside other selection functions
function setFilterContext(index) {
    if (index === null || index === undefined) return;

    // Set path
    path = String(pathsDict.get(index));

	// Set path
    name = String(namesDict.get(index));

    // Set directory
    directory = String(directoryFilterDict.get(index));

    // Set date
    creationDate = String(dateFilterDict.get(index));

	// Set Analysis data
	analysisData = String(analysisDict.get(index));

    // Get and store coordinates
    coords = coordsDict.get(index);
    if (!coords || coords.length < 2) {
        post("No coordinates found for index " + index + "\n");
        return;
    }
}

// Commands for console (i.e., programming language)
let coords = null;

function info() {
	print("File name: " + name);
	print("File directory: " + directory);
	print("File date: " + creationDate);
	
	print("Spectral Feature: " + analysisData);
}

function filters() {
    print(`Path filter is ${filterState.isActive.directory ? 'active' : 'inactive'}.\n`);
    print(`Duration filter is ${filterState.isActive.duration ? 'active' : 'inactive'}.\n`);
    print(`Date filter is ${filterState.isActive.date ? 'active' : 'inactive'}.\n`);
    print(`Extension filter is ${filterState.isActive.extension ? 'active' : 'inactive'}.\n`);
    print(`Spectral filter is ${filterState.isActive.spectral ? 'active' : 'inactive'}.\n`);
}

function rndm() {
    const fr = filterState.activeIndices;
    if (!fr || fr.length === 0) {
        print("No filtered results to select from.\n");
        return;
    }

    // Pick a random index from the filtered selection
    const randomKey = fr[Math.floor(Math.random() * fr.length)];

    // Get that index's coordinates
    coords = coordsDict.get(randomKey);
    if (!coords || coords.length < 2) {
        print("No coordinates found for selected key.\n");
        return;
    }

    // Set path, directory, and date
    setFilterContext(randomKey);

    // Find index of matching point in points array
    let matchIndex = null;
    points.forEach((pt, index) => {
        if (pt[0] === coords[0] && pt[1] === coords[1]) {
            matchIndex = index;
        }
    });

    if (matchIndex !== null) {
        selectedNode = matchIndex;
        print("Selected sample: " + pathsDict.get(randomKey) + " at index " + selectedNode + "\n");
        mgraphics.redraw();
    } else {
        print("Could not find matching node in points array.\n");
    }
}

function sim() {
    const fr = filterState.activeIndices;
    if (!fr || fr.length === 0) {
        print("No filtered results to select from.\n");
        return;
    }

    const x0 = coords[0];
    const y0 = coords[1];

    const nearbyKeys = [];
    for (let i = 0; i < fr.length; i++) {
        const key = fr[i];
        const c = coordsDict.get(key);
        if (!c || c.length < 2) continue;

        const dx = c[0] - x0;
        const dy = c[1] - y0;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist >= 1 && dist <= 3) {
            nearbyKeys.push(key);
        }
    }

    if (nearbyKeys.length === 0) {
        print("No similar samples found within distance 1–3.\n");
        return;
    }

    const pickedKey = nearbyKeys[Math.floor(Math.random() * nearbyKeys.length)];
    coords = coordsDict.get(pickedKey);

    if (!coords || coords.length < 2) {
        print("No coordinates found for selected similar key.\n");
        return;
    }

    // Set path, directory, and date
    setFilterContext(pickedKey);

    let matchIndex = null;
    points.forEach((pt, index) => {
        if (pt[0] === coords[0] && pt[1] === coords[1]) {
            matchIndex = index;
        }
    });

    if (matchIndex !== null) {
        selectedNode = matchIndex;
        print("Selected similar sample: " + path + " at index " + selectedNode + "\n");
        mgraphics.redraw();
    } else {
        print("Could not find matching node in points array.\n");
    }
}


function dif() {
    const fr = filterState.activeIndices;
    if (!fr || fr.length === 0) {
        print("No filtered results to select from.\n");
        return;
    }

    const x0 = coords[0];
    const y0 = coords[1];

    const distantKeys = [];
    for (let i = 0; i < fr.length; i++) {
        const key = fr[i];
        const c = coordsDict.get(key);
        if (!c || c.length < 2) continue;

        const dx = c[0] - x0;
        const dy = c[1] - y0;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist >= 15) {
            distantKeys.push({ key: key, dist: dist });
        }
    }

    if (distantKeys.length === 0) {
        print("No distant samples found (distance >= 15).\n");
        return;
    }

    distantKeys.sort(function(a, b) { return b.dist - a.dist; });

    const topSlice = Math.max(1, Math.floor(distantKeys.length / 10));
    const picked = distantKeys[Math.floor(Math.random() * topSlice)];
    const pickedKey = picked.key;
    coords = coordsDict.get(pickedKey);

    if (!coords || coords.length < 2) {
        print("No coordinates found for selected distant key.\n");
        return;
    }

    // Set path, directory, and date
    setFilterContext(pickedKey);

    let matchIndex = null;
    points.forEach((pt, index) => {
        if (pt[0] === coords[0] && pt[1] === coords[1]) {
            matchIndex = index;
        }
    });

    if (matchIndex !== null) {
        selectedNode = matchIndex;
        print("Selected distant sample: " + path + " at index " + selectedNode + "\n");
        mgraphics.redraw();
    } else {
        print("Could not find matching node in points array.\n");
    }
}

function add(playlist) {
    if (!path) {
        print("Invalid path. Cannot add to playlist.\n");
        return;
    }
	
	if (playlist == 1) {
		playlist1Dict.set(playlist1Index, path);
    	print(`Added to playlist at index ${playlist1Index}: ${path}\n`);
    	playlist1Index++;

	} else if (playlist == 2) {
		playlist2Dict.set(playlist2Index, path);
    	print(`Added to playlist at index ${playlist2Index}: ${path}\n`);
    	playlist2Index++;

	}
}

function rep(playlist, index) {
    if (!path) {
        print("Invalid path. Cannot add to playlist.\n");
        return;
    }
	
	if (playlist == 1) {
		playlist1Dict.replace(index, path);
    	print(`replaced playlist at index ${index}: ${path}\n`);

	} else if (playlist == 2) {
		playlist2Dict.replace(index, path);
    	print(`Replaced playlist at index ${index}: ${path}\n`);

	}
}

function sub(playlist, index) {
    if (!path) {
        print("Invalid path. Cannot add to playlist.\n");
        return;
    }
	
	if (playlist == 1) {
		playlist1Dict.remove(index);
    	print(`Removed sample at index ${index}: ${path}\n`);

	} else if (playlist == 2) {
		playlist2Dict.remove(index);
    	print(`Removed sample at index ${index}: ${path}\n`);

	}
}

// The audio control functions. Buffer, params, etc.
function density(val) {
	let grain_density = this.patcher.getnamed("grain_density");
	grain_density.message("int", val); 
}

function length(val) {
	let grain_length = this.patcher.getnamed("grain_length");
	grain_length.message("int", val); 
}

function rate(name, val) {
	var g = this.patcher.getnamed(name);
	if (g) {
		g.message("float", val);
	} else {
		print("No object found with name: " + name + "\n");
	}
}

// Scheduling and time based functions
var rampInterval = 5; // ms
var activeTasks = [];

function ramp(funcName, fromVal, toVal, duration) {
	var steps = Math.floor(duration / rampInterval);
	var stepCount = 0;

	var task = new Task(function () {
		var progress = stepCount / steps;
		var val = fromVal + (toVal - fromVal) * progress;

		if (typeof this[funcName] === "function") {
			this[funcName](val); // Call the named function with interpolated value
		} else {
			print("Function " + funcName + " not found.\n");
			task.cancel();
			return;
		}

		stepCount++;

		if (stepCount > steps) {
			task.cancel();
			var idx = activeTasks.indexOf(task);
			if (idx !== -1) activeTasks.splice(idx, 1);
			print("Ramp complete.\n");
		}
	}, this);

	task.interval = rampInterval;
	task.repeat(steps + 1);
	activeTasks.push(task);
}

function print(txt) {
	outlet(0, txt);
}













