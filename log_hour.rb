#!/usr/bin/env ruby


"- Extract from Google Online Spreadsheet
 - Prepare the message (Date Range, Logged Hours, Special Notes, Body Template)
 - Send the email"
require 'dotenv'
require 'gmail'
require 'net/https'


Dotenv.load

GMAIL_USERNAME = ENV['GMAIL_USERNAME']
GMAIL_PASSWORD = ENV['GMAIL_PASSWORD']

http = NET::HTTP.new('www.google.com',443)
http.user_ssl = true
path = '/account/ClientLogin'
data = 'accountType=HOSTED_OR_GOOGLE'.'&Email='.GMAIL_USERNAME.'&Passwd='GMAIL_PASSWORD.'&service=wise'





GMAIL = Gmail.connect(GMAIL_USERNAME, GMAIL_PASSWORD)
#KUMARS_EMAIL = 'kumar.a@example.com'

#Executiveprograms@brown.edu,zoe_stoll@brown.edu
RECIPIENT_EMAIL = 'jingyiping_zhang@brown.edu;jzhang12@cs.brown.edu'
DB_NAME_REGEX  = /\S+_staging/
KEYWORDS_REGEX = /sorry|help|wrong/i

def create_reply(dateRange,specialNotes,hours)
  GMAIL.compose do
    to RECIPIENT_EMAIL
    subject "[EMCS2000] Log Hours #{dateRange}"
    body "Hi,\n The followings are my hours for week #{dateRange}:\n
    Note:#{specialNotes}\n
    Regards,\n Jingyiping"
  end
end

GMAIL.inbox.find(:unread, from: KUMARS_EMAIL).each do |email|
  if email.body.raw_source[KEYWORDS_REGEX] && (db_name = email.body.raw_source[DB_NAME_REGEX])
    backup_file = "/home/backups/databases/#{db_name}-" + (Date.today - 1).strftime('%Y%m%d') + '.gz'
    abort 'ERROR: Backup file not found' unless File.exist?(backup_file)

    # Restore DB
    `gunzip -c #{backup_file} | psql #{db_name}`

    # Mark as read, add label and reply
    email.read!
    email.label('Database fixes')
    reply = create_reply(email.subject)
    GMAIL.deliver(reply)
  end
end


	reply = create_reply(email.subject)
    GMAIL.deliver(reply)