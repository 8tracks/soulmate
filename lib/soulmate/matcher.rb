module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      options = { :limit => 5, :cache => true }.merge(options)

      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or Soulmate.stop_words.include?(w)
      end.sort

      return [] if words.empty?

      cachekey = "#{cachebase}:" + words.join('|')

      if !options[:cache] || !Soulmate.redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        Soulmate.redis.zinterstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      ids = Soulmate.redis.zrevrange(cachekey, 0, options[:limit] - 1)
      if ids.size > 0
        results = Soulmate.redis.hmget(database, *ids)
        results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
        results.map { |r| MultiJson.decode(r) }
      else
        []
      end
    end

    def offset_matches_for_term(term, options = {})
      start = options[:offset] || 0
      limit = options[:limit] || 10

      stop  =  start + limit - 1

      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or Soulmate.stop_words.include?(w)
      end.sort

      cachekey = "#{cachebase}:" + words.join('|')

      if !options[:cache] || !Soulmate.redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        Soulmate.redis.zinterstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      total_entries = Soulmate.redis.zcard(cachekey)
      ids = Soulmate.redis.zrevrange(cachekey, start, stop)

      collection = []

      unless ids.empty?
        results = Soulmate.redis.hmget(database, *ids)
        results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
        collection = results.map { |r| MultiJson.decode(r) }
      end

      OpenStruct.new(:collection => collection, :total_entries => total_entries)
    end

    def paginated_matches_for_term(term, options = {})
      options = { :page => 1, :per_page => 5, :cache => true }.merge(options)

      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or Soulmate.stop_words.include?(w)
      end.sort

      if words.empty?
        return WillPaginate::Collection.create(
            options[:page],
            options[:per_page]
          ) do |pager|
          pager.replace([])
          pager.total_entries = 0
        end
      end

      cachekey = "#{cachebase}:" + words.join('|')

      if !options[:cache] || !Soulmate.redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        Soulmate.redis.zinterstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      WillPaginate::Collection.create(
        options[:page],
        options[:per_page]
      ) do |pager|
        start = ((pager.current_page - 1) * pager.per_page)
        stop  = start + pager.per_page - 1

        ids = Soulmate.redis.zrevrange(cachekey, start, stop)
        if ids.size > 0
          results = Soulmate.redis.hmget(database, *ids)
          results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted

          pager.replace(results.map { |r| MultiJson.decode(r) })
          pager.total_entries = Soulmate.redis.zcard(cachekey)
        else
          pager.replace([])
          pager.total_entries = 0
        end
      end
    end
  end
end
