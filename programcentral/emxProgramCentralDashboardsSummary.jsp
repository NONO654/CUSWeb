<%--  emxProgramCentralDashboardsCollectionList.jsp

  Displays the list of user-defined dashboards.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String strPrinterFriendly = emxGetParameter(request,"PrinterFriendly");
  boolean isPrinterFriendly = false;
  if ((strPrinterFriendly != null) && (strPrinterFriendly.equals("true"))) {
    isPrinterFriendly = true;
  }
  String addingTo = emxGetParameter(request,"addingTo");
  String dashboardName = "";
  long  dashboardCount = 0L;
  SetList dashboardList = matrix.db.Set.getSets( context, true);

  // process the adding to flag
  if(addingTo == null){
    addingTo = "null";
  }

  boolean show = !addingTo.equals("True");
  StringBuffer command = new StringBuffer();
  MapList dbMapList = new MapList();
  if ( !dashboardList.isEmpty() )
  {
    Iterator dbList = dashboardList.iterator();
    while ( dbList.hasNext() ) // loop through each set owned by the user
    {
      matrix.db.Set thisSet = ( matrix.db.Set )dbList.next();
      dashboardName = thisSet.toString();
      if ( dashboardName.startsWith( ".dashboard-" ) )
      {
        command.append("list property on set \"" + dashboardName + "\";");
        dashboardName = dashboardName.substring( 11 );
        dashboardCount = thisSet.count( context );
        Long countLong = new java.lang.Long(dashboardCount);
        String nextURL = "emxProgramCentralDashboardsDetailsFS.jsp?dashboardName=" + com.matrixone.apps.domain.util.XSSUtil.encodeForURL(dashboardName);
        //Add values to map and finally onto a maplist.  HTML will use this.
        HashMap dashboardMap = new HashMap();
        dashboardMap.put("dashboardName",dashboardName);
        dashboardMap.put("dashboardCount",countLong.toString());
        dashboardMap.put("nextURL",nextURL);
        dbMapList.add((Map)dashboardMap);
      }
    }

    //Modified:28-Feb-2011:rvw:R211 PRG:IR-098537V6R2012 - pass additional flags to mqlCommand() to allow multiple commands
    String output = MqlUtil.mqlCommand(context, command.toString(), false, true);
    // parse the output and add the description to the map for that set.
    HashMap dbDescMap = new HashMap();
    int dbCount = dbMapList.size();
    int i = 0;
    if (dbCount > 0){
      i = output.indexOf(".dashboard-",i);
      while(i > -1){
        // We have at least one description
        i+=11;
        int endNameIndex = output.indexOf("value",i);
        String dbName = output.substring(i,endNameIndex-1);
        String dbDesc = "";
        int descBeginIndex = endNameIndex + 6;
        i = output.indexOf("description on set",descBeginIndex);
        if (i > -1){ // We have more descriptions to loop through.
          dbDesc = output.substring(descBeginIndex,i-1);
          i = output.indexOf(".dashboard-",i);
        } else { // This is the last description
          dbDesc = output.substring(descBeginIndex,output.length());
        }
        dbDescMap.put(dbName,dbDesc);
      }
    }

    // update the map list
    Iterator dbMapListItr = dbMapList.iterator();
    while (dbMapListItr.hasNext()) {
      Map dbMap = (Map) dbMapListItr.next();
      String name = (String) dbMap.get("dashboardName");
      String description = (String) dbDescMap.get(name);
      if(description == null) {
        description = "";
      }
      dbMap.put("dashboardDesc",description);
    }
  }
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
    <form name="Dashboards" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
        <framework:sortInit
          defaultSortKey="dashboardName"
          defaultSortType="string"
          mapList="<%= dbMapList %>"
          params=""
          resourceBundle="emxProgramCentralStringResource"
          ascendText="emxProgramCentral.Common.SortAscending"
          descendText="emxProgramCentral.Common.SortDescending"/>
            <table class="list" border="0" width="100%">
              <tr>
                <% if (!isPrinterFriendly) { %>
                <th nowrap="nowrap" align="center" width="5%">
                    <input type="checkbox" name="selectAll" onClick="checkAll( this, 'chkbox' )" />
                </th>
                <% } %>

                <th class="thheading" nowrap="nowrap" width="13%">
                  <framework:sortColumnHeader
                    title="emxProgramCentral.Common.DashboardName"
                    sortKey="dashboardName"
                    sortType="string"
                    anchorClass="tab"/>
                </th>
                <th class="thheading" nowrap="nowrap" width="13%">
                  <framework:sortColumnHeader
                    title="emxProgramCentral.Common.DashboardCount"
                    sortKey="dashboardCount"
                    sortType="integer"
                    anchorClass="tab"/>
                </th>
                <th class="thheading" nowrap="nowrap" width="13%">
                  <framework:sortColumnHeader
                    title="emxProgramCentral.Common.Description"
                    sortKey="dashboardDesc"
                    sortType="string"
                    anchorClass="tab"/>
                </th>
                <% if (!isPrinterFriendly) { %>
                  <th nowrap="nowrap" width="10%">&nbsp;</th>
                <% } %>
              </tr>

              <framework:ifExpr expr="<%= dbMapList.size() != 0 %>">
                <framework:mapListItr mapList="<%= dbMapList %>" mapName="map">
<%
        String strAgent = request.getHeader("User-Agent");
        String nextURLpopup = (String) map.get("nextURL");
        if (strAgent != null && strAgent.indexOf("MSIE") > -1) {
          nextURLpopup = com.matrixone.apps.domain.util.XSSUtil.encodeForURL( nextURLpopup );
        }
%>
                  <tr class='<framework:swap id="1"/>'>
                    <% if (!isPrinterFriendly) { %>
                    <td nowrap="nowrap" align="left" width="5%">
                      <input type="checkbox" name="chkbox" value="<xss:encodeForHTMLAttribute><%=map.get("dashboardName")%></xss:encodeForHTMLAttribute>" />
                    </td>
                    <% } %>
                    <td nowrap="nowrap" width="20%">
                      <framework:ifExpr expr = "<%=show%>">
                    <% if (!isPrinterFriendly) { %>
                        <a href="<xss:encodeForHTMLAttribute><%=map.get("nextURL")%></xss:encodeForHTMLAttribute>" target="content">
                   <%-- XSSOK--%> 
                          <img src="../common/images/iconSmallDashboard.gif" border="0"/>&nbsp;<%=map.get("dashboardName")%>
                        </a>
                    <% } else { %>
                    <%-- XSSOK--%>
                          <img src="../common/images/iconSmallDashboard.gif" border="0"/>&nbsp;<%=map.get("dashboardName")%>
                    <% } %>
                      </framework:ifExpr>
                      <framework:ifExpr expr = "<%=!show%>">
                    <% if (!isPrinterFriendly) { %>
                        <a href="javascript:showDetailsPopup('<%=XSSUtil.encodeURLForServer(context,nextURLpopup)%>')">
                     <%-- XSSOK--%> 
                          <img src="../common/images/iconSmallDashboard.gif" border="0"/>&nbsp;<%=map.get("dashboardName")%>
                        </a>
                    <% } else { %>
                     <%-- XSSOK--%>
                         <img src="../common/images/iconSmallDashboard.gif" border="0"/>&nbsp;<%=map.get("dashboardName")%>
                    <% } %>
                      </framework:ifExpr>
                    </td>
                    <td align="center" width="10%"><xss:encodeForHTML><%=map.get("dashboardCount")%></xss:encodeForHTML></td>
                    <td align="left" width="30%"><xss:encodeForHTML><%=map.get("dashboardDesc")%></xss:encodeForHTML></td>
                    <% if (!isPrinterFriendly) { %>
                      <td align="center" width="10%">
                        <a href="javascript:showDetailsPopup('<%=XSSUtil.encodeURLForServer(context,nextURLpopup)%>')">
                          <img src="../common/images/iconNewWindow.gif" border="0" alt="New Window" />
                        </a>
                      </td>
                    <% } %>
                  </tr>
                </framework:mapListItr>
              </framework:ifExpr>
              <framework:ifExpr expr="<%= dbMapList.size() == 0 %>">
                <tr>
                  <td class="noresult" colspan="7" height="40">
              <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.NoDashboards</emxUtil:i18n>
            </td>
                </tr>
              </framework:ifExpr>

            </table>
          </form>
        </body>
    <script language = "javascript" type = "text/javaScript">
    //<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers

    // this function turns on all the checkboxes
    function checkAll ( allbox, chkprefix ) {
      form = allbox.form;
      max = form.elements.length;
      for ( var i = 0; i<max; i++ ) {
        fieldname = form.elements[i].name;
        if ( fieldname.substring( 0, chkprefix.length ) == chkprefix ) {
          form.elements[i].checked = allbox.checked;
        }
      }
    }

    function pageSubmition() {
      form = document.Dashboards;
      var numselected = 0;
      for (var i = 1; i < form.elements.length; i++){
        if(form.elements[i].checked == true){
          var dashboardname = form.elements[i].value;
          numselected++;
        }
      }
      if(numselected != 1){
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseSelectOnlyOneItemForEdit</emxUtil:i18nScript>");
        return;
      }
      parent.getWindowOpener().AddDashboard(dashboardname);
      parent.window.closeWindow();
    }

    function submitDelete() {
      form = document.Dashboards;
      chkprefix = 'chkbox';
      max = form.elements.length;
      num = 0;
      dashCount = 0;
      var CollectionString = "";
      for (var i=0; i<max; i++) {
        fieldname = form.elements[i].name;
        if (fieldname.substring(0,chkprefix.length) == chkprefix) {
          dashCount++;
          if(form.elements[i].checked == true) {
            num++;
            CollectionString += "\n\t" + form.elements[i].value;
          }
        }
      }
      if (dashCount == 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.NoDashboardsToDelete</emxUtil:i18nScript>");
        return false;
      } else if (num == 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.SelectItemToDelete</emxUtil:i18nScript>");
        return false;
      }

      var confirmText = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ConfirmDashboardsDelete1</emxUtil:i18nScript>";
      confirmText += "\n" + CollectionString + "\n\n";
      confirmText += "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ConfirmDashboardsDelete2</emxUtil:i18nScript>";

      if(confirm(confirmText)) {
        form.action = "emxProgramCentralDashboardsDeleteProcess.jsp";
        form.submit();
      }
      else return false;
    }

    // Stop hiding here -->//]]>
    </script>
</html>
