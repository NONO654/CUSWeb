<%--
  SpecificationStructureUtil.jsp

  Performs actions that modify the Specification Structure.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
 --%>
 
<%-- @quickreview	XXXX	XXXX	YY:MM:DD	COMMENT %-->
<%-- @quickreview	OEP		QYG		12:08:24	IR-174856V6R2013x- "Raise EC" and "Attach to EC" commands could not handle large 
 											    number of objects. If user have selected 1000+ objects and click on "Raise EC" command, 
 											    code tries to print out all the object names on the dialog url, because of url length limitation 
 											    on the IE browser there is not enough space to display all of this on browser.--%>
<%-- @quickreview 	LX6		QYG		12:11:29 	When a disconnect is done on structure, synchronize sequence Order and refresh table  	--%>
<%-- @quickreview 	QYG				13:09:03	IR-234284V6R2014x: for disconnect, only refresh the page once after all objects are removed from the UI.--%>										
<%-- @quickreview 	T25 	OEP 	12:12:10 	HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
<%-- @quickreview 	T25 	DJH 	12:12:12 	Solved merge with Louis' code --%>
<%-- @quickreview 	T25 	OEP 	12:12:18 	HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included --%>
<%-- @quickreview 	LX6 	QYG 	13:03:19 	UI enhancement display a simplified form depending on settings--%>
<%-- @quickreview 	DJH 	DJH 	13:04:23 	Correction REG IR-228533V6R2014, IR-228531V6R2014. Add Suite name in URL in else if ("Creation".equals(strMode)) block--%>
<%-- @quickreview 	ZUD 	DJH 	13:06:14 	Correction IR-232692V6R2014x 	The Page does not refresh, Requirement is displayed in spite of removing -%>
<%-- @quickreview 	T25 	DJH 	13:10:18 	HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc code is included. -%>
<%-- @quickreview 	HAT1	ZUD 	14:06:03 	Correction IR-274607V6R2015. STP: in Requirement, Creating Requirement Specification from category "Specification" in Requirement is KO. -%>
<%-- @quickreview 	LX6      		14:11:25 	Don't display derived requirements on creation in table --%>
<%-- @quickreview 	KIE1 	ZUD 	15:02:24 	HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%-- @quickreview 	LX6      		15:04:01 	FUN054695 ENOVIA GOV TRM Revision refactoring. --%>
<%-- @quickreview 	JX5      		15:06:11 	Autoname Checked by Default --%>
<%-- @quickreview 	QYG      		15:06:24 	IR-366442-3DEXPERIENCER2016x fix button labels on create form --%>
<%-- @quickreview 	LX6	   			15:07:20 	ENOVIA GOV TRM Revision refactoring  --%>
<%-- @quickreview 	KIE1 	ZUD 	16:11:15 	IR-407482-3DEXPERIENCER2017x : An operator will not notice if he/she successfully adds a Sub/Derived Requirement  --%>
<%-- @quickreview 	ZUD 			16:03:09 	IR-416285-3DEXPERIENCER2017x : R418-STP: In customized type of objects "Use case" is not working Properly, & "Specification folder, Taste case & Test execution" types are not present. --%>
<%-- @quickreview 	JX5  	QYG 	16:05:02 	Move reconciliation services to REQModeler %--> 
<%-- @quickreview 	HAT1 	ZUD 	16:05:03 	Populating title as per autoName of Name in Web form.   --%>
<%-- @quickreview 	HAT1 	ZUD 	16:05:17  	IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated. --%>
<%-- @quickreview HAT1 ZUD 16:06:01 : IR-445639-3DEXPERIENCER2017x: R419-STP: "Autoname" check box is not available on Creation form of Requirement objects. --%>
<%-- @quickreview KIE1 ZUD 16:11:04 : IR-475850-3DEXPERIENCER2018x: R419-FUN055837: Unnecessary Requirement object is getting created, after error message object type name revision not unique on creation form. --%>
<%-- @quickreview KIE1 ZUD 16:12:14 : R419-UX: Improper header for Create Requirement Specification, Requirement, Chapter, comment slideIn. --%>
<%-- @quickreview KIE1 ZUD 17:03:09 :IR-501206-3DEXPERIENCER2017x: R420-STP: Irrelevant options are shown on Req. Specification creation page, when created under Specification folder.--%>
<%-- @quickreview HAT1 ZUD 17:03:29 : IR-508271-3DEXPERIENCER2018x: R419-STP: After object creation, Auto refresh list view page is KO.  --%>
<%-- @quickreview   HAT1    ZUD     17:11:24 : IR-555094-3DEXPERIENCER2018x: Create a ReqSpec with a custom policy. --%>

<%-- Common Includes --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc" %>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import="com.matrixone.apps.requirements.RequirementsConstants"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import="com.dassault_systemes.i3dx.changelog.Userfact"%>
<%@page import="com.dassault_systemes.i3dx.changelog.Userfact.UserFactType"%>
<%@page import="com.dassault_systemes.requirements.reconciliation.ILReconciliationServices"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%@page import="com.dassault_systemes.requirements.ReplaceServices"%>
<%@page import="com.dassault_systemes.requirements.ReqServices"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<html>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
	<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
	
<%
String strMode = emxGetParameter(request,"mode");
if("disconnect".equalsIgnoreCase(strMode) || "delete".equalsIgnoreCase(strMode))
{
%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
}
/*
* @quickreview LX6 QYG 12:07:30 (IR-182432R2013x "STP : Sub Requirement Add under Released Requirement is allowed from RFLP Navigator. ")
* @quickreview LX6 QYG 12:08:24(IR-123051V6R2013x  "FIR : No message on invoking invalid commands for Group in list view. ")
* @quickreview LX6 QYG 14 Nov 12("Enhancement of import Existing Structure performance")
*/

//Start:IR:1230516R2013x:LX6
  boolean bFlag=false;
  try
  {
//Start:IR:1230516R2013x:LX6
		boolean bIsFromRichTextEditor = "true".equalsIgnoreCase(emxGetParameter(request,"isRTE")) ? true: false;
     String strObjectId = emxGetParameter(request, "objectId");
     boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request,"isFromRMB"));
     String emxTableRowId = emxGetParameter(request, "emxTableRowId");
     
        
		if (strObjectId == null) {
		    strObjectId = "";
		}
        // Extract Table Row ids of the checkboxes selected.
        String[] arrRowIds = emxGetParameterValues(request, "emxTableRowId");
        
        if (arrRowIds == null || arrRowIds.length == 0)
        {
            arrRowIds = new String[1];
            arrRowIds[0] = strObjectId;
        }

        // Extract the Object ids of the Objects to be processed...
        boolean bIsFromTree = (arrRowIds[0].indexOf("|") >= 0);
        String[] arrRelIds = (bIsFromTree? new String[arrRowIds.length]: arrRowIds);
        String[] arrObjIds = (bIsFromTree? new String[arrRowIds.length]: arrRowIds);

        if (bIsFromTree)
        {
            for (int ii = 0; ii < arrRowIds.length; ii++)
            {
                String[] tokens = arrRowIds[ii].split("[|]");
                arrRelIds[ii] = (tokens.length > 1? tokens[0]: "");
                arrObjIds[ii] = (tokens.length > 1? tokens[1]: tokens[0]);
            }
        }

        if (strMode.equalsIgnoreCase("delete"))
        {
            // Ensure that the parent object has fromdisconnect access...
            DomainObject rootObject = DomainObject.newInstance(context, strObjectId);
            String disConnect = rootObject.getInfo(context, "current.access[fromdisconnect]");
            if (! disConnect.equalsIgnoreCase("TRUE"))
            {
               throw(new MatrixException("DisconnectAccessRestricted"));
            }

            //Invoke the JPO method
            JPO.invoke(context, "emxSpecificationStructure", null, "commandDeleteTree", arrRowIds, HashMap.class);

            if (bIsFromTree)
            {
%>
    <script language="javascript" type="text/javaScript">
<%
                // Loop for refreshing the tree
                for (int ii = 0; ii < arrObjIds.length; ii++)
                {
%>
      <!-- hide JavaScript from non-JavaScript browsers -->
      //<![CDATA[
      	if(getTopWindow().trees){
        	var tree = getTopWindow().trees['emxUIDetailsTree'];
        	tree.deleteObject("<xss:encodeForJavaScript><%=arrObjIds[ii]%></xss:encodeForJavaScript>");
        }
      //]]>
<%
			if(bIsFromRichTextEditor){
%>
	  			getTopWindow().deleteObject("<xss:encodeForJavaScript><%=arrObjIds[ii]%></xss:encodeForJavaScript>");
<%            		}
                }
%>
      <!-- hide JavaScript from non-JavaScript browsers -->
      //<![CDATA[
        refreshTreeDetailsPage();
      //]]>
    </script>
<%
            }
            else
            {
%>
    <script language="javascript" type="text/javaScript">
      <!-- hide JavaScript from non-JavaScript browsers -->
      //<![CDATA[
        refreshContentPage();
      //]]>
    </script>
<%
            }
        }

        else if (strMode.equalsIgnoreCase("disconnect"))
        {
        	String isUserAgent = EnoviaResourceBundle.getProperty(context, "emxRequirement.contextUser.UserAgent");
    		if("true".equalsIgnoreCase(isUserAgent))
    		{
    			ContextUtil.pushContext(context);	
    		}
            //returns true in case of successful disconnect.
            boolean bRemove = false;

            // Ensure that the parent object has fromdisconnect access...
            DomainObject rootObject = DomainObject.newInstance(context, strObjectId);
            String disConnect = rootObject.getInfo(context, "current.access[fromdisconnect]");
            if (! disConnect.equalsIgnoreCase("TRUE"))
            {
               throw(new MatrixException("DisconnectAccessRestricted"));
            }
%>
    <script language="javascript" type="text/javaScript">
      <!-- hide JavaScript from non-JavaScript browsers -->
      //<![CDATA[
	    function getTableRowIds(win, objectId, relId){
	        var checkboxArray = new Array();
	        if(relId == null || relId == "null") relId = "";
	        var aRowsSelected = emxUICore.selectNodes(win.oXML,"/mxRoot/rows//r[@o='" + objectId + "' and @r='" + relId + "']");
	        var chkLen = aRowsSelected.length;
	        for(var j = 0; j < chkLen; j++){
	           var id = aRowsSelected[j].getAttribute("id");
	           var oid = aRowsSelected[j].getAttribute("o");
	           var relid = aRowsSelected[j].getAttribute("r");
	           if (relid == null || relid == "null") {
	              relid = "";
	           }
	           var parentId = aRowsSelected[j].getAttribute("p");
	           if (parentId == null || parentId == "null") {
	              parentId = "";
	           }
	           var totalRowInfo = relid + "|" + oid + "|" + parentId + "|" + id;
	           checkboxArray[checkboxArray.length] = totalRowInfo;
	        }
	        return checkboxArray;
	    }
	    var cBoxArray;
<%
			try{
	            // Loop for refreshing the tree
	            for (int ii = 0; ii < arrRelIds.length; ii++)
	            {
	                // Check for a root node: Disconnect is not applicable...
	                if (arrRelIds[ii].length() == 0)
	                {
%>      
						alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, emxGetParameter(request, "StringResourceFileId"), context.getLocale(), "emxRequirements.Alert.SpecificationRemoveRoot")%></xss:encodeForJavaScript>");
<%                  	continue;
	                }

	                DomainRelationship.disconnect(context, arrRelIds[ii]);
%>
			      	if(getTopWindow().trees){
			        	var tree = getTopWindow().trees['emxUIDetailsTree'];
			        	if(tree.getSelectedNode())
			        	{
			        		tree.getSelectedNode().removeChild("<xss:encodeForJavaScript><%=arrObjIds[ii]%></xss:encodeForJavaScript>");
			        	}
			        }
<%					if(bIsFromRichTextEditor){ %>
	  					parent.removeRelationship("<xss:encodeForJavaScript><%=arrRelIds[ii]%></xss:encodeForJavaScript>", "<xss:encodeForJavaScript><%=arrObjIds[ii]%></xss:encodeForJavaScript>");
	  					if(parent.oXML){
							cBoxArray = getTableRowIds(parent, "<xss:encodeForJavaScript><%=arrObjIds[ii]%></xss:encodeForJavaScript>", "<xss:encodeForJavaScript><%=arrRelIds[ii]%></xss:encodeForJavaScript>");
							parent.emxEditableTable.removeRowsSelected(cBoxArray);
	  					}
<%            		} else{ %>
						cBoxArray = getTableRowIds(parent, "<xss:encodeForJavaScript><%=arrObjIds[ii]%></xss:encodeForJavaScript>", "<xss:encodeForJavaScript><%=arrRelIds[ii]%></xss:encodeForJavaScript>");
						parent.emxEditableTable.removeRowsSelected(cBoxArray);
						
						// ++ HAT1 ZUD: IR-604654-3DEXPERIENCER2019x ++
						if(parent.parent && parent.parent.emxEditableTable) 
						{
							var locURL = parent.window.location.href; 
							var isParentSubReqWindow = false;
							
							if(locURL.includes("getUpDirectionSubRequirements"))
								isParentSubReqWindow = true;
							
							if(isParentSubReqWindow)
							{
								cBoxArray = getTableRowIds(parent.parent, "<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>", "<xss:encodeForJavaScript><%=arrRelIds[ii]%></xss:encodeForJavaScript>");
							}
							else
							{
								cBoxArray = getTableRowIds(parent.parent, "<xss:encodeForJavaScript><%=arrObjIds[ii]%></xss:encodeForJavaScript>", "<xss:encodeForJavaScript><%=arrRelIds[ii]%></xss:encodeForJavaScript>");
							}
							parent.parent.emxEditableTable.removeRowsSelected(cBoxArray);
						}
						// -- HAT1 ZUD: IR-604654-3DEXPERIENCER2019x --
<%					}
	            }
	      //START LX6 IR-191273V6R2014 synchronize Seq Order and Refresh on Disconnect
        //Synchronize Sequence Order attribute
        String[] emxTableRowIdActual = emxGetParameterValues(request, "emxTableRowId");
        Map ParentsMap = new HashMap();
          for(int i=0;i<emxTableRowIdActual.length;i++)
        {
          //put all parents Id in a Map
          String ParentId = emxTableRowIdActual[i].split("[|]")[2];
          DomainObject ParentObject = DomainObject.newInstance(context, ParentId);
          if((ParentObject.exists(context))&&(!ParentsMap.containsKey(ParentId)))
          {
          //Do a 1 level synchronization 
          String relTypes = ReqSchemaUtil.getSpecStructureRelationship(context) + "," +
             ReqSchemaUtil.getSubRequirementRelationship(context) + "," +
             ReqSchemaUtil.getDerivedRequirementRelationship(context);
          SpecificationStructure.normalizeSequenceOrderMultiRelationship(context, ParentObject, relTypes);
          ParentsMap.put(ParentId,"value");
          }
        }     
%>
        //Refresh the table
				if(parent.emxEditableTable)
				{
				    if(parent.emxEditableTable.isRichTextEditor)
				     {
				         parent.refreshSCE();//structure content editor SCE
				     }
				     else
				     {
				         parent.emxEditableTable.refreshStructureWithOutSort();   // Structure Browser
				     }
				 }                   
				 else
				 {
				     parent.location.href = parent.location.href;
				 }
<%
        //END LX6 IR-191273V6R2014 synchronize Seq Order and Refresh on Disconnect
				if(bIsFromRichTextEditor){
%>					<jsp:useBean id="richtextTableBean" class="com.matrixone.apps.requirements.ui.UITableRichText" scope="session" />
<%					String timeStamp = emxGetParameter(request, "timeStamp"); 
					richtextTableBean.expireObjectList(timeStamp); //clear object list for filtering
				}
            }finally{
%>
      //]]>

		// ZUD Fix IR-232692V6R2014x refresh Structure tree
    	refreshStructureTree();
    	
    </script>
<%
			}

			if("true".equalsIgnoreCase(isUserAgent))
			{
				ContextUtil.popContext(context);	
			}
        }
        else if("ensureSpecStructureSelection".equalsIgnoreCase(strMode))
        {
        	String[] items = emxTableRowId.split("[|]", -1);
        	String oid = items[1];
        	String pid = items[2];
        	// START:LX6 import structure performance improvement
        	if(RequirementsUtil.isRequirement(context, oid) && 
        			(pid.trim().length() == 0 || RequirementsUtil.isRequirement(context, pid)) || RequirementsUtil.isParameter(context, oid))
        	{
        		throw new Exception("InvalidSpecTreeSelection");
        	}
        	// END:LX6 import structure performance improvement
        	String command = emxGetParameter(request,"command");
        	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
        	String strLanguage = request.getHeader("Accept-Language");
        	Map commandMap = UIToolbar.getCommand(context, command);
        	String targetLocation = (String)((Map)commandMap.get("settings")).get("Target Location");
        	String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
          	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
          		autonameChecked = "true";
          	}
	    		String href = (String)commandMap.get("href");
	    		href = UINavigatorUtil.parseHREF(context,href, "Requirements");
	    		href += "&nameField=program&suiteKey=Requirements&SuiteDirectory=requirements&StringResourceFileId=emxRequirementsStringResource&targetLocation=slidein&emxTableRowId=" + emxTableRowId + (isFromRMB ? "&isFromRMB=true" : "");
//START LX6
	    		//Check if we must display the simplified creation form
	    		String isSimplifiedForm = EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm");
	    		if(isSimplifiedForm == null || "".equals(isSimplifiedForm) || "false".equals(isSimplifiedForm))
	    		{
	    			href += "&vaultChooser=true";
	    			href += "&typeChooser=true";
	    		}
	    		else
	    		{
	    			href += "&vaultChooser=false";
	    			href += "&typeChooser=false";
	    			if(href.contains("type_Chapter"))
	    			{
	  	        		href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&slideInMode=refreshSlideInFrame";
	    				String ChapterPolicy = PropertyUtil.getSchemaProperty(context,
	    						ReqServices.getCustomDefaultPolicy(context, PropertyUtil.getSchemaProperty(context,"type_Chapter"))
	    						);
	    				
	    				href += "&Policy="+ChapterPolicy;
	    				

	    				href += "&type="+ReqSchemaUtil.getChapterType(context);
	    			}
	    			if(href.contains("type=type_Comment"))
	         		 {
	  	        		href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&slideInMode=refreshSlideInFrame";
	    				String CommentPolicy =  PropertyUtil.getSchemaProperty(context,
	    	    						ReqServices.getCustomDefaultPolicy(context, PropertyUtil.getSchemaProperty(context,"type_Comment"))
	    	    						);
	            		href += "&Policy="+CommentPolicy;
	            		href += "&type="+ReqSchemaUtil.getCommentType(context);
	         		 }
	    			if(href.contains("type=type_Requirement"))
            		{
	  	        		href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&slideInMode=refreshSlideInFrame";
	    				String RequirementPolicy =  PropertyUtil.getSchemaProperty(context,
	    	    						ReqServices.getCustomDefaultPolicy(context, PropertyUtil.getSchemaProperty(context,"type_Requirement"))
	    	    						);
              			href += "&Policy="+RequirementPolicy;
              			href += "&type="+ReqSchemaUtil.getRequirementType(context);
            		}
	    		}
//END LX6	    		
%>
		        <script src="../webapps/AmdLoader/AmdLoader.js"></script>
		        <script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
		        <script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
				<SCRIPT language="JavaScript">
				require(['DS/ENORMTCustoSB/panelRightContext'], function(){
					var detailsFrame = findFrame(getTopWindow(),'detailsDisplay');
					if(detailsFrame!=null){
						var dashboardSlideIn = $('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document);
						if(dashboardSlideIn.is(':visible')==true){
							closePanel();
						}
					}
				});
				if(<xss:encodeForJavaScript><%="slidein".equalsIgnoreCase(targetLocation)%></xss:encodeForJavaScript>)
				{
					getTopWindow().showSlideInDialog("<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>", true, window.name,"",550);
				}
				else
				{
					showNonModalDialog("<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>");
				}
				</SCRIPT>
<%    		
    		//response.sendRedirect(href);
    		return;
        }

        //Start V6R2010xHF1
        else if ("EnsureSourceReqForNewSubReq".equals(strMode) || "EnsureSourceReqForNewDerivedReq".equals(strMode)) 
        {
            String strSourceObjectId = arrObjIds[0];
            
            // ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy. ++
			BusinessObject busObj = new BusinessObject(strSourceObjectId);
			busObj.open(context);
        	String objType = busObj.getTypeName();
        	busObj.close(context);
            
            if (objType.equalsIgnoreCase("Requirement Proxy")) 
            {
        		throw new Exception("SelectReqOrSubRequirementOnly");
            }
            // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 
            else if (!RequirementsUtil.isRequirement(context, strSourceObjectId)) 
            {
        		throw new Exception("SelectRequirementOnly");
            }
            else 
            {
        		String strRelSymName = ("EnsureSourceReqForNewSubReq".equals(strMode))?"relationship_RequirementBreakdown":"relationship_DerivedRequirement";
%>
		        <script src="../webapps/AmdLoader/AmdLoader.js"></script>
		        <script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
		        <script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
				<SCRIPT language="JavaScript">
				require(['DS/ENORMTCustoSB/panelRightContext'], function(){
					var dashboardSlideIn = $('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document);
					if(dashboardSlideIn.is(':visible')==true){
						closePanel();
					}
				});
<%
				if (isFromRMB) {
%>				
					 //window.parent.autoCheckRow("<!%=emxTableRowId%>");
<%
				}
		DomainObject bo = DomainObject.newInstance(context, strSourceObjectId);
		State curState = bo.getCurrentState(context);
		String strState = curState.getName();

		if(strState.equals("Release") || strState.equals("Obsolete"))
		{
		  throw new Exception("modifyReleaseObsoleteState");
		}	
		else
		{
//START LX6			
			String isSimplifiedForm = EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm");
			String valueToAdd = "";
       if(isSimplifiedForm == null || "".equals(isSimplifiedForm) || "false".equals(isSimplifiedForm))
       {
    	   valueToAdd = "&vaultChooser=true";
       }
       else
       {
    	   
    	   String RequirementPolicy =  PropertyUtil.getSchemaProperty(context,
					ReqServices.getCustomDefaultPolicy(context, PropertyUtil.getSchemaProperty(context,"type_Requirement"))
					);
    	   valueToAdd = "&Policy="+RequirementPolicy;
       }
       boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
       String csrfTokenName = "";
       String csrfTokenValue = "";
       if(csrfEnabled)
       {
       	Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
       	csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
       	csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
       }
       System.out.println("CSRFINJECTION");
       String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
     	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
     		autonameChecked = "true";
     	}
     	//HAT1 ZUD Populating title as per autoName of Name in Web form.
%>
					var strDialogUrl = "../common/emxCreate.jsp?type=type_Requirement"+"<%=valueToAdd%>"+"&typeChooser=true&nameField=program&form=RMTSpecTreeCreateNewRequirement&header=emxRequirements.Heading.CreateRequirement&HelpMarker=emxhelpnewsubderivedreqcreate&suiteKey=Requirements&showApply=true&isChildCreation=true&submitAction=xmlMessage&postProcessURL=../requirements/CreateProcess.jsp&slideInMode=refreshSlideInFrame&objectCompare=false&showClipboard=false&operation=SpecStructureNewSubDerivedReq&direction=From"+
												"&createProcessJPO=emxSpecificationStructure:postCreateSetSequenceOrder&subMode="  <%--XSSOK--%>
												+ "<xss:encodeForJavaScript><%="EnsureSourceReqForNewSubReq".equals(strMode) ? "ForSubRequirement" : "ForDerivedRequirement"%></xss:encodeForJavaScript>" + "&emxTableRowId=" + "<xss:encodeForJavaScript><%=emxTableRowId%></xss:encodeForJavaScript>" + "&windowMode=slidein" + (<xss:encodeForJavaScript><%=isFromRMB%></xss:encodeForJavaScript>? "&isFromRMB=true" : "")+"<%=csrfEnabled ? ("&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "= " + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue ) : ""%>";
					getTopWindow().showSlideInDialog(strDialogUrl, true, window.name,"",550);
				</SCRIPT>
<%
//END LX6
	}
            }
        }   
        else if ("EnsureSourceReqForAddExistingSubDerivedReq".equals(strMode)) 
        {
        	// Start:IR:182432V6R2013x:LX6
        	
        	//String strObjectId = emxGetParameter(request, "objectId");   
        	DomainObject bo = DomainObject.newInstance(context, strObjectId);
        	State curState = bo.getCurrentState(context);
        	String strState = curState.getName();

        	if(strState.equals("Release") || strState.equals("Obsolete"))
        	{
        	    throw new Exception("modifyReleaseObsoleteState");
        	}
          String strSourceObjectId = arrObjIds[0];
          	
          	// ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy. ++
			BusinessObject busObj = new BusinessObject(strSourceObjectId);
			busObj.open(context);
      		String objType = busObj.getTypeName();
      		busObj.close(context);
          
          if (objType.equalsIgnoreCase("Requirement Proxy")) 
          {
      		throw new Exception("SelectReqOrSubRequirementOnly");
          }
          // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 
          
          if (!RequirementsUtil.isRequirement(context, strSourceObjectId)) 
          {
      		throw new Exception("SelectRequirementOnly");
          }
          else 
          {
%>
				<SCRIPT language="JavaScript">
<%
				if (isFromRMB) {
%>				
					window.parent.autoCheckRow("<xss:encodeForJavaScript><%=emxTableRowId%></xss:encodeForJavaScript>");
<%
				}
					 boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
					    String csrfTokenName = "";
					    String csrfTokenValue = "";
					    if(csrfEnabled)
					    {
					    	Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
					    	csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
					    	csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
					    }
				if(emxGetParameter(request, "command")==null)
				{
					
					    System.out.println("CSRFINJECTION");
%>				    
					var strUrl = "../requirements/SpecificationStructureAddExisting.jsp?toolbar=none&editLink=false&addType=SubDerivedRequirement&emxTableRowId=<xss:encodeForJavaScript><%=emxTableRowId%></xss:encodeForJavaScript>" +
					"<%=csrfEnabled ? ("&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "= " + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue ) : ""%>";<%--XSSOK--%>
					window.location.href = strUrl;
				</SCRIPT>
<%        
				}
				else
				{
					  String command = emxGetParameter(request, "command");
					  HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
					  String strLanguage = request.getHeader("Accept-Language");
					  Map commandMap = UIToolbar.getCommand(context, command);
					  String targetLocation = (String)((Map)commandMap.get("settings")).get("Target Location");
					  String href = (String)commandMap.get("href");
					  href = UINavigatorUtil.parseHREF(context,href, "Requirements");
					  href += "&suiteKey=Requirements&Submit=true&SuiteDirectory=requirements&emxTableRowId=" + emxTableRowId +
							  (csrfEnabled ? ("&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "= " + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue ) : "");
					  %>
         
        if(<xss:encodeForJavaScript><%="slidein".equalsIgnoreCase(targetLocation)%></xss:encodeForJavaScript>)
        {
          getTopWindow().showSlideInDialog("<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>", true, window.name,"",550);
        }
        else
        {
          window.location = "<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>";
        }
        </SCRIPT>
        <%
				} 
            }
        }
        // End:IR:182432V6R2013x:LX6
        // Start:IR:123051V6R2013x:LX6
        else if ("RMTStructureCompare".equals(strMode))
        {
        	  String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
            boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,tableRowIds);
            if(isRequirementGroupInList == true)
            {
              throw new Exception("invalidForReqGroup");
            }
            HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
            String strLanguage = request.getHeader("Accept-Language");
            Map commandMap = UIToolbar.getCommand(context, strMode);
            //String targetLocation = (String)((Map)commandMap.get("settings")).get("Target Location");
            String href = (String)commandMap.get("href");
            href = UINavigatorUtil.parseHREF(context,href, "Requirements");
            href += "&suiteKey=Requirements&Submit=true&SuiteDirectory=requirements&emxTableRowId=" + emxTableRowId;
%>
            <SCRIPT language="JavaScript">
              window.location = "<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>";
            </SCRIPT>
<%
        }
        else if("RMTCreateRevisionRequirementActionLink".equals(strMode))
        {
        	String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
            boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,tableRowIds);
            if(isRequirementGroupInList == true)
            {
              throw new Exception("invalidForReqGroup");
            }
            HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
            String strLanguage = request.getHeader("Accept-Language");
            Map commandMap = UIToolbar.getCommand(context, strMode);
            //String targetLocation = (String)((Map)commandMap.get("settings")).get("Target Location");
            String href = (String)commandMap.get("href");
            href = UINavigatorUtil.parseHREF(context,href, "Requirements");
            href += "&suiteKey=Requirements&Submit=true&SuiteDirectory=requirements&emxTableRowId=" + emxTableRowId;
%>
            <SCRIPT language="JavaScript">
                getTopWindow().showSlideInDialog("<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>", true);
            </SCRIPT>
<%
        }
        else if ("APPSubscriptionMultiObject".equals(strMode))
        {
        	String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
          boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,tableRowIds);
          if(isRequirementGroupInList == true)
          {
            throw new Exception("invalidForReqGroup");
          }
          HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
          String strLanguage = request.getHeader("Accept-Language");
          Map commandMap = UIToolbar.getCommand(context, strMode);
          //String targetLocation = (String)((Map)commandMap.get("settings")).get("Target Location");
          String href = (String)commandMap.get("href");
          href = UINavigatorUtil.parseHREF(context,href, "Requirements");
          href += "&suiteKey=Requirements&Submit=true&SuiteDirectory=requirements&emxTableRowId=" + emxTableRowId;
%>
          <SCRIPT language="JavaScript">
            showNonModalDialog("<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>");
          </SCRIPT>
<%
        }
        // End:IR:123051V6R2013x:LX6
        else if ("PreEnsureSourceTargetSelection".equals(strMode)) 
        {
            //System.out.println("DEBUG: PreEnsureSourceTargerSelection");
            String strSubMode = emxGetParameter(request,"subMode");
            String strOperation = emxGetParameter(request,"operation");
            String strSubOperation = emxGetParameter(request,"subOperation");
            
%>
			<form name="FormPreEnsureSourceTargetSelection" action="SpecificationStructureUtil.jsp" method="POST">
			<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
				<input type="text" name="mode"          value="EnsureSourceTargetSelection" />
				<input type="text" name="subMode" value="<xss:encodeForHTMLAttribute><%=strSubMode %></xss:encodeForHTMLAttribute>" />
				<input type="text" name="operation" value="<xss:encodeForHTMLAttribute><%=strOperation %></xss:encodeForHTMLAttribute>" />
				<input type="text" name="subOperation" value="<xss:encodeForHTMLAttribute><%=strSubOperation %></xss:encodeForHTMLAttribute>" />
				<input type="text" name="sourceIds"     value="" />
				<input type="text" name="targetIds"     value="" />
			</form>
			<script language="JavaScript">
				function adjustRelId(emxTableRowId)
				{
					var strObjId = "";
					if (emxTableRowId)
					{
						var tokens = emxTableRowId.split('|');
						if (tokens[0] == "") {
							emxTableRowId = "dummyRelId" + emxTableRowId;
							//
							// For selection of root objects e.g. specification object there is no rel id
							// we put there dummy value for the further processing
							//
						}
					}
					return emxTableRowId;
				}
				function convertToCommaSeparatedIds (objCheckboxes) 
				{
					var strIds = "";
    	       		var emxTableRowId = "";					
			        for(var p in objCheckboxes) {
			        	if (strIds.length != 0) {
			        		strIds += "!";
			        	}
			        	emxTableRowId = objCheckboxes[p];
			        	strIds += adjustRelId(emxTableRowId);
			        }
			        return strIds;
    	       }
    	       
				function findAndSubmitSourceTargetSelection() {
			        // Find the target object selection
			        var targetCheckboxes = window.parent.getCheckedCheckboxes();
			        
			        // Find the source object selection
			        var sourceCheckboxes = null;	
			        try 
			        {
				//KIE1 ZUD TSK447636 
			        	if (window.getTopWindow().getWindowOpener().parent.getCheckedCheckboxes) 
			        	{
			         		sourceCheckboxes = window.getTopWindow().getWindowOpener().parent.getCheckedCheckboxes();
			         	}
			         	else {
			         		//For SCE
			         		if (window.getTopWindow().getWindowOpener().parent.document.forms["emxTableForm"])
			         		{
			         			var objForm = window.getTopWindow().getWindowOpener().parent.document.forms["emxTableForm"];
			         			for (var i = 0; i < objForm.elements.length; i++)
			         			{
			         				var objElement = objForm.elements[i];
			         				if (objElement.name == "emxTableRowId")
			         				{
			         					var emxTableRowId = objElement.value;
			         					sourceCheckboxes = new Object();
			         					sourceCheckboxes[emxTableRowId] = emxTableRowId;
			         				}
			         			}
			         		}
			         	}
			        	if (sourceCheckboxes == null)
			        	{
			        		throw "Source selection not found.";
			        	}
			        }
			        catch (exp)
			        {
			        	alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.CouldNotFindSourceSelection")%></xss:encodeForJavaScript>");
					//KIE1 ZUD TSK447636 
			        	window.getTopWindow().closeWindow();
			        	return;
			        }
					// Comma separated source and target selection ids
					var strSourceIds = convertToCommaSeparatedIds (sourceCheckboxes);
					var strTargetIds = convertToCommaSeparatedIds (targetCheckboxes);
					
	    	        //alert("Derived and linked the existing requirement successfully. Source=" + strSourceIds + ", Target=" + strTargetIds);
					document.FormPreEnsureSourceTargetSelection.sourceIds.value = strSourceIds;
					document.FormPreEnsureSourceTargetSelection.targetIds.value = strTargetIds;
    	       		document.FormPreEnsureSourceTargetSelection.submit();
    	       		
    	       		
    	       }
<%
				if (isFromRMB) {
%>				
					window.parent.autoCheckRow("<xss:encodeForJavaScript><%=emxTableRowId%></xss:encodeForJavaScript>");
<%
				}
%>    	       
    	       findAndSubmitSourceTargetSelection();
    	   </script>
<%        		
        }
        else if ("EnsureSourceTargetSelection".equals(strMode)) 
        {
            //System.out.println("DEBUG: EnsureSourceTargetSelection");
            String strSubMode = emxGetParameter(request,"subMode");
            String strOperation = emxGetParameter(request,"operation");
            String strSubOperation = emxGetParameter(request,"subOperation");
            String strSourceIds = emxGetParameter(request,"sourceIds");
            String strTargetIds = emxGetParameter(request,"targetIds");
            
%>
			<form name="FormEnsureSourceTargetSelection" action="SpecificationStructureUtil.jsp" method="POST">
			<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
				<input type="text" name="mode"          value="SubmitSourceTargetSelection" />
				<input type="text" name="subMode" value="<xss:encodeForHTMLAttribute><%=strSubMode %></xss:encodeForHTMLAttribute>" />
				<input type="text" name="operation" value="<xss:encodeForHTMLAttribute><%=strOperation %></xss:encodeForHTMLAttribute>" />
				<input type="text" name="subOperation" value="<xss:encodeForHTMLAttribute><%=strSubOperation %></xss:encodeForHTMLAttribute>" />
				<input type="text" name="sourceIds"     value="<xss:encodeForHTMLAttribute><%=strSourceIds %></xss:encodeForHTMLAttribute>" />
				<input type="text" name="targetIds"     value="<xss:encodeForHTMLAttribute><%=strTargetIds %></xss:encodeForHTMLAttribute>" />
			</form>
<%   
			StringList slSourceIds = new StringList();
			StringList slTargetIds = new StringList();
			StringList slSourceParentIds = new StringList();
			StringList slTargetParentIds = new StringList();
			
			//Remove parent IDs from the data which is not needed for validation
			for (StringItr idsItr = new StringItr(FrameworkUtil.split(strSourceIds, "!")); idsItr.next();) {
			    String strId = idsItr.obj();
			    StringList slIds = FrameworkUtil.split(strId, "|");
			    slSourceIds.add(slIds.get(1));
			    slSourceParentIds.add(slIds.get(2));
			}
			
			for (StringItr idsItr = new StringItr(FrameworkUtil.split(strTargetIds, "!")); idsItr.next();) {
			    String strId = idsItr.obj();
			    StringList slIds = FrameworkUtil.split(strId, "|");
			    slTargetIds.add(slIds.get(1));
			    slTargetParentIds.add(slIds.get(2));
			}
			
			String strRelationshipSymName = ("ForSubRequirement".equals(strSubMode))?"relationship_RequirementBreakdown":"relationship_DerivedRequirement";
			
			SpecificationStructure specStructure = new SpecificationStructure();
			int nValidationCode = 0;
			if(slSourceIds.size() >= 1)
			{
			nValidationCode = specStructure.checkSourceAndTargetReqValidatyForLinking (
																				context, 
																				slSourceIds,
																				slSourceParentIds,
																				slTargetIds,
																				slTargetParentIds,
																				strRelationshipSymName,
																				strOperation,
																				strSubOperation);
			}
			else
			{
			    throw new Exception("Source selection not found.");
			}

			if (nValidationCode == 0) 
			{
%>
				<script language="JavaScript">
					document.FormEnsureSourceTargetSelection.submit();
				</script>
<%				    
			}
			else {
				throw new Exception("Error" + nValidationCode);
			}
        }
        else if ("SubmitSourceTargetSelection".equals(strMode)) 
        {
            //System.out.println("DEBUG: In SubmitSourceTargetSelection");
            String strSubMode = emxGetParameter(request,"subMode");
            String strOperation = emxGetParameter(request,"operation");
            String strSubOperation = emxGetParameter(request,"subOperation");
            String strSourceIds = emxGetParameter(request,"sourceIds");
            String strTargetIds = emxGetParameter(request,"targetIds");
            
            if ("LinkExisting".equals(strOperation)) {
        		String strRelName = "";
        		String strMessage = "";
        		
        		if ("ForSubRequirement".equals(strSubMode)) {
        		    strRelName = ReqSchemaUtil.getSubRequirementRelationship(context);
        		    strMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Status.SubRequirementLinked"); 
        		}
        		else if ("ForDerivedRequirement".equals(strSubMode)) {
        		    strRelName = ReqSchemaUtil.getDerivedRequirementRelationship(context);
        		    strMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Status.DerivedRequirementLinked"); 
        		}
        		else {
        		    throw new RuntimeException("Invalid subMode '" + strSubMode + "'");
        		}
        		
        		StringList slSourceIds = new StringList();
				StringList slTargetIds = new StringList();
				
				//Remove parent IDs from the data which is not needed for validation
				for (StringItr idsItr = new StringItr(FrameworkUtil.split(strSourceIds, "!")); idsItr.next();) {
				    String strId = idsItr.obj();
				    StringList slIds = FrameworkUtil.split(strId, "|");
				    slSourceIds.add(slIds.get(1));
				}
				
				for (StringItr idsItr = new StringItr(FrameworkUtil.split(strTargetIds, "!")); idsItr.next();) {
				    String strId = idsItr.obj();
				    StringList slIds = FrameworkUtil.split(strId, "|");
				    slTargetIds.add(slIds.get(1));
				}
        		
				String xmlMessage = "";
        		// Connect sub/derived requirement
        		for (StringItr sourceItr = new StringItr(slSourceIds); sourceItr.next();) {
        		    String strSourceId = sourceItr.obj();
        		    for (StringItr targetItr = new StringItr(slTargetIds); targetItr.next();) {
        				String strTargetId = targetItr.obj();
        				xmlMessage += SpecificationStructure.insertNodeAtSelected(context, "|" + strSourceId + "||", strTargetId, null, true, null, strRelName);
        		    }
        		}
        		xmlMessage = "<mxRoot><action>add</action><data fromRMB=\"true\" status=\"committed\" >" + xmlMessage + "</data></mxRoot>";
        		if(xmlMessage != "")
        			throw new Exception("SuccessfullyAdded");
        		
%>
				<script language="JavaScript">
					   // alert("<!%=strMessage%>");
					   //KIE1 ZUD TSK447636 
					   if(typeof getTopWindow().getWindowOpener().parent.emxEditableTable != 'undefined' && getTopWindow().getWindowOpener().parent.emxEditableTable.isRichTextEditor){
				          	getTopWindow().getWindowOpener().parent.emxEditableTable.refreshObject();  
				       }else 
					   if(getTopWindow().getWindowOpener().parent.refreshRows)
					   {
					   		getTopWindow().getWindowOpener().parent.refreshRows();
					   }
					   if(typeof getTopWindow().getWindowOpener().parent.emxEditableTable != 'undefined'){
						   //START : Don't display derived requirements on creation in table
						   <%
						   if (!"ForDerivedRequirement".equals(strSubMode)){
						   %>
						   		getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
						   <%
						   }
						   %>
						   //END : Don't display derived requirements on creation in table
						   if(!getTopWindow().getWindowOpener().parent.emxEditableTable.isRichTextEditor)
						   {
								var rowId = "<xss:encodeForJavaScript><%=strSourceIds%></xss:encodeForJavaScript>".split("|")[3];
						        var aRowsSelected = getTopWindow().getWindowOpener().parent.emxUICore.selectNodes(getTopWindow().getWindowOpener().parent.oXML,"/mxRoot/rows//r[@id='" + rowId + "']"); 
						    	var xmlDOM = getTopWindow().getWindowOpener().parent.emxUICore.createXMLDOM();
						    	xmlDOM.loadXML('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
								var newRelId = getTopWindow().getWindowOpener().parent.emxUICore.selectNodes(xmlDOM,"/mxRoot/data/item")[0].getAttribute("relId");
						        var newChild = getTopWindow().getWindowOpener().parent.emxUICore.selectNodes(aRowsSelected[0],"//r[@r='" + newRelId + "']");
						        if(newChild.length == 0){
						        	getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
						        }
							}
					   }
					   //KIE1 ZUD TSK447636 
				</script>
<%        		
            }
            else if ("CreateNewAndLink".equals(strOperation)) {
            	    boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
            	    String csrfTokenName = "";
            	    String csrfTokenValue = "";
            	    if(csrfEnabled)
            	    {
            	    	Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
            	    	csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
            	    	csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
            	    }
            	    System.out.println("CSRFINJECTION");
            	    String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
                 	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
                 		autonameChecked = "true";
                 	}
%>
				<script language="JavaScript">
					var strURL = "../common/emxCreate.jsp?type=type_Requirement&typeChooser=true&autoNameChecked="+"<%=autonameChecked%>"+"&nameField=both&vaultChooser=true&form=RMTSpecTreeCreateNewRequirement&header=emxRequirements.Heading.CreateRequirement&HelpMarker=emxhelpnewreqchaptercomment&showApply=true&submitAction=xmlMessage&postProcessURL=../requirements/CreateProcess.jsp&createProcessJPO=emxSpecificationStructure:postCreateSetSequenceOrder&objectCompare=false&showClipboard=false";
					strURL += "&subMode=<xss:encodeForJavaScript><%=strSubMode%></xss:encodeForJavaScript>";
					strURL += "&operation=<xss:encodeForJavaScript><%=strOperation%></xss:encodeForJavaScript>";
					strURL += "&subOperation=<xss:encodeForJavaScript><%=strSubOperation%></xss:encodeForJavaScript>";
					strURL += "&sourceIds=<xss:encodeForJavaScript><%=strSourceIds%></xss:encodeForJavaScript>";
					strURL += "&targetIds=<xss:encodeForJavaScript><%=strTargetIds%></xss:encodeForJavaScript>";
					strURL += "&suiteKey=Requirements";
					strURL += "<%=csrfEnabled ? ("&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "= " + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue ) : ""%>";<%--XSSOK--%>
					
					showDialog(strURL);
				</script>
<%        	
            }
        }
        else if ("RaiseEC".equals(strMode)) 
        {
        	   // Start:IR:123051V6R2013x:LX6
             String strURL = null;
             String[] arrSelectedIds = emxGetParameterValues(request, "emxTableRowId");
             boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,arrSelectedIds);
             if(isRequirementGroupInList == true)
             {
            	 throw new Exception("invalidForReqGroup");
             }
             // End:IR:123051V6R2013x:LX6
             // request.setAttribute("emxTableRowId", arrSelectedIds);
             StringBuffer strTemp = new StringBuffer();
    
			  if(arrSelectedIds != null)
			  {
			    for(int i=0;i<arrSelectedIds.length;i++)
			    {
			        strTemp.append(arrSelectedIds[i]);
			        strTemp.append(",");
			    }
			  }
			  
			  //START:OEP:IR-174856V6R2013x
			  if(strTemp.length() > 0)
				  strTemp.deleteCharAt(strTemp.length() -1);
			  
			  %>
			   <form name="ECForm" action="../components/emxEngineeringChangeUtil.jsp" method="post">
			    <input type="hidden" name="functionality" value="RaiseECFSInstance"/>
			    <input type="hidden" name="mode" value="validateRaiseEC"/>
			    <input type="hidden" name="srcDestRelName" value="relationship_ECAffectedItem"/>
			    <input type="hidden" name="connectAtFrom" value="true"/>
			    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId %></xss:encodeForHTMLAttribute>"/>
			    <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=strTemp.toString() %></xss:encodeForHTMLAttribute>"/>
			    <input type="hidden" name="suiteKey" value="Components"/>
			    
			  </form>
			   <script language="javascript" type="text/javascript">
     				 document.ECForm.submit();
    			</script>
			  <%
			//END:OEP:IR-174856V6R2013x
        }
        else if ("Creation".equals(strMode)) 
        {
        	  String strTypeToCreate = PropertyUtil.getSchemaProperty(context,emxGetParameter(request,"type"));
        	  String strsubmitAction = emxGetParameter(request,"submitAction");
        	  String strForm = emxGetParameter(request,"form");
        	  String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
           	  if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
           		autonameChecked = "true";
           	  }
        	  String header = emxGetParameter(request,"header");
        	  String href = "../common/emxCreate.jsp?nameField=program&showApply=true"; //HAT1 ZUD Populating title as per autoName of Name in Web form.
        	  String isSimplified = EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm");
	        	href +="&header=" + header;
	        	href += "&type=" + strTypeToCreate;
	        	href += "&form="+strForm;
	        	
	        	if(strsubmitAction != null && !"".equals(strsubmitAction))
	        	{
	        		href += "&submitAction="+strsubmitAction;
	        	}
        	  //String isVaultChooser = "";
                  // ZUD Type Chosser should be present for all creation forms as types can be specialized
        	   href += "&typeChooser=true";
        	  if(isSimplified ==  null || "".equals(isSimplified) ||"false".equals(isSimplified))
        	  {
        		  href += "&vaultChooser=true";
        		  
        	  }
        	  else
        	  {
        		  href += "&vaultChooser=false";
        		  if(ReqSchemaUtil.getRequirementType(context).equals(strTypeToCreate))
        		  {
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,ReqServices.getCustomDefaultPolicy(context, strTypeToCreate));
        			  href += "&type=" + ReqSchemaUtil.getRequirementType(context);
        			  
        			  // For RichText
  	        		  href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&operation=setRichText&slideInMode=refreshSlideInFrame";
  	        		  href += "&HelpMarker=emxhelprequirementcreate";
        		  }
        		  else if(ReqSchemaUtil.getChapterType(context).equals(strTypeToCreate))
        		  {
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,ReqServices.getCustomDefaultPolicy(context, strTypeToCreate));
        			  href += "&type=" + ReqSchemaUtil.getChapterType(context);
        			  href += "&HelpMarker=emxhelpnewreqchaptercomment";
        		  }
        		  else if(ReqSchemaUtil.getCommentType(context).equals(strTypeToCreate))
                  {
      			    href += "&Policy=" + PropertyUtil.getSchemaProperty(context,ReqServices.getCustomDefaultPolicy(context, strTypeToCreate));
                    href += "&type=" + ReqSchemaUtil.getCommentType(context);
                    
                 	// For RichText
	        		href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&operation=setRichText";
	        		href += "&HelpMarker=emxhelpnewreqchaptercomment";
                  }
        		  else if(ReqSchemaUtil.getRequirementGroupType(context).equals(strTypeToCreate))
                  {
  	        		href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&slideInMode=refreshSlideInFrame";
      			    href += "&Policy=" + PropertyUtil.getSchemaProperty(context,ReqServices.getCustomDefaultPolicy(context, strTypeToCreate));
                    href += "&type=" + ReqSchemaUtil.getRequirementGroupType(context);
                    href += "&HelpMarker=emxhelpspecificationfoldercreate";
                  }
        		  else if(ReqSchemaUtil.getRequirementSpecificationType(context).equals(strTypeToCreate))
        		  {
    	        	  href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&slideInMode=refreshSlideInFrame";
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,ReqServices.getCustomDefaultPolicy(context, strTypeToCreate));
        			  href += "&type=" + ReqSchemaUtil.getRequirementSpecificationType(context);
        			  href += "&HelpMarker=emxhelpspeccreate";
        		  }
        	  }

            //djh: Correction REG IR-228533V6R2014, IR-228531V6R2014. Add Suite name in href
        	  href += "&suiteKey=Requirements";
            %>
            <script type="text/javascript">
            if(getTopWindow().opener){
            	window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href)%>";
            }else{
            	/* HAT1 ZUD: IR-508271-3DEXPERIENCER2018x fix: replacing the window.frame argument with "" */
		        getTopWindow().showSlideInDialog("<%=XSSUtil.encodeForJavaScript(context, href)%>", true, "", "", 550); 
            }
           </script>
           <%
        }
        /* ++ HAT1 ZUD Default Policy ++ */
        else if ("reqUnderModelCreation".equals(strMode)) 
        {
        	  String strTypeToCreate = PropertyUtil.getSchemaProperty(context,emxGetParameter(request,"type"));
        	  String strsubmitAction = emxGetParameter(request,"submitAction");
        	  String strForm = emxGetParameter(request,"form");
        	  String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
           	  if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
           		autonameChecked = "true";
           	  }
        	  String header = emxGetParameter(request,"header");
        	  String href = "../common/emxCreate.jsp?nameField=program&showApply=true"; //HAT1 ZUD Populating title as per autoName of Name in Web form.
        	  String isSimplified = EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm");
	        	href +="&header=" + header;
	        	href += "&type=" + strTypeToCreate;
	        	href += "&form="+strForm;
	    
	        	
	        	href += "&SuiteDirectory=requirements";
	        	href += "&StringResourceFileId=emxRequirementsStringResource";
	        	href += "&suiteKey=Requirements";
	        	
	        	href += "&objectId=" + strObjectId;
	        	
	        	if(emxTableRowId != null && !"".equals(emxTableRowId))
	        	{
		        	href += "&emxTableRowId=" + emxTableRowId;
	        	}
	        	if(strsubmitAction != null && !"".equals(strsubmitAction))
	        	{
	        		href += "&submitAction="+strsubmitAction;
	        	}

	        	href += "&typeChooser=false";
        	  if(isSimplified ==  null || "".equals(isSimplified) ||"false".equals(isSimplified))
        	  {
        		  href += "&vaultChooser=true";
        		  
        	  }
        	  else
        	  {
        		  href += "&vaultChooser=false";
        		  if(ReqSchemaUtil.getRequirementType(context).equals(strTypeToCreate))
        		  {
        			  String strType = ReqSchemaUtil.getRequirementType(context);
        			  String Policy = PropertyUtil.getSchemaProperty(context, ReqServices.getCustomDefaultPolicy(context, strType));
        			  
        			  href += "&Policy=" + Policy;
        			  href += "&type=" + strType;
        			  href += "&relationship=relationship_CandidateItem";
        			  // For RichText
  	        		  href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&operation=setRichText";
  	        		  href += "&HelpMarker=emxhelprequirementcreate";
        		  }
        	  }
        	  
            %>
            <script type="text/javascript">
            if(getTopWindow().opener){
            	window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href)%>";
            }else{
		        getTopWindow().showSlideInDialog("<%=XSSUtil.encodeForJavaScript(context, href)%>", true, "", "", 550); 
            }
           </script>
           <%
        }
        
        else if ("reqUnderProductCreation".equals(strMode)) 
        {
        	  String strTypeToCreate = PropertyUtil.getSchemaProperty(context,emxGetParameter(request,"type"));
        	  String strsubmitAction = emxGetParameter(request,"submitAction");
        	  String strForm = emxGetParameter(request,"form");
        	  String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
           	  if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
           		autonameChecked = "true";
           	  }
        	  String header = emxGetParameter(request,"header");
        	  String href = "../common/emxCreate.jsp?nameField=program&showApply=true"; //HAT1 ZUD Populating title as per autoName of Name in Web form.
        	  String isSimplified = EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm");
	        	href +="&header=" + header;
	        	href += "&type=" + strTypeToCreate;
	        	href += "&form="+strForm;
	    
	        	
	        	href += "&SuiteDirectory=requirements";
	        	href += "&StringResourceFileId=emxRequirementsStringResource";
	        	href += "&suiteKey=Requirements";
	        	
	        	href += "&objectId=" + strObjectId;
	        	
	        	if(emxTableRowId != null && !"".equals(emxTableRowId))
	        	{
		        	href += "&emxTableRowId=" + emxTableRowId;
	        	}
	        	if(strsubmitAction != null && !"".equals(strsubmitAction))
	        	{
	        		href += "&submitAction="+strsubmitAction;
	        	}

	        	href += "&typeChooser=false";
        	  if(isSimplified ==  null || "".equals(isSimplified) ||"false".equals(isSimplified))
        	  {
        		  href += "&vaultChooser=true";
        		  
        	  }
        	  else
        	  {
        		  href += "&vaultChooser=false";
        		  if(ReqSchemaUtil.getRequirementType(context).equals(strTypeToCreate))
        		  {
        			  String strType = ReqSchemaUtil.getRequirementType(context);
        			  String Policy = PropertyUtil.getSchemaProperty(context, ReqServices.getCustomDefaultPolicy(context, strType));
        			  
        			  href += "&Policy=" + Policy;
        			  href += "&type=" + strType;
        			  
        			  
        			  href += "&relationship=relationship_ProductRequirement";
        			  // For RichText
  	        		  href += "&postProcessURL=" + "../requirements/CreateProcess.jsp&operation=setRichText";
  	        		  href += "&HelpMarker=emxhelprequirementcreate";
        		  }

        	  }
        	  
            %>
            <script type="text/javascript">
            if(getTopWindow().opener){
            	window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href)%>";
            }else{
		        getTopWindow().showSlideInDialog("<%=XSSUtil.encodeForJavaScript(context, href)%>", true, "", "", 550); 
            }
           </script>
           <%
        }
        /* -- HAT1 ZUD: Default Policy -- */
        
        else if ("graphDisplay".equals(strMode)){
        	String command = emxGetParameter(request,"command");
        	Map commandMap = UIToolbar.getCommand(context, command);
        	String targetLocation = (String)((Map)commandMap.get("settings")).get("Target Location");
        	if(strObjectId == null || strObjectId.isEmpty()){
        		strObjectId = emxGetParameter(request, "emxTableRowId").split("[|]")[1];
        	}
        	String suitKey = (String)((Map)commandMap.get("settings")).get("Registered Suite");
	    		String href = (String)commandMap.get("href");
	    		href = UINavigatorUtil.parseHREF(context,href, "Requirements");
	    		href += "&objectId="+strObjectId;
	    		href += "&suiteKey="+suitKey;
	    		
	   %>
	   <script language="JavaScript">
	   var frame = findFrame(getTopWindow(),"RMTDisplayGraphUtil")
	   if(frame != null){
		   frame.location.href = "<%=XSSUtil.encodeForJavaScript(context, href)%>";
		   parent.objPortal.controller.doMaximise(parent.objPortal.element.children[0].children[0]);
	   }else{
		   showNonModalDialog("<xss:encodeForJavaScript><%=href%></xss:encodeForJavaScript>");
	   }
	   <%-- findFrame(getTopWindow(),"RMTDisplayGraphUtil").location.href = "<%=XSSUtil.encodeForJavaScript(context, href)%>"; --%>
	   /* parent.objPortal.controller.doMaximise(parent.objPortal.element.children[0].children[0]); */
	   </script>
	   <%
        }else if("customExpand".equals(strMode)){
        	String strReceivedCustomType = emxGetParameter(request, "RMTCustomTypes");
        	String strReceivedExpandLevel = emxGetParameter(request, "expandLevel");
        	String timeStamp = emxGetParameter(request, "fpTimeStamp");
        	HashMap tableData = indentedTableBean.getTableData(timeStamp);
        	HashMap requestMap = indentedTableBean.getRequestMap(tableData);
        	requestMap.put("RMTCustomTypes", strReceivedCustomType);
        	requestMap.put("customExpandLevel", strReceivedExpandLevel);  
        }else if("createAndAttachToReqGroup".equals(strMode)){
        	String objId = emxTableRowId.split("[|]")[1];
        	DomainObject object = DomainObject.newInstance(context, objId);
        	String objectType = object.getType(context);
        	String type = emxGetParameter(request, "type");
        	String relType = emxGetParameter(request, "relType");
        	String Policy = "";
			String form = "RMTRequirementGroup";
        	
        	if(type.equalsIgnoreCase("type_SoftwareRequirementSpecification")){
        		
        		 Policy =  PropertyUtil.getSchemaProperty(context,
  			  			ReqServices.getCustomDefaultPolicy(context, PropertyUtil.getSchemaProperty(context,type))
  			  			);
        		// added SpecCreationForm
        		form = "RMTSpecCreation";
        	}else if(type.equalsIgnoreCase("type_RequirementGroup")){
        		
  			  	 Policy =  PropertyUtil.getSchemaProperty(context,
  			  			ReqServices.getCustomDefaultPolicy(context, PropertyUtil.getSchemaProperty(context,type))
  			  			);

        		// added RMTRequirementGroup
        		form = "RMTRequirementGroup";
        	}else{
        		throw new Exception("InvalidSelectionForGroupOperation");
        	}
        	// checked with iskind of type
        	if(!object.isKindOf(context, ReqSchemaUtil.getRequirementGroupType(context))){
        		//error
        		throw new Exception("InvalidSelectionForGroupOperation");
        	}else{
        		String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
             	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
             		autonameChecked = "true";
             	}
        		%>
        		<script language="javascript" type="text/javaScript"> //HAT1 ZUD: IR-439337-3DEXPERIENCER2017x fix
        		var url = "../common/emxCreate.jsp?type="+"<%=type%>"+"&typeChooser=true&nameField=program&form="+"<%=form%>"+"&HelpMarker=emxhelpnewsubderivedreqcreate&showApply=true&relationship="+"<%=relType%>"+"&isChildCreation=true&submitAction=xmlMessage&postProcessURL=../requirements/RMTGroupCreationPostProcess.jsp&objectCompare=false&showClipboard=false&operation=CreateSubGroup&categoryTreeName=null&objectId="+"<%=objId%>";
        		url += "&suiteKey=Requirements";
        		url += "&Policy="+"<%=Policy%>";
            	getTopWindow().showSlideInDialog(url,true, window.name,"","550");
            	</script>
            	<%
        	}
        }
        // START : IR-274607V6R2015 HAT1:ZUD 
        else if ("ReqSpecLinkReq".equals(strMode)) 
        {
        	  String strTypeToCreate = PropertyUtil.getSchemaProperty(context,emxGetParameter(request,"type"));
        	  String strsubmitAction = emxGetParameter(request,"submitAction");
        	  String strForm = emxGetParameter(request,"form");
        	  String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
           	  if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
           		autonameChecked = "true";
           	  }
        	  String header = emxGetParameter(request,"header");
        	  // New field added "&postProcessURL=../requirements/CreateProcess.jsp"
        	  String[] arrSelectedIds1 = emxGetParameterValues(request, "emxTableRowId");  //HAT1 ZUD Populating title as per autoName of Name in Web form.
        	  String href = "../common/emxCreate.jsp?nameField=program&HelpMarker=emxhelprequirementcreate&showApply=true&postProcessURL=../requirements/CreateProcess.jsp&operation=OpReqSpecLinkReq&ReqId="+strObjectId;
        	  String isSimplified = EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm");
	        	href +="&header=" + header;
	        	href += "&type=" + strTypeToCreate;
	        	href += "&form="+strForm;
	        	if(strsubmitAction != null && !"".equals(strsubmitAction))
	        	{
	        		href += "&submitAction="+"";
	        	}
        	  //String isVaultChooser = "";
        	  if(isSimplified ==  null || "".equals(isSimplified) ||"false".equals(isSimplified))
        	  {
        		  href += "&vaultChooser=true";
        		  href += "&typeChooser=true";	  
        	  }
        	  else
        	  {
        		  href += "&vaultChooser=false";
        		  href += "&typeChooser=false";
        		  if(ReqSchemaUtil.getRequirementType(context).equals(strTypeToCreate))
        		  {
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,
        					  ReqServices.getCustomDefaultPolicy(context, strTypeToCreate)
        					  );
        			  href += "&type=" + ReqSchemaUtil.getRequirementType(context);
        		  }
        		  else if(ReqSchemaUtil.getChapterType(context).equals(strTypeToCreate))
        		  {
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,
        					  ReqServices.getCustomDefaultPolicy(context, strTypeToCreate)
        					  );
        			  href += "&type=" + ReqSchemaUtil.getChapterType(context);
        		  }
        		  else if(ReqSchemaUtil.getCommentType(context).equals(strTypeToCreate))
                  {
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,
        					  ReqServices.getCustomDefaultPolicy(context, strTypeToCreate)
        					  );
                    href += "&type=" + ReqSchemaUtil.getCommentType(context);
                  }
        		  else if(ReqSchemaUtil.getRequirementGroupType(context).equals(strTypeToCreate))
                  {
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,
        					  ReqServices.getCustomDefaultPolicy(context, strTypeToCreate)
        					  );
                    href += "&type=" + ReqSchemaUtil.getRequirementGroupType(context);
                  }
        		  else if(ReqSchemaUtil.getRequirementSpecificationType(context).equals(strTypeToCreate))
        		  {
        			  href += "&Policy=" + PropertyUtil.getSchemaProperty(context,
        					  ReqServices.getCustomDefaultPolicy(context, strTypeToCreate)
        					  );
        			  href += "&type=" + ReqSchemaUtil.getRequirementSpecificationType(context);
        		  }
        	  }

            //djh: Correction REG IR-228533V6R2014, IR-228531V6R2014. Add Suite name in href
        	  href += "&suiteKey=Requirements";
            %>
            <script type="text/javascript">
		    getTopWindow().showSlideInDialog("<%=XSSUtil.encodeForJavaScript(context, href)%>", true, window.name,"",550);
           </script>
           <%
        // END : IR-274607V6R2015 HAT1:ZUD
        //START : LX6 FUN054695 ENOVIA GOV TRM Revision refactoring
        }else if ("replaceByNewRevision".equals(strMode)||"replaceByLastRevision".equals(strMode)) 
        {
        	
        	
        	boolean doReconcile = false;
        	String timeStamp = emxGetParameter(request, "timeStamp");
        	HashMap tableData = indentedTableBean.getTableData(timeStamp);
        	HashMap requestMap = indentedTableBean.getRequestMap(tableData);
        	MapList tableObjectList = indentedTableBean.getObjectList(tableData);
        	String selectedIds[] = emxGetParameterValues(request, "emxTableRowId");
        	StringList ids = new StringList();
        	for(int i=0;i<selectedIds.length;i++){
        		ids.add(selectedIds[i].split("[|]")[1]);
        	}
        	
        	MapList ordererMap = RequirementsCommon.getOrderedObjectMaps(context, ids, "ascending",tableObjectList);
        	Iterator itr = ordererMap.iterator();
        	try{
        	while(itr.hasNext()){
        		Map currentMap = (Map)itr.next();
	       		String selectedId = (String)currentMap.get("id");
	       		String relId = (String)currentMap.get("id[connection]");
	        	if(selectedIds.length==0){
					//the selected object is the root one
					throw new Exception("RootObjectSelected");
				}
	        	//String selectedId = emxTableRowId.split("[|]")[1];
				if(selectedId.equalsIgnoreCase(strObjectId)){
					//the selected object is the root one
					throw new Exception("RootObjectSelected");
				}
				
	            // ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy. ++
				BusinessObject busObj = new BusinessObject(selectedId);
				busObj.open(context);
	        	String objType = busObj.getTypeName();
	        	busObj.close(context);
	        	
			    if(!RequirementsUtil.isObjectRevisionable(context, selectedId) || objType.equalsIgnoreCase("Requirement Proxy")){
			    	//the object is not revisionable
			    	throw new Exception("NotRevisionable");
			    }
	            // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 
   
			    
			    ReplaceServices.replaceByLastNewRevision(context, selectedId, relId, strObjectId, strMode);
        	}
        	}
        	catch(Exception e){
        		ContextUtil.abortTransaction(context);
				throw e;
        	}
        	

        	%>
    		<script type="text/javascript">
    		var frame = findFrame(getTopWindow(),'detailsDisplay')
    		if(frame.editableTable !=null&&frame.emxEditableTable!=null){
    			//there is no portal displayed
    			frame.editableTable.loadData();
    			frame.emxEditableTable.refreshStructureWithOutSort();
    		}else{
    			//the table is in a portal
    			var channel = findCurrentChannel();
    			if(channel!=null){
    				//the channel is found 
    				channel.editableTable.loadData();
    				channel.emxEditableTable.refreshStructureWithOutSort();
    			}else{
    				//default behavior;
        			refreshTablePage();
        		}
    		}
            </script>
            <%
        }
      //END : LX6 FUN054695 ENOVIA GOV TRM Revision refactoring
else {
            System.out.println("DEBUG: Invalid mode " + strMode);            
        }
        //End V6R2010xHF1
    }

    catch (Exception e)
    {
        bFlag = true;
        String strAlertString = "emxRequirements.Alert." + e.getMessage();
        String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), strAlertString); 
        if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
        {
            session.putValue("error.message", e.getMessage());
        }
        else
        {
            session.putValue("error.message", i18nErrorMessage);
        }
        
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
	if("slidein".equals((String)emxGetParameter(request,"targetLocation")))
	{
%>
		<script language="JavaScript">
		getTopWindow().closeSlideInDialog();
		</script>
<%		
	}
    if (bFlag)
    {
%>
    <script language="Javascript" type="text/javaScript">
      <!-- hide JavaScript from non-JavaScript browsers -->
      //<![CDATA[
      	try{
	       findFrame(parent, 'pagecontent').clicked = false;
           parent.turnOffProgress();
	       history.back();
        }catch(oError){ }
        
      //]]>
    </script>
<%
    }
%>
</html>

