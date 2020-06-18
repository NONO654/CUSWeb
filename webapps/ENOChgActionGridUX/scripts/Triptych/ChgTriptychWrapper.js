/**
 * @module DS/ENOXModelApp/components/Triptych/TriptychWrapper.js
 * @description
 */

define(
  'DS/ENOChgActionGridUX/scripts/Triptych/ChgTriptychWrapper',
  [
    'DS/ENOXTriptych/js/ENOXTriptych',
    'css!DS/ENOChgActionGridUX/ENOChgActionGridUX'
  ],
  function(
    ENOXTriptych,  
    _css_triptych_wrapper
  ) {
    'use strict';

    var TriptychWrapper = function() {};

    TriptychWrapper.prototype.init = function(applicationChannel, parentContainer, /*options,*/ left, main, right) {
      this._left = document.createElement('div');
      this._left.classList.add('ca-triptych-wrapper');
      this._main = document.createElement('div');
      this._main.classList.add('ca-triptych-wrapper');
      this._right = document.createElement('div');
      this._right.classList.add('ca-triptych-wrapper');

      this._applicationChannel = applicationChannel;
      this._triptych = new ENOXTriptych();
      var leftState = widget.body.offsetWidth < 550 ? 'close' : 'open';
      var triptychOptions = {
        left: {
          resizable: true,
          originalSize: 400,
          originalState: 'close', // 'open' for open, 'close' for close
          overMobile: true,
          withClose: false,
        },
        right: {
          resizable: true,
          minWidth: 250,
          originalSize: 400,
          originalState: 'close', // 'open' for open, 'close' for close
          overMobile: true
        },
        borderLeft: true,
        container: parentContainer, // options.container,
        withtransition: true,
        modelEvents: this._applicationChannel
      };
      this._triptych.init(triptychOptions, this._left, this._main, this._right);
    };

    TriptychWrapper.prototype.inject = function(container) {
      this._triptych.inject(container);
    };

    // expose Triptych API if need be..
    TriptychWrapper.prototype._getTriptych = function() {
      return this._triptych;
    };

    TriptychWrapper.prototype.getLeftPanelContainer = function() {
      return this._left;
    };
    TriptychWrapper.prototype.getLeftPanelContainerTriptych = function() {
      return this._triptych._leftPanelContent;
    };

    TriptychWrapper.prototype.getRightPanelContainer = function() {
      return this._right;
    };

    TriptychWrapper.prototype.getMainPanelContainer = function() {
      return this._main;
    };

    return TriptychWrapper;
  });
