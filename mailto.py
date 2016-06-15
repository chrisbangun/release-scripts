#!/bin/python
#ACB

import re
import os
import sys

def test():
	mails = "['<mailto:someone@gmail.com|someone@gmail.com>]"
	print mails.count('mailto')
	result = re.sub("(<mailto:)+","",mails)
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
