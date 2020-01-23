import logging

import azure.functions as func
import os
import json
from azure.eventhub import EventHubClient, EventData

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    connection_str = "Endpoint=sb://{}/;SharedAccessKeyName={};SharedAccessKey={};EntityPath={}".format(
        os.environ['EVENT_HUB_HOSTNAME'],
        os.environ['EVENT_HUB_SAS_POLICY'],
        os.environ['EVENT_HUB_SAS_KEY'],
        os.environ['EVENT_HUB_NAME'])
    client = EventHubClient.from_connection_string(connection_str)
    
    req_body = req.get_json()
    req_payload = json.dumps(req_body)
    
    client = EventHubClient.from_connection_string(connection_str)
    sender = client.add_sender(partition="0")

    try:
        client.run()
        logging.info('Send Alert with this payload: %s', req_payload)
        event_data = EventData(req_payload)
        sender.send(event_data)
        logging.info('Sent payload to Event Hub!')
    except:
        raise
    finally:
        client.stop()

    return func.HttpResponse(f"Hello {req_body}!")
