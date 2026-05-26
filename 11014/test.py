import pandas as pd
import requests
import csv
import time

# =========================
# CONFIG
# =========================

CSV_FILE = "case.csv"

URL = "https://api-eod4.app.neovance.com/api/core/v1/integrations/cds/document"

TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ilh0LW83aERicHVwQXotWlBtNkh4Q0ZXUzNjSSIsImtpZCI6Ilh0LW83aERicHVwQXotWlBtNkh4Q0ZXUzNjSSJ9.eyJhdWQiOiJhcGk6Ly9hYmZhM2VmMi01YjIzLTQ1NzctODgwMi00YTZiZDBiYjllMDAiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8yMTNjZTJkZC0zNzlkLTQ1NjUtYWRiNy04MjhiNWQ5NmUwMzEvIiwiaWF0IjoxNzc5MzQ4ODI0LCJuYmYiOjE3NzkzNDg4MjQsImV4cCI6MTc3OTM1MzI4NSwiYWNyIjoiMSIsImFpbyI6IkFhUUFXLzhjQUFBQTliTjNGRzRrbDAraUE2aG1pT1dza3d4ZVdtNGNlZmc4bUtsZ21jSTQ1SVhoK1EyN2xEMktIN0lmRjB5MFFwQ2hlR05oWEFFUHMrdWYvbmNYNzdNdWR1OHlKeERmK2JnSHFEaXVBWWN4MloxaFFNNHJ2L2dXVHZqRVZzRFdIek1sNkErRlgybGhVV3Z1RGorV2picG96TDh3bmFPNTVCSnh5VWNEVU9LTStzcnpVR3lGemZZSFhoNkRRSWZFZjZ2bERpRHJPMWp5ZjJFbDFiTnpxS2N1V2c9PSIsImFtciI6WyJwd2QiLCJyc2EiLCJtZmEiXSwiYXBwaWQiOiJhYmZhM2VmMi01YjIzLTQ1NzctODgwMi00YTZiZDBiYjllMDAiLCJhcHBpZGFjciI6IjAiLCJkZXZpY2VpZCI6ImZkMTg4MTc1LTEzNjItNDM5My1iZjNmLWNhZGY0ZDY4NGRjNCIsImZhbWlseV9uYW1lIjoiR29zd2FtaSIsImdpdmVuX25hbWUiOiJSaXR3aWsiLCJpcGFkZHIiOiI0NS4xMjYuMTYzLjEzNCIsIm5hbWUiOiJSaXR3aWsgR29zd2FtaSIsIm9pZCI6IjhlMWQ3NjQ3LTVkMTQtNDMwOS05NTZhLTEwYThmMjBiNzVlYyIsIm9ucHJlbV9zaWQiOiJTLTEtNS0yMS00MTM2NjU0NzM0LTIxOTI4MjM5ODAtMTY2NTg2MTg4MC0xMDM2MiIsInJoIjoiMS5BWEVCM2VJOElaMDNaVVd0dDRLTFhaYmdNZkktLXFzalczZEZpQUpLYTlDN25nQjhBWUZ4QVEuIiwic2NwIjoiYXBpX2FjY2VzcyIsInNpZCI6IjAwMWYyOGFhLTU3MDgtNmFkMS03OTY0LWJhZGEyMzZjMjNhNCIsInN1YiI6InZsRlhTYWVnMm14M245aHVFdURyOTJhUkZPSUlyTV96c191UlVtMmRLQUkiLCJ0aWQiOiIyMTNjZTJkZC0zNzlkLTQ1NjUtYWRiNy04MjhiNWQ5NmUwMzEiLCJ1bmlxdWVfbmFtZSI6InJpdHdpay5nb3N3YW1pQG5lb3ZhbmNlLmNvbSIsInVwbiI6IlJpdHdpay5Hb3N3YW1pQG5lb3ZhbmNlLmNvbSIsInV0aSI6InF1RUF6RVpleDBteFp5Y0lFRDlWQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfZnRkIjoia1VJUWkyN1BMZjktWjlJV3dxYWFjajJmMUlXVnVuUEt5SjZzN1hreTRZa0JkWE5sWVhOMExXUnpiWE0ifQ.dL2e0tGFFoIHQDElKZOX9BoAbVRxHugqdcKMa_aNTo64ptcAQ5MTaHANNZTt3LTuOKAGQ2aK-iqaYbkYbBVWd4-Zvx4JvMpnYG6JVAdY_qnW7WOfTjm7UHrUplRYfu9fExc5WUiYlt_VahT0elAfT8PZ5CfYgsWwOykHBNCPjNEHn8jBRndq3D0ywW6afWwAt1nn5KPThnQijB7FG8a7UHsQLTu7aVXNiulRNahhNF-owKYAROpjeYLorI2ElZ3kKcr2iG--wQKCYYK4hFFIYog-fHsjavgtoDHTwDsn_rYsgDkvi2lOEgjnUZsDdU7N0Pzxf9Ibrs24OhAgFmwDyw"

HEADERS = {
    "accept": "application/json, text/plain, */*",
    "authorization": f"Bearer {TOKEN}",
    "content-type": "application/json",
    "x-tenantid": "1003"
}

CASE_ID = 13896079
TASK_ID = 118984408
MODE = "sync"

# =========================
# READ DOCUMENT IDS
# =========================

df = pd.read_csv(CSV_FILE)

document_ids = df["document_id"].dropna().tolist()

print(f"Total document ids found: {len(document_ids)}")

# =========================
# PROCESS API
# =========================

success = []
failed = []

for document_id in document_ids:

    payload = {
        "document_id": int(document_id),
        "case_id": CASE_ID,
        "task_id": TASK_ID,
        "mode": MODE
    }

    try:

        response = requests.post(
            URL,
            headers=HEADERS,
            json=payload,
            timeout=120
        )

        print(f"\nDocument ID: {document_id}")
        print(f"Status Code: {response.status_code}")

        if response.status_code in [200, 201]:

            success.append(document_id)
            print("SUCCESS")

        else:

            failed.append(document_id)
            print("FAILED")
            print(response.text)

    except Exception as e:

        failed.append(document_id)
        print(f"ERROR for {document_id}: {str(e)}")

    time.sleep(1)

# =========================
# SAVE OUTPUT
# =========================

output_df = pd.DataFrame({
    "successful_document_ids": pd.Series(success),
    "failed_document_ids": pd.Series(failed)
})

output_df.to_csv("document_results.csv", index=False)

print("\nExecution completed.")
print("Results saved to document_results.csv")