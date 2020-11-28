#!/usr/bin/python
#
# Tracks Duet3d print time predictions and prints the data in CSV format.
# Tested with Python3
# Hit Ctrl-C to stop. 

import json
import time
import urllib.request

url = 'http://10.0.0.7/rr_status?type=3'

print(f'Duet3 URL: [{url}]')

<<<<<<< HEAD

def ReportHeader():
    print(','.join([
        'status',
        'printer_time',
        'print_time',
        'layer',
        'fraction',
        'sec_left_layer',
        'sec_left_filament',
        'sec_left_file',
         'M73_percents',
         'M73_minutes']))


def ReportCurrentValues():
    response = urllib.request.urlopen(url)
    doc = json.loads(response.read())
    # print(json.dumps(doc, sort_keys=False, indent=2))
    values = [
        str(doc['status']),
        str(doc['time']),
        str(doc['printDuration']),
        str(doc['currentLayer']),
        str(doc['fractionPrinted']),
        str(doc['timesLeft']['layer']),
        str(doc['timesLeft']['filament']),
        str(doc['timesLeft']['file']),
        str(doc['temps']['bed']['standby']),
        str(doc['temps']['tools']['standby'][0][0]),
    ]
    print(','.join(values))

=======
print('Duet3 URL: [%s]' % url)

def ReportHeader():
  print(','.join([
    'status',
    'printer_time_secs',
    'print_time_secs',
    'layer_number',
    'fraction_done',
    'secs_left_by_layer',
    'secs_left_by_filament',
    'secs_left_by_file' ]))

def ReportCurrentValues():
  response = urllib.request.urlopen(url)
  doc = json.loads(response.read())
  #print(json.dumps(doc, sort_keys=False, indent=2))
  values = [
    str(doc['status']),
    str(doc['time']),
    str(doc['printDuration']),
    str(doc['currentLayer']),
    str(doc['fractionPrinted']),
    str(doc['timesLeft']['layer']),
    str(doc['timesLeft']['filament']),
    str(doc['timesLeft']['file']),
  ]
  print(','.join(values))
>>>>>>> 205095e9631c22e66ef45a6039a2484b2e0387f7

# Main
ReportHeader()
while True:
    ReportCurrentValues()
    time.sleep(60)
