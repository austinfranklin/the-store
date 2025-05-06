autowatch = 1;

mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

// UI + Terminal state
var lines = [];
var prompt = "> ";
var input = "";
var commandHistory = [];
var historyIndex = -1;
var maxHistory = 50;
var maxVisibleLines = 30;
var cursorVisible = true;
var cursorPos = 0;  // Cursor position within the input text
var width = mgraphics.size[0];
var height = mgraphics.size[1];
var lineHeight = 16;

// Cursor blink
var blinkTask = new Task(toggleCursor, this);
blinkTask.interval = 500;
blinkTask.repeat();

function msg_int(ascii) {
    // Backspace or Delete
    if (ascii === 8 || ascii === 127) {
        input = input.slice(0, -1);
        cursorPos = Math.max(0, cursorPos - 1);
    }
    // Enter key
    else if (ascii === 13) {
        if (input.trim().length > 0) {
            lines.push(prompt + input);
            commandHistory.push(input);

            if (commandHistory.length > maxHistory) {
                commandHistory = commandHistory.slice(-maxHistory);
            }

            outlet(0, input);
        } else {
            lines.push(prompt);
            outlet(0, "");
        }

        input = "";
        historyIndex = -1;
        cursorPos = 0;
    }
    // Up arrow
    else if (ascii === 30) {
        if (commandHistory.length > 0) {
            if (historyIndex < commandHistory.length - 1) {
                historyIndex++;
                input = commandHistory[commandHistory.length - 1 - historyIndex];
                cursorPos = input.length;
            }
        }
    }
    // Down arrow
    else if (ascii === 31) {
        if (historyIndex > 0) {
            historyIndex--;
            input = commandHistory[commandHistory.length - 1 - historyIndex];
            cursorPos = input.length;
        } else {
            historyIndex = -1;
            input = "";
            cursorPos = 0;
        }
    }
    // Left arrow
    else if (ascii === 28) {
        cursorPos = Math.max(0, cursorPos - 1);
    }
    // Right arrow
    else if (ascii === 29) {
        cursorPos = Math.min(input.length, cursorPos + 1);
    }
    // Printable characters
    else if (ascii >= 32 && ascii <= 126) {
        input = input.slice(0, cursorPos) + String.fromCharCode(ascii) + input.slice(cursorPos);
        cursorPos++;
    }

    if (lines.length > 1000) {
        lines = lines.slice(-1000);
    }

    mgraphics.redraw();
}

function toggleCursor() {
    cursorVisible = !cursorVisible;
    mgraphics.redraw();
}

function paint() {
    mgraphics.set_source_rgba(0, 0, 0, 0);
    mgraphics.rectangle(0, 0, width, height);
    mgraphics.fill();

    mgraphics.set_source_rgba(1, 1, 0.5, 0.25);
    mgraphics.select_font_face("Courier");
    mgraphics.set_font_size(14);

    var displayLines = lines.slice(-maxVisibleLines);
    var yStart = height - (displayLines.length + 1) * lineHeight;

    for (var i = 0; i < displayLines.length; i++) {
        var y = yStart + i * lineHeight;
        mgraphics.move_to(10, y);
        mgraphics.show_text(displayLines[i]);
    }

    mgraphics.move_to(10, height - lineHeight);
    mgraphics.show_text(prompt + input.slice(0, cursorPos) + (cursorVisible ? "|" : "") + input.slice(cursorPos));
}

// Handle incoming text
function anything() {
    var txt = arrayfromargs(messagename, arguments).join(" ");
    lines.push("> PRINT: " + txt);

    if (lines.length > 1000) {
        lines = lines.slice(-1000);
    }

    mgraphics.redraw();
}
