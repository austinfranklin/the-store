mgraphics.init();
mgraphics.autofill = 0;
mgraphics.relative_coords = 0;

// ----- Config -----
inlets = 1;
outlets = 1;

const coordsDict = new Dict("sampCoords"); // Dict for all sample coords in disc
const layersDict = new Dict("sampCoordsCell"); // Dict for all samples on overlapping nodes
const playlistDict = new Dict("playlistFiles"); // Dict for storing samples for music

// Storage
let points = [];
let selectedNode = null;  // To track the selected node

// UI settings
const cellSize = 10; // Size of each cell on the grid
const cols = 50;     // Columns (adjust based on your SOM)
const rows = 50;     // Rows

// Storage for tracking already drawn nodes (to avoid redundant drawing)
let drawnNodes = new Set();

// Paint function: draw everything
function paint() {
    post("paint() called\n");  // Check if paint() is triggered

    // Clear the drawnNodes set each time paint is called
    drawnNodes.clear();  // This resets the set so it tracks nodes for this draw only

    mgraphics.set_source_rgba(0.1, 0.1, 0.1, 1.0); // Dark background color
    mgraphics.rectangle(0, 0, mgraphics.size[0], mgraphics.size[1]); // Draw a rectangle that fills the window
    mgraphics.fill(); // Fill the background

    // Draw points, skipping those that are already drawn at the same position
    points.forEach((pt, index) => {
        const coordsKey = `${pt[0]},${pt[1]}`; // Create a key from the coordinates

        // Check if this coordinate has already been drawn
        if (drawnNodes.has(coordsKey)) {
            return;  // Skip this point as it's already been drawn
        }

        // Mark the node as drawn
        drawnNodes.add(coordsKey);

        // Check if the point is in the active filter set or selected
        const isSelected = selectedNode !== null && points[selectedNode][0] === pt[0] && points[selectedNode][1] === pt[1];
        const isFiltered = filterState.activeIndices.includes(index);  // Check if this point is part of the filtered indices
        
        if (isSelected) {
            mgraphics.set_source_rgba(1.0, 0.3, 0.3, 1.0); // Red for selected nodes at the same position
        } else if (isFiltered) {
            mgraphics.set_source_rgba(0.3, 1.0, 0.3, 1.0); // Green for filtered nodes
        } else {
            mgraphics.set_source_rgba(0.7, 0.9, 1.0, 1.0); // Light blue for unselected nodes
        }

        // Map coordinates to the mgraphics window size
        let x = mapCoord(pt[1], cols) * mgraphics.size[0] / 2 + mgraphics.size[0] / 2; // X coordinate
        let y = mapCoord(pt[0], rows) * mgraphics.size[1] / 2 + mgraphics.size[1] / 2; // Y coordinate
        
        mgraphics.arc(x, y, 3, 0, Math.PI * 2); // Draw a circle (node) at each point
        mgraphics.fill(); // Fill the circle with the current color
    });
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

// Click handler to highlight the selected node
function onclick(x, y, button, shift, capslock, option, ctrl) {
    post("onclick() called\n"); // Debugging: Check when click happens

    // Map the mouse coordinates to normalized coordinates (-1 to 1)
    const normX = (x / mgraphics.size[0]) * 2 - 1;
    const normY = (y / mgraphics.size[1]) * 2 - 1;

    // Map the normalized coordinates to grid coordinates (0 to 49 for a 50x50 grid)
    const gridX = Math.floor((normX + 1) * (cols - 1) / 2);  // Mapping to grid width
    const gridY = Math.floor((normY + 1) * (rows - 1) / 2);  // Mapping to grid height

    //post(`Mapped click position: x=${gridX}, y=${gridY}\n`); // Debugging: Check mapped coordinates

    post("Array: ", layersDict.get(`${gridX}-${gridY}`));
    
    // Find the closest node
    let minDistance = Infinity;
    let closestNode = null;
    points.forEach((pt, index) => {
        // Convert point's grid coordinates to OpenGL space
        const ptX = mapCoord(pt[1], cols);
        const ptY = mapCoord(pt[0], rows);
        
        // Calculate the distance between the click and the point
        const dist = Math.sqrt(Math.pow(ptX - normX, 2) + Math.pow(ptY - normY, 2));
        if (dist < minDistance) {
            minDistance = dist;
            closestNode = index;
        }
    });

    // If click is close enough to a point, select it
    if (minDistance < 0.05) { // Threshold for selecting a point
        selectedNode = closestNode;
        post(`Node selected: ${selectedNode}\n`); // Debugging: Check if a node was selected
    } else {
        selectedNode = null;
        post("No node selected\n"); // Debugging: Check if no node is selected
    }

    mgraphics.redraw(); // Trigger redraw to highlight the selected node
}

//----- Filtering
// Initialize metadata dictionaries
const directoryFilterDict = new Dict("directoryFilter");
const durationFilterDict = new Dict("durationFilter");
const dateFilterDict = new Dict("dateFilter");
const extensionFilterDict = new Dict("extensionFilter");

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
loadTask.schedule(500);

// Filtering state
const filterState = {
    activeIndices: [],
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

// Filter functions
this.directoryFilter = (directoryValue, isActive) => {
    filterState.isActive.directory = !!isActive;
    filterState.criteria.directory = isActive ? directoryValue : null;
    updateFilteredIndices();
    post(`Path filter is now ${filterState.isActive.directory ? 'active' : 'inactive'}.\n`);
};

this.durationFilter = (durationValue, isActive) => {
    filterState.isActive.duration = !!isActive;
    filterState.criteria.duration = isActive ? durationValue : null;
    updateFilteredIndices();
    post(`Duration filter is now ${filterState.isActive.duration ? 'active' : 'inactive'}.\n`);
};

this.dateFilter = (dateValue, isActive) => {
    filterState.isActive.date = !!isActive;
    filterState.criteria.date = isActive ? dateValue : null;
    updateFilteredIndices();
    post(`Date filter is now ${filterState.isActive.date ? 'active' : 'inactive'}.\n`);
};

this.extensionFilter = (extensionValue, isActive) => {
    filterState.isActive.extension = !!isActive;
    filterState.criteria.extension = isActive ? extensionValue.toLowerCase() : null;
    updateFilteredIndices();
    post(`Extension filter is now ${filterState.isActive.extension ? 'active' : 'inactive'}.\n`);
};

function updateFilteredIndices() {
    let filteredIndices = [...cachedIndices];

    // Apply filtering criteria
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

    // Store filtered indices in the state
    filterState.activeIndices = filteredIndices.length > 0 ? filteredIndices : [];

    // Redraw the nodes after filtering
    mgraphics.redraw(); // Trigger repaint after updating the filtered state
}

// Paint function: draw everything in a single pass
function paint() {
    post("paint() called\n");

    // Reset drawing state
    mgraphics.set_source_rgba(0.1, 0.1, 0.1, 1.0); // Dark background color
    mgraphics.rectangle(0, 0, mgraphics.size[0], mgraphics.size[1]);
    mgraphics.fill(); // Clear the screen

    // Create a set to track which nodes have been drawn
    let drawnNodes = new Set();

    // Loop through filtered points and draw them
    filterState.activeIndices.forEach(index => {
        const pt = points[index]; // Get the point corresponding to the filtered index

        const coordsKey = `${pt[0]},${pt[1]}`; // Create a key from the coordinates

        // Skip already drawn points
        if (drawnNodes.has(coordsKey)) return;

        // Mark the node as drawn
        drawnNodes.add(coordsKey);

        // Check if this point is selected or filtered
        const isSelected = selectedNode !== null && points[selectedNode][0] === pt[0] && points[selectedNode][1] === pt[1];
        const isFiltered = filterState.activeIndices.includes(index);

        // Set color based on the selection/filter state
        if (isSelected) {
            mgraphics.set_source_rgba(1.0, 0.3, 0.3, 1.0); // Red for selected
        } else if (isFiltered) {
            mgraphics.set_source_rgba(0.7, 0.9, 1.0, 1.0); // Green for filtered
        } else {
            mgraphics.set_source_rgba(0.7, 0.9, 1.0, 1.0); // Light blue for unselected
        }

        // Map coordinates to the mgraphics window size
        let x = mapCoord(pt[1], cols) * mgraphics.size[0] / 2 + mgraphics.size[0] / 2;
        let y = mapCoord(pt[0], rows) * mgraphics.size[1] / 2 + mgraphics.size[1] / 2;

        // Draw circle at the point
        mgraphics.arc(x, y, 3, 0, Math.PI * 2);
        mgraphics.fill(); // Fill the circle with the set color
    });
}
