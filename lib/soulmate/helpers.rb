# encoding: UTF-8

module Soulmate
  module Helpers

    def prefixes_for_phrase(phrase)
      words = normalize(phrase).split(' ').reject do |w|
        Soulmate.stop_words.include?(w)
      end
      words.map do |w|
        (MIN_COMPLETE-1..(w.length-1)).map{ |l| w[0..l] }
      end.flatten.uniq
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
end