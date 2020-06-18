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
<%@page import="com.dassault_systemes.DictionaryAuthor_itfs.DAuData,
				com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities,
                com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuUniquenessKey,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuType,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttrInfos"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
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
String errMsg = "";

int nbAttrs = (null != emxTableRowId) ? emxTableRowId.length : 0;
int k = 0;
//System.out.println(nbAttrs + " attribue(s) to constrain");
//System.out.println("uniquenessKeyId = " + uniquenessKeyId);

String mVAFound="";
//if (nbAttrs > 0)
{
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
		    ArrayList<IDAuAttribute> listAttributes = new ArrayList<IDAuAttribute>();
			for (k = 0; k < nbAttrs; k++)
			{
				if(mVAFound!="found"){
					String attrId = emxTableRowId[k];
					// MFL le 15 Septembre 11 curieusement la forme des Ids vient de changer. |38016.53567.5632.5790||0,1				
					if (attrId.startsWith("|") == true ) {
						attrId = attrId.substring(1);
					}
					int idxPipes = attrId.indexOf("||");
					if (idxPipes > 0 ) {								
						attrId = attrId.substring(0,idxPipes);
					}
					IDAuAttribute attr = manager.getAttributeFromId(context,attrId);
					if (null != attr){
						if(attr.getAttrInfos(context).getMultiValuated(context)){
							mVAFound= "found";
							errMsg = attr.getName(context);

						}else
							listAttributes.add(attr);
					}
					else
						System.out.println("ERROR : Attribute " + attrId + " not found");
				}
			}
			
			if(mVAFound==""){
				// Reset now constrained attributes
				IDAuUniquenessKey IUK = manager.getUniquenessKeyFromId(context, uniquenessKeyId);
				if (IUK != null) {
					IUK.setConstrainedAttributes(context,listAttributes);
					%>			
					<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>		
					<%
				}
			}else {
					errMsg+= " "+ DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.MVASelected");
					%>	
					<script language="javascript" type="text/javaScript">
						var msg = "<%=errMsg%>";
						alert(msg);
					</script>
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

var typeAhead = "<%=typeAhead%>";
var targetWindow = null;
var uiType = "<%=uiType%>";
var alertOpened = "<%=mVAFound%>";

if(alertOpened==""){
	// Reload the page 
	top.opener.location.href = top.opener.location.href ; 

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
