import requests
import uuid

url = 'https://ucxqakixdpqqmbbpeptm.supabase.co/rest/v1/campaigns'
key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeHFha2l4ZHBxcW1iYnBlcHRtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDUzNjU0NywiZXhwIjoyMDg2MTEyNTQ3fQ.T6KVddETcHWZ33qZxZ05F-Trvq8lC_8_YYtsPIEKZpg'

headers = {
    'Authorization': 'Bearer ' + key,
    'apikey': key,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
}

tests = [
    ('id + title', {'id': str(uuid.uuid4()), 'title': 'Test Campaign'}),
    ('id + title + target_amount', {'id': str(uuid.uuid4()), 'title': 'Test2', 'target_amount': 1000}),
    ('id + title + category', {'id': str(uuid.uuid4()), 'title': 'Test3', 'category': 'Charity'}),
    ('id + title + status', {'id': str(uuid.uuid4()), 'title': 'Test4', 'status': 'active'}),
    ('Only id', {'id': str(uuid.uuid4())}),
]

for test_name, data in tests:
    print('Test:', test_name)
    response = requests.post(url, json=data, headers=headers)
    print('Status:', response.status_code)
    if response.status_code == 201:
        print('SUCCESS! Required fields found.')
        print('Inserted:', response.json())
        break
    else:
        print('Error:', response.text[:400])
    print()
