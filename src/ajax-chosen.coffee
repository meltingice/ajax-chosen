do ($ = jQuery) ->

  $.fn.ajaxChosen = (options, callback) ->
    # This will come in handy later.
    select = @
    
    chosenXhr = null
    
    # Set default option parameters
    minTermLength = options.minTermLength or 3      # Minimum term length to send ajax request.
    afterTypeDelay = options.afterTypeDelay or 500  # Delay after typing to send ajax request.
    jsonTermKey = options.jsonTermKey or "term"     # The term key name for the json service

    # Load chosen. To make things clear, I have taken the liberty
    # of using the .chzn-autoselect class to specify input elements
    # we want to use with ajax autocomplete.
    @chosen()
    
    # Now that chosen is loaded normally, we can bootstrap it with
    # our ajax autocomplete code.
    @next('.chzn-container')
      .find(".search-field > input")
      .bind 'keyup', ->
        # This code will be executed every time the user types a letter
        # into the input form that chosen has created
        
        # Retrieve the current value of the input form
        val = $.trim $(@).attr('value')

        msg = if val.length < minTermLength then "Keep typing..." else "Looking for '" + val + "'"
        select.next('.chzn-container').find('.no-results').text(msg)
        
        # Some simple validation so we don't make excess ajax calls. I am
        # assuming you don't want to perform a search with less than 3
        # characters.
        return false if val.length < minTermLength or val is $(@).data('prevVal')
        
        # We delay searches by a small amount so that we don't flood the
        # server with ajax requests.
        clearTimeout(@timer) if @timer
        
        # Set the current search term so we don't execute the ajax call if
        # the user hits a key that isn't an input letter/number/symbol
        $(@).data('prevVal', val)
        
        # This is a useful reference for later
        field = $(@)
        
        # Default term key is `term`.  Specify alternative in options.jsonTermKey
        options.data = {} if not options.data?
        options.data[jsonTermKey] = val
        
        # If the user provided an ajax success callback, store it so we can
        # call it after our bootstrapping is finished.
        success ?= options.success
        
        # Create our own callback that will be executed when the ajax call is
        # finished.
        options.success = (data) ->
          # Exit if the data we're given is invalid
          return if not data?
          
          # Go through all of the <option> elements in the <select> and remove
          # ones that have not been selected by the user.
          select.find('option').each -> $(@).remove() if not $(@).is(":selected")
          
          # Send the ajax results to the user callback so we can get an object of
          # value => text pairs to inject as <option> elements.
          items = callback data
          
          # Iterate through the given data and inject the <option> elements into
          # the DOM
          $.each items, (value, text) ->
            $("<option />")
              .attr('value', value)
              .html(text)
              .appendTo(select)
              
          # Tell chosen that the contents of the <select> input have been updated
          # This makes chosen update its internal list of the input data.
          select.trigger("liszt:updated")
          
          # Finally, call the user supplied callback (if it exists)
          success() if success?

          # For some reason, the contents of the input field get removed once you
          # call trigger above. Often, this can be very annoying (and can make some
          # searches impossible), so we add the value the user was typing back into
          # the input field.
          field.attr('value', val)
          
        # Execute the ajax call to search for autocomplete data with a timer
        @timer = setTimeout -> 
          chosenXhr.abort() if chosenXhr
          chosenXhr = $.ajax(options)
        , afterTypeDelay

    # This code assigns ajax for select tag without multiple option
    @next('.chzn-container')
      .find(".chzn-search > input")
      .bind 'keyup', ->
        val = $.trim $(@).attr('value')
        return false if val.length < minTermLength or val is $(@).data('prevVal')

        field = $(@)
        options.data = {}
        options.data[jsonTermKey] = val
        success ?= options.success

        options.success = (data) ->
          return if not data?
          select.find('option').each -> $(@).remove()
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
          chosenXhr.abort() if chosenXhr
          chosenXhr = $.ajax(options)
        , afterTypeDelay
