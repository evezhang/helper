#!/usr/bin/env ruby


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
REAL_EMAIL = 'Executiveprograms@brown.edu;zoe_stoll@brown.edu;jingyiping_zhang@brown.edu'
MY_EMAIL = 'jingyiping_zhang@brown.edu'
#DB_NAME_REGEX  = /\S+_staging/
#KEYWORDS_REGEX = /sorry|help|wrong/i
SHEET_ID = '1ciejIwKmXbUgy615PjmNkDu6weLDOVG1wdXP5zcLlHA'



def create_reply(recipientEmail,subject,email_body)
  GMAIL.compose do
    to recipientEmail
    subject "[EMCS2000] JINGYIPING ZHANG Worked Hours "+subject
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



#
#GMAIL.inbox.find(:unread, from: KUMARS_EMAIL).each do |email|
#  if email.body.raw_source[KEYWORDS_REGEX] && (db_name = email.body.raw_source[DB_NAME_REGEX])
#    backup_file = "/home/backups/databases/#{db_name}-" + (Date.today - 1).strftime('%Y%m%d') + '.gz'
#    abort 'ERROR: Backup file not found' unless File.exist?(backup_file)
#
#    # Restore DB
#    `gunzip -c #{backup_file} | psql #{db_name}`

#    # Mark as read, add label and reply
#    email.read!
#    email.label('Database fixes')
#    reply = create_reply(email.subject)
#    GMAIL.deliver(reply)
#  end
#end







