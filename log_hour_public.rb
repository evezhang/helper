#!/usr/bin/env ruby
# - Author: Jingyiping Zhang
# - Last Modified: 10/30/2016 - make it pulic

# - Extract from Google Online Spreadsheet
# - Prepare the message (Date Range, Logged Hours, Special Notes, Body Template)
# - Send the email
require 'dotenv'
require 'gmail'
require 'net/https'
require_relative 'sample-code.rb'


Dotenv.load

GMAIL_USERNAME = ENV['GMAIL_USERNAME']
GMAIL_PASSWORD = ENV['GMAIL_PASSWORD']


GMAIL = Gmail.connect(GMAIL_USERNAME, GMAIL_PASSWORD)

#Executiveprograms@brown.edu;zoe_stoll@brown.edu
# !!FIX ME!!
# Add the email addresses here with ";" separator
REAL_EMAIL = 'abc@samle.com;def@sample.com;myself@sample.com'
MY_EMAIL = 'myself@sample.com'
# !! FIX ME!!
SHEET_ID = 'GOOGLE SHEET ID FROM THE URL'



def create_reply(recipientEmail,subject,email_body)
  GMAIL.compose do
    to recipientEmail
    # !!FIX ME!!
    subject "[EMCS2000] MY_NAME Worked Hours "+subject
    body email_body
  end
end

if ARGV.length !=1
	puts "NOT ENOUGH PARAMs"
	exit
end
if ARGV.length == 2
  specialNotes = ARGV[1]
end

recipientEmail = MY_EMAIL
if ARGV[0] == 'REAL'
	recipientEmail = REAL_EMAIL
end
data = Extract_From_Google_Sheet.new(SHEET_ID)
subject,body = data.extractData(specialNotes)

reply = create_reply(recipientEmail,subject,body)
GMAIL.deliver(reply)







