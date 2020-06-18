
/**
* Component to handle 2 resizable Views on Vertical level. Can be % or px based.
*/
define('DS/ENOXSplitViewVertical/js/ENOXSplitViewVertical', [
    'DS/CoreEvents/ModelEvents',
    'DS/Handlebars/Handlebars',
    'text!DS/ENOXSplitViewVertical/html/ENOXSplitViewVertical.html',
    'css!DS/ENOXSplitViewVertical/css/ENOXSplitViewVertical.css'
],

function (
        ModelEvents,
        Handlebars,
        _html_ENOXSplitViewVertical,
        _css_ENOXSplitViewVertical
    ) {
    'use strict';

    /* Fetching the panel template through Handlebars */
    var panelTemplate = Handlebars.compile(_html_ENOXSplitViewVertical);
    var debug_resizer = false;


    var ENOXSplitViewVertical = function () {
        this._options = {};
    };

    ENOXSplitViewVertical.prototype.init = function (options) {
        this._options.withtransition = options && options.withtransition !== undefined ? options.withtransition : true; // by default, transitions are applied
        this._options.sizeType = options && (options.sizeType === '%' || options.sizeType === 'px') ? options.sizeType : 'px'; // by default, px based-view, but could be used in '%' (cannot switch from one to the other)
        this._options.resizable = options && options.resizable ? options.resizable : false; // not implemented for now, to know whether we have a 'grip' to manually resize the two containers
        if (this._options.resizable && options.sizeType === '%') this._options.resizable = false; // cannot resize in px base view for now
        this._options.withoverflowhidden = options && options.withoverflowhidden !== undefined ? options.withoverflowhidden : false;

        this._modelEvents = options && options.modelEvents ? options.modelEvents : new ModelEvents(); // still handle internally a modelevents (for ease of code)
        this._top = options && options.originalTop ? options.originalTop : 50; // by default, 50% or 50px if only px defined...
        this._options.withBotMaximize = options && options.withBotMaximize ? options.withBotMaximize : false; // not implemented for now, would add a button to max btm
        this._options.withTopMaximize = options && options.withTopMaximize ? options.withTopMaximize : false; // not implemented for now, would add a button to max top

        this._topVisible = true;
        this._botVisible = true;
        this._maxHeightOnTop = 600;

        this._subscribeToEvents();
        this._initDivs(); // 'create div' without appending them (render sortof)
        this.__number = 40;
    };

    ENOXSplitViewVertical.prototype._initDivs = function () {
        this._container = document.createElement('div');
        var container = panelTemplate(this._options);
        this._container.innerHTML = container;
        this._container = this._container.firstChild; // work around not to create an additional (useless) div

        // set the different 'useful' private containers : top container, bot container, and resizer (not used atm)
        this._topPanel = this._container.querySelector('.top-container');
        this._botPanel = this._container.querySelector('.bot-container');
        this._resizer = this._container.querySelector('.resizer');
        this._initresizer();
        this._resize();
    };

    // for showTop, showBot, hideTop, hideBot, hideSide, showSide, toggleSide methods, please check in ENOXSplitView
    // (not needed as for today in Vertical view - this not implemented yet)
    // Same goes for _initResizer

    ENOXSplitViewVertical.prototype.getTop = function () {
        return this._topPanel;
    };
    ENOXSplitViewVertical.prototype.getBot = function () {
        return this._botPanel;
    };
    ENOXSplitViewVertical.prototype.getContent = function () { // should not be used straight away ?
        return this._container;
    };

    // inject, append the container on a given parentContainer
    ENOXSplitViewVertical.prototype.inject = function (parentContainer) {
        parentContainer.appendChild(this._container);
    };

    ENOXSplitViewVertical.prototype._subscribeToEvents = function () {
        var that = this;
        this._listSubscription = [];
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-vertical-set-top-size' }, function (size) {
            that._resize(size);
        }));

        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-vertical-set-max-top-size' }, function(maxsize){
          that._maxHeightOnTop = maxsize;
        }));
    };

    ENOXSplitViewVertical.prototype._initresizer = function () {
        if (debug_resizer) console.log('init resizer');
        var that = this;
        if (!this._resizer) {
            return; // secure test in case it's not resizable
        }

        // internal functions
        var stopanimation = function () { // prevent animation when resizing manually on mobile/desktop using the resize-handler
            that._topPanel.classList.remove('withtransition');
            that._botPanel.classList.remove('withtransition');
        };
        var startanimation = function () { // restart animations
            if (that._options.withtransition) {
                that._topPanel.classList.add('withtransition');
                that._botPanel.classList.add('withtransition');
            }
        };
        var pauseEvent = function (event_param) {
            //https://stackoverflow.com/questions/5429827/how-can-i-prevent-text-element-selection-with-cursor-drag
            if (event_param.stopPropagation) event_param.stopPropagation();
            if (event_param.preventDefault) event_param.preventDefault();
            event_param.cancelBubble = true;
            event_param.returnValue = false;
            return false;
        };

        var initialY = null;
        var beginY = null;
        var finalY = null;
        var resizing = false;
        var initResize = function (e) {
            stopanimation();
            initialY = that._top;
            beginY = e.clientY ? e.clientY : e.touches[0].clientY;
            resizing = true;
            pauseEvent(e);
            if (e.type === 'touchstart') {
                document.addEventListener('touchmove', doResize);
                document.addEventListener('touchend', stopResize);
            }
            else if (e.type === 'mousedown') {
                document.addEventListener('mousemove', doResize);
                document.addEventListener('mouseup', stopResize);
            }
        };
        var doResize = function (e) {
            var currentY = e.clientY ? e.clientY : e.touches[0].clientY;
            if (resizing) { // secure test
                //that._top = initialY + (currentY - beginY);//Math.max(MIN_OPENED_SIZE, initialLeft + (currentX - beginX) * 100 / totalX);
                //that._top = Math.min(80, that._leftWidth);
                that._resize(initialY + (currentY - beginY));
            }
        };
        var stopResize = function (e) {
            startanimation();
            resizing = false;
            if (e.type === 'touchend') {
                document.removeEventListener('touchmove', doResize);
                document.removeEventListener('touchend', stopResize);
            }
            else if (e.type === 'mouseup') {
                document.removeEventListener('mousemove', doResize);
                document.removeEventListener('mouseup', stopResize);
            }
        };
        this._resizer.addEventListener('mousedown', initResize);
        this._resizer.addEventListener('touchstart', initResize);
    };

    ENOXSplitViewVertical.prototype._resize = function (param) {
        if (this._topVisible && this._botVisible) { // case both panels are visible
            if (this._options.sizeType === '%') { // in case of %, some limits are made (10%min, 90% max)
                if (param) {
                    this._top = Math.max(10,param);
                    this._top = Math.min(90,param);
                }
                else {
                    this._top = Math.max(10, this._top);
                    this._top = Math.min(90, this._top);
                }
            }
            else {
                if (param) {
                    //this._top = Math.max(10,param); // warning ! in case of 'px', we do NOT prevent the height to go larger than its container height !
                    this._top = Math.min(this._maxHeightOnTop, Math.max(this.__number, param)); // warning ! in case of 'px', we do NOT prevent the height to go larger than its container height !
                    this._top = Math.min(this._container.offsetHeight - this.__number, this._top);
                } else if (param === null) { // can force a resize
                    //this._top += 40;
                }
            }
            this._topPanel.style.height = this._top + this._options.sizeType;
            this._botPanel.style.height = 'calc(100% - ' + this._top + this._options.sizeType + ')';
            if (this._resizer) this._resizer.style.top = 'calc(' + this._top + this._options.sizeType + ' - 5px)';
        }

        var that = this;
        that._modelEvents.publish({ event: 'splitview-vertical-resize-started', data: that._top });
        if (!this._options.withtransition) {
            that._modelEvents.publish({ event: 'splitview-vertical-resized', data: that._top });
        }
        else {
            setTimeout(function () {
                that._modelEvents.publish({ event: 'splitview-vertical-resized', data: that._top });
            }, 400);
        }

        //else if (this._topVisible) { // only top is visible (with current implementation, should never happen)
        //    this._resizer.classList.add('displaynone');
        //    this._topPanel.style.height = '100%';
        //    this._botPanel.style.height = 0;
        //}
        //else if (this._botVisible) {// only bot is visible (with current implementation, should never happen)
        //    this._resizer.classList.add('displaynone');
        //    this._topPanel.style.height = 0;
        //    this._botPanel.style.height = '100%';
        //}
        //else { } // shud not happen ? no panel visible .. be SIRIUS BLACK
    };

    ENOXSplitViewVertical.prototype.destroy = function () { // would be great to have destroy/init/subscribeToEvents/initDiv/getContent shared prototype...
        // destroy DOM
        this._container = null;

        // destroy listener
        var i = 0;
        var len = this._listSubscription.length;
        for (i = 0; i < len; i++) {
            this._modelEvents.unsubscribe(this._listSubscription[i]);
        }

        // destroy remaining objects
        var keys = Object.keys(this); // will return an array of own properties
        // remove the _modelEvents from keys
        var idx = keys.indexOf('_modelEvents'); // remove all members but modelEvents.. Note that it could be removed if not-passed by parent callee...
        if (idx > -1) {
            keys.splice(idx, 1);
        }

        for (i = 0; i < keys.length; i++) {
            this[keys[i]] = undefined;
        }
    };

    ENOXSplitViewVertical.prototype.setMaxHeightOnTop = function (maxheight) {
        this._maxHeightOnTop = maxheight;
    };

    ENOXSplitViewVertical.prototype.setNumberTop = function (top) {
        this.__number = top;
    };

    return ENOXSplitViewVertical;
});
