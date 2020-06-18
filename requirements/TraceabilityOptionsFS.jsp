<%-- TraceabilityOptionsFS.jsp

Copyright (c) 2007-2018 Dassault Systemes.

All Rights Reserved.
This program contains proprietary and trade secret information
of MatrixOne, Inc.  Copyright notice is precautionary only and
does not evidence any actual or intended publication of such program.
--%>
<%--
 @quickreview QYG ---	12:09:06(IR-187893			"Fulfillment Report and Traceability Report from Product Context is KO, if no requirements selected from list.")
 @quickreview QYG ---	12:08:25(IR-185730V6R2013x  "Requirement-TestCase Traceability Report is KO from Requirement list page. ")
 @quickreview LX6 QYG	12:08:24(IR-123051V6R2013x  "FIR : No message on invoking invalid commands for Group in list view. ")
 @quickreview JX5 QYG	13:06:04(IR-235268V6R2014	"STP: Multiple selection is KO for Traceability report for Specification or Requirement from list page.")
 @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
 @quickreview HAT1 ZUD 17:12:22 : IR-531745-3DEXPERIENCER2018x: R20-NLS: Name and Revision on the Traceability windows is No Translated.
 --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="matrix.util.List"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UIPortal"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%
//Start:IR:1230516R2013x:LX6
boolean isError = false;
try
  {
//End:IR:1230516R2013x:LX6
	// Extract the Table Row ids of the checkboxes selected, if any.
//JX5 start IR-235268V6R2014
	String emxRowInfo = emxGetParameter(request,"RowInfo");
	String emxTableRowId[];
	if(emxRowInfo == null || emxRowInfo.equals("") || emxRowInfo.equals("null"))
	{
		emxTableRowId = emxGetParameterValues(request,"emxTableRowId");
	}
	else{
		emxTableRowId = emxRowInfo.split(":");
	}
//JX5 end IR-235268V6R2014
	
	String objectId = emxGetParameter(request,"objectId");
	String CFFFilterExpr = emxGetParameter(request,"CFFExpressionFilterInput_OID");
//Start:IR:1230516R2013x:LX6
	if(emxTableRowId != null){
		boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,emxTableRowId);
		if(isRequirementGroupInList == true)
		{
			isError = true;
		  throw new Exception("invalidForReqGroup");
		}
	}
//End:IR:1230516R2013x:LX6
	String hiddenParams = "";
	String forNext = "";
	if (objectId != null && !objectId.equals(""))
	{
	   hiddenParams = objectId;
	   forNext = objectId;
	}
	else if (emxTableRowId != null)
	{
	   for (int kk = 0; kk < emxTableRowId.length; kk++)
	   {
	      String itemId = emxTableRowId[kk];
	
         StringList sl = FrameworkUtil.split(itemId, "|");
         if(sl.size() == 3)
         {
        	 itemId = (String) sl.get(0);
         }
         else if(sl.size() == 4)
         {
        	 itemId = (String) sl.get(1);
         }

	      if (kk == 0)
	      {
	         hiddenParams = itemId;
	         objectId = itemId;
	      }
	      else
	      {
	         hiddenParams += "," + itemId;
	      }
	   }
	}
	
	String strObjType = "Requirement";
	if (objectId != null && !objectId.equals(""))
	{
	   DomainObject domObj = DomainObject.newInstance(context, objectId);
	   String objectType = domObj.getInfo(context, DomainConstants.SELECT_TYPE);
	
	   List lstSpecChildTypes = ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getRequirementSpecificationType(context));
	   lstSpecChildTypes.add(ReqSchemaUtil.getRequirementSpecificationType(context));
	
	   List lstProdChildTypes = ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getProductsType(context));
	   lstProdChildTypes.add(ReqSchemaUtil.getProductsType(context));
	
	   if ( lstSpecChildTypes.contains(objectType) )
	      strObjType = "Specification";
	   else if ( lstProdChildTypes.contains(objectType) )
	      strObjType = "Product";
	}
	
	String strRepType = emxGetParameter(request, "reportType");
	if(strRepType == null || strRepType.equals(""))
	{
	   strRepType = "Requirement";
	}
	
	
	//Added:26-May-09:kyp:V6R2010x:RMT Requirements Allocation Report
	// Following code is to take care optional selection of requirements under product
	// If this is Requirement report then
	//         If it is run on Product then
	//                 If user has selected any requirements then
	//                        Consider these requirements only and generate report
	//                        Change object type to Requirement
	//                 Else
	//                        Consider the product and generate report for all the requirements under it.
	//                 End if
	//         Else
	//                 Proceed normally
	//         End if
	// End if
	//
	if ("Requirement".equals(strRepType) && 
			("Product".equals(strObjType) || "Requirement".equals(strObjType)) 
				&& emxTableRowId != null) {
	    strObjType = "Requirement";
	    for (int kk = 0; kk < emxTableRowId.length; kk++)
	    {
	       String itemId = emxTableRowId[kk];
		   
		   String[] tokens = itemId.split("[|]", -1);
		   if(tokens.length >= 2){
			   itemId = tokens[1];
		   }
	       
	       if (kk == 0)
	       {
	          hiddenParams = itemId;
	          objectId = itemId;
	       }
	       else
	       {
	          hiddenParams += "," + itemId;
	       }
	    }
	}
	if ("Specification".equals(strObjType) && emxTableRowId != null)
	{
	    for (int kk = 0; kk < emxTableRowId.length; kk++)
	    {
	       String itemId = emxTableRowId[kk];
	       
	       StringList sl = FrameworkUtil.split(itemId, "|");
	      if(sl.size() == 3)
	      {
		  	itemId = (String) sl.get(0);
	      }
	      else if(sl.size() == 4)
	      {
		  	itemId = (String) sl.get(1);
	      }
	      else
	      {
		  itemId = itemId;
	      }
	      
	       if (kk == 0)
	       {
	          hiddenParams = itemId;
	          objectId = itemId;
	       }
	       else
	       {
	          hiddenParams += "," + itemId;
	       }
	    }
	}
	//End:V6R2010x:RMT Requirements Allocation Report
	
	framesetObject fs = new framesetObject();
	fs.setDirectory(appDirectory);
	fs.setStringResourceFile("emxRequirementsStringResource");
	
	// ----------------- Do Not Edit Above ------------------------------
	
	// Specify URL to come in middle of frameset
	String contentURL = "TraceabilityOptions.jsp";
	
	String HelpMarker2 = emxGetParameter(request, "HelpMarker2");
	
	// add these parameters to each content URL, and any others the App needs
	//String CFFFilterExpr = emxGetParameter(request,"CFFExpressionFilterInput_OID");
	contentURL += "?emxTableRowId=" + hiddenParams + "&selectedType=" + strObjType + "&reportType=" + strRepType + "&forNext=" +forNext +
					((HelpMarker2 == null || HelpMarker2.equals("") )? "" : ("&HelpMarker2=" + HelpMarker2)) 
					+ ((CFFFilterExpr == null || CFFFilterExpr.equals("") )? "" : ("&CFFExpressionFilterInput_OID=" + CFFFilterExpr))
					+ "&objectId=" + objectId;   //HAT1 ZUD IR-531745-3DEXPERIENCER2018x fix.
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	String HelpMarker = emxGetParameter(request, "HelpMarker");
	if(HelpMarker == null || HelpMarker.equals(""))
	{
		HelpMarker = "emxhelptraceabilityreportoptions";
	}
	
	
	fs.initFrameset("emxRequirements.TraceabilityReport.OptionsHeader", HelpMarker,
	                contentURL, false, false, false, false);
	/*
	fs.createFooterLink("emxRequirements.Button.Done", "validateForm()",
	                    "role_GlobalUser", false, true, "emxUIButtonDone.gif", 1);
	*/
	//fs.createFooterLink("emxRequirements.Button.Cancel", "cancel()",
	//                    "role_GlobalUser", false, true, "emxUIButtonCancel.gif", 1);
	
	// ----------------- Do Not Edit Below ------------------------------
	fs.writePage(out);
//Start:IR:1230516R2013x:LX6
  }
	catch(Exception e)
	{
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
	}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript" ></script>
<script type="text/javascript">
<%
if(isError == true)
{
%>
//KIE1 ZUD TSK447636 
getTopWindow().closeWindow();
<%
}
%>
</script type="text/javascript">
<!-- //End:IR:1230516R2013x:LX6 -->
