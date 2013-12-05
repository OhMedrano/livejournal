require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'sinatra/activerecord'

require 'rack-flash'
require 'bcrypt'

configure(:development){ set :database, 'sqlite3:///twitter.sqlite3' }

require './models'

#stuff you need for the flash
enable :sessions
use Rack::Flash, :sweep => true
set :sessions => true