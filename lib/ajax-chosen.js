
(function($) {
  if ($ == null) $ = jQuery;
  return $.fn.ajaxChosen = function(settings, callback) {
    var chosenXhr, defaultOptions, options, select;
    if (settings == null) settings = {};
    if (callback == null) callback = function() {};
    defaultOptions = {
      minTermLength: 3,
      afterTypeDelay: 500,
      jsonTermKey: "term"
    };
    select = this;
    chosenXhr = null;
    options = $.extend({}, defaultOptions, settings);
    this.chosen();
    return this.next('.chzn-container').find(".search-field > input, .chzn-search > input").bind('keyup', function() {
      var field, msg, val;
      val = $.trim($(this).attr('value'));
      msg = val.length < options.minTermLength ? "Keep typing..." : "Looking for '" + val + "'";
      select.next('.chzn-container').find('.no-results').text(msg);
      if (val.length < options.minTermLength || val === $(this).data('prevVal')) {
        return false;
      }
      if (this.timer) clearTimeout(this.timer);
      $(this).data('prevVal', val);
      field = $(this);
      if (!(options.data != null)) options.data = {};
      options.data[options.jsonTermKey] = val;
      if (typeof success === "undefined" || success === null) {
        success = options.success;
      }
      options.success = function(data) {
        var items;
        if (!(data != null)) return;
        select.find('option').each(function() {
          if (!$(this).is(":selected")) return $(this).remove();
        });
        items = callback(data);
        $.each(items, function(value, text) {
          return $("<option />").attr('value', value).html(text).appendTo(select);
        });
        select.trigger("liszt:updated");
        if (typeof success !== "undefined" && success !== null) success();
        field.attr('value', val);
        return field.css('width', 'auto');
      };
      return this.timer = setTimeout(function() {
        if (chosenXhr) chosenXhr.abort();
        return chosenXhr = $.ajax(options);
      }, options.afterTypeDelay);
    });
  };
})($);
