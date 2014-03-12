module Canvas
  class CourseProvision
    include ActiveAttr::Model, ClassLogger
    extend Calcentral::Cacheable

    # Admins cannot rely on CalCentral "Act As" in production because the instructor may not yet have logged into Calcentral.
    # Nor can we rely on Canvas "Masquerade" because the instructor may not yet have a bCourses account.
    # TODO Reconsider this requirement when bCourses User Provisioning is available.
    def initialize(uid, options={})
      @uid = uid
      @admin_acting_as = options[:admin_acting_as]
      @admin_by_ccns = options[:admin_by_ccns]
      @admin_term_slug = options[:admin_term_slug]
    end

    # Must be protected by a call to "user_authorized?"!
    def get_feed
      return nil unless user_authorized?
      self.class.fetch_from_cache instance_key do
        if @admin_term_slug && @admin_by_ccns
          get_feed_by_ccns_internal
        else
          get_feed_internal
        end
      end
    end

    def instance_key
      if @admin_term_slug && @admin_by_ccns
        instance_key = "#{@admin_term_slug}-#{@admin_by_ccns.join(',')}"
      elsif @admin_acting_as
        # Since admin state is part of the feed, the cache needs to distinguish an acting-as feed
        # from the instructor's own feed.
        instance_key = "#{@admin_acting_as}_#{@uid}"
      else
        instance_key = @uid
      end
      instance_key
    end

    def create_course_site(term_slug, ccns)
      return nil unless user_authorized?
      working_uid = @admin_acting_as || @uid
      cpcs = Canvas::CanvasProvideCourseSite.new(working_uid)
      cpcs.save
      cpcs.background.create_course_site(term_slug, ccns, @admin_by_ccns.present?)
      self.class.expire instance_key unless @admin_by_ccns
      cpcs.job_id
    end

    def get_feed_internal
      working_uid = @admin_acting_as || @uid
      worker = Canvas::CanvasProvideCourseSite.new(working_uid)
      feed = {
        is_admin: user_admin?,
        admin_acting_as: @admin_acting_as,
        teaching_semesters: worker.candidate_courses_list,
        admin_semesters: user_admin? ? worker.current_terms : nil
      }
      feed
    end

    def get_feed_by_ccns_internal
      worker = Canvas::CanvasProvideCourseSite.new(@uid)
      feed = {
        is_admin: user_admin?,
        admin_semesters: worker.current_terms,
        teaching_semesters: worker.courses_list_from_ccns(@admin_term_slug, @admin_by_ccns)
      }
      feed
    end

    def user_admin?
      policy = UserAuth.get(@uid).policy
      @uid.present? && policy.can_import_canvas_users?
    end

    def user_authorized?
      @uid.present? && (
      user_admin? || (
      @admin_acting_as.nil? &&
        @admin_by_ccns.nil? &&
        @admin_term_slug.nil?
      )
      )
    end

  end
end
