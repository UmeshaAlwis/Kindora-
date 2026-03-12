import requests
import json

url = 'https://ucxqakixdpqqmbbpeptm.supabase.co/rest/v1/information_schema.columns'
headers = {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeHFha2l4ZHBxcW1iYnBlcHRtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDUzNjU0NywiZXhwIjoyMDg2MTEyNTQ3fQ.T6KVddETcHWZ33qZxZ05F-Trvq8lC_8_YYtsPIEKZpg',
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeHFha2l4ZHBxcW1iYnBlcHRtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDUzNjU0NywiZXhwIjoyMDg2MTEyNTQ3fQ.T6KVddETcHWZ33qZxZ05F-Trvq8lC_8_YYtsPIEKZpg'
}

response = requests.get(url + '?table_name=eq.campaigns&select=column_name,data_type,is_nullable', headers=headers)
print('Status:', response.status_code)
if response.status_code == 200:
    columns = response.json()
    print('\nCampaigns table columns:')
    for col in columns:
        print('  - {}: {} (nullable: {})'.format(col['column_name'], col['data_type'], col['is_nullable']))
else:
    print('Error:', response.text)
