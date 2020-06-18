<%--  emxClassificationPaths.jsp   -
    This page queries the required data from database to display
    the required properties for Generic Document

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "";
--%>
<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file="emxLibraryCentralUtils.inc" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil" %>

<%
					//Modified for the bug no:344439 
boolean isLCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionLibraryCentral",false,null,null);
String objectId = emxGetParameter(request, "objectId");
String sBookShelf = Framework.getPropertyValue(session,"type_Bookshelf");
String sBook = Framework.getPropertyValue(session,"type_Book");
String sFolder = Framework.getPropertyValue(session,"type_ProjectVault");
boolean bShowClassificationPath = true;
DomainObject domainObj = new DomainObject();
domainObj.setId(objectId);
String strType  =  domainObj.getInfo(context,DomainObject.SELECT_TYPE);
String parentType = LibraryCentralCommon.getParentType(context, strType ,context.getVault());
String languageStr = request.getHeader("Accept-Language");
	
if (parentType.equals(LibraryCentralConstants.TYPE_DOCUMENT_LIBRARY) || parentType.equals(sBookShelf) || parentType.equals(sBook) || parentType.equals(sFolder))
{
    bShowClassificationPath = false;
}

if(isLCInstalled && bShowClassificationPath)
{
    
    String mode = emxGetParameter(request, "mode");
    if (mode == null) {
        mode = "view";
    }
    String maxColsStr = emxGetParameter(request, "maxCols");
    if (maxColsStr == null) {
        maxColsStr = "2";
    }
    Integer maxCols = new Integer(Integer.parseInt(maxColsStr));
    String label = emxGetParameter(request, "label");
    String i18Label = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(languageStr),"emxLibraryCentral.Properties.ClassificationPaths");	 
    if (label == label) {
        label = i18Label;
    }
    String strResource = emxGetParameter(request, "stringResource");
    if (strResource == null) {
        strResource = "";
    }

    HashMap mainMap = new HashMap();
    HashMap paramMap = new HashMap();
    HashMap requestMap = new HashMap();

    requestMap.put("mode", mode);

    mainMap.put("requestMap", requestMap);
    mainMap.put("paramMap", paramMap);
    mainMap.put("maxCols", maxCols);

    paramMap.put("objectId", objectId);

    String[] args = JPO.packArgs(mainMap);
    String[] constructor = { null };

    String clsHtml = (String) JPO.invoke(context,
            "emxLibraryCentralClassificationPath", constructor,
            "getClassificationPathsHTML", args, String.class);
			
	/* Decoding HTML String for URL. Done by PSA11(IR-505781-3DEXPERIENCER2018x). */
	clsHtml = XSSUtil.decodeFromURL(clsHtml);			
%>
      <tr>
        <td class="label" width="150">
			<xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,strResource,new Locale(languageStr),label)%></xss:encodeForHTML>
        </td>
        <td class="field" colspan="<xss:encodeForHTML><%=maxCols.intValue() -1 %></xss:encodeForHTML>">
          <%=clsHtml%>
        </td>
      </tr>
<%
}
%>

