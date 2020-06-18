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
<%@page import="com.dassault_systemes.DictionaryAuthor_itfs.DAuData,
                com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuUniquenessKey,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuType,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute,
				com.dassault_systemes.DictionaryPackagesMngtModelUI.CustoConfigUniquenessKeyActivation"%>
<%!
String computeName(Context iContext, String iObjectId)
{
	String name = "";
	try
	{
		if ((null != iObjectId) && !iObjectId.isEmpty())
		{
			IDAuManager manager = DAuManagerAccess.getDAuManager();
			if (null != manager)
			{
				DAuData typeExtData = manager.getTypeOrExtensionFromId(iContext, iObjectId);
				if (null != typeExtData)
				{
					IDAuType type = typeExtData.IDAUTYPE;
					if(type ==null)
					{
					  type = typeExtData.IDAUINSTANCE;
					}
					if (null != type)
					{
						String typeName = type.getName(iContext);
						if ((null != typeName) && !typeName.isEmpty())
							name = typeName;
					}
					else
					{
						IDAuExtension extension = typeExtData.IDAUEXTENSION;
						if (null != extension)
						{
							String extensionName = extension.getName(iContext);
							if ((null != extensionName) && !extensionName.isEmpty())
								name = extensionName;
						}
					}
				}
			}
		}
	}
	catch (Exception e)
	{
		System.out.println("MFL - emxPackagesConfigurationSearchUtil - Exception : " + e.getMessage());
	}
	
	return name;
}
%>

<%
/*System.out.println("MFL - UniquenessKeys Activation - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);
String parmValue = "";
String tableRowIds[] = null;
while( eNumParameters.hasMoreElements() ) {
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
}
*/
response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
response.setHeader("Pragma", "no-cache"); //HTTP 1.0
String fieldNameActual = emxGetParameter(request, "fieldNameActual");
String uiType = emxGetParameter(request, "uiType");
String typeAhead = emxGetParameter(request, "typeAhead");
String frameName = emxGetParameter(request, "frameName");
String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
//String uniquenessKeyId = emxGetParameter(request, "parentOID");
String uniquenessKeyId = emxGetParameter(request, "objectId");

int nbAttrs = (null != emxTableRowId) ? emxTableRowId.length : 0;
int k = 0;
//System.out.println(nbAttrs + " attribue(s) to constrain");
//System.out.println("uniquenessKeyId = " + uniquenessKeyId);

//if (nbAttrs > 0)
try
{
	String [] ukNames = CustoConfigUniquenessKeyActivation.getAllUniquenessKeysNames(context);
	String ukName = "";
	String status = "";
	String comboName = "";
	boolean bCommit = false;
	for (int i = 0; i < ukNames.length; i++) {
		ukName = ukNames[i];
		if (!ukName.isEmpty() && !ukName.equals("mxTNR")) {
		    comboName = CustoConfigUniquenessKeyActivation.removePrefix("VPLMuk/",ukName) + "Combo";
			status = emxGetParameter(request, comboName);
			CustoConfigUniquenessKeyActivation.activateUniquenessKey(context,ukName,status);
			bCommit = true;
		}
	}
	if (bCommit) {
		%>
		<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
		<%
	}
}
catch (Exception e)
{
	session.putValue("error.message", e.getMessage());
	%>
	<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
	<%
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
// Reload the page 
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

</script>
