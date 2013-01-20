# encoding: utf-8

module QueryableHelper
  unloadable
  
  include ActsAsQueryable::Helpers::Scripts
  include ActsAsQueryable::Helpers::Filters
  include ActsAsQueryable::Helpers::Columns
  include ActsAsQueryable::Helpers::GroupBy
  include ActsAsQueryable::Helpers::SortCriteria
  include ActsAsQueryable::Helpers::List
  include ActsAsQueryable::Helpers::Form

  # Public: Find a query by id, params, or session where appropriate.
  #
  # Returns nothing.
  def find_query
    if params[:query_id].present?
      find_query_by_id
    else
      if params[:set_filter] || session[query_session_key].nil?
        find_query_by_params
      else
        find_query_by_session
      end
    end
  end

  # Public: Conditions for the find_by methods when looking up a query by id.
  #
  # Returns a String or Hash of find conditions or nil.
  def find_query_by_id_conditions
  end

  # Public: Find a saved query by id and sets the @query instance variable.
  # The conditions for the find are taken from find_query_by_id_conditions.
  # The query id is stored in the session if found.
  #
  # Returns nothing.
  def find_query_by_id
    find_query_class
    @query = @query_class.find_by_id params[:query_id], :conditions => find_query_conditions
    return unless @query
    session[query_session_key] = {:id => @query.id}
  end

  # Public: Find a query in the session. First looks for a query by id if
  # an id is in the session. If a query with that id is not found (using 
  # find_query_conditions) a new query is instantiated with the rest of the 
  # attributes from the session, if any.
  #
  # Returns nothing.
  def find_query_by_session
    find_query_class
    attrs = session[query_session_key].present? ? session[query_session_key].dup : {}
    @query = @query_class.find_by_id(attrs[:id], :conditions => find_query_conditions) if attrs[:id]
    attrs.delete :id
    @query ||= @query_class.new(attrs.merge :name => "_")
  end

  # Public: Build a query from params. A new query is instantiated with
  # attributes from params and stored in the session as a Hash.
  #
  # Returns nothing.
  def find_query_by_params
    find_query_class
    @query = @query_class.new :name => "_"
    if params[:fields] || params[:f]
      @query.filters = {}
      @query.add_filters(params[:fields] || params[:f], params[:operators] || params[:op], params[:values] || params[:v])
    else
      @query.available_filters.each_key do |name|
        @query.add_short_filter(name, params[name]) if params[name]
      end
    end
    @query.group_by = params[:group_by]
    @query.columns = params[:c] || (params[:query] && params[:query][:columns])
    @query.sort_criteria = (params[:query] && params[:query][:sort_criteria])
    session[query_session_key] = {:filters => @query.filters, :group_by => @query.group_by, :columns => @query.columns, :sort_criteria => @query.sort_criteria}
  end

  # Public: Find the query class to use. Looks up the queryable_class
  # attribute to find the queryable class, then gets the query_class
  # from the queryable class.
  #
  # Returns nothing.
  def find_query_class
    @queryable_class ||= self.class.read_inheritable_attribute :queryable
    return unless @queryable_class && @queryable_class.queryable?
    @query_class ||= @queryable_class.query_class
    return unless @query_class
  end

  # Public: Build a query session key from the query_class.
  #
  # Returns a String session key.
  def query_session_key
    "query_#{@query_class.name.underscore.gsub '/', '_'}"
  end

  # Public: Translation shortcut. Passes arguments to I18n::t with a humanized
  # default based on the label.
  #
  # Returns the translated String.
  def qt(label, *args)
    t(label, :default => label.to_s.titleize)
  end
end
