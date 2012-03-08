(function() {
  (function($) {
    if ($ == null) {
      $ = jQuery;
    }
    return $.fn.ajaxChosen = function(settings, callback) {
      var chosenXhr, defaultOptions, options, select;
      if (settings == null) {
        settings = {};
      }
      if (callback == null) {
        callback = function() {};
      }
      defaultOptions = {
        minTermLength: 3,
        afterTypeDelay: 500,
        jsonTermKey: "term"
      };
      select = this;
      chosenXhr = null;
      options = $.extend({}, defaultOptions, settings);
      this.chosen();
      this.next('.chzn-container').find(".search-field > input").bind('keyup', function(e) {
        var field, msg, val;
        val = $.trim($(this).attr('value'));
        msg = val.length < options.minTermLength ? "Keep typing..." : "Looking for '" + val + "'";
        select.next('.chzn-container').find('.no-results').text(msg);
        if (val.length < options.minTermLength || val === $(this).data('prevVal') || [16, 91, 93].indexOf(e.keyCode) > -1) {
          return false;
        }
        if (this.timer) {
          clearTimeout(this.timer);
        }
        $(this).data('prevVal', val);
        field = $(this);
        if (!(options.data != null)) {
          options.data = {};
        }
        options.data[options.jsonTermKey] = val;
        if (typeof success === "undefined" || success === null) {
          success = options.success;
        }
        options.success = function(data) {
          var items;
          if (!(data != null)) {
            return;
          }
          select.find('option').each(function() {
            if (!$(this).is(":selected")) {
              return $(this).remove();
            }
          });
          items = callback(data);
          $.each(items, function(value, text) {
            return $("<option />").attr('value', value).html(text).appendTo(select);
          });
          select.trigger("liszt:updated");
          if (typeof success !== "undefined" && success !== null) {
            success();
          }
          return field.attr('value', val);
        };
        return this.timer = setTimeout(function() {
          if (chosenXhr) {
            chosenXhr.abort();
          }
          return chosenXhr = $.ajax(options);
        }, options.afterTypeDelay);
      });
      return this.next('.chzn-container').find(".chzn-search > input").bind('keyup', function(e) {
        var field, val;
        val = $.trim($(this).attr('value'));
        if (val.length < options.minTermLength || val === $(this).data('prevVal') || [16, 91, 93].indexOf(e.keyCode) > -1) {
          return false;
        }
        field = $(this);
        options.data = {};
        options.data[options.jsonTermKey] = val;
        if (typeof success === "undefined" || success === null) {
          success = options.success;
        }
        options.success = function(data) {
          var items;
          if (!(data != null)) {
            return;
          }
          select.find('option').each(function() {
            return $(this).remove();
          });
          items = callback(data);
          $.each(items, function(value, text) {
            return $("<option />").attr('value', value).html(text).appendTo(select);
          });
          select.trigger("liszt:updated");
          field.attr('value', val);
          if (typeof success !== "undefined" && success !== null) {
            return success();
          }
        };
        return this.timer = setTimeout(function() {
          if (chosenXhr) {
            chosenXhr.abort();
          }
          return chosenXhr = $.ajax(options);
        }, options.afterTypeDelay);
      });
    };
  })($);
}).call(this);
