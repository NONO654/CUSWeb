<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%--  emxTypeSelectorLoadFullTree.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTypeChooserLoadAllLevels.jsp.rca 1.8 Wed Oct 22 15:47:49 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>


<%!
String loadJSChildren ( matrix.db.Context context, String sTypeName, String languageStr, boolean observeHidden, boolean showIcons, StringList excludedTypeList)
{
    StringBuffer strResult = new StringBuffer();

    try {

        String sSmallIcon=UINavigatorUtil.getTypeIconFromCache(sTypeName);
        if (sSmallIcon == null || sSmallIcon.length() == 0 )
        {
                sSmallIcon = "iconSmallDefault.gif";
        }

        //get child types
        StringList lstChildren = UINavigatorUtil.getChildrenTypeFromCache(sTypeName, observeHidden);
        Iterator excludedTypeItr = excludedTypeList.iterator();
        while(excludedTypeItr.hasNext()){
        	String excludeType = excludedTypeItr.next().toString();
        	if(lstChildren.contains(excludeType)){
        		lstChildren.remove(excludeType);
        		excludedTypeItr.remove();
        	}
        }

        //boolean hasChildren =  UINavigatorUtil.getChildrenTypeFromCache(typeName).size() > 0;
        boolean hasAllChildrenHidden=true;
        for(int intCount=0;intCount<lstChildren.size();intCount++)
        {
          if (!UINavigatorUtil.isHidden((String)lstChildren.get(intCount)))
          {
            hasAllChildrenHidden=false;
            break;
          }
        }
        boolean hasChildren = lstChildren!=null && lstChildren.size() > 0 && !hasAllChildrenHidden;
        //Till here added for the bug 315446

        strResult.append("<aef:type name=\"");
        strResult.append(sTypeName);
        strResult.append("\" abstract=\"");
        strResult.append(String.valueOf(UINavigatorUtil.isAbstract(sTypeName)));
        strResult.append("\" haschildren=\"");
        //modified for the bug 315446
        strResult.append(hasChildren);
        //modified for the bug 315446
        strResult.append("\"><aef:label>");

        if (showIcons) {
           strResult.append("<aef:image src=\"images/");
           strResult.append(sSmallIcon);
           strResult.append("\" />");
        }

        strResult.append("<aef:text>");
        strResult.append(XSSUtil.encodeForXML(context, i18nNow.getTypeI18NString(sTypeName,languageStr)));
        strResult.append("</aef:text></aef:label>");
        strResult.append("</aef:type>");

        //if there are any children
        if (lstChildren != null)
        {
                for (int i=0; i < lstChildren.size(); i++)
                {
                        String sBaseTypeName = (String) lstChildren.elementAt(i);
                        if(!observeHidden || !UINavigatorUtil.isHidden(sBaseTypeName)) {
                                strResult.append(loadJSChildren(context, sBaseTypeName, languageStr, observeHidden, showIcons, excludedTypeList));
                        }
                }
        }

    } catch (Exception e) {
        strResult.append("Error: Loading Children --");
        strResult.append(e.toString());
    }

    return strResult.toString();
  }
%>
 <!-- //XSSOK -->
<aef:typechooser xmlns:aef="http://www.matrixone.com/aef" selection="<%= "true".equals(emxGetParameter(request, "multiSelect")) ? "multiple" : "single" %>" abstractselect="<%=XSSUtil.encodeForXML(context, emxGetParameter(request, "abstractSelect")) %>">
<%

  boolean showIcons = Boolean.parseBoolean(emxGetParameter(request, "showIcons"));

  try {
      String languageStr = request.getHeader("Accept-Language");
      String sType = emxGetParameter(request,"txtName");
      String ObserveHidden = emxGetParameter(request,"ObserveHidden");
      String excludedTypes = emxGetParameter(request, "notTypes");
      StringList excludedTypeList = FrameworkUtil.split(excludedTypes,",");
      boolean bObserveHidden = true;
      if(ObserveHidden != null && ObserveHidden.equalsIgnoreCase("false"))
      {
         bObserveHidden=false;
      }
      //this handles the initial loading of the tree
%>
<aef:notTypes NotTypes="<%=XSSUtil.encodeForXML(context, excludedTypes)%>" />
        <aef:root>
            <aef:label>
                <% if (showIcons) { %>
                <aef:image src="images/iconSmallType.gif" />
                <% } %>
                <aef:text><emxUtil:i18n localize="i18nId">emxFramework.TypeChooser.Types</emxUtil:i18n></aef:text>
            </aef:label>
<%
      int iNumTypes = Integer.parseInt(emxGetParameter(request, "numTypes"));

      for (int i=0; i < iNumTypes; i++) {
        String sTypeName = emxGetParameter(request, "type" + String.valueOf(i));
%>
       <!-- //XSSOK -->
      <%= loadJSChildren(context,sTypeName , languageStr, bObserveHidden, showIcons,  excludedTypeList)%>
<%
      }
    } catch (Exception e) { %>
    Java Exception Occured: <%= e %>"
<%  } %>
        </aef:root>
</aef:typechooser>
