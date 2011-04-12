module AutocompleteSelectHelper
  # Return a html script tag which includes the required javascript
  # files for autocomplete_select to operate.
  def autocomplete_select_includes
    javascript_include_tag "autocomplete_select/autocomplete_select.js"
  end
  
  # Create a autocompleting select field for the provided object and
  # method.  An example:
  #
  #   <% form_for :client do |f| %>
  #     <%= f.autocomplete_select :company_id %>
  #   <% end %>
  #
  # The above example will use the +company+ resource index with the
  # parameter +search+ to try and complete the entered company.
  #
  # A block may be given to add extra HTML snippets after the input
  # field;
  #
  #   <% f.autocomplete_select :company_id do %>
  #     Enter company name
  #   <% end %>
  #
  # The field will fire a change event when a selection is made.  Pass
  # a +onchange+ in +options+ to set it up;
  #
  #  <%= f.autocomplete_select :company_id, :onchange => 'App.updateCompany(this.value)' %>
  #
  # When the named association can not derived from the given
  # +method+, the +association+ option can be passed.
  #
  # The resource url is constructed from the association name with
  # +polymorphic_path+.  Extra options can be passed with the
  # +url_options+ option.
  # 
  # The visible value is normally obtained by calling +to_s+ on the
  # currently selected instance.  Use the +val_fn+ option to pass an
  # alternative Proc object.  Don't forget to produce simular output
  # in your autocomplete response in the associated controller/view.
  # 
  # The remaining options are passed to the hidden field which will
  # hold the id of the selected object.
  def autocomplete_select(object, method, options = {}, &block)
    attribute = method.to_s.gsub(/_id$/, '')
    association = options.delete(:association) || attribute
    errors = options[:object].errors
    disabled = options.delete(:disabled)
    val_fn = options.delete(:val_fn) || lambda{|val| h(val.to_s)}
    resource_url = polymorphic_path(association.to_s.pluralize,
                                    {:format => :autocomplete}.
                                    merge(options.delete(:url_options) || {}))
    input_options,
    extras_options,
    anchor_options = if value = options[:object].send(attribute)
                       [{:style => 'display:none'},
                        {:style => 'display:none'},
                        disabled ? {
                          :href => nil,
                          :class => "autocomplete-selection-disabled"
                        } : {}]
                     else
                       [{},
                        {},
                        {:style => 'display:none'}]
                     end
    
    container_class_names = ["autocomplete-select"]
    container_class_names << "fieldWithErrors" if errors.on(attribute) || errors.on(method)
    
    insert = capture(&block) if block_given?

    result = content_tag(:div,
                         hidden_field(object, method, options) +

                         tag(:input, {
                               :type => :text,
                               :value => "", :resource_url => resource_url
                             }.merge(input_options)) +

                         (insert ? content_tag(:span,
                                               insert,
                                               {
                                                 :class => 'search-extras'
                                               }.merge(extras_options)) : '') +

                         content_tag(:a, value ? val_fn.call(value) : "", {
                                       :href => '#',
                                       :class => 'autocomplete-selection'
                                     }.merge(anchor_options)) +

                         content_tag(:div, '', {
                                       :class => 'autocomplete',
                                       :style => 'display:none'
                                     }), {
                           :class => container_class_names.join(' ')
                         })
    
    if block_given? && block.binding.send(:eval, 'defined?(_erbout)')
      concat(result, block.binding)
    else
      result
    end
  end

  # Render an unordered list for an autocomplete response.  Provide a
  # +val_fn+ Proc object when +to_s+ on the instances in the
  # collection is not suitable as list item value.  The rest of the
  # options are passed as attributes for the +ul+ tag.
  def autocomplete_list(collection, options = {})
    val_fn = options.delete(:val_fn) || lambda{|val| h(val.to_s)}
    content_tag(:ul,
                collection.map{|val| content_tag(:li,
                                                 val_fn.call(val),
                                                 :id => val.id)}.join,
                options)
  end
end
