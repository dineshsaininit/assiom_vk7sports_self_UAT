"""Read-only QA preflight. Never resets, starts containers, authenticates or queries a DB."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import os
import subprocess

root = Path(__file__).resolve().parents[1]  # repo root
assert root.resolve() == root

def command(args):
    result = subprocess.run(args, cwd=root, capture_output=True, text=True, timeout=15)
    return {'command': args, 'exit_code': result.returncode, 'stdout': result.stdout.strip(), 'stderr': result.stderr.strip()}

compose = command(['docker', 'compose', '--env-file', '.env.docker', '-f', 'docker/compose.qa.yml', 'config', '--format', 'json'])
if compose['exit_code'] == 0:
    data = json.loads(compose.pop('stdout'))
    compose['configuration'] = {'project': data['name'], 'volumes': data['volumes'], 'services': {
        key: {field: value.get(field) for field in ['ports', 'volumes', 'networks']}
        for key, value in data['services'].items()}}
env = {}
for line in (root/'app/.env').read_text().splitlines():
    match = re.match(r'^(APP_ENV|APP_DEBUG|APP_URL|DB_CONNECTION|DB_HOST|DB_PORT|DB_DATABASE|DB_USERNAME)=(.*)$', line)
    if match:
        env[match[1]] = match[2]
lock = json.loads((root/'app/composer.lock').read_text())
b2b = next(p for p in lock['packages'] if p['name'] == 'bagisto/b2b-suite')
files = ['qa/README-CODEX.md', 'qa/reset.sh', 'qa/golden.sql.gz', 'docker/compose.qa.yml',
         'app/packages/Webkul/Core/src/Core.php', 'app/composer.lock',
         'app/packages/VK7/Wholesale/src/Providers/WholesaleServiceProvider.php',
         'app/packages/VK7/Wholesale/src/Repositories/CustomerQuoteRepository.php']
print(json.dumps({
    'captured_at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'scope': str(root), 'compose_parse': compose, 'configuration_allowlist': env,
    'bagisto_code_version': re.search(r"BAGISTO_VERSION = '([^']+)'", (root/'app/packages/Webkul/Core/src/Core.php').read_text())[1],
    'b2b_lock_version': b2b['version'], 'b2b_source_reference': b2b['source']['reference'],
    'runtime_probe': command(['docker', 'compose', '--env-file', '.env.docker', '-f', 'docker/compose.qa.yml', 'ps', '--format', 'json']),
    'http_probe': command(['curl', '--max-time', '5', '--silent', '--show-error', '--output', '/dev/null', '--write-out', 'HTTP %{http_code}', os.environ.get('QA_BASE', 'http://127.0.0.1:8100') + '/customer/login']),
    'baseline': 'LIVE BASELINE NOT VERIFIED; no DB query or reset executed',
    'source_sha256': {name: hashlib.sha256((root/name).read_bytes()).hexdigest() for name in files}
}, indent=2))
