(function() {
  var ajaxChosen, root;
  root = this;
  ajaxChosen = (function() {
    function ajaxChosen(select, options, callback) {
      new Chosen(select);
      select.next('.chzn-container').down('.chzn-search > input').observe('keyup', function() {
        var field, query_key, success, val;
        val = $(this).value.strip();
        if (val.length < 3 || val === $(this).readAttribute('data-prevVal')) {
          return false;
        }
        $(this).writeAttribute('data-prevVal', val);
        field = $(this);
        query_key = options.query_key || "term";
        (options.parameters = {})[query_key] = val;
        success = options.success;
        options.onSuccess = function(data) {
          var items;
          if (!(data != null)) {
            return;
          }
          select.childElements().each(function(el) {
            if (!el.selected) {
              return el.remove();
            }
          });
          items = callback ? callback(data.responseJSON) : data.responseJSON;
          $H(items).each(function(pair) {
            return select.insert({
              bottom: new Element("option", {
                value: pair.key
              }).update(pair.value)
            });
          });
          select.fire("liszt:updated");
          field.value = val;
          if (success != null) {
            return success();
          }
        };
        return new Ajax.Request(options.url, options);
      });
    }
    return ajaxChosen;
  })();
  root.ajaxChosen = ajaxChosen;
}).call(this);
