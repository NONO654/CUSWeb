define('DS/ENOChgServices/scripts/services/ChgErrors',
  ['DS/UIKIT/Alert'],
  function(Alert) {
    var ChgErrors = {

      error: function(message) {
        this.message(message, 'error');
      },

      message: function(message, type) {

        if (this.alertCA != null) {
          this.alertCA.hide();
        }
        var autoHide = true;

        if (type == 'error')
          autoHide = false;

        this.alertCA = new Alert({
          closable: true,
          visible: true,
          autoHide: autoHide,
          hideDelay: 5000,
          className: 'wp-alert'
        }).inject(document.body, 'top');

        this.alertCA.add({
          className: type,
          message: message
        });

      },
      success: function(message) {
        this.message(message, 'success');
      },
      warn: function(message) {
        this.message(message, 'warning');
      },
    };
    return ChgErrors;
  });

define('DS/ENOChgServices/scripts/services/ChgServiceGlobalVariable',
  ['UWA/Class'],
  function(UWAClass) {
    'use strict';
  var iconMap;
  var ChgServiceGlobalVariable = UWAClass.singleton({
  getIconMap:function(){
      return this.iconMap;
  },
  setIconMap:function(iconMap){
    this.iconMap=iconMap;
  }
})

    return ChgServiceGlobalVariable;
  });

define('DS/ENOChgServices/scripts/services/ChgDataProcess',
  ['i18n!DS/ENOChgServices/assets/nls/ChgServiceNLS',
'DS/ENOChgServices/scripts/services/ChgServiceGlobalVariable'],
  function(CA_NLS,ChgServiceGlobalVariable) {
    var ChgDataProcess = {
      processCASummaryList: function(resp) {
        var result = [];
        var CAIds = [];
        var CAModelMap = {};
        var memberName = [];
        var processData = [];
        var asOwner = resp.details.owner;
        if (asOwner != null && asOwner != undefined) {
          asOwner.forEach(function(eachCA) {
            eachCA.contextUserRole = CA_NLS.ECM_CA_Team_Owner;
            CAIds.push(eachCA.id);
            memberName.push(eachCA.owner);
            CAModelMap[eachCA.id] = eachCA;
          });
        }
        var asContributor = resp.details.contributor;
        if (asContributor != null && asContributor != undefined) {
          asContributor.forEach(function(eachCA) {
            if (CAIds.indexOf(eachCA.id) == -1) {
              eachCA.contextUserRole = CA_NLS.ECM_CA_Summary_Contributor;
              CAIds.push(eachCA.id);
              memberName.push(eachCA.owner);
              CAModelMap[eachCA.id] = eachCA;
            } else {
              CAModelMap[eachCA.id].contextUserRole += ", " + CA_NLS.ECM_CA_Summary_Contributor;
            }
          });
        }
        var asReviewer = resp.details.reviewer;
        if (asReviewer != null && asReviewer != undefined) {
          asReviewer.forEach(function(eachCA) {
            if (CAIds.indexOf(eachCA.id) == -1) {
              eachCA.contextUserRole = CA_NLS.ECM_CA_Summary_Reviewer;
              CAIds.push(eachCA.id);
              memberName.push(eachCA.owner);
              CAModelMap[eachCA.id] = eachCA;
            } else {
              CAModelMap[eachCA.id].contextUserRole += ", " + CA_NLS.ECM_CA_Summary_Reviewer;
            }
          });
        }
        var asFollower = resp.details.follower;
        if (asFollower != null && asFollower != undefined) {
          asFollower.forEach(function(eachCA) {
            if (CAIds.indexOf(eachCA.id) == -1) {
              eachCA.contextUserRole = CA_NLS.ECM_CA_Summary_Follower;
              CAIds.push(eachCA.id);
              memberName.push(eachCA.owner);
              CAModelMap[eachCA.id] = eachCA;
            } else {
              CAModelMap[eachCA.id].contextUserRole += ", " + CA_NLS.ECM_CA_Summary_Follower;
            }
          });
        }
       //

       //code snippet for to seperate the newly added CAs from existing.
       if(enoviaServerCAWidget.existingCAIds===null){
         enoviaServerCAWidget.existingCAIds = CAIds;
         enoviaServerCAWidget.newlyAssignCAIds = "";
       }else if(enoviaServerCAWidget.existingCAIds==""){
         enoviaServerCAWidget.newlyAssignCAIds = enoviaServerCAWidget.existingCAIds = CAIds;
       }else if(enoviaServerCAWidget.existingCAIds!=null && enoviaServerCAWidget.existingCAIds!=null){
         enoviaServerCAWidget.newlyAssignCAIds = CAIds.filter(function(x){
           return enoviaServerCAWidget.existingCAIds.indexOf(x)==-1;
         });
         enoviaServerCAWidget.existingCAIds = CAIds;
       }
        console.log(enoviaServerCAWidget.existingCAIds);
        console.log(enoviaServerCAWidget.newlyAssignCAIds);
       //
        CAIds.forEach(function(eachID) {
          var CAObj = CAModelMap[eachID];
          var contextCAId = CAObj.id;
          contextCAId = contextCAId.split("pid:");
          contextCAId = contextCAId[1];
          var contextCAName = CAObj.name;
          var contextCAOwner = CAObj.owner;
          var state = CAObj.state;
          var stateGrade = 0;
          if (state == "In Work") {
            stateGrade = 1;
          } else if (state == "In Approval") {
            stateGrade = 2;
          } else if (state == "Approved") {
            stateGrade = 3;
          }
          state = CA_NLS.get("CHG_CA_State_" + state);
          var type = CAObj.type;
          var severity = CAObj.attributes.Severity;
          var severityGrade = 0;
          if (severity == "Medium") {
            severityGrade = 1;
          } else if (severity == "High") {
            severityGrade = 2;
          }
          severity = CA_NLS.get("CHG_CA_Severity_" + severity);
          var synopsis = CAObj.attributes.Synopsis;
          var dueDate = CAObj.attributes.EstimatedCompletionDate;
          var role = CAObj.contextUserRole;
          var hold = CAObj["Change On Hold"];
          if (hold == "True") {
            //state = state + " [" + CA_NLS.CHG_CA_State_On_Hold + "]";
          }
          var arr = CAObj.contextUserRole;
          var recent='';
          if(enoviaServerCAWidget.newlyAssignCAIds.indexOf(CAObj.id)!=-1){
             recent=  CA_NLS.CHG_CA_Recent_Value;
          }
          var obj = {
            'title': synopsis,
            'name': contextCAName,
            "maturity": state,
            "severity": severity,
            //"dueDate": dueDate,
            "responsible": contextCAOwner,
            "userRole": role,
            'id': contextCAId,
            'type': type,
            'displayType': type,
            'severityGrade': severityGrade,
            'stateGrade': stateGrade,
            'recent':recent,
            "icon": "https://vdevpril155plp.dsone.3ds.com:443/3DSpace/snresources/images/icons/large/I_Product_Thumbnail.png"
          };
          if (dueDate != "" && dueDate != null) {
            obj.dueDate = dueDate;
          }
          processData.push(obj);
        });
        result["processData"] = processData;
        result["memberList"] = memberName;
        return result;


      },
      /*
       * Method to process the List mapping with Full Name
       */
      processedListWithName: function(data) {
        var processData = data.processList;
        var userDisplayName = data.userDisplayName;
        for (var k = 0; k < processData.length; k++) {
          var caInfo = processData[k];
          var userName = caInfo.responsible;
          caInfo.responsible = userDisplayName.userInfo[userName].userDisplayName;
          caInfo.ownerId = userDisplayName.userInfo[userName].id;
          caInfo.trigram = userName;
        }
        return processData;
      },
      /*
       * Method to process the Single Change Action details
       */
      processChangeActionCreateData: function(CADetails) {
        var result = [];
        var processData = [];
        var memberName =[];
        //  getting details from service and processing
        var name = CADetails.changeaction.name;
        var id = CADetails.changeaction.id;
        if(id.substring(0,3) == "pid"){
          id=id.substring(4);
        }
        var type = CADetails.changeaction.type;
        var state = '';
        var severity = '';
        var synopsis = '';
        var hold = '';
        var owner = '';
        var synopsis = '';
        var dueDate = '';
        var role = CA_NLS.CHG_CA_Role_Owner;
        var arr = CADetails.changeaction.attributes;
        for (var i = 0; i < arr.length; i++) {
          if (arr[i]["name"] == "current") {
            state = arr[i].value;
          } else if (arr[i]["name"] == "attribute_Severity") {
            severity = arr[i].value;
          } else if (arr[i]["name"] == "attribute_Synopsis") {
            synopsis = arr[i].value;
          } else if (arr[i]["name"] == "interface[Change On Hold]") {
            hold = arr[i].value;
          } else if (arr[i]["name"] == "attribute_Originator") {
            owner = arr[i].value;
          } else if (arr[i]["name"] == "attribute_EstimatedCompletionDate") {
            dueDate = arr[i].value;
          }
        }
        var DATE_TAG_FORMAT = '%Y-%m-%d';
        if (dueDate) {
          dueDate = new UWA.Date(dueDate).strftime(DATE_TAG_FORMAT);
        } else {
          dueDate = "";
        }
        var severityGrade = 0;
        if (severity == "Medium") {
          severityGrade = 1;
        } else if (severity == "High") {
          severityGrade = 2;
        }
        var stateGrade = 0;
        if (state == "In Work") {
          stateGrade = 1;
        } else if (state == "In Approval") {
          stateGrade = 2;
        } else if (state == "Approved") {
          stateGrade = 3;
        }
		state = CA_NLS.get("CHG_CA_State_" + state);
        severity = CA_NLS.get("CHG_CA_Severity_" + severity);
        // declaring the object and mapping with value
        var obj = {
          'title': synopsis,
          'name': name,
          "maturity": state,
          "severity": severity,
          //"dueDate": dueDate,
          "responsible": owner,
          "userRole": role,
          'id': id,
          'type': type,
          'displayType': type,
          'severityGrade': severityGrade,
          'stateGrade': stateGrade,
        };
        if (dueDate != "" && dueDate != null) {
          obj.dueDate = dueDate;
        }
        processData.push(obj);
        memberName.push(owner);
        result["processData"] = processData;
        result["memberList"] = memberName;
        return result;
      },
      /*
       * Method to create the ObjectId list to send web service
      */
      makeObjList: function(dataInput) {
        var objList = [];
        var objTypeList = [];
        for (var k = 0; k < dataInput.length; k++) {
          if (k == 0) {
            var typeTemp = dataInput[k].type;
            var typeId = dataInput[k].id;
            objTypeList.push(typeTemp);
            objList.push(typeId);
          } else if (!(objTypeList.indexOf(dataInput[k].type)!==-1)) {
            var typeTemp = dataInput[k].type;
            var typeId = dataInput[k].id;
            objTypeList.push(typeTemp);
            objList.push(typeId);
          }

        }
        return objList;
      },
      /*
       * Creating the Iocn Map to store the type -> icon url in Map
      */
      createIconMap: function(response) {
        var iconMap = {};
        var keyType = "";
        var iconURL = "";
        var iconPreviewURL = "";
        if(response!=null && response.hasOwnProperty("results")){
        var result = response.results;
        for (var k = 0; k < result.length; k++) {
          var attributesList = response.results[k].attributes;
          for (var j = 0; j < attributesList.length; j++) {

            var idFieldName = attributesList[j].name;

            if (idFieldName == "ds6w:type") {
              keyType = attributesList[j].value;
            }
            if (idFieldName == "type_icon_url") {
              iconURL = attributesList[j].value;
            }
            if (idFieldName == "preview_url") {
              iconPreviewURL = attributesList[j].value;
            }

          }
          iconMap[keyType] = iconMap[keyType] || [];
          //iconMap[keyType] = iconMap[keyType] || [];
          iconMap[keyType].push(iconURL);
          iconMap[keyType].push(iconPreviewURL);

        }
      }else{
          // this is for non- index data
           keyType="Change Action";
           var iUrl="/snresources/images/icons/small/I_ECM_CA.png";
           var pURL="/snresources/images/icons/large/I_ECM_CA108x144.png";
           var iconUrl = enoviaServerCAWidget.computeUrl(iUrl);
           var iconPreviewUrl = enoviaServerCAWidget.computeUrl(pURL);
           iconURL=iconUrl;
           iconPreviewURL=iconPreviewUrl;
           iconMap[keyType] = iconMap[keyType] || [];
          // iconMap[keyType] = iconMap[keyType."iconURL"] || [];
          // iconMap[keyType."previewURL"] = iconMap[keyType."previewURL"] || [];
           iconMap[keyType].push(iconURL);
           iconMap[keyType].push(iconPreviewURL);
      }
      ChgServiceGlobalVariable.setIconMap(iconMap);

      },

      processCAListIndexed: function(response) {
        var result = response.results;
        var processData = [];
        if (result != undefined) {
          for (var k = 0; k < result.length; k++) {
            var attrCAList = result[k].attributes;
            var state = "";
            var dueDate = "";
            var owner = "";
            var changeAssignee = [];
            var changeFollower = [];
            var changeReviewer = [];
			var changeRef=[];
            var severity = "";
            var title = "";
            var name = "";
            var hold = "";
            var id = "";
            var iconURL = "";
            var privewURL = "";
            var role = "";
            var roleOwner = "";
            var count = 0;
            var responsible = "";
            var onHold="false";
			var isRef="false";
            for (var i = 0; i < attrCAList.length; i++) {
              if (attrCAList[i]["name"] == "current") {
                state = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "ds6w:what/ds6w:type") {
                type = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "resourceid") {
                id = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "type_icon_url") {
                iconURL = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "preview_url") {
                privewURL = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "ds6w:when/ds6w:ends/ds6w:dueDate") {
                dueDate = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "ds6w:who/ds6w:responsible") {
                responsible = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "owner") {
                roleOwner = attrCAList[i].value;
                var contextUser = enoviaServerCAWidget.contextUser;
                if (roleOwner == contextUser) {
                  role = "Owner";
                }
              } else if (attrCAList[i]["name"] == "ECM_CHANGE_ON_HOLD") {
                hold = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "ds6w:why/ds6w:fulfills/ds6w:severity") {
                severity = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "ds6w:label") {
                title = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "ds6w:identifier") {
                name = attrCAList[i].value;
              } else if (attrCAList[i]["name"] == "ECM_CHANGE_ASSIGNEE_USERNAME_FULLNAME") {
                changeAssignee.push(attrCAList[i].value);
              } else if (attrCAList[i]["name"] == "ECM_CHANGE_FOLLOWER_USERNAME_FULLNAME") {
                changeFollower.push(attrCAList[i].value);
              } else if (attrCAList[i]["name"] == "ECM_CHANGE_REVIEWER_USERNAME_FULLNAME") {
                changeReviewer.push(attrCAList[i].value);
              }else if (attrCAList[i]["name"] == "ECM_CHANGE_REFERENTIAL") {
                changeRef.push(attrCAList[i].value);
                isRef="attach";
              }
            }

            var DATE_TAG_FORMAT = '%Y-%m-%d';
            if (dueDate) {
              dueDate = new UWA.Date(dueDate).strftime(DATE_TAG_FORMAT);
            } else {
              dueDate = "";
            }
            var severityGrade = 0;
            if (severity == "Medium") {
              severityGrade = 1;
            } else if (severity == "High") {
              severityGrade = 2;
            }
            var stateGrade = 0;
            if (state == "In Work") {
              stateGrade = 1;
            } else if (state == "In Approval") {
              stateGrade = 2;
            } else if (state == "Approved") {
              stateGrade = 3;
            }

            state = CA_NLS.get("CHG_CA_State_" + state);
            if (hold == "TRUE") {
              //state = state + " [" + CA_NLS.CHG_CA_State_On_Hold + "]";
              onHold="true";
            }
            severity = CA_NLS.get("CHG_CA_Severity_" + severity);
            var recent = '';
            /* if(enoviaServerCAWidget.newlyAssignCAIds.indexOf(CAObj.id)!=-1){
                recent=  CA_NLS.CHG_CA_Recent_Value;
             }*/
            var obj = {
              'title': title,
              'name': name,
              "maturity": state,
              "severity": severity,
              //"dueDate": dueDate,
              "responsible": responsible,
              "userRole": role,
              'id': id,
              'type': type,
              'displayType': type,
              'severityGrade': severityGrade,
              'stateGrade': stateGrade,
              'recent': recent,
              "iconURL": iconURL,
              "previewURL": privewURL,
              "changeReviewer": changeReviewer,
              "changeFollower": changeFollower,
              "changeAssignee": changeAssignee,
              "owner": roleOwner,
              "onHold":onHold,
			  "referential":isRef
            };
            if (dueDate != "" && dueDate != null) {
              obj.dueDate = dueDate;
            }
            processData.push(obj);
          }
        }
        //  console.log(processData);
        return processData;
      },
    createMemberList: function(data) {
      var that = this;
      var memberList = [];
      var outcomeAssignee = [];
      var outcomeFollower = [];
      var outcomeReviewer = [];
      for (var i = 0; i < data.length; i++) {
        var chgAssigneList = data[i].changeAssignee;
        if (chgAssigneList.length > 0) {
          outcomeAssignee = that.createListSenderNames(chgAssigneList);
        }
        var chgFollowerList = data[i].changeFollower;
        if (chgFollowerList.length > 0) {
          outcomeFollower = that.createListSenderNames(chgFollowerList);
        }
        var chgReviewerList = data[i].changeReviewer;
        if (chgReviewerList.length > 0) {
          var outcomeReviewer = that.createListSenderNames(chgReviewerList);
        }
      }
      memberList = [].concat(outcomeAssignee, outcomeFollower, outcomeReviewer);
      return memberList;

    },
    createListSenderNames: function(senderList) {
      var result = [];
      for (var i = 0; i < senderList.length; i++) {
        var tempName = senderList[i];
        result.push(tempName);
      }
      return result;
    },

      /**
       * 
       * @param {*} CADetails : 
       * @param {*} attribute_name : eg "attribute_Synopsis"
       * @returns value : of null if attribute_name not found
       */
      getAttribute:function(CADetails,attribute_name){
        if(CADetails.changeaction != "undefined"){
          if(CADetails.changeaction.attributes){
            // CADetails.changeaction.attributes.forEach(
            //   function(item){
            //     if(item.name == attribute_name){
            //       return item.value;
            //     }
            //   }
            // )
            var arr = CADetails.changeaction.attributes;
            for(var i=0 ; i<arr.length ; i++){
              if(arr[i].name==attribute_name){
                return arr[i].value;
              }
            }
          }
        }
        return null ;
      }
    };

    return ChgDataProcess;
  });

define('DS/ENOChgServices/scripts/services/ChgInfraService',
  [
    'DS/Foundation/WidgetUwaUtils',
    'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
    'DS/ENOChgServices/scripts/services/ChgErrors',
    'DS/WAFData/WAFData',
    'i18n!DS/ENOChgServices/assets/nls/ChgServiceNLS',
    'DS/UIKIT/Mask',
    'DS/PlatformAPI/PlatformAPI',
    'DS/ENOChangeActionUX/scripts/CAWidgetConfiguration'
  ],
  function(WidgetUwaUtils, i3DXCompassPlatformServices, ChgErrors, WAFData, CA_NLS, Mask, PlatformAPI, CAWidgetConfiguration) {
    var ChgInfraService = {
      URL: null,
      _SCPreferred: null,
      _theListSC: null,
      _theListSC_NLS: null,
      _SCPreferredDB: null,
      init: function() {
        WidgetUwaUtils.setupEnoviaServer();
        window.enoviaServer.widgetName = "ChangeActionManagement";
        window.enoviaServer.widgetId = window.widget.id;
        window.enoviaServer.tenant = widget.getValue("x3dPlatformId") ? widget.getValue("x3dPlatformId") : 'OnPremise';
        window.enoviaServerCAWidget = {
          serviceName: "3DSpace",
          baseURL: "",
          swymURL: "",
          InterCom: UWA.Utils.InterCom,
          compassSocket: null,
          prefIntercomServer: null,
          compassSocketName: "",
          prefSocketName: "",
          arrOid: [],
          timezone: new Date().getTimezoneOffset(),
          wsCallTimeout: 180000,
          mySecurityContext: "",
          proxy: window.UWA.Data.proxies["passport"] ? "passport" : "ajax",
          myRole: "",
          contextUser: "",
          isNative: false,
          isPoweredBy: this.IsPoweredBy(),
          is3DSpace: false,
          fromIDCard: false,
          referentialsSearchType: "",
          contextSearchType: "",
          proposedSearchType: "",
          datamodel: "new", //todo why needed?
          project_space: "",
          organization: "",
          mySkeleton: null,
          PropWidget: null,
          NamePref: "Title",
          ViewPref: "Tile",
          UXPref: "New",
          reviewerType: {
            typeOfReviewer: '',
            labelSelected: false
          },
          frameWorkName: "ENOChangeActionUX",
          TaggerInNative: false,
          CHG_OPEN_FROM_NATIVE: "false",
          CHG_TRANSFER_REALIZED: "false",
          CHG_FLOWDOWN: "false",
          CHG_CA_PROCESS_STEPS: "false",
          CHG_NATIVE_TAGGER: "true",
          CHG_CHANGE_MATURITY: "false",
          CHG_CHANGE_MATURITY_HEADER: "true",
          CHG_DOWNLOAD_REFERENTIAL: "false",
          CHG_CHANGE_ASSESSMENT: "false",
          CHG_TRANSFER_OWNERSHIP: "false",
          CHG_CHANGE_SUMMARY_GRID: "false",
          indexMode:"true",
          isChangeAvailable: false,
          supportedOperations: "None,NewVersion,NewMinorVersion,NewEvolution,Create",
          supportedActivities: "Modify,Release,Obsolete",
          supportedOperationMap: new Object(),
          get3DSpaceURL: function() {
            return this.baseURL;
          },
          getSwymURL: function() {
            return this.swymURL;
          },
          computeUrl: function(relativeURL) {
            return this.get3DSpaceURL() + relativeURL;
          },
          computeSwymUrl: function(relativeURL) {
            return this.getSwymURL() + relativeURL;
          },
          getSecurityContext: function() {
            return this.mySecurityContext;
          },
          getRole: function() {
            return this.myRole;
          },
          collabspace: "",
          tenant: widget.getValue("x3dPlatformId") ? widget.getValue("x3dPlatformId") : 'OnPremise',
          tenantnls: "", //to do calculate this
          existingCAIds: null,
          newlyAssignCAIds: null
        };
      },
      setInfraValue: function(callback) {
        var randomName = "wdg_" + new Date().getTime();
		// To-do need to move this file in Chgservice
        CAWidgetConfiguration.setupIntercomConnections.call(this, widget, enoviaServerCAWidget, randomName);
        //widget.body.empty();
        var user = PlatformAPI.getUser();
        if (user)
        enoviaServerCAWidget.contextUser = user.login;
      //  Mask.mask(widget.body);
        ChgInfraService.populate3DSpaceURL()
          .then(function(success) {
              ChgInfraService.populateSecurityContext()
                .then(function(securityContextDetails) {
                  ChgInfraService.getSearchTypes().
                  then(function(searchTypeDetails) {
                    ChgInfraService.getExpressionValue()
                      .then(function(success1) {
                        ChgInfraService.PopulatePreferences().then(function(success) {
                         widget.body.empty();
                            if (enoviaServerCAWidget.CHG_CHANGE_SUMMARY_GRID == 'true') {
                              var ViewPref = widget.getPreference("ViewMode").value;
                              enoviaServerCAWidget.ViewPref = ViewPref;
                            }
                                      var CApid = null;
                                      var contentX3D = (widget.getValue('X3DContentId')) ? JSON.parse(widget.getValue('X3DContentId')) : null;
                                      var TransientCAPid = widget.getValue('TransientCAPid');
                                      var originatingCAPid = widget.getValue('originatingPid');
                                      var objName = widget.getValue('objName');
                                      var originatingCAName = widget.getValue('originatingcaName');
                                      var fromFlowDown = widget.getValue('status');
                                      var nameTitlePrefForFlowdown = widget.getValue('nameTitlePref');
                                      if (contentX3D !== null && widget.getValue('lastRootNodeID') === undefined &&
                                                                                !widget.getValue('clearInPreview')) {
                                                                                var contextX3DData = contentX3D.data;
                                                                                if (contextX3DData !== null && contextX3DData.items.length > 0) {
                                                                                    var lastitem = contextX3DData.items[contextX3DData.items.length - 1];
                                                                                    CApid = lastitem.objectId;
                                                                                    if (UWA.is(CApid)) {
                                                                                        ChgInfraService.IsChangeAction(CApid)
                                                                                        .then(function (success) {
                                                                                            if (success.isChangeAction === "TRUE") {
                                                                                                var contextCAID = "pid:" + CApid;
                                                                                                var options = {
                                                                                                    transientCAPid: contextCAID,
                                                                                                    originatingCAPid: originatingCAPid,
                                                                                                    originatingCAName: originatingCAName,
                                                                                                    objNametoFilterforFlowDown: objName,
                                                                                                    isFromFlowDown: fromFlowDown,
                                                                                                    nameTitlePref: nameTitlePrefForFlowdown,
                                                                                                }
                                                                                                callback("IDcard",options);
                                                                                                //ChangeAction.getCAIDCard(options);
                                                                                            } else {
                                                                                                if (enoviaServerCAWidget.mySecurityContext != "")
                                                                                                  //  ChangeAction.loadContent();
                                                                                                  callback("LoadSummary");
                                                                                            }
                                                                                        },
                                                                                         function (error) {
                                                                                             console.log("widget initilization failed");
                                                                                             return Promise.reject(error);
                                                                                         });
                                                                                    }
                                                                                }
                                                                            }else if (TransientCAPid) {
                                            if (UWA.is(TransientCAPid)) {
                                                ChgInfraService.IsChangeAction(TransientCAPid)
                                                .then(function (success) {
                                                    if (success.isChangeAction === "TRUE") {
                                                        var contextCAID = "pid:" + TransientCAPid;
                                                        var options = {
                                                            transientCAPid: contextCAID,
                                                            originatingCAPid: originatingCAPid,
                                                            originatingCAName: originatingCAName,
                                                            objNametoFilterforFlowDown: objName,
                                                            isFromFlowDown: fromFlowDown,
                                                            nameTitlePref: nameTitlePrefForFlowdown,
                                                        }
                                                          callback("IDcard",options);
                                                      //  ChangeAction.getCAIDCard(options);
                                                    } else {
                                                        if (enoviaServerCAWidget.mySecurityContext != "")
                                                          callback("LoadSummary");
                                                          //  CASkeleton.loadContent();
                                                    }
                                                });
                                            }
                                        }else {
                                            if (enoviaServerCAWidget.mySecurityContext != "") {
                                                //CASkeleton.loadContent();
                                                callback("LoadSummary");
                                            }
                                        }
                          //Mask.unmask(widget.body);
                        //  callback("infra set successfully");

                          },
                          function(error) {
                            console.log("PopulatePreferences fail");
                            return Promise.reject(error);
                          });
                        /*  Mask.unmask(widget.body);
                          callback("infra set successfully");*/
                        //PlatformAPI.publish("InfraInitialize");

                      }, function(error) {
                        console.log("getExpressionValue fail");
                        return Promise.reject(error);
                      });
                  }, function(error) {
                    console.log("searchTypeDetails fail");
                    return Promise.reject(error);
                  });
                }, function(error) {
                  console.log("populateSecurityContext fail");
                  return Promise.reject(error);
                });
            },
            function(error) {
              console.log("populate3DSpaceURL fail");
              return Promise.reject(error);
            });

      },
      IsPoweredBy: function() {
        var params = {};
        var parser = document.createElement('a');
        parser.href = location.href;
        var query = parser.search.substring(1);
        var vars = query.split('&');
        for (var i = 0; i < vars.length; i++) {
          var pair = vars[i].split('=');
          params[pair[0]] = decodeURIComponent(pair[1]);
        }
        if (params.widgetDomain && (params.widgetDomain.search('catiav5') >= 0 || params.widgetDomain.search('solidworks') >= 0))
          return true;
        else
          return false;
      },
      populate3DSpaceURL: function() {
        var returnedPromise = new Promise(function(resolve, reject) {
          i3DXCompassPlatformServices.getPlatformServices({
            onComplete: function(data) {
              for (var count = 0; count < data.length; count++) {
                if (enoviaServerCAWidget.tenant == data[count]["platformId"]) {
                  enoviaServerCAWidget.baseURL = data[count]["3DSpace"];
                  enoviaServerCAWidget.federatedURL = data[count]["3DSearch"];
                  enoviaServerCAWidget.swymURL = data[count]["3DSwym"];
                  var swymURL= enoviaServerCAWidget.swymURL;
                  if(swymURL!=undefined){
                    enoviaServerCAWidget.isSwymInstalled=true;
                  }else{
                    enoviaServerCAWidget.isSwymInstalled=false;
                  }

                }
              }
              resolve();
            },
            onFailure: reject
          });
        });
        return returnedPromise;
      },
      populateSecurityContext: function() {
        var that = this;
        var returnedPromise = new Promise(function(resolve, reject) {
          var url = "/resources/pno/person/getsecuritycontext";
          var postdata = "";

          var onCompleteCallBack = function(securityContextDetails) {
            response = securityContextDetails.SecurityContext;
            if (!response || response == null) ChgErrors.error(CA_NLS.ECM_CA_Use_Preferences);
            else {

              if (securityContextDetails != null && securityContextDetails != "" && securityContextDetails.hasOwnProperty("SecurityContext")) {
                var prefix = "";
                if (securityContextDetails.SecurityContext.indexOf("ctx::") != 0) //ctx:: is mandatory. In some serveur, this ctx doesn't exist
                  prefix = 'ctx::';
                response = prefix + securityContextDetails.SecurityContext;
              }
              console.log("Setting security Context: " + response);
              enoviaServerCAWidget.mySecurityContext = response;

              response = response.replace("ctx::", "");

              if (UWA.is(window.enoviaServer))
                window.enoviaServer.context = response;

              enoviaServerCAWidget.myRole = response.substring(0, response.indexOf("."));
              window.enoviaServer.myRole = response.substring(0, response.indexOf("."));

              enoviaServerCAWidget.collabspace = response.substring(response.lastIndexOf('.') + 1, response.length);
              resolve(securityContextDetails);
            }
          };

          var _CurrentSC = widget.getValue('SC');
          if ((_CurrentSC != null) && (_CurrentSC != undefined) && (_CurrentSC != "")) {
            var response = "ctx::" + _CurrentSC;
            enoviaServerCAWidget.mySecurityContext = response;

            response = response.replace("ctx::", "");
            enoviaServerCAWidget.myRole = response.substring(0, response.indexOf("."));
            window.enoviaServer.myRole = response.substring(0, response.indexOf("."));
            enoviaServerCAWidget.collabspace = response.substring(response.lastIndexOf('.') + 1, response.length);
            resolve(response);
          } else
            that.makeWSCall(url, 'GET', 'enovia', 'application/json', postdata, onCompleteCallBack, reject, true);
        });
        return returnedPromise;
      },
      populateRoles: function() {
        var returnedPromise = new Promise(function(resolve, reject) {
          i3DXCompassPlatformServices.getGrantedRoles(function(userGrantedRoles) {
            var arrOfTechnicalProducts = ["CAP", "CHG", "COR", "DAR", "FCD", "FME", "FRA", "FTM", "GLS", "PDA", "PDE", "PDM", "PPE", "QUC", "SPM", "TRM", "UWE", "UXG", "ENO_ECM_TP"];

            userGrantedRoles.forEach(function(role) {
              /*if ((((role.id === "CHG") || (role.id === "ENO_ECM_TP") || (role.id === "PDM") ||
                  (role.id === "PDA") || (role.id === "PDE") || (role.id === "PPE") || ) && role.platforms.indexOf(enoviaServerCAWidget.tenant) >= 0) || (role.id === "InternalDS")) {
                  enoviaServerCAWidget.isChangeAvailable = true;
              }*/

              if (((arrOfTechnicalProducts.indexOf(role.id) >= 0) && role.platforms.indexOf(enoviaServerCAWidget.tenant) >= 0) ||
                (role.id === "InternalDS")) {
                enoviaServerCAWidget.isChangeAvailable = true;
              }
            });
            resolve(true);
          });
        });
        return returnedPromise;
      },
      PopulatePreferences: function() {
        var returnedPromise = new Promise(function(resolve, reject) {
          var isTenant = widget.getValue("x3dPlatformId") == "" ? false : widget.getValue("x3dPlatformId") != "OnPremise" ? true : false;
          var promisesArr = [];
          //var promiseNamePreferences = ChgInfraService.PopulateNamePreferences();
          var promiseViewPreferences = ChgInfraService.PopulateViewPreferences();
          var promisecollabspacesDetails = ChgInfraService.PopulateSCPreferences();
          if (isTenant) {
            var promiseTenantPreferences = ChgInfraService.populateTenantPreferences();
            //promisesArr.push(promisecollabspacesDetails, promiseTenantPreferences, promiseNamePreferences, promiseViewPreferences);
			promisesArr.push(promisecollabspacesDetails, promiseTenantPreferences, promiseViewPreferences);
          }
		  else{
			//promisesArr.push(promisecollabspacesDetails, promiseNamePreferences, promiseViewPreferences);
			promisesArr.push(promisecollabspacesDetails, promiseViewPreferences);
		  }

          Promise.all(promisesArr)
            .then(function(resp) {
                //we add adding Security context preference in this method
                ChgInfraService.ComputeList(resp[0].collabspacesDetails);
                if (isTenant) {
                    widget.addPreference(resp[1].TenantPreference);
                    //widget.addPreference(resp[2].NamePreference);
                    if (enoviaServerCAWidget.CHG_CHANGE_SUMMARY_GRID == 'true') {
                        widget.addPreference(resp[2].ViewPreference);
                    }
                }
                else {
                    //widget.addPreference(resp[1].NamePreference);
                    if (enoviaServerCAWidget.CHG_CHANGE_SUMMARY_GRID == 'true') {
                        widget.addPreference(resp[1].ViewPreference);
                    }
                }
                resolve("success");
            });
        });

        return returnedPromise;
      },
	  /*
      PopulateNamePreferences: function() {

        var NlsPreference = CA_NLS.ECM_CA_Pref_Name_Title_Label;
        var NlsPrefName = CA_NLS.ECM_CA_Pref_Name_Label;
        var NlsPrefTitle = CA_NLS.ECM_CA_Pref_Title_Label;
        var structure = {
          name: "NameOrTitle",
          type: "list",
          label: NlsPreference,
          options: []
        };
        var returnedPromise = new Promise(function(resolve, reject) {
          structure.options.push({
            value: "Name",
            label: NlsPrefName
          });
          structure.options.push({
            value: "Title",
            label: NlsPrefTitle
          });
          var response = {};
          response["NamePreference"] = structure;
          resolve(response);

        });
        return returnedPromise;
      },
	  */
      PopulateViewPreferences: function() {

        var NlsPreference = CA_NLS.CHG_CA_Pref_View_Label;
        var NlsPrefGrid = CA_NLS.CHG_CA_Pref_Grid_Label;
        var NlsPrefTile = CA_NLS.CHG_CA_Pref_Tile_Label;
        var structure = {
          name: "ViewMode",
          type: "list",
          label: NlsPreference,
          options: []
        };
        var returnedPromise = new Promise(function(resolve, reject) {
          structure.options.push({
            value: "Grid",
            label: NlsPrefGrid
          });
          structure.options.push({
            value: "Tile",
            label: NlsPrefTile
          });
          var response = {};
          response["ViewPreference"] = structure;
          resolve(response);

        });
        return returnedPromise;
      },

      PopulateSCPreferences: function() {
        ChgInfraService._SCPreferredDB = "";
        ChgInfraService._SCPreferred = "";
        var returnedPromise = new Promise(function(resolve, reject) {
          var pathWS = "/resources/modeler/pno/person?current=true";
          pathWS += "&select=collabspaces&select=preferredcredentials";
          var vDataObj = "";
          var onCompleteCallback = function(collabspacesDetails) {
            var response = {};
            response['collabspacesDetails'] = collabspacesDetails;
            resolve(response);
          };
          ChgInfraService.makeWSCall(pathWS, 'GET', 'enovia', 'application/json', vDataObj, onCompleteCallback, reject);

        });
        return returnedPromise;

      },
      getExpressionValue: function() {

        var returnedPromise = new Promise(function(resolve, reject) {
          var url = "/resources/v2/e6w/service/ExpresssionSearch/CHG*";
          var postdata = "";

          var onCompleteCallBack = function(success) {
            var expressionKeys = ['CHG_DEPENDENCY_LEGACY', 'CHG_NATIVE_TAGGER', 'CHG_TRANSFER_REALIZED', 'CHG_FLOWDOWN', 'CHG_REALIZED_INSTANCE_NAME', 'CHG_OPEN_FROM_NATIVE', 'CHG_CA_PROCESS_STEPS', 'CHG_CHANGE_MATURITY_HEADER', 'CHG_CHANGE_MATURITY', 'CHG_DOWNLOAD_REFERENTIAL', 'CHG_CHANGE_ASSESSMENT', 'CHG_CHANGE_SUMMARY_GRID'];
            if (success && success.data) {
              success.data.forEach(function(dataElem) {
                if (dataElem.dataelements) {
                  var keys = Object.keys(dataElem.dataelements);
                  for (var key in keys) {
                    if (expressionKeys.indexOf(keys[key]) >= 0) {
                      if (dataElem.dataelements)
                        enoviaServerCAWidget[keys[key]] = dataElem.dataelements[keys[key]];
                    }
                  }
                }
              });
            }
            resolve();
          };

          ChgInfraService.makeWSCall(url, 'GET', 'enovia', 'application/json', postdata, onCompleteCallBack, reject, true);
        });

        return returnedPromise;
      },
      onPnORetrieve: function(isOK) {
        if (isOK) {
          var NlsPreference = CA_NLS.ECM_CA_SC_CREDENTIALS;
          var SCPreference = ChgInfraService.getSCPreference(NlsPreference);
          widget.addPreference(SCPreference);
          var _PreviousSC = widget.getValue('SC');
          var _CurrentSC = ChgInfraService.getSCPreferred(_PreviousSC);
          widget.setValue('SC', _PreviousSC);
        }
      },
      onRefresh: function() {
        var _CurrentSC = widget.getValue('SC');
        prefix = 'ctx::';
        response = prefix + _CurrentSC;
        console.log("Setting security Context: " + response);
        enoviaServerCAWidget.mySecurityContext = response;

        response = response.replace("ctx::", "");
        enoviaServerCAWidget.myRole = response.substring(0, response.indexOf("."));

        enoviaServerCAWidget.collabspace = response.substring(response.lastIndexOf('.') + 1, response.length);
      },
      checkValiditySC: function(compare) {
        var find = false;
        var i = 0;
        if (ChgInfraService._theListSC) {
          while ((!find) && (i < ChgInfraService._theListSC.length)) {
            if (compare === ChgInfraService._theListSC[i]) {
              find = true;
            }
            i++;
          }
        }

        return find;
      },

      ComputeList: function(elt) {
        var NoIssue = false;
        var ListSC = [];
        var ListSC_NLS = [];
        var CREDENTIALS_SEPARATOR = ' \u25CF ';
        var TheCBPreferred, TheRolePreferred, TheOrgPreferred;
        var ThePreferredJson = elt.preferredcredentials;
        if (ThePreferredJson && ThePreferredJson.collabspace &&
          ThePreferredJson.role &&
          ThePreferredJson.organization) {
          var TheCBPreferredJson = ThePreferredJson.collabspace;
          var TheRolePreferredJson = ThePreferredJson.role;
          var TheOrgPreferredJson = ThePreferredJson.organization;
          TheCBPreferred = TheCBPreferredJson.name;
          TheRolePreferred = TheRolePreferredJson.name;
          TheOrgPreferred = TheOrgPreferredJson.name;

          ChgInfraService._SCPreferredDB = TheRolePreferred + "." + TheOrgPreferred + "." + TheCBPreferred;
        }

        var TheCollabSpacesArray = elt.collabspaces;
        if (TheCollabSpacesArray && TheCollabSpacesArray.length > 0) {
            //check if multiorgaization
            var bMultiOrgnizationPresent = false;
            var currOrgName = undefined;
            for (var i = 0; i < TheCollabSpacesArray.length; i++) {
                var TheCurrentCSJson = TheCollabSpacesArray[i];
                var TheCurrentCS = TheCurrentCSJson.name;
                var TheCouples = TheCurrentCSJson.couples;
                for (var j = 0; j < TheCouples.length; j++) {
                    var TheCurrentCoupleJson = TheCouples[j];
                    var TheOrganization = TheCurrentCoupleJson.organization;
                    var TheRole = TheCurrentCoupleJson.role;
                    var TheCurrentOrg = TheOrganization.name;
                    var TheCurrentRole = TheRole.name;
                    var TheCurrentRoleNLS = TheRole.nls;

                    var SCCurrent = TheCurrentRole + "." + TheCurrentOrg + "." + TheCurrentCS;
                    var SCCurrent_NLS = bMultiOrgnizationPresent ? TheCurrentCS + CREDENTIALS_SEPARATOR + TheCurrentOrg + CREDENTIALS_SEPARATOR + TheCurrentRoleNLS : TheCurrentCS + CREDENTIALS_SEPARATOR + TheCurrentRoleNLS;

                    ListSC.push(SCCurrent);
                    ListSC_NLS.push(SCCurrent_NLS);
                    if (ChgInfraService._SCPreferredDB != "") {
                        // at least one must be the preferred SC
                        if ((TheOrgPreferred === TheCurrentOrg) &&
                            (TheRolePreferred === TheCurrentRole) &&
                            (TheCBPreferred === TheCurrentCS)) {
                            NoIssue = true;
                        }
                    } else NoIssue = true;
                }
            }
            ChgInfraService._theListSC = ListSC;
            ChgInfraService._theListSC_NLS = ListSC_NLS;
        }
        ChgInfraService.onPnORetrieve(NoIssue);

      },

      getSCPreference: function(NlsForPreference) {

        var structure = {
          name: "SC",
          type: "list",
          label: NlsForPreference,
          options: []
        };

        if (ChgInfraService._theListSC) {
          for (var i = 0; i < ChgInfraService._theListSC.length; i++) {
            // {value,label} both mandatory
            structure.options.push({
              value: ChgInfraService._theListSC[i],
              label: ChgInfraService._theListSC_NLS[i]
            });
          }
        }
        return structure;
      },

      getSCPreferred: function(theCurrentSC) {
        var returnValue;
        //The value from the db  is the first choice
        if (ChgInfraService._SCPreferredDB != "") {
          returnValue = ChgInfraService._SCPreferredDB;
        } else { // no preferred SC in DB
          // is the previous current SC still valid ?
          if (ChgInfraService.checkValiditySC(theCurrentSC)) {
            returnValue = theCurrentSC;
          } else {
            returnValue = undefined;
          }
        }
        return returnValue;
      },
      populateTenantPreferences: function() {

        var Nls3DexperiencePlatformPreference = CA_NLS.ECM_CA_Pref_3DEXPERIENCE_Platform;
        var structure = {
          name: "x3dPlatformId",
          type: "list",
          label: Nls3DexperiencePlatformPreference,
          options: []
        };
        var returnedPromise = new Promise(function(resolve, reject) {
          i3DXCompassPlatformServices.getPlatformServices({
            onComplete: function(data) {
              data.forEach(function(platform) {
                var platformId = platform["platformId"];
                structure.options.push({
                  value: platformId,
                  label: platformId
                });
                var x3dPlatformId = widget.getValue("x3dPlatformId");
                if (x3dPlatformId === platformId) {
                  ChgInfraService.update3DspaceURL(platform);
                }
              });
              var response = {};
              response["TenantPreference"] = structure;
              resolve(response);
            },
            onFailure: function() {
              console.log("Error getting Tenant details");
            }
          });

        });

        return returnedPromise;

      },
      update3DspaceURL: function(platform) {

        enoviaServerCAWidget.baseURL = platform["3DSpace"];
        enoviaServerCAWidget.federatedURL = platform["3DSearch"];
        //we are using this tenant every where in application
        enoviaServerCAWidget.tenant = platform["platformId"];
      },
      /*
       * Method to set the drag content of object
      */
      readyDragContent: function(dragEvent, dndInfos) {

        var items = [];
        var objectToDrop = {
          envId: widget.getValue("x3dPlatformId") ? widget.getValue("x3dPlatformId") : 'OnPremise',
          serviceId: "3DSpace",
          contextId: "",
          objectId: dndInfos.nodeModel.options.grid.id,
          objectType: dndInfos.nodeModel.options.grid.type,
          displayName: dndInfos.nodeModel.options.grid.name,
          displayType: dndInfos.nodeModel.options.grid.displayType,
        };
        items.push(objectToDrop);
        var jsonResponse = {
          protocol: "3DXContent",
          version: "1.1",
          source: "X3DCSMA_AP",
          widgetId: widget.id,
          data: {
            items: items
          }
        };
        dragEvent.dataTransfer.setData("Text", JSON.stringify(jsonResponse));
        dragEvent.dataTransfer.effectAllowed = "all";
      },
      /*
       * Method to set Title of CA Widget
      */
      updateWidgetTitle: function() {

        var title = CA_NLS.CHG_CA_Widget_Title;
        // To-do when row select we need to update the title with CA name /title

        return widget.setTitle(title);
      },
      /*
       * Method to set the search types allowed as Context ( Add context in CA)
      */
      getSearchTypes: function() {
        var that = this;
        var returnedPromise = new Promise(function(resolve, reject) {
          var url = "/resources/modeler/change/typeeallowed";
          var postdata = "";

          var onCompleteCallback = function(resultObject) {
            enoviaServerCAWidget.referentialsSearchType = that.getResultStringFromJSONArrayObj(resultObject.referentials);
            enoviaServerCAWidget.contextSearchType = that.getResultStringFromJSONArrayObj(resultObject.context);
            enoviaServerCAWidget.proposedSearchType = that.getResultStringFromJSONArrayObj(resultObject.proposed);
            resolve(resultObject);
          };

          that.makeWSCall(url, 'GET', 'enovia', 'application/json', postdata, onCompleteCallback, reject, true);
        });

        return returnedPromise;
      },
      getResultStringFromJSONArrayObj: function(JSONArrayObj) {
        var returnStringValue = "";

        if (JSONArrayObj != undefined && JSONArrayObj != "" && JSONArrayObj.length > 0) {
          for (var i = 0; i < JSONArrayObj.length; i++) {
            if (returnStringValue == "") {
              returnStringValue = JSONArrayObj[i];
            } else {
              returnStringValue = returnStringValue + "," + JSONArrayObj[i];
            }
          }
        }
        return returnStringValue;
      },
     IsChangeAction: function (pid) {
                     var that = this;
                    var returnedPromise = new Promise(function (resolve, reject) {
                    var url = "/resources/modeler/change/changeaction/pid:" + pid;
                        var postdata = "";

                        var onCompleteCallBack = function (Data) {
                            var successMsg = {
                                isChangeAction: "TRUE"
                            };
                            resolve(successMsg);
                        };

                        var onFailureCallBack = function () {
                            var successMsg = {
                                isChangeAction: "FALSE"
                            };
                            resolve(successMsg);
                        }

                        that.makeWSCall(url, 'GET', 'enovia', 'application/json', postdata, onCompleteCallBack, onFailureCallBack, true);
                    });

                    return returnedPromise;
                },
		/*
       * Method to get the avatar details for person
       *@input - User fullname (Gaurav Chauhan)
       *@output options.avatarStr (GC) , options.avatarColor(rgb(245,100,163))
      */
      getAvatarDetails: function(name) {
        var options = {};
        var backgroundColors = [
          [7, 139, 250],
          [249, 87, 83],
          [111, 188, 75],
          [158, 132, 106],
          [170, 75, 178],
          [26, 153, 123],
          [245, 100, 163],
          [255, 138, 46],
        ]
        initials = name.match(/\b\w/g);
        var firstLetter = initials[0].toUpperCase();
        var lastLetter = initials[initials.length - 1].toUpperCase();

        var avatarStr = (firstLetter + lastLetter);

        var i = Math.ceil((firstLetter.charCodeAt(0) + lastLetter.charCodeAt(0)) % backgroundColors.length);
        var avatarColor = "rgb(" + backgroundColors[i][0] + "," + backgroundColors[i][1] + "," + backgroundColors[i][2] + ")";

        options.name = name;
        options.avatarStr = avatarStr;
        options.avatarColor = avatarColor;

        return options;
      },

      /**
       * This is generic method to make REST WS Calls
       * @param URL : Resource URL ( Server Details No Needed)
       * @param httpMethod: HTPP Method to call
       * @param authentication: Type of Passport Target in authentication header
       * @param ContentType: Type of content ( Mostly application/ds-json)
       * @param ReqBody: Request Body ( For POST methods)
       * @param onCompleteCallback: Call Back method to call when request is successful to process the result
       * @param failCallback: Call Back method to call in case of WS request failure
       * @param IsCallAsync: A boolean value to indicate if the call needs to be Asynchronus.
       * @author SE3
       */
      makeWSCall: function(URL, httpMethod, authentication, ContentType, ReqBody, userCallbackOnComplete, userCallbackOnFailure, options) {

        //var url = enoviaServerCAWidget.computeUrl(URL);

        var options = options || null;

        var url = "";
        if (options != null && options.isfederated != undefined && options.isfederated == true)
          url = enoviaServerCAWidget.federatedURL + URL;
        else
          url = enoviaServerCAWidget.computeUrl(URL);

        var timestamp = new Date().getTime();
        if (url.indexOf("?") == -1) {
          url = url + "?tenant=" + enoviaServerCAWidget.tenant + "&timestamp=" + timestamp;
        } else {
          url = url + "&tenant=" + enoviaServerCAWidget.tenant + "&timestamp=" + timestamp;
        }

        var securityContext = enoviaServerCAWidget.getSecurityContext();
        // Encoding for special character for company name IE specific
        securityContext = encodeURIComponent(securityContext);

        userCallbackOnComplete = userCallbackOnComplete || function() {};
        userCallbackOnFailure = userCallbackOnFailure || function() {};

        // For NLS translation
        //if(lang == undefined || lang == 'undefined'){
        var lang = widget.getValue('lang');
        if (widget.lang)
          lang = widget.lang;
        //}

        var queryobject = {};
        queryobject.method = httpMethod;
        queryobject.timeout = enoviaServerCAWidget.wsCallTimeout;

        if (options == null || options.isSwymUrl == undefined || options.isSwymUrl == false ){
        queryobject.type = 'json';
        }

        if (enoviaServerCAWidget.isNative) {
          if (securityContext) {
            queryobject.headers = {
              Accept: 'application/json',
              'Content-Type': ContentType,
              'SecurityContext': securityContext,
              'Accept-Language': lang
            };

          } else { //will be called only once for security context
            queryobject.headers = {
              Accept: 'application/json',
              'Content-Type': ContentType,
              'Accept-Language': lang
            };
          }
        } else {
          if (authentication) {
            queryobject.auth = {
              passport_target: authentication
            };
          }
          queryobject.proxy = enoviaServerCAWidget.proxy;
          if (securityContext) {

            queryobject.headers = {
              Accept: 'application/json',
              'Content-Type': ContentType,
              'SecurityContext': securityContext,
              'Accept-Language': lang
            };

          } else { //will be called only once for security context
            queryobject.headers = {
              Accept: 'application/json',
              'Content-Type': ContentType,
              'Accept-Language': lang
            };
          }

        }

        if (ReqBody)
          queryobject.data = ReqBody;

        queryobject.onComplete = function(data) {
          //console.log("Success calling url: " + url);
          //console.log("Success data: " + JSON.stringify(data));
          userCallbackOnComplete(data);
        };
        queryobject.onFailure = function(errDetailds, errData) {
          console.log("Error in calling url: " + url);
          console.log("Additional Details:: httpMethod: " + httpMethod + " authentication: " + authentication + " securityContext: " + securityContext + " ContentType: " + ContentType);
          console.log("Error Detail: " + errDetailds);
          console.log("Error Data: " + JSON.stringify(errData));

          if (errData && errData.errorMessage) ChgErrors.error(errData.errorMessage);
          else if (errDetailds && errDetailds.message) ChgErrors.error(errDetailds.message);
          else ChgErrors.error("Something went wrong, please check logs for more details");

          userCallbackOnFailure(errDetailds, errData);
          //CASpinner.endWait(widget.body);
        };

        queryobject.onTimeout = function() {
          console.log("Timedout for url: " + url);
          ChgErrors.error("Webservice Timedout, please refresh and try again.");
          //CASpinner.endWait(widget.body);
        }

        WAFData.authenticatedRequest(url, queryobject);
      }

    };

    return ChgInfraService;
  });

define('DS/ENOChgServices/scripts/services/ChgDataService',
  [
    'DS/Foundation/WidgetUwaUtils',
    'DS/ENOChgServices/scripts/services/ChgInfraService'
  ],
  function(WidgetUwaUtils, ChgInfraService) {
    var ChgDataService = {
      /*
      * Method to get the CA summary list
      */
      getCASummary: function() {

        var returnedPromise = new Promise(function(resolve, reject) {
          var url = "/resources/modeler/change/changeactions?contributor=1&reviewer=1&follower=1&states=Prepare%7CInWork%7CInApproval%7CApproved";

          var postdata = "";

          var onCompleteCallback = function(response) {
            resolve(response);
          };

          ChgInfraService.makeWSCall(url, 'GET', 'enovia', 'application/json', postdata, onCompleteCallback, reject, false);
        });

        return returnedPromise;
      },
      /*
      * Method to get the Full Name
      */
      getUserFullName: function(processList, userName) {
        var returnedPromise = new Promise(function(resolve, reject) {
          var dName = "";
          var dataToSend = "";
          if (Array.isArray(userName)) {
            for (var i = 0; i < userName.length; i++) {
            if (dataToSend != "") {
                  if (-1 === dataToSend.indexOf(userName[i])) dataToSend = dataToSend + "%7C" + userName[i];
              } else {
                  dataToSend = userName[i];
              }
            }
          } else {
            dataToSend = userName;
          }
          var onCompleteCallback = function(CADetails) {
            var response = {};
            response['userDisplayName'] = CADetails;
            response['processList'] = processList;
            resolve(response);
          };

          var url = "/resources/modeler/change/userdisplayname";
          var securityContext = enoviaServerCAWidget.getSecurityContext();
          ChgInfraService.makeWSCall(url, 'GET', 'enovia', 'application/json', "userNames=" + dataToSend, onCompleteCallback, null, false);

        });
        return returnedPromise;
      },
      /*
       * Method to get the icon url and returning the map with type and icon url
       */
      getTypeIcon: function(processedCAListWithFullName, objList) {
        var returnedPromise = new Promise(function(resolve, reject) {
          var failure = function(response) {
            reject(response);
          };
          var url = "/cvservlet/fetch/v2";
          var jsonData = {
            "physicalid": objList,
            "label": "test",
            "select_predicate": ["ds6w:type"]
          };
          var postdata = JSON.stringify(jsonData);
          var success = function(iconDetails) {
            var response = {};
            response['processedCAListWithFullName'] = processedCAListWithFullName;
            response['iconDetails'] = iconDetails;
            resolve(response);
          };
          if (objList.length > 0) {
            ChgInfraService.makeWSCall(url, 'POST', 'enovia', 'application/json', postdata, success, failure, true);
          } else {
            var response = {};
            response['processedCAListWithFullName'] = processedCAListWithFullName;
            response['iconDetails'] = [];
            resolve(response);
          }
          //  ChgInfraService.makeWSCall(url, 'POST', 'enovia', 'application/json', postdata, success, failure, true);
        });
        return returnedPromise;
      },
      getCAFDData: function(refine) {

        var returnedPromise = new Promise(function(resolve, reject) {

          var failure = function(response) {
            reject(response);
          };
          var success = function(response) {
            console.log(" ****************   "+response);
            resolve(response);
          };
        var url = "/search?xrequestedwith=xmlhttprequest";
        var loginUser = enoviaServerCAWidget.contextUser;
        var inputjson = {
          "with_indexing_date": true,
          "with_nls": false,
          "label": "gn1_Test",
          "locale": "en",
          "select_predicate": ["ECM_CHANGE_ON_HOLD","ECM_CHANGE_ASSIGNEE_USERNAME","ECM_CHANGE_REVIEWER_USERNAME","ECM_CHANGE_FOLLOWER_USERNAME","ECM_CHANGE_REFERENTIAL","ECM_CHANGE_REVIEWER_RT_USERNAME","ECM_CHANGE_ASSIGNEE_USERNAME_FULLNAME","ECM_CHANGE_REVIEWER_USERNAME_FULLNAME","ECM_CHANGE_FOLLOWER_USERNAME_FULLNAME","owner", "current", "ds6w:label", "ds6w:type", "ds6w:description", "ds6w:identifier", "ds6w:responsible", "ds6w:lastModifiedBy", "ds6wg:marketing_Name"],
          "select_file": ["icon", "thumbnail_2d"],
          "query": "(flattenedtaxonomies:\"types/Change Action\" AND NOT [ds6w:status]:\"Cancelled.Cancelled\" AND NOT [ds6w:status]:\"Change Action.Complete\" AND ( owner:" + loginUser + " OR [ECM_CHANGE_ASSIGNEE_USERNAME]:" + loginUser + "  OR [ECM_CHANGE_REVIEWER_USERNAME]:"+ loginUser +" OR [ECM_CHANGE_FOLLOWER_USERNAME]:" + loginUser + " OR [ECM_CHANGE_REVIEWER_RT_USERNAME]:" + loginUser+"))",
          "nresults": 1000,
          "start": "0",
          "source": [],
          "tenant": enoviaServerCAWidget.tenant
        }
        //6Wtagger Refinement
        if(refine){
          inputjson.refine = {};
          inputjson.refine = refine.allfilters;
        }
        var inputjson = JSON.stringify(inputjson);
        var failure = function() {}
        var options = {
          isfederated: true
        }
        ChgInfraService.makeWSCall(url, "POST", "enovia", 'application/json', inputjson, success, failure, options);
        });
          return returnedPromise;
      }

    };

    return ChgDataService;
  });

