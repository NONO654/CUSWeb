<%--  emxPackagesConfigurationEditConstrainedAttributes.jsp  --  Edit constrained attributes
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPackagesConfigurationEditConstrainedAttributes.jsp.rca 1.1 Wed Jan 14 05:57:06 2009 ds-smourougayan Experimental przemek $
  --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.DictionaryAuthor_itfs.DAuData,
                com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager,
				com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuUniquenessKey,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuType,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute"%>
<%

/*System.out.println("YI3 - EditScopes - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);
  String parmValue = "";
String tableRowIds[] = null;
    while( eNumParameters.hasMoreElements() ) {
      String parmName  = (String)eNumParameters.nextElement();
System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
     }
System.out.println("YI3 - EditScopes - hashMap");*/

response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
response.setHeader("Pragma", "no-cache"); //HTTP 1.0
String fieldNameActual = emxGetParameter(request, "fieldNameActual");
String uiType = emxGetParameter(request, "uiType");
String typeAhead = emxGetParameter(request, "typeAhead");
String frameName = emxGetParameter(request, "frameName");
String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
String extensionId = emxGetParameter(request, "objectId");
String errString = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.scopes");
String errDelExtWithoutScope =  DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.DelExtWithoutScope");
int nbscopes = (null != emxTableRowId) ? emxTableRowId.length : 0;
int k = 0;
System.out.println(nbscopes + " scope(s) to add");
String packSelected = "";
//if (nbAttrs > 0)
{
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
		    ArrayList<IDAuType> listScopes = new ArrayList<IDAuType>();
			DAuData objectData= null;
			IDAuType type = null;
			for (k = 0; k < nbscopes; k++)
			{
				String scopeId = emxTableRowId[k];
				// MFL le 15 Septembre 11 curieusement la forme des Ids vient de changer. |38016.53567.5632.5790||0,1				
				if (scopeId.startsWith("|") == true ) {
					scopeId = scopeId.substring(1);
				}
				int idxPipes = scopeId.indexOf("||");
				if (idxPipes > 0 ) {								
					scopeId = scopeId.substring(0,idxPipes);
				}				
				IDAuPackage currentPackage = manager.getPackageFromId(context, scopeId);
				if (null != currentPackage){
					packSelected = "selected";	
				}else{
					objectData = manager.getTypeOrExtensionFromId(context,scopeId);
					type = objectData.IDAUTYPE;
					if(type==null)
						type = objectData.IDAUINSTANCE;
				}
        
				if (null != type){
					listScopes.add(type);
				}
				else
					System.out.println("ERROR : Type " + scopeId + " not found");
			}
			// Reset now constrained attributes
			if(packSelected !="selected"){
				if(listScopes!=null && listScopes.size()>0){
				DAuData data = manager.getTypeOrExtensionFromId(context, extensionId);
				IDAuExtension extension = data.IDAUEXTENSION;
				if(null != extension ){
					extension.setScopes(context, listScopes,true);
					%>			
					<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>		
					<%
				}
				}
				else{
					throw new Exception (errDelExtWithoutScope);
				}
			}
		}		
		catch (Exception e)
		{
			session.putValue("error.message", e.getMessage());
			%>
			<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
			<%
		}		
	}
}
%>

<%@page import="matrix.util.StringList,
                java.util.HashMap,
                com.matrixone.apps.domain.DomainObject,
                java.util.StringTokenizer,
                com.matrixone.apps.domain.DomainConstants,
                java.util.Map,
                com.matrixone.apps.domain.util.PersonUtil,
                com.matrixone.apps.framework.ui.UICache,
                com.matrixone.apps.framework.ui.UIUtil"
                %>

<script language="javascript" type="text/javaScript">

var iSelected = "<%=packSelected%>";
var errMsg = "<%=errString%>";
if(iSelected=="selected"){
	alert(errMsg);
	top.location.href = "../common/emxCloseWindow.jsp";
	}else{
	//Reload the page 
	top.opener.location.href = top.opener.location.href ; 

	var typeAhead = "<%=typeAhead%>";
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
}
</script>
