#!/usr/bin/env ruby
# - Author: Jingyiping Zhang
# - Reference: https://developers.google.com/sheets/quickstart/ruby
require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'
class Extract_From_Google_Sheet
  def initialize(spreadsheet_id='GOOGLE SHEET ID FROM THE URL')
    @spreadsheet_id = spreadsheet_id
    @OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    @APPLICATION_NAME = 'EmailMyHour'
    # !!FIX ME!!
    # Please follow the step 1 and step 2 here: https://developers.google.com/sheets/quickstart/ruby
    @CLIENT_SECRETS_PATH = 'PATH/TO/JSON'
    @CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                                 "sheets.googleapis.com-SPSHourSheet.yaml")
    @SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
    # !!FIX ME!! Plase keep the space there as it is
    @FULL_NAME = 'LASTNAME, FIRSTNAME '
    # !!FIX ME!!
    @YOUR_NAME = 'YOURNAME'
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # Local Crendential STORED!!!
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(@CREDENTIALS_PATH))
    client_id = Google::Auth::ClientId.from_file(@CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: @CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, @SCOPE, token_store)

    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: @OOB_URI)
      puts "Open the following URL in the browser and enter the " +
           "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: @OOB_URI)
    end
    credentials
  end

  def findDateRange(date)
    wday = date.wday
    startDate = date - wday
    endDate = startDate + 6
    return startDate, startDate.strftime('%-m/%-d/%y')<<'-'<<endDate.strftime('%-m/%-d/%y')
  end

  def prepareBody(row,stepLen,startDate,specialNotes,subject)
    body = ""
    body << "Hi,\n\nThe followings are my hours for week " + subject+":\n"
    
    (1..7*stepLen).step(stepLen) do |n|
      body << "\t"<<startDate.strftime('%-m/%-d/%y') << ' : '
      if row[n].empty? && row[n+1].empty?
        body << "NONE"
      else
        body <<row[n] <<' - '<< row[n+1]
      end
      body <<"\n"
      startDate += 1
    end
    body << "Total Hour: " << row[row.length-1]<<"\n"
    if !specialNotes.nil? && !specialNotes.empty?
      body << "Note:"+specialNotes+"\n"
    end
    body << "\nRegards,\n"+@YOUR_NAME

    return body
  end  
  # Initialize the API
  def extractData(specialNotes=nil)
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = @APPLICATION_NAME
    service.authorization = authorize

    startDate,dateRange = findDateRange(Date.parse(Time.now.to_s))
    #puts dateRange

    range = dateRange+'!A:AD'
    response = service.get_spreadsheet_values(@spreadsheet_id, range)
    
    puts 'No data found.' if response.values.empty?
    response.values.each do |row|
      if row[0] != @FULL_NAME
        next
      end
      # Data Description: TimeIn TimeOut Break Hours
      return dateRange, prepareBody(row,4,startDate,specialNotes,dateRange)
    end
  end


end


if __FILE__ == $0
  
  data = Extract_From_Google_Sheet.new
  subject,body = data.extractData
  puts subject
  puts body
end







