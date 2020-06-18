define("DS/ENOChgActionGridUX/scripts/View/ChgTweakerExpandInput", [
  "UWA/Core",
  "DS/Tweakers/TweakerBase",
  "DS/Utilities/Dom",
  "DS/Utilities/Utils",
  "DS/Core/PointerEvents",
  'DS/Utilities/KeyboardUtils',
  'DS/ENOChgActionGridUX/scripts/View/ChgExpandInputTextBox',
  'DS/ENOChgActionGridUX/scripts/View/ChgCreateChangeAction'
], function (UWA, TweakerBase, DomUtils, Utils, PointerEvents, KeyboardUtils, ExpandInputTextBox, ChgCreateChangeAction) {
  "use strict";

  //Copy from tweaker for line editor
  function valueFromString(type, value) {
    switch (type) {
      case 'integer':
        var res = parseInt(value, 10);
        if (isNaN(res)) {
          this.valueType = "string";
          res = value ? value.toString() : '';
        }
        return res;
      case 'number':
        var res = parseFloat(value);
        if (isNaN(res)) {
          this.valueType = "string";
          res = value ? value.toString() : '';
        }
        return res;
      case 'boolean':
        return (/true/i.exec(value) !== null || value === '1');
      case 'string':
        return value ? value.toString() : '';
      case 'object':
        return JSON.parse(value);
      default:
        // T0 DO retrieve type from name and call a fromString method
        return value;
    }
  }

  //Copy from tweaker for line editor
  function stringFromValue(type, value) {
    if (typeof (value) === 'string')
      return value;

    if (type === 'object') {
      return JSON.stringify(value);
    }
    else if ((type === 'integer' || type === 'number') && ((Number.isNan && Number.isNaN(value) === true) || (isNaN !== undefined && isNaN(value) === true))) {
      return 'NaN';
    }
    else if (type === 'integer' || type === 'number') {// || type === 'string') {
      return value.toString();
    }
    else {
      return value;
    }
  }

  var TweakerExpandInput = TweakerBase.inherit({
    name: "TweakerExpandInput",
    publishedProperties: {
      displayStyle: {
        defaultValue: "TextBox",
        type: "string"
      },
      value: {
        defaultValue: "",
        type: "string",
        advancedSetter: true
      },
      valueType: {
        defaultValue: "string",
        type: "string"
      }
    },
    computeTweakerContentLength: function () {
      return this._getCurrentTouchMode() ? 19 : 14;
    },

    _upgradeValue: function (value) {
      if (value === "1" || value === 1 || value === "true" || value === true) {
        return true;
      } else if (
        value === "0" ||
        value === 0 ||
        value === "false" ||
        value === false
      ) {
        return false;
      } else {
        return "undefined";
      }
    }
  });

  var BaseViewModuleTweakerInput = function (tweaker, options) {
    TweakerBase.prototype.baseViewModule.call(this, tweaker, options);
  };
  Utils.applyMixin(
    BaseViewModuleTweakerInput,
    TweakerBase.prototype.baseViewModule
  );

  var WriteViewModuleTweakerInput = function (tweaker, options) {
    BaseViewModuleTweakerInput.call(this, tweaker, options);
  };
  Utils.applyMixin(WriteViewModuleTweakerInput, BaseViewModuleTweakerInput);

  WriteViewModuleTweakerInput.prototype.buildView = function () {
    var opt = this._options.viewOptions || {};
    opt.escapeHTML = this._tweaker.escapeHTML;
    opt.touchMode = this._tweaker._getCurrentTouchMode();
    opt.disabled = this._tweaker.readOnly;
    //  select all text when taking the focus.
    opt.selectAllOnFocus = true;
    opt.fireOnlyFromUIInteractionFlag = true;
    opt.autoCommitFlag = true;

    var linerEd = new ExpandInputTextBox(opt); //WUXLineEditor(opt);
    this._view = linerEd;

    this.setValue(this._tweaker.value);
  };

  WriteViewModuleTweakerInput.prototype.handleEvents = function () {
    // -- Shortcuts
    var me = this;
    var tweaker = this._tweaker;
    var view = this._view;

    // No event for readOnly case
    if (!view || !tweaker) {
      return;
    }

    //default method
    DomUtils.addEventOnElement(tweaker, view, "focus", function (e) {
      e.stopPropagation();
      // tweaker.onPreEdit();
    });

    //default method
    DomUtils.addEventOnElement(tweaker, view, "blur", function (e) {
      e.stopPropagation();
//      view.createCAContainer.style.setProperty("display","none");

      // End transaction if needed
      // A transaction is ended only once the focus is lost. Pressing ENTER
      // and firing a change does not end the transaction !
      tweaker.onPostEdit();
    });

    //default method
    DomUtils.addEventOnElement(tweaker, view, "uncommittedChange", function (e) {
      e.stopPropagation();
      tweaker.onPreEdit(); // onPreEdit done at the first uncommittedChange so that we always enter a transaction even after a cancel
    });

    DomUtils.addEventOnElement(tweaker, view.dropdown, "click", function (e) {
      e.stopPropagation();
      view.createCAContainer.style.setProperty("display","none");
    });

    //if (view._myInput) {
    DomUtils.addEventOnElement(tweaker, view.lineEditor /*view._myInput*/, "keydown", function (
      e
    ) {
      e.stopPropagation();
      view.lineEditor._clearFieldButton.style.removeProperty("display");    
      if (e.keyCode === KeyboardUtils.ESCAPE) {
        tweaker.onCancelEdit();
      }
      if (e.keyCode === KeyboardUtils.ENTER) {
        view.value = view.lineEditor.value;
        view.createCAContainer.style.setProperty("display","none");
        //tweaker.onChange();
        if (tweaker.keyDownEventCallback) {
          tweaker.keyDownEventCallback(e, tweaker, view.lineEditor);
        }
      }

    });
    //}

    DomUtils.addEventOnElement(tweaker, view, "change", function (e) {
      e.stopPropagation();
      var strVal = view.value;
      var validatedValue = undefined;
      if (strVal === undefined || strVal === null) {
        validatedValue = strVal;
      } else {
        validatedValue = valueFromString(tweaker.valueType, strVal);
      }
      me.setTweakerValue(validatedValue);
    });
  };

  WriteViewModuleTweakerInput.prototype.setValue = function (newValue) {
    var tweaker = this._tweaker;
    var view = this._view;
    if (!view || !tweaker) {
      return;
    }
    if (newValue === undefined || newValue === null) {
      view.value = newValue;
    } else {
      view.value = stringFromValue(tweaker.valueType, newValue);
    }
  };

  TweakerExpandInput.prototype.baseViewModule = BaseViewModuleTweakerInput;

  TweakerExpandInput.prototype.VIEW_MODULES = {
    TextBox: { classObject: WriteViewModuleTweakerInput },
    readOnly: { classObject: WriteViewModuleTweakerInput }
  };

  TweakerExpandInput.prototype.registerViewModule = function (
    identifier,
    viewModule
  ) {
    // TODO : Remove following line when new view modules will be allowed and
    // when VIEW_MODULES table will have an approve structure
    return;

    // Empty identifier, module, classObject or classPath not allowed.
    if (
      !identifier ||
      !viewModule ||
      (!viewModule.classObject && !viewModule.classPath)
    ) {
      return;
    }

    // Check that the module is not already registered
    // TODO : override de View module ?
    if (TweakerString.prototype.VIEW_MODULES[identifier] !== undefined) {
      return;
    }

    // Add the new viewModule
    // TODO : add Promesse
    // TODO : dynamic require to deal with classPath
    TweakerString.prototype.VIEW_MODULES[identifier] = viewModule;
  };

  TweakerExpandInput.prototype.registerkeyDownCallback = function (m) {
    this.keyDownEventCallback = m;
  }

  return TweakerExpandInput;
});
