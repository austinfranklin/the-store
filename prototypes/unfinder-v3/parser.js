var stack = [];
var channels = {}; // future use

function anything() {
    var args = arrayfromargs(messagename, arguments);
    parse(args);
}

function parse(lines) {
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i].toString().trim();
        if (line.length === 0) continue;

        if (line.charAt(0) === '>') {
            var cmd = line.slice(1).toLowerCase();
            handleCommand(cmd);
        } else {
            handleValue(line);
        }
    }
}

function handleValue(val) {
    if (!isNaN(val)) {
        stack.push(parseFloat(val));
    } else {
        stack.push(val);
    }
    logStack();
}

function handleCommand(cmd) {
    if (cmd === "fn") {
        find();
    } else if (cmd === "sc") {
        schedule();
    } else if (cmd === "lp") {
        loop();
    } else if (cmd === "vo") {
        volume();
    } else if (cmd === "ln") {
        lerpNumber();
    } else if (cmd === "pp") {
        pop();
    } else if (cmd === "et") {
        edit();
    } else {
        post("Unknown command: " + cmd + "\n");
    }
}

function find() {
    var features = [];
    while (stack.length && typeof stack[stack.length - 1] !== "number") {
        features.push(stack.pop());
    }
    features.reverse();
    post("Find sample with features: " + features.join(", ") + "\n");
}

function schedule() {
    if (stack.length) {
        var time = stack.pop();
        post("Scheduling event at time: " + time + "ms\n");
    } else {
        post("Error: no time value on stack\n");
    }
}

function loop() {
    if (stack.length) {
        var bool = stack.pop();
        post("Setting looping to: " + (bool ? "ON" : "OFF") + "\n");
    } else {
        post("Error: no boolean value for loop\n");
    }
}

function volume() {
    if (stack.length >= 2) {
        var targetVol = stack.pop();
        var time = stack.pop();
        post("Ramping volume to " + targetVol + " over " + time + "ms\n");
    } else if (stack.length === 1) {
        var targetVol = stack.pop();
        post("Setting immediate volume to " + targetVol + "\n");
    } else {
        post("Muting track (no values on stack)\n");
    }
}

function lerpNumber() {
    if (stack.length >= 2) {
        var targetVal = stack.pop();
        var time = stack.pop();
        post("Ramping number to " + targetVal + " over " + time + "ms\n");
    } else {
        post("Error: not enough values to ramp\n");
    }
}

function pop() {
    if (stack.length) {
        var popped = stack.pop();
        post("Popped: " + popped + "\n");
    } else {
        post("Pop error: stack empty\n");
    }
}

function edit() {
    var features = [];
    while (stack.length && typeof stack[stack.length - 1] !== "number") {
        features.push(stack.pop());
    }
    features.reverse();
    post("Edit track with features: " + features.join(", ") + "\n");
}

function logStack() {
    post("Stack: " + JSON.stringify(stack) + "\n");
}
