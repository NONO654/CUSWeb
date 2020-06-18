/*
 * @module 'DS/ENOChgActionGridUX/scripts/Model/ChangeDataGridModel'
 */
define('DS/ENOChgActionGridUX/scripts/Model/ChgChangeDataGridModel',
  [
    'UWA/Class/Model',
    'DS/TreeModel/TreeDocument',
    'DS/TreeModel/TreeNodeModel',
    'DS/TreeModel/DataModelSet',
    'DS/ENOChgServices/scripts/services/ChgServiceGlobalVariable',
    'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS',
    'DS/ENOChgServices/scripts/services/ChgInfraService'
  ],
  function(
    Model,
    TreeDocument,
    TreeNodeModel,
    DataModelSet,
    ChgServiceGlobalVariable,
    APP_NLS,
    ChgInfraService
  ) {
    'use strict';

    var ChgChangeDataGridModel = Model.extend({

      init: function() {

      },
      /*
      * Method to create the tree document for data grid view
      */
      createTreeDocument: function() {
        var dataModelSet = new DataModelSet();
        // that.treeDocument
        var treeDocument = new TreeDocument({
          dataModelSet: dataModelSet
        });

        return treeDocument;
      },
      /*
      * Method to load the data inside data grid view
      */
      loadData: function(treeDocument, data) {
        var dataModelSet = new DataModelSet();
        treeDocument.prepareUpdate();
        //  var caIcon = { iconName: "change", fontIconFamily: WUXManagedFontIcons.Font3DS, fontIconSize: "2x"};
         // Need to move on FONT icon or image URL from service
           var iconMap= ChgServiceGlobalVariable.getIconMap();
           for (var i = 0; i < data.length; i++) {
            // var type=data[i].type;
             var iUrl=iconMap[data[i].type][0];
             var ithumbnail =iconMap[data[i].type][1];
			       var dueDate = "-";
             if(data[i].dueDate != null && data[i].dueDate != undefined){
               var DATE_TAG_FORMAT = '%Y-%m-%d';
               dueDate = new UWA.Date(data[i].dueDate).strftime(DATE_TAG_FORMAT);
             }
			      var subLabel = data[i].name+" | "+data[i].responsible;
            var desc = data[i].maturity+" | "+dueDate;
            var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE+": "+data[i].title+"\n"+
            APP_NLS.CHG_TOOLTIP_NAME+": "+data[i].name+"\n"+
            APP_NLS.CHG_TOOLTIP_SEVERITY+": "+data[i].severity+"\n"+
            APP_NLS.CHG_TOOLTIP_OWNER+": "+data[i].responsible+"\n"+
            APP_NLS.CHG_TOOLTIP_MATURITY+": "+data[i].maturity+"\n"+
            APP_NLS.CHG_TOOLTIP_DUEDATE+": "+dueDate;

            var sevClass = "sevLow wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-low";
            var statusbarIcons = ["level-low"];
            var statusbarIconsTooltips = ["Low"];

            if (data[i].severityGrade == 1) {
              sevClass = "sevMed wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-medium";
              statusbarIcons = ["level-medium"];
              statusbarIconsTooltips = ["Medium"];
            } else if (data[i].severityGrade == 2) {
              sevClass = "sevHigh wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-high";
              statusbarIcons = ["level-high"];
              statusbarIconsTooltips = ["High"];
            }

            //name
            var nameDiv = new UWA.Element("div", {});
            var name = UWA.createElement('span', {
                     html: data[i].name
                });
            name.inject(nameDiv);
            data[i].ca_name = nameDiv.outerHTML;

            //severity
            var sevDiv = new UWA.Element("div", {});
            var sevContainer = new UWA.Element("div", {
              class:'gridIconContainer'
            });
            var sevIcon = UWA.createElement('div', {
                class: sevClass
            });
            sevIcon.inject(sevContainer);
            var sev = UWA.createElement('span', {
                     html: data[i].severity
                });
            sevContainer.inject(sevDiv);
            sev.inject(sevDiv);

            data[i].sev = sevDiv.outerHTML;

            // responsible
            var ownerIconURL = "/api/user/getpicture/login/"+data[i].trigram+"/format/normal";
            var ownerIconUrl = enoviaServerCAWidget.computeSwymUrl(ownerIconURL);
          //  var defaultPersonUrl="/snresources/images/icons/small/I_ENOVIA_RscPerson.png";
            var responsible = new UWA.Element("div", {});
            var owner = new UWA.Element("div", {
              class:'assignee'
            });
            var ownerIcon = "";
            if(enoviaServerCAWidget.isSwymInstalled){
              ownerIcon = UWA.createElement('img', {
                  class: "userIcon",
                  src: ownerIconUrl
              });
            } else {
              //  ownerIconUrl=enoviaServerCAWidget.computeUrl(defaultPersonUrl);
              var iconDetails = ChgInfraService.getAvatarDetails(data[i].responsible);
              ownerIcon = UWA.createElement('div', {
                    html: iconDetails.avatarStr,
                    class: "avatarIcon"
                });
              ownerIcon.style.setProperty("background",iconDetails.avatarColor);
            }
            ownerIcon.inject(owner);
            var ownerName = UWA.createElement('span', {
                    'class': 'userName',
                     html: data[i].responsible
                });
             owner.inject(responsible);
             ownerName.inject(responsible);

           data[i].user = responsible.outerHTML;

      /*       if(data[i].severity == "Low"){
               statusbarIcons = ["pause"];
               statusbarIconsTooltips = ["Hold"];
             } else if(data[i].severity == "Medium"){
               statusbarIcons = ["pause","thumbs-down"];
               statusbarIconsTooltips = ["Hold","Reject"];
             } else if(data[i].severity == "High"){
               statusbarIcons = ["pause","thumbs-down","attach"];
               statusbarIconsTooltips = ["Hold","Reject","Referential"];
             }*/

             var oNode = TreeNodeModel.createTreeNodeDataModel(dataModelSet, {
               label: data[i].title,
               subLabel : subLabel,
               description : desc,
               grid: data[i],
               icons:[iUrl],
               thumbnail:[ithumbnail],
               activeFlag: false,
               customTooltip: customTooltip,
               statusbarIcons: statusbarIcons,
               statusbarIconsTooltips: statusbarIconsTooltips
               //emptyStatusbarVisibleFlag: true
             });
             /*var badge = {
                         bottomRight:"bell-add"
                       };
             if(data[i].recent=="Yes"){
                 oNode.options.activeFlag = true; //oNode.setBadges(badge);
              }else{
                oNode.options.activeFlag = false;
              }*/
          treeDocument.addChild(oNode);
        }
        treeDocument.pushUpdate();
      },
      loadDataIndexed: function(treeDocument, data) {

        var dataModelSet = new DataModelSet();
        treeDocument.prepareUpdate();
        for (var i = 0; i < data.length; i++) {
          var iUrl = data[i].iconURL; //iconMap[data[i].type][0];
          var ithumbnail = data[i].previewURL; //iconMap[data[i].type][1];

          var dueDate = "-";
          if (data[i].dueDate != null && data[i].dueDate != undefined) {
            var DATE_TAG_FORMAT = '%Y-%m-%d';
            dueDate = new UWA.Date(data[i].dueDate).strftime(DATE_TAG_FORMAT);
          }
          var subLabel = data[i].name + " | " + data[i].responsible;
          var desc = data[i].maturity + " | " + dueDate;
          var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE + ": " + data[i].title + "\n" +
            APP_NLS.CHG_TOOLTIP_NAME + ": " + data[i].name + "\n" +
            APP_NLS.CHG_TOOLTIP_SEVERITY + ": " + data[i].severity + "\n" +
            APP_NLS.CHG_TOOLTIP_OWNER + ": " + data[i].responsible + "\n" +
            APP_NLS.CHG_TOOLTIP_MATURITY + ": " + data[i].maturity + "\n" +
            APP_NLS.CHG_TOOLTIP_DUEDATE + ": " + dueDate;

            var sevClass = "sevLow wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-low";
             var statusbarIcons = ["level-low"];
             var statusbarIconsTooltips = ["Low"];

             if (data[i].severityGrade == 1) {
               sevClass = "sevMed wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-medium";
               statusbarIcons = ["level-medium"];
               statusbarIconsTooltips = ["Medium"];
             } else if (data[i].severityGrade == 2) {
               sevClass = "sevHigh wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-high";
               statusbarIcons = ["level-high"];
               statusbarIconsTooltips = ["High"];
             }

             //name
             var nameDiv = new UWA.Element("div", {});
             var name = UWA.createElement('span', {
                      html: data[i].name
                 });
             name.inject(nameDiv);

             if(data[i].onHold == "true"){
               var holdIconContainer = new UWA.Element("div", {
                 class:'gridIconContainer',
                 title: 'Hold'
               });
               var holdIcon = UWA.createElement('div', {
                   class: "fonticon fonticon-pause"
               });
               holdIcon.inject(holdIconContainer);
               holdIconContainer.inject(nameDiv);

               // for tile view
               statusbarIcons.push("pause");
               statusbarIconsTooltips.push("Hold");
             }
			 if(data[i].referential == "attach"){
				 statusbarIcons.push("attach");
                 statusbarIconsTooltips.push("Referential");
			 }

             data[i].ca_name = nameDiv.outerHTML;

             //severity
             var sevDiv = new UWA.Element("div", {});
             var sevContainer = new UWA.Element("div", {
               class:'gridIconContainer'
             });
             var sevIcon = UWA.createElement('div', {
                 class: sevClass
             });
             sevIcon.inject(sevContainer);
             var sev = UWA.createElement('span', {
                      html: data[i].severity
                 });
             sevContainer.inject(sevDiv);
             sev.inject(sevDiv);

             data[i].sev = sevDiv.outerHTML;

      //assignee
        var assigneesDiv = new UWA.Element("div", {});
        if(data[i].changeAssignee[0]){
          var tooltip = "";
          var changeAssignees = data[i].changeAssignee[0].split(",");
          for(var j=0; j<changeAssignees.length; j++){
              var changeAssignee = changeAssignees[j].split("|");
              var assigneeName = changeAssignee[0];
              var assigneeTrigram = changeAssignee[1];
              tooltip = tooltip + assigneeName + " (" + assigneeTrigram + "),\n";

              var URL = "/api/user/getpicture/login/"+assigneeTrigram+"/format/normal";
              var url = enoviaServerCAWidget.computeSwymUrl(URL);
        //      var defaultPersonUrl="/snresources/images/icons/small/I_ENOVIA_RscPerson.png";

              var assignee = new UWA.Element("div", {
                class:'assignee'
              });
              var userIcon = "";
              if(enoviaServerCAWidget.isSwymInstalled){
                 userIcon = UWA.createElement('img', {
                      class:'userIcon',
                      src: url
                 });
              } else {
                //  url=enoviaServerCAWidget.computeUrl(defaultPersonUrl);
                var iconDetails = ChgInfraService.getAvatarDetails(assigneeName);
                userIcon = UWA.createElement('div', {
                      html: iconDetails.avatarStr,
                      class: "avatarIcon"
                  });
                userIcon.style.setProperty("background",iconDetails.avatarColor);
              }
              userIcon.inject(assignee);
              assignee.inject(assigneesDiv);
          }

          tooltip = tooltip.slice(0, -2);
          assigneesDiv.set({
             title: tooltip
          });

              }
        data[i].assignees = assigneesDiv.outerHTML;

     // Reviewers
     var reviewersDiv = new UWA.Element("div", {});
     if(data[i].changeReviewer[0]){
       var tooltip = "";
       var changereviewers = data[i].changeReviewer[0].split(",");
       for(var j=0; j<changereviewers.length; j++){
           var changereviewer = changereviewers[j].split("|");
           var reviewerName = changereviewer[0];
           var reviewerTrigram = changereviewer[1];
           tooltip = tooltip + reviewerName + " (" + reviewerTrigram + "),\n";

           var URL = "/api/user/getpicture/login/"+reviewerTrigram+"/format/normal";
           var url = enoviaServerCAWidget.computeSwymUrl(URL);
      //     var defaultPersonUrl="/snresources/images/icons/small/I_ENOVIA_RscPerson.png";

           var reviewer = new UWA.Element("div", {
             class:'assignee'
           });

            var userIcon = "";
            if(enoviaServerCAWidget.isSwymInstalled){
               userIcon = UWA.createElement('img', {
                    class:'userIcon',
                    src: url
               });
            } else {
              //  url=enoviaServerCAWidget.computeUrl(defaultPersonUrl);
              var iconDetails = ChgInfraService.getAvatarDetails(reviewerName);
              userIcon = UWA.createElement('div', {
                    html: iconDetails.avatarStr,
                    class: "avatarIcon"
                });
              userIcon.style.setProperty("background",iconDetails.avatarColor);
            }

           userIcon.inject(reviewer);
           reviewer.inject(reviewersDiv);
       }

       tooltip = tooltip.slice(0, -2);
       reviewersDiv.set({
          title: tooltip
       });

           }
     data[i].reviewers = reviewersDiv.outerHTML;
 // Follower
     var followersDiv = new UWA.Element("div", {});
     if(data[i].changeFollower[0]){
       var tooltip = "";
       var changefollowers = data[i].changeFollower[0].split(",");
       for(var j=0; j<changefollowers.length; j++){
           var changefollower = changefollowers[j].split("|");
           var followerName = changefollower[0];
           var followerTrigram = changefollower[1];
           tooltip = tooltip + followerName + " (" + followerTrigram + "),\n";

           var URL = "/api/user/getpicture/login/"+followerTrigram+"/format/normal";
           var url = enoviaServerCAWidget.computeSwymUrl(URL);
           var follower = new UWA.Element("div", {
             class:'assignee'
           });
            var userIcon = "";
            if(enoviaServerCAWidget.isSwymInstalled){
               userIcon = UWA.createElement('img', {
                    class:'userIcon',
                    src: url
               });
            } else {
              //  url=enoviaServerCAWidget.computeUrl(defaultPersonUrl);
              var iconDetails = ChgInfraService.getAvatarDetails(followerName);
              userIcon = UWA.createElement('div', {
                    html: iconDetails.avatarStr,
                    class: "avatarIcon"
                });
              userIcon.style.setProperty("background",iconDetails.avatarColor);
            }
           userIcon.inject(follower);
           follower.inject(followersDiv);
       }

       tooltip = tooltip.slice(0, -2);
       followersDiv.set({
          title: tooltip
       });

           }
     data[i].followers = followersDiv.outerHTML;

          // responsible
          var ownerIconURL = "/api/user/getpicture/login/"+data[i].owner+"/format/normal";
          var ownerIconUrl = enoviaServerCAWidget.computeSwymUrl(ownerIconURL);
      //    var defaultPersonUrl="/snresources/images/icons/small/I_ENOVIA_RscPerson.png";

          var responsible = new UWA.Element("div", {});
          var owner = new UWA.Element("div", {
            class:'assignee'
          });
          var ownerIcon = "";
          if(enoviaServerCAWidget.isSwymInstalled){
            ownerIcon = UWA.createElement('img', {
                class: "userIcon",
                src: ownerIconUrl
            });
          } else {
            //  ownerIconUrl=enoviaServerCAWidget.computeUrl(defaultPersonUrl);
            var iconDetails = ChgInfraService.getAvatarDetails(data[i].responsible);
            ownerIcon = UWA.createElement('div', {
                  html: iconDetails.avatarStr,
                  class: "avatarIcon"
              });
            ownerIcon.style.setProperty("background",iconDetails.avatarColor);
          }

          ownerIcon.inject(owner);
          var ownerName = UWA.createElement('span', {
                  'class': 'userName',
                   html: data[i].responsible
              });
           owner.inject(responsible);
           ownerName.inject(responsible);

           data[i].user = responsible.outerHTML;

    /*       if(data[i].severity == "Low" && data[i].maturity == "In Work"){
             statusbarIcons = ["pause"];
             statusbarIconsTooltips = ["Hold"];
           } else if(data[i].severity == "Medium"){
             statusbarIcons = ["pause","thumbs-down"];
             statusbarIconsTooltips = ["Hold","Reject"];
           } else if(data[i].severity == "High"){
             statusbarIcons = ["pause","thumbs-down","attach"];
             statusbarIconsTooltips = ["Hold","Reject","Referential"];
           }*/

          var oNode = TreeNodeModel.createTreeNodeDataModel(dataModelSet, {
            label: data[i].title,
            subLabel: subLabel,
            description: desc,
            grid: data[i],
            icons: [iUrl],
            thumbnail: ithumbnail,
            customTooltip: customTooltip,
            emptyStatusbarVisibleFlag: true,
            activeFlag: false,
            statusbarIcons: statusbarIcons,
            statusbarIconsTooltips: statusbarIconsTooltips
          });
          treeDocument.addChild(oNode);
        }
        treeDocument.pushUpdate();
      },
      /*
      * Method to update the newly create node inside the data grid view
      */
      updateNode: function(treeDocument, data) {
        var dataModelSet = new DataModelSet();
        var iconMap= ChgServiceGlobalVariable.getIconMap();
        var iUrl=iconMap[data[0].type][0];
        var ithumbnail =iconMap[data[0].type][1];
		    var dueDate = "-";
        if(data[0].dueDate != null && data[0].dueDate != undefined){
          var DATE_TAG_FORMAT = '%Y-%m-%d';
          dueDate = new UWA.Date(data[0].dueDate).strftime(DATE_TAG_FORMAT);
        }
        var subLabel = data[0].name+" | "+data[0].responsible;
        var desc = data[0].maturity+" | "+dueDate;
        var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE+": "+data[0].title+"\n"+
        APP_NLS.CHG_TOOLTIP_NAME+": "+data[0].name+"\n"+
        APP_NLS.CHG_TOOLTIP_SEVERITY+": "+data[0].severity+"\n"+
        APP_NLS.CHG_TOOLTIP_OWNER+": "+data[0].responsible+"\n"+
        APP_NLS.CHG_TOOLTIP_MATURITY+": "+data[0].maturity+"\n"+
        APP_NLS.CHG_TOOLTIP_DUEDATE+": "+dueDate;

        var sevClass = "sevLow wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-low";
        var statusbarIcons = ["level-low"];
        var statusbarIconsTooltips = ["Low"];

        if (data[0].severityGrade == 1) {
          sevClass = "sevMed wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-medium";
          statusbarIcons = ["level-medium"];
          statusbarIconsTooltips = ["Medium"];
        } else if (data[0].severityGrade == 2) {
          sevClass = "sevHigh wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-high";
          statusbarIcons = ["level-high"];
          statusbarIconsTooltips = ["High"];
        }

        //name
        var nameDiv = new UWA.Element("div", {});
        var name = UWA.createElement('span', {
                 html: data[0].name
            });
        name.inject(nameDiv);
        data[0].ca_name = nameDiv.outerHTML;

        //severity
        var sevDiv = new UWA.Element("div", {});
        var sevContainer = new UWA.Element("div", {
          class:'gridIconContainer'
        });
        var sevIcon = UWA.createElement('div', {
            class: sevClass
        });
        sevIcon.inject(sevContainer);
        var sev = UWA.createElement('span', {
                 html: data[0].severity
            });
        sevContainer.inject(sevDiv);
        sev.inject(sevDiv);

        data[0].sev = sevDiv.outerHTML;

        // responsible
        var ownerIconURL = "/api/user/getpicture/login/"+data[0].trigram+"/format/normal";
        var ownerIconUrl = enoviaServerCAWidget.computeSwymUrl(ownerIconURL);
      //  var defaultPersonUrl="/snresources/images/icons/small/I_ENOVIA_RscPerson.png";
        var responsible = new UWA.Element("div", {});
        var owner = new UWA.Element("div", {
          class:'assignee'
        });
        var ownerIcon = "";
        if(enoviaServerCAWidget.isSwymInstalled){
          ownerIcon = UWA.createElement('img', {
              class: "userIcon",
              src: ownerIconUrl
          });
        } else {
          //  ownerIconUrl=enoviaServerCAWidget.computeUrl(defaultPersonUrl);
          var iconDetails = ChgInfraService.getAvatarDetails(data[0].responsible);
          ownerIcon = UWA.createElement('div', {
                html: iconDetails.avatarStr,
                class: "avatarIcon"
            });
          ownerIcon.style.setProperty("background",iconDetails.avatarColor);
        }
        ownerIcon.inject(owner);
        var ownerName = UWA.createElement('span', {
                'class': 'userName',
                 html: data[0].responsible
            });
         owner.inject(responsible);
         ownerName.inject(responsible);

       data[0].user = responsible.outerHTML;

      /*  if(data[0].severity == "Low"){
          statusbarIcons = ["pause"];
          statusbarIconsTooltips = ["Hold"];
        } else if(data[0].severity == "Medium"){
          statusbarIcons = ["pause","thumbs-down"];
          statusbarIconsTooltips = ["Hold","Reject"];
        } else if(data[0].severity == "High"){
          statusbarIcons = ["pause","thumbs-down","attach"];
          statusbarIconsTooltips = ["Hold","Reject","Referential"];
        }*/


        var oNode = TreeNodeModel.createTreeNodeDataModel(dataModelSet, {
		   label: data[0].title,
		   subLabel : subLabel,
		   description : desc,
		   grid: data[0],
		   icons:[iUrl],
		   thumbnail:[ithumbnail],
		   customTooltip: customTooltip,
       statusbarIcons: statusbarIcons,
       statusbarIconsTooltips: statusbarIconsTooltips
		 });

        treeDocument.addChild(oNode, 0);
      },
      updateNodeIndexed:function(treeDocument, data){
             var dataModelSet = new DataModelSet();
             //To- DO Need to get this from service
             var iUrl = "/snresources/images/icons/small/I_ECM_CA.png";
             var pURL = "/snresources/images/icons/large/I_ECM_CA108x144.png";
             var iconUrl = enoviaServerCAWidget.computeUrl(iUrl);
             var ithumbnail = enoviaServerCAWidget.computeUrl(pURL);
             var dueDate = "-";
             if(data[0].dueDate != null && data[0].dueDate != undefined){
               dueDate = data[0].dueDate;
      }
             var subLabel = data[0].name+" | "+data[0].responsible;
             var desc = data[0].maturity+" | "+dueDate;
             var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE+": "+data[0].title+"\n"+
             APP_NLS.CHG_TOOLTIP_NAME+": "+data[0].name+"\n"+
             APP_NLS.CHG_TOOLTIP_SEVERITY+": "+data[0].severity+"\n"+
             APP_NLS.CHG_TOOLTIP_OWNER+": "+data[0].responsible+"\n"+
             APP_NLS.CHG_TOOLTIP_MATURITY+": "+data[0].maturity+"\n"+
             APP_NLS.CHG_TOOLTIP_DUEDATE+": "+dueDate;

             var sevClass = "sevLow wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-low";
             var statusbarIcons = ["level-low"];
             var statusbarIconsTooltips = ["Low"];

             if (data[0].severityGrade == 1) {
               sevClass = "sevMed wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-medium";
               statusbarIcons = ["level-medium"];
               statusbarIconsTooltips = ["Medium"];
             } else if (data[0].severityGrade == 2) {
               sevClass = "sevHigh wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-high";
               statusbarIcons = ["level-high"];
               statusbarIconsTooltips = ["High"];
             }

             //name
             var nameDiv = new UWA.Element("div", {});
             var name = UWA.createElement('span', {
                      html: data[0].name
                 });
             name.inject(nameDiv);
             data[0].ca_name = nameDiv.outerHTML;

             //severity
             var sevDiv = new UWA.Element("div", {});
             var sevContainer = new UWA.Element("div", {
               class:'gridIconContainer'
             });
             var sevIcon = UWA.createElement('div', {
                 class: sevClass
             });
             sevIcon.inject(sevContainer);
             var sev = UWA.createElement('span', {
                      html: data[0].severity
                 });
             sevContainer.inject(sevDiv);
             sev.inject(sevDiv);

             data[0].sev = sevDiv.outerHTML;

             // responsible
             var ownerIconURL = "/api/user/getpicture/login/"+data[0].trigram+"/format/normal";
             var ownerIconUrl = enoviaServerCAWidget.computeSwymUrl(ownerIconURL);
			      // var defaultPersonUrl="/snresources/images/icons/small/I_ENOVIA_RscPerson.png";

             var responsible = new UWA.Element("div", {});
             var owner = new UWA.Element("div", {
               class:'assignee'
            });
            var ownerIcon = "";
            if(enoviaServerCAWidget.isSwymInstalled){
              ownerIcon = UWA.createElement('img', {
                  class: "userIcon",
                  src: ownerIconUrl
              });
            } else {
              //  ownerIconUrl=enoviaServerCAWidget.computeUrl(defaultPersonUrl);
              var iconDetails = ChgInfraService.getAvatarDetails(data[0].responsible);
              ownerIcon = UWA.createElement('div', {
                    html: iconDetails.avatarStr,
                    class: "avatarIcon"
                });
              ownerIcon.style.setProperty("background",iconDetails.avatarColor);
            }
             ownerIcon.inject(owner);
             var ownerName = UWA.createElement('span', {
                     'class': 'userName',
                      html: data[0].responsible
                 });
              owner.inject(responsible);
              ownerName.inject(responsible);

            data[0].user = responsible.outerHTML;

        /*     if(data[0].severity == "Low" && data[0].maturity == "In Work"){
               statusbarIcons = ["pause"];
               statusbarIconsTooltips = ["Hold"];
             } else if(data[0].severity == "Medium"){
               statusbarIcons = ["pause","thumbs-down"];
               statusbarIconsTooltips = ["Hold","Reject"];
             } else if(data[0].severity == "High"){
               statusbarIcons = ["pause","thumbs-down","attach"];
               statusbarIconsTooltips = ["Hold","Reject","Referential"];
             }*/

           var oNode = TreeNodeModel.createTreeNodeDataModel(dataModelSet, {
            label: data[0].title,
            subLabel : subLabel,
            description : desc,
            grid: data[0],
            icons:[iconUrl],
            thumbnail:[ithumbnail],
            customTooltip: customTooltip,
            statusbarIcons: statusbarIcons,
            statusbarIconsTooltips: statusbarIconsTooltips,
            emptyStatusbarVisibleFlag: true
    });

        treeDocument.addChild(oNode, 0);
      }

    });

    return ChgChangeDataGridModel;

  });
