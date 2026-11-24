.pragma library

// The settings and what they may be: a switch, a choice, or a whole number in a range.
const items = {
    gridFollow:     { kind: "bool", fallback: true },
    gridColor:      { kind: "color", fallback: "#39d353" },
    showStreaks:    { kind: "bool", fallback: true },
    showLegend:     { kind: "bool", fallback: true },
    showCards:      { kind: "bool", fallback: true },
    showIcon:       { kind: "bool", fallback: true },
    days:           { kind: "int", fallback: 7, min: 3, max: 14, step: 1 },
    squareSize:     { kind: "int", fallback: 9, min: 6, max: 14, step: 1 },
    squareRound:    { kind: "int", fallback: 2, min: 0, max: 7, step: 1 },
    clickAction:    { kind: "enum", fallback: "panel", options: ["panel", "refresh", "none"] },
    middleAction:   { kind: "enum", fallback: "refresh", options: ["refresh", "panel", "none"] },
    openAs:         { kind: "enum", fallback: "panel", options: ["panel", "window"] },
    windowWidth:    { kind: "int", fallback: 860, min: 720, max: 1200, step: 20 },
    windowHeight:   { kind: "int", fallback: 560, min: 440, max: 1000, step: 20 },
    autoRefresh:    { kind: "bool", fallback: true },
    refreshMinutes: { kind: "int", fallback: 30, min: 5, max: 240, step: 5 }
};

function isHex(v) { return typeof v === "string" && /^#[0-9a-fA-F]{6}$/.test(v); }

// one value, made safe; anything it may not be is the default
function clean(key, v) {
    const it = items[key];
    if (it.kind === "bool") return typeof v === "boolean" ? v : it.fallback;
    if (it.kind === "enum") return it.options.indexOf(v) >= 0 ? v : it.fallback;
    if (it.kind === "color") return isHex(v) ? v.toLowerCase() : it.fallback;
    return typeof v === "number" && isFinite(v) ? Math.max(it.min, Math.min(it.max, Math.round(v))) : it.fallback;
}

function resolve(saved) {
    const src = saved && typeof saved === "object" ? saved : {};
    const out = {};
    for (const k in items) out[k] = clean(k, src[k]);
    return out;
}
