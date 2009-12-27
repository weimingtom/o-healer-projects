#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	 http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


import os
import wsgiref.handlers
from pyamf.remoting.gateway.wsgi import WSGIGateway
from pyamf import ASObject

from google.appengine.api import users
from google.appengine.ext import db,webapp
from google.appengine.ext.webapp import template

#==Data==

class SaveData(db.Model):
	author = db.UserProperty()
	stage = db.TextProperty()


#==API==


def Save(data):
	#Check
	if users.get_current_user():
		owner = users.get_current_user()
	else:
		return#Err:Plaese Login

	#Init
	save_data = SaveData()
	for k, v in data.iteritems():
		if k == "stage":
			save_data.stage = v

	#Save
	save_data.put()


#API List
services = {
	'save':Save,
}



def main():
	application = WSGIGateway(services)
	wsgiref.handlers.CGIHandler().run(application)

if __name__ == "__main__":
	main()
