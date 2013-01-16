# encoding: utf-8

module QueryableHelper
  unloadable
  
  include ActsAsQueryable::Helpers::Scripts
  include ActsAsQueryable::Helpers::Filters
  include ActsAsQueryable::Helpers::Columns
  include ActsAsQueryable::Helpers::GroupBy
  include ActsAsQueryable::Helpers::Sort
  include ActsAsQueryable::Helpers::List
  include ActsAsQueryable::Helpers::Form

  def query_session_key
    "query_#{@query_class.name.underscore.gsub '/', '_'}"
  end

  def find_query
    @queryable_class = self.class.read_inheritable_attribute :queryable
    return unless @queryable_class && @queryable_class.queryable?
    @query_class ||= @queryable_class.query_class
    return unless @query_class

    if !params[:query_id].blank?
      @query = @query_class.find_by_id params[:query_id]
      return unless @query
      session[query_session_key] = {:id => @query.id}
    else
      if params[:set_filter] || session[query_session_key].nil?
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
      else
        attrs = session[query_session_key].dup
        @query = @query_class.find_by_id(attrs[:id]) if attrs[:id]
        attrs.delete :id
        @query ||= @query_class.new(attrs.merge :name => "_")
      end
    end
  end
end
