import logging
import json
import azure.functions as func


def main(event: func.EventHubEvent):
    payload = event.get_body()
    logging.info('Python EventHub trigger processed an event: %s',
                 event.get_body().decode('utf-8'))
                 
    #can we get the body as json
    alert_contents = event.get_body().decode('utf-8')
    if type(alert_contents) == str:
        alerts = json.loads(alert_contents)
    else:
        alerts = json.load(alert_contents)

    logging.info('testing alerts %s', alert_contents)

    #https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-common-schema-definitions
    for alert in alerts:
        [logging.info(f"Found alert Target ID: {alertTargetID}") for alertTargetID in alert['data']['essentials']['alertTargetIDs']]