import requests
import json

def get_access_token(username, password):

   url = 'https://summerclassics.sugarondemand.com/rest/v11_7/oauth2/token'
   payload = {
      "grant_type":"password",
      "client_id":"sugar",
      "client_secret":"",
      "username":username,
      "password":password,
      "platform":"base",
   }

   auth_response = requests.post(url, json=payload)
   response_data = auth_response.json()
   
   access_response = {
       "status":str(auth_response),
       "access_token":"",
       "error":"",
       "error_message":""
   }

   if 'access_token' in response_data:
       access_response['access_token'] = response_data['access_token']
   elif 'error' in response_data:
       access_response['error'] = response_data['error']
       access_response['error_message'] = response_data['error_message']
   else:
       access_response['error'] = 'Unknown Response'
       access_response['error_message'] = response_data

   return access_response

def GetModuleByName(ModuleName, username, password, max_num = 100, offset = 0):
    
    response = get_access_token(username, password)

    if 'access_token' in response:
        access_token = response['access_token']
    else:
        print(response['error']+' : '+response['error_message'])

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
        print('Unable to get authorization token.')

    return response
