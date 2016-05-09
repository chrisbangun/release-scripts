#!/bin/python
#ACB

import re
import os
import sys

def test():
	mails = "['<mailto:ongki@traveloka.com|ongki@traveloka.com>','<mailto:afrishal@traveloka.com|afrishal@traveloka.com>','<mailto:arganka@traveloka.com|arganka@traveloka.com>]"
	#mails = "'<mailto:arganka@traveloka.com|arganka@traveloka.com>'"
	#mails = "--eval var_user=['<mailto:ongki@traveloka.com|ongki@traveloka.com>','<mailto:afrishal@traveloka.com|afrishal@traveloka.com>','<mailto:arganka@traveloka.com|arganka@traveloka.com>'] /home/mongoscript/analytics/repository/data-migrations/traveloka-migrations/tera/insertNewSecretAgent.js"
	print mails.count('mailto')
	result = re.sub("(<mailto:)+","",mails) #target=var _user=['ongki@traveloka.com','afrishal@traveloka.com','arganka@traveloka.com']""
	chunk_email = result.split(',')
	param=""
	for mail in chunk_email[1:len(chunk_email)]:
		correct_mail = mail.split('|')[0]
		correct_mail = re.sub("[']+","",correct_mail)
		param = param+correct_mail+","
		print correct_mail
	param = param.strip(',')
	param = param+"]"
	print param




test()