<%-- emxSearchRouteTemplateResults.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchRouteTemplateResults.jsp.rca 1.15 Wed Oct 22 16:18:08 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<script language="javascript">
  function submitform() {
    var checkedFlag = "false";
    var radioFlag = "false";
    // force to select atleast one member to remove
    for (var varj = 0; varj < document.templateresults.elements.length; varj++) {
      if (document.templateresults.elements[varj].type == "radio") {
        radioFlag = "true";
        if (document.templateresults.elements[varj].checked ){
          checkedFlag = "true";
          var selected = document.templateresults.elements[varj].value;
          var index = selected.indexOf('@');
          parent.window.getWindowOpener().parent.frames[1].document.forms[0].templateName.value=selected.substring(0,index);
          parent.window.getWindowOpener().parent.frames[1].document.forms[0].templateId.value=selected.substring(index+1,selected.length);
          break;
        }
      }
    }

    if ((checkedFlag == "false") && (radioFlag == "true")) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.SearchTemplate.SelectOne</emxUtil:i18nScript>");
      return;
    } else {
      window.closeWindow();
    }
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String supplierOrgId     = emxGetParameter(request,"supplierOrgId");
  boolean isFromSupplierRoute = false;
  if(supplierOrgId != null && !"null".equals(supplierOrgId) && supplierOrgId.trim().length() > 0)
  {
	isFromSupplierRoute = true;
  }
  StringList supplierOrgIdList = new StringList(1);
  supplierOrgIdList.add(supplierOrgId);


  String sNamePattern = emxGetParameter(request,"txtName");
  String sScope = emxGetParameter(request,"selScope");

  //Preload LookUp Strings
  String typeRouteTemplate = PropertyUtil.getSchemaProperty(context,"type_RouteTemplate");
  String relRouteTemplates = PropertyUtil.getSchemaProperty(context,"relationship_RouteTemplates");

  String sUser = "User";
  String sEnterprise = "Enterprise";
  String sAll = "*";

  BusinessObject boPersonObj = JSPUtil.getPerson(context, session);
  BusinessObject boPerson = null;

  boolean isTemplate = false;

  // build Relationship and Type patterns
  Pattern relPattern = new Pattern(relRouteTemplates);
  Pattern typePattern = new Pattern(typeRouteTemplate);

  // build select params
  SelectList selectStmts = new SelectList();
  selectStmts.addName();
  selectStmts.addDescription();
  selectStmts.addRevision();
  selectStmts.addOwner();
  selectStmts.addId();
  selectStmts.addCurrentState();

  // build select params for Relationship
  SelectList selectRelStmts = new SelectList();

  String classname = "odd";
  BusinessObject objTemplate = null;
  Pattern pattern = null;
  if(sNamePattern != null) {
    pattern = new Pattern(sNamePattern);
  } else {
    sNamePattern = sAll;
    sScope = sAll;
    pattern = new Pattern(sAll);
  }

%>

<form name="templateresults" id="templateresults" method="post" onSubmit="return false">
 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

    <tr>
      <th width="5%" style="text-align:center">&nbsp;</th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n></th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></th>
    </tr>

<%
	//select member company ids
	String SELECT_MEMBER_COMPANY_ID = "from[" + DomainObject.RELATIONSHIP_ROUTE_NODE + "].to.to[" + DomainObject.RELATIONSHIP_EMPLOYEE + "].from.id";
	selectStmts.add(SELECT_MEMBER_COMPANY_ID);

    if ((sAll.equals(sScope)) || (sEnterprise.equals(sScope))){
      BusinessObject boOrg = JSPUtil.getOrganization(context, session,boPersonObj);
      if(boOrg != null){
        ExpansionWithSelect templateSelect = boOrg.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                             selectStmts,selectRelStmts,false, true, (short)1);

        RelationshipWithSelectItr relTemplateItr = new RelationshipWithSelectItr(templateSelect.getRelationships());
        while (relTemplateItr != null && relTemplateItr.next()) {

          objTemplate = relTemplateItr.obj().getTo();
          Hashtable templateHash = relTemplateItr.obj().getTargetData();
          String strRevision = (String)templateHash.get("revision");
          String templateId = (String)templateHash.get("id");
          String templateName = (String)templateHash.get("name");
          String templateDesc = (String)templateHash.get("description");
          String templateState = (String)templateHash.get("current");
		  String memberCompanyId = "";
		  StringList memberCompanyIds = new StringList();
		  try{
				memberCompanyId = (String)templateHash.get(SELECT_MEMBER_COMPANY_ID);
				memberCompanyIds.add(memberCompanyId);
		  }catch(Exception e){
				memberCompanyIds = (StringList)templateHash.get(SELECT_MEMBER_COMPANY_ID);
		  }

          if (pattern.match((String) templateName) && templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE)) {
			memberCompanyIds.removeAll(supplierOrgIdList);
			boolean templateHasOnlySupplierPerson = (memberCompanyIds.size() > 0)?false:true;
			if(!isFromSupplierRoute || (isFromSupplierRoute && templateHasOnlySupplierPerson)){
				isTemplate = true;
%><!-- //XSSOK -->
            <tr class="<%=classname%>">
              <td><input type="radio" name ="radList" id="radList" value = "<%=XSSUtil.encodeForHTMLAttribute(context, templateName)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateId)%>" /></td>
              <td><%=XSSUtil.encodeForHTML(context, templateName)%>&nbsp;</td>
              <td><%=XSSUtil.encodeForHTML(context, strRevision)%>&nbsp;</td>
              <td><%=XSSUtil.encodeForHTML(context, templateDesc)%>&nbsp;</td>
            </tr>
<%
            if(classname == "odd") {
              classname = "even";
            }
            else {
              classname = "odd";
            }
          }
		 }
        }
      }
    }


    // To retrieve templates Owned by Current User
    Collection obPersonIds = null;
    Iterator personItr  = null;
    if ((sAll.equals(sScope)) || (sUser.equals(sScope))) {
      HashMap personHash = new HashMap();
      personHash.put("",boPersonObj.getObjectId());
      obPersonIds = personHash.values();

      personItr = obPersonIds.iterator();
      while(personItr.hasNext()) {
        boPerson = new BusinessObject((String)personItr.next());
        ExpansionWithSelect templateSelect = boPerson.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                               selectStmts,selectRelStmts,false, true, (short)1);
        RelationshipWithSelectItr relTemplateItr = new RelationshipWithSelectItr(templateSelect.getRelationships());
        while (relTemplateItr != null && relTemplateItr.next()){
          objTemplate = relTemplateItr.obj().getTo();
          Hashtable templateUserHash = relTemplateItr.obj().getTargetData();
          String strRevision = (String)templateUserHash.get("revision");
          String strOwner = (String)templateUserHash.get("owner");
          String templateId = (String)templateUserHash.get("id");
          String templateName = (String)templateUserHash.get("name");
          String templateDesc = (String)templateUserHash.get("description");
          String templateState = (String)templateUserHash.get("current");
 		  String memberCompanyId = "";
		  StringList memberCompanyIds = new StringList();
		  try{
				memberCompanyId = (String)templateUserHash.get(SELECT_MEMBER_COMPANY_ID);
				memberCompanyIds.add(memberCompanyId);
	 	  }catch(Exception e){
				memberCompanyIds = (StringList)templateUserHash.get(SELECT_MEMBER_COMPANY_ID);
		  }

          if ((pattern.match((String) templateName)) && (strOwner.equals(context.getUser())) && templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE)) {
			  memberCompanyIds.removeAll(supplierOrgIdList);
			  boolean templateHasOnlySupplierPerson = (memberCompanyIds.size() > 0)?false:true;
			  if(!isFromSupplierRoute || (isFromSupplierRoute && templateHasOnlySupplierPerson)){
			     isTemplate = true;
%><!-- //XSSOK -->
            <tr class="<%=classname%>">
              <td><input type="radio" name ="radList" id="radList" value = "<%=XSSUtil.encodeForHTMLAttribute(context, templateName)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateId)%>" /></td>
              <td><%=XSSUtil.encodeForHTML(context, templateName)%>&nbsp;</td>
              <td><%=XSSUtil.encodeForHTML(context, strRevision)%>&nbsp;</td>
              <td><%=XSSUtil.encodeForHTML(context, templateDesc)%>&nbsp;</td>
            </tr>

<%
            if(classname == "odd") {
              classname = "even";
            }
            else {
              classname = "odd";
            }
          }
  	     }
        }
      }
    }

    if(!isTemplate){
%>
      <tr>
        <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.SearchTemplate.NoRouteTemplatesFound</emxUtil:i18n></td>
      </tr>

<%
    }
%>

  </table>
</form>
<%
  // ----- Common Page End Include  -------
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
