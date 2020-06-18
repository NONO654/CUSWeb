
/**
* Component to handle 2 resizable Views handling animations/hide/show/resize/
*/
define('DS/ENOXSplitView/js/ENOXSplitView', [
    'DS/CoreEvents/ModelEvents',
    'DS/Handlebars/Handlebars',
    'DS/ResizeSensor/js/ResizeSensor',
    'text!DS/ENOXSplitView/html/ENOXSplitView.html',
    'css!DS/ENOXSplitView/css/ENOXSplitView.css',
    'css!DS/UIKIT/UIKIT.css'
],

function (
        ModelEvents,
        Handlebars,
        ResizeSensor,
        html_ENOXSplitView,
        _css_ENOXSplitView,
        _css_uikit
    ) {
    'use strict';

    // resizing is done in percentages, the 2 views always represent 100% width

    var MIN_OPENED_SIZE = 20;
    var MOBILE_BREAKPOINT = 550;
    var debug = true;

    /* Fetching the panel template through Handlebars */
    var panelTemplate = Handlebars.compile(html_ENOXSplitView);

    var ENOXSplitView = function () {
        this._options = {};
    };

    ENOXSplitView.prototype.init = function (options) {
        this._options.withtransition = options && (options.withtransition === true || options.withtransition === false) ? options.withtransition : true; // whether the user wants transition in open/close/changeSize panels
        this._options.withoverflowhidden = options && (options.withoverflowhidden === true || options.withoverflowhidden === false) ? options.withoverflowhidden : false; // with or without overflow
        this._options.withborder = options && options.withborder !== undefined ? options.withborder : true; // for having a border in between the two panels
        this._modelEvents = options && options.modelEvents ? options.modelEvents : new ModelEvents(); // used in local if not passed in param (to avoid "useless" IF statements)

        this._leftWidth = options && options.params && options.params.leftWidth ? options.params.leftWidth : 50; // by default, 50% for each panel
        this._leftWidth = Math.max(30, this._leftWidth); // min-ed to 20%
        this._leftWidth = Math.min(70, this._leftWidth); // max-ed to 80%
        this._leftVisible = options && options.params && options.params.leftVisible !== undefined ? options.params.leftVisible : true; // left is visible by default
        this._rightVisible = options && options.params && options.params.rightVisible !== undefined ? options.params.rightVisible : false; // right is not visible by default

        this._options.rightMaximizer = options && options.rightMaximizer !== undefined ? options.rightMaximizer : true; // right has maximizer by default (little corner icon)
        this._options.leftMaximizer = options && options.leftMaximizer !== undefined ? options.leftMaximizer : false; // left has no maximizer by default (litttle corner icon)

        this._options.resizable = options && options.resizable !== undefined ? options.resizable : true; // whether both panels are resizable
        this._options.mobileOptim = options && options.mobileOptim !== undefined ? options.mobileOptim : false; // false by default not to impact others..

        if (!this._leftVisible && !this._rightVisible) {
            this._leftVisible = true; // stupid initialization
        }

        this._subscribeToEvents(); // initialization of subscription
        this._initDivs(); // initialization of DOM elements

    };

    ENOXSplitView.prototype._initDivs = function () {
        this._container = document.createElement('div'); // the main container element
        var container = panelTemplate(this._options); // see .html template
        this._container.innerHTML = container;
        this._container = this._container.firstChild;

        this._leftPanel = this._container.querySelector('.left-container');
        this._rightPanel = this._container.querySelector('.right-container');
        this._leftPanel2 = this._container.querySelector('.left-content');
        this._rightPanel2 = this._container.querySelector('.right-content');
        this._resizer = this._container.querySelector('.split-view-resizer');
        if (!this._options.resizable) {
            this._resizer.classList.add('displaynone');
        }
        if (!this._rightVisible) {
            this._rightPanel.classList.remove('with-left-border');
        }
        this._leftMaximizer = this._container.querySelector('.left-maximizer');
        this._rightMaximizer = this._container.querySelector('.right-maximizer');

        this._resize(); // call a first resize to set size properly
        this._initMaximizers();
        this._initResizer();
        this._initMobile();
    };

    ENOXSplitView.prototype._initMobile = function () {
        if (!this._options.mobileOptim) {
            return; // do nothing if the mobile optimization is not activated
        }
        this._previousLeftVisible = this._leftVisible;
        this._previousRightVisible = this._rightVisible;
        //this._switchViewAccess = this._container.querySelector('.switch-view-access');
        this._leftRadioButton = this._container.querySelector('input[type="radio"]:nth-child(4)');
        this._rightRadioButton = this._container.querySelector('input[type="radio"]:nth-child(5)');
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-split-view-leaving-mobile' }, this._leaveMobile.bind(this)));
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-split-view-entering-mobile' }, this._enterMobile.bind(this)));

        var that = this;
        this._leftRadioButton.onclick = function () {
            that._showLeft();
            that._hideRight();
        };
        this._rightRadioButton.onclick = function () {
            that._showRight();
            that._hideLeft();
        };
    };

    ENOXSplitView.prototype._leaveMobile = function () {
        this._currentMode = 'large';
        this._container.classList.remove('mobile');
        this._leftRadioButton.style.display = 'none';
        this._rightRadioButton.style.display = 'none';
        if (this._previousLeftVisible) {
            this._showLeft();
        }
        if (this._previousRightVisible) {
            this._showRight();
        }
    };

    ENOXSplitView.prototype._enterMobile = function () {
        this._currentMode = 'small';
        this._container.classList.add('mobile');
        this._previousLeftVisible = this._leftVisible;
        this._previousRightVisible = this._rightVisible;
        //this._switchViewAccess.style.display = ''; // show again the buttons for switching view
        this._leftRadioButton.style.display = '';
        this._rightRadioButton.style.display = '';
        if (this._leftVisible) { // priority on left panel
            this._leftRadioButton.click();
        } else { // at least one panel is visible for sure..no need to check whether right is visible
            this._rightRadioButton.click();
        }
    };


    ENOXSplitView.prototype.attachResizeSensor = function () {
        this._currentMode = 'large';
        if (!this._options.mobileOptim) {
            return; // do nothing if the mobile optimization is not activated
        }
        if (this._container.offsetWidth > MOBILE_BREAKPOINT) {
            this._currentMode = 'large';
            this._leaveMobile();
        } else {
            this._currentMode = 'small';
            this._enterMobile();
        }
        if (debug) { console.log('current size screen = ' + this._currentMode); }

        // subscribe to the container to know if we are in mobile size or not.
        var that = this;
        this._resizeSensor = new ResizeSensor(this._container, function (e) {
            if (that._container.offsetWidth > MOBILE_BREAKPOINT && that._currentMode === 'small') {
                that._currentMode = 'large';
                that._modelEvents.publish({ event: 'enox-split-view-leaving-mobile' });
            } else if (that._container.offsetWidth < MOBILE_BREAKPOINT && that._currentMode === 'large') {
                that._currentMode = 'small';
                that._modelEvents.publish({ event: 'enox-split-view-entering-mobile' });
            }
        });

    };

    ENOXSplitView.prototype._initMaximizers = function () {
        var that = this;

        if (that._leftMaximizer) {
            that._leftMaximizer.onclick = function () {
                //if (!that._container.querySelector('.left-container').classList.contains('maximized')) {
                if (!that._leftPanel.classList.contains('maximized')) {
                    that._modelEvents.publish({ event: 'splitview-maximize-panel', data: 'left' });
                }
                else {
                    that._modelEvents.publish({ event: 'splitview-restore-panel' });
                }
            };
        }

        if (that._rightMaximizer) {
            that._rightMaximizer.onclick = function () {
                //if (!that._container.querySelector('.right-container').classList.contains('maximized')) {
                if (!that._rightPanel.classList.contains('maximized')) {
                    that._modelEvents.publish({ event: 'splitview-maximize-panel', data: 'right' });
                }
                else {
                    that._modelEvents.publish({ event: 'splitview-restore-panel' });
                }
            };
        }

        this._modelEvents.subscribe({ event: 'splitview-maximized-panel-started' }, function () {
            if (that._leftMaximizer) {
                that._leftMaximizer.classList.remove('fonticon-resize-full'); // reset
                that._leftMaximizer.classList.remove('fonticon-resize-small'); // reset
                that._leftMaximizer.classList.add('fonticon-resize-small'); // re-set properly
            }
            if (that._rightMaximizer) {
                that._rightMaximizer.classList.remove('fonticon-resize-full'); // reset
                that._rightMaximizer.classList.remove('fonticon-resize-small'); // reset
                that._rightMaximizer.classList.add('fonticon-resize-small'); // re-set properly
            }
        });

        this._modelEvents.subscribe({ event: 'splitview-restored-panel' }, function () {
            if (that._leftMaximizer) {
                that._leftMaximizer.classList.remove('fonticon-resize-full'); // reset
                that._leftMaximizer.classList.remove('fonticon-resize-small'); // reset
                that._leftMaximizer.classList.add('fonticon-resize-full'); // re-set properly
            }
            if (that._rightMaximizer) {
                that._rightMaximizer.classList.remove('fonticon-resize-full'); // reset
                that._rightMaximizer.classList.remove('fonticon-resize-small'); // reset
                that._rightMaximizer.classList.add('fonticon-resize-full'); // re-set properly
            }
        });
    };

    ENOXSplitView.prototype.getLeft = function () {
        if (!this._options.leftMaximizer) {
            return this._leftPanel;
        }
        else if (this._leftPanel2) {
            return this._leftPanel2;
            //return this._container.querySelector('.left-content');
        }
    };
    ENOXSplitView.prototype.getRight = function () {
        if (!this._options.rightMaximizer) {
            return this._rightPanel;
        }
        else if (this._rightPanel2) {
            return this._rightPanel2;
            //return this._container.querySelector('.right-content');
        }
    };
    ENOXSplitView.prototype.getContent = function () {
        return this._container; // dunno who would use that..
    };
    ENOXSplitView.prototype._showRight = function () {
        this._rightVisible = true;
        if (this._options.mobileOptim && this._currentMode === 'small') {
            this._rightRadioButton.checked = true;
            this._hideLeft();
        }
        this._resize();
    };
    ENOXSplitView.prototype._hideRight = function () {
        if (this._leftVisible === false) { // cannot hide the panel when only one visible
            return;
        }
        this._rightVisible = false;
        this._resize();
    };
    ENOXSplitView.prototype._showLeft = function () {
        this._leftVisible = true;
        if (this._options.mobileOptim && this._currentMode === 'small') {
            this._leftRadioButton.checked = true;
            this._hideRight();
        }
        this._resize();
    };
    ENOXSplitView.prototype._hideLeft = function () {
        if (this._rightVisible === false) { // cannot hide the panel when only one visible
            return;
        }
        this._leftVisible = false;
        this._resize();
    };
    ENOXSplitView.prototype._hideSide = function (side) {
        if (this._options.withborder) {
            this._rightPanel.classList.remove('with-left-border');
        }
        if (side === 'left'){
            this._hideLeft();
        }
        else if (side === 'right'){
            this._hideRight();
        }
    };
    ENOXSplitView.prototype._showSide = function (side) {
        if (this._options.withborder) {
            this._rightPanel.classList.add('with-left-border');
            if (!this._options.resizable) {
                this._rightPanel.classList.remove('with-left-border');
            }
        }

        if (side === 'left'){
            this._showLeft();
        }
        else if (side === 'right'){
            this._showRight();
        }
    };
    ENOXSplitView.prototype._toggleSide = function (side) { // toggle the visibility of a side
        if (side === 'left') {
            if (this._leftVisible) {
                this._hideLeft();
            }
            else {
                this._showLeft();
            }
        }
        else if (side === 'right') {
            if (this._rightVisible) {
                this._hideRight();
            }
            else {
                this._showRight();
            }
        }
    };

    ENOXSplitView.prototype.inject = function (container) { // append the component wherever need be
        container.appendChild(this._container);
    };

    ENOXSplitView.prototype._subscribeToEvents = function () {
        var that = this;
        this._listSubscription = [];
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-toggle-panel' }, function (side) {
            that._toggleSide(side);
        }));
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-show-panel' }, function (side) {
            that._showSide(side);
        }));
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-hide-panel' }, function (side) {
            that._hideSide(side);
        }));
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-maximize-panel' }, function (side) {
            that._maximizeView(side);
        }));
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-restore-panel' }, function () {
            that._restoreView();
        }));

        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-set-content-panel' }, function (sideAndContent) {
            if (sideAndContent.side === 'left') {
                that.getLeft().textContent = '';
                that.getLeft().appendChild(sideAndContent.content);
            }
            else if (sideAndContent.side === 'right') {
                that.getRight().textContent = '';
                that.getRight().appendChild(sideAndContent.content);
            }
        }));

        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-set-size-panel' }, function (sideAndSize) {
            if (sideAndSize.side === 'left') {
                that._resize(sideAndSize.size);
            }
            else if (sideAndSize.side === 'right') {
                that._resize(100 - sideAndSize.size);
            }
        }));
    };

    ENOXSplitView.prototype._initResizer = function () {
        if (debug) console.log('init resizer');
        var that = this;

        // internal functions
        var stopanimation = function () { // prevent animation when resizing manually on mobile/desktop using the resize-handler
            that._leftPanel.classList.remove('withtransition');
            that._rightPanel.classList.remove('withtransition');
        };
        var startanimation = function () { // restart animations
            if (that._options.withtransition) {
                that._leftPanel.classList.add('withtransition');
                that._rightPanel.classList.add('withtransition');
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
        var initialLeft = null;
        var totalX = null;
        var beginX = null;
        var finalX = null;
        var resizing = false;
        var initResize = function (e) {
            totalX = that._container.offsetWidth;
            stopanimation();
            initialLeft = that._leftWidth;
            beginX = e.clientX ? e.clientX : e.touches[0].clientX;
            if (debug) console.log('beginX : ' + beginX);
            if (debug) console.log('totalX : ' + totalX);
            resizing = true;
            // resizingRight = false;
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
            var currentX = e.clientX ? e.clientX : e.touches[0].clientX;
            if (resizing) { // secure test
                //that._leftWidth = Math.max(MIN_OPENED_SIZE, initialLeft + (currentX - beginX));
                if (debug) console.log('currentX : ' + currentX);
                
                that._leftWidth = Math.max(MIN_OPENED_SIZE, initialLeft + (currentX - beginX) * 100 / totalX);
                that._leftWidth = Math.min(80, that._leftWidth);
                that._resize();
            }
        };
        var stopResize = function (e) {
            startanimation();
             if (debug) console.log('stop resize');
            resizing = false;
            initialLeft = that._leftWidth;
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

    ENOXSplitView.prototype._resize = function (param) {
        this._leftPanel.classList.remove('maximized');
        this._rightPanel.classList.remove('maximized');
        if (this._leftVisible && this._rightVisible) {
            if (this._leftMaximizer) { this._leftMaximizer.classList.remove('displaynone'); }
            if (this._rightMaximizer) { this._rightMaximizer.classList.remove('displaynone'); }
            if (param) {
                this._leftWidth = param;
            }

            this._leftWidth = Math.max(this._leftWidth, 30);
            this._leftWidth = Math.min(this._leftWidth, 70);

            this._leftPanel.style.width = this._leftWidth + '%';
            this._rightPanel.style.width = 100 - this._leftWidth + '%';
            this._rightPanel.style.left = this._leftWidth + '%';
            this._resizer.style.left = 'calc(' + this._leftWidth + '% - 5px)';
            this._resizer.classList.remove('displaynone');
        }
        else if (this._leftVisible) { // only left is visible
            this._resizer.classList.add('displaynone');
            if (this._leftMaximizer) {this._leftMaximizer.classList.add('displaynone'); }
            if (this._rightMaximizer) { this._rightMaximizer.classList.add('displaynone'); }
            this._leftPanel.style.width = '100%';
            this._leftPanel.style.left = 0;
            this._rightPanel.style.width = 0;
            this._rightPanel.style.left = '100%';
        }
        else if (this._rightVisible) {// only right is visible
            this._resizer.classList.add('displaynone');
            if (this._leftMaximizer) { this._leftMaximizer.classList.add('displaynone'); }
            if (this._rightMaximizer) { this._rightMaximizer.classList.add('displaynone'); }
            this._rightPanel.style.width = '100%';
            this._rightPanel.style.left = 0;
            this._leftPanel.style.width = 0;
        }
        //else { } // dafuk ? no panel visible .. be SIRIUS BLACK

        if (!this._options.resizable) {
            this._resizer.classList.add('displaynone'); // reset properly the resizer
        }
        if (!this._options.withtransition) {
            this._modelEvents.publish({ event: 'splitview-size-changed', data: this._leftWidth });
        }
        else {
            var that = this;
            setTimeout(function () {
                that._modelEvents.publish({ event: 'splitview-size-changed', data: that._leftWidth });
            }, 400);
        }
    };

    ENOXSplitView.prototype._maximizeView = function (side) { // is that really useful to keep both visible & one on top of the other ? - can do with show/hide
        if (side === 'left' && this._leftVisible) {
            this._leftPanel.classList.add('last-maximized');
            this._rightPanel.classList.remove('last-maximized');
            this._leftPanel.classList.add('maximized');
            this._leftPanel.style.width = '100%';
            this._leftPanel.style.left = 0;
        }
        else if (side === 'right' && this._rightVisible) {
            this._leftPanel.classList.remove('last-maximized');
            this._rightPanel.classList.add('last-maximized');
            this._rightPanel.classList.add('maximized');
            this._rightPanel.style.width = '100%';
            this._rightPanel.style.left = 0;
        }
        this._modelEvents.publish({ event: 'splitview-maximized-panel-started' });
        if (!this._options.withtransition) {
            this._modelEvents.publish({ event: 'splitview-maximized-panel'});
        }
        else {
            var that = this;
            setTimeout(function () {
                that._modelEvents.publish({ event: 'splitview-maximized-panel'});
            }, 400);
        }
        //this._modelEvents.publish({ event: 'splitview-maximized-panel' });
    };

    ENOXSplitView.prototype._restoreView = function () { // is that really useful to keep both visible & one on top of the other ? - can do with show/hide
        this._resize();
        this._modelEvents.publish({ event: 'splitview-restored-panel' });
    };

    ENOXSplitView.prototype.destroy = function () { // would be great to have destroy/init/subscribeToEvents/initDiv/getContent shared prototype...
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


    return ENOXSplitView;
});
