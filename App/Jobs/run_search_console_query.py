import googleapiclient.discovery
from googleapiclient.errors import HttpError
import gcloud_config_helper
from flask import current_app


SCOPES = ['https://www.googleapis.com/auth/webmasters.readonly']
API_SERVICE_NAME = 'searchconsole'
API_VERSION = 'v1'


def run():
    # authenticate client
    credentials, project = gcloud_config_helper.default()
    search_console_service = googleapiclient.discovery.build(
      API_SERVICE_NAME, API_VERSION, credentials=credentials
      )
    try:
      site_list = search_console_service.sites().list().execute()
    except HttpError as e:
      current_app.logger.error(f"Not able to query Search Console error {e}")
    return "Results from search console"
