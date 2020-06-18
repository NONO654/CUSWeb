define(
  'DS/ENOChgActionGridUX/scripts/View/ChgWelcomePanelWrapper',
  [
    'DS/ENOXWelcomePanel/js/ENOXWelcomePanel',
    'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS'
  ],
  function(
    ENOXWelcomePanel,
    APP_NLS
  ) {
    'use strict';

    var WelcomePanelWrapper = function() {};

    WelcomePanelWrapper.prototype.init = function(applicationChannel, parentContainer) {

      this._applicationChannel = applicationChannel;

      var activities = [{
        id: 'activities',
        title: APP_NLS.CHG_Activity_Title,
        actions: [{
            id: 'CA',
            text: APP_NLS.CHG_Activity_CA,
            fonticon: 'wux-ui-3ds wux-ui-3ds-2x wux-ui-3ds-change',
            className: 'action-new'
          }
          /*, {
                          id:"CO",
                          text:APP_NLS.CHG_Activity_CO,
                          fonticon: 'wux-ui-3ds wux-ui-3ds-2x wux-ui-3ds-change',
                          className: 'action-new'
                      }, {
                          id:"CR",
                          text:APP_NLS.CHG_Activity_CR,
                          fonticon: 'wux-ui-3ds wux-ui-3ds-2x wux-ui-3ds-change',
                          className: 'action-new'
                      }*/
        ]
      }];

      var welcomePanelOptions = {
        collapsed: false,
        title: 'ca',
        notifications: [],
        activities: activities,
        parentContainer: parentContainer,
        modelEvents: applicationChannel
      };
      var wp = new ENOXWelcomePanel(welcomePanelOptions);
      wp.render();

      //  this._subscribeToEvents();
    };
    return WelcomePanelWrapper;
  });
