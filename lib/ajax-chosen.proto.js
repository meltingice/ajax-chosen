(function() {
  var ajaxChosen, root;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  root = this;
  ajaxChosen = (function() {
    __extends(ajaxChosen, Chosen);
    ajaxChosen.prototype.activate_field = function() {
      if (this.options.show_on_activate && !this.active_field) {
        this.results_show();
      }
      return ajaxChosen.__super__.activate_field.apply(this, arguments);
    };
    function ajaxChosen(select, options, callback) {
      this.options = options;
      ajaxChosen.__super__.constructor.call(this, select, options);
      select.next('.chzn-container').down('.chzn-search > input').observe('keyup', function() {
        var field, query_key, success, val;
        val = $(this).value.strip();
        if (val.length < 3 || val === $(this).readAttribute('data-prevVal')) {
          return false;
        }
        $(this).writeAttribute('data-prevVal', val);
        field = $(this);
        query_key = options.query_key || "term";
        (options.parameters || (options.parameters = {}))[query_key] = val;
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
            if (select.value !== pair.key) {
              return select.insert({
                bottom: new Element("option", {
                  value: pair.key
                }).update(pair.value)
              });
            }
          });
          val = field.value;
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
