root = this

class ajaxChosen extends Chosen
  activate_field: ->
    if @options.show_on_activate and not @active_field
      this.results_show() 
    super
  
  constructor: (select, @options, callback) ->
    # Load chosen. To make things clear, I have taken the liberty
    # of using the .chzn-autoselect class to specify input elements
    # we want to use with ajax autocomplete.
    super select, options
    
    # Now that chosen is loaded normally, we can bootstrap it with
    # our ajax autocomplete code.
    select.next('.chzn-container')
      .down('.chzn-search > input')
      .observe 'keyup', ->
        # This code will be executed every time the user types a letter
        # into the input form that chosen has created
        
        # Retrieve the current value of the input form
        val = $(this).value.strip()
        # Some simple validation so we don't make excess ajax calls. I am
        # assuming you don't want to perform a search with less than 3
        # characters.
        
        return false if val.length < 3 or val is $(this).readAttribute('data-prevVal')
        
        # Set the current search term so we don't execute the ajax call if
        # the user hits a key that isn't an input letter/number/symbol
        $(this).writeAttribute('data-prevVal', val)
        
        # This is a useful reference for later
        field = $(this)
        
        # I'm assuming that it's ok to use the parameter name `term` to send
        # the form value during the ajax call. Change if absolutely needed.
        query_key = options.query_key || "term"
        (options.parameters ||= {})[query_key] = val
        
        # If the user provided an ajax success callback, store it so we can
        # call it after our bootstrapping is finished.
        success = options.success
        
        # Create our own callback that will be executed when the ajax call is
        # finished.
        options.onSuccess = (data) ->       
          # Exit if the data we're given is invalid
          return if not data?

          # Go through all of the <option> elements in the <select> and remove
          # ones that have not been selected by the user.
          select.childElements().each (el) -> el.remove() if not el.selected

          # Send the ajax results to the user callback so we can get an object of
          # value => text pairs to inject as <option> elements.
          items = if callback then callback(data.responseJSON) else data.responseJSON

          # Iterate through the given data and inject the <option> elements into
          # the DOM
          $H(items).each (pair) ->
            if select.value != pair.key
              select.insert
                bottom:
                  new Element("option", {value: pair.key})
                    .update(pair.value)
              
          val = field.value
              
          # Tell chosen that the contents of the <select> input have been updated
          # This makes chosen update its internal list of the input data.
          select.fire("liszt:updated")
          
          # For some reason, the contents of the input field get removed once you
          # call trigger above. Often, this can be very annoying (and can make some
          # searches impossible), so we add the value the user was typing back into
          # the input field.
          field.value = val
          
          # Finally, call the user supplied callback (if it exists)
          success() if success?
          
        # Execute the ajax call to search for autocomplete data
        new Ajax.Request options.url, options
        
root.ajaxChosen = ajaxChosen