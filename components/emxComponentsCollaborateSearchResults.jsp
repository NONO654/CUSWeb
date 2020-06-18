<%-- emxComponentsCompanySearchResults.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCollaborateSearchResults.jsp.rca 1.8 Wed Oct 22 16:17:58 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file  = "../emxPaginationInclude.inc" %>
<%@include file = "emxComponentsCollaborateSearchResultsInclude.inc"%>

<%
  MapList templateMapList =  new MapList();
  MapList colMapList = new MapList();

  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String sLink              = emxGetParameter(request,"typename");
  String objectId           = emxGetParameter(request,"objectId");
  String sPagination        = emxGetParameter(request,"pagination");
  String sQueryLimit        = emxGetParameter(request,"QueryLimit");
  short objlimit = 0;
  try
  {
    objlimit = Short.parseShort(sQueryLimit);
  }
  catch(NumberFormatException e)
  {
    objlimit = 0;
  }

  String sAll = "*";
  if(sLink == null)
  {
    sLink ="Company";
  }

  DomainObject Company      = DomainObject.newInstance(context);
  
  //Added for bug 377964
  if(session.getAttribute("objectId") != null)
      session.removeAttribute("objectId");

%>

<script language="javascript">
  function submitform()
  {
      var checkedFlag = "false";
      var selIds = "";

      // force to select atleast one item
      for (var varj = 0; varj < document.templateresults.elements.length; varj++)
      {
        if (document.templateresults.elements[varj].type == "checkbox" &&
        document.templateresults.elements[varj].checked &&
        ( document.templateresults.elements[varj].name.indexOf('chkItem') > -1))
        {
          checkedFlag = "true";
          selIds += document.templateresults.elements[varj].value + ",";
        }
      }
      if (checkedFlag == "false")
      {
        alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Common.PleaseSelectAnItem</emxUtil:i18nScript>");
        return;
      }
      document.templateresults.selectedIds.value=selIds;
      document.templateresults.action = "emxComponentsSpecifyShareTypesFS.jsp";
      document.templateresults.target="_top";
      document.templateresults.submit();
      return;
  }

  function closeWindow()
  {
     getTopWindow().closeWindow();
    return;
  }

  function doCheck() {
    var objForm = document.templateresults;
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;

    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkItem') > -1){
        objForm.elements[i].checked = chkList.checked;
      }
  }
    // Function to uncheck all the check box values.
  function updateCheck() {
    var objForm     = document.templateresults;
    var chkList     = objForm.chkList;
    chkList.checked = false;
  }


  function newSearch()
  {
    getTopWindow().document.location.href = "../common/emxSearch.jsp?defaultSearch=APPSearchForCompanies&toolbar=APPSearchCompanyToolBar&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&portalMode=false";
  }


</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    // Get actual admin names.
    String typeCompany             =  PropertyUtil.getSchemaProperty(context, "type_Company");
    String attrPhoneNumber         =  PropertyUtil.getSchemaProperty(context, "attribute_OrganizationPhoneNumber");
    String attrFaxNumber           =  PropertyUtil.getSchemaProperty(context, "attribute_OrganizationFaxNumber");
    String attrWebSite             =  PropertyUtil.getSchemaProperty(context, "attribute_WebSite");
    String relCollaborationPartner =  PropertyUtil.getSchemaProperty(context, "relationship_CollaborationPartner");
    String relCollaborationRequest =  PropertyUtil.getSchemaProperty(context, "relationship_CollaborationRequest");
    String typeBusinessUnit        =  PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
    String strDivisionRel          =  PropertyUtil.getSchemaProperty(context, "relationship_Division");
    String relEmployee             =  PropertyUtil.getSchemaProperty(context, "relationship_Employee");

    //Bug 314794 - Start
    String languageStr = request.getHeader("Accept-Language");
    String strUnknownPhoneNumber = i18nNow.getDefaultAttributeValueI18NString(attrPhoneNumber, languageStr); 
    String strUnknownFaxNumber   = i18nNow.getDefaultAttributeValueI18NString(attrFaxNumber, languageStr);  
    AttributeType attrType = new AttributeType(attrPhoneNumber);
    attrType.open(context);
    String sDefaultPhoneNumber = attrType.getDefaultValue();
    attrType.close(context);
    attrType = new AttributeType(attrFaxNumber);
    attrType.open(context);
    String sDefaultFaxNumber = attrType.getDefaultValue();
    attrType.close(context);
    //Bug 314794 - End


    // get the search conditions selected
    String namePattern            = emxGetParameter(request, "txtName");
    Iterator itrSearchList        = null;
    boolean noResultFound         = true;

    // Define select clause.
    SelectList busSelect = new SelectList();

    String selId=DomainObject.SELECT_ID;
    String selName =DomainObject.SELECT_NAME;
    String selType = DomainObject.SELECT_TYPE;
    String selWebSite = busSelect.getAttributeSelect(attrWebSite);
    String selFaxNumber = busSelect.getAttributeSelect(attrFaxNumber);
    String selPhoneNumber = busSelect.getAttributeSelect(attrPhoneNumber);

    busSelect.addElement(selId);
    busSelect.addElement(selName);
    busSelect.addElement(selType);
    busSelect.addElement(selWebSite);
    busSelect.addElement(selFaxNumber);
    busSelect.addElement(selPhoneNumber);

    // Define the company map object.
    ArrayList companyList = new ArrayList();
    BusinessObject boOrgObject = new BusinessObject(objectId);
    boOrgObject.open(context);
    BusinessObject myCompany = null;
    /*
    * Change "search" to "expand" based on the collaboration type.
    */
    if(sLink.equals("Company"))
    {
      companyList = JSPUtil.queryIntoArrayList(context
                                      ,typeCompany
                                      ,namePattern
                                      ,"*"
                                      ,"*"
                                      ,"*"
                                      ,""
                                      ,busSelect
                                      ,objlimit
                                      );

    }
    else if(sLink.equals("BU"))
    {
      companyList = JSPUtil.queryIntoArrayList(context
                                       ,typeBusinessUnit
                                       ,namePattern
                                       ,"*"
                                       ,"*"
                                       ,"*"
                                       ,""
                                       ,busSelect
                                       ,objlimit
                                       );
    }
    if ( companyList != null )
    {
        itrSearchList = companyList.iterator();
    }

    // Loop through each company in the list.
    boolean bConnected = false ;
    Hashtable companyAttributesTable = null;
    String compId = "";

    if(boOrgObject.getTypeName().equals(typeBusinessUnit))
    {
         com.matrixone.apps.common.Company obj = new com.matrixone.apps.common.Company(boOrgObject.getObjectId());
         String key = obj.getInfo(context, DomainObject.SELECT_PRIMARY_KEY);
         myCompany = obj.getCompanyForKey(context, key);
         myCompany.open(context);
         compId = myCompany.getObjectId();
         Company.setId(compId);
         myCompany.close(context);

    } else {

        Company.setId(objectId);

    }

    String sBUId       = "from[" + strDivisionRel+ "].to.id";
    StringList sBUList = Company.getInfoList(context,sBUId);

    String sortName = "";
    String sOrgId = "";
    String sObjectId = "";
    Map map = null;
    BusinessObject boObject = null;

    while (itrSearchList != null && itrSearchList.hasNext())
    {
      bConnected = false ;
      // Get the next map in the list.
      map = (Map) itrSearchList.next();
      sortName = (String)map.get(selName);
      sOrgId = "";
      sObjectId = (String)map.get(selId);

      boObject = new BusinessObject(sObjectId);
      boObject.open(context);

      ArrayList collabRelList = JSPUtil.getCollaborationRels(context
                                                    ,session
                                                    ,boOrgObject
                                                    ,boObject
                                                    );


      if(collabRelList != null && collabRelList.size() > 0)
      {
        bConnected = true;
      } else if(sLink.equals("Company") && compId.equals(sObjectId)) {
        bConnected = true;
      } else if(sLink.equals("BU") && sBUList.contains(sObjectId)) {
        bConnected = true;
      }
      boObject.close(context);

      noResultFound = false;

      Hashtable companyHashTableFinal = new Hashtable();
      companyHashTableFinal.put(DomainObject.SELECT_ID, sObjectId);
      companyHashTableFinal.put(DomainObject.SELECT_NAME, sortName);
      companyHashTableFinal.put(DomainObject.SELECT_TYPE,map.get(DomainObject.SELECT_TYPE));
      companyHashTableFinal.put("bConnected", String.valueOf(bConnected));
      companyHashTableFinal.put("phone", map.get(selPhoneNumber));
      companyHashTableFinal.put("fax", map.get(selFaxNumber));
      companyHashTableFinal.put("website", map.get(selWebSite));

      templateMapList.add(companyHashTableFinal);
  }

  if (emxPage.isNewQuery())
  {
    emxPage.getTable().setObjects(templateMapList);
    emxPage.getTable().setSelects(new SelectList());
  }
  // this Maplist is the one which is used to make the table.
  colMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());

  String sParams = "jsTreeID="+jsTreeID+"&suiteKey="+suiteKey+"&txtName="+namePattern;
  sParams += "&typename=" + sLink + "&pagination=" + sPagination + "&QueryLimit=" + sQueryLimit;


%>

<form name="templateresults" id="templateresults" method="post" target="_parent">
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

  <framework:sortInit
     defaultSortKey="<%=DomainObject.SELECT_NAME%>"
     defaultSortType="string"
     mapList="<%=colMapList%>"
     resourceBundle="emxComponentsStringResource"
     ascendText="emxComponents.Common.SortAscending"
     descendText="emxComponents.Common.SortDescending"
     params = "<%=XSSUtil.encodeForHTML(context, sParams)%>"  />

  <table class="list" id="UITable">
   <tr>
    <th width="2%" style="text-align: center;">
      <span style="text-align: center;">
     <table>
     <tr>
       <td align="center">
         <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
       </td>
     </tr>
     </table>
     </span>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Common.Name"
        sortKey="<%=DomainObject.SELECT_NAME%>"
        sortType="string"/>
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Table.Phone"
        sortKey="phone"
        sortType="string"/>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Common.Fax"
        sortKey="fax"
        sortType="string"/>
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Table.WebSite"
        sortKey="website"
        sortType="string"/>
    </th>

  </tr>

  <framework:mapListItr mapList="<%=colMapList%>" mapName="templateMap">
  <tr class='<framework:swap id ="1" />'>

<%
    sObjectId  = (String)templateMap.get(DomainObject.SELECT_ID);
    String sConnected = (String)templateMap.get("bConnected");
    sortName   = (String)templateMap.get(DomainObject.SELECT_NAME);
    String strType = (String)templateMap.get(DomainObject.SELECT_TYPE);
    selPhoneNumber    = (String)templateMap.get("phone");
    selFaxNumber      = (String)templateMap.get("fax");
    selWebSite        = (String)templateMap.get("website");


    if(boOrgObject.getObjectId().equals(sObjectId) || sConnected.equals("true")) {
%>
     <td align="center"><img src="../common/images/utilCheckOffDisabled.gif" alt="" /></td>
<%
    }  else {
%>
      <td align="center"><input type="checkbox" name="chkItem" id="chkItem" onclick="updateCheck()" value="<%=XSSUtil.encodeForHTMLAttribute(context, sObjectId)%>" /></td>
<%
    }
%>
    <td>
<%
    if(typeCompany.equals(strType))
    {
%>
        <img src="../common/images/iconCompany16.png" name="imgGeneric" id="imgGeneric" border="0" />
<%
    }
    else
    {
%>
        <img src="../common/images/iconBusinessUnit16.png" name="imgGeneric" id="imgGeneric" border="0" />
<%
    }
%>
        <%= XSSUtil.encodeForHTML(context, sortName) %></td>
     <!-- Modiifed below code for bug fix 314794 -->
     <!-- //XSSOK -->
    <td><%= (sDefaultPhoneNumber.equals(selPhoneNumber))?XSSUtil.encodeForHTML(context, strUnknownPhoneNumber):XSSUtil.encodeForHTML(context, selPhoneNumber) %>&nbsp;</td>
    <!-- //XSSOK -->
    <td><%= (sDefaultFaxNumber.equals(selFaxNumber))?XSSUtil.encodeForHTML(context, strUnknownFaxNumber):XSSUtil.encodeForHTML(context, selFaxNumber) %>&nbsp;</td>
      
<%
    if(selWebSite.startsWith("http://")||selWebSite.startsWith("https://"))
    {
%>
      <td><a href="<%= XSSUtil.encodeForHTML(context, selWebSite) %>" target="_blank">
          <%= XSSUtil.encodeForHTML(context, selWebSite) %>
        </a>&nbsp;
      </td>
<%
    }
    else{
%>
      <td><a href="http://<%= XSSUtil.encodeForHTML(context, selWebSite) %>" target="_blank">
          <%= XSSUtil.encodeForHTML(context, selWebSite) %>
        </a>&nbsp;
      </td>
<%
    }
%>
  </tr>
  </framework:mapListItr>

<%
  boOrgObject.close(context);

  if( noResultFound )
  {
%>
    <tr>
        <td align="center" colspan="13" class="error">
        	<emxUtil:i18n localize="i18nId">emxComponents.Common.NoResultsFound</emxUtil:i18n></td>
    </tr>
<%
  }
  %>
  </table>
  <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context, objectId)%>" />
  <input type="hidden" name="selectedIds" value="" />
</form>


<%
  // ----- Common Page End Include  -------
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
