<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>

<%@page import = "matrix.util.StringList"%>
<%@page import = "java.io.UnsupportedEncodingException"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Iterator"%>

<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import = "com.matrixone.apps.domain.util.mxType"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import = "matrix.db.BusinessType"%>
<%@page import = "matrix.db.BusinessTypeList"%>
<%@page import = "matrix.db.BusinessTypeItr"%>
<%@page import = "matrix.db.Context"%>
<%@page import = "matrix.db.RelationshipType"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "java.net.URLEncoder"%>
<%@page import = "java.util.Map"%>

<jsp:useBean id="tableBean"
    class="com.matrixone.apps.framework.ui.UITable"
    scope="session"/>
<jsp:useBean id="simBean"
    class="com.dassault_systemes.smaslm.matrix.web.smaSearchSimulation"
    scope="session"/>


<html>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>

<%
    String sMode = "";

    // save original mode so can use multiple select chooser for
    // searching mutiple attribute groups
    String oldMode = "";
    simBean.resetVPMSearch();
    
    // get optional type choosers map
    HashMap chooserStrMap = SimulationUtil.getChooserMap(context,false);
    HashMap chooserCmdMap = SimulationUtil.getChooserMap(context,true);

    HashMap chooserCommand = new HashMap();
    chooserCommand.put("simTypeChooserSimulationCreate",   "SMASimType_Search");
    chooserCommand.put("simTypeChooserSimulationViewEdit", "SMASimType_Search");
    chooserCommand.put("simTypeChooserAnalyticsCaseViewEdit", "SMASimType_Search");
    chooserCommand.put("simTypeChooserSimulationSearch",   "SMASimType_Search");
    chooserCommand.put("simTypeChooserActivityCreate",     "SMASimType_Search");
    chooserCommand.put("simTypeChooserAdviseCreate",       "SMASimType_Search");
    chooserCommand.put("simTypeChooserActivityViewEdit",   "SMASimType_Search");
    chooserCommand.put("simTypeChooserActivitySearch",     "SMASimType_Search");
    chooserCommand.put("simTypeChooserTemplateCreate",     "SMASimType_Search");
    chooserCommand.put("simTypeChooserTemplateViewEdit",   "SMASimType_Search");
    chooserCommand.put("simTypeChooserTemplateSearch",     "SMASimType_Search");
    chooserCommand.put("simTypeChooserSimDoc",             "SMASimType_Search");
    chooserCommand.put("simTypeChooserSimDocMultiple",     "SMASimType_Search");//HL Import Attributes During Execution - PT6
    chooserCommand.put("connectorChooser",                 "SMAConnector_Search");
    chooserCommand.put("vpmSimulationChooser",             "SMA_VPMSimulation_Search");
    chooserCommand.put("simulationChooser",                "SMASimulation_Search");
    chooserCommand.put("activityChooser",                  "SMAActivity_Search");
    chooserCommand.put("taskChooser",                      "SMATask_Search");
    chooserCommand.put("documentChooser",                  "SMASimDocuments_Search");
    chooserCommand.put("documentSingleChooser",            "SMASimDocumentSingle_Search");
    chooserCommand.put("templateChooser",                  "SMATemplate_Search");
    chooserCommand.put("companionTemplateChooser",                  "SMACompanionTemplate_Search");
    chooserCommand.put("exporterChooser",                 "SMAExporter_Search");
    chooserCommand.put("importerChooser",                 "SMAImporter_Search");
    //IR-076644 : To add Requirement Central Chooser in Template Instantiation options
    chooserCommand.put("otherChooser",              "SMAOtherEntities_Search");
    chooserCommand.put("parameterChooser",                 "SMA_PlmParameter_Search");
    chooserCommand.put("adviseSimulationJobChooser",       "SMAJob_SearchAnalytics");    
    chooserCommand.put("hostGroupChooser",                 "SMAHostGroup_Search");
    chooserCommand.put("folderChooser",                 "SMAWorkspaceFolder_Search");
    chooserCommand.put("hostChooser",                 "SMAHost_Search");
    
    // iterate over chooser string map to see if already in command map
    Iterator it = chooserStrMap.entrySet().iterator();
    while (it.hasNext()) 
    {
        Map.Entry pairs = (Map.Entry)it.next();
        String chsrStr = (String)pairs.getValue();
        
        // if chooser string not in the command map
        if (!chooserCommand.containsKey(chsrStr))
        {
            // get the corresponding search command for the chooser str
            String chsrCmd = (String)chooserCmdMap.get(pairs.getKey());
            // if we have a command add it to the command map
            if (chsrCmd != null && chsrCmd.length() >0)
            {
                chooserCommand.put(chsrStr,chsrCmd);
            }
        }
    }
    try
    {
        // mode controls what to do in this jsp
        sMode = emxGetParameter(request, "slmmode");
        String objectId = emxGetParameter(request, "objectId");
        
        // if we are choosing a host...get the selected group's ID
        // which is returned as name "|" "|" OID
        if ("hostChooser".equals(sMode))
        {
            String rowId = emxGetParameter(request,"emxTableRowId");
            String [] rowInfo = rowId.split( "\\|"); 
            
            // make sure we have a station name and OID
            if (rowInfo != null && rowInfo.length == 4)
            {
                objectId = rowInfo[2];
                if (objectId.isEmpty())
                {
                    String invalidSearchSelection =
                          SimulationUtil.getI18NString(context,
                              "Error.Station.Not.Selected");
                    throw new Exception(invalidSearchSelection);
                                        
                }
            }
            if ( ! AccessUtil.hasAccess(
              		context, objectId, "modify"))
            {
                DomainObject hostObj = 
                        new DomainObject(objectId);

                String sError = 
              		SimulationUtil.getI18NString(context,
              			"smaSimulation.StationGroupAddNoModify",
                        "P1", 
                        SimulationUtil.getObjectName(context, hostObj));
                %>
                <script language = javascript>
			      alert("<%=sError%>");
			      closeWindow();
                </script>
                <%
                return;
            }	    		 
        }
        String typeStringParam = emxGetParameter(request, "typeString");

        // check to see if we have a dynamic-type chooser
        String typeChooser = null;
        String selection = "single";

        // dynamic ViewEdit chooser?
        if ("simTypeChooserViewEdit_Common".equals(sMode))
        {
            if (objectId != null)
            {
                typeChooser = getViewEditChooserForType(context, objectId);
            }
            else
            {
                typeChooser = getViewEditChooserForType(typeStringParam);
            }

            selection = "multiple";
        }
        // dynamic Search chooser?
        else if ("simTypeChooserSearch_Common".equals(sMode))
        {
            if (objectId != null)
            {
                typeChooser = getSearchChooserForType(context, objectId);
            }
            else
            {
                typeChooser = getSearchChooserForType(typeStringParam);
            }

            selection = "multiple";
        }

        if (typeChooser != null)
        {
            // keep original mode so can use new chooser mutiple for
            // mutiple attribute group search
            oldMode = sMode;

            // if we have a type-based chooser, use it
            sMode = typeChooser;
        }

//        Enumeration xx = request.getParameterNames();
//        System.out.println("---------------------------------------");
//        while (xx.hasMoreElements())
//        {
//            String name = (String) xx.nextElement();
//            String value = emxGetParameter(request, name);
//            System.out.println(name + " = " + value);
//        }

        // use multi select for attributes when creating activity,
        // process or template
        if( sMode.equalsIgnoreCase("simTypeChooserSimulationCreate") ||
            sMode.equalsIgnoreCase("simTypeChooserActivityCreate") ||
            sMode.equalsIgnoreCase("simTypeChooserAdviseCreate") ||            
            sMode.equalsIgnoreCase("adviseSimulationJobChooser") ||
            sMode.equalsIgnoreCase("simTypeChooserTemplateCreate") ||
            sMode.equalsIgnoreCase("hostChooser") ||
            sMode.equalsIgnoreCase("simTypeChooserSimDocMultiple"))//HL Import Attributes During Execution - PT6
        {
            oldMode = sMode;
            selection = "multiple";
        }

        if( sMode.equalsIgnoreCase("simTypeChooserSimulationCreate") ||
            sMode.equalsIgnoreCase("simTypeChooserSimulationViewEdit") ||
            sMode.equalsIgnoreCase("simTypeChooserAnalyticsCaseViewEdit") ||
            sMode.equalsIgnoreCase("simTypeChooserSimulationSearch") ||
            sMode.equalsIgnoreCase("simTypeChooserActivityCreate") ||
            sMode.equalsIgnoreCase("simTypeChooserAdviseCreate") ||
            sMode.equalsIgnoreCase("simTypeChooserActivityViewEdit") ||
            sMode.equalsIgnoreCase("simTypeChooserActivitySearch") ||
            sMode.equalsIgnoreCase("simTypeChooserTemplateCreate") ||
            sMode.equalsIgnoreCase("simTypeChooserTemplateViewEdit") ||
            sMode.equalsIgnoreCase("simTypeChooserTemplateSearch") ||
            sMode.equalsIgnoreCase("simTypeChooserSimDoc") ||
            sMode.equalsIgnoreCase("simTypeChooserSimDocMultiple") ||//HL Import Attributes During Execution - PT6
            sMode.equalsIgnoreCase("vpmSimulationChooser") ||
            sMode.equalsIgnoreCase("simulationChooser") ||
            sMode.equalsIgnoreCase("activityChooser") ||
            sMode.equalsIgnoreCase("taskChooser") ||
            sMode.equalsIgnoreCase("documentChooser") ||
            sMode.equalsIgnoreCase("documentSingleChooser") ||
            sMode.equalsIgnoreCase("connectorChooser")||
            sMode.equalsIgnoreCase("exporterChooser")||
            sMode.equalsIgnoreCase("importerChooser")||
            sMode.equalsIgnoreCase("templateChooser")||
            sMode.equalsIgnoreCase("companionTemplateChooser")||
            sMode.equalsIgnoreCase("adviseSimulationJobChooser")||
            sMode.equalsIgnoreCase("parameterChooser")||
            sMode.equalsIgnoreCase("otherChooser") ||            
            sMode.equalsIgnoreCase("folderChooser") ||
            sMode.equalsIgnoreCase("hostGroupChooser") ||            
            sMode.equalsIgnoreCase("hostChooser") ||            
            chooserStrMap.values().contains(sMode))
        {
            String fND = emxGetParameter(request, "fieldNameDisplay");
            String fNA = emxGetParameter(request, "fieldNameActual");
            String frm = emxGetParameter(request, "slmform");
            String sForm = emxGetParameter(request, Search.REQ_PARAM_FORM_NAME);
            String sFrame = emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME);
            String assocType = emxGetParameter(request, "assocType");
            String inclusionList = emxGetParameter(request
                , "inclusionList");
            if ( assocType == null )
                assocType = "" ;
            else
                assocType = "&assocType=" + assocType;

            
            String invokedFrom = emxGetParameter(request, "invokedFrom");
            String sFID = emxGetParameter(request, "fieldId");
            String actualfieldId = emxGetParameter(request, "actualfieldId");
            
            

            String srchCmd = "";
            if( chooserCommand.containsKey(sMode) )
            {
                srchCmd = (String)chooserCommand.get(sMode);
                if(sMode.equalsIgnoreCase("adviseSimulationJobChooser"))
                {
                	srchCmd = "SMASimDocuments_Search" + "," + srchCmd + "," + "SMAAdv_SearchOtherObjects,SMAAdv_SearchCreateFromFiles,SMASimulation_Search";
                }
            }

            // get submit url.  Pass in old mode to see if using
            // new chooser multiple for multiple attribute selection
            String submitUrl = getSubmitURL(request,oldMode);

            if (objectId != null)
            {
                submitUrl = appendObjectIdParam(submitUrl, objectId);
            }

            if ( srchCmd.length() > 0 )
            {
                URLBuilder URL = getURLBuilder(request);
                URL.append("../components/emxCommonSearch.jsp");
                URL.append("?searchmode=chooser");
                URL.append("&formName=").append(sForm);
                URL.append("&frameName=").append(sFrame);
                URL.append("&suiteKey=SimulationCentral");
                URL.append("&selection=").append(selection);
                URL.append("&SubmitURL=").
                    append(getUrlEncodedString(context, submitUrl));
                URL.append("&searchmenu=SMASearchContainer");
                URL.append("&searchcommand=").append(srchCmd);
                URL.append("&form=").append(frm);
                URL.append("&fieldNameDisplay=").append(fND);
                URL.append("&fieldNameActual=").append(fNA);
                URL.append("&openedBy=").append(sMode);
                URL.append(assocType);
                URL.append("&resultsToolbar=SMACommon_SearchResultToolbar");

                
                if(invokedFrom != null) {
                    URL.append("&invokedFrom="+invokedFrom);
                    URL.append("&fieldId="+sFID);
                    URL.append("&actualfieldId="+actualfieldId);
                }
                
                if(inclusionList!= null){
                    URL.append("&inclusionList="+inclusionList);
                }
                
                // if we are doing a vpm search add the vpm data
                // to the new url
                if (srchCmd.equals("SMA_VPMSimulation_Search"))
                {
                    String vpmUsage = emxGetParameter(
                        request, SimulationConstants.VPM_ATTR_USAGE);
                    String vpmDiscipline = emxGetParameter(
                       request,SimulationConstants.VPM_ATTR_DISCIPLINE);
                    String vpmType = emxGetParameter(
                        request, SimulationConstants.VPM_ATTR_TYPE);
                    if (vpmUsage == null) vpmUsage = "";
                    if (vpmDiscipline == null) vpmDiscipline = "";
                    if (vpmType == null) vpmType = "";
                    URL.append("&")
                        .append(SimulationConstants.VPM_ATTR_USAGE)
                        .append("=").appendEncoded(context,vpmUsage);
                    URL.append("&")
                        .append(SimulationConstants.VPM_ATTR_DISCIPLINE)
                        .append("=").appendEncoded(context,vpmDiscipline);
                    URL.append("&")
                        .append(SimulationConstants.VPM_ATTR_TYPE)
                        .append("=").appendEncoded(context,vpmType);
                }
%>
            <script language="Javascript">
                document.location.href = "<%=URL.toString()%>";
            </script>
<%
            }
            else
            {
                System.out.println("DUDE! BAD CHOOSER");
            }
        }

        // Called by emxCommonSearch.jsp (from above)
        else if(sMode.equalsIgnoreCase("chooser"))
        {
            String sRowIds[] = emxGetParameterValues(request,"emxTableRowId");

            String selObjID = sRowIds[0];

            HashMap paramMap = new HashMap();
            HashMap programMap = new HashMap();

            paramMap.put("objectId",selObjID);
            programMap.put("paramMap",paramMap);

            String[] methodargs = JPO.packArgs(programMap);

            String sTitle = (String)JPO.invoke(context,
                "jpo.simulation.SimulationUI", null,
                "getTitle", methodargs, String.class );

            String timeStamp = emxGetParameter(request, "timeStamp");
            Map map = (HashMap)tableBean.getRequestMap(timeStamp);

            String sFrm = (String)map.get(Search.REQ_PARAM_FORM_NAME);
            String sFND = (String)map.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
            String sFNA = (String)map.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
            String sFNAOID = sFNA + "OID"; //fix for 178683V6R2013x
            String sFID =  (String)map.get("fieldId");
            String actualfieldId = (String)map.get("actualfieldId");
            String invokedFrom = (String)map.get("invokedFrom");
            
%>
            <script language="javascript" type="text/javaScript">
            //<![CDATA[
            try{
<%
                if("performanceStudy".equalsIgnoreCase(invokedFrom)) {      
                    DomainObject DO = DomainObject.newInstance(context,selObjID);
                    String physicalId = DO.getInfo(context,"physicalid");
%>

                    var contentFrame = getTopWindow().getWindowOpener().getTopWindow(),
                        model = {};

                    model['value_display'] = "<%=sTitle%>";
                    model['value'] = "<%=selObjID%>";
                    model['title'] = "<%=sTitle%>";
                    model['chooser_physicalid'] = "<%=physicalId%>";
                    model.operation ='contentChooser';
                    model = JSON.stringify(model);
                    contentFrame.postMessage(model, "*");

<%
				} else if("simulationCompanion".equalsIgnoreCase(invokedFrom)) 
				{
				    DomainObject DO = DomainObject.newInstance(context,selObjID);
				    String title = DO.getAttributeValue(context, 
					        DomainConstants.ATTRIBUTE_TITLE);
				    String objType = DO.getInfo(context, DomainConstants.SELECT_TYPE);
				    String lastModified = DO.getInfo(context, DomainConstants.SELECT_MODIFIED);
				    String description = DO.getInfo(context, DomainConstants.SELECT_DESCRIPTION);
%>
					var contentFrame = getTopWindow().getWindowOpener();
					var scAdAppMain = contentFrame.document.body.querySelector('ad-app-main');
					if( scAdAppMain != null ) {
						var scDataview = scAdAppMain.shadowRoot.querySelector('ad-data-view');
						if( scDataview != null ) {
							var scMdataView = scDataview.shadowRoot.querySelector('ad-mdata-view');
							if( scMdataView != null ) {
								scMdataView.addReferencedContent("<%=selObjID%>", "<%=title%>", "<%=objType%>", "<%=lastModified%>", "<%=description%>");
							}
						}
					}
					
<%
                }else if("experienceStudio".equalsIgnoreCase(invokedFrom)) {      
                    DomainObject DO = DomainObject.newInstance(context,selObjID);
                    String physicalId = DO.getInfo(context,"physicalid"); 
%>
                var contentFrame = getTopWindow().getWindowOpener();
                var object = {};
                object['chooser_virtualid'] = '<%=sFNA%>';
                object['value_display'] = '<%=sTitle%>';
                object['value'] = '<%=selObjID%>';
                object['title'] = '<%=sTitle%>';
                object['chooser_physicalid'] = '<%=physicalId%>';
                contentFrame.objectChosen(object);
<%
               } else {      
%>
                var sFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
                if( sFrame == null )
                    sFrame = getTopWindow().getWindowOpener();

                var txtTypeDisplay = sFrame.document.<%=sFrm%>.<%=sFND%>;
                var txtTypeActual  = sFrame.document.<%=sFrm%>.<%=sFNA%>;
                var txtTypeActualOID  = sFrame.document.<%=sFrm%>.<%=sFNAOID%>; 

                //txtTypeDisplay.value = "<%=sTitle%>";
                //txtTypeActual.value = "<%=selObjID%>";
                //txtTypeActualOID.value = "<%=selObjID%>";
                var txtTypeActualOID  = sFrame.document.<%=sFrm%>.<%=sFNAOID%>;
                var txtTypeId  = sFrame.document.<%=sFrm%>.<%=sFID%>;

                txtTypeDisplay.value = "<%=sTitle%>";
                txtTypeActual.value = "<%=selObjID%>";
                txtTypeActualOID.value = "<%=selObjID%>";
<%
              }
%>
                       
          }
          catch(error)
          {
                
                getTopWindow().closeWindow();                
          }
            

            <%
                        // This is not an elegant solution but it is the only
                        // way I can find to hide/show the sim type attributes
                        if ( sFNA.equals("SimType") )
                        {
            %>
                           if ( getTopWindow().getWindowOpener().getSimTypeAttrs )
                              getTopWindow().getWindowOpener().getSimTypeAttrs(true);
            <%
                        }
            %>

            getTopWindow().closeWindow();
            
            </script>
<%
        }

        // support search for multiple attribute groups
        else if(sMode.equalsIgnoreCase("chooserMultiple"))
        {
            String sRowIds[] = emxGetParameterValues(request,"emxTableRowId");
            StringBuilder selObjID = new StringBuilder();
            StringBuilder sTitle = new StringBuilder();

            // if more than one attribute group is selected
            // use them both separated by "; "

            /*fix for IR-067813V6R2012x warnig message for no objects is not proper
                null check is inserted - sh2
            */
            if (sRowIds != null)
            {
                for (int idx = 0; idx < sRowIds.length; idx++)
                {

                    String objID = sRowIds[idx];

                    HashMap paramMap = new HashMap();
                    HashMap programMap = new HashMap();

                    paramMap.put("objectId",objID);
                    programMap.put("paramMap",paramMap);

                    String[] methodargs = JPO.packArgs(programMap);

                    String objTitle = (String)JPO.invoke(context,
                        "jpo.simulation.SimulationUI", null,
                        "getTitle", methodargs, String.class );

                    if (idx >0)
                    {
                        selObjID.append("; ");
                        sTitle.append("; ");
                    }
                    selObjID.append(objID);
                    sTitle.append(objTitle);
                }

            String timeStamp = emxGetParameter(request, "timeStamp");
            Map map = (HashMap)tableBean.getRequestMap(timeStamp);

            String sFrm = (String)map.get(Search.REQ_PARAM_FORM_NAME);
            String sFND = (String)map.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
            String sFNA = (String)map.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
%>
            <script language="javascript" type="text/javaScript">
            //<![CDATA[
            var sFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
            if( sFrame == null )
                sFrame = getTopWindow().getWindowOpener();

            var txtTypeDisplay = sFrame.document.<%=sFrm%>.<%=sFND%>;
            var txtTypeActual  = sFrame.document.<%=sFrm%>.<%=sFNA%>;

            txtTypeDisplay.value = "<%=sTitle%>";
            txtTypeActual.value = "<%=selObjID%>";

            <%
                        // This is not an elegant solution but it is the only
                        // way I can find to hide/show the sim type attributes
                        if ( sFNA.equals("SimType") )
                        {
            %>
                           if ( getTopWindow().getWindowOpener().getSimTypeAttrs )
                              getTopWindow().getWindowOpener().getSimTypeAttrs(true);
            <%
                        }
            %>

            getTopWindow().closeWindow();
            </script>
             <%}else{
             String message = SimulationUtil.getI18NString(context,"smaSimulationCentral.Error.NoSelection");
             if(message==null || "smaSimulationCentral.Error.NoSelection".equals(message))
                 message ="Nothing Selected";
             %>
                <script type="text/javascript">
                var s="<%=message%>";
                alert(s);
                var sFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
                if( sFrame == null )
                    sFrame = getTopWindow().getWindowOpener();
                </script>
            <%}

        }
        else if ( sMode.equalsIgnoreCase("addexisting"))
        {
            String hlp = emxGetParameter(request, "HelpMarker");
            String row = emxGetParameter(request, "emxTableRowId");
            String fromPage = emxGetParameter(request, "fromPage");
            String refreshFrame = emxGetParameter(request, "refreshFrame");
            String srcDestRelName = emxGetParameter(request, "srcDestRelName");

            if ( srcDestRelName == null || srcDestRelName.length() == 0 )
                srcDestRelName = "relationship_SimulationContent_Referenced";            

            simBean.loadData(context);
            HashMap cmds = simBean.getAvailableContentPageSearchCmds();
            
            String    sCMDs = (String)cmds.get("commands");
            String   sTypes = (String)cmds.get("cmdTypes");
            String[] aTypes = sTypes.split("\\|");
            if ( aTypes.length > 0 )
                sTypes = aTypes[aTypes.length-1];

            sCMDs = sCMDs.replace("|",",");

            String addlSearchCmds = emxGetParameter(request, "searchCmds");
            if ( addlSearchCmds != null && addlSearchCmds.length() > 0 )
                sCMDs = addlSearchCmds + "," + sCMDs;

            // Create URL to forward to
            StringBuffer URL = new StringBuffer(1);
            URL.append("../components/emxCommonSearch.jsp");
            URL.append("?searchmode=addexisting");           
            URL.append("&suiteKey=SimulationCentral");
            URL.append("&searchmenu=SMASearchContainer");
            URL.append("&searchcommand=" + sCMDs);
            URL.append("&isTo=true");
            URL.append("&selection=multiple");
            URL.append("&srcDestRelName=").append(srcDestRelName);
            URL.append("&suiteKey=Components");
            URL.append("&useSelectedObjectId=true");
            URL.append("&resultsToolbar=SMACommon_SearchResultToolbar");
            URL.append("&emxTableRowId=").append(row);
            URL.append("&HelpMarker=").append(hlp);
            URL.append("&").append(Search.REQ_PARAM_SUBMIT_URL);
            URL.append("=../simulationcentral/smaContentConnect.jsp");
            URL.append("&refreshFrame=").append(refreshFrame);
            URL.append("&fromPage=").append(fromPage);
            URL.append("&openedBy=").append(sMode);


            if ( sTypes.length() > 0 )
                URL.append("&inclusionList=").append(sTypes);

            Enumeration xx = request.getParameterNames();
            while (xx.hasMoreElements())
            {
                String name = (String) xx.nextElement();
                String value = emxGetParameter(request, name);
                URL.append("&"+name+"="+value);
            }

%>
            <script language="Javascript">
                getTopWindow().location.href = "<%=URL.toString()%>";
            </script>
<%
        }
        
        else if ( sMode.equalsIgnoreCase("addAnalyticsDataSet"))
        {
            String hlp = emxGetParameter(request, "HelpMarker");
            //String row = emxGetParameter(request, "emxTableRowId");
            String row = null;
            String fromPage = emxGetParameter(request, "fromPage");
            String refreshFrame = emxGetParameter(request, "refreshFrame");
            String srcDestRelName = emxGetParameter(request, "srcDestRelName");
            
            if ( srcDestRelName == null || srcDestRelName.length() == 0 ){
                srcDestRelName = "relationship_SimulationContent_Referenced";
            }
            
            String sCMDs = "SMASimDocuments_Search,SMAJob_SearchAnalytics,SMAAdv_SearchOtherObjects,SMAAdv_SearchCreateFromFiles";
            
            // Create URL to forward to
            StringBuffer URL = new StringBuffer(1);
            URL.append("../components/emxCommonSearch.jsp");
            URL.append("?searchmode=addexisting"); 
            URL.append("&suiteKey=SimulationCentral");
            URL.append("&searchmenu=SMASearchContainer");
            URL.append("&searchcommand=" + sCMDs);
            URL.append("&isTo=true");
            URL.append("&selection=multiple");
            URL.append("&srcDestRelName=").append(srcDestRelName);
            URL.append("&suiteKey=Components");
            URL.append("&useSelectedObjectId=true");
            URL.append("&resultsToolbar=SMACommon_SearchResultToolbar");
            URL.append("&emxTableRowId=").append(row);
            URL.append("&HelpMarker=").append(hlp);
            URL.append("&").append(Search.REQ_PARAM_SUBMIT_URL);
            URL.append("=../simulationcentral/smaContentConnect.jsp");
            URL.append("&refreshFrame=").append(refreshFrame);
            URL.append("&fromPage=").append(fromPage);
            URL.append("&openedBy=").append(sMode);
            URL.append("&submitAction=refreshCaller");
            
            URL.append("&updateAction=refreshCaller");

            Enumeration xx = request.getParameterNames();
            while (xx.hasMoreElements())
            {
                String name = (String) xx.nextElement();
                String value = emxGetParameter(request, name);
                URL.append("&"+name+"="+value);
            }

%>
            <script language="Javascript">
                getTopWindow().location.href = "<%=URL.toString()%>";
            </script>
<%            

        }
        
        else if (sMode.equalsIgnoreCase("plmObjectChooser"))
        {
            String hlp = emxGetParameter(request, "HelpMarker");
            String row = emxGetParameter(request, "emxTableRowId");
            String fromPage = emxGetParameter(request, "fromPage");
            String refreshFrame = emxGetParameter(request, "refreshFrame");
            String srcDestRelName = emxGetParameter(request, "srcDestRelName");
            
            String fND = emxGetParameter(request, "fieldNameDisplay");
            String fNA = emxGetParameter(request, "fieldNameActual");
            String frm = emxGetParameter(request, "slmform");
            String sForm = emxGetParameter(request, Search.REQ_PARAM_FORM_NAME);
            String sFrame = emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME);
            String assocType = emxGetParameter(request, "assocType");
            
            String inclusionList = emxGetParameter(request
                , "inclusionList");
            if ( assocType == null )
                assocType = "" ;
            else
                assocType = "&assocType=" + assocType;

            if ( srcDestRelName == null || srcDestRelName.length() == 0 )
            {               
                srcDestRelName = "relationship_SimulationData";
            }
            
            String submitUrl = getSubmitURL(request,oldMode);

            if (objectId != null)
            {
                submitUrl = appendObjectIdParam(submitUrl, objectId);
            }
                

            simBean.loadData(context);
            HashMap cmds;
            cmds = simBean.getAvailablePLMObjectSearchCmds();
            
            String    sCMDs = (String)cmds.get("commands");
            String   sTypes = (String)cmds.get("cmdTypes");
            String[] aTypes = sTypes.split("\\|");
            if ( aTypes.length > 0 )
                sTypes = aTypes[aTypes.length-1];

            sCMDs = sCMDs.replace("|",",");

            String addlSearchCmds = emxGetParameter(request, "searchCmds");
            if ( addlSearchCmds != null && addlSearchCmds.length() > 0 )
                sCMDs = addlSearchCmds + "," + sCMDs;

            // Create URL to forward to
            StringBuffer URL = new StringBuffer(1);
            URL.append("../components/emxCommonSearch.jsp");
            URL.append("?searchmode=chooser");
            URL.append("&formName=").append(sForm);
            URL.append("&frameName=").append(sFrame);
            URL.append("&SubmitURL=").append(getUrlEncodedString(context, submitUrl));          
            URL.append("&form=").append(frm);
            URL.append("&fieldNameDisplay=").append(fND);
            URL.append("&fieldNameActual=").append(fNA);
            URL.append("&suiteKey=SimulationCentral");
            URL.append("&searchmenu=SMASearchContainer");
            URL.append("&searchcommand=" + sCMDs);
            URL.append("&isTo=true");
            URL.append("&selection=multiple");
            URL.append("&srcDestRelName=").append(srcDestRelName);
            URL.append("&suiteKey=Components");
            URL.append("&useSelectedObjectId=true");
            URL.append("&resultsToolbar=SMACommon_SearchResultToolbar");
            URL.append("&emxTableRowId=").append(row);
            URL.append("&HelpMarker=").append(hlp);           
            URL.append("&refreshFrame=").append(refreshFrame);
            URL.append("&fromPage=").append(fromPage);
            URL.append("&openedBy=").append(sMode);


            if ( sTypes.length() > 0 )
                URL.append("&inclusionList=").append(sTypes);

            Enumeration xx = request.getParameterNames();
            while (xx.hasMoreElements())
            {
                String name = (String) xx.nextElement();
                String value = emxGetParameter(request, name);
                URL.append("&"+name+"="+value);
            }

%>
            <script language="Javascript">
                getTopWindow().location.href = "<%=URL.toString()%>";
            </script>
<%
        }

        else if ( sMode.equalsIgnoreCase("addWorkspaceContent") )
        {
            String hlp = emxGetParameter(request, "HelpMarker");
            String row = emxGetParameter(request, "emxTableRowId");
            String fromPage = emxGetParameter(request, "fromPage");
            String refreshFrame = emxGetParameter(request, "refreshFrame");
            String srcDestRelName = emxGetParameter(request, "srcDestRelName");

            if ( srcDestRelName == null || srcDestRelName.length() == 0 )
                srcDestRelName = "relationship_VaultedDocuments";

            simBean.loadData(context);
            HashMap cmds = simBean.getAvailableHomePageSearchCmds();

            String    sCMDs = (String)cmds.get("commands");
            String   sTypes = (String)cmds.get("cmdTypes");
            String[] aTypes = sTypes.split("\\|");
            if ( aTypes.length > 0 )
                sTypes = aTypes[aTypes.length-1];

            sCMDs = sCMDs.replace("|",",");

            String addlSearchCmds = emxGetParameter(request, "searchCmds");
            if ( addlSearchCmds != null && addlSearchCmds.length() > 0 )
                sCMDs = addlSearchCmds + "," + sCMDs;

            // Create URL to forward to
            StringBuffer URL = new StringBuffer(1);
            URL.append("../components/emxCommonSearch.jsp");
            URL.append("?searchmode=addexisting");
            URL.append("&suiteKey=SimulationCentral");
            URL.append("&searchmenu=SMASearchContainer");
            URL.append("&searchcommand=" + sCMDs);
            URL.append("&isTo=true");
            URL.append("&selection=multiple");
            URL.append("&srcDestRelName=").append(srcDestRelName);
            URL.append("&suiteKey=Components");
            URL.append("&useSelectedObjectId=true");
            URL.append("&resultsToolbar=SMACommon_SearchResultToolbar");
            URL.append("&emxTableRowId=").append(row);
            URL.append("&HelpMarker=").append(hlp);
            URL.append("&").append(Search.REQ_PARAM_SUBMIT_URL);
            URL.append("=../simulationcentral/smaContentConnect.jsp");
            URL.append("&refreshFrame=").append(refreshFrame);
            URL.append("&fromPage=").append(fromPage);
            URL.append("&openedBy=").append(sMode);
            if ( sTypes.length() > 0 )
                URL.append("&inclusionList=").append(sTypes);

            Enumeration xx = request.getParameterNames();
            while (xx.hasMoreElements())
            {
                String name = (String) xx.nextElement();
                String value = emxGetParameter(request, name);
                URL.append("&").append(name).append("=").append(value);
            }
%>
            <script language="Javascript">
                getTopWindow().location.href = "<%=URL.toString()%>";
            </script>
<%
        }

        else if ( sMode.equalsIgnoreCase("searchTypeChooser") )
        {
            simBean.loadData(context);

            String inclusionList = emxGetParameter(request,"inclusionList");
            if( inclusionList == null || inclusionList.length() == 0 )
            {
                HashMap cmds = simBean.getAvailableContentPageSearchCmds();

                inclusionList = (String)cmds.get("cmdTypes");
                String[] aTypes = inclusionList.split("\\|");
                if ( aTypes.length > 0 )
                    inclusionList = aTypes[aTypes.length-1];
            }

            StringBuffer URL = new StringBuffer(1);
            URL.append("../common/emxTypeChooser.jsp");
            URL.append("?SelectType=multiselect");
            URL.append("&SelectAbstractTypes=true");

            if ( inclusionList != null && inclusionList.length() > 0 )
                URL.append("&InclusionList=").append(inclusionList);

            Enumeration xx = request.getParameterNames();
            while (xx.hasMoreElements())
            {
                String name = (String) xx.nextElement();
                String value = emxGetParameter(request, name);
                URL.append("&").append(name).append("=").append(value);
            }
%>
            <script language="Javascript">
                getTopWindow().location.href = "<%=URL.toString()%>";
            </script>
<%
        }
        else
        {
%>
            <script language="javascript" type="text/javaScript">
            //<![CDATA[
            var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
            topFrameObj.window.focus();
            parent.closeWindow();
    //            refreshTreeDetailsPage();
             </script>
    <%
        }
    }
    catch (NullPointerException  ex)
    {
        String invalidSearchSelection =
            SimulationUtil.getI18NString(context,
                "Error.Internal.NoSelection" );
            emxNavErrorObject.addMessage(invalidSearchSelection);
    }
    catch (Exception ex)
    {
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>

<%!
/**
 * Checks the specified request for a SubmitURL parameter.  If found,
 * returns the value of that parameter.  Otherwise returns a default
 * submit URL string.
 * @param request The {@link javax.servlet.http.HttpServletRequest} on
 * which to look for a SubmitURL parameter.
 * @param oldMode - String containing original mode if attribute group
 *                  search.  Otherwise it will be empty
 * @return The value of the SubmitURL parameter from the specified
 * request or the default value for this JSP.
 */
private static String getSubmitURL(HttpServletRequest request, String oldMode)
{
    // get the parameter value from the request
    String submitUrlParam = emxGetParameter(request, "SubmitURL");

    if (submitUrlParam != null)
    {
        // return the parameter value
        return submitUrlParam;
    }

    // return the default
    // if oldMode is set for the attribute group search then use new
    // chooser mutiple to support search of multiple attribute groups

    // also supporting multiple attribute groups when creating
    // activity, process or template
    if (oldMode.equalsIgnoreCase("simTypeChooserSearch_Common") ||
        oldMode.equalsIgnoreCase("simTypeChooserSimulationCreate") ||
        oldMode.equalsIgnoreCase("simTypeChooserActivityCreate") ||
        oldMode.equalsIgnoreCase("simTypeChooserAdviseCreate") ||
        oldMode.equalsIgnoreCase("adviseSimulationJobChooser") ||
        oldMode.equalsIgnoreCase("simTypeChooserTemplateCreate") ||
        oldMode.equalsIgnoreCase("hostChooser") ||
        oldMode.equalsIgnoreCase("simTypeChooserSimDocMultiple"))//HL Import Attributes During Execution - PT6
    {
        return "../simulationcentral/smaSearchUtil.jsp?slmmode=chooserMultiple";
    }
    else
        return "../simulationcentral/smaSearchUtil.jsp?slmmode=chooser";
}


/**
 * Appends the specified object ID to the specified URL string as a
 * query parameter and returns the resulting URL string.
 * @param urlString The URL string to which to append the object ID.
 * @param objectId The object ID value to append to the URL.
 * @return The URL string with the object ID added to the query string
 * as a parameter.
 */
private static String appendObjectIdParam(
    String urlString, String objectId)
{
    // create a buffer
    StringBuilder buf = new StringBuilder(urlString);

    // if this is the first query parameter start the query string
    if (buf.indexOf("?") == -1)
    {
        buf.append('?');
    }
    // not the first query parameter => continue the query string
    else
    {
        buf.append('&');
    }

    // add the OID as a query parameter
    return buf.append("objectId=").append(objectId).toString();
}


 /**
 *  Returns the URL-encoded version of the specified string.
 *  @param context
 *  @param StringsToencode
 *  @returns The URL-encoded string
 *  Changed method from previous because of the new method from BPS side
 */
 private static String getUrlEncodedString(
     Context context , String rawString)
 throws UnsupportedEncodingException
 {
     return XSSUtil.encodeForURL(context,rawString);
 }


/**
 * Array of type constants that are searchable from this JSP.
 * <br><br>
 * These types are processed in the order in which they occur.  For
 * this JSP to behave properly, sub-types MUST occur in the array
 * prior to ANY of their super-types.
 */
private static final String[] TYPE_STRINGS =
    new String[]
    {
        SimulationConstants.SYMBOLIC_type_Simulation,
        SimulationConstants.SYMBOLIC_type_SimulationActivity,
        SimulationConstants.SYMBOLIC_type_SimulationTemplate,
        SimulationConstants.SYMBOLIC_type_SimulationDocument,
        SimulationConstants.SYMBOLIC_type_AnalyticsCase
    };

/**
 * Map of type constants to ViewEdit chooser names.
 */
private static final Map VIEW_EDIT_CHOOSER_MAP;

/**
 * Map of type constants to Search chooser names.
 */
private static final Map SEARCH_CHOOSER_MAP;

/**
 * Initialize the chooser maps.
 */
static
{
    VIEW_EDIT_CHOOSER_MAP = new HashMap();
    VIEW_EDIT_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_Simulation,
        "simTypeChooserSimulationViewEdit");
    VIEW_EDIT_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationActivity,
        "simTypeChooserActivityViewEdit");
    VIEW_EDIT_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationTemplate,
        "simTypeChooserTemplateViewEdit");
    VIEW_EDIT_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationDocument,
        "simTypeChooserSimDoc");
    //HL Import Attributes During Execution - PT6
    VIEW_EDIT_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationDocument,
        "simTypeChooserSimDocMultiple");
    VIEW_EDIT_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_AnalyticsCase,
        "simTypeChooserAnalyticsCaseViewEdit");
    

    SEARCH_CHOOSER_MAP = new HashMap();
    SEARCH_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_Simulation,
        "simTypeChooserSimulationSearch");
    SEARCH_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationActivity,
        "simTypeChooserActivitySearch");
    SEARCH_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationTemplate,
        "simTypeChooserTemplateSearch");
    SEARCH_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationDocument,
        "simTypeChooserSimDoc");
    //HL Import Attributes During Execution - PT6
    SEARCH_CHOOSER_MAP.put(
        SimulationConstants.SYMBOLIC_type_SimulationDocument,
        "simTypeChooserSimDocMultiple");

}


/**
 * @return The correct ViewEdit chooser for the type of the object
 * with the specified object ID.
 */
private static String getViewEditChooserForType(
        Context context, String objectId)
    throws Exception
{
    return getViewEditChooserForType(
        getKindOfTypeString(context, objectId));
}


/**
 * @return The correct ViewEdit chooser for the specified object type.
 */
private static String getViewEditChooserForType(
        String typeString)
    throws Exception
{
    if (typeString != null)
    {
        return (String) VIEW_EDIT_CHOOSER_MAP.get(typeString);
    }

    return null;
}


/**
 * @return The correct Search chooser for the type of the object
 * with the specified object ID.
 */
private static String getSearchChooserForType(
        Context context, String objectId)
    throws Exception
{
    return getSearchChooserForType(
        getKindOfTypeString(context, objectId));
}


/**
 * @return The correct Search chooser for the specified object type.
 */
private static String getSearchChooserForType(String typeString)
{
    if (typeString != null)
    {
        return (String) SEARCH_CHOOSER_MAP.get(typeString);
    }

    return null;
}


/**
 * @return The correct chooser from the specified Map for the type of
 * the object with the specified object ID.
 */
private static String getChooserForTypeFromMap(
        Context context, String objectId, final Map CHOOSER_MAP)
    throws Exception
{
    final String TYPE_STRING = getKindOfTypeString(context, objectId);

    if (TYPE_STRING != null)
    {
        return (String) CHOOSER_MAP.get(TYPE_STRING);
    }

    return null;
}


/**
 * @return The correct value from the TYPE_STRINGS array for the type
 * of the object with the specified object ID.
 */
private static String getKindOfTypeString(
        Context context, String objectId)
    throws Exception
{
    if (objectId == null)
    {
        return null;
    }

    Map argsMap = new HashMap();
    argsMap.put("objectId", objectId);
    argsMap.put("typeStrings", TYPE_STRINGS);

    // get the kind-of flags for all of the types
    Map kindOfMap = (Map) JPO.invoke(
        context,
        "jpo.simulation.SimulationUI",
        null,
        "isKindOf",
        JPO.packArgs(argsMap),
        Map.class);

    // iterate over all the types
    for (int i = 0; i < TYPE_STRINGS.length; ++i)
    {
        // check to see if the object is of the current type
        String typeString = TYPE_STRINGS[i];
        Boolean isKindOfFlag = (Boolean) kindOfMap.get(typeString);

        if (Boolean.TRUE.equals(isKindOfFlag))
        {
            // if so, return the current type
            return typeString;
        }
    }

    // no match
    return null;
}
%>
