#!/usr/bin/env node

// Fails when shipped files change without a version bump. Compares the working
// tree against a base commit (default HEAD^1: on a pull_request checkout HEAD is
// the merge commit, so its first parent is the tip of the base branch).
//
//   node scripts/check-version.mjs [base-ref]

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import path from "node:path";
import process from "node:process";

const marketplacePath = ".cursor-plugin/marketplace.json";
const versionPattern = /^(\d+)\.(\d+)\.(\d+)$/;

const base = process.argv[2] ?? "HEAD^1";
const errors = [];

function git(...args) {
  return execFileSync("git", args, { encoding: "utf8" });
}

function readJsonAt(ref, filePath) {
  try {
    return JSON.parse(git("show", `${ref}:${filePath}`));
  } catch {
    return null;
  }
}

function readJson(filePath) {
  return JSON.parse(readFileSync(filePath, "utf8"));
}

function parseVersion(version, context) {
  const match = versionPattern.exec(version ?? "");
  if (!match) {
    errors.push(`${context}: "${version}" is not a MAJOR.MINOR.PATCH version`);
    return null;
  }
  return match.slice(1).map(Number);
}

function isGreater(a, b) {
  for (let i = 0; i < 3; i++) {
    if (a[i] !== b[i]) return a[i] > b[i];
  }
  return false;
}

function requireBump(context, baseVersion, headVersion) {
  const parsedHead = parseVersion(headVersion, context);
  const parsedBase = parseVersion(baseVersion, `${context} on ${base}`);
  if (!parsedHead || !parsedBase) return;
  if (!isGreater(parsedHead, parsedBase)) {
    errors.push(`${context}: version ${headVersion} must be greater than ${baseVersion} on ${base}`);
  } else {
    console.log(`${context}: ${baseVersion} -> ${headVersion}`);
  }
}

const changed = git("diff", "--name-only", base, "--")
  .split("\n")
  .filter(Boolean);
const isUnder = (dir) => changed.some((file) => file.startsWith(`${dir}/`));

const marketplace = readJson(marketplacePath);

for (const plugin of marketplace.plugins ?? []) {
  const dir = path.posix.normalize(plugin.source);
  if (!isUnder(dir)) continue;

  const manifestPath = `${dir}/.cursor-plugin/plugin.json`;
  const baseManifest = readJsonAt(base, manifestPath);
  const headManifest = readJson(manifestPath);
  if (!baseManifest) {
    parseVersion(headManifest.version, manifestPath);
    console.log(`${manifestPath}: new plugin at ${headManifest.version}`);
    continue;
  }
  requireBump(manifestPath, baseManifest.version, headManifest.version);
}

if (isUnder("plugins") || isUnder(".cursor-plugin")) {
  const baseMarketplace = readJsonAt(base, marketplacePath);
  requireBump(
    `${marketplacePath} metadata.version`,
    baseMarketplace?.metadata?.version,
    marketplace.metadata?.version,
  );
} else {
  console.log("No changes under plugins/ or .cursor-plugin/, no version bump needed.");
}

if (errors.length > 0) {
  for (const error of errors) console.error(`error: ${error}`);
  process.exit(1);
}
