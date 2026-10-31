"""Shared, environment-driven settings for VK7 QA scripts (F8). Holds no credentials.

Values come from the environment (load .env.docker first, e.g. `set -a; . ./.env.docker; set +a`).
Secrets are read from env vars, or from files in QA_SECRETS_DIR (untracked, chmod 600).
"""
import os, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))  # repo root
BASE = os.environ.get("QA_BASE", "http://127.0.0.1:8100")
MAILPIT = os.environ.get("QA_MAILPIT", "http://127.0.0.1:8125")
DB_NAME = os.environ.get("QA_DB_NAME", "bagisto_qa")
SECRETS_DIR = os.environ.get("QA_SECRETS_DIR", os.path.join(ROOT, ".local-secrets"))
ADMIN_2FA = os.environ.get("QA_ADMIN_2FA", "0") == "1"


def env(name, default):
    return os.environ.get(name, default)


def required(name):
    value = os.environ.get(name)
    if not value:
        sys.exit(f"missing environment variable {name} (see .env.docker.example)")
    return value


def cred(name, filename):
    """Env var first, else QA_SECRETS_DIR/filename. Never printed."""
    value = os.environ.get(name)
    if value:
        return value
    path = os.path.join(SECRETS_DIR, filename)
    if os.path.exists(path):
        return open(path).read().strip()
    sys.exit(f"missing credential: set {name} or create {path} (chmod 600)")
