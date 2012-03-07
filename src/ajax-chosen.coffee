(($) ->

  $.fn.ajaxChosen = (options, callback) ->
    # This will come in handy later.
    select = this
    
    
    # Set default option parameters
    minTermLength = options.minTermLength || 3  # Minimum term length to send ajax request.
    afterTypeDelay = options.afterTypeDelay || 800       # Delay after typing to send ajax request.

    # Load chosen. To make things clear, I have taken the liberty
    # of using the .chzn-autoselect class to specify input elements
    # we want to use with ajax autocomplete.
    this.chosen()
    
    # Now that chosen is loaded normally, we can bootstrap it with
    # our ajax autocomplete code.
    this.next('.chzn-container')
      .find(".search-field > input")
      .bind 'keyup', (e) ->
        # This code will be executed every time the user types a letter
        # into the input form that chosen has created
        
        # Retrieve the current value of the input form
        val = $.trim $(this).attr('value')
        
        # Some simple validation so we don't make excess ajax calls. I am
        # assuming you don't want to perform a search with less than 3
        # characters.  Also don't make ajax call for control characters (cmd, shift)
        return false if val.length < minTermLength or 
          val is $(this).data('prevVal') or 
          [16,91,93].indexOf(e.keyCode) > -1
        
        # We delay searches by a small amount so that we don't flood the
        # server with ajax requests.
        clearTimeout(@timer) if @timer
        
        # Set the current search term so we don't execute the ajax call if
        # the user hits a key that isn't an input letter/number/symbol
        $(this).data('prevVal', val)
        
        # This is a useful reference for later
        field = $(this)
        
        # I'm assuming that it's ok to use the parameter name `term` to send
        # the form value during the ajax call. Change if absolutely needed.
        options.data = term: val
        
        # If the user provided an ajax success callback, store it so we can
        # call it after our bootstrapping is finished.
        success ?= options.success
        
        # Create our own callback that will be executed when the ajax call is
        # finished.
        options.success = (data) ->
          # Exit if the data we're given is invalid
          return if not data?
          
          # Go through all of the <option> elements in the <select> and remove
          # ones that have not been selected by the user.  For those selected
          # by the user, add them to a list to filter from the results later.
          selected_values = []
          select.find('option').each -> 
            if not $(this).is(":selected")
              $(this).remove() 
            else
              selected_values.push $(this).val() + "-" + $(this).text()
              
          # Send the ajax results to the user callback so we can get an object of
          # value => text pairs to inject as <option> elements.
          items = callback data
          
          # Iterate through the given data and inject the <option> elements into
          # the DOM if it doesn't exist in the selector already
          $.each items, (value, text) ->
            if selected_values.indexOf(value + "-" + text) == -1
              $("<option />")
                .attr('value', value)
                .html(text)
                .appendTo(select)
              
          # Tell chosen that the contents of the <select> input have been updated
          # This makes chosen update its internal list of the input data.
          select.trigger("liszt:updated")
          
          # For some reason, the contents of the input field get removed once you
          # call trigger above. Often, this can be very annoying (and can make some
          # searches impossible), so we add the value the user was typing back into
          # the input field.
          field.attr('value', val)
          
          # Because non-ajax Chosen isn't constantly re-building results, when it
          # DOES rebuild results (during liszt:updated above, it clears the input 
          # search field before scaling it.  This causes the input field width to be 
          # at it's minimum, which is about 25px.  

          # The proper way to fix this would be create a new method in chosen for
          # rebuilding results without clearing the input field.  Or to call 
          # Chosen.search_field_scale() after resetting the value above.  This isn't
          # possible with the current state of Chosen.  The quick fix is to simply reset
          # the width of the field after we reset the value of the input text.
          field.css('width','auto')

          # Finally, call the user supplied callback (if it exists)
          success() if success?
          
        # Execute the ajax call to search for autocomplete data with a timer
        @timer = setTimeout -> 
          $.ajax(options)
        , afterTypeDelay

    # (JPascal) This code assign ajax for select tag without multiple option
    this.next('.chzn-container')
      .find(".chzn-search > input")
      .bind 'keyup', (e) ->
        val = $.trim $(this).attr('value')
        return false if val.length < minTermLength or 
          val is $(this).data('prevVal') or
          [16,91,93].indexOf(e.keyCode) > -1
        field = $(this)
        options.data = term: val
        success ?= options.success
        options.success = (data) ->
          return if not data?
          select.find('option').each -> $(this).remove()
          items = callback data
          $.each items, (value, text) ->
            $("<option />")
              .attr('value', value)
              .html(text)
              .appendTo(select)
          select.trigger("liszt:updated")
          field.attr('value', val)
          success() if success?
        @timer = setTimeout -> 
          $.ajax(options)
        , afterTypeDelay
)(jQuery)