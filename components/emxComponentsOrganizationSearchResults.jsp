<%--  emxComponentsOrganizationSearchResults.jsp  -  Search results summary page for main search

  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc. 
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsOrganizationSearchResults.jsp.rca 1.2.7.6 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $
--%>

<%@ include file = "emxComponentsDesignTopInclude.inc"%>
<%@ include file = "emxComponentsVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>

<%
    String languageStr      = request.getHeader("Accept-Language");
    String suiteKey         = emxGetParameter(request,"suiteKey");
    String selectType       = emxGetParameter(request, "searchtype");
    String attrOrgId        = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
    String attrCageCode     = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");
    String txtName          = emxGetParameter(request, "txtName");
    String role             = emxGetParameter(request, "role");
    String selection           = emxGetParameter(request,"selection");
    if (txtName == null || txtName.equalsIgnoreCase("null") || txtName.length() <= 0)
    {
        txtName = "*";
    }

    String queryLimit = emxGetParameter(request,"queryLimit");
    if (queryLimit == null || queryLimit.equals("null") || queryLimit.equals("")){
        queryLimit = "0";
    }

    // display radio button for the results by default, if the selection parameter passed with value as 'multiple' then dispaly checkbox
    boolean bSingleSelect = true;
    if (selection != null && "multiple".equals(selection))
    {
      bSingleSelect = false;
    }

    String sForm  = emxGetParameter(request,"form");
    String sField = emxGetParameter(request,"field");
    String sFieldId = emxGetParameter(request,"fieldId");
    String sFieldRev = emxGetParameter(request,"fieldRev");
    String srole = emxGetParameter(request,"role");
    String isEdit     = emxGetParameter(request,"isEdit");
    String objectId       = emxGetParameter(request,"objectId");
    
    if(sFieldRev == null || "null".equals(sFieldRev))
    {
        sFieldRev = "";
    }
    if(isEdit == null || "null".equals(isEdit))
    {
        isEdit = "";
    }
    if(objectId == null || "null".equals(objectId))
    {
        objectId = "";
    }
    if(!"".equals(objectId))
    {
        DomainObject domObj = new DomainObject(objectId);
    }

    // Get default icon for type
    String defaultTypeIcon    = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");

    MapList totalresultList   = null;
    String queryString = request.getQueryString();
    boolean hasFromConnectAccess=false;
    //Declare display variables
    String objectName   = "";
    String typeIcon     = "";
    String code         ="";
    SelectList resultSelects = new SelectList(7);
    resultSelects.add(DomainObject.SELECT_ID);
    resultSelects.add(DomainObject.SELECT_TYPE);
    resultSelects.add(DomainObject.SELECT_NAME);
    resultSelects.add(DomainObject.SELECT_DESCRIPTION);
    resultSelects.add("attribute["+attrCageCode+"]");
    resultSelects.add("attribute["+attrOrgId+"]");
    resultSelects.add("current.access[fromconnect]");

    // Determine if we should use printer friendly version
    boolean isPrinterFriendly = false;
    String printerFriendly    = emxGetParameter(request, "PrinterFriendly");

    if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
        isPrinterFriendly = "true".equals(printerFriendly);
    }

    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
    String vaultPattern = person.getCompany(context).getAllVaults(context, true);
    if (role != null && !"null".equals(role) && !"".equals(role))
    {
        String srelPattern =   PropertyUtil.getSchemaProperty(context,"relationship_Member");
        SelectList busSelect = new SelectList(5);
        busSelect.add(DomainConstants.SELECT_ID);
        busSelect.add(DomainConstants.SELECT_TYPE);
        busSelect.add(DomainConstants.SELECT_NAME);
        busSelect.add(DomainConstants.SELECT_DESCRIPTION);
        busSelect.add("current.access[fromconnect]");
        SelectList relSelect = new SelectList(1);
        relSelect.add(DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_PROJECT_ROLE));
        String sWhereExp=null;
        if (!"*".equals(txtName))
        {
                sWhereExp = " name ~~ \""+txtName+"\" ";
        }

        MapList tempresultList=new MapList();
        totalresultList =  person.getRelatedObjects(context,
                                         srelPattern,         //java.lang.String relationshipPattern,
                                         selectType,                 //java.lang.String typePattern,
                                         busSelect,           //matrix.util.StringList objectSelects,
                                         relSelect,                //matrix.util.StringList relationshipSelects,
                                         true,                //boolean getTo,
                                         false,               //boolean getFrom,
                                         (short)1,            //short recurseToLevel,
                                         sWhereExp,         //java.lang.String objectWhere,
                                         null);               //java.lang.String relationshipWhere)
        for(int i=0; i< totalresultList.size() ; i++)
        {
            Map map= (Map)totalresultList.get(i);
            String projectRole= (String)map.get(DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_PROJECT_ROLE));
            StringList roleSelected=FrameworkUtil.split(projectRole,"~");
            if (roleSelected.contains(role))
            { 
                tempresultList.add(map);
            }
        }
        
        totalresultList = tempresultList;
        tempresultList = null;
    }
    else 
    {
        totalresultList = DomainObject.findObjects(context,
                                                 selectType,
                                                 txtName,
                                                 "*",
                                                 "*",
                                                 vaultPattern,
                                                 null,
                                                 ".finder",
                                                 true,
                                                 resultSelects,
                                                 Short.parseShort(queryLimit));
    }

%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script language="Javascript">

  // function checks or unchecks column of checkboxes associated
  // with table rows
  function doCheck()
  {

    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;

    for (var i=0; i < objForm.elements.length; i++)
    {
      if (objForm.elements[i].name.indexOf('checkbox') > -1)
      {
        if(!objForm.elements[i].disabled)
        {
          objForm.elements[i].checked = chkList.checked;
        }
      }
    }
  }

    function newSearch()
    {
<%
        String sURL = "emxComponentsRDOSearchDialogFS.jsp?form=" + XSSUtil.encodeForURL(context,sForm) + "&field=" + XSSUtil.encodeForURL(context,sField) + "&fieldId=" + XSSUtil.encodeForURL(context,sFieldId) + "&fieldRev=" + XSSUtil.encodeForURL(context,sFieldRev) + "&role="+ XSSUtil.encodeForURL(context,srole) +"&searchLinkProp=SearchRDOLinks&pageFlag=eServiceComponentsSearchOrganization"+ "&selection="+ XSSUtil.encodeForURL(context,selection);
%>
        parent.location="<%=sURL%>";
    }

    function selectDone()
    {

        var bool=false;
        var temp2 = "";
        var id = false;
        var count=0;
        var isEdit = "<%=isEdit%>";
    
        var temp = "";
        var temp1 = "";
        for (var i = 0; i<document.formDataRows.elements.length; i++)
        {
<%
           if (bSingleSelect) {
%>
            if(document.formDataRows.elements[i].type == "radio") {
<%
           } else {
%>
            if(document.formDataRows.elements[i].type == "checkbox") {
<%
           }
%>
                if(document.formDataRows.elements[i].checked == true)
                {
                    bool=true;
                    if(temp == "")
                    {
                      temp = document.formDataRows.elements[i].value;
                    }
                    else
                    {
                      temp = temp + "," + document.formDataRows.elements[i].value;
                    }

                    if(temp1 == "")
                    {
                      temp1 = eval('document.formDataRows.fieldId' + count + '.value');
                    }
                    else
                    {
                      temp1 = temp1 + "," + eval('document.formDataRows.fieldId' + count + '.value');
                    }
<%
                    if(!"".equals(sFieldRev))
                    {
%>
                        if(uniqueId == "attribute_OrganizationID")
                        {
                            temp2 = eval('document.formDataRows.fieldOrgId' + count + '.value');
                            id=true;
                        }
                        else if(uniqueId == "attribute_CageCode")
                        {
                            temp2 = eval('document.formDataRows.fieldCageCode' + count + '.value');
                            id=true;
                        }
<%
                    }

                    if (bSingleSelect) {
%>
                    break;
<%
                    }
%>
                }
                count++;
            }
        }
        if(!bool)
        {
            alert("<emxUtil:i18nScript localize="i18nId" >emxComponents.Common.PleaseMakeASelection</emxUtil:i18nScript>");
        }
        else
        {
            parent.window.opener.document.<%=sForm%>.<%=sField%>.value=temp;//XSSOK
            parent.window.opener.document.<%=sForm%>.<%=sFieldId%>.value=temp1;//XSSOK
            getTopWindow().close();
        }
    }

</script>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

  <fw:sortInit
    defaultSortKey="<%= DomainObject.SELECT_NAME %>"
    defaultSortType="string"
    resourceBundle="emxComponentsStringResource"
    mapList="<%= totalresultList %>"
    params="<%= queryString %>"
    ascendText="emxComponents.Common.SortAscending"
    descendText="emxComponents.Common.SortDescending" />

<form name="formDataRows" method="post" action="">
  <table class="list" id="UITable">
    <tr>
<%
     if(bSingleSelect) {
%>
      <th>&nbsp;</th>
<%
     } else {
%>
      <th>
         <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
      </th>
<%
     }
%>
      <th nowrap="nowrap">
        <fw:sortColumnHeader
          title="emxComponents.Common.Name"
          sortKey="<%= DomainObject.SELECT_NAME %>"
          sortType="string" />
      </th>

      <th nowrap="nowrap">
        <fw:sortColumnHeader
          title="emxComponents.Common.Type"
          sortKey="<%= DomainObject.SELECT_TYPE %>"
          sortType="string" />
      </th>

      <th nowrap="nowrap">
        <fw:sortColumnHeader
          title="emxComponents.Common.Description"
          sortKey="<%= DomainObject.SELECT_DESCRIPTION %>"
          sortType="string" />
      </th>
<%
      int i=0;
%>
	<!-- XSSOK -->
      <fw:mapListItr mapList="<%= totalresultList %>" mapName="resultsMap">
<%
        objectName      = (String)resultsMap.get(DomainObject.SELECT_NAME);

%>
        <tr class='<fw:swap id="even"/>'>
<%
         
          String alias = FrameworkUtil.getAliasForAdmin(context, "type", (String)resultsMap.get(DomainObject.SELECT_TYPE), true);

          if ( (alias == null) || (alias.equals("null")) || (alias.equals("")) ){
            typeIcon = defaultTypeIcon;
          } else {
            typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
          }

          hasFromConnectAccess = ((String) resultsMap.get("current.access[fromconnect]")).equalsIgnoreCase("true")?true:false;
          if (!isPrinterFriendly) {
            if(hasFromConnectAccess){
              if (bSingleSelect) {
%>
              <td><input type="radio" name="radio" value="<%=objectName %>" /></td>
               <input type="hidden" name="fieldId<%=i%>" value="<%=(String)resultsMap.get(DomainObject.SELECT_ID)%>" />
              <input type="hidden" name="fieldCageCode<%=i%>" value="<%=(String)resultsMap.get("attribute["+attrCageCode+"]")%>" />
              <input type="hidden" name="fieldOrgId<%=i%>" value="<%=(String)resultsMap.get("attribute["+attrOrgId+"]")%>" />
<%
              } else {
%>
              <td><input type="checkbox" name="checkbox" value="<%=objectName %>" /></td>
               <input type="hidden" name="fieldId<%=i+1%>" value="<%=(String)resultsMap.get(DomainObject.SELECT_ID)%>" />
              <input type="hidden" name="fieldCageCode<%=i+1%>" value="<%=(String)resultsMap.get("attribute["+attrCageCode+"]")%>" />
              <input type="hidden" name="fieldOrgId<%=i+1%>" value="<%=(String)resultsMap.get("attribute["+attrOrgId+"]")%>" />
<%
              }
%>
             

<%
            i++;
            }else{

%>
              <td><img src="../common/images/utilRadiooffdisabled.gif" /></td>
<%
            }
          }
%>

          <td><img src="../common/images/<%=typeIcon%>" border="0" /><%=objectName%>&nbsp;</td>
          <td><%=i18nNow.getTypeI18NString((String)resultsMap.get(DomainObject.SELECT_TYPE),languageStr)%>&nbsp;</td>
          <td><%=(String)resultsMap.get(DomainObject.SELECT_DESCRIPTION)%>&nbsp;</td>
        </tr>
    </fw:mapListItr>
<%
    if (totalresultList.size() == 0){
%>
      <tr><td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.Common.NoResultsFound</emxUtil:i18n></td></tr>
<%
    }
%>
  </table>
  <input type="hidden" name="txtName" value="<%=XSSUtil.encodeForHTMLAttribute(context,txtName)%>"/>
  <input type="hidden" name="queryLimit" value="<%=XSSUtil.encodeForHTMLAttribute(context,queryLimit)%>" />
  <input type="hidden" name="suiteKey" value="<%=XSSUtil.encodeForHTMLAttribute(context,suiteKey)%>" />
</form>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
