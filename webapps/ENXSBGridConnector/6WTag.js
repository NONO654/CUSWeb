define('DS/ENXSBGridConnector/6WTag', ['DS/WAFData/WAFData', 'DS/TagNavigatorProxy/TagNavigatorProxy', 'emxUICore'],
  function(WAFData, TagNavigatorProxy, emxUICore) {

    var bpsTagNavSBInit = {
      tnWin: null,
      tagXML: null,
      aSBRowNodes: null,
      tnID: null,
      oidMapping: {},
      StandardFunctions: null,
      multiValueSeparator: "0x08 ",
      getTNWindow: function() {
        return this.tnWin || getTopWindow();
      },

      handleFilter: function(objSelection) {
        //apply selection (objSelection) to the tagXML
        if (this.tagXML) {
          this.showObjects(objSelection.filteredSubjectList);
        }
      },

      showObjects: function(filteredSubjectList) {
        var aAllObjIds = tagService.StandardFunctions.getAttributeFromAllNodes("id");
        if (aAllObjIds.length == 0) {
          return;
        }
        var filteredIds = [];

        for (var i = 0; i < aAllObjIds.length; i++) {
          var objectId = aAllObjIds[i];
          var pid = this.oidMapping[objectId];
          if (filteredSubjectList.find(pid) >= 0) {
            filteredIds.push(objectId);
          }
        }

        var filterManager = dataGridModel.getFilterManager();
        if (filterManager) {
          filterManager.setPropertyFilterModel('id', {
            filterId: 'set',
            filterModel: filteredIds
          });
        }
      },

      handleDrawTags: function() {
        var aDGRowNodes = tagService.StandardFunctions.getAttributeFromAllNodes("id");

        if (aDGRowNodes.length > 0) {
          //get tag data from service
          var postData = "oid_list=" + aDGRowNodes.join(",");
          var options = {
            type: 'xml',
            method: 'POST',
            data: "oid_list=" + aDGRowNodes.join(","),
            onComplete: function(objTagXml) { // inner function don't use "this"
              //store tagXML
              bpsTagNavSBInit.tnID.unsetTags();
              bpsTagNavSBInit.tagXML = objTagXml;
              //build 6w tag object
              var tagObj = bpsTagNavSBInit.buildJSONTagData(objTagXml, aDGRowNodes);
              //load tag nav
              bpsTagNavSBInit.tnID.setSubjectsTags(JSON.parse(JSON.stringify(tagObj)));
              //bpsTagNavSBInit.handleTagCollect();
            }
          };
          WAFData.authenticatedRequest("../../resources/bps/sbtagdata/sbtagdata", options);
        } else {
          //unload
          bpsTagNavSBInit.tnID.setSubjectsTags({});
        }
      },

      handleTagCollect: function() {
        //get oids from oXML
        var aDGRowNodes = tagService.StandardFunctions.getAttributesFromSelectedNodes("id", false);
        var aPID = []
        for (var i = 0; i < aDGRowNodes.length; i++) {
          var pid = bpsTagNavSBInit.oidMapping[aDGRowNodes[i]];
          if (pid) {
            aPID.push(pid);
          }
        }
        if (aPID.length > 0) {
          bpsTagNavSBInit.tnID.focusOnSubjects(aPID);
        } else {
          bpsTagNavSBInit.tnID.unfocus();
        }
      },

      buildJSONTagData: function(tagXML, aSBRowNodes) {
        var columnList = null;
        if (aSBRowNodes != null) {
          columnList = [];
          var columns = emxUICore.selectNodes(tagXML, "/mxRoot/columns/column");
          for (var i = 0; i < columns.length; i++) {
            var col = columns[i];
            var colName = col.getAttribute("name");
            var colField = col.getAttribute("label");
            var predicate = null;
            if (colField == null) {
              predicate = colName.substring(0, colName.length - 1);
            } else {
              predicate = colName.replace("/" + colField, "");
            }
            //in weblogic, the xml is not passing settings; working around this issue.
            //var sixw = emxUICore.selectSingleNode(col, 'settings/setting[@name="sixw"]');
            //var predicate = emxUICore.getText(sixw);
            var colObj = {
              "name": colName,
              "label": colField,
              "sixw": predicate
            };
            columnList.push(colObj);
          }
          this.columnList = columnList;
        } else {
          columnList = this.columnList;
        }

        var tagData = {};
        var rows = emxUICore.selectNodes(tagXML, "/mxRoot/rows/r");
        var tag, cells, colObj, value, j, k, values;
        for (var i = 0; i < rows.length; i++) {
          var row = rows[i];
          var pid = row.getAttribute("o");
          if (aSBRowNodes != null) {
            var oid = aSBRowNodes[i];
            this.oidMapping[oid] = pid;
          }
          if (row.getAttribute("filter") == "true") continue;
          tags = [];

          cells = row.getElementsByTagName("c");
          for (j = 0; j < cells.length; j++) {
            colObj = columnList[j];
            value = emxUICore.getText(cells[j]);
            values = value.split(this.multiValueSeparator);
            for (k = 0; k < values.length; k++) {
              if (values[k] == "") continue;
              if (values[k].contains("/")) {
                var s = values[k].split("/");
                tag = {
                  "object": s,
                  "dispObject": s,
                  "sixw": colObj.sixw,
                  "field": colObj.label
                };
              } else {
                tag = {
                  "object": values[k],
                  "dispObject": values[k],
                  "sixw": colObj.sixw,
                  "field": colObj.label
                };
              }
              tags.push(tag);
            }
          }
          tagData[pid] = tags;
        }

        return tagData;
      },

      init: function(StandardFunctions) {
        this.StandardFunctions = StandardFunctions;
        var tagger, oThis = this,
          path;
        topAccessWin = this.getTNWindow();

        if (topAccessWin) {
          path = window.location.pathname.split('/')[1];
          tagServiceURL = window.location.protocol + "//" + window.location.host + "/" + path;

          //topAccessWin.jQuery(topAccessWin.document).bind('TN_LAUNCHED', oThis.handleDrawTags);
          if (!oThis.tnID) {
            var paramWidgetId = this.getTNWindow().location.search.match(/[?&]widgetId=([^&]*)?/),
              paramTenant = this.getTNWindow().location.search.match(/[?&]tenant=([^&]*)?/);
            paramWidgetId = (paramWidgetId == null ? undefined : paramWidgetId[1] || undefined);
            paramTenant = (paramTenant == null ? undefined : paramTenant[1] || undefined);
            paramTenant = (paramTenant == null ? (topAccessWin.curTenant == "" ? "OnPremise" : topAccessWin.curTenant) : paramTenant);
            if (typeof this.getTNWindow().taggerCtx === "undefined") {
              this.getTNWindow().taggerCtx = "context2";
            }
            var options = {
              widgetId: paramWidgetId,
              contextId: paramWidgetId == null ? this.getTNWindow().taggerCtx : undefined,
              tenant: paramTenant == "onpremise" ? undefined : paramTenant,
              filteringMode: 'WithFilteringServices'
            };
            if (!this.getTNWindow().isfromIFWE && emxUIConstants.TOPFRAME_ENABLED) {

              tagger = this.getTNWindow().topFrameTagger.get6WTagger(this.getTNWindow().taggerCtx);
              tagger.setAsCurrent();
            }

            //setup listeners
            //when a tag is clicked in TN
            oThis.tnID = TagNavigatorProxy.createProxy(options);
            oThis.tnID.toggleProxyFocus("true");
            oThis.tnID.addFilterSubjectsListener(oThis.handleFilter, oThis, false);

            //when SB loads or changes data
            //console.log("setting sb listeners");
            topAccessWin.jQuery(topAccessWin.document).bind('dg_data_changed.bps_dg', oThis.handleDrawTags);
            topAccessWin.jQuery(topAccessWin.document).bind('dg_selection_changed.bps_dg', oThis.handleTagCollect);

            removeTagger = function() {
              oThis.tnID.die();
            }

            destroySBListeners = function() {
              //console.log("destroying sb listeners");
              topAccessWin.jQuery(topAccessWin.document).unbind(".bps_dg");
              //topAccessWin.jQuery(topAccessWin.document).unbind('TN_LAUNCHED');
              //if(topAccessWin.emxUISlideIn && topAccessWin.emxUISlideIn.current_slidein && topAccessWin.emxUISlideIn.current_slidein.dir == "left"){
              //topAccessWin.closeSlideInDialog();
              //topAccessWin.showSlideInDialog.mode = "";
              //}
              /*
              if (topAccessWin.bpsTagNavConnector && topAccessWin.bpsTagNavConnector.TagNavigator) {
                topAccessWin.bpsTagNavConnector.rebuildViewNeeded = false;
                topAccessWin.bpsTagNavConnector.TagNavigator.get6WTagger(tagService.getTNWindow().taggerCtx).clearFilters(true);
              } else if (emxUIConstants.TOPFRAME_ENABLED) {*/
              tagService.getTNWindow().topFrameTagger.get6WTagger(tagService.getTNWindow().taggerCtx).clearFilters(true);
              //}
            };
            if (oThis.getTNWindow().isMobile) {
              jQuery(window).bind('unload', destroySBListeners);
              jQuery(window).bind('unload', removeTagger);
            } else {
              jQuery(window).bind('beforeunload', removeTagger);
              jQuery(window).bind('unload', destroySBListeners);
            }


          } else {
            oThis.tnID.activate();
          }



        }
        window.tagService = oThis;
      }
    };

    return bpsTagNavSBInit;
  });
