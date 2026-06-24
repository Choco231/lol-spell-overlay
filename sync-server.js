const http = require("node:http");
const os = require("node:os");

const PORT = Number(process.env.LOL_SPELL_SYNC_PORT || 17898);
const LANES = ["TOP", "JUG", "MID", "ADC", "SUP"];
const ALLOWED_ROOMS = new Set(["team1", "team2", "team3"]);
const defaultState = {
  slots: [
    [{ id: "SummonerFlash", startedAt: 0, duration: 0 }, { id: "SummonerTeleport", startedAt: 0, duration: 0 }],
    [{ id: "SummonerFlash", startedAt: 0, duration: 0 }],
    [{ id: "SummonerFlash", startedAt: 0, duration: 0 }, { id: "SummonerDot", startedAt: 0, duration: 0 }],
    [{ id: "SummonerFlash", startedAt: 0, duration: 0 }, { id: "SummonerHeal", startedAt: 0, duration: 0 }],
    [{ id: "SummonerFlash", startedAt: 0, duration: 0 }, { id: "SummonerExhaust", startedAt: 0, duration: 0 }]
  ],
  mods: LANES.map(() => ({ cosmic: false, ionian: false, unleashed: false })),
  updatedAt: Date.now()
};

let state = structuredClone(defaultState);
const states = new Map([["team1", state]]);
const clients = new Map();

function normalizeRoom(value) {
  const normalized = String(value || "team1")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 32);
  return normalized || "team1";
}

function roomFromRequest(req) {
  const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  return normalizeRoom(url.searchParams.get("room"));
}

function isAllowedRoom(room) {
  return ALLOWED_ROOMS.has(room);
}

function stateForRoom(room) {
  if (!states.has(room)) {
    states.set(room, structuredClone(defaultState));
  }
  return states.get(room);
}

function clientsForRoom(room) {
  if (!clients.has(room)) {
    clients.set(room, new Set());
  }
  return clients.get(room);
}

function sendJson(res, code, data) {
  res.writeHead(code, {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json; charset=utf-8"
  });
  res.end(JSON.stringify(data));
}

function broadcast(room) {
  const payload = `event: state\ndata: ${JSON.stringify(stateForRoom(room))}\n\n`;
  for (const res of clientsForRoom(room)) {
    try {
      res.write(payload);
    } catch {
      clientsForRoom(room).delete(res);
    }
  }
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", chunk => {
      body += chunk;
      if (body.length > 1_000_000) {
        reject(new Error("body too large"));
        req.destroy();
      }
    });
    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

function localAddresses() {
  const entries = [];
  for (const items of Object.values(os.networkInterfaces())) {
    for (const item of items || []) {
      if (item.family === "IPv4" && !item.internal) entries.push(item.address);
    }
  }
  return entries;
}

const server = http.createServer(async (req, res) => {
  if (req.method === "OPTIONS") {
    return sendJson(res, 204, {});
  }

  if (req.method === "GET" && req.url === "/health") {
    return sendJson(res, 200, { ok: true, port: PORT, rooms: [...ALLOWED_ROOMS] });
  }

  const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  const pathname = url.pathname;
  const room = roomFromRequest(req);

  if (!isAllowedRoom(room)) {
    return sendJson(res, 400, { ok: false, error: "invalid room", rooms: [...ALLOWED_ROOMS] });
  }

  if (req.method === "GET" && pathname === "/state") {
    return sendJson(res, 200, { room, ...stateForRoom(room) });
  }

  if (req.method === "GET" && pathname === "/events") {
    res.writeHead(200, {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "text/event-stream; charset=utf-8",
      "Cache-Control": "no-cache, no-transform",
      "Connection": "keep-alive"
    });
    clientsForRoom(room).add(res);
    res.write(`event: state\ndata: ${JSON.stringify({ room, ...stateForRoom(room) })}\n\n`);
    req.on("close", () => clientsForRoom(room).delete(res));
    return;
  }

  if (req.method === "POST" && pathname === "/state") {
    try {
      const body = await readBody(req);
      const nextState = JSON.parse(body || "{}");
      if (!Array.isArray(nextState.slots) || !Array.isArray(nextState.mods)) {
        return sendJson(res, 400, { ok: false, error: "invalid state" });
      }
      state = {
        slots: nextState.slots,
        mods: nextState.mods,
        updatedAt: Date.now()
      };
      states.set(room, state);
      broadcast(room);
      return sendJson(res, 200, { ok: true, room });
    } catch (error) {
      return sendJson(res, 400, { ok: false, error: String(error.message || error) });
    }
  }

  sendJson(res, 404, { ok: false, error: "not found" });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log("");
  console.log("LoL Spell Sync Server is running.");
  console.log(`Port: ${PORT}`);
  console.log("");
  console.log("Client URL examples:");
  console.log(`  http://<server-public-ip>:${PORT}`);
  console.log("");
  console.log("Detected local addresses:");
  for (const address of localAddresses()) {
    console.log(`  http://${address}:${PORT}`);
  }
  console.log("");
  console.log("Press Ctrl+C to stop.");
});
