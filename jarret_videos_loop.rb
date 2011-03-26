require "rubygems"
require "bundler"
Bundler.setup(:default)
Bundler.require(:default)
require 'yaml'
require 'cgi'

creds_path = File.join(File.dirname(__FILE__),'gmail.yml')
raise "Must have a gmail.yml, see gmail.example.yml" unless File.exist?(creds_path)
USERNAME, PASSWORD = YAML.load_file(creds_path).values_at('username','password')

LINK_NAMES = ['About the Expert: Jarret Delos Santos',
              'How to Play Ukulele: What is a Ukulele?',
              'Buying a Ukulele: What to Look For',
              'Buying a Ukulele: Accessories',
              'How to String a Ukulele',
              'How to Play Ukulele: Singing Tips',
              'How to Play Ukulele: Fingerpicking',
              'How to Tune a Ukulele: Tuning by Electric Tuner',
              'How to Tune a Ukulele: Tuning by Tuning Fork',
              'How to Tune a Ukulele: Tuning by Pitch Pipe',
              'Types of Ukuleles: Concert Ukulele',
              'Types of Ukuleles: Baritone Ukulele',
              'Types of Ukuleles: Soprano Ukulele',
              'How to Read Ukulele Chord Charts',
              'How to Read Ukulele Chord Charts']

def coerce_or_inspect(stringish)
  return stringish.to_s
rescue
  return stringish.inspect
end
              
def email_up_in_hurr(shout_out = nil)
  #Doesn't seem to work yet, or at least not in 1.9.2 on windows
  message = coerce_or_inspect shout_out

  Gmail.new(USERNAME, PASSWORD) do |gmail|
    gmail.deliver do
      to "#{USERNAME}@gmail.com"
      subject "will script for food"
      text_part do
        body "Just wanted to say #{message}"
      end
      html_part do
        body "<p>Well, if you <em>must</em> know... <strong>#{CGI.escape_html message}</strong></p>"
      end
    end
  end
end
  
page = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*chrome",
      :url => "http://www.howcast.com/",
      :timeout_in_second => 60
      
page.start_new_browser_session
page.open "/videos/453012-About-the-Expert-Jarret-Delos-Santos"
begin
  while "hell has yet to freeze over"
    sleep(40 + rand.*(80).to_i) #sleep for a random amount between 40 and 120 seconds
    
    #open up that hella sick playlist slider, who programmed the backend code for that? some cool guy I guess.
    page.click "link=open/close"
    sleep 1
    
    #click on a random uke video
    name = LINK_NAMES[rand.*(LINK_NAMES.size).to_i]
    page.click "link=#{name}"
    page.wait_for_page_to_load "30000" #stock directive from the selenium IDE
  end
rescue
  email_up_in_hurr "Unexpected error!#{$!.inspect}"
ensure
  #We want to leave this open for now so we can check it out
  #page.close_current_browser_session
end