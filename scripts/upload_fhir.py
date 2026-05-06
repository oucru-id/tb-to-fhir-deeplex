#!/usr/bin/env python3
import argparse
import json
import os
import sys
from datetime import datetime, timezone

import requests


def fetch_access_token(auth_base_url, client_id, client_secret):
    token_url = f"{auth_base_url.rstrip('/')}/protocol/openid-connect/token"
    payload = {
        "grant_type": "client_credentials",
        "client_id": client_id,
        "client_secret": client_secret,
        "scope": "openid",
    }
    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    resp = requests.post(token_url, data=payload, headers=headers, timeout=30)
    if resp.status_code != 200:
        print(f"ERROR: Token request failed ({resp.status_code}): {resp.text}", file=sys.stderr)
        sys.exit(1)

    token_data = resp.json()
    access_token = token_data.get("access_token")
    if not access_token:
        print(f"ERROR: No access_token in response: {resp.text}", file=sys.stderr)
        sys.exit(1)

    return access_token


def upload_bundle(fhir_file, fhir_server_url, access_token, api_key):
    with open(fhir_file, "r") as f:
        bundle = json.load(f)

    headers = {
        "Content-Type": "application/fhir+json",
        "Accept": "application/fhir+json",
        "Authorization": f"Bearer {access_token}",
    }
    if api_key:
        headers["X-Api-Key"] = api_key

    resp = requests.post(fhir_server_url, json=bundle, headers=headers, timeout=120)

    return resp.status_code, resp.text


def main():
    parser = argparse.ArgumentParser(description="Upload a FHIR bundle using OAuth 2.0 client credentials")
    parser.add_argument("--fhir_file", required=True, help="Path to the FHIR bundle JSON file")
    parser.add_argument("--fhir_server_url", required=True, help="FHIR server base URL (POST target)")
    parser.add_argument("--auth_base_url", default="", help="OAuth SSO base URL (e.g. https://sso.example.com/realms/myrealm)")
    parser.add_argument("--client_id", default="", help="OAuth client_id")
    parser.add_argument("--client_secret", default="", help="OAuth client_secret")
    parser.add_argument("--static_token", default="", help="Pre-existing static Bearer token (skips OAuth flow)")
    parser.add_argument("--api_key", default="", help="API key sent as X-Api-Key header")
    args = parser.parse_args()

    if args.static_token:
        access_token = args.static_token
    elif args.auth_base_url and args.client_id and args.client_secret:
        print(f"Fetching OAuth token from {args.auth_base_url}...")
        access_token = fetch_access_token(args.auth_base_url, args.client_id, args.client_secret)
        print("Token acquired.")
    else:
        print("ERROR: Provide either --static_token or all of --auth_base_url, --client_id, --client_secret", file=sys.stderr)
        sys.exit(1)

    print(f"Uploading {args.fhir_file} to {args.fhir_server_url}...")
    import time
    max_retries = 5
    for attempt in range(1, max_retries + 1):
        print(f"  attempt {attempt}/{max_retries}")
        http_status, response_body = upload_bundle(
            args.fhir_file, args.fhir_server_url, access_token, args.api_key
        )
        if http_status != 429:
            break
        wait = 2 ** attempt
        print(f"retrying in {wait}s...")
        time.sleep(wait)

    success = 200 <= http_status < 300
    timestamp = datetime.now(timezone.utc).isoformat()
    basename = os.path.basename(args.fhir_file)
    output_file = os.path.splitext(basename)[0] + ".upload.json"

    try:
        response_json = json.loads(response_body)
    except (json.JSONDecodeError, ValueError):
        response_json = response_body

    result = {
        "status": "success" if success else "failed",
        "http_status": http_status,
        "file": args.fhir_file,
        "timestamp": timestamp,
        "server": args.fhir_server_url,
        "response": response_json,
    }

    with open(output_file, "w") as f:
        json.dump(result, f, indent=2)

    print(f"Upload completed with status {http_status}")

    if not success:
        print(f"ERROR: Upload failed ({http_status}): {response_body}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
