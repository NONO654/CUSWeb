<%--  emxPackagesConfigurationActivationUniquenessKey.jsp  --  Edit constrained attributes
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPackagesConfigurationActivationUniquenessKey.jsp.rca 1.1 Wed Jan 14 05:57:06 2009 ds-smourougayan Experimental przemek $
  --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil,
				com.dassault_systemes.DictionaryPackagesMngtModelUI.CustoConfigUniquenessKeyActivation,
				com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
				

<%

Enumeration eNumParameters = emxGetParameterNames(request);
String typName = "";
String paramValue = "";
String tableRowIds[] = null;
ArrayList<String> addTypes =new ArrayList<String>();
ArrayList<String> valuesOfTypesToAdd= new ArrayList<String>();
ArrayList<String> removeTypes =new ArrayList<String>();
ArrayList<String> valuesOfTypesToRemove= new ArrayList<String>();
String typesToRemove=""; 
String typesToAdd="";
while( eNumParameters.hasMoreElements() ) {
	String parmName  = (String)eNumParameters.nextElement();
	if(parmName !=null && parmName.endsWith("Combo")){
	//System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
		typName = parmName.substring(0,parmName.indexOf("Combo"));
		//System.out.println("type name : "+typName);
		
		paramValue = emxGetParameter(request, parmName);
		if(paramValue!=null && paramValue.equals("TRUE")){			
			if(CustoConfigUniquenessKeyActivation.checkExistenceOfTypeInMxTNRFromAdmin(context,typName).equals("FALSE")){
				typesToAdd=typesToAdd+typName+", ";	
				valuesOfTypesToAdd.add(paramValue);	
				addTypes.add(typName);				
			}
		}else if(paramValue.equals("FALSE")){
			if(CustoConfigUniquenessKeyActivation.checkExistenceOfTypeInMxTNRFromAdmin(context, typName).equals("TRUE")){
				typesToRemove=typesToRemove+typName+", ";	
				valuesOfTypesToRemove.add(paramValue);	
				removeTypes.add(typName);	
			}
		}
		
	}
}
//System.out.println("type to remove : "+typesToRemove);
//System.out.println("type to add : "+typesToAdd);
response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
response.setHeader("Pragma", "no-cache"); //HTTP 1.0
String fieldNameActual = emxGetParameter(request, "fieldNameActual");
String uiType = emxGetParameter(request, "uiType");
String typeAhead = emxGetParameter(request, "typeAhead");
String frameName = emxGetParameter(request, "frameName");
String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");

int nbAttrs = (null != emxTableRowId) ? emxTableRowId.length : 0;
int k = 0;
//System.out.println(nbAttrs + " attribue(s) to constrain");

//if (nbAttrs > 0)
//boolean bCommit = false;
try
{
	//StringBuffer sCacheResetMsg = new StringBuffer();
	String strLang = context.getSession().getLanguage();
	String removedMsg = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.Confirm.RemoveType");
	String addedMsg = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.Confirm.AddType");
%>

<script language="javascript">
	var typToRemove = "<%=typesToRemove%>";
	var typToAdd = "<%=typesToAdd%>";
	var rmMsg = "<%=removedMsg%>";
	var addMsg = "<%=addedMsg%>";
	var msg="";

	if(typToRemove!=null && typToRemove!="" )
		msg =msg+ rmMsg+ "\n" + typToRemove+ "\n";
		
	if(typToAdd!=null && typToAdd!="" )
		msg=msg+ addMsg+ " \n" + typToAdd;

	alert(msg);
	top.location.href = "../common/emxCloseWindow.jsp";
	

</script>
<%

	for(int i=0;i< removeTypes.size();i++){	
		CustoConfigUniquenessKeyActivation.addOrRemoveTypeFromMxTNR(context, removeTypes.get(i),valuesOfTypesToRemove.get(i));
	}
	for(int i=0;i< addTypes.size();i++){	
		CustoConfigUniquenessKeyActivation.addOrRemoveTypeFromMxTNR(context, addTypes.get(i),valuesOfTypesToAdd.get(i));
	}
	//bCommit = true;
	
	//if (bCommit) {
		%>
		<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
		<%
	//}
}
catch (Exception e)
{
	emxNavErrorObject.addMessage(""+e.getMessage());
	session.putValue("error.message", e.getMessage());
	%>
	<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
	<%
}		
%>

<script language="javascript" type="text/javaScript">
// Reload the page 
top.opener.location.href = top.opener.location.href ; 


var typeAhead = "<%=typeAhead%>";
//alert(typeAhead);
var targetWindow = null;
var uiType = "<%=uiType%>";
if(typeAhead == "true")
{
	var frameName = "<%=frameName%>";
	if(frameName == null || frameName == "null" || frameName == "") {
		targetWindow = window.parent;
	} else {
		targetWindow = top.findFrame(window.parent, frameName);
	}
}else
{
	targetWindow = top.opener;
}

if(typeAhead != "true")
top.location.href = "../common/emxCloseWindow.jsp";

</script>
