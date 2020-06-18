<%--  emxEngrApprovalsSummary.inc  - This is the approvals include file.
   The regular signatures and route approvals required to promote an object are listed here
   with their current status.

   Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEngrApprovalsSummary.jsp.rca 1.23 Wed Oct 22 15:49:21 2008 przemek Experimental przemek $
--%>


<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxPaginationInclude.inc"%>


<%
  DomainObject viewApprovalsBO = DomainObject.newInstance(context);
  Route routeObj = (Route)DomainObject.newInstance(context,
                    DomainConstants.TYPE_ROUTE,DomainConstants.PROGRAM);



  String languageStr        = request.getHeader("Accept-Language");
  String sAdHoc             = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Route.AdHoc", languageStr);
  String sLifeCycle         = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Route.LifeCycle", languageStr);
  String attApprivalStatus  = PropertyUtil.getSchemaProperty(context, "attribute_ApprovalStatus");
  boolean bRouteSize         =false;
  boolean bSign              =false;

  String isPrinterFriendly  = emxGetParameter(request, "PrinterFriendly");
  String objectId           = emxGetParameter(request, "objectId");
  viewApprovalsBO.setId(objectId);

  String sPolicy            = viewApprovalsBO.getInfo(context, viewApprovalsBO.SELECT_POLICY);
  MapList memberList        = new MapList();

  // get a MapList of all the approval data including routes
  MapList stateRouteList = viewApprovalsBO.getApprovalsInfo(context);

  String queryString     = request.getQueryString();
  SelectList objSelects  = new SelectList();
  objSelects.addElement(routeObj.SELECT_NAME);
  objSelects.addElement(Person.SELECT_FIRST_NAME);
  objSelects.addElement(Person.SELECT_LAST_NAME);

  SelectList relSelects  = new SelectList();
  relSelects.addElement(routeObj.SELECT_COMMENTS);
  relSelects.addElement(routeObj.SELECT_APPROVAL_STATUS);
  relSelects.addElement(routeObj.SELECT_APPROVERS_RESPONSIBILITY);
  relSelects.addElement(routeObj.SELECT_ROUTE_TASK_USER);
  
  final String SELECT_ROUTE_SEQUENCE_INPUT = "attribute[" + DomainConstants.ATTRIBUTE_ROUTE_SEQUENCE + "].inputvalue"; 
  relSelects.addElement(SELECT_ROUTE_SEQUENCE_INPUT);
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<!--Modified:7-Sept-2010:s4e:R210 PRG: IR-052762V6R2011x
When view is printer friendly then sort command will be disabled on State column
-->
<%if(!"True".equalsIgnoreCase(isPrinterFriendly))
{
%>

  <fw:sortInit
  defaultSortKey="<%= viewApprovalsBO.SELECT_NAME %>"
  defaultSortType="string"
  resourceBundle="emxProgramCentralStringResource"
  mapList="<%=stateRouteList%>"
  params="<%=XSSUtil.encodeURLForServer(context,queryString) %>"
  ascendText="emxProgramCentral.Common.SortAscending"
  descendText="emxProgramCentral.Common.SortDescending" />

  <table class="list" width="100%" border="0" cellpadding="3" cellspacing="2" >
  <tr>
    <th nowrap="nowrap">
      <fw:sortColumnHeader
          title="emxProgramCentral.Common.State"
          sortKey="<%=viewApprovalsBO.SELECT_NAME%>"
          sortType="string"
          anchorClass="sortMenuItem" />
    </th>
<%
}
else
{
%>
    <fw:sortInit
    defaultSortKey="<%= viewApprovalsBO.SELECT_NAME %>"
    defaultSortType="string"
    resourceBundle="emxProgramCentralStringResource"
    mapList="<%=stateRouteList%>"
    params="<%=XSSUtil.encodeURLForServer(context,queryString) %>"
    ascendText="emxProgramCentral.Common.SortAscending"
    descendText="emxProgramCentral.Common.SortDescending" />

    <table class="list" width="100%" border="0" cellpadding="3" cellspacing="2" >
    <tr>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.State</emxUtil:i18n></th>
<%
}
%>
<!--End:Modified:7-Sept-2010:s4e:R210 PRG: IR-052762V6R2011x -->
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Route</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Signature</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Signer</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Status</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Description</emxUtil:i18n></th>
   </tr>

  <fw:mapListItr mapList="<%= stateRouteList %>" mapName="stateRouteMap">

<%
        StringItr sSignatureItr = null;
        StringItr sSignersItr   = null;
        StringItr sCommentItr   = null;
        StringItr sStatusItr    = null;
        boolean hasSigs = false;

        // Check for State Name and Ad Hoc routes
        String sStateName = (String)stateRouteMap.get(viewApprovalsBO.SELECT_NAME);

        if ("Ad Hoc Routes".equals(sStateName)) {
          hasSigs = false;
          sStateName = sAdHoc;
        }
        else if (sStateName != null) {
          sSignatureItr = new StringItr((StringList)stateRouteMap.get(viewApprovalsBO.KEY_SIGNATURE));
          sSignersItr   = new StringItr((StringList)stateRouteMap.get(viewApprovalsBO.KEY_SIGNER));
          sCommentItr   = new StringItr((StringList)stateRouteMap.get(viewApprovalsBO.KEY_COMMENTS));
          sStatusItr    = new StringItr((StringList)stateRouteMap.get(viewApprovalsBO.KEY_STATUS));
          hasSigs = sSignatureItr.next();
          sSignatureItr.reset();
        }


        // Check for Routes
        Vector routes = (Vector)stateRouteMap.get(viewApprovalsBO.KEY_ROUTES);
        if (hasSigs) {
        bSign=true;

%>
          <tr class='<fw:swap id="0"/>'>
          <td valign="top"><%=i18nNow.getStateI18NString(sPolicy,sStateName.trim(),languageStr)%>&nbsp;</td>
          <td valign="top"><xss:encodeForHTML><%=sLifeCycle%></xss:encodeForHTML>&nbsp;</td>
<%
        }

        String sSignStatus;
        boolean isFirst = true;
        if (sSignatureItr != null) {
          while (sSignatureItr.next()) {

          if (!isFirst)
          {

%>
              <tr class='<fw:swap id="0"/>'>
              <td>&nbsp;</td>
              <td> &nbsp;</td>
<%
            }
            isFirst = false;


             // get next data for each list
             sSignersItr.next();
             sStatusItr.next();
             sCommentItr.next();

             String sSignName = sSignatureItr.obj();
             String sSigner   = sSignersItr.obj();
             String sSignDesc = sCommentItr.obj();
             String status    = sStatusItr.obj();
             // Internationalize status
             if (status.equalsIgnoreCase("Approved")){
               sSignStatus = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Approved", languageStr);
             }
             else if (status.equalsIgnoreCase("Ignore")){
               sSignStatus = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Ignored", languageStr);
             }
             else if (status.equalsIgnoreCase("Rejected")){
               sSignStatus = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Rejected", languageStr);
             }
             else  if (status.equalsIgnoreCase("Signed")){
               sSignStatus = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Signed", languageStr);
             }
             else{
               sSignStatus = "";
             }
%>

               <td valign="top"><xss:encodeForHTML><%=sSignName%></xss:encodeForHTML>&nbsp;</td>
               <td valign="top"><xss:encodeForHTML><%=sSigner%></xss:encodeForHTML>&nbsp;</td>
               <td valign="top"><%if((sSignStatus != null)&&(!sSignStatus.equalsIgnoreCase("null"))){%><xss:encodeForHTML><%=sSignStatus%></xss:encodeForHTML><%}%>&nbsp;</td>
               <td valign="top"><xss:encodeForHTML><%=sSignDesc%></xss:encodeForHTML>&nbsp;</td>
               </tr>
<%
          }
        }

        for (int rteCnt = 0; rteCnt < routes.size(); rteCnt++) {
           bRouteSize=true;
           String sRouteId = (String)routes.get(rteCnt);
%>
           <tr class='<fw:swap id="0"/>'>
<%
           if ((rteCnt == 0) && (!hasSigs)) {
               String strStateName =i18nNow.getStateI18NString(sPolicy,sStateName.trim(),languageStr);
%>
             <td valign="top"><%=strStateName%>&nbsp;</td>
<%
           }
           else {
%>
             <td valign="top">&nbsp;</td>
<%
           }


            String sRouteName = "";
            String routeNodeResponsibility = "";
            String sPersonName             = "";
            String routeNodeStatus         = "";
            String routeNodeComments       = "";

            Hashtable memberMap = new Hashtable();
            if(sRouteId != null && !"null".equals(sRouteId) && !"".equals(sRouteId))
            {
              routeObj.setId(sRouteId);
              sRouteName = routeObj.getName(context);
              memberList = routeObj.getRouteMembers(context, objSelects, relSelects, false);
              memberList.sort(SELECT_ROUTE_SEQUENCE_INPUT, "ascending", "integer");
            }
%>
           <td valign="top"><xss:encodeForHTML><%=sRouteName%></xss:encodeForHTML></td>

<%
            for(int k = 0; k < memberList.size() ; k++)
            {
              memberMap = (Hashtable) memberList.get(k);
              routeNodeResponsibility = (String) memberMap.get(routeObj.SELECT_APPROVERS_RESPONSIBILITY);
              sPersonName             = (String) memberMap.get(routeObj.SELECT_ROUTE_TASK_USER);
              routeNodeStatus         = (String) memberMap.get(routeObj.SELECT_APPROVAL_STATUS);
              routeNodeComments       = (String) memberMap.get(routeObj.SELECT_COMMENTS);

              if(sPersonName == null || "null".equals(sPersonName) || "".equals(sPersonName)){
                //sPersonName             = (String) memberMap.get(routeObj.SELECT_NAME);
                sPersonName             = (String) memberMap.get(Person.SELECT_FIRST_NAME)+" "+(String) memberMap.get(Person.SELECT_LAST_NAME); //IR-408609-3DEXPERIENCER2017x
              }
              else
              {
                sPersonName = PropertyUtil.getSchemaProperty(context, sPersonName);
              }

              if(k > 0)
              {
%>
                <tr class='<fw:swap id="0"/>'>
                <td valign="top">&nbsp;</td>
                <td valign="top">&nbsp;</td>
<%
              }
%>

              <td valign="top"><xss:encodeForHTML><%=routeNodeResponsibility%></xss:encodeForHTML>&nbsp;</td>
              <td valign="top"><xss:encodeForHTML><%=sPersonName%></xss:encodeForHTML>&nbsp;</td>
              <td valign="top"><%=i18nNow.getRangeI18NString(attApprivalStatus, routeNodeStatus,languageStr)%>&nbsp;</td>
              <td valign="top"><xss:encodeForHTMLAttribute><%=routeNodeComments%></xss:encodeForHTMLAttribute>&nbsp;</td>
              </tr>
<%
            }
        }
%>
    </fw:mapListItr>

<%
    if (bRouteSize==false && bSign==false)
    {
      String noFiles = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.NoSignaturesOrRoutesInApprovals",languageStr);
%>
        <tr class="even" ><td colspan="6" align="center" ><xss:encodeForHTML><%=noFiles%></xss:encodeForHTML></td></tr>
<%
    }
%>

  </table>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
