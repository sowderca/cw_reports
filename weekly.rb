require 'connect-stoopid'
require 'date'
require 'axlsx'
require 'chronic'
require 'mailgun'
require 'business_time'
require_relative('global')

cw_client = ConnectStoopid::ReportingClient.new(CW_URL, COMP, CW_USR, CW_PSS)
mg_client = Mailgun::Client.new(ML_KEY)

mb_obj = Mailgun::MessageBuilder.new



p     = Axlsx::Package.new
wb    = p.workbook
array = Array.new
excel = Array.new
excel << :tables
BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri, :sat]
tuesday = Chronic.parse('tuesday this week').to_date
saturday = Chronic.parse('saturday this week').to_date
days = tuesday.business_dates_until(saturday)
days.push(saturday)
# Arrays for storing value; Might be a less memory heavy method of doing this ***
opened_sc_array         = Array.new
opened_nc_array         = Array.new
opened_ga_array         = Array.new
opened_fcr_array        = Array.new
closed_nc_array         = Array.new
closed_sc_array         = Array.new
closed_ga_array         = Array.new
closed_fcr_array        = Array.new
sc_team_closed_array    = Array.new
nc_team_closed_array    = Array.new
ga_team_closed_array    = Array.new
night_opened_sc_array   = Array.new
night_opened_nc_array   = Array.new
night_opened_ga_array   = Array.new
night_opened_fcr_array  = Array.new
night_closed_sc_array   = Array.new
night_closed_nc_array   = Array.new
night_closed_ga_array   = Array.new
night_closed_fcr_array  = Array.new

days.each do |day|
    array << day.iso8601
end

#-------------------------------------------> START main loop
array.each do |day|
    d = Date.parse(day)
    yesterday = 1.business_day.before(d).iso8601
    @this_morning      = "[#{day}T07:00:00-04:00]"
    @yesterday_evening = "[#{yesterday}T18:00:00-04:00]"
    @yesterday_morning = "[#{yesterday}T07:00:00-04:00]"
opened_SC              = nil
opened_NC              = nil
opened_GA              = nil
opened_FCR             = nil
closed_NC              = nil
closed_SC              = nil
closed_GA              = nil
closed_FCR             = nil
sc_closed              = nil
nc_closed              = nil
ga_closed              = nil
night_closed_GA        = nil
night_closed_NC        = nil
night_closed_SC        = nil
night_closed_FCR       = nil
night_opened_GA        = nil
night_opened_NC        = nil
night_opened_SC        = nil
night_opened_FCR       = nil


# FCR Shift
# -------------------------------------------------------------------------
loop do 
    opened_SC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_morning} and date_entered < #{@yesterday_evening} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'SC Services' or team_name = 'SC Internal')")
    opened_sc_array.push(opened_SC) unless opened_SC.nil? 
    break unless opened_SC.nil? 
end   
loop do 
    opened_NC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_morning} and date_entered < #{@yesterday_evening} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'NC Govt' or team_name = 'NC Internal')")
    opened_nc_array.push(opened_NC) unless opened_NC.nil? 
    break unless opened_NC.nil? 
end
loop do 
    opened_GA = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_morning} and date_entered < #{@yesterday_evening} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'GA Govt' or team_name = 'GA Govt Internal')")
    opened_ga_array.push(opened_GA) unless opened_GA.nil? 
    break unless opened_GA.nil? 
 end
loop do 
    opened_FCR = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_morning} and date_entered < #{@yesterday_evening} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'FCR')")
    opened_fcr_array.push(opened_FCR) unless opened_FCR.nil? 
    break unless opened_FCR.nil? 
end
loop do 
    closed_SC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_morning} and date_closed < #{@yesterday_evening} and (Board_Name = 'SC Services' or Board_Name = 'SC Internal') and (closed_by = 'sowderca' or closed_by = 'browndea' or closed_by = 'baileypa' or closed_by = 'sleeperk' or closed_by = 'johnsonc' or closed_by = 'hurstgab' or closed_by = 'rogersda' or closed_by = 'postonja')")
    closed_sc_array.push(closed_SC) unless closed_SC.nil?   
    break unless closed_SC.nil? 
end
loop do 
    closed_NC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_morning} and date_closed < #{@yesterday_evening} and (Board_Name = 'NC Govt Services' or Board_Name = 'NC Govt Internal') and (closed_by = 'sowderca' or closed_by = 'browndea' or closed_by = 'baileypa' or closed_by = 'sleeperk' or closed_by = 'johnsonc' or closed_by = 'hurstgab' or closed_by = 'rogersda' or closed_by = 'postonja')")
    closed_nc_array.push(closed_NC) unless closed_NC.nil? 
    break unless closed_NC.nil? 
end
loop do 
    closed_GA = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_morning} and date_closed < #{@yesterday_evening} and (Board_Name = 'GA Govt Services' or Board_Name = 'GA Govt Internal') and (closed_by = 'sowderca' or closed_by = 'browndea' or closed_by = 'baileypa' or closed_by = 'sleeperk' or closed_by = 'johnsonc' or closed_by = 'hurstgab' or closed_by = 'rogersda' or closed_by = 'postonja')")
    closed_ga_array.push(closed_GA) unless closed_GA.nil? 
    break unless closed_GA.nil? 
end
loop do 
    closed_FCR = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_morning} and date_closed < #{@yesterday_evening} and Board_Name = 'FCR' and (closed_by = 'sowderca' or closed_by = 'browndea' or closed_by = 'baileypa' or closed_by = 'sleeperk' or closed_by = 'johnsonc' or closed_by = 'hurstgab' or closed_by = 'rogersda' or closed_by = 'postonja')")
    closed_fcr_array.push(closed_FCR) unless closed_FCR.nil? 
    break unless closed_FCR.nil? 
end


# Teams 
# --------------------------------------------------------------------------------
loop do 
     sc_closed= cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_morning} and date_closed < #{@yesterday_evening} and (closed_by = 'cgod' or closed_by = 'floydshe' or closed_by = 'tuckerdu' or closed_by = 'blackmor' or closed_by = 'hutchinj' or closed_by = 'ricanora' or closed_by = 'tronconi' or closed_by = 'turnerbr' or closed_by = 'vanduzew' or closed_by = 'washingt' or closed_by = 'burgettr') and (Board_Name = 'SC Services' or Board_Name = 'SC Internal')")
     sc_team_closed_array.push(sc_closed) unless sc_closed.nil?  
     break unless sc_closed.nil? 
end
loop do 
    nc_closed = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_morning} and date_entered < #{@yesterday_evening} and (closed_by = 'caywoodc' or closed_by = 'watsonro' or closed_by = 'pennellk' or closed_by = 'carterj' or closed_by = 'watsonro' or closed_by = 'tujensen' or closed_by = 'fieldedd') and (Board_Name = 'NC Govt Services' or Board_Name = 'NC Govt Internal')")
    nc_team_closed_array.push(nc_closed) unless nc_closed.nil?  
    break unless nc_closed.nil? 
end
loop do 
    ga_closed = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_morning} and date_entered < #{@yesterday_evening} and (closed_by = 'mcquiths' or closed_by = 'coxjosh' or closed_by = 'billupsd'  or closed_by = 'forcedan' or closed_by = 'israelyo' or closed_by = 'paynesim' or closed_by = 'keddingl') and (Board_Name = 'GA Govt Services' or Board_Name = 'GA Govt Internal')")
    ga_team_closed_array.push(ga_closed) unless ga_closed.nil?  
    break unless ga_closed.nil? 
end
# 2nd and 3rd Shift
# ------------------------------------------------------------------------------------------
loop do 
    night_opened_SC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_evening} and date_entered < #{@this_morning} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'SC Services' or team_name = 'SC Internal')")
    night_opened_sc_array.push(night_opened_SC) unless night_opened_SC.nil? 
    break unless night_opened_SC.nil? 
end
loop do 
    night_opened_NC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_evening} and date_entered < #{@this_morning} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'NC Govt' or team_name = 'NC Internal')")
    night_opened_nc_array.push(night_opened_NC) unless night_opened_NC.nil? 
    break unless night_opened_NC.nil? 
end
loop do 
    night_opened_GA = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_evening} and date_entered < #{@this_morning} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'GA Govt' or team_name = 'GA Govt Internal')")
    night_opened_ga_array.push(night_opened_GA) unless night_opened_GA.nil? 
    break unless night_opened_GA.nil? 
end
loop do 
    night_opened_FCR = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_entered >= #{@yesterday_evening} and date_entered < #{@this_morning} and (closed_by != 'Zadmin' and closed_by != 'ltadmin') and (team_name = 'FCR')")
    night_opened_fcr_array.push(night_opened_FCR) unless night_opened_FCR.nil? 
    break unless night_opened_FCR.nil? 
end
loop do 
    night_closed_SC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_morning} and date_closed < #{@this_morning} and (Board_Name = 'SC Services' or Board_Name = 'SC Internal') and (closed_by != 'Zadmin' and closed_by != 'ltadmin')")
    night_closed_sc_array.push(night_closed_SC) unless night_closed_SC.nil?  
    break unless night_closed_SC.nil? 
end
loop do 
    night_closed_NC = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_evening} and date_closed < #{@this_morning} and (Board_Name = 'NC Govt Services' or Board_Name = 'NC Govt Internal' and closed_by != 'Zadmin' and closed_by != 'ltadmin')")
    night_closed_nc_array.push(night_closed_NC) unless night_closed_NC.nil? 
    break unless night_closed_NC.nil? 
end
loop do 
    night_closed_GA = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_evening} and date_closed < #{@this_morning} and (Board_Name = 'GA Govt Services' or Board_Name = 'GA Govt Internal' and closed_by != 'Zadmin' and closed_by != 'ltadmin')")
    night_closed_ga_array.push(night_closed_GA) unless night_closed_GA.nil? 
    break unless night_closed_GA.nil? 
end
loop do 
    night_closed_FCR = cw_client.run_report_count("reportName" => "Service", "conditions" => "date_closed >= #{@yesterday_evening} and date_closed < #{@this_morning} and Board_Name = 'FCR' and closed_by != 'Zadmin' and closed_by != 'ltadmin'") 
    night_closed_fcr_array.push(night_closed_FCR) unless night_closed_FCR.nil? 
    break  unless night_closed_FCR.nil? 
end

end
#------------------------------------------------------------------> END main loop
unresolved_sc     = nil
unresolved_nc     = nil
unresolved_ga     = nil

loop do 
    unresolved_sc = cw_client.run_report_count("reportName" => "Service", "conditions" => "(Closed_Flag = 'False' and status_description != 'Resolved' and status_description != 'Resolved (RMM)') and Urgency != 'Do Not Respond' and (Territory = 'NETA' or Territory = 'SC' or Territory = 'Lancaster County, SC' or Territory = 'Jasper County') and (Board_Name = 'SC Services' or Board_Name = 'SC Internal' or Board_Name = 'FCR' or Board_Name = 'Labtech Alerts - Internal' or Board_Name = 'App Dev')")
    break unless unresolved_sc.nil? 
end
loop do 
    unresolved_nc = cw_client.run_report_count("reportName" => "Service", "conditions" => "(Closed_Flag = 'False' and status_description != 'Resolved' and status_description != 'Resolved (RMM)') and Urgency != 'Do Not Respond' and (Board_Name = 'NC Govt Services' or Board_Name = 'NC Govt Internal' or Board_Name = 'FCR' or Board_Name = 'Labtech Alerts - Internal' or Board_Name = 'App Dev')")
    break unless unresolved_nc.nil? 
end
loop do 
    unresolved_ga = cw_client.run_report_count("reportName" => "Service", "conditions" => "(Closed_Flag = 'False' and status_description != 'Resolved' and status_description != 'Resolved (RMM)') and Urgency != 'Do Not Respond' and (Territory = 'Boulder City' or Territory = 'City of Union City' or Territory = 'GA' or Territory = 'NC' or Territory = 'City of Milton') and (Board_Name = 'GA Govt Services' or Board_Name = 'GA Govt Internal' or Board_Name = 'FCR' or Board_Name = 'Labtech Alerts - Internal' or Board_Name = 'App Dev')")
    break unless unresolved_ga.nil? 
end

opened_SC         = opened_sc_array.inject(:+)
opened_NC         = opened_nc_array.inject(:+)
opened_GA         = opened_ga_array.inject(:+)
opened_FCR        = opened_fcr_array.inject(:+)
closed_SC         = closed_sc_array.inject(:+)
closed_NC         = closed_nc_array.inject(:+)
closed_GA         = closed_ga_array.inject(:+)
closed_FCR        = closed_fcr_array.inject(:+)
sc_closed         = sc_team_closed_array.inject(:+)
nc_closed         = nc_team_closed_array.inject(:+)
ga_closed         = ga_team_closed_array.inject(:+)
night_opened_SC   = night_opened_sc_array.inject(:+)
night_opened_NC   = night_opened_nc_array.inject(:+)
night_opened_GA   = night_opened_ga_array.inject(:+)
night_opened_FCR  = night_opened_fcr_array.inject(:+)
night_closed_SC   = night_closed_sc_array.inject(:+)
night_closed_NC   = night_closed_nc_array.inject(:+)
night_closed_GA   = night_closed_ga_array.inject(:+)
night_closed_FCR  = night_closed_fcr_array.inject(:+)

# reg hours
# ------------------------------
daily_totalOpened = opened_SC+ opened_NC + opened_GA + opened_FCR rescue nil
daily_totalClosed = closed_SC+ closed_NC + closed_GA + closed_FCR rescue nil
fcr_rate          = daily_totalClosed.to_f.send(:/, daily_totalOpened).send(:*,100) rescue nil
fcr_sc            = closed_SC.to_f.send(:/, opened_SC).send(:*,100) rescue nil
fcr_nc            = closed_NC.to_f.send(:/, opened_NC).send(:*,100) rescue nil
fcr_ga            = closed_GA.to_f.send(:/, opened_GA).send(:*,100) rescue nil
fcr_fcr           = closed_FCR.to_f.send(:/, opened_FCR).send(:*,100) rescue nil


# night hours
# -----------------------------
nightly_totalOpened = night_opened_SC + night_opened_NC + night_opened_GA + night_opened_FCR rescue nil
nightly_totalClosed = night_closed_SC + night_closed_NC + night_closed_GA + night_closed_FCR rescue nil

# totals 
# ----------------------------
tickets_opened     = daily_totalOpened + nightly_totalOpened rescue nil
tickets_closed     = daily_totalClosed + nightly_totalClosed + sc_closed + nc_closed + ga_closed rescue nil
tickets_unresolved = unresolved_sc + unresolved_nc + unresolved_ga rescue nil

if excel.include?(:tables)
    wb.add_worksheet(:name => "Week of #{tuesday}") do |sheet|
        sheet.add_row ["Vc3 Metrics"]
        sheet.add_row ["",""]
        sheet.add_row ["Total closed past week", "#{tickets_closed}"]
        sheet.add_row ["Total opened past week", "#{tickets_opened}"]
        sheet.add_row ["Total current unresolved", "#{tickets_unresolved}"]
        sheet.add_row ["",""]
        sheet.add_row ["",""]
        sheet.add_row ["FCR"]
        sheet.add_row ["Team", "Total", "FCR", "SC", "NC", "GA"]
        sheet.add_row ["Closed by FCR", "#{daily_totalClosed}", "#{closed_FCR}", "#{closed_SC}", "#{closed_NC}", "#{closed_GA}"]
        sheet.add_row ["Opened per team", "#{daily_totalOpened}", "#{opened_FCR}", "#{opened_SC}", "#{opened_NC}", "#{opened_GA}"]
        sheet.add_row ["FCR percent closed", "#{fcr_rate}", "#{fcr_fcr}", "#{fcr_sc}", "#{fcr_nc}", "#{fcr_ga}"]
        sheet.add_row ["",""]
        sheet.add_row ["Second and third Shift"]
        sheet.add_row ["Team", "Total", "FCR", "SC", "NC", "GA"]
        sheet.add_row ["Closed", "#{nightly_totalClosed}", "#{night_closed_FCR}", "#{night_closed_SC}", "#{night_closed_NC}", "#{night_closed_GA}"]
        sheet.add_row ["Opened", "#{nightly_totalOpened}", "#{night_opened_FCR}", "#{night_opened_SC}", "#{night_opened_NC}", "#{night_opened_GA}"]
        sheet.add_row ["",""]
        sheet.add_row ["Regional Teams"]
        sheet.add_row ["Team", "SC", "NC", "GA"]
        sheet.add_row ["Closed tickets by team past week", "#{sc_closed}", "#{nc_closed}", "#{ga_closed}"]
        sheet.add_row ["Total current unresloved by team", "#{unresolved_sc}", "#{unresolved_nc}", "#{unresolved_ga}"]
   end
end

p.serialize('weekly.xlsx')
#Email set up and send
# Define the from address.
mb_obj.set_from_address("reports@vc3.com", {"first"=>"Cameron", "last" => "Sowder"});
# Define a to recipient.
mb_obj.add_recipient(:to, "cameron.sowder@vc3.com", {"first" => "Cameron", "last" => "Sowder"});
# Define a cc recipient.
mb_obj.add_recipient(:to, "Amy.McKeown@vc3.com", {"first" => "Amy", "last" => "McKeown"});
#mb_obj.add_recipient(:to, "Team-FCR@vc3.com", {"first" => "Mark", "last" => "Carter"});
# Define the subject.
mb_obj.set_subject("Weekly report");
# Define the body of the message.
mb_obj.set_text_body("Weekly Report");
# Set the Message-Id header. Pass in a valid Message-Id.
mb_obj.set_message_id("<2014101400 0000.11111.11111@example.com>")
# Clear the Message-Id header. Pass in nil or empty string.
mb_obj.set_message_id(nil)
mb_obj.set_message_id('')
# Other Optional Parameters.
mb_obj.add_attachment("weekly.xlsx");


# Send your message through the client
mg_client.send_message("mg.vc3.com", mb_obj)
File.delete('weekly.xlsx')
