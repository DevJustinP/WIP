import sys
import json
from SugarCrm_Functions import GetModuleByName

record_dict = {}

if __name__ == '__main__':
    Module = sys.argv[1]
    UserName = sys.argv[2]
    Password = sys.argv[3]
    response = GetModuleByName(Module, UserName, Password, 2)
    
    json_data = json.loads(response.text)

    for record in json_data['records']:
        record_dict[record['id']] = { 
            'Subject': record['name'],
            'Description': record['description'],
            'Attachment': record['filename'],
            'RelatedToModule': record['parent_type'],
            'RelatedToID': record['parent_id'],
            'ContactID': record['contact_id'],
            'AssignedUser': record['assigned_user_name'],
            'AssignedUserID': record['assigned_user_id'],
            #'TeamID': record['team_name[0].id'],
            'DateCreated': record['date_entered'],
            'DateModified': record['date_modified'],
            'CreatedByName': record['created_by_name'],
            'CreatedByID': record['created_by'],
            'ModifiedByName': record['modified_by_name'],
            'ModifiedByID': record['modified_user_id'],
            'HasAttachment ': record['has_attachment_c'],
            'VisitorID': record['visitorid_c'],
            'Type': record['updatetype_c'],
            'SubType': record['notetype_c'],
            'FileExtension': record['file_ext'],
            'EmailType': record['email_type'],
            'EmailID': record['email_id'],
            'NoteParentID': record['note_parent_id'],
            'ExternaID': record['external_id'],
            'NoteSoure': record['entry_source'],
            'IsAttachemnt': record['attachment_flag'],
            'Tag': record['tag'],
            'IntegrationSyncID': record['sync_key'],
            #'Team1': record['team_name[0].name'],
            #'Team2': record['team_name[0].name_2'],
            'ExternalSourceID': record['source_id'],
            'ExternalSource': record['source_type'],
            'ExternalSourceMeta': record['source_meta']

        }

    datatypes = {}

    for record in record_dict.values():
        for key, value in record.items():
            if key not in datatypes:
                datatypes[key] = {
                    'name': key,
                    'type': type(value),
                    'size': len(str(value))
                }
            elif len(str(value)) > datatypes[key]["size"]:
                datatypes[key]["size"] = len(str(value))                

    # Print the results
    for key, value in datatypes.items():
        print(f'Datatype of {key}: {value["type"]}, size {value["size"]}')
