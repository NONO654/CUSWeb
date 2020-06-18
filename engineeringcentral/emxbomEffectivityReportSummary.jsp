<%-- emxbomEffectivityReportSummary.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%
	final String DateFrm = (new Integer(java.text.DateFormat.MEDIUM)).toString();
  Part part = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

  String jsTreeID        = emxGetParameter(request,"jsTreeID");
  String initSource      = emxGetParameter(request,"initSource");
  String suiteKey        = emxGetParameter(request,"suiteKey");
  String objectId        = emxGetParameter(request,"objectId");
  String effectivityDate = emxGetParameter(request,"effectivityDate");
  String effectivityTime = emxGetParameter(request,"effectivityTime");
  String languageStr     = request.getHeader("Accept-Language");

  double iTimeZone = (new Double((String)session.getValue("timeZone"))).doubleValue(); //60*60*1000 *-1;
  String dateStr = eMatrixDateFormat.parseCalendarInputDateTime(effectivityDate, "", iTimeZone, Locale.US);
  String strDateTime = eMatrixDateFormat.getFormattedInputDateTime(dateStr, effectivityTime, DateFormat.SHORT, iTimeZone, Locale.US);
  effectivityDate = strDateTime;
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

  //Determine if we should use printer friendly version
  boolean isPrinterFriendly = false;
  String showPrinterFriendly = emxGetParameter(request,"PrinterFriendly");
  if (showPrinterFriendly != null && !"null".equals(showPrinterFriendly) && !"".equals(showPrinterFriendly)) {
    isPrinterFriendly = "true".equals(showPrinterFriendly);
  }
    String nextURL = "";
    String target = "";
    String newWindowURL = "";
    boolean tempBool = true;
%>
    <%@include file = "emxEngrStartReadTransaction.inc"%>
<%
  try {
    BusinessObject partObj = new BusinessObject(objectId);
    partObj.open(context);

    // Don't bother with report if Development part
    // TODO! This check should be done at the bean level when the rest of this
    // page is moved.
    //
	String policyClassification = EngineeringUtil.getPolicyClassification(context, partObj.getPolicy(context).getName());

    if (policyClassification.equalsIgnoreCase("Development"))
    {
      String policyError = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.EngrEffReport.DevelopmentPolicyError", request.getHeader("Accept-Language"));
      throw new MatrixException(policyError);
    }

    //Get the effective object revision which is in release state based on the effectivity date
    BusinessObject effectiveObjRev = EngineeringUtil.getEfffectiveObjRev(context, partObj, effectivityDate);

    String effectiveBusId = "";
    if (effectiveObjRev != null)
    {
      effectiveBusId = effectiveObjRev.getObjectId();
    }

    part.setId(objectId);
    String partName = part.getName(context);
    String partType = part.getType(context);

    MapList engEffRevDataList = part.getEngEffectivityRevisionData(context, effectiveBusId, null, null, effectivityDate, false);

    // used if need to convert date to the word "present"
    // java.util.Date today = new java.util.Date();
    // SimpleDateFormat mxDateFormat = new SimpleDateFormat(com.matrixone.apps.domain.util.eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
    // StringBuffer todaydate = mxDateFormat.format(today, new StringBuffer(), new FieldPosition(0));
    // today = com.matrixone.apps.domain.util.eMatrixDateFormat.getJavaDate(todaydate.toString());
%>
      <table class="list" border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
          <td class="field">
          <!-- XSSOK -->
            <%=i18nNow.getTypeI18NString(partType,languageStr)%>
          </td>
          <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Name</emxUtil:i18n></td>
          <td class="field">
            <xss:encodeForHTML><%=partName%></xss:encodeForHTML>
          </td>
          <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Rev</emxUtil:i18n></td>
          <td class="field">
            <xss:encodeForHTML><%=part.getRevision(context)%></xss:encodeForHTML>
          </td>
          <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Description</emxUtil:i18n></td>
          <td class="field" wrap="hard">
            <xss:encodeForHTML><%=part.getDescription(context)%></xss:encodeForHTML>
          </td>
        </tr>
      </table>

      <fw:sortInit
          defaultSortKey="none"
          defaultSortType="string"
          resourceBundle="emxEngineeringCentralStringResource"
          mapList="<%= engEffRevDataList %>"
          ascendText="emxEngineeringCentral.Common.SortAscending"
          descendText="emxEngineeringCentral.Common.SortDescending" />

      <table class="list" border="0" cellspacing="3" cellpadding="2" width="100%">
      <tr>
      <!-- XSSOK -->
        <th class="thheading" width="50%" colspan="3" nowrap align="left">&nbsp;<%=i18nNow.getTypeI18NString(partType,languageStr)%> <xss:encodeForHTML><%=partName%></xss:encodeForHTML> (<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Effectivity</emxUtil:i18n> <xss:encodeForHTML><%=effectivityDate%></xss:encodeForHTML>)</th>
        <th class="thheading" width="50%" colspan="3" nowrap align="left">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.FutureReleases</emxUtil:i18n></th>
      </tr>
      <tr>

      <th width="25%" nowrap align="left" class="thheading">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.EngrEffReport.Name"
            sortKey="<%=part.SELECT_NAME%>"
            sortType="string"
            />
      </th>

      <th width="5%" nowrap align="left" class="thheading">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.EngrEffReport.Rev"
            sortKey="<%=part.SELECT_REVISION%>"
            sortType="string"
            />
      </th>

      <th width="20%" nowrap align="left" class="thheading">
       <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.EngrEffReport.EffectiveDate"
            sortKey="<%=part.SELECT_EFFECTIVITY_FROM_DATE%>"
            sortType="string"
            />
      </th>

      <th width="25%" nowrap align="left" class="thheading">
       <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.EngrEffReport.Name"
            sortKey="<%=part.SELECT_FUTURE_NAME%>"
            sortType="string"
            />
      </th>

      <th width="5%" nowrap align="left" class="thheading">
       <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.EngrEffReport.Rev"
            sortKey="<%=part.SELECT_FUTURE_REVISION%>"
            sortType="string"
            />
      </th>

      <th width="20%" nowrap align="left" class="thheading">
       <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.EngrEffReport.EffectiveDate"
            sortKey="<%=part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE%>"
            sortType="string"
            />
      </th>
      </tr>
	<!-- XSSOK -->
      <fw:mapListItr mapList="<%= engEffRevDataList %>" mapName="engEff">
      <tr class='<fw:swap id="1"/>'>
<%
      nextURL =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + engEff.get(part.SELECT_ID) + "&emxSuiteDirectory=" + appDirectory;
      if (!isPrinterFriendly) {
%>
        <!-- XSSOK -->
        <td align="left" width="25%"><font size="2">&nbsp;<a href='javascript:emxShowModalDialog("<%=nextURL%>",650,550,false)'><%=engEff.get(part.SELECT_NAME)%></a>&nbsp;</font></td>
<%
      }
      else {
%>
        <!-- XSSOK -->
        <td align="left" width="25%"><font size="2">&nbsp;<%=engEff.get(part.SELECT_NAME)%>&nbsp;</font></td>
<%
      }
%>
      <td align="left" nowrap width="5%" height="15"><font size="2">&nbsp;<xss:encodeForHTML><%=(String)engEff.get(part.SELECT_REVISION)%></xss:encodeForHTML></font></td>

<%    String futureId = (String)engEff.get(part.SELECT_FUTURE_ID);
      //if (strToDate.length() > 0 && futureId.length() == 0 && today.compareTo(toDate) <= 0) //if the effective to date is today or later
      if (false)
      {
%>
		<!-- XSSOK -->
        <td align="left" nowrap width="20%" height="15"><font size="2"><emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Present</emxUtil:i18n>
        </font></td>
<%    }
      //fix bug 246415, the above code need to be cleaned by original author
      else if("".equals(engEff.get(part.SELECT_NAME)))
      //display empty column if there is no part to display
      {
%>
        <td align="left" nowrap width="20%" height="15">&nbsp;</td>
<%
      }
      else if("".equals(engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE)) && "".equals(engEff.get(part.SELECT_EFFECTIVITY_TO_DATE)) )
      {

%>
        <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.NoEffectiveRevision</emxUtil:i18n></font></td>
<%
      }
      else
      {
%>
         <td align="left" nowrap width="20%" height="15">
            <font size="2">
            <!-- XSSOK -->
                <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate>
                <!-- XSSOK -->
                <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%=engEff.get(part.SELECT_EFFECTIVITY_TO_DATE)%></emxUtil:lzDate>
            </font>
         </td>
<%    }

      if (futureId.length() == 0)
      {
%>
        <td colspan="3" align="left"><font size="2">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.NoFutureReleases</emxUtil:i18n></font></td>
<%
      }
      else
      {
        nextURL =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + engEff.get(part.SELECT_FUTURE_ID) + "&emxSuiteDirectory=" + appDirectory;
        if (!isPrinterFriendly) {
%>
			 <!-- XSSOK -->
          <td align="left" width="25%"><font size="2"><a href='javascript:emxShowModalDialog("<%=nextURL%>",650,550,false)'><%=engEff.get(part.SELECT_FUTURE_NAME)%></a></font></td>
<%
        }
        else {
%>
			 <!-- XSSOK -->
          <td align="left" width="25%"><font size="2"><%=engEff.get(part.SELECT_FUTURE_NAME)%></font></td>
<%
        }
%>
		 <!-- XSSOK -->
        <td align="left" nowrap width="5%" height="15"><font size="2">&nbsp;<%=(String)engEff.get(part.SELECT_FUTURE_REVISION)%></font></td>
<%
        //if (strToDate.length() > 0 && today.compareTo(toDate) <= 0) //if the effective to date is today or later
        if (false)
        {
%>
           <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
           <!-- XSSOK -->
               <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Present</emxUtil:i18n>
              </font></td>
<%
        }
        else
        {
%>
           <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
           <!-- XSSOK -->
               <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_TO_DATE)%></emxUtil:lzDate>
              </font></td>
<%      }
      }
%>
      </tr>
      </fw:mapListItr>
      <tr><td>&nbsp;</td></tr>
      </table>
<%
      // Get the top level children for the current object
      StringList selectRelStmts = new StringList(1);
      selectRelStmts.addElement(part.SELECT_RELATIONSHIP_ID);

      StringList selectStmts = new StringList(4);
      selectStmts.addElement(part.SELECT_ID);
      selectStmts.addElement(part.SELECT_NAME);
      selectStmts.addElement(part.SELECT_DESCRIPTION);
      selectStmts.addElement(part.SELECT_REVISION);

      part.setId(effectiveBusId);
      String effectivePartName = part.getName(context);
      String effectivePartType = part.getType(context);
      String effectiveRevision = part.getRevision(context);
      MapList engEffList = part.getEffectivityBOMReport(context, effectiveBusId, selectStmts, selectRelStmts, effectivityDate);
      boolean isBOMEmpty = engEffList.isEmpty();
      int futureRevListSize = engEffList.size();
%>
      <fw:sortInit
          defaultSortKey="none"
          defaultSortType="string"
          resourceBundle="emxEngineeringCentralStringResource"
          mapList="<%= engEffList %>"
          ascendText="emxEngineeringCentral.Common.SortAscending"
          descendText="emxEngineeringCentral.Common.SortDescending" />

      <table class="list" align = "center" width = "100%" border = "0" cellspacing = "1">
        <tr>
        <!-- XSSOK -->
          <th class="thheading" width="50%" colspan="3" nowrap align="left">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectivityBOMtopLevelFor</emxUtil:i18n> <b><%=i18nNow.getTypeI18NString(effectivePartType,languageStr)%> : <xss:encodeForHTML><%=effectivePartName%></xss:encodeForHTML>  <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Rev</emxUtil:i18n> <xss:encodeForHTML><%=effectiveRevision%></xss:encodeForHTML></th>
          <th class="thheading" width="50%" colspan="3" nowrap align="left">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.FutureReleases</emxUtil:i18n></th>
        </tr>

        <tr>

          <th width="25%" nowrap align="left" class="thheading">
          <!-- XSSOK -->
            <fw:sortColumnHeader
                title="emxEngineeringCentral.EngrEffReport.Name"
                sortKey="<%=part.SELECT_NAME%>"
                sortType="string"
                />
          </th>

          <th width="5%" nowrap align="left" class="thheading">
          <!-- XSSOK -->
            <fw:sortColumnHeader
                title="emxEngineeringCentral.EngrEffReport.Rev"
                sortKey="<%=part.SELECT_REVISION%>"
                sortType="string"
                />
          </th>

          <th width="20%" nowrap align="left" class="thheading">
          <!-- XSSOK -->
            <fw:sortColumnHeader
                title="emxEngineeringCentral.EngrEffReport.EffectiveDate"
                sortKey="<%=part.SELECT_EFFECTIVITY_FROM_DATE%>"
                sortType="string"
                />
          </th>

          <th width="25%" nowrap align="left" class="thheading">
          <!-- XSSOK -->
            <fw:sortColumnHeader
                title="emxEngineeringCentral.EngrEffReport.Name"
                sortKey="<%=part.SELECT_FUTURE_NAME%>"
                sortType="string"
                />
          </th>

          <th width="5%" nowrap align="left" class="thheading">
          <!-- XSSOK -->
            <fw:sortColumnHeader
                title="emxEngineeringCentral.EngrEffReport.Rev"
                sortKey="<%=part.SELECT_FUTURE_REVISION%>"
                sortType="string"
                />
          </th>

          <th width="20%" nowrap align="left" class="thheading">
          <!-- XSSOK -->
            <fw:sortColumnHeader
                title="emxEngineeringCentral.EngrEffReport.EffectiveDate"
                sortKey="<%=part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE%>"
                sortType="string"
                />
          </th>
        </tr>
<%
      if (isBOMEmpty)
      {
%>
        <tr>
          <td>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.NoEffectivityBOMavailable</emxUtil:i18n></td>
        </tr>
<%
      }
      else
      {

%>
		<!-- XSSOK -->
        <fw:mapListItr mapList="<%= engEffList %>" mapName="engEff">
        <!-- XSSOK -->
        <tr class='<fw:swap id="1"/>'>
<%
        nextURL =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + engEff.get(part.SELECT_ID) + "&emxSuiteDirectory=" + appDirectory;
        if (!isPrinterFriendly) {
%>
		<!-- XSSOK -->
          <td align=left width="25%"><font size="2">&nbsp;<%=i18nNow.getTypeI18NString((String)engEff.get(part.SELECT_TYPE),languageStr)%> <a href='javascript:emxShowModalDialog("<%=nextURL%>",650,550,false)'> <%=engEff.get(part.SELECT_NAME)%></a>&nbsp;</font></td>
<%
        }
        else {
%>
			<!-- XSSOK -->
          <td align=left width="25%"><font size="2">&nbsp;<%=i18nNow.getTypeI18NString((String)engEff.get(part.SELECT_TYPE),languageStr)%><%=engEff.get(part.SELECT_NAME)%>&nbsp;</font></td>
<%
        }
%>
		<!-- XSSOK -->
          <td align="left" nowrap width="5%" height="15"><font size="2">&nbsp;<%=engEff.get(part.SELECT_REVISION)%></font></td>
<%
          String fromDate = (String)engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE);
          String futureId = (String)engEff.get(part.SELECT_FUTURE_ID);
          if (fromDate.length() == 0)
          {
%>
             <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;</font></td>
<%
          }
          else
          {
             //if (strToDate.length() > 0 && futureId.length() == 0 && today.compareTo(toDate) <= 0) //if the effective to date is today or later
             if (false)
             {
%>
                <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
                <!-- XSSOK -->
                  <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Present</emxUtil:i18n>
                  </font></td>
<%           }
             else
             {
%>
                <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
                <!-- XSSOK -->
                  <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%=engEff.get(part.SELECT_EFFECTIVITY_TO_DATE)%></emxUtil:lzDate>
                  </font></td>
<%           }
          }
          nextURL =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + engEff.get(part.SELECT_FUTURE_ID) + "&emxSuiteDirectory=" + appDirectory;
          if (futureId.length() == 0)
          {
%>
            <td colspan="3"><font size="2">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.NoFutureReleases</emxUtil:i18n></font></td>
<%
          }
          else
          {
            if (!isPrinterFriendly) {
%>
				<!-- XSSOK -->
              <td align="left" width="25%"><font size="2"><a href='javascript:emxShowModalDialog("<%=nextURL%>",650,550,false)'><%=engEff.get(part.SELECT_FUTURE_NAME)%></a></font></td>
<%
            }
            else {
%>
<!-- XSSOK -->
              <td align="left" width="25%"><font size="2"><%=engEff.get(part.SELECT_FUTURE_NAME)%></font></td>
<%
            }
%>
<!-- XSSOK -->
            <td align="left" nowrap width="5%" height="15"><font size="2">&nbsp;<%=engEff.get(part.SELECT_FUTURE_REVISION)%></font></td>
<%
             //if (strToDate.length() > 0 && today.compareTo(toDate) <= 0) //if the effective to date is today or later
             if (false)
             {
%>
                <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
                <!-- XSSOK -->
                  <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Present</emxUtil:i18n>
                </font></td>
<%           }
             else
             {
%>
                <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
                <!-- XSSOK -->
                  <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_TO_DATE)%></emxUtil:lzDate>
                </font></td>
<%           }
          }
%>
          </tr>
          </fw:mapListItr>
<%
        }
%>
        <tr><td>&nbsp;</td></tr>
    </table>
<%
      // Get the top level children for the current object
      MapList engEffSpecList = part.getEngEffectivitySpecReport(context, effectiveBusId, selectStmts, selectRelStmts, effectivityDate, false);

      boolean isSpecEmpty = engEffSpecList.isEmpty();
      futureRevListSize = engEffSpecList.size();
%>
      <fw:sortInit
          defaultSortKey="none"
          defaultSortType="string"
          resourceBundle="emxEngineeringCentralStringResource"
          mapList="<%= engEffSpecList %>"
          ascendText="emxEngineeringCentral.Common.SortAscending"
          descendText="emxEngineeringCentral.Common.SortDescending" />

      <table class="list" align = "center" width = "100%" border = "0" cellspacing = "1">
      <tr>
      <!-- XSSOK -->
        <th width="50%" colspan="3" nowrap align="left" class="thheading">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.DefiningDocumentsFor</emxUtil:i18n> <b><%=i18nNow.getTypeI18NString(effectivePartType,languageStr)%> : <xss:encodeForHTML><%=effectivePartName%></xss:encodeForHTML>  <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Rev</emxUtil:i18n> <xss:encodeForHTML><%=effectiveRevision%></xss:encodeForHTML></th>
        <th width="50%" colspan="3" nowrap align="left" class="thheading">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.FutureReleases</emxUtil:i18n></th>
      </tr>
      <tr>

        <th width="25%" nowrap align="left" class="thheading">
        <!-- XSSOK -->
          <fw:sortColumnHeader
              title="emxEngineeringCentral.EngrEffReport.Name"
              sortKey="<%=part.SELECT_NAME%>"
              sortType="string"
              />
        </th>

        <th width="5%" nowrap align="left" class="thheading">
        <!-- XSSOK -->
          <fw:sortColumnHeader
              title="emxEngineeringCentral.EngrEffReport.Rev"
              sortKey="<%=part.SELECT_REVISION%>"
              sortType="string"
              />
        </th>

        <th width="20%" nowrap align="left" class="thheading">
        <!-- XSSOK -->
          <fw:sortColumnHeader
              title="emxEngineeringCentral.EngrEffReport.EffectiveDate"
              sortKey="<%=part.SELECT_EFFECTIVITY_FROM_DATE%>"
              sortType="string"
              />
        </th>

        <th width="25%" nowrap align="left" class="thheading">
        <!-- XSSOK -->
          <fw:sortColumnHeader
              title="emxEngineeringCentral.EngrEffReport.Name"
              sortKey="<%=part.SELECT_FUTURE_NAME%>"
              sortType="string"
              />
        </th>

        <th width="5%" nowrap align="left" class="thheading">
        <!-- XSSO: -->
          <fw:sortColumnHeader
              title="emxEngineeringCentral.EngrEffReport.Rev"
              sortKey="<%=part.SELECT_FUTURE_REVISION%>"
              sortType="string"
              />
        </th>

        <th width="20%" nowrap align="left" class="thheading">
        <!-- XSSOK -->
          <fw:sortColumnHeader
              title="emxEngineeringCentral.EngrEffReport.EffectiveDate"
              sortKey="<%=part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE%>"
              sortType="string"
              />
        </th>
      </tr>

<%
    if (isSpecEmpty)
    {
%>
      <tr>
        <td>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.NoDefiningDocuments</emxUtil:i18n></td>
      </tr>
<%
    }
    else
    {
%>
		<!-- XSSOK -->
      <fw:mapListItr mapList="<%= engEffSpecList %>" mapName="engEff">
      <!-- XSSOK -->
      <tr class='<fw:swap id="1"/>'>
<%
        nextURL =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + engEff.get(part.SELECT_ID) + "&emxSuiteDirectory=" + appDirectory;
        if (!isPrinterFriendly) {
%>
		<!-- XSSOK -->
          <td align=left width="25%"><font size="2">&nbsp;<%=i18nNow.getTypeI18NString((String)engEff.get(part.SELECT_TYPE),languageStr)%> <a href='javascript:emxShowModalDialog("<xss:encodeForURL><%=nextURL%></xss:encodeForURL>",650,550,false)'> <%=engEff.get(part.SELECT_NAME)%></a>&nbsp;</font></td>
<%
        }
        else {
%>
			<!-- XSSOK -->
          <td align=left width="25%"><font size="2">&nbsp;<%=i18nNow.getTypeI18NString((String)engEff.get(part.SELECT_TYPE),languageStr)%><%=engEff.get(part.SELECT_NAME)%>&nbsp;</font></td>
<%
        }
%>
		<!-- XSSOK -->
        <td align="left" nowrap width="5%" height="15"><font size="2">&nbsp;<%=engEff.get(part.SELECT_REVISION)%></font></td>

<%
        String fromDate = (String)engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE);
        String futureId = (String)engEff.get(part.SELECT_FUTURE_ID);
        if (fromDate.length() == 0)
        {
%>
          <td><font size="2">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.NoEffectiveRevision</emxUtil:i18n></font></td>
<%
        }
        else
        {
          //if (strToDate.length() > 0 && futureId.length() == 0 && today.compareTo(toDate) <= 0) //if the effective to date is today or later
          if (false)
          {
%>
            <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
            <!-- XSSOK -->
              <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Present</emxUtil:i18n>
            </font></td>
<%        }
          else
          {
%>
            <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
            <!-- XSSOK -->
              <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%=engEff.get(part.SELECT_EFFECTIVITY_TO_DATE)%></emxUtil:lzDate>
            </font></td>
<%        }
        }
        nextURL =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + engEff.get(part.SELECT_FUTURE_ID) + "&emxSuiteDirectory=" + appDirectory;
        if (futureId.length() == 0)
        {
%>
          <td colspan="3"><font size="2">&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.NoFutureReleases</emxUtil:i18n></font></td>
<%
        }
        else
        {
          if (!isPrinterFriendly) {
%>
		  <!-- XSSOK -->
            <td align="left" width="25%"><font size="2"><a href='javascript:emxShowModalDialog("<%=nextURL%>",650,550,false)'><%=engEff.get(part.SELECT_FUTURE_NAME)%></a></font></td>
<%
          }
          else {
%>          
             <!-- XSSOK -->
            <td align="left" width="25%"><font size="2"><%=engEff.get(part.SELECT_FUTURE_NAME)%></font></td>
<%
          }
%>
			  <!-- XSSOK -->
          <td align="left" nowrap width="5%" height="15"><font size="2">&nbsp;<%=engEff.get(part.SELECT_FUTURE_REVISION)%></font></td>
<%
          //if (strToDate.length() > 0 && today.compareTo(toDate) <= 0) //if the effective to date is today or later
          if (false)
          {
%>
            <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
              <!-- XSSOK -->
              <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.Present</emxUtil:i18n>
            </font></td>
<%        }
          else
          {
%>
            <td align="left" nowrap width="20%" height="15"><font size="2">&nbsp;
              <!-- XSSOK -->
              <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_FROM_DATE)%></emxUtil:lzDate> - <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%=engEff.get(part.SELECT_FUTURE_EFFECTIVITY_TO_DATE)%></emxUtil:lzDate>
            </font></td>
<%        }
        }
%>
      </tr>
      </fw:mapListItr>
<%
    }
%>
    </table>
<%
    } catch(Exception e) {
%>
      <%@include file = "emxEngrAbortTransaction.inc"%>
<%
      throw e;
    }
%>
<%@include file = "emxEngrCommitTransaction.inc"%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
