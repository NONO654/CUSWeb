<%--  emxUIBottomPageInclude.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUIBottomPageInclude.inc.rca 1.71 Tue Oct 28 23:00:48 2008 przemek Experimental przemek $
--%>

<%@include file = "emxUITopInclude.inc"%><%@ page import = "com.matrixone.apps.framework.ui.*" %><%@ page import = "com.matrixone.apps.domain.util.*" %>
<%
String bttoolbar = emxGetParameter(request,"bttoolbar");

HashMap toolbar = framesetObject.removeMenu(context, bttoolbar);
MapList childList = new MapList();
if(toolbar != null){
	childList = (MapList)toolbar.get(UICache.CHILDREN);
}

String stringResourceFile     = emxGetParameter(request,"strfile");
boolean doTranslate = true;
if ((stringResourceFile == null) || ("".equals(stringResourceFile))){
	doTranslate  = false;
}

%>
<table>
<tr>
    	<td class='functions'></td>
		   <td class='buttons'>
		   <table><tr>
<%
for (int i=0; i < childList.size(); i++){
	if(i != 0) {
%>
		<td> </td>
<%
	}
	HashMap tempMap1 = (HashMap)childList.get(i);
	HashMap tempMap = framesetObject.removeCommand(context, (String)tempMap1.get(UICache.NAME));
	if(tempMap == null){
		continue;
	}
      String target = "target='_parent'";
	  String linkIsJavascript = UIMenu.getSetting(tempMap,"Javascript");
	  String linkHref = (String)tempMap.get("href");
      if (!"true".equalsIgnoreCase(linkIsJavascript)){
        linkHref = linkHref;
      }else{
        linkHref = "javascript:window.frames['pagecontent']." + linkHref;
        target="";
      }

      String strDisplay = (String)tempMap.get("label");
      //String strDisplay = UINavigatorUtil.getI18nString((String)tempMap.get("label"),UINavigatorUtil.getStringResourceFileId(UIMenu.getSetting(tempMap,"Registered Suite")),request.getHeader("Accept-Language"));
      if (doTranslate) {
      	strDisplay = i18nNow.getI18nString(strDisplay,stringResourceFile,request.getHeader("Accept-Language"));
      }

      String lid = (String)tempMap1.get("linkid");
	  String stridicon = "";
	  String stridbtn = "";
	  if(lid != null && !"".equals(lid)){
		stridicon += "id=\"" + lid + "icon\"";
		stridbtn += "id=\"" + lid + "btn\"";
	  }
      
	  String btnclsname = "btn-default";
	  if(childList.size() < 2 || i == childList.size() -2){
			  btnclsname = "btn-primary";
	  } 
      
%>
		   <!-- //XSSOK -->
		   <td><a class="footericon" <%=stridicon%> onclick="<%=linkHref%> <%=target%>" ><img src='../<%=XSSUtil.encodeForHTMLAttribute(context,(String) UIMenu.getSetting(tempMap,"Image"))%>' border=0 align=absmiddle></a></td>
		   <!-- //XSSOK -->
		   <td><a <%=stridbtn%> onclick="<%=linkHref%> <%=target%>" ><button class="<%=btnclsname%>" type="button"><%=strDisplay%></button></a></td>
<%
  }
%>
</tr></table>
</td>
</tr>
</table>

