// Fails when the baseline version or the Prettier version disagree between the workflow, package.json and README.
import { readFileSync } from "node:fs";

const workflow = readFileSync(".github/workflows/prettier-baseline.yml", "utf8");
const readme = readFileSync("README.md", "utf8");
const pkg = JSON.parse(readFileSync("package.json", "utf8"));

const declared = (name) => workflow.match(new RegExp(`^  ${name}: (\\S+)$`, "m"))?.[1];
const baseline = declared("BASELINE_VERSION");
const prettier = declared("PRETTIER_VERSION");

const problems = [];
if (!baseline) problems.push("prettier-baseline.yml declares no BASELINE_VERSION");
if (!prettier) problems.push("prettier-baseline.yml declares no PRETTIER_VERSION");
if (pkg.devDependencies?.prettier !== prettier) {
  problems.push(`package.json pins prettier ${pkg.devDependencies?.prettier}, the workflow uses ${prettier}`);
}
for (const text of [
  `Current version: \`${baseline}\` (Prettier \`${prettier}\`)`,
  `prettier-baseline.yml@${baseline}`,
  `"prettier": "${prettier}"`,
]) {
  if (!readme.includes(text)) problems.push(`README.md does not contain ${text}`);
}

if (problems.length) {
  for (const problem of problems) console.error(`check-baseline-versions: ${problem}`);
  process.exit(1);
}
console.log(`check-baseline-versions: ${baseline}, Prettier ${prettier} agree everywhere.`);
