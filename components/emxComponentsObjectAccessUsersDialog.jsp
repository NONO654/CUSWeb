<%--  emxComponentsObjectAccessUsersDialog.jsp   -   Displays the Access Users Objects List
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsObjectAccessUsersDialog.jsp.rca 1.4.7.5 Wed Oct 22 16:17:59 2008 przemek Experimental przemek $

--%>
    <%@include file = "emxComponentsDesignTopInclude.inc"%>
    <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
    <%@include file = "emxComponentsJavaScript.js" %>
    <%@include file = "../emxContentTypeInclude.inc"%>

    <jsp:useBean id="accessFormBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
    String keyValue = emxGetParameter(request,"keyValue");
    String charSet = request.getCharacterEncoding();
    if(charSet == null || charSet.trim().equals(""))
    {
        charSet = "UTF8";
    }

    String showAllProgram = (String) accessFormBean.getElementValue("showAllProgram");
    String showAllFunction = (String) accessFormBean.getElementValue("showAllFunction");
    String pushGrantor = (String) accessFormBean.getElementValue("pushGrantor");
    String lbcAccess = (String) accessFormBean.getElementValue("lbcAccess");
    if(pushGrantor == null || "null".equals(pushGrantor) || "".equals(pushGrantor))
    {
        pushGrantor = PropertyUtil.getSchemaProperty(context, "person_CommonAccessGrantor");
    }

    String access = (String) accessFormBean.getElementValue("accessChoice");
    if(access == null || "null".equals(access))
    {
        access = "";
    }

    accessFormBean.processForm(session, request, "keyValue");

    String languageStr = request.getHeader("Accept-Language");

    StringList strListAccess = new StringList();
    StringList validAccessList = new StringList();

    if(!"".equals(access))
    {
        access = FrameworkUtil.findAndReplace(access, "_", " ");
        strListAccess = FrameworkUtil.split(access, ",");
        int strListAccessSize = strListAccess.size();

        for (int k=0; k < strListAccessSize; k++)
        {
            String tempAccess = (String)strListAccess.get(k);
            String strProperty = "emxComponents.AccessMapping."+FrameworkUtil.findAndReplace(tempAccess, " ", "").trim();
            String propValue = EnoviaResourceBundle.getProperty(context,strProperty);
            if(propValue != null && !"null".equals(propValue) && !"".equals(propValue))
            {
                validAccessList.add(tempAccess);
            }
        }
    }

    String objectId  =  (String) accessFormBean.getElementValue("objectId");
%>

<script language="Javascript" type="text/javascript">

    // function to close window
    function closeWindow()
    {
        window.location.href = "emxComponentsObjectAccessUpdateAccess.jsp?action=cancel";
    }


    function submitForm()
    {
        var checkedFlag = "false";
        // force to select atleast one member to add
        for( var i = 0; i < document.ContentForm.elements.length; i++)
        {
            if (document.ContentForm.elements[i].type == "checkbox" && document.ContentForm.elements[i].name == "chkItem" )
            {
                checkedFlag = "true";
                break;
            }
        }
        if (checkedFlag == "false")
        {
            alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.ObjectAccess.AddOneUser</emxUtil:i18nScript>");
        }
        else
        {
            document.ContentForm.target = "_parent";
            document.ContentForm.action="emxComponentsObjectAccessSetAccessProcess.jsp?keyValue=<%= XSSUtil.encodeForURL(context, keyValue)%>&action=add";
            startProgressBar(true);
            document.ContentForm.submit();
        }
        return;
    }


    function addPeople()
    {
    	<%if(Boolean.parseBoolean(lbcAccess)){%>
        emxShowModalDialog('emxComponentsAddExistingPersonSearchDialogFS.jsp?keyValue=<%= XSSUtil.encodeForURL(context, keyValue)%>&callPage=emxComponentsObjectAccessUsersDialog&suiteKey=Common&objectId=<%=  XSSUtil.encodeForURL(context, objectId)%>&lbcAccess=<%=XSSUtil.encodeForURL(context, lbcAccess)%>', 600, 525);
        <%}else{%>
    		emxShowModalDialog('emxComponentsAddExistingPersonSearchDialogFS.jsp?keyValue=<%= XSSUtil.encodeForURL(context, keyValue)%>&callPage=emxComponentsObjectAccessUsersDialog&suiteKey=Common&objectId=<%=  XSSUtil.encodeForURL(context, objectId)%>', 600, 525);
    	<%}%>
    }


    function addRole()
    {
        emxShowModalDialog('emxRoleSearchDialogFS.jsp?keyValue=<%= XSSUtil.encodeForURL(context, keyValue)%>&callPage=emxComponentsObjectAccessUsersDialog&mainSearchPage=emxRoleSearchDialogFS.jsp', 600, 525);
    }


    function addGroup()
    {
        emxShowModalDialog('emxGroupSearchDialogFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&callPage=emxComponentsObjectAccessUsersDialog&mainSearchPage=emxGroupSearchDialogFS.jsp', 600, 525);
    }


    function removeMembers()
    {
        var checkedFlag = "false";
        document.ContentForm.selUsers.value="";
        // force to select atleast one member to add
        for(var i = 0; i < document.ContentForm.elements.length; i++)
        {
            if (document.ContentForm.elements[i].type == "checkbox" && document.ContentForm.elements[i].name == "chkItem" && document.ContentForm.elements[i].checked)
            {
                checkedFlag = "true";
                break;
            }
        }

        // Sending all the selected roles and groups in input type hidden
        for(var i = 0; i < document.ContentForm.elements.length; i++)
        {
            if ((document.ContentForm.elements[i].type == "checkbox") && (document.ContentForm.elements[i].name == "chkItem") && (document.ContentForm.elements[i].checked))
            {
                document.ContentForm.selUsers.value = document.ContentForm.selUsers.value + document.ContentForm.elements[i+1].value + "|";
            }
        }
        if (checkedFlag == "false")
        {
            alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.ObjectAccess.SelectRemove</emxUtil:i18nScript>");
            return;
        }
        else
        {
           document.ContentForm.action="emxComponentsObjectAccessAddUsersProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&action=remove&userList="+document.ContentForm.selUsers.value;
            document.ContentForm.submit();
        }
        return ;
    }

</script>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

<%@ include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    int count = 0;
    String sAccess            = null;
    String userName          = "";
    String sTargetType        = "";
    String sDisplayTargetName = "";
    String sTargetOrganization = "";

    MapList accessUsersMapList = null;

    try
    {
        accessUsersMapList = (MapList)accessFormBean.getElementValue("accessUsersMapList");
        if(accessUsersMapList == null || accessUsersMapList.equals("null") || accessUsersMapList.equals(""))
        {
            accessUsersMapList = new MapList();
        }
    }
    catch(Exception ex)
    {
        accessUsersMapList = new MapList();
    }

    String sParams = "keyValue="+ keyValue;
%>

<form name="ContentForm" method="post" target="_parent" onSubmit="javascript:submitForm(); return false">
    <table class="list" id="UITable">
    <!-- //XSSOK -->
    <framework:sortInit  defaultSortKey="LastFirstName"  defaultSortType="string"  mapList="<%=accessUsersMapList%>"  resourceBundle="emxComponentsStringResource"  ascendText="emxComponents.Common.SortAscending"  descendText="emxComponents.Common.SortDescending"  params = "<%=sParams%>"  />

     <tr>
       <th width="2%" style="text-align: center;" >
        <span style="text-align: center;">
         <input type="checkbox" name="checkAll" id="checkAll" onclick="allSelected('ContentForm')"/>
        </span>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Name"
           sortKey="LastFirstName"
           sortType="string"/>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Type"
           sortKey="type"
           sortType="string"/>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Organization"
           sortKey="OrganizationName"
           sortType="string"/>
      </th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Access</emxUtil:i18n></th>
    </tr>
<%
    if(accessUsersMapList == null || accessUsersMapList.size() == 0)
    {
%>
    <tr>
        <td align="center" colspan="13" class="error">
            <emxUtil:i18n localize="i18nId">emxComponents.ObjectAccess.NoUserAdded</emxUtil:i18n>
        </td>
    </tr>
<%
    }
    else
    {
        int validAccessListSize = validAccessList.size();
        HashMap accessMap = new HashMap(validAccessListSize);
        for (int j=0; j < validAccessListSize; j++)
        {
            String strAccess = (String)validAccessList.get(j);
            String strTempAccess = FrameworkUtil.findAndReplace(strAccess, " ", "");
            strTempAccess = "emxComponents.ObjectAccess."+strTempAccess.trim();
            accessMap.put(strAccess, EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), strTempAccess));
        }
%>
        <!-- //XSSOK -->
        <framework:mapListItr mapList="<%=accessUsersMapList%>" mapName="accessUserMap">

<%
        userName            = (String)accessUserMap.get("name");
        sTargetType         = (String)accessUserMap.get("type");
        sDisplayTargetName  = (String)accessUserMap.get("LastFirstName");
        sTargetOrganization = (String)accessUserMap.get("OrganizationName");
        sAccess             = (String)accessUserMap.get("access");
        if(sTargetOrganization == null || "null".equals(sTargetOrganization))
        {
            sTargetOrganization = "";
        }
        //Modified for Bug # 344847 - Begin
        if ("Role".equals(sTargetType))
            {
                sDisplayTargetName = i18nNow.getAdminI18NString("Role",sDisplayTargetName,languageStr);
            }
        else if ("Group".equals(sTargetType))
            {
                sDisplayTargetName = i18nNow.getAdminI18NString("Group",sDisplayTargetName,languageStr);
            }
        //Modified for Bug # 344847 - End
%>
        <tr class='<framework:swap id ="1" />'>
            <td style="font-size: 8pt" align="center" >

            <input type="checkbox" name="chkItem" id="chkItem" onclick="updateSelected('ContentForm')" value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/>
            </td>

            <td><%=sDisplayTargetName%></td>
<%
            if ("Role".equals(sTargetType))
            {
                sTargetType = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.Role");
            }
            else if ("Group".equals(sTargetType))
            {
                sTargetType = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.Group");
            }
            else if ("Person".equals(sTargetType))
            {
                sTargetType = i18nNow.getTypeI18NString(sTargetType, languageStr);
            }
%>
            <td><%=sTargetType%>&nbsp;</td>
            <td><xss:encodeForHTML><%=sTargetOrganization%></xss:encodeForHTML>&nbsp;</td>
            <td>
            <input type="hidden" name="<%="User"+count%>" value="<xss:encodeForHTMLAttribute><%=FrameworkUtil.encodeNonAlphaNumeric(userName, charSet)%></xss:encodeForHTMLAttribute>" />
                <select name=<%="Access"+count%> style="font-size:8pt" onChange="updateSession(this, this.form)" rowNumber="<%=count%>">
<%
                    for (int j=0; j < validAccessListSize; j++)
                    {
                        String strAcc = (String)validAccessList.get(j);
%>                      
				<!-- //XSSOK -->		
				<option value="<xss:encodeForHTMLAttribute><%=strAcc%></xss:encodeForHTMLAttribute>"> <%=(String)accessMap.get(strAcc)%> </option>
<%
                    }
%>
                </select>
            </td>
        </tr>
<script language="Javascript" type="text/javascript">
    document.ContentForm.Access<%=count%>.value = "<xss:encodeForJavaScript><%=sAccess%></xss:encodeForJavaScript>";
</script>
<%
        count++;
%>
        </framework:mapListItr>
   <%
    }
%>

    </table>

    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="pushGrantor" value="<xss:encodeForHTMLAttribute><%=pushGrantor%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="showAllProgram" value="<xss:encodeForHTMLAttribute><%=showAllProgram%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="showAllFunction" value="<xss:encodeForHTMLAttribute><%=showAllFunction%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="selUsers" value=""/>

</form>

<div id="divHiddenFrame" style="display:none">
    <iframe width="0" height="0" name='intermediateHiddenFrame' id='intermediateHiddenFrame' src=""></iframe>
</div>

<script language="Javascript" type="text/javascript">

    function updateSession(ele, thisForm)
    {
        var name = eval("document."+thisForm.name+".User"+ele.name.substring(6)).value;
        document.getElementById('intermediateHiddenFrame').src="emxComponentsObjectAccessUpdateAccess.jsp?access="+ele.value+"&name="+name;
    }

</script>

<%@ include file = "../emxUICommonEndOfPageInclude.inc" %>
