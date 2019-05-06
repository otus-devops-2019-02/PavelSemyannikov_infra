#!/usr/bin/python2.7

import json
import sys
import argparse
import os
import time
import googleapiclient.discovery
from six.moves import input
import warnings
warnings.filterwarnings("ignore", "Your application has authenticated using end user credentials")

# Variables
compute = googleapiclient.discovery.build('compute', 'v1')
project = "infra-236008"
zone = "europe-west1-b"

# Functions
def list_instances(compute, project, zone):
  result = compute.instances().list(project=project, zone=zone).execute()
  return result['items'] if 'items' in result else None

if len(sys.argv) > 1:
  arg = sys.argv[1]
else:
  arg = None

if arg == "--list":
  app = []
  db = []
  other = []
  inventory = []
  instances = list_instances(compute, project, zone)
  if instances:
    for instance in instances:
      vmname = instance["name"]
      vmip = instance["networkInterfaces"][0]["accessConfigs"][0]["natIP"]
      if "app" in vmname:
        app.append(vmip)
      elif "db" in vmname:
        db.append(vmip)
      else:
        other.append(vmip)
    inventory.append("{")
    if app:
      inventory.append("\"app\": {")
      inventory.append("\"hosts\": ")
      appjson = json.dumps(app)
      inventory.append(appjson)
      if db:
        inventory.append("},")
      else:
        if other:
          inventory.append("},")
        else:
          inventory.append("}")
    if db:
      inventory.append("\"db\": {")
      inventory.append("\"hosts\": ")
      dbjson = json.dumps(db)
      inventory.append(dbjson)
      if other:
        inventory.append("},")
      else:
        inventory.append("}")
    if other:
      inventory.append("\"other\": {")
      inventory.append("\"hosts\": ")
      otherjson = json.dumps(other)
      inventory.append(otherjson)
      inventory.append("}")
    inventory.append("}")
    for str in inventory:
      print(str)
