module Soulmate
  module Helpers

    def prefixes_for_phrase(phrase)
      Soulmate.get_words(phrase).map do |w|
        (MIN_COMPLETE-1..(w.length-1)).map{ |l| w[0..l] }
      end.flatten.uniq
    end

    def normalize(str)
      Soulmate.normalize(str)
    end
  end
end