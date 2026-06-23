#!/usr/bin/env python3

import csv
import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# ================= CONFIG =================

TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IndoMDZzRWt6TEhKNXNOTmFVeVJZMl82TzhLMCIsImtpZCI6IndoMDZzRWt6TEhKNXNOTmFVeVJZMl82TzhLMCJ9.eyJhdWQiOiJhcGk6Ly9jOGMwZWIyOS1kN2M0LTRmZTgtODZmOC1kMzE5M2ZlY2VkMjAiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8yMTNjZTJkZC0zNzlkLTQ1NjUtYWRiNy04MjhiNWQ5NmUwMzEvIiwiaWF0IjoxNzgyMjExNDEwLCJuYmYiOjE3ODIyMTE0MTAsImV4cCI6MTc4MjIxNTg2NywiYWNyIjoiMSIsImFpbyI6IkFhUUFXLzhjQUFBQXlkZkhXN09FYUxkUmo1QnpxWVhMNklKQjNZQ1hCNjZuQTVvcXhIMFZXQVdaSmNhVTVNVzVqNFNMbWEvZmFOMEk3Zkk3TU54UXFiZlU3OWlnWUpWT25aSWV3ZytHa09FOW9Ga0tHNnBUTGdJenZWSXF3ZytLSU1pcEpRK2JqQlViVlFCdWtVR2dxZ2JlRTIxUGNmRU80UHZNOXdkRU9BVjBpS3lxN2Q4akM4c0JlZ0FxQVlSV2tCN3ZIQ1JqQThhUUM1QjA1Y3JUUDBVbkFHRFRENUxsWFE9PSIsImFtciI6WyJwd2QiLCJtZmEiXSwiYXBwaWQiOiJjOGMwZWIyOS1kN2M0LTRmZTgtODZmOC1kMzE5M2ZlY2VkMjAiLCJhcHBpZGFjciI6IjAiLCJkZXZpY2VpZCI6IjZlODNhNjUxLTY3NjctNDI2OC1iNmQxLTI3MDNhNDY5OWQxOSIsImZhbWlseV9uYW1lIjoiRGhpcmFqIiwiZ2l2ZW5fbmFtZSI6IkRoaXJhaiIsImlwYWRkciI6IjEwMy4xNzkuOC4xNTUiLCJuYW1lIjoiRGhpcmFqIERoaXJhaihWZWVyc2EpIiwib2lkIjoiYmUzNzcwYTUtMTVmOC00ZWRjLWJkYjctOGQ4MGMzYWVmOWEzIiwib25wcmVtX3NpZCI6IlMtMS01LTIxLTQxMzY2NTQ3MzQtMjE5MjgyMzk4MC0xNjY1ODYxODgwLTUxMjMiLCJyaCI6IjEuQVhFQjNlSThJWjAzWlVXdHQ0S0xYWmJnTVNucndNakUxLWhQaHZqVEdUX3M3U0FBQUZ4eEFRLiIsInNjcCI6ImFwaV9hY2Nlc3MiLCJzaWQiOiIwMDVmMTdkYS0yMjcxLWRjNzEtNTFlYy04Zjg4NmY2ZGRlOTkiLCJzdWIiOiJveXBwMDlXcUZWU3QyUHFhTFotbmIyVGxiLVViRnpKTk4wLXZ3ZDIyRU9rIiwidGlkIjoiMjEzY2UyZGQtMzc5ZC00NTY1LWFkYjctODI4YjVkOTZlMDMxIiwidW5pcXVlX25hbWUiOiJkaGlyYWouZGhpcmFqQG5lb3ZhbmNlLmNvbSIsInVwbiI6ImRoaXJhai5kaGlyYWpAbmVvdmFuY2UuY29tIiwidXRpIjoiRktMbTRhY29nRU9rakFHVkF2b0lBQSIsInZlciI6IjEuMCIsInhtc19mdGQiOiIwalB2MzZOWTVtQmNoamhibElnbUFkZDFKTS1GaENEMklZSHdyb1NVXzRZQmRYTmxZWE4wTFdSemJYTSJ9.kjisqget7a2X3a1Qj84Q-tcS4vGeAwEcP23v_QfRFne4C2QepzWBIcpsOG89AUGqqCoWIrvPzqpo_3xJb0GWBdWfXcv7jyryPhRnzSGTbkwkQWj8q3I2rZRirK4r-IZ0r1ei2mOBDfGuXw4E0RlE2RWqLI0qp4_gJ-PKzihHFypDbGJJXoQ8Glaku6rD6pTBXX9akpRRkWDx8Hj1GzrF0jfFtOZhwGMcQIOxhx79zHHvBpjWUWEc3ElIk_TbBxEaOpHR0PY8ZDXJ9PvFzty5zFeBW4s5_332bE5npfC_1ZDjOhX-T-wpenfhM8Z9UonDfbjpFzpMGYjnihmIXTWkmQ"

TENANT_ID = "1003"

BASE_URL = "https://qaapi.app-np.neovance.com/api/workflow"

INPUT_FILE = "records.csv"
# CSV must have columns: tmissinginfovalidationid, instanceId, ordercasetaskid

SUCCESS_FILE = "success.jsonl"
FAILED_FILE = "failed.jsonl"

CONCURRENCY = 5
BATCH_DELAY_SEC = 10
REQUEST_TIMEOUT = 120

INTERRUPT_SIGNAL = "stopCurrentFlow"

COMPLETE_TASK_PAYLOAD = {
    "entityId": "32",
    "layoutId": "53"
}

# ==========================================


def get_headers(token):
    return {
        "accept": "application/json, text/plain, */*",
        "authorization": f"Bearer {token}",
        "content-type": "application/json",
        "x-tenantid": TENANT_ID,
    }


def create_session():
    session = requests.Session()
    adapter = HTTPAdapter(max_retries=Retry(
        total=3,
        backoff_factor=2,
        status_forcelist=[500, 502, 503, 504],
        allowed_methods=["PATCH", "POST"],
    ))
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    return session


def load_records(csv_file):
    records = []
    with open(csv_file, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        required = {"tmissinginfovalidationid", "instanceId", "ordercasetaskid"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Missing columns in CSV: {missing}")
        for row in reader:
            records.append({
                "tmissinginfovalidationid": row["tmissinginfovalidationid"].strip(),
                "instanceId": row["instanceId"].strip(),
                "ordercasetaskid": row["ordercasetaskid"].strip(),
                "case_id": row["case_id"].strip()
            })
    return records


def is_token_error(status_code):
    return status_code in (401, 403)


def complete_task(session, token, task_id, step_label):
    """PATCH /v2/process/task/{task_id}?state=COMPLETED&forced=true"""
    url = f"{BASE_URL}/v2/process/task/{task_id}"
    try:
        response = session.patch(
            url,
            headers=get_headers(token),
            params={"state": "COMPLETED", "forced": "true"},
            json=COMPLETE_TASK_PAYLOAD,
            timeout=REQUEST_TIMEOUT,
        )
        body = _parse_body(response)
        return {
            "step": step_label,
            "status_code": response.status_code,
            "ok": response.ok,
            "response": body,
            "token_expired": is_token_error(response.status_code),
        }
    except Exception as e:
        return {"step": step_label, "status_code": None, "ok": False, "error": str(e), "token_expired": False}


def interrupt_instance(session, token, instance_id):
    """POST /v2/process/{instanceId}/interrupt?signal=stopCurrentFlow"""
    url = f"{BASE_URL}/v2/process/{instance_id}/interrupt"
    try:
        response = session.post(
            url,
            headers=get_headers(token),
            params={"signal": INTERRUPT_SIGNAL},
            timeout=REQUEST_TIMEOUT,
        )
        body = _parse_body(response)
        return {
            "step": "interrupt",
            "status_code": response.status_code,
            "ok": response.ok,
            "response": body,
            "token_expired": is_token_error(response.status_code),
        }
    except Exception as e:
        return {"step": "interrupt", "status_code": None, "ok": False, "error": str(e), "token_expired": False}


def _parse_body(response):
    try:
        return response.json()
    except Exception:
        return response.text


def process_record(session, token_holder, record):
    """
    Runs the 3-step sequence for one record.
    token_holder is a mutable dict {"token": "..."} so threads can read refreshed token.
    Returns (success: bool, result_dict, token_expired: bool)
    """
    rec_id = record["tmissinginfovalidationid"]
    instance_id = record["instanceId"]
    task_id = record["ordercasetaskid"]
    case_id = record["case_id"]

    steps = []

    # Step 1: Complete task (ordercasetaskid)
    r1 = complete_task(session, token_holder["token"], rec_id, "complete_task_1")
    steps.append(r1)
    if r1["token_expired"]:
        return False, _build_result(record, steps, "TOKEN_EXPIRED"), True
    if not r1["ok"]:
        return False, _build_result(record, steps, "FAILED_AT_COMPLETE_TASK_1"), False

    # Step 2: Interrupt instance
    r2 = interrupt_instance(session, token_holder["token"], instance_id)
    steps.append(r2)
    if r2["token_expired"]:
        return False, _build_result(record, steps, "TOKEN_EXPIRED"), True
    if not r2["ok"]:
        return False, _build_result(record, steps, "FAILED_AT_INTERRUPT"), False

    # Step 3: Complete task again (same task_id)
    r3 = complete_task(session, token_holder["token"], task_id, "complete_task_2")
    steps.append(r3)
    if r3["token_expired"]:
        return False, _build_result(record, steps, "TOKEN_EXPIRED"), True
    if not r3["ok"]:
        return False, _build_result(record, steps, "FAILED_AT_COMPLETE_TASK_2"), False

    return True, _build_result(record, steps, "SUCCESS"), False


def _build_result(record, steps, status):
    return {
        "tmissinginfovalidationid": record["tmissinginfovalidationid"],
        "instanceId": record["instanceId"],
        "ordercasetaskid": record["ordercasetaskid"],
        "status": status,
        "steps": steps,
    }


def prompt_new_token():
    print("\n[!] Token expired or unauthorized.")
    new_token = input("Enter new Bearer token: ").strip()
    return new_token


def main():
    global TOKEN

    print(f"Loading records from {INPUT_FILE}...")
    records = load_records(INPUT_FILE)

    if not records:
        print("No records found.")
        return

    print(f"Loaded {len(records)} record(s)")
    print("\nFirst few records:")
    for r in records[:5]:
        print(r)

    confirmation = input(
        f"\nAbout to process {len(records)} record(s) "
        f"(complete → interrupt → complete). Continue? (Y/N): "
    ).strip().upper()

    if confirmation != "Y":
        print("Cancelled.")
        return

    session = create_session()
    token_holder = {"token": TOKEN}

    success_count = 0
    failure_count = 0
    skipped_due_to_token = []

    with open(SUCCESS_FILE, "w", encoding="utf-8") as sout, \
         open(FAILED_FILE, "w", encoding="utf-8") as fout:

        for start in range(0, len(records), CONCURRENCY):
            batch = records[start:start + CONCURRENCY]
            batch_num = start // CONCURRENCY + 1
            print(f"\n========== Batch {batch_num} ({len(batch)} records) ==========")

            token_expired_in_batch = False
            futures_map = {}

            with ThreadPoolExecutor(max_workers=CONCURRENCY) as executor:
                for record in batch:
                    f = executor.submit(process_record, session, token_holder, record)
                    futures_map[f] = record

                for future in as_completed(futures_map):
                    record = futures_map[future]
                    rec_id = record["tmissinginfovalidationid"]
                    case_id = record["case_id"]

                    try:
                        ok, result, token_expired = future.result()
                    except Exception as e:
                        ok, token_expired = False, False
                        result = _build_result(record, [], f"EXCEPTION: {e}")

                    if token_expired:
                        token_expired_in_batch = True
                        skipped_due_to_token.append(rec_id)
                        fout.write(json.dumps(result) + "\n")
                        failure_count += 1
                        print(f"TOKEN_EXPIRED | {rec_id}")
                    elif ok:
                        success_count += 1
                        sout.write(json.dumps(result) + "\n")
                        print(f"SUCCESS | {case_id}")
                    else:
                        failure_count += 1
                        fout.write(json.dumps(result) + "\n")
                        print(f"FAILED  | {case_id} | {result['status']}")

            if token_expired_in_batch:
                new_token = prompt_new_token()
                token_holder["token"] = new_token
                print(f"Token updated. Remaining records will use new token.")
                # Note: already-failed token records are logged; continuing with next batch

            if start + CONCURRENCY < len(records):
                print(f"\nWaiting {BATCH_DELAY_SEC}s before next batch...")
                time.sleep(BATCH_DELAY_SEC)

    print("\n===================================")
    print("Execution Complete")
    print("===================================")
    print(f"Total   : {len(records)}")
    print(f"Success : {success_count}")
    print(f"Failed  : {failure_count}")
    print(f"Success Log : {SUCCESS_FILE}")
    print(f"Failure Log : {FAILED_FILE}")

    if skipped_due_to_token:
        print(f"\n[!] {len(skipped_due_to_token)} record(s) failed due to token expiry.")
        print("    Re-run with failed.jsonl IDs after updating the token.")


if __name__ == "__main__":
    main()