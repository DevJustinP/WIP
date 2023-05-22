import sys
from SugarCrm_Functions import GetModuleByName

if __name__ == '__main__':
    Module = sys.argv[1]
    UserName = sys.argv[2]
    Password = sys.argv[3]

    maxRecords = 10
    offset = 0
    record = 0
    maxNumber = 20

    DICTrecord = {  }

    while offset >= 0:
        response = GetModuleByName(Module, UserName, Password, maxRecords, offset)

        if 'offset' in response:
            offset = response['offset']
        elif offset >= maxNumber:
            offset = -1
        else:
            offset = -1

        if 'records' in response:
            for record in response['records']:
                DICTrecord[record] = {
                    'Subject': record['name'],
                    'Description': record['description'],
                    'Attachment': record['filename'],
                    'RelatedToModule': record['parent_type'],
                    'RelatedToID': record['parent_id'],
                    'ContactID': record['contact_id'],
                    'AssignedUser': record['assigned_user_name'],
                    'AssignedUserID': record['assigned_user_id'],
                    'TeamID': record['team_name'][0]['id'],
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

    print(f"{DICTrecord}")