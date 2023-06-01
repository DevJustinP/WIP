import sys
import requests
import json
from SugarCrm_Functions import get_access_token

UserName = sys.argv[1]
Password = sys.argv[2]

print(UserName)
print(Password)

url = 'https://summerclassics.sugarondemand.com/rest/v11_7/oauth2/token'
payload = {
    "grant_type":"password",
    "client_id":"sugar",
    "client_secret":"",
    "username":UserName,
    "password":Password,
    "platform":"base"
}

auth_response = requests.post(url, json=payload)
response_data = auth_response.json()

print(json.dumps(response_data, indent=3))