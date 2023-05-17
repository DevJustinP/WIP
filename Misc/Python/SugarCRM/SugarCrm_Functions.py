import requests
import json

def get_access_token(username, password):

   url = 'https://summerclassics.sugarondemand.com/rest/v11_7/oauth2/token'
   payload = {
      'grant_type':'password',
      'client_id':'sugar',
      'client_secret':'',
      'username':username,
      'password':password,
      'platform':'base',
   }

   auth_response = requests.post(url, json=payload)
   response_data = auth_response.json()
   access_token = response_data['access_token']
   
   return access_token

def GetModuleByName(ModuleName, username, password, max_num = 100, offset = 0):
    
    access_token = get_access_token(username, password)
    if access_token:
        url = 'https://summerclassics.sugarondemand.com/rest/v11_7/'+ModuleName
            
        headers = {
            'oauth-token':access_token,
            'Content-Type':'application/json'
        }
        payload = {
            'max_num':max_num,
            'offset':offset
        }

        response = requests.get(url, headers=headers, json=payload)
    else:
        print('Unalbe to get authorization token.')


    return response

def GetAllModuleByName(ModuleName, username, password, max_num):
    offset = 0
    while offset > -1 :

        print('Getting offset of '+str(offset))
        response = GetModuleByName(ModuleName, username, password, max_num, offset)

        json_data = json.loads(response.text)
        offset = json_data['next_offset']
