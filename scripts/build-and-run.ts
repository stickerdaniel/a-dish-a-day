#!/usr/bin/env bun
/**
 * Build and run iOS app on simulator or physical device
 *
 * Usage: bun scripts/build-and-run.ts [options]
 * Run with --help for more information
 */

import * as p from "@clack/prompts";
import { $ } from "bun";
import { tmpdir } from "os";
import { join } from "path";

// ============================================================================
// Types
// ============================================================================

type DestinationType = "simulator" | "device";

interface Destination {
  type: DestinationType;
  udid: string;
  name: string;
  state: string;
  model?: string;
  runtimeId?: string;
}

interface ProjectConfig {
  project: string;
  scheme: string;
}

interface Simulator {
  udid: string;
  name: string;
  state: string;
  isAvailable: boolean;
}

interface SimctlListOutput {
  devices: Record<string, Simulator[]>;
}

interface DevicectlDevice {
  deviceProperties: { name: string };
  hardwareProperties: { udid: string; productType: string; platform: string };
  connectionProperties: { tunnelState: string };
}

interface DevicectlOutput {
  result: { devices: DevicectlDevice[] };
}

// ============================================================================
// CLI Parsing & Help
// ============================================================================

const args = process.argv.slice(2);
const useBooted = args.includes("--booted");
const useDevice = args.includes("--device");
const skipBuild = args.includes("--skip-build");

const deviceNameIndex = args.indexOf("--device-name");
const deviceNameFilter = deviceNameIndex !== -1 ? args[deviceNameIndex + 1] : null;

const schemeIndex = args.indexOf("--scheme");
const schemeArg = schemeIndex !== -1 ? args[schemeIndex + 1] : null;

function showHelp(): void {
  console.log(`
🍭 iOS Build & Run Script

Usage:
  bun scripts/build-and-run.ts [options]

Options:
  --help, -h       Show this help message
  --booted         Use currently booted simulator
  --device         Use first available physical device (prefers iPhone)
  --device-name    Filter device by name (e.g., --device-name "iPad")
  --scheme         Specify scheme name (e.g., --scheme "A Dish A Day")
  --skip-build     Skip build, just install and launch

Examples:
  bun scripts/build-and-run.ts                        # Interactive mode
  bun scripts/build-and-run.ts --booted               # Use booted simulator
  bun scripts/build-and-run.ts --device               # Use connected iPhone
  bun scripts/build-and-run.ts --device --skip-build  # Quick relaunch on device
`);
  process.exit(0);
}

if (args.includes("--help") || args.includes("-h")) {
  showHelp();
}

// ============================================================================
// Project Detection
// ============================================================================

async function detectProjectConfig(): Promise<ProjectConfig> {
  const spin = p.spinner();
  spin.start("Detecting project configuration...");

  try {
    // Find .xcodeproj files
    const result = await $`ls -d *.xcodeproj 2>/dev/null`.quiet().nothrow();
    const projects = result.stdout.toString().trim().split("\n").filter(Boolean);

    if (projects.length === 0) {
      spin.stop("No .xcodeproj found");
      throw new Error("No .xcodeproj found in current directory");
    }

    const project = projects[0];

    // Get schemes
    const schemesResult = await $`xcodebuild -project ${project} -list -json`.quiet();
    const data = JSON.parse(schemesResult.stdout.toString());
    const schemes: string[] = data.project.schemes;

    if (schemes.length === 0) {
      spin.stop("No schemes found");
      throw new Error("No schemes found in project");
    }

    let scheme: string;
    
    // Use --scheme argument if provided
    if (schemeArg && schemes.includes(schemeArg)) {
      scheme = schemeArg;
      spin.stop(`Found ${project} with scheme "${scheme}"`);
    } else if (schemes.length === 1) {
      scheme = schemes[0];
      spin.stop(`Found ${project} with scheme "${scheme}"`);
    } else {
      // Filter out dependency schemes (keep app schemes)
      const appSchemes = schemes.filter((s: string) => !s.includes("Mobile") && !s.includes("Package"));
      
      if (appSchemes.length === 1) {
        scheme = appSchemes[0];
        spin.stop(`Found ${project} with scheme "${scheme}"`);
      } else {
        spin.stop(`Found ${project} with ${schemes.length} schemes`);

        const selected = await p.select({
          message: "Select scheme:",
          options: schemes.map((s) => ({ value: s, label: s })),
        });

        if (p.isCancel(selected)) {
          p.cancel("Operation cancelled");
          process.exit(0);
        }

        scheme = selected as string;
      }
    }

    return { project, scheme };
  } catch (error) {
    spin.stop("Failed to detect project");
    throw error;
  }
}

// ============================================================================
// Destination Discovery
// ============================================================================

async function getSimulators(): Promise<Destination[]> {
  const result = await $`xcrun simctl list devices -j`.quiet();
  const data: SimctlListOutput = JSON.parse(result.stdout.toString());

  const destinations: Destination[] = [];
  for (const [runtimeId, devices] of Object.entries(data.devices)) {
    for (const device of devices) {
      if (device.isAvailable) {
        destinations.push({
          type: "simulator",
          udid: device.udid,
          name: device.name,
          state: device.state,
          runtimeId,
        });
      }
    }
  }

  return destinations;
}

async function getPhysicalDevices(): Promise<Destination[]> {
  try {
    const tmpFile = join(tmpdir(), `devicectl-${Date.now()}.json`);
    await $`xcrun devicectl list devices --json-output ${tmpFile}`.quiet();

    const jsonContent = await Bun.file(tmpFile).text();
    const data: DevicectlOutput = JSON.parse(jsonContent);
    await $`rm -f ${tmpFile}`.quiet();

    return data.result.devices
      .filter((d) => d.hardwareProperties.platform === "iOS")
      .map((d) => ({
        type: "device" as DestinationType,
        udid: d.hardwareProperties.udid,
        name: d.deviceProperties.name,
        state: d.connectionProperties.tunnelState === "connected" ? "connected" : "available",
        model: formatModelName(d.hardwareProperties.productType),
      }));
  } catch {
    return [];
  }
}

function formatModelName(productType: string): string {
  // Convert "iPhone16,1" to "iPhone 15 Pro" etc.
  const modelMap: Record<string, string> = {
    "iPhone16,1": "iPhone 15 Pro",
    "iPhone16,2": "iPhone 15 Pro Max",
    "iPhone15,2": "iPhone 14 Pro",
    "iPhone15,3": "iPhone 14 Pro Max",
    "iPhone17,1": "iPhone 16 Pro",
    "iPhone17,2": "iPhone 16 Pro Max",
    "iPhone18,1": "iPhone 17 Pro",
    "iPhone18,2": "iPhone 17 Pro Max",
    "iPad16,3": "iPad Pro 11-inch (M4)",
    "iPad16,4": "iPad Pro 11-inch (M4)",
    "iPad16,5": "iPad Pro 13-inch (M4)",
    "iPad16,6": "iPad Pro 13-inch (M4)",
  };
  return modelMap[productType] || productType;
}

function getRuntimeName(runtimeId: string): string {
  const match = runtimeId.match(/SimRuntime\.(.+)$/);
  if (match) {
    return match[1].replace(/-/g, " ").replace(/(\d+) (\d+)/, "$1.$2");
  }
  return runtimeId;
}

// ============================================================================
// Destination Selection
// ============================================================================

async function selectDestination(): Promise<Destination> {
  const spin = p.spinner();
  spin.start("Discovering devices and simulators...");

  const [simulators, devices] = await Promise.all([getSimulators(), getPhysicalDevices()]);

  spin.stop(`Found ${devices.length} device(s) and ${simulators.length} simulator(s)`);

  // Handle --device flag
  if (useDevice) {
    let availableDevices = devices.filter((d) => d.state === "connected" || d.state === "available");

    if (deviceNameFilter) {
      availableDevices = availableDevices.filter(
        (d) =>
          d.name.toLowerCase().includes(deviceNameFilter.toLowerCase()) ||
          d.model?.toLowerCase().includes(deviceNameFilter.toLowerCase())
      );
    } else {
      // Prefer iPhones over iPads
      const iphones = availableDevices.filter(
        (d) => d.model?.includes("iPhone") || d.name.toLowerCase().includes("iphone")
      );
      if (iphones.length > 0) availableDevices = iphones;
    }

    if (availableDevices.length > 0) {
      p.log.info(`Using device: ${availableDevices[0].name}`);
      return availableDevices[0];
    }
    p.log.error("No matching physical device available");
    process.exit(1);
  }

  // Handle --booted flag
  if (useBooted) {
    const booted = simulators.find((s) => s.state === "Booted");
    if (booted) {
      p.log.info(`Using booted simulator: ${booted.name}`);
      return booted;
    }
    p.log.error("No booted simulator found");
    process.exit(1);
  }

  // Filter and deduplicate simulators by name (keep booted ones and newest runtime)
  const iosSimulators = simulators
    .filter((s) => s.runtimeId?.includes("iOS") && s.name.includes("iPhone"))
    .sort((a, b) => {
      // Booted first
      if (a.state === "Booted" && b.state !== "Booted") return -1;
      if (b.state === "Booted" && a.state !== "Booted") return 1;
      // Then by runtime version (newer first)
      const runtimeA = a.runtimeId || "";
      const runtimeB = b.runtimeId || "";
      return runtimeB.localeCompare(runtimeA);
    });

  // Deduplicate by name, keeping first (booted or newest runtime)
  const seenNames = new Set<string>();
  const uniqueSimulators = iosSimulators.filter((s) => {
    if (seenNames.has(s.name)) return false;
    seenNames.add(s.name);
    return true;
  });

  // Build options: devices first, then simulators
  type SelectOption = { value: string; label: string; hint?: string };
  const options: SelectOption[] = [];

  // Physical devices with 📱 prefix
  for (const d of devices) {
    options.push({
      value: d.udid,
      label: `📱 ${d.name}`,
      hint: d.model || "Physical Device",
    });
  }

  // Simulators with 💻 prefix
  for (const s of uniqueSimulators) {
    options.push({
      value: s.udid,
      label: `💻 ${s.name}`,
      hint: s.state === "Booted" ? "🟢 Booted" : getRuntimeName(s.runtimeId || ""),
    });
  }

  if (options.length === 0) {
    p.log.error("No destinations available");
    process.exit(1);
  }

  const selected = await p.select({
    message: "Select destination:",
    options: options.map((o) => ({
      value: o.value,
      label: o.label,
      hint: o.hint,
    })),
  });

  if (p.isCancel(selected)) {
    p.cancel("Operation cancelled");
    process.exit(0);
  }

  const destination = [...devices, ...uniqueSimulators].find((d) => d.udid === selected);
  if (!destination) {
    p.log.error("Failed to find selected destination");
    process.exit(1);
  }

  return destination;
}

// ============================================================================
// Build Operations
// ============================================================================

async function buildApp(destination: Destination, config: ProjectConfig): Promise<string> {
  const spin = p.spinner();
  spin.start(`Building ${config.scheme} for ${destination.name}...`);

  try {
    const xcodeDest =
      destination.type === "simulator"
        ? `platform=iOS Simulator,name=${destination.name}`
        : `platform=iOS,id=${destination.udid}`;

    const productDir = destination.type === "simulator" ? "Debug-iphonesimulator" : "Debug-iphoneos";

    await $`xcodebuild -project ${config.project} -scheme ${config.scheme} -destination ${xcodeDest} build`.quiet();

    spin.stop("Build succeeded");

    // Find built app
    const findResult =
      await $`find ~/Library/Developer/Xcode/DerivedData -name "*.app" -path "*/${productDir}/*" -type d`.quiet();
    const appPaths = findResult.stdout
      .toString()
      .trim()
      .split("\n")
      .filter((p) => p && !p.includes("Index.noindex"));

    if (appPaths.length === 0) {
      throw new Error("Could not find built app");
    }

    return appPaths[0];
  } catch (error) {
    spin.stop("Build failed");
    throw error;
  }
}

async function findExistingApp(destination: Destination): Promise<string> {
  const productDir = destination.type === "simulator" ? "Debug-iphonesimulator" : "Debug-iphoneos";

  const findResult =
    await $`find ~/Library/Developer/Xcode/DerivedData -name "*.app" -path "*/${productDir}/*" -type d`.quiet();
  const paths = findResult.stdout
    .toString()
    .trim()
    .split("\n")
    .filter((p) => p && !p.includes("Index.noindex"));

  if (!paths[0]) {
    throw new Error("No built app found. Run without --skip-build first.");
  }

  return paths[0];
}

async function getBundleId(appPath: string): Promise<string> {
  const result = await $`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${appPath}/Info.plist"`.quiet();
  return result.stdout.toString().trim();
}

// ============================================================================
// Simulator Operations
// ============================================================================

async function bootSimulator(destination: Destination): Promise<void> {
  if (destination.type !== "simulator" || destination.state === "Booted") {
    return;
  }

  const spin = p.spinner();
  spin.start(`Booting ${destination.name}...`);

  await $`xcrun simctl boot ${destination.udid}`.quiet();
  await $`open -a Simulator`.quiet();
  await Bun.sleep(3000);

  spin.stop("Simulator ready");
}

async function installOnSimulator(destination: Destination, appPath: string): Promise<void> {
  const spin = p.spinner();
  spin.start("Installing app on simulator...");
  await $`xcrun simctl install ${destination.udid} ${appPath}`.quiet();
  spin.stop("App installed");
}

async function launchOnSimulator(destination: Destination, bundleId: string): Promise<void> {
  const spin = p.spinner();
  spin.start(`Launching ${bundleId}...`);

  const result = await $`xcrun simctl launch ${destination.udid} ${bundleId}`.quiet();
  const output = result.stdout.toString().trim();
  const pid = output.split(": ")[1];

  spin.stop(`App launched (PID: ${pid})`);
}

// ============================================================================
// Device Operations
// ============================================================================

async function installOnDevice(destination: Destination, appPath: string): Promise<void> {
  const spin = p.spinner();
  spin.start("Installing app on device...");
  await $`xcrun devicectl device install app --device ${destination.udid} ${appPath}`.quiet();
  spin.stop("App installed");
}

async function launchOnDevice(destination: Destination, bundleId: string): Promise<void> {
  const spin = p.spinner();
  spin.start(`Launching ${bundleId}...`);

  const tmpFile = join(tmpdir(), `launch-${Date.now()}.json`);
  const result =
    await $`xcrun devicectl device process launch --terminate-existing --json-output ${tmpFile} --device ${destination.udid} ${bundleId}`
      .quiet()
      .nothrow();

  if (result.exitCode !== 0) {
    const errorStr = result.stderr.toString();
    await $`rm -f ${tmpFile}`.quiet();

    if (errorStr.includes("code signature") || errorStr.includes("trusted by the user")) {
      spin.stop("Launch blocked - developer profile not trusted");
      p.log.warn("Developer profile not trusted on device!");
      p.log.info("On your iPhone, go to:");
      p.log.info("Settings > General > VPN & Device Management");
      p.log.info("Then trust your developer profile.");
      p.note("App is installed - launch it manually or trust the profile and re-run.");
      return;
    }

    spin.stop("Launch failed");
    throw new Error(`Launch failed: ${errorStr}`);
  }

  try {
    const jsonContent = await Bun.file(tmpFile).text();
    const jsonResult = JSON.parse(jsonContent);
    await $`rm -f ${tmpFile}`.quiet();

    if (jsonResult.info?.outcome === "success") {
      const pid = jsonResult.result?.process?.processIdentifier;
      spin.stop(`App launched${pid ? ` (PID: ${pid})` : ""}`);
    } else {
      spin.stop("App launched");
    }
  } catch {
    await $`rm -f ${tmpFile}`.quiet();
    spin.stop("App launched");
  }
}

// ============================================================================
// Main
// ============================================================================

async function main() {
  p.intro("🍭 iOS Build & Run");

  try {
    // Detect project configuration
    const config = await detectProjectConfig();

    // Select destination
    const destination = await selectDestination();

    // Build or find existing app
    let appPath: string;
    if (skipBuild) {
      p.log.info("Skipping build...");
      appPath = await findExistingApp(destination);
    } else {
      appPath = await buildApp(destination, config);
    }

    // Get bundle ID
    const bundleId = await getBundleId(appPath);
    p.log.info(`Bundle ID: ${bundleId}`);

    // Install and launch
    if (destination.type === "simulator") {
      await bootSimulator(destination);
      await installOnSimulator(destination, appPath);
      await launchOnSimulator(destination, bundleId);
    } else {
      await installOnDevice(destination, appPath);
      await launchOnDevice(destination, bundleId);
    }

    p.outro("✨ Done!");
  } catch (error) {
    p.log.error(String(error));
    process.exit(1);
  }
}

main();
