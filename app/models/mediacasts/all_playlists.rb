module Mediacasts
  class AllPlaylists < BaseProxy

    include ClassLogger, SafeJsonParser

    PROXY_ERROR = {
      :proxy_error_message => "There was a problem fetching the webcasts."
    }

    ERRORS = {
      :video_error_message => "There are no webcasts available."
    }

    def initialize(options = {})
      super(Settings.playlists_warehouse_proxy, options)
    end

    def get
      self.class.smart_fetch_from_cache(
        {user_message_on_exception: PROXY_ERROR[:proxy_error_message]}) do
        request_internal
      end
    end

    private

    def request_internal
      return {} unless Settings.features.videos
      if @fake
        logger.info "Fake = #@fake, getting data from JSON fixture file; cache expiration #{self.class.expires_in}"
        data = safe_json File.read(Rails.root.join('fixtures', 'json', 'webcasts.json').to_s)
      else
        response = get_response(
          @settings.base_url,
          basic_auth: {username: @settings.username, password: @settings.password},
          on_error: {return_feed: PROXY_ERROR}
        )
        data = response.parsed_response
      end

      if !data || !(data.is_a? Hash)
        raise Errors::ProxyError.new(
            'Error occurred converting response to json',
            response: response,
            url: @settings.base_url,
            return_feed: PROXY_ERROR
          )
      end

      processed_playlists = {
        courses: {}
      }
      data['courses'].each do |course|
        if course['year'] && course['semester'] && course['deptName'] && course['catalogId']
          key = Mediacasts::CourseMedia.course_id(course['year'], course['semester'], course['deptName'], course['catalogId'])
          processed_playlists[:courses][key] = {
            audio_only: course['audioOnly'],
            audio_rss: course['audioRSS'].to_s,
            recordings: course['recordings'],
            itunes_audio: course['iTunesAudio'].to_s,
            itunes_video: course['iTunesVideo'].to_s
          }
        end
      end

      processed_playlists
    end

  end
end

