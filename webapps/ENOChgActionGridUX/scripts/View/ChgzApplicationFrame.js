define('DS/ENOChgActionGridUX/scripts/View/ChgzApplicationFrame',
[
        'DS/CoreEvents/ModelEvents',
        'DS/Core/Core',
        'DS/ENOChgActionGridUX/scripts/Triptych/ChgTriptychWrapper',
        'DS/ENOChgActionGridUX/scripts/View/ChgApplicationTopBarWrapper',
        'DS/ENOChgActionGridUX/scripts/View/ChgWelcomePanelWrapper',
        'css!DS/UIKIT/UIKIT.css',
        'css!DS/ENOChgActionGridUX/ENOChgActionGridUX'
],

function (ModelEvents, Core, TriptychWrapper, ApplicationTopBarWrapper, WelcomePanelWrapper) {
    'use strict';

    var zApplicationFrame = function () {};

    zApplicationFrame.prototype._init = function (modelEvent,/* router, */welcomePanel, middleContent) {
        this._applicationChannel = modelEvent;
        //this._router = router;
        this._leftContent = welcomePanel;
        this._middleContent = middleContent;
        this._initDom();
    };

    zApplicationFrame.prototype._initDom = function () {

        var existzPlaneDiv = document.querySelector('#zPlaneid');
        if(existzPlaneDiv){
              existzPlaneDiv.destroy();
        }

        this._content = UWA.createElement('div',{'id': 'zPlaneid'});
        this._content.classList.add('z-panel');

      //  this._topbar = document.createElement('div');
      this._topbar = UWA.createElement('div', {
        'id': 'ztoolbar',
        'styles': {
          'display': 'none'

        }
      });
        this._topbar.classList.add('z-topbar');

        this._mainContainer = document.createElement('div');
        this._mainContainer.classList.add('z-content');
        this._content.appendChild(this._topbar);
        this._content.appendChild(this._mainContainer);
         this._pageToolBarComponent = new ApplicationTopBarWrapper();
         this._pageToolBarComponent.init(this._applicationChannel/*, this._router*/, this._topbar);

         this._triptychWrapper = new TriptychWrapper();
         this._triptychWrapper.init(this._applicationChannel, this._mainContainer);
        //main
       if (this._middleContent && this._middleContent._container) {
            this._applicationChannel.publish({ event: 'triptych-set-content', data: { side: 'middle', content: this._middleContent._container } });
       }
      //  this._subscribeEvents();

       this.__mobileBreakpoint = this._triptychWrapper._triptych.__mobileBreakpoint;

    };
    // subscribe the events to zApplicationFrame
    zApplicationFrame.prototype._subscribeEvents = function () {
        this._listSubscription = [];
        var that = this;
        that._listSubscription.push(that._applicationChannel.subscribe({ event: 'triptych-show-panel' }, function (data) {
            if (that._content.clientWidth < that.__mobileBreakpoint) {
                that._topbar.classList.add('hide');
                that._mainContainer.classList.add('full-height');
            }
        }));
        //triptych-panel-hidden
        that._listSubscription.push(that._applicationChannel.subscribe({ event: 'triptych-panel-hide-started' }, function (data) {
            if (that._content.clientWidth < that.__mobileBreakpoint) {
                that._topbar.classList.remove('hide');
                that._mainContainer.classList.remove('full-height');
            }
        }));

        that._listSubscription.push(that._applicationChannel.subscribe({ event: 'triptych-entering-mobile' }, function () {
            that._topbar.classList.remove('hide');
            that._mainContainer.classList.remove('full-height');
            that._applicationChannel.publish({ event: 'triptych-hide-panel', data: 'left' });
        }));

        that._listSubscription.push(that._applicationChannel.subscribe({ event: 'triptych-leaving-mobile' }, function () {
            that._topbar.classList.remove('hide');
            that._mainContainer.classList.remove('full-height');
            that._applicationChannel.publish({ event: 'triptych-show-panel', data: 'left' }); // cannot do that all the time (should only be done at landing page.. let's keep it commented :))
        }));

    };
    zApplicationFrame.prototype.inject = function (parentElement) {
        parentElement.appendChild(this._content);
    };

    zApplicationFrame.prototype.destroy = function () {
        this._content = null;
    };
    return zApplicationFrame;
});
