<%--
Copyright (c) 2007-2018 Dassault Systemes.
All Rights Reserved
This program contains proprietary and trade secret information of
MatrixOne, Inc.  Copyright notice is precautionary only and does
not evidence any actual or intended publication of such program.

--%>

<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
      are added under respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included
     @quickreview T25 DJH 13:10:18  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview HAT1:ZUD 14:06:03 : Correction IR-274607V6R2015. STP: in Requirement, Creating Requirement Specification from category "Specification" in Requirement is KO.
     @quickreview ZUD DJH  14:06:26 : HL Sequence Order to Tree Order Migration
     @quickreview LX6      14:11:25 : Don't display derived requirements on creation in table
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
     @quickreview HAT1 ZUD 15:12:16 : IR-296852-3DEXPERIENCER2017x: STP: In Webtop, Title field does not retrieve object name as default value for Title attribute. 
     @quickreview HAT1 ZUD 16:05:03 : Populating title as per autoName of Name in Web form.
     @quickreview HAT1 ZUD 16:05:17  IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated.
--%>
<%@ page import="matrix.db.*, java.util.*, com.matrixone.apps.domain.util.*, com.matrixone.apps.framework.ui.*, com.matrixone.apps.domain.*,com.matrixone.apps.domain.DomainRelationship"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.jdom.input.SAXBuilder"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file = "../emxTagLibInclude.inc"%>

<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<jsp:useBean id="createBean"
    class="com.matrixone.apps.framework.ui.UIForm" scope="session" />
    
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.domain.util.TreeOrderUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

<%		
/*
* @quickreview QYG 12:08:28 IR-185854V6R2013x (Creation of child object in Requirement or Requirement Specification is KO)	
* @quickreview LX6 QYG 12:07:30 (IR-182432R2013x "STP : Sub Requirement Add under Released Requirement is allowed from RFLP Navigator. ")
* @quickreview ZUD DJH 13:06:14 (IR-233654V6R2014x "When create Requirement using Sub Requirement or Derived Requirement function, Tree view is not reflected immediately ")
*/
	try{
			matrix.db.Context context = (matrix.db.Context)request.getAttribute("context");
			String newRelId = null;
	    	String strOperation = emxGetParameter(request,"operation");
			String newObjectId = emxGetParameter(request, "newObjectId");
			String refreshSlideInFrame = emxGetParameter(request, "slideInMode");
			String  strTableRowId = null;
			
			// ++ HAT1 ZUD: IR-296852-3DEXPERIENCER2017x: To populate Title field same as Name of object when it is blank.
			//getting name or Req object
			DomainObject domObj = DomainObject.newInstance(context, newObjectId);
			StringList selectList = new StringList(2);
	        selectList.addElement(DomainConstants.SELECT_TYPE);
	        selectList.addElement(DomainConstants.SELECT_NAME);
	        Map objectInfo = domObj.getInfo(context, selectList);
	        
	        String objectType = (String)objectInfo.get(DomainConstants.SELECT_TYPE);
	        String objectName = (String)objectInfo.get(DomainConstants.SELECT_NAME);
	        
			Attribute attrib_title = domObj.getAttribute(context, DomainConstants.ATTRIBUTE_TITLE);
			String str_title = "";
			str_title = attrib_title.getValue();

			if(str_title.equalsIgnoreCase("") || str_title.equalsIgnoreCase(null))
			{
				ContextUtil.startTransaction(context, true);
				// Set the title
				domObj.setAttributeValue(context, DomainConstants.ATTRIBUTE_TITLE, objectName);
				ContextUtil.commitTransaction(context);
			}
			// -- HAT1 ZUD: IR-296852-3DEXPERIENCER2017x fix
			
			// To set the richText
			if (strOperation != null && strOperation.equals("setRichText")) {
				
				%>
				<script language="javascript">
			
				// Set the rich Text
				var windowDocument = findFrame(getTopWindow(), 'slideInFrame');
				
				// It can means it's from CATIA
				if (!windowDocument) {
					windowDocument = getTopWindow();
				}
				
				if (windowDocument && windowDocument.objectCreationType && windowDocument.objectCreationContentData) {
					var data = new FormData();
				    data.append('type', windowDocument.objectCreationType);
				    data.append('objectId', "<xss:encodeForJavaScript><%=newObjectId%></xss:encodeForJavaScript>");
				    data.append('contentText', windowDocument.objectCreationContentText);
				    data.append('contentData', windowDocument.objectCreationContentData); //must be last item!! 
				
				    windowDocument.jQuery.ajax({
				        type: 'POST',
				        cache: false,
				        contentType: false,
				        processData: false,
				        url: "../resources/richeditor/res/setRichContent" + "?" + windowDocument.objectCreationCsrfParams,
				        data: data,
				        complete: function(data) {
				        	// NOP
				        },
			            error: function(xhr, status, error){
			            	var message = typeof xhr.responseText == 'string' ? JSON.parse(xhr.responseText).status : xhr.responseText; 
			            	alert(error + ":" + message);
			            },
				        dataType: 'text',
				        async: false
				    });
				}
	
				</script>
				<%
				
				return;
			}
			
			if("CreateSubDerived".equals(strOperation) || "SpecStructureNewSubDerivedReq".equals(strOperation))
	    	{
	    		//copy the default rich text values from parent
	    		 String strParentObjectId = "";
	    		 strTableRowId = emxGetParameter(request, "emxTableRowId");
	                if (strTableRowId != null)
	    		 {
    				 StringList objectIdList = FrameworkUtil.split(strTableRowId, "|");
    				 if (objectIdList.size() == 3)
    				 {
    					 strParentObjectId = (String) objectIdList.get(0);
    				 } 
    				 else if (objectIdList.size() == 4)
    				 {
    					 strParentObjectId = (String) objectIdList.get(1);
    				 }
    				 
    				// FIXME Need to set the parent richtext for the son
    				 /* DomainObject parent = DomainObject.newInstance(context, strParentObjectId);
    				 Map attrMap = (Map) parent.getAttributeMap(context);
    				 DomainObject newObject = DomainObject.newInstance(context, newObjectId);
    				 String key = ReqSchemaUtil.getContentTextAttribute(context);
    				 newObject.setAttributeValue(context, key, (String)attrMap.get(key));
    				 key = ReqSchemaUtil.getContentDataAttribute(context);
    				 newObject.setAttributeValue(context, key, (String)attrMap.get(key));
    				 key = ReqSchemaUtil.getContentTypeAttribute(context);
    				 newObject.setAttributeValue(context, key, (String)attrMap.get(key)); */
	    		 }
	    	}
			// START : IR-274607V6R2015 HAT1:ZUD Operation for mode ReqSpecLinkReq in SpecificationStructureUtil.jsp for postProcessURL.
			if("OpReqSpecLinkReq".equals(strOperation))
			{
				 String strParentObjectId = "";
	    		 strTableRowId = emxGetParameter(request, "ReqId");
	 		     String strRelName = ReqSchemaUtil.getSpecStructureRelationship(context); 
	 		     
					String iNewRelId =RequirementsCommon.connectObjects(context, newObjectId, strTableRowId, strRelName);
					
					// ZUD Fix For TreeOrder Attribute
					
					if((strRelName.equals(ReqSchemaUtil.getSpecStructureRelationship(context))))
					{					
					String[] IDs = iNewRelId.split(" ", -1);					
					String RelID = IDs[2];					
					String []RelIdToFetch = RelID.split("=",-1);					
					String RelIdForTreeOrder = RelIdToFetch[1];					
					RelIdForTreeOrder = RelIdForTreeOrder.replace("\"", " ");					
					DomainRelationship.setAttributeValue(context,RelIdForTreeOrder,ReqSchemaUtil.getTreeOrderAttribute(context),""+TreeOrderUtil.getNextTreeOrderValue());
									
					}

	    		  %>
	    		  <script language="javascript">    			
	    		  var RMTRequirementSpecificationsFrame = findFrame (getTopWindow(), "RMTRequirementSpecifications");
    		      if (RMTRequirementSpecificationsFrame){
    		        	RMTRequirementSpecificationsFrame.editableTable.loadData();
    		        	RMTRequirementSpecificationsFrame.RefreshTableHeaders();
    		        	RMTRequirementSpecificationsFrame.rebuildView();
    		        }
	    		  </script> 
	    			<%
			}
			// END : IR-274607V6R2015 HAT1:ZUD

	    	
			//ContextUtil.commitTransaction(context); //IR-060188V6R2011x, IR-068849V6R2011x: commit object creation to check its uniqueness.
			String relId = emxGetParameter(request, "relId");
		    String form = emxGetParameter(request, "form");
		    String timeStamp = emxGetParameter(request, "timeStamp");
			String languageStr = emxGetParameter(request, "Accept-Language");
		    String submitAction = emxGetParameter(request, "submitAction");
		    String strSubMode = emxGetParameter(request,"subMode");
		    String strStatusMsg = "";

		    String xmlMessage = null;
			
		    String postProcessJPO = emxGetParameter(request, "createProcessJPO");
            if (postProcessJPO != null && !"".equals(postProcessJPO) && postProcessJPO.indexOf(":") > 0 ) {
                HashMap programMap = new HashMap(6);
                HashMap paramMap = new HashMap(6);
                paramMap.put("objectId", newObjectId);
                paramMap.put("newObjectId", newObjectId);
                paramMap.put("relId", relId);
                paramMap.put("languageStr", languageStr);
                programMap.put("requestMap", UINavigatorUtil.getRequestParameterMap(pageContext));
                programMap.put("paramMap", paramMap);
                HashMap formMap = createBean.getFormData(timeStamp);
                programMap.put("formMap", formMap);
             	// Start V6R2010xHF1
	       		String strSubOperation = emxGetParameter(request,"subOperation");
	        	String strSourceIds = emxGetParameter(request,"sourceIds");
	      		String strTargetIds = emxGetParameter(request,"targetIds");
	      		boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
	      		
	      		programMap.put("operation", strOperation);
	      		programMap.put("subOperation", strSubOperation);
	      		programMap.put("targetIds", strTargetIds);
		    	// End V6R2010xHF1

          String[] methodargs = JPO.packArgs(programMap);
          String strJPOName = postProcessJPO.substring(0, postProcessJPO.indexOf(":"));
          String strMethodName = postProcessJPO.substring(
                  postProcessJPO.indexOf(":") + 1, postProcessJPO.length());
          try
          { 
	          // Start:IR:182432V6R2013x:LX6
	          ContextUtil.startTransaction(context, true);
	          // End:IR:182432V6R2013x:LX6
	          xmlMessage = (String)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, String.class);
	          ContextUtil.commitTransaction(context);
          }
          catch(Exception exp)
          {
	        	// Start:IR:182432V6R2013x:LX6
	          ContextUtil.abortTransaction(context);
	          // End:IR:182432V6R2013x:LX6
	          throw new Exception(exp.getMessage());
          }
				if("xmlMessage".equalsIgnoreCase(submitAction) && xmlMessage != null)
	            {
				 // Start V6R2010xHF1
			    	if ("CreateNewAndLink".equals(strOperation))
			    	{
			    	    //
			    	    // Find the target selected
			    	    //
			    	    StringList slTargetIds = FrameworkUtil.split(strTargetIds, "!");
			    	    //Note: Taking only first target id for refresh!
			    	    String strTargetEmxTableRowId = (String)slTargetIds.get(0);
			    	    StringList slTargetEmxTableRowId = FrameworkUtil.split(strTargetEmxTableRowId, "|");
						
			    	    final String SELECT_SPEC_STRUCTRE_REL_ID = "to[" + ReqSchemaUtil.getSpecStructureRelationship(context) + "].id";
			    	    final String SELECT_SPEC_STRUCTRE_PARENT_ID = "to[" + ReqSchemaUtil.getSpecStructureRelationship(context) + "].from.id";
			    	    
			    	    //
			    	    // Find information about new object
			    	    //
			    	    StringList slBusSelect = new StringList();
			    		slBusSelect.add(SELECT_SPEC_STRUCTRE_REL_ID);
			    		slBusSelect.add(SELECT_SPEC_STRUCTRE_PARENT_ID);
			    		
			    	    DomainObject newObject = DomainObject.newInstance(context, newObjectId);
			    	    Map mapNewObjectInfo = newObject.getInfo(context, slBusSelect);
			    	    String strNewRelId = (String)mapNewObjectInfo.get(SELECT_SPEC_STRUCTRE_REL_ID);
			    		String strParentId = (String)mapNewObjectInfo.get(SELECT_SPEC_STRUCTRE_PARENT_ID);
			    	    
			    		//
			    		// Compose the XML message for refresh
			    		//
			    		xmlMessage = "<mxRoot><action>add</action>" +
                			"<data status=\"committed\" fromRMB=\"" + isFromRMB + "\" " + (("AddChild".equals(strSubOperation))? "":"pasteBelowOrAbove=\"true\"") + " >" +
                			"<item oid=\"" + newObjectId + "\" relId=\"" + strNewRelId + "\" pid=\"" + strParentId + "\" direction=\"\"" ;
                			
			    		if ("AddAbove".equals(strSubOperation))
			    		{
			    		    xmlMessage += " pasteAboveToRow=\"" + slTargetEmxTableRowId.get(3) + "\" />";
			    		}
			    		else if ("AddBelow".equals(strSubOperation)) 
			    		{
				    		xmlMessage += " pasteBelowToRow=\"" + slTargetEmxTableRowId.get(3) + "\" />";
			    		}
			    		else if ("AddChild".equals(strSubOperation))
			    		{
			    			xmlMessage += " />";
			    		}
			            xmlMessage +="</data></mxRoot>";
												
%>
						<script language="javascript">
						 //KIE1 ZUD TSK447636 
							if(typeof getTopWindow().getWindowOpener().parent.emxEditableTable != 'undefined' && getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected)
							{
								// Refresh structure browser in search window TODO
					          	getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
					          	
								//Proceed further for linking as sub/derived requirement
					          	if (getTopWindow().getWindowOpener().parent.frames["listHidden"])
					          	{
					          		<%
					          		boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
					          		String csrfTokenName="";
					          		String csrfTokenValue="";
					          		if(csrfEnabled)
					          		{
					          			Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
					          			csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
					          			csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
				          				          			
					          		}
					          		System.out.println("CSRFINJECTION");
					          		%>
					          		var strURL = "../requirements/SpecificationStructureUtil.jsp?";
					          		strURL += "mode=SubmitSourceTargetSelection";
					          		strURL += "&subMode=<xss:encodeForJavaScript><%=strSubMode%></xss:encodeForJavaScript>";
					          		strURL += "&operation=LinkExisting";
					          		strURL += "&subOperation=<xss:encodeForJavaScript><%=strSubOperation%></xss:encodeForJavaScript>";
					          		strURL += "&sourceIds=<xss:encodeForJavaScript><%=strSourceIds%></xss:encodeForJavaScript>";
					          		strURL += "&targetIds=<xss:encodeForJavaScript><%="dummy|" + newObjectId + "|dummy|dummy"%></xss:encodeForJavaScript>";
								strURL += "<%=csrfEnabled ? ("&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "= " + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue ) : ""%>";<%--XSSOK--%>
								 //KIE1 ZUD TSK447636 
					          		getTopWindow().getWindowOpener().parent.frames["listHidden"].location.href = strURL;
					          	}
					    	}
				    	</script>
<%					
			    	}
			    	else
			    	{
			    		if("CreateSubDerived".equals(strOperation) || "SpecStructureNewSubDerivedReq".equals(strOperation))
			    		{
		   	        		 SAXBuilder builder = new SAXBuilder();
		   	        		 builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
		   	        		 builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
		   	        		 builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
		   	        		 newRelId = builder.build(new StringReader(xmlMessage)).getRootElement().getAttributeValue("relId"); //relId to the parent requirement
			        		 
			        		 xmlMessage = "<mxRoot><action>add</action><data status=\"committed\"" + 
				    			("true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB")) ? " fromRMB=\"true\"" : "") + ">" + 
				    			xmlMessage + "</data></mxRoot>";
				    			
				    		 if("SpecStructureNewSubDerivedReq".equals(strOperation))
				    		 {
				    		    String strTargetSpecification  = emxGetParameter(request, "RequirementTargetSpecification");
								String strLocale = context.getSession().getLanguage();
						
								if("ForSubRequirement".equalsIgnoreCase(strSubMode))
							    {
								    strStatusMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Status.SubRequirementCreated"); 
							    }
							    else
							    {
									strStatusMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Status.DerivedRequirementCreated"); 
							    }
								if(!strTargetSpecification.equals(""))
								{
								    StringTokenizer sourceToken = new StringTokenizer(strTargetSpecification, ",");
								    while(sourceToken.hasMoreTokens()){
									 	String strTargetSpecificationSelectionParameter = sourceToken.nextToken();
									 	    if(strTargetSpecificationSelectionParameter != null){
	%>
									 			<script language="JavaScript">
									 				try{
														var sbWindow = findFrame(getTopWindow(), "detailsDisplay");
														if(!sbWindow) {
															sbWindow = findFrame(getTopWindow(), "content");
														}
														<%-- relId below doesn't seem to be correct --%>
														sbWindow.emxEditableTable.addToSelected('<mxRoot><action>add</action><data fromRMB="true" status="committed" >' + 
									        			'<item location="appendChild" oid="<xss:encodeForJavaScript><%=newObjectId%></xss:encodeForJavaScript>" relId="<xss:encodeForJavaScript><%=newRelId%></xss:encodeForJavaScript>" pid="<xss:encodeForJavaScript><%=strTargetSpecificationSelectionParameter%></xss:encodeForJavaScript>"/></data></mxRoot>');
									 				}catch(e){}
												</script>
	<%
									 	    }
								    }
								}
				    		 }
				    	}
				    	else //create objects in spec structure
				    	{
						    xmlMessage = "<mxRoot><action>add</action><data status=\"committed\"" + 
						    			("true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB")) ? " fromRMB=\"true\"" : "") + 
						    			(xmlMessage.indexOf("pasteAboveToRow") > 0 ? " pasteBelowOrAbove=\"true\"" :"") + ">" + 
						    			xmlMessage + "</data></mxRoot>";
				    	}
%>
<script language="javascript">

	//Set the rich Text
	var windowDocument = findFrame(getTopWindow(), 'slideInFrame');
	
	// It can means it's from CATIA
	if (!windowDocument) {
		windowDocument = getTopWindow();
	}
	
	if (windowDocument && windowDocument.objectCreationType && windowDocument.objectCreationContentData) {
		var data = new FormData();
	    data.append('type', windowDocument.objectCreationType);
	    data.append('objectId', "<xss:encodeForJavaScript><%=newObjectId%></xss:encodeForJavaScript>");
	    data.append('contentText', windowDocument.objectCreationContentText);
	    data.append('contentData', windowDocument.objectCreationContentData); //must be last item!! 
	
	    windowDocument.jQuery.ajax({
	        type: 'POST',
	        cache: false,
	        contentType: false,
	        processData: false,
	        url: "../resources/richeditor/res/setRichContent" + "?" + windowDocument.objectCreationCsrfParams,
	        data: data,
	        complete: function(data) {
	        	// NOP
	        },
            error: function(xhr, status, error){
            	var message = typeof xhr.responseText == 'string' ? JSON.parse(xhr.responseText).status : xhr.responseText; 
            	alert(error + ":" + message);
            },
	        dataType: 'text',
	        async: false
	    });
	}

	var sbWindow = findFrame(getTopWindow(), "detailsDisplay");
	if(!sbWindow) {
		sbWindow = findFrame(getTopWindow(), "content");
	}

	// ++ ZUD Fix For IR-233654V6R2014x ++ 
	if(<xss:encodeForJavaScript><%="SpecStructureNewSubDerivedReq".equals(strOperation)%></xss:encodeForJavaScript> || 
			<xss:encodeForJavaScript><%="CreateSubDerived".equals(strOperation)%></xss:encodeForJavaScript> )
	{
		 refreshStructureTree();		 
	}
	
	// -- ZUD Fix For IR-233654V6R2014x --

	
	
	if(<xss:encodeForJavaScript><%="SpecStructureNewSubDerivedReq".equals(strOperation)%></xss:encodeForJavaScript>)
	{
		if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.isRichTextEditor){
			sbWindow.emxEditableTable.refreshObject();  
	    }
	    else if(sbWindow && sbWindow.refreshRows)
		{
			//sbWindow.refreshRows();
	  	}
		getTopWindow().status = "<xss:encodeForJavaScript><%=strStatusMsg%></xss:encodeForJavaScript>";
	}
	if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.addToSelected){

		<%
		DomainRelationship relObject = null;
		String relType = null;
		if(newRelId!=null){
			relObject = DomainRelationship.newInstance(context,newRelId);
			relObject.openRelationship(context);
			relType = relObject.getTypeName();
			relObject.close(context);
			//START Don't display derived requirements on creation in table
			if(! ReqSchemaUtil.getDerivedRequirementRelationship(context).equalsIgnoreCase(relType)){
			%>
				sbWindow.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
			<%
			}
			else{
			%>
				var Url = "../common/emxTree.jsp?objectId=<xss:encodeForJavaScript><%=newObjectId%></xss:encodeForJavaScript>";
				getTopWindow().showNonModalDialog(Url, 900, 600,true );
			<%
			}
		}else{
			%>
			sbWindow.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
			<%
		}
			%>
		//STOP : Don't display derived requirements on creation in table
		//IR-117952V6R2012x
		if(<xss:encodeForJavaScript><%="SpecStructureNewSubDerivedReq".equals(strOperation)%></xss:encodeForJavaScript> && !sbWindow.emxEditableTable.isRichTextEditor){
			var rowId = "<xss:encodeForJavaScript><%=strTableRowId%></xss:encodeForJavaScript>".split("|")[3];
	        var aRowsSelected = sbWindow.emxUICore.selectNodes(sbWindow.oXML,"/mxRoot/rows//r[@id='" + rowId + "']"); 
	        
	        //var expand = nRow.getAttribute("expand");
	        //if(!expand) {
	        //sbWindow.expandPasteRows(aRowsSelected);
	        //}
	        
	        var newChild = sbWindow.emxUICore.selectNodes(aRowsSelected[0],"/mxRoot/rows//r[@r='<xss:encodeForJavaScript><%=newRelId%></xss:encodeForJavaScript>']");
	        //START : Don't display derived requirements on creation in table
	        if(newChild.length == 0){
	        	<%
	        	if(! ReqSchemaUtil.getDerivedRequirementRelationship(context).equalsIgnoreCase(relType)){
	        	%>
	    			sbWindow.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
	    		<%
	        	}
	        	%>
	        }
	        //END : Don't display derived requirements on creation in table
		}
	}
	
</script>	
<%
				    }
				//End V6R2010xHF1
	            }//xmlMessage
            }//PostProcessJPO
	    	
    } catch(Exception exp) {

        matrix.db.Context context = (matrix.db.Context)request.getAttribute("context");
        String errorLock = "";
        
        try {
	        StringList selectStmts = new StringList("reserved");
	        selectStmts.addElement("name");
	        selectStmts.addElement("reservedby");
	        selectStmts.addElement("reservedcomment");
	        selectStmts.addElement("reservedstart");
	
	        StringList slIds = FrameworkUtil.split((String) UINavigatorUtil.getRequestParameterMap(pageContext).get("emxTableRowId"), "|");
	        
	        DomainObject domObj = DomainObject.newInstance(context, (String) slIds.get(0));
	        Map<String, String> ReservedInfo = (Map<String, String>) domObj.getInfo(context, selectStmts);
	        String reserved = (String) ReservedInfo.get("reserved");
	
	        
	        if(reserved.equalsIgnoreCase("true")) {
	            String nameObject = (String) ReservedInfo.get("name");
	            String reservedby = (String) ReservedInfo.get("reservedby");

	            errorLock = "\n" + " \n" + nameObject + " " + EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxFramework.Basic.ReservedBy") + 
	                    " " + reservedby + "."; 
	        }
        } catch(Exception ex) {
            // NOP
        }
        
        String errorMessage = exp.toString();
        if (errorMessage != null && errorMessage.length() > 0) {
            if (errorMessage.indexOf("not unique") > 0) {
                errorMessage = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.NotUniqueMsg"); 
            }
        }
	    emxNavErrorObject.addMessage(errorMessage + errorLock);
	}
%>


