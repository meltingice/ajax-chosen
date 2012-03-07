(function() {
  (function($) {
    return $.fn.ajaxChosen = function(options, callback) {
      var select;
      select = this;
      this.chosen();
      this.next('.chzn-container').find(".search-field > input").bind('keyup', function() {
        var field, msg, val;
        val = $.trim($(this).attr('value'));
        msg = val.length < minTermLength ? "Keep typing..." : "Looking for '" + val + "'";
        select.next('.chzn-container').find('.no-results').text(msg);
        if (val.length < 3 || val === $(this).data('prevVal')) {
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
          field.attr('value', val);
          if (typeof success !== "undefined" && success !== null) {
            return success();
          }
        };
        return this.timer = setTimeout(function() {
          return $.ajax(options);
        }, 800);
      });
      return this.next('.chzn-container').find(".chzn-search > input").bind('keyup', function() {
        var field, val;
        val = $.trim($(this).attr('value'));
        if (val.length < 3 || val === $(this).data('prevVal')) {
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
        }, 800);
      });
    };
  })(jQuery);
}).call(this);
