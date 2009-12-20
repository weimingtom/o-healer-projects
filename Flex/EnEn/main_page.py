#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#



import os
from google.appengine.ext.webapp import template

from google.appengine.api import users
from google.appengine.ext import db,webapp
from google.appengine.ext.webapp.util import run_wsgi_app


#==Data==

class SaveData(db.Model):
	name = db.StringProperty(multiline=False)
	score = db.IntegerProperty()



#==Page==

class MainPage(webapp.RequestHandler):
	def get(self):
		#Login
		if users.get_current_user():
			url = users.create_logout_url(self.request.uri)
			show_login = False
		else:
			url = users.create_login_url(self.request.uri)
			show_login = True

		#Ranking
		save_data_list = db.GqlQuery("SELECT * FROM SaveData ORDER BY score DESC LIMIT 10")
		info_list = []
		for save_data in save_data_list:
			info_list.append({'name':save_data.name, 'score':str(save_data.score)})

		template_values = {
			'info_list': info_list,
			'url':url,
			'show_login':show_login,
		}

		path = os.path.join(os.path.dirname(__file__), 'index.html')
		self.response.out.write(template.render(path, template_values))

#==Main==

application = webapp.WSGIApplication(
	[('/', MainPage)],
	debug=True)

def main():
	#Page
	run_wsgi_app(application)

if __name__ == "__main__":
	main()
