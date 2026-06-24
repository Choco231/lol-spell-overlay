const http = require("node:http");
const os = require("node:os");

const PORT = Number(process.env.LOL_SPELL_SYNC_PORT || 17898);
const LANES = ["TOP", "JUG", "MID", "ADC", "SUP"];
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
const clients = new Set();

function sendJson(res, code, data) {
  res.writeHead(code, {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json; charset=utf-8"
  });
  res.end(JSON.stringify(data));
}

function broadcast() {
  const payload = `event: state\ndata: ${JSON.stringify(state)}\n\n`;
  for (const res of clients) {
    try {
      res.write(payload);
    } catch {
      clients.delete(res);
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
    return sendJson(res, 200, { ok: true, port: PORT });
  }

  if (req.method === "GET" && req.url === "/state") {
    return sendJson(res, 200, state);
  }

  if (req.method === "GET" && req.url === "/events") {
    res.writeHead(200, {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "text/event-stream; charset=utf-8",
      "Cache-Control": "no-cache, no-transform",
      "Connection": "keep-alive"
    });
    clients.add(res);
    res.write(`event: state\ndata: ${JSON.stringify(state)}\n\n`);
    req.on("close", () => clients.delete(res));
    return;
  }

  if (req.method === "POST" && req.url === "/state") {
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
      broadcast();
      return sendJson(res, 200, { ok: true });
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
  console.log("Share one of these addresses with clients on the same network:");
  for (const address of localAddresses()) {
    console.log(`  http://${address}:${PORT}`);
  }
  console.log("");
  console.log("Press Ctrl+C to stop.");
});
