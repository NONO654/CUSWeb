<%--  SpecificationCreateFS.jsp
   FrameSet page for Create Requirement Specification dialog

   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<!-- /*
* @quickreview LX6 18 Sep 12("Enhancement of import Existing Structure : filtering of the import list")
* @quickreview LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
* @quickreview KIE1 ZUD 23:08:17 :IR-543286-3DEXPERIENCER2018x: duplicate command not using autonaming
*/ -->
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.dassault_systemes.requirements.ReqConstants"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.framework.ui.framesetObject"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%
  boolean bFlag = false;
  try
  {
	  framesetObject fs = new framesetObject();
	  fs.setDirectory(appDirectory);
//START :LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	  String isCopyReqSpec = (emxGetParameter(request,"copyReqSpec")==null)?"false":emxGetParameter(request,"copyReqSpec");
	  String copyReqSpecparameter = "&copyReqSpec="+isCopyReqSpec;
//END :LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	  String suiteKey     = emxGetParameter(request, "suiteKey");
	  String objectId =  emxGetParameter(request, "objectId");
	  String targetTableRowId = emxGetParameter(request, "emxTableRowId");
		//String typesProperty = emxGetParameter(request, "typelist");
		String relationshipProperty = emxGetParameter(request, "relationshiplist");
	
		String TargetId = targetTableRowId.split("[|]")[1];
		DomainObject Object = DomainObject.newInstance(context, TargetId);
		String ObjectType = Object.getType(context);
	  if(Object.isKindOf(context, ReqSchemaUtil.getRequirementGroupType(context))){
		  //Duplicate not allowed for specification folder
		  throw new Exception("DuplicateSpecFodlerNotAllowed");  
	  }

		Map options = new HashMap();
		String paramValue = targetTableRowId;
		if(paramValue != null){
			options.put("targetTableRowId", paramValue);
		}
		paramValue = emxGetParameter(request,"connectProgram");
		if(paramValue != null){
			options.put("connectProgram", paramValue);
		}
		// adding to autoname to map as we are using only autoname
		options.put("autoName","true");
		paramValue = emxGetParameter(request,"connectFunction");
		if(paramValue != null){
			options.put("connectFunction", paramValue);
		}
		paramValue = emxGetParameter(request,"completeExpandProgram");
		if(paramValue != null){
			options.put("completeExpandProgram", paramValue);
		}
		paramValue = emxGetParameter(request,"completeExpandFunction");
		if(paramValue != null){
			options.put("completeExpandFunction", paramValue);
		}
		paramValue = emxGetParameter(request,"expandProgramMenu");
		if(paramValue != null){
			if(paramValue.equals("RMTSpecTreeProgramMenu") == true)
			{
				options.put("expandProgramMenu", "RMTSpecTreeImportProgramMenu");
			}
			else
			{
				options.put("expandProgramMenu", paramValue);
			}
		}
		paramValue = emxGetParameter(request,"sbTableMenu");
		if(paramValue != null){
			options.put("sbTableMenu", paramValue);
		}
		paramValue = emxGetParameter(request,"freezePane");
		if(paramValue != null){
			options.put("freezePane", paramValue);
		}
		paramValue = emxGetParameter(request,"sbSortColumnName");
		if(paramValue != null){
			options.put("sbSortColumnName", paramValue);
		}
		paramValue = emxGetParameter(request,"selectedTable");
		if(paramValue != null){
			options.put("selectedTable", paramValue);
		}
		paramValue = emxGetParameter(request,"selectedProgram");
		if(paramValue != null){
			options.put("selectedProgram", paramValue);
		}
	 //this parameter is used in the copy trigger to define if we pass through the WebApp or CATIA
	  paramValue = emxGetParameter(request,ReqConstants.FROM_WEB_APP);
	    if(paramValue != null){
	      options.put(ReqConstants.FROM_WEB_APP, paramValue);
	    }
		paramValue = relationshipProperty;
		if(paramValue != null){
	        options.put("relationshiplist", paramValue);
	    }
		
		long number = new Random(System.currentTimeMillis()).nextLong();
		String key = "import" + System.currentTimeMillis() + "_" + number;
		session.setAttribute(key, options);
	
	    // Specify URL to come in middle of frameset
	    String contentURL  = "ImportStructureOptions.jsp";
//START :LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
//Start:LX6:Enhancement of the import structure list
	    contentURL += "?suiteKey=" + suiteKey + "&specIdToExclude=" + objectId + "&key=" + key + "&selectedObject=" + targetTableRowId + copyReqSpecparameter;
//End:LX6:Enhancement of the import structure list
//END :LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	    // Marker to pass into Help Pages
	    // icon launches new window with help frameset inside
	    String HelpMarker  = "emxhelpspecimport1";
	    String Header = "";
	    if(isCopyReqSpec.equalsIgnoreCase("true")){
	    	Header      = "emxRequirements.DuplicateReqSpec.Heading.Step1";
	    }
	    else{
	    	Header      = "emxRequirements.ImportStructure.Heading.Step1"; 
	    }
	
	    fs.initFrameset(Header,
	                    HelpMarker,
	                    contentURL,
	                    false,
	                    true,
	                    false,
	                    false);
	
	    fs.setStringResourceFile("emxRequirementsStringResource");
//START :LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	    if(isCopyReqSpec.equalsIgnoreCase("true"))
	    {
	    	fs.createFooterLink("emxRequirements.SCE.Button.Ok",
                    "duplicateReqSpec()",
                    "role_GlobalUser",
                    false,
                    true,
                    "common/images/buttonDialogNext.gif",
                    0);
	    }
	    else
	    {
	    	fs.createFooterLink("emxRequirements.Button.Next",
                    "submitForm()",
                    "role_GlobalUser",
                    false,
                    true,
                    "common/images/buttonDialogNext.gif",
                    0);
	    }
	      //KIE1 ZUD TSK447636 
//END :LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
    	fs.createFooterLink("emxRequirements.Button.Cancel",
                "parent.closeWindow();",
                "role_GlobalUser",
                false,
                true,
                "common/images/buttonDialogCancel.gif",
                0);
	
	    fs.writePage(out);
	  }
    catch (Exception e)
    {
    	  bFlag = true;
        String strAlertString = "emxRequirements.Alert." + e.getMessage();
        String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), strAlertString);
        if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
        {
            session.putValue("error.message", e.getMessage());
        }
        else
        {
            session.putValue("error.message", i18nErrorMessage);
        }
     %>   

<% 
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
if (bFlag == true)
{
%>
    <script language="javascript" type="text/javaScript">
      //KIE1 ZUD TSK447636 
    window.getTopWindow().closeWindow();
    </script>
<%
}
%>
