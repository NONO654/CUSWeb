/**
 * @module DS/ENOXModelApp/components/ApplicationTopBar/ApplicationTopBarWrapper.js
 * @description
 */

define(
  'DS/ENOChgActionGridUX/scripts/View/ChgApplicationTopBarWrapper',
  [
    'DS/ENOXPageToolBar/js/PageToolBar',
    'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS',
    'DS/ENOChgActionGridUX/scripts/Config/ChgCAAppGlobalConfig',
    'DS/ENOXBreadcrumb/js/Breadcrumb'
  ],
  function(
    PageToolBar,
    APP_NLS,
    CAAppGlobalConfig,
    Breadcrumb
  ) {
    'use strict';

    var ApplicationTopBarWrapper = function() {};

    ApplicationTopBarWrapper.prototype.init = function(applicationChannel, /* xmodelrouterparam,*/ parentContainer_param) {

      //this.xModelRouter = xmodelrouterparam;
      this._applicationChannel = applicationChannel;

      // init toolbar
      var topbarOptions = {
        withInformationButton: false,
        withWelcomePanelButton: false,
        //isWelcomePanelCollapsed: false,
        modelEvents: this._applicationChannel,
        parentContainer: parentContainer_param
      };

      //creating the page toolbar and adding the topbar options to it
      var myPageToolBar = new PageToolBar(topbarOptions);
      myPageToolBar.render().inject(parentContainer_param);

      // init breadcrumb
      var breadcrumbContainer = myPageToolBar.getBodyContent();
      var that = this;
      this._breadcrumb = new Breadcrumb({
        rootID: 'home',
        rootText: APP_NLS.CHG_Home,
        rootIcon: 'home',
        modelEvents: this._applicationChannel
      });
      //  this._breadcrumb.render().inject(breadcrumbContainer);

      //  this._subscribeToEvents();
    };

    ApplicationTopBarWrapper.prototype._subscribeToEvents = function() {
      var that = this;

      // when trying to reduce the welcome panel container (click on the little arrow in the TopToolBar)
      this._applicationChannel.subscribe({
        event: 'welcome-panel-collapse'
      }, function() {
        that._applicationChannel.publish({
          event: 'triptych-set-size',
          data: {
            size: CAAppGlobalConfig.LEFT_PANEL_SIZE_COLLAPSED,
            side: 'left'
          }
        });
        that._applicationChannel.publish({
          event: 'triptych-show-panel',
          data: 'left'
        });
      });


      // same for expand of the welcome panel
      this._applicationChannel.subscribe({
        event: 'welcome-panel-expand'
      }, function() {
        that._applicationChannel.publish({
          event: 'triptych-set-size',
          data: {
            size: CAAppGlobalConfig.LEFT_PANEL_SIZE_EXPANDED,
            side: 'left'
          }
        });
        that._applicationChannel.publish({
          event: 'triptych-show-panel',
          data: 'left'
        });
      });

      // when clicking on the 'I' of Information while it's opened
      this._applicationChannel.subscribe({
        event: 'information-panel-close'
      }, function() {
        that._applicationChannel.publish({
          event: 'triptych-hide-panel',
          data: 'right'
        });
      });

      // when clicking on the 'I' of Information while it's closed
      this._applicationChannel.subscribe({
        event: 'information-panel-open'
      }, function() {
        that._applicationChannel.publish({
          event: 'triptych-show-panel',
          data: 'right'
        });
        that._applicationChannel.publish({
          event: 'information-panel-visible',
          data: null
        });
      });

      // if something closed the right panel, update the 'I' color
      this._applicationChannel.subscribe({
        event: 'triptych-panel-hidden'
      }, function(data) {
        if (data === 'right') {
          that._applicationChannel.publish({
            event: 'information-panel-hidden',
            data: null
          });
        }
      });

      // concerning click on breadcrumb
      /*this._applicationChannel.subscribe({ event: 'breadcrumb-link-clicked' }, function (link) {
            //that._applicationChannel.publish({ event: 'triptych-hide-panel', data: 'right' });
            //that._applicationChannel.publish({ event: 'triptych-set-content', data: { side: 'right', content: null } });
            var linkid = link.linkID.replace(/-/g, '.');
            if (linkid === 'home') {
                that.xModelRouter.navigate(xModelAppGlobalConfig.ROUTE_LANDING_PAGE);
            }
            else if (linkid === xModelAppGlobalConfig.ROUTE_MODELS) {
                that.xModelRouter.navigate(xModelAppGlobalConfig.ROUTE_MODELS, { data: 'from breadcrumb' }); // should not re-trigger the 'activate'
            }
            else if (linkid === xModelAppGlobalConfig.ROUTE_DICTIONARY) {
                that.xModelRouter.navigate(xModelAppGlobalConfig.ROUTE_DICTIONARY);
            }
            else {
                var additionalData = null;
                var i = 0;
                for (i = 0; i < that._breadcrumb.collection.length; i += 1) {
                    if (that._breadcrumb.collection.at(i).id === link.linkID) {
                        additionalData = that._breadcrumb.collection.at(i).get('additionalData');
                        break;
                    }
                }
var debug = false;
                if (debug) { console.log(additionalData); }
                additionalData ? that.xModelRouter.navigate(linkid, additionalData) : that.xModelRouter.navigate(linkid);
            }
        });*/
    };

    return ApplicationTopBarWrapper;
  });
