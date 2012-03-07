(function() {
  (function($) {
    return $.fn.ajaxChosen = function(options, callback) {
      var afterTypeDelay, minTermLength, select;
      select = this;
      minTermLength = options.minTermLength || 3;
      afterTypeDelay = options.afterTypeDelay || 800;
      this.chosen();
      this.next('.chzn-container').find(".search-field > input").bind('keyup', function(e) {
        var field, val;
        val = $.trim($(this).attr('value'));
        if (val.length < minTermLength || val === $(this).data('prevVal') || [16, 91, 93].indexOf(e.keyCode) > -1) {
          return false;
        }
        if (this.timer) {
          clearTimeout(this.timer);
        }
        $(this).data('prevVal', val);
        field = $(this);
        options.data = {
          term: val
        };
        if (typeof success === "undefined" || success === null) {
          success = options.success;
        }
        options.success = function(data) {
          var items, selected_values;
          if (!(data != null)) {
            return;
          }
          selected_values = [];
          select.find('option').each(function() {
            if (!$(this).is(":selected")) {
              return $(this).remove();
            } else {
              return selected_values.push($(this).val() + "-" + $(this).text());
            }
          });
          items = callback(data);
          $.each(items, function(value, text) {
            if (selected_values.indexOf(value + "-" + text) === -1) {
              return $("<option />").attr('value', value).html(text).appendTo(select);
            }
          });
          select.trigger("liszt:updated");
          field.attr('value', val);
          field.css('width', 'auto');
          if (typeof success !== "undefined" && success !== null) {
            return success();
          }
        };
        return this.timer = setTimeout(function() {
          return $.ajax(options);
        }, afterTypeDelay);
      });
      return this.next('.chzn-container').find(".chzn-search > input").bind('keyup', function(e) {
        var field, val;
        val = $.trim($(this).attr('value'));
        if (val.length < minTermLength || val === $(this).data('prevVal') || [16, 91, 93].indexOf(e.keyCode) > -1) {
          return false;
        }
        field = $(this);
        options.data = {
          term: val
        };
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
          return $.ajax(options);
        }, afterTypeDelay);
      });
    };
  })(jQuery);
}).call(this);
