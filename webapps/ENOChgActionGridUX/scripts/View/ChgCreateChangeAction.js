define('DS/ENOChgActionGridUX/scripts/View/ChgCreateChangeAction',
  ['DS/ENOChangeActionUX/scripts/CreateCAForm',
    'DS/ENOChgServices/scripts/services/ChgDataProcess',
    'DS/ENOChangeActionUX/scripts/CAUtility',
    'DS/ENOChgServices/scripts/services/ChgDataService',
    "DS/Notifications/NotificationsManagerUXMessages",
    "DS/Notifications/NotificationsManagerViewOnScreen",
    "DS/UIKIT/Mask",
    "DS/Controls/ResponsiveTileView",
    'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS',
  'DS/ENOChgServices/scripts/services/ChgServiceGlobalVariable'],
  function (CreateCAForm,
    ChgDataProcess, CAUtility, ChgDataService
    , NotificationsManagerUXMessages, NotificationsManagerViewOnScreen, Mask,
    WUXResponsiveTileView,
     APP_NLS,ChgServiceGlobalVariable) {
    var ChgCreateChangeAction = {
      // callback to get the CA data after creation
      onCompleteCallback: function (CADetails) {
        // To Process the CA details
        var result = ChgDataProcess.processChangeActionCreateData(CADetails);
        // Getting the noda data
        var processNode = result["processData"];
        // owner trigram list
        var memberList = result["memberList"];
        ChgDataService.getUserFullName(processNode, memberList)
          .then(function (processedListWithName) {
            // Mapping the fullname against the trigram
            var processNode = ChgDataProcess.processedListWithName(processedListWithName);

            if(enoviaServerCAWidget.indexMode != "true"){
              // add newly created CA to existing CAs
              enoviaServerCAWidget.existingCAIds.push("pid:"+processNode[0].id);
            }

              // Update the new node in data grid view
              require(['DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout'], function (ChgDataGridLayout) {
                ChgDataGridLayout.refreshLayout(processNode);
              });

              var divToMask = document.getElementById("outer-ca-div");
              if (divToMask != null || divToMask != "undefined") {
                Mask.unmask(divToMask);
              }



          }, function (error) {
            return Promise.reject(error);
          });

        var infoOptions = {
          level: "info",
          title: APP_NLS.CHG_CREATE_SUCCESS,
          subtitle: ChgDataProcess.getAttribute(CADetails,"attribute_Synopsis"),
          message: CADetails.changeaction.name,
          sticky: false
        };
        // Adds the notification options.
        window.notif = NotificationsManagerUXMessages;
        NotificationsManagerViewOnScreen.setNotificationManager(window.notif);
        NotificationsManagerViewOnScreen.getFadeOutPolicy(2); //2 is fast
        if (NotificationsManagerViewOnScreen._notifScreen != null)
          NotificationsManagerViewOnScreen._notifScreen.addClassName("ca-align-center");
        NotificationsManagerUXMessages.addNotif(infoOptions);

        //TODO : Find a better fadeout
        // setTimeout(function (e) {
        //   NotificationsManagerViewOnScreen.removeLastNotificationDisplayed();
        // }, 700);
      },

      onFailureCallback: function () {
        console.log("ERROR : FAILED CREATE CA");
        var divToMask = document.getElementById("outer-ca-div");
        if (divToMask != null || divToMask != "undefined") {
          Mask.unmask(divToMask);
        }
      },
      /*
       * Method to create the Change Action with Details (By create Change Action form)
       */
      createChangeAction: function () {
        // calling the create Change Action with callback
        CreateCAForm.createCAFromActionBar(null, null, ChgCreateChangeAction.onCompleteCallback);
      },
      /*
       * Method to create the Blank Change Action ( with title only)
       */
      createBlankChangeAction: function (e, tweaker, lineEditor) {
        var name = lineEditor.value;
		if(window.__karma__ !== undefined)
	    {
			name = 'ODT_CA';
		}
        if ( name != null && name.trim() != "") {
          var divToMask = document.getElementById("outer-ca-div");
          if (divToMask != null || divToMask != "undefined") {
            Mask.mask(divToMask);
          }
          var caData = {
            "version": "v0",
            "changeaction":
            {
              "name": "",
              "revision": "-",
              "type": "type_ChangeAction",
              "description": name,
              "attributes": [
                {
                  "name": "Synopsis",
                  "value": name
                },
                {
                  "name": "Estimated Completion Date",
                  "value": ""
                },
                {
                  "name": "Severity",
                  "value": "Low"
                }
              ]
            }
          };
          CAUtility.createCA(JSON.stringify(caData),
            ChgCreateChangeAction.onCompleteCallback,
            ChgCreateChangeAction.onFailureCallback);
        }

        lineEditor.value = "";

      }
    }

    return ChgCreateChangeAction;
  });
