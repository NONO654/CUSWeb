<%-- emxComponentsPotentialSuppliersSearchResults.jsp   -  The Supplier Summary page

   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPotentialSuppliersSearchResults.jsp.rca 1.8 Wed Oct 22 16:17:58 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file  = "../emxPaginationInclude.inc" %>
<%@include file = "emxComponentsCollaborateSearchResultsInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language = "javascript">

  function designate() 
  {
      if(jsIsClicked()) {
          alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
          return;
      }
    var objForm = document.SupplierSummary;
    var checkedFlag = "false";

    for (var varj = 0; varj < objForm.elements.length; varj++) 
    {
      if (objForm.elements[varj].type == "checkbox" &&
      objForm.elements[varj].checked &&
      ( objForm.elements[varj].name.indexOf('supplierId') > -1)) 
      {
        checkedFlag = "true";
        break;
      }
    }
    // force to select atleast one item
    if (checkedFlag == "false") 
    {
      alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Common.PleaseSelectAnItem</emxUtil:i18nScript>");
      return;
    }
    objForm.action = "emxComponentsPotentialSuppliersAddExistingProcess.jsp";
    objForm.target="_top";
    if (jsDblClick()) {
        objForm.submit();
    }
    return;
  }

  function doCheck() 
  {
    var objForm = document.SupplierSummary;
    var chkList = objForm.chkList;

    for (var i=0; i < objForm.elements.length; i++)
    {
      if (objForm.elements[i].name.indexOf('supplierId') > -1)
      {
        objForm.elements[i].checked = chkList.checked;
      }  
    }
  }  

  function updateCheck() 
  {
    var objForm     = document.SupplierSummary;
    var chkList     = objForm.chkList;
    chkList.checked = false;
  }
</script>

<%
    MapList orgObjMapList =  new MapList();
    MapList orgMapList = new MapList();
    
    String namePattern             = emxGetParameter(request, "txtName");
    String jsTreeID                = emxGetParameter(request,"jsTreeID");
    String suiteKey                = emxGetParameter(request,"suiteKey");
    String sLink                   = emxGetParameter(request,"typename");
    String objectId                = emxGetParameter(request,"objectId");
    String sPagination             = emxGetParameter(request,"pagination");
    String sQueryLimit             = emxGetParameter(request,"QueryLimit");

    String sParams = "jsTreeID="+jsTreeID+"&suiteKey="+suiteKey+"&txtName="+namePattern;
    sParams += "&objectId=" + objectId + "&typename=" + sLink + "&pagination=" + sPagination + "&QueryLimit=" + sQueryLimit;
    
    short objlimit = 0;
    try
    {
      objlimit = Short.parseShort(sQueryLimit);
    }
    catch(NumberFormatException e)
    {
      objlimit = 0;
    }

    if(sLink == null)
    {
      sLink ="Company";
    } 
    
    String typeCompany             =  PropertyUtil.getSchemaProperty(context, "type_Company");
    String attrPhoneNumber         =  PropertyUtil.getSchemaProperty(context, "attribute_OrganizationPhoneNumber");
    String attrFaxNumber           =  PropertyUtil.getSchemaProperty(context, "attribute_OrganizationFaxNumber");
    String attrWebSite             =  PropertyUtil.getSchemaProperty(context, "attribute_WebSite");
    String typeBusinessUnit        =  PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
    String strDivisionRel          =  PropertyUtil.getSchemaProperty(context, "relationship_Division");
    String stateActive             =  FrameworkUtil.lookupStateName(context, DomainObject.POLICY_ORGANIZATION, "state_Active");

    // Define select clause.
    SelectList busSelect = new SelectList();
    String selId            = DomainObject.SELECT_ID;
    String selName          = DomainObject.SELECT_NAME;
    String selType          = DomainObject.SELECT_TYPE;
    String selWebSite       = busSelect.getAttributeSelect(attrWebSite);
    String selPhoneNumber   = busSelect.getAttributeSelect(attrPhoneNumber);
    String selParentName    = "to["+ DomainObject.RELATIONSHIP_DIVISION +"].from.name";
    String selParentType    = "to["+ DomainObject.RELATIONSHIP_DIVISION +"].from.type";
    String selParentID      = "to["+ DomainObject.RELATIONSHIP_DIVISION +"].from.id";
    String selSupplierID    = "to["+ DomainObject.RELATIONSHIP_SUPPLIER +"].from.id";
    String selCurrent       = DomainObject.SELECT_CURRENT;

    busSelect.addElement(selId);
    busSelect.addElement(selName);
    busSelect.addElement(selType);
    busSelect.addElement(selWebSite);
    busSelect.addElement(selPhoneNumber);
    busSelect.addElement(selParentName);
    busSelect.addElement(selParentType);
    busSelect.addElement(selParentID);
    busSelect.addElement(selSupplierID);
    busSelect.addElement(selCurrent);
    
    String whereClause = selId + "!=" + objectId;

    // Define the company map object.
    ArrayList companyList = new ArrayList();

    if(sLink.equals("Company")) 
    {
      companyList = JSPUtil.queryIntoArrayList(context
                                      ,typeCompany
                                      ,namePattern
                                      ,"*"
                                      ,"*"
                                      ,"*"
                                      ,whereClause
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
                                       ,whereClause
                                       ,busSelect
                                       ,objlimit
                                       );
    }
    
    Iterator itrSearchList = companyList.iterator();
    boolean noResultFound         = true;
    
    Map mapOrg = null;
    while (itrSearchList.hasNext()) 
    {
        mapOrg = (Map) itrSearchList.next();
        orgObjMapList.add(mapOrg);
        noResultFound = false;
    }
    
    if (emxPage.isNewQuery()) 
    {
      emxPage.getTable().setObjects(orgObjMapList);
      emxPage.getTable().setSelects(new SelectList());
    }
    // this Maplist is the one which is used to make the table.
    orgMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
    
    String supplierId      = "";
    String supplierType    = "";
    String supplierName    = "";
    String supplierPhone   = "";
    String supplierWebSite = "";
    String currentState    = "";
    String companyName     = "";
    String companyType     = "";
    boolean isSupplier     = false;
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="SupplierSummary" method="post" action="emxComponentsPotentialSuppliersAddExistingProcess.jsp">
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

<framework:sortInit
   defaultSortKey="<%= DomainObject.SELECT_NAME %>"
   defaultSortType="string"
   resourceBundle="emxComponentsStringResource"
   mapList="<%= orgMapList %>"
   ascendText="emxComponents.Common.SortAscending"
   descendText="emxComponents.Common.SortDescending" />


<table class="list" id="UITable">
  <tr>
        <th width="2%"> 
             <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
        </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Common.Name"
        sortKey="<%=selName%>"
        sortType="string"/>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Table.Phone"
        sortKey="<%=selPhoneNumber%>"
        sortType="string"/>
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Table.WebSite"
        sortKey="<%=selWebSite%>"
        sortType="string"/>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Common.CompanyName"
        sortKey="<%=selParentName%>"
        sortType="string"/>
    </th>

  </tr>


 <framework:mapListItr mapList="<%= orgMapList %>" mapName="map">
<%
    supplierId = (String)map.get(selId);
    supplierName =  (String)map.get(selName);
    supplierType = (String)map.get(selType);
    supplierPhone = (String)map.get(selPhoneNumber);
    supplierWebSite = (String)map.get(selWebSite);
    currentState =  (String)map.get(selCurrent);
    companyName = (String)map.get(selParentName);
    if(companyName == null || "null".equals(companyName))
    {
        companyName = "";
    }
    companyType = (String)map.get(selParentType);
    if(companyType == null || "null".equals(companyType))
    {
        companyType = "";
    }

    String suppliers = (String)map.get(selSupplierID);
    isSupplier =  false;
    if( suppliers != null && !"".equals(suppliers))
    {
      isSupplier = (suppliers.indexOf(objectId) != -1);
    }
     
    if( !isSupplier )
    {
%>
      <tr class='<framework:swap id ="1" />'>
      <td>
<%       
      if (!stateActive.equals(currentState)) 
      {
%>
         &nbsp;<img src="images/utilCheckOffDisabled.gif" />
<%    }
      else
      {
%>       
         <input type="checkbox" name="supplierId" value="<xss:encodeForHTMLAttribute><%=supplierId%></xss:encodeForHTMLAttribute>" onclick="updateCheck()" />
<%         
      }
%>       
      </td>
    
      <td><img src="../common/images/<%=(typeCompany.equals(supplierType))?"iconSmallCompany":"iconSmallBusinessUnit"%>.gif" name="imgGeneric" id="imgGeneric" border="0" alt="<xss:encodeForHTMLAttribute><%=supplierName%></xss:encodeForHTMLAttribute>" /><xss:encodeForHTML><%=supplierName%></xss:encodeForHTML>&nbsp;</td>
      <td><xss:encodeForHTML><%=supplierPhone%></xss:encodeForHTML>&nbsp;</td>
      <td>
<%
      if(supplierWebSite.startsWith("http://")||supplierWebSite.startsWith("https://"))
      {
%>
         <!-- //XSSOK -->
        <a href="<%= supplierWebSite %>" target="_blank">
<%
      }
      else
      {
%>
  <!-- //XSSOK -->
        <a href="http://<%= supplierWebSite %>" target="_blank">
<%
      }
%>
      <xss:encodeForHTML><%= supplierWebSite %></xss:encodeForHTML>
      </a>&nbsp;
    </td>
    
    <td>
<%    
    if(!"".equals(companyName))
    {
%>    
        <img src="../common/images/<%=(typeCompany.equals(companyType))?"iconSmallCompany":"iconSmallBusinessUnit"%>.gif" name="imgGeneric" id="imgGeneric" border="0" alt="*" /><xss:encodeForHTML><%=companyName%></xss:encodeForHTML>
<%        
    }
%>    
    &nbsp;</td>
    </tr>
<%
   }
%>
 </framework:mapListItr>
<% 
  if( noResultFound ) 
  {
%>
    <tr>
        <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.Common.NoResultsFound</emxUtil:i18n></td>
    </tr>
<%
  }
%>
 
</table>
<input type = "hidden" name = "objectId" value = "<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
</form>

<!-- Contents Ends Here  -->
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
