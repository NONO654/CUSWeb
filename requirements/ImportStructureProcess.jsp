<%--  ImportStructureProcess.jsp
   

   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<!-- /*
* @quickreview LX6 QYG 14 Nov 12("Enhancement of import Existing Structure performance")
* @quickreview LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
* @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
* @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
* @quickreview HAT1 ZUD 02:11:17 :IR-559728-3DEXPERIENCER2018x: R419-STP: For Partial Structure duplication  "Duplication string" is not getting apply to duplicated Req objects.   
*/ -->
<%@page import="com.dassault_systemes.requirements.ReqConstants"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import = "java.util.*"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%@page import="com.matrixone.apps.requirements.SpecificationStructure"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<html>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<head>
<%!
	
	void AddParam(javax.servlet.http.HttpServletRequest request, Map params, String key)
	{
		String value = emxGetParameter(request, key);
		if(value != null){
			params.put(key, value);
		}
	}
	
	String getCopyWithLinkParameter(String[] tokens)
	{
		String CopyWithLink  = "false";
		for(int i = 0; i < tokens.length; i++)
		{
			if(tokens[i].contains(ReqConstants.COPY_WITH_LINK))
			{
				String Values[] = tokens[i].split(":");
				CopyWithLink = Values[1];
			}
		}
		return CopyWithLink;
	}

	 String getFromWebAppParameter(String[] tokens)
	  {
	    String isFromWebApp  = "false";
	    for(int i = 0; i < tokens.length; i++)
	    {
	      if(tokens[i].contains(ReqConstants.FROM_WEB_APP))
	      {
	        String Values[] = tokens[i].split(":");
	        isFromWebApp = Values[1];
	      }
	    }
	    return isFromWebApp;
	  }
	
 %>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
	try{
		Map params = new HashMap();

		String options = emxGetParameter(request,"options");
		if(options != null){
			String[] tokens = options.split("[;]");
			for(int i = 0; i < tokens.length; i++){
				String token = tokens[i];
				String[] items = token.split("[:]");
				if(items.length == 2){
					params.put(items[0], items[1]);
				}
			}
			PropertyUtil.setGlobalRPEValue(context, ReqConstants.COPY_WITH_LINK, getCopyWithLinkParameter(tokens));
			PropertyUtil.setGlobalRPEValue(context, ReqConstants.FROM_WEB_APP, getFromWebAppParameter(tokens));
		}
		
	  	String key = (String)params.get("key"); 
		if(key != null){ 
	  		Map otherParams = (Map)session.getAttribute(key);
	  		if(otherParams != null){
				params.putAll(otherParams);
			}
		}
		
		// ++ HAT1 ZUD: IR-559728-3DEXPERIENCER2018x fix ++
		String perfixValue = (String)params.get("prefix");
		if(perfixValue == null || "null".equalsIgnoreCase(perfixValue))
		{
			perfixValue = "";
			params.put("prefix",perfixValue);
		}
 		// -- HAT1 ZUD: IR-559728-3DEXPERIENCER2018x fix --
		
//START LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
		String isCopyreqSpec = (emxGetParameter(request,"copyReqSpec")==null)?"false":emxGetParameter(request,"copyReqSpec");
//END LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications		
		AddParam(request, params, "xmlmsg");
		AddParam(request, params, "selectedProgram");
		AddParam(request, params, "prefix");
		
		AddParam(request, params, SpecificationStructure.PARAM_DIRECTION);
		AddParam(request, params, SpecificationStructure.PARAM_RELATIONSHIP);
		AddParam(request, params, SpecificationStructure.PARAM_SELECTED_RELATIONSHIP);
		AddParam(request, params, SpecificationStructure.PARAM_TYPE);
		AddParam(request, params, SpecificationStructure.PARAM_SELECTED_TYPE);
		
		ContextUtil.startTransaction(context, true);
		String Clonedobject = null;
//START LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
		if(isCopyreqSpec.equalsIgnoreCase("true"))
		{
			//it's an duplicate requirement Specification
			String reqSpecToClone = emxGetParameter(request, "emxTableRowId").split("[|]")[1];
			//clone the root object for duplication
			Clonedobject = SpecificationStructure.CloneObject(context, params, reqSpecToClone);
			//use it to import all objects
			params.put("emxTableRowId", "|" +reqSpecToClone + "|");
			params.put("targetTableRowId", "|" +Clonedobject + "|");
			String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
			if(selectedItems !=null){
				String[] objectsId=new String[selectedItems.length];
				for(int i = 0;i<selectedItems.length;i++){
					objectsId[i] = selectedItems[i].split("[|]")[1];
				}
				params.put("selectedObjectIds", Arrays.toString(objectsId));
			}
		}
		else
		{
			if(!"true".equalsIgnoreCase(emxGetParameter(request, "isComplete"))){
				String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
				if(selectedItems !=null){
					String[] objectsId=new String[selectedItems.length];
					for(int i = 0;i<selectedItems.length;i++){
						objectsId[i] = selectedItems[i].split("[|]")[1];
					}
					params.put("selectedObjectIds", Arrays.toString(objectsId));
				}
			}
			//it's the import stucture feature 
			AddParam(request, params, "emxTableRowId");	
		}
//END LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
		//START:LX6:Import structure performance
		SpecificationStructure SpecStruct = new SpecificationStructure();
		SpecStruct.ImportStructure(context, params);
		ContextUtil.commitTransaction(context);
		//END:LX6:Import structure performance
 %>
<script language="javascript" type="text/javaScript">
	<%
	if(isCopyreqSpec!=null&&isCopyreqSpec.equalsIgnoreCase("true"))
	{
		DomainObject object = DomainObject.newInstance(context, Clonedobject);
		object.openObject(context);
		String objectType = object.getType(context);
		if(object.isKindOf(context, ReqSchemaUtil.getRequirementSpecificationType(context))){
			objectType = ReqSchemaUtil.getRequirementSpecificationType(context);
		}else if(object.isKindOf(context, ReqSchemaUtil.getRequirementType(context))){
			objectType = ReqSchemaUtil.getRequirementSpecificationType(context);
		}
		objectType = objectType.replace(" ","_");
		String menu = EnoviaResourceBundle.getProperty(context, "emxRequirements.getStructureMenu."+objectType);
		%>
		var href = "../common/emxTree.jsp?mode=insert&emxSuiteDirectory=requirements&suiteKey=Requirements&objectId=<xss:encodeForJavaScript><%=Clonedobject%></xss:encodeForJavaScript>";
		 //KIE1 ZUD TSK447636 
		getTopWindow().getWindowOpener().location.href = href; 
	<%
	}
	else
	{
	%>
	 //KIE1 ZUD TSK447636 
		if(getTopWindow().getWindowOpener().emxEditableTable && getTopWindow().getWindowOpener().emxEditableTable.isRichTextEditor){
	        //richtexteditor
	        getTopWindow().getWindowOpener().parent.refreshSCE();
	    }
	    else{
	    	//IYI1 IR-498810
			//getTopWindow().getWindowOpener().parent.document.location.href = getTopWindow().getWindowOpener().parent.document.location.href;
	    	getTopWindow().getWindowOpener().parent.editableTable.loadData();
	    	getTopWindow().getWindowOpener().parent.emxEditableTable.refreshStructureWithOutSort();

	    }	
		//getTopWindow().opener = "x";
	<%
	}
	%>
	 //KIE1 ZUD TSK447636 
	getTopWindow().closeWindow();
</script>
<%
		if(key!= null){
			session.removeAttribute(key);
		}
    }
    catch(Exception ex)
    {
    	ContextUtil.abortTransaction(context);
    	String msg = ex.getMessage();
    	if(msg == null || "".equals(msg)){
    		msg = ex.toString();
    	}
    	session.putValue("error.message", msg);
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</head>
<body>
</body>
</html>
