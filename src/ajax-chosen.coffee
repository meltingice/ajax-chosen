do ($ = jQuery) ->
  defaultOptions =
    minTermLength: 3
    afterTypeDelay: 500
    jsonTermKey: "term"
    keepTypingMsg: "Keep typing..."
    lookingForMsg: "Looking for"

  class ajaxChosen
    constructor: (@element, settings, callback, chosenOptions) ->
      chosenXhr = null

      @callback_function = callback

      # Merge options with defaults
      @options = $.extend {}, defaultOptions, @element.data(), settings

      # If the user provided an ajax success callback, store it so we can
      # call it after our bootstrapping is finished.
      @success = settings.success

      # Load chosen. To make things clear, I have taken the liberty
      # of using the .chosen-autoselect class to specify input elements
      # we want to use with ajax autocomplete.
      @element.chosen(if chosenOptions then chosenOptions else {})

      # Now that chosen is loaded normally, we can bootstrap it with
      # our ajax autocomplete code.
      @search_field = @element.next('.chosen-container')
        .find(".search-field > input, .chosen-search > input")

      @register_observers()

    register_observers: ->
      @search_field.keyup (evt) => @update_list(evt); return
      @search_field.focus (evt) => @search_field_focused(evt); return

    search_field_focused: (evt) ->
      return @update_list(evt) if @options.minTermLength == 0 and @search_field.val().length == 0

    update_list: (evt) ->
      # This code will be executed every time the user types a letter
      # into the input form that chosen has created

      # Retrieve the current value of the input form
      @untrimmed_val = @search_field.val()
      val = $.trim @search_field.val()

      # Depending on how much text the user has typed, let them know
      # if they need to keep typing or if we are looking for their data
      msg = if val.length < @options.minTermLength then @options.keepTypingMsg else @options.lookingForMsg + " '#{val}'"
      @element.next('.chosen-container').find('.no-results').text(msg)

      # If input text has not changed ... do nothing
      return false if val is @search_field.data('prevVal')

      # Set the current search term so we don't execute the ajax call if
      # the user hits a key that isn't an input letter/number/symbol
      @search_field.data('prevVal', val)

      # At this point, we have a new term/query ... the old timer
      # is no longer valid.  Clear it.

      # We delay searches by a small amount so that we don't flood the
      # server with ajax requests.
      clearTimeout(@timer) if @timer

      # Do not make ajax calls if search value length is lower than the minimum term length
      return false if val.length < @options.minTermLength

      # Default term key is `term`.  Specify alternative in @options.options.jsonTermKey
      @options.data = {} unless @options.data?
      @options.data[@options.jsonTermKey] = val
      @options.data = @options.dataCallback(@options.data) if @options.dataCallback?

      _this = @
      options = @options

      options.success = (data) ->
        _this.show_results(data)

      # Execute the ajax call to search for autocomplete data with a timer
      @timer = setTimeout ->
        _this.chosenXhr.abort() if _this.chosenXhr
        _this.chosenXhr = $.ajax(options)
      , options.afterTypeDelay

    # Create our own callback that will be executed when the ajax call is
    # finished.
    show_results: (data) ->
      # Exit if the data we're given is invalid
      return unless data?

      # Go through all of the <option> elements in the <select> and remove
      # ones that have not been selected by the user.  For those selected
      # by the user, add them to a list to filter from the results later.
      selected_values = []
      @element.find('option').each ->
        if not $(@).is(":selected")
          $(@).remove()
        else
          selected_values.push $(@).val() + "-" + $(@).text()
      @element.find('optgroup:empty').each ->
        $(@).remove()

      # Send the ajax results to the user callback so we can get an object of
      # value => text pairs to inject as <option> elements.
      items = if @callback_function? then @callback_function(data, @search_field) else data

      nbItems = 0

      _this = @

      # Iterate through the given data and inject the <option> elements into
      # the DOM if it doesn't exist in the selector already
      $.each items, (i, element) ->
        nbItems++

        if element.group
          group = _this.element.find("optgroup[label='#{element.text}']")
          group = $("<optgroup />") unless group.size()

          group.attr('label', element.text)
            .appendTo(_this.element)
          $.each element.items, (i, element) ->
            if typeof element == "string"
              value = i;
              text = element;
            else
              value = element.value;
              text = element.text;
            if $.inArray(value + "-" + text, selected_values) == -1
              $("<option />")
                .attr('value', value)
                .html(text)
                .appendTo(group)
        else
          if typeof element == "string"
            value = i;
            text = element;
          else
            value = element.value;
            text = element.text;
          if $.inArray(value + "-" + text, selected_values) == -1
            $("<option />")
              .attr('value', value)
              .html(text)
              .appendTo(_this.element)

      if nbItems
        # Tell chosen that the contents of the <select> input have been updated
        # This makes chosen update its internal list of the input data.
        @element.trigger("chosen:updated")
      else
        # If there are no results, display the no_results text
        @element.data().chosen.no_results_clear()
        @element.data().chosen.no_results @search_field.val()

      # Finally, call the user supplied callback (if it exists)
      @success(data) if @success?

      # For some reason, the contents of the input field get removed once you
      # call trigger above. Often, this can be very annoying (and can make some
      # searches impossible), so we add the value the user was typing back into
      # the input field.
      @search_field.val(@untrimmed_val)

      # Because non-ajax Chosen isn't constantly re-building results, when it
      # DOES rebuild results (during chosen:updated above, it clears the input
      # search field before scaling it.  This causes the input field width to be
      # at it's minimum, which is about 25px.

      # The proper way to fix this would be create a new method in chosen for
      # rebuilding results without clearing the input field.  Or to call
      # Chosen.search_field_scale() after resetting the value above.  This isn't
      # possible with the current state of Chosen.  The quick fix is to simply reset
      # the width of the field after we reset the value of the input text.
      # @search_field.css('width','auto')

    $.fn.ajaxChosen = (options = {}, callback, chosenOptions = {}) ->
      @each ->
        new ajaxChosen($(@), options, callback, chosenOptions)

