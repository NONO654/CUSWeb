<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%--  emxTypeSelectorLoadFirstLevel.jsp - loads only the first level of the type chooser.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTypeChooserLoadFirstLevel.jsp.rca 1.9 Tue Oct 28 18:55:08 2008 przemek Experimental przemek $
--%>


<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%

    //get URL parameters
    String language         = request.getHeader("Accept-Language");
    boolean observeHidden   = Boolean.parseBoolean(emxGetParameter(request, "ObserveHidden"));
    boolean showIcons       = Boolean.parseBoolean(emxGetParameter(request, "showIcons"));
    int numTypes            = Integer.parseInt(emxGetParameter(request, "numTypes"));
    String notTypes        = (String)emxGetParameter(request, "notTypes");
    
    //define strings for later
    String icon             = null;
    String typeName         = null;
%>
 <!-- //XSSOK -->
<aef:typechooser xmlns:aef="http://www.matrixone.com/aef" selection="<%= "true".equals(emxGetParameter(request, "multiSelect")) ? "multiple" : "single" %>" abstractselect="<%= XSSUtil.encodeForXML(context, emxGetParameter(request, "abstractSelect")) %>">
<aef:notTypes NotTypes="<%=XSSUtil.encodeForXML(context, notTypes)%>"/>
<%
  try {

%>
        <aef:root>
            <aef:label>
                <% if (showIcons) { %>
                <aef:image src="images/iconSmallType.gif" />
                <% } %>
                <aef:text><emxUtil:i18n localize="i18nId">emxFramework.TypeChooser.Types</emxUtil:i18n></aef:text>
            </aef:label>
<%


      for (int i=0; i < numTypes; i++)
      {
          typeName = emxGetParameter(request, "type" + String.valueOf(i));
          if(!observeHidden || !UINavigatorUtil.isHidden(typeName)) {
              //added for the bug 315446
              //boolean hasChildren =  UINavigatorUtil.getChildrenTypeFromCache(typeName).size() > 0;
              StringList stChildTypeNames=UINavigatorUtil.getChildrenTypeFromCache(typeName, observeHidden);
              boolean hasAllChildrenHidden=true;
              for(int intCount=0;intCount<stChildTypeNames.size();intCount++)
              {
                  if (!UINavigatorUtil.isHidden((String)stChildTypeNames.get(intCount)))
                  {
                      hasAllChildrenHidden=false;
                      break;
                  }
              }
              boolean hasChildren =  stChildTypeNames != null && stChildTypeNames.size() > 0 && !hasAllChildrenHidden;
              //Till here added for the bug 315446
              icon = UINavigatorUtil.getTypeIconFromCache(typeName);
              if (icon == null || icon.length() == 0 ) {
                  icon = "iconSmallDefault.gif";
              }
      %>
			<!-- XSSOK -->
              <aef:type name="<%=XSSUtil.encodeForXML(context, typeName)%>" abstract="<%=UINavigatorUtil.isAbstract(typeName)%>" haschildren="<%=hasChildren%>">
                  <aef:label>
                      <% if (showIcons) { %>
                           <!-- //XSSOK -->
                          <aef:image src="images/<%=icon%>" />
                      <% }  %>
                      <aef:text><%=EnoviaResourceBundle.getTypeI18NString(context,typeName,language)%></aef:text>
                  </aef:label>
              </aef:type>

    <%
            }
      }
  } catch (Exception e) { %>
  <aef:error><%="<!["%>CDATA[<%= e %>]]></aef:error>
<% } %>
   </aef:root>
</aef:typechooser>
