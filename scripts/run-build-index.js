#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const repoRoot = process.cwd();
const sourceFile = path.join(repoRoot, "scripts", "build-index.ts");
const distFile = path.join(repoRoot, "dist", "scripts", "build-index.js");

function mtimeOrZero(file) {
  try {
    return fs.statSync(file).mtimeMs;
  } catch {
    return 0;
  }
}

function run(cmd, args) {
  const result = spawnSync(cmd, args, {
    stdio: "inherit",
    cwd: repoRoot,
    env: process.env,
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

const needsCompile = mtimeOrZero(distFile) < mtimeOrZero(sourceFile);
if (needsCompile) {
  run("npm", ["run", "-s", "build:ts", "--", "--pretty", "false"]);
}

run("node", [distFile, ...process.argv.slice(2)]);
