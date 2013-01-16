# encoding: utf-8

module ActsAsQueryable::Helpers
  module Form

    def query_form_tag(query=nil, url_for_options={}, options={}, &block)
      query ||= @query
      form_tag(url_for_options, {:id => "query_form", :onsubmit => "return false;"}.merge(options)) do
        if block_given?
          yield
        else
          concat query_filters(query)
          concat query_columns(query)
          concat query_group_by(query)
          concat query_sort_criteria(query)
          concat query_apply_button(query)
        end
      end
    end

    # Public: Render an "apply" button for the filter.
    #
    # query - A Queryable or nil to use the @query instance variable.
    # options - A Hash of options.
    #
    # Returns the button as a String.
    def query_apply_button(query=nil, options={})
      query ||= @query
      link_to_remote qt(:apply), { 
        :url => { :set_filter => 1 },
        :before => "selectAllOptions('selected_columns');",
        :update => "content",
        :complete => "apply_filters_observer()",
        :with => "Form.serialize('query_form')"
      }.merge(options)
    end

    def query_errors(query=nil)
      query ||= @query
      error_messages_for "query", :object => query
    end
  end
end