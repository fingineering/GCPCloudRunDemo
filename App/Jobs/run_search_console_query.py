import google.oauth2.credentials
import googleapiclient.discovery
import gcloud_config_helper


SCOPES = ['https://www.googleapis.com/auth/webmasters.readonly']
API_SERVICE_NAME = 'searchconsole'
API_VERSION = 'v1'


def run():
    # authenticate client
    credentials, project = gcloud_config_helper.default()
    search_console_service = googleapiclient.discovery.build(
      API_SERVICE_NAME, API_VERSION
      , credentials=credentials
      )
    site_list = search_console_service.sites().list().execute()
    return "Results from search console"