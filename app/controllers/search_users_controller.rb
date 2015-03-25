class SearchUsersController < ApplicationController

  def search_users
    authorize(current_user, :can_view_as?)
    users_found = User::SearchUsers.new(id: params['id']).search_users
    render json: { users: to_camel_keys(users_found) }.to_json
  end

  def search_users_by_uid
    authorize(current_user, :can_view_as?)
    users_found = User::SearchUsersByUid.new(id: params['id']).search_users_by_uid
    render json: { users: to_camel_keys(users_found) }.to_json
  end

  private
  def to_camel_keys(value)
    case value
      when Array
        value.map { |v| to_camel_keys(v) }
      when Hash
        Hash[value.map { |k, v| [k.camelize(:lower), to_camel_keys(v)] }]
      else
        value
    end
  end

end
