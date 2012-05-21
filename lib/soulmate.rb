# encoding: UTF-8

require 'uri'
require 'multi_json'
require 'redis'

require 'soulmate/version'
require 'soulmate/helpers'
require 'soulmate/base'
require 'soulmate/matcher'
require 'soulmate/loader'

module Soulmate

  extend self

  MIN_COMPLETE = 2
  DEFAULT_STOP_WORDS = ["vs", "at", "the"]

  def redis_server=(redis)
    @redis = redis
    @redis_url = nil
  end

  def redis=(url)
    @redis = nil
    @redis_url = url
    redis
  end

  def redis
    @redis ||= (
      url = URI(@redis_url || ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0")

      ::Redis.new({
        :host => url.host,
        :port => url.port,
        :db => url.path[1..-1],
        :password => url.password
      })
    )
  end

  def stop_words
    @stop_words ||= DEFAULT_STOP_WORDS
  end

  def stop_words=(arr)
    @stop_words = Array(arr).flatten
  end


  def get_words(phrase)
    normalize(phrase).split(' ').reject do |w|
      Soulmate.stop_words.include?(w)
    end
  end
  
  def normalize(str)
    # str.downcase.gsub(/[^a-z0-9 ]/i, '').strip
    
    str = str.downcase.strip

    accents = {
       ['á','à','â','ä','ã'] => 'a',
       # ['Ã','Ä','Â','À','Á'] => 'A',
       ['é','è','ê','ë'] => 'e',
       # ['Ë','É','È','Ê'] => 'E',
       ['í','ì','î','ï'] => 'i',
       # ['Í','Î','Ì','Ï'] => 'I',
       ['ó','ò','ô','ö','õ'] => 'o',
       # ['Õ','Ö','Ô','Ò','Ó'] => 'O',
       ['ú','ù','û','ü'] => 'u',
       # ['Ú','Û','Ù','Ü'] => 'U',
       ['ç'] => 'c', ['Ç'] => 'C',
       ['ñ'] => 'n', ['Ñ'] => 'N'
    }

  	accents.each_pair do |ac, rep|
  	  ac.each do |a|
    		str = str.gsub(a, rep)
  	  end
  	end
    
    str
  end
end
