require 'active_record'
require 'json_translate/translates'
require 'json_translate/translates/class_methods'
require 'json_translate/translates/instance_methods'
require 'json_translate/translates/query_methods'

ActiveRecord::Base.extend(JSONTranslate::Translates)
