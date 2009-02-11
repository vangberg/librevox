# Here goes your database connection and options:

RAMAZE_DB_CONNECTION = ENV["RAMAZE_DB_CONNECTION"] || "sqlite:db/fsr.db"
require "rubygems"
require "ramaze"
require "sequel"

DB = Sequel.connect(RAMAZE_DB_CONNECTION)
# Here go your requires for models:
# require 'model/user'
