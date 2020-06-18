<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%--  emxTypeSelectorLoadType.jsp - loads the children for a single type

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTypeChooserLoadType.jsp.rca 1.9 Tue Oct 28 18:55:08 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%

    String typeName = emxGetParameter(request, "type");
    String language = request.getHeader("Accept-Language");
    boolean observeHidden = Boolean.parseBoolean(emxGetParameter(request, "ObserveHidden"));
    boolean showIcons = Boolean.parseBoolean(emxGetParameter(request, "showIcons"));
	String excludedTypes = emxGetParameter(request, "notTypes");
    StringList excludedTypeList = (StringList)FrameworkUtil.split(excludedTypes,",");
    String icon = null;
    try {
        icon =UINavigatorUtil.getTypeIconFromCache(typeName);
        if (icon == null || icon.length() == 0 ) {
            icon = "iconSmallDefault.gif";
        }
    } catch (Exception ex) {
        out.print("<aef:error><![CDATA[Error getting icon: " + ex.getMessage() + "]]></aef:error>");
    }

%>
<!-- //XSSOK -->
<aef:type xmlns:aef="http://www.matrixone.com/aef" selection="<%= "true".equals(emxGetParameter(request, "multiSelect")) ? "multiple" : "single" %>" name="<%=XSSUtil.encodeForXML(context, typeName)%>" abstract="<%=UINavigatorUtil.isAbstract(typeName)%>" abstractselect="<%=XSSUtil.encodeForXML(context, emxGetParameter(request, "abstractSelect")) %>">
	<aef:notTypes NotTypes="<%=XSSUtil.encodeForXML(context, excludedTypes)%>"/>
    <aef:label>
        <% if (showIcons) { %>
            <!-- //XSSOK -->
            <aef:image src="images/<%=icon%>" />
        <% } %>
        <aef:text><%=XSSUtil.encodeForXML(context, EnoviaResourceBundle.getTypeI18NString(context,typeName,language))%></aef:text>
    </aef:label>
<%
    try {
        //get child types
        StringList lstChildren = UINavigatorUtil.getChildrenTypeFromCache(typeName, observeHidden);
        //added for the bug 315446
        boolean hasAllChildrenHidden=true;
        for(int intCount=0;intCount<lstChildren.size();intCount++)
        {
          if (!UINavigatorUtil.isHidden((String)lstChildren.get(intCount)) || !observeHidden)
          {
            hasAllChildrenHidden=false;
            break;
          }
        }
        //if there are any children
        //if (lstChildren != null) {
        if (lstChildren != null && !hasAllChildrenHidden) {
        //Till here added for the bug 315446
            for (int i=0; i < lstChildren.size(); i++) {
                String sBaseTypeName = (String) lstChildren.elementAt(i);
                boolean exclude = false;
                //check whether the type is in the excludedlist
                for (int j=0; j < excludedTypeList.size(); j++) {
                    if(sBaseTypeName.equalsIgnoreCase((String)excludedTypeList.elementAt(j))){
                        exclude = true;
                        break;
                    }
                }
                if((!observeHidden || !UINavigatorUtil.isHidden(sBaseTypeName)) && !exclude) {
                    boolean hasChildren =  UINavigatorUtil.getChildrenTypeFromCache(sBaseTypeName, observeHidden).size() > 0;
                    icon = UINavigatorUtil.getTypeIconFromCache(sBaseTypeName);
                    if (icon == null || icon.length() == 0 ) {
                        icon = "iconSmallDefault.gif";
                    }
%>
					<!-- //XSSOK -->
                    <aef:type name="<%=sBaseTypeName%>" abstract="<%=UINavigatorUtil.isAbstract(sBaseTypeName)%>" haschildren="<%=hasChildren%>">
                        <aef:label>
                            <% if (showIcons) { %>
                                <!-- //XSSOK -->
                                <aef:image src="images/<%=icon%>" />
                            <% }  %>
                            <aef:text><%=XSSUtil.encodeForXML(context,EnoviaResourceBundle.getTypeI18NString(context,sBaseTypeName,language))%></aef:text>
                        </aef:label>
                    </aef:type>

<%
                }
            }
        }
    } catch (Exception ex) {
        out.print("<aef:error><![CD" + "ATA[Error loading children: " + ex.getMessage() + "]]></aef:error>");
    }
%>
</aef:type>
