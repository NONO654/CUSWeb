<%--  emxEngrIntermediateSearchUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
	String strForm = emxGetParameter(request,"formName");
	String field = emxGetParameter(request,"field");
	// 374591
	//String strECRPolicyClassification = FrameworkProperties.getProperty(context, "emxEngineeringCentral.CreateECRPolicyDefault");
    String policyName = PropertyUtil.getSchemaProperty(context,"policy_ECR");
	if (strForm.indexOf("edit")!= -1) {
		String objectId = emxGetParameter(request,"objectId");
		DomainObject obj = new DomainObject(objectId);
		policyName = obj.getInfo(context, "policy");
	}
    String policyClassification = FrameworkUtil.getPolicyClassification(context, policyName);

     String strLanguage = request.getHeader("Accept-Language");
     String strContentURL = "../common/emxFullSearch.jsp?" + emxGetQueryString(request) + "&HelpMarker=emxhelpfullsearch";

     //get the selected Objects from the Full Search Results page
     //If the selection is empty given an alert to user

	  // if the chooser is in the Custom JSP


	  String strValidateField = emxGetParameter(request,"validateField");

	  // 374591
	  if (strValidateField != null && !("StaticApproval".equals(policyClassification) && strValidateField.indexOf("ChangeResponsibilityOID") != -1))
	  {

		  String strMesage = "";

		  // 374591
		  if ("ChangeResponsibilityOID".equals(strValidateField))
		  {
			 strMesage = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.ChangeResponsibilityAlert", strLanguage);
		  }
		  //Modified For MBOM
                  else if ("DesignResponsibilityOID".equals(strValidateField) || "RDOOID".equals(strValidateField) || "ManufacturingResponsibility".equals(strValidateField) || "txtPlantID".equals(strValidateField))
		  {
			strMesage = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.DesignResponsibilityAlert", strLanguage);
		  }

   %>
   <script language="javascript" src="../common/scripts/emxUICore.js"></script>
  <script language="javascript" type="text/javaScript">

var vfieldNameValidate = "";
var temp = "";
//XSSOK
var valField = "<%=XSSUtil.encodeForJavaScript(context,strValidateField)%>";
//XSSOK
var formName = "<%=XSSUtil.encodeForJavaScript(context,strForm)%>";
var fieldResponsibility = "";

if (valField == "DesignResponsibilityOID")
{
	vfieldNameValidate = eval("getTopWindow().getWindowOpener().document." + formName + "." + valField);
	temp = vfieldNameValidate.value;
//modified for 373823
	//fieldResponsibility = "DesignResponsibilityDisplay";
	fieldResponsibility = "DesignResponsibilityOID";
}
else if (valField == "ChangeResponsibilityOID")
{
	vfieldNameValidate = getTopWindow().getWindowOpener().document.getElementsByName("ChangeResponsibility");
	temp = vfieldNameValidate[0].value;
	if (temp == "" || temp.indexOf(".") == -1){
		vfieldNameValidate = getTopWindow().getWindowOpener().document.getElementsByName("ChangeResponsibilityOID");
		temp = vfieldNameValidate[0].value;
		//377419
		fieldResponsibility = "ChangeResponsibilityOID";
	}
//modified for 373823
				//fieldResponsibility = "ChangeResponsibilityDisplay";
		//377419
		else{
			fieldResponsibility = "ChangeResponsibility";
		}		
			
				
}
else if (valField == "RDOOID")
{
	vfieldNameValidate = eval("getTopWindow().getWindowOpener().document." + formName + "." + valField);
	temp = vfieldNameValidate.value;
//modified for 373823	
	//fieldResponsibility = "RDODisplay";
	fieldResponsibility = "RDOOID";
}
//Added for MBOM
//373823
else if (valField =="ManufacturingResponsibilityOid")
{
	vfieldNameValidate = eval("parent.window.getWindowOpener().document."+formName+"."+valField);
	temp = vfieldNameValidate.value;
//modified for 373823	
	//fieldResponsibility = "ManufacturingResponsibilityDis";
	fieldResponsibility = "ManufacturingResponsibilityOid";
}
else if (valField =="txtPlantID")
{
	vfieldNameValidate = eval("parent.window.getWindowOpener().document."+formName+"."+valField);
	temp = vfieldNameValidate.value;
//modified for 373823	
	//fieldResponsibility = "txtPlantIDDis";
	fieldResponsibility = "txtPlantID";
}
//End: Added for MBOM

	                      if(temp != "")
	                      {
				var desResponsibilityFiled = eval("getTopWindow().getWindowOpener().document." + formName + "." + fieldResponsibility);
				var desResponsibility = desResponsibilityFiled.value;
				//XSSOK
				var field = "<%=XSSUtil.encodeForJavaScript(context,field)%>";
				//XSSOK
				var contentURL = "<%=XSSUtil.encodeForJavaScript(context,strContentURL)%>";
				var fieldModified = field + ":MEMBER_ID=" + desResponsibility;
				contentURL = contentURL.replace(field, fieldModified);
				document.location.href = contentURL + "&orgId="+temp;
							}
							else
							{
							//XSSOK	
							alert("<%=strMesage%>");
							getTopWindow().closeWindow();
							}

	                    </script>
	               <%
	          }
	          else
	          {
	          %>
	          <script language="javascript" type="text/javaScript">
		  //XSSOK
	          document.location.href = "<%=XSSUtil.encodeForJavaScript(context,strContentURL)%>";
	          </script>
	      <%
	     }
	     %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
