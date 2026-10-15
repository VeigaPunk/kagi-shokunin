// Read-only local dispatch prerequisite; not a routing overlay or a native judge.
// Run with Node: node .ufo/round-20/route-admission.mjs
import { readGlobalSeatRouting, parseAgentModelOverrides } from '/home/vgpnk/Projects/ufo-fsd-alpha/scripts/omp-global-config.mjs';
import { readFileSync } from 'node:fs';

const configPath = '/home/vgpnk/.omp/agent/config.yml';
const specPath = new URL('./wave/spec.json', import.meta.url);
const routing = readGlobalSeatRouting({ path: configPath });
const overrides = parseAgentModelOverrides(routing.text);
const spec = JSON.parse(readFileSync(specPath, 'utf8'));
const expected = {
  executor: '@m_composer',
  scribe: '@m_composer',
  revenger: '@m_grok',
  reviewer: '@m_grok',
  critic: '@m_grok',
  sentinel: '@m_grok',
  connector: '@m_antigravity',
};
const roles = [...new Set(spec.items.map(item => item.role))].sort();
const mismatches = [];
for (const role of roles) {
  const actual = overrides.get(role) ?? null;
  if (!expected[role] || actual !== expected[role]) {
    mismatches.push({ role, actual, required: expected[role] ?? null });
    console.log(`ROUTE_MISMATCH role=${role} actual=${actual ?? 'unbound'} required=${expected[role] ?? 'undeclared'}`);
  }
}
const aliases = ['m_composer', 'm_grok', 'm_antigravity', 'm_zfl'];
const missingAliases = aliases.filter(alias => typeof routing.modelRoles.get(alias) !== 'string');
const chain = routing.fallbackChains.get('m_antigravity') ?? [];
const zfl = routing.modelRoles.get('m_zfl');
const hasFallback = typeof zfl === 'string' && Array.isArray(chain) &&
  chain.some(hop => hop === '@m_zfl' || hop === 'm_zfl' || hop === zfl);
if (!hasFallback) console.log('ROUTE_MISMATCH fallback=m_antigravity actual=missing required=@m_zfl');
for (const alias of missingAliases) console.log(`ROUTE_MISMATCH alias=${alias} actual=absent`);
console.log(`GLOBAL_CONFIG_SHA256: ${routing.sha256}`);
const blocked = mismatches.length > 0 || missingAliases.length > 0 || !hasFallback;
console.log(`KAGI_ROUTE_ADMISSION: ${blocked ? 'BLOCKED' : 'READY'} (roles=${roles.length} mismatched=${mismatches.length} missing_aliases=${missingAliases.length} connector_fallback=${hasFallback ? 'present' : 'missing'} dispatched=0)`);
process.exitCode = blocked ? 2 : 0;
