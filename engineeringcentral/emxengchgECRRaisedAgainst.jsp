<%-- emxengchgECRRaisedAgainst.jsp--This pag searches for Parts raised against an ECR.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxengchgJavaScript.js" %>


<%
  Part partId = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  ECR ecrId = (ECR)DomainObject.newInstance(context,
                    DomainConstants.TYPE_ECR,DomainConstants.ENGINEERING);


  String objectId = emxGetParameter(request,"objectId");
  // 359020 - updated Raised Against Change to Raised Against ECR
  String sRel = PropertyUtil.getSchemaProperty(context,"relationship_RaisedAgainstECR");

  String languageStr = request.getHeader("Accept-Language");
  //For I18n
  String stypeECR = PropertyUtil.getSchemaProperty(context,"type_ECR");
  String sLanButtonAccessDenied = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.AccessDenied", languageStr);
  String sLanButtonDisconnect = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Disconnect", languageStr);

  BusinessObject partIdObj = null;
  int iSequence = 0;
  //Get the form values from the request parameter
  String sECRNum = emxGetParameter(request, "objectId");
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  try
  {
  // Set the Id for ECR bean
  ecrId.setId(sECRNum);//sECOId);
  /* Definitions for ECR to Part expand select */
  SelectList sListSelRelStmts = ecrId.getRelationshipSelectList(5);
  sListSelRelStmts.addElement(DomainRelationship.SELECT_ID);
  sListSelRelStmts.addElement(DomainRelationship.SELECT_NAME);
  SelectList sListSelStmts = ecrId.getObjectSelectList(9);
  sListSelStmts.addElement(DomainObject.SELECT_ID);
  sListSelStmts.addElement(DomainObject.SELECT_NAME);
  sListSelStmts.addType();
  sListSelStmts.addDescription();
  sListSelStmts.addRevision();
  sListSelStmts.addElement("policy");
    String srelPattern = sRel;
%>
  <%@include file = "../emxUICommonHeaderEndInclude.inc" %>
    <form name="formDataRows" method="post">
<%
    //DISPLAY SECTION//
    //Declare display variables
    //V6R2011
    //MapList partMapList = ecrId.expandSelect(context, srelPattern, "*", sListSelStmts, sListSelRelStmts, false, true, (short)1,null,null,null,false);
com.matrixone.apps.domain.util.ContextUtil.startTransaction(context,false);
	MapList partMapList = FrameworkUtil.toMapList(ecrId.getExpansionIterator(context, srelPattern, "*",
	        sListSelStmts, sListSelRelStmts, false, true, (short)1,
        null, null, (short)0,
        false, false, (short)0, false),
        (short)0, null, null, null, null);
	com.matrixone.apps.domain.util.ContextUtil.commitTransaction(context);
    iSequence = 1;
    String sColspan = null;
    int iOddEven = 1;
    String sRowClass = "";
    boolean boolDataFound = false;
    BusinessObject busObjPart = null;
    boolean boolHasAccessOnThisNewPart = false;
    boolean boolHasAccessOnAnyNewPart =  false;
    String nextURL = "";
    String target = "";
  if(partMapList.size() > 0)
  {

  String queryString = emxGetQueryString(request);
  //Determine if we should use printer friendly version
  String showPrinterFriendly = emxGetParameter(request,"showPrinterFriendly");
%><!-- XSSOK -->
     <fw:sortInit
             defaultSortKey="<%= ecrId.SELECT_NAME %>"
             defaultSortType="string"
             resourceBundle="emxEngineeringCentralStringResource"
             mapList="<%= partMapList %>"
             params="<%= queryString %>"
            ascendText="emxEngineeringCentral.Common.SortAscending"
            descendText="emxEngineeringCentral.Common.SortDescending"
             />
     <table width="100%%" border="0" cellpadding="3" cellspacing="3">
         <tr>
           <th nowrap="nowrap"><!-- XSSOK -->
             <fw:sortColumnHeader
                       title="emxEngineeringCentral.Common.Name"
                       sortKey="<%= ecrId.SELECT_NAME %>"
                       sortType="string"
                       anchorClass="sortMenuItem" />
           </th>
           <th nowrap="nowrap"><!-- XSSOK -->
             <fw:sortColumnHeader
                       title="emxEngineeringCentral.Common.Revision"
                       sortKey="<%= ecrId.SELECT_REVISION %>"
                       sortType="string"
                       anchorClass="sortMenuItem" />
           </th>

           <th nowrap="nowrap"><!-- XSSOK -->
             <fw:sortColumnHeader
                       title="emxEngineeringCentral.Common.Type"
                       sortKey="<%= ecrId.SELECT_TYPE %>"
                       sortType="string"
                       anchorClass="sortMenuItem" />
           </th>

           <th nowrap="nowrap"><!-- XSSOK -->
             <fw:sortColumnHeader
                 title="emxEngineeringCentral.ECO.PartDescription"
                 sortKey="<%= ecrId.SELECT_DESCRIPTION %>"
                 sortType="string"
                 anchorClass="sortMenuItem" />
           </th>
           <th nowrap="nowrap"><!-- XSSOK -->
             <fw:sortColumnHeader
                       title="emxEngineeringCentral.Common.State"
                       sortKey="<%= ecrId.SELECT_STATES %>"
                       sortType="string"
                       anchorClass="sortMenuItem" />
           </th>

         </tr>
         <!-- XSSOK -->
       <fw:mapListItr mapList="<%= partMapList %>" mapName="partMap">
       <!-- XSSOK -->
        <tr class='<fw:swap id="even"/>'>
<%
          String typeIcon = null;
          String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");
          String alias = FrameworkUtil.getAliasForAdmin(context, "type", (String)partMap.get(DomainObject.SELECT_TYPE), true);

          if ((alias == null) || (alias.equals("")) || (alias.equals("null"))){          
            typeIcon = defaultTypeIcon;
          }
          else {
            typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
          }
        //Determine new/revised part and get revision numbers if applicable
          String sPartId = (String)partMap.get(DomainObject.SELECT_ID);
          String sObjType = (String)partMap.get("type");
          String sPartName = (String)partMap.get(DomainObject.SELECT_NAME);
          String sPartDescription = (String)partMap.get("description");
          partId.setId(sPartId);
          String sPartstate = partId.getCurrentState(context).getName();
          String sPartRev = (String)partMap.get("revision");
          String sPolicy  = (String)partMap.get("policy");
          boolDataFound = true;
%>

          <input type="hidden" name="PartName" value="<xss:encodeForHTMLAttribute><%=sPartName%></xss:encodeForHTMLAttribute>" />
          <!-- XSSOK -->
          <td width="85%"><img src="../common/images/<%=typeIcon%>" border="0" alt="<%=i18nNow.getTypeI18NString(sObjType,languageStr)%>" />&nbsp;<xss:encodeForHTML><%=sPartName%></xss:encodeForHTML></td>
	  <!-- XSSOK -->
          <td width="4%" ><%=sPartRev%>&nbsp;</td>
	  <!-- XSSOK -->
          <td width="8%" ><%=i18nNow.getTypeI18NString(sObjType,languageStr)%>&nbsp;</td>
	  <!-- XSSOK -->
          <td width="12%"><%=sPartDescription%>&nbsp;</td>
	  <!-- XSSOK -->
          <td width="10%"><%=i18nNow.getStateI18NString(sPolicy,sPartstate,languageStr)%>&nbsp;</td>
        <tr></tr>
<%
          iSequence++;
%>
        </tr>
        </fw:mapListItr>
      </table>
<%
    } //end if
      if (partMapList.size() == 0)
      {
%>
         <table width="95%" border="0" >
           <tr>
            <td width="25%" class="label"><b><emxUtil:i18n localize="i18nId">emxEngineeringCentral.ECR.NoPartRaisedAgainstECR</emxUtil:i18n>&nbsp; <xss:encodeForHTML><%=stypeECR%></xss:encodeForHTML></b> </td>
           </tr>
         </table >
<%
      }
    } //end try
    catch(Exception Ex)
    {
         // System.out.println(Ex.toString());
         com.matrixone.apps.domain.util.ContextUtil.abortTransaction(context);
         throw Ex;
    }
%>
 <%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
