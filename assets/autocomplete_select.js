var SelectAutocompleter = Class.create(Ajax.Autocompleter, {
  render: function($super) {
    $super();
    if (this.entryCount == 0) {
      this.element.addClassName("not-found");
      setTimeout(function() { this.element.value = ""; }.bind(this), 250);
    } else {
      this.element.removeClassName("not-found");
    }
  }
});

var AutocompleteSelectors = {}

var AutocompleteSelect = Class.create({
  initialize: function(input, options) {
    this.container = $(input).hasClassName('autocomplete-select') ? $(input) : $(input).up('.autocomplete-select');
    this.search = this.container.down('input[type=text]');
    this.search_extras = this.container.down('.search-extras');
    this.field = this.container.down('input[type=hidden]');
    this.selector = this.container.down('.autocomplete');
    this.selection = this.container.down('.autocomplete-selection');

    new SelectAutocompleter(this.search, this.selector, this.search.getAttribute("resource_url"), $H({
      method: 'GET',
      paramName: 'search',
      autoSelect: true,
      afterUpdateElement: function(text, li) {
        this.set(li.id, li.innerHTML);
        this.selection.focus();
      }.bind(this)
    }).merge(options).toObject());

    this.selection.observe('click', this.clear.bind(this));
    if ($(input).hasClassName('autocomplete-selection')) this.clear();

    if (this.field.id) AutocompleteSelectors[this.field.id] = this;
  },

  set: function(value, display) {
    this.field.value = value;
    this.search.hide();
    if (this.search_extras) this.search_extras.hide();
    this.selection.innerHTML = display;
    this.selection.show();
    this.field.fire('hidden:change');
  },

  clear: function(event) {
    if (event) Event.stop(event);

    this.field.value = '';
    this.selection.hide();
    this.search.value = '';
    this.search.show();
    if (this.search_extras) this.search_extras.show();

    try {
      this.search.focus();
    } catch(e) {
      /* ignore exception thrown by IE when element is invisible */
    }
  },

  highlight: function(options) {
    this.container.highlight(options);
  }
})

AutocompleteSelect.activate = function() {
  $$('.autocomplete-select input[type=hidden]').each(function(e) {
    if (!e.autocomplete_select) {
      e.autocomplete_select = new AutocompleteSelect(e);
    }
  });
}

// make sure you call field.fire('hidden:change') when a hidden field changes
document.observe('dom:loaded', function() {
  $$('.autocomplete-select input[type=hidden]').each(function(e) {
    var onchange = e.getAttribute('onchange')
    if (onchange) {
      if (typeof(onchange) != 'function') {
        eval("onchange = (function(event){(function(){" + onchange + "}).bind(Event.element(event))()});");
      }
      e.observe('hidden:change', onchange);
    }
  });
})

// activate autocomplete select fields
document.observe('dom:loaded', function() {
  AutocompleteSelect.activate();
});
