<%--  emxSystemData.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxSystemData.jsp.rca 1.10 Wed Oct 22 15:48:11 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>
<head>

<%@page import  ="com.matrixone.apps.domain.util.MqlUtil"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<title><emxUtil:i18n localize="i18nId">emxFramework.AdminTool.SystemData</emxUtil:i18n></title>

<script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
<%@include file = "emxUIConstantsInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
<script language="JavaScript">
<%
String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

   boolean isPrinterFriendly = false;
   String printerFriendly = emxGetParameter(request, "PrinterFriendly");

if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
 isPrinterFriendly = "true".equals(printerFriendly);
%>
	addStyleSheet("emxUIDefaultPF");
	addStyleSheet("emxUIPropertiesPF");
	addStyleSheet("emxUIPF");
<%
} else {
%>
	addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIForm");
  	addStyleSheet("emxUIToolbar");
	addStyleSheet("emxUIProperties");
    addStyleSheet("emxUIDOMLayout");
    addStyleSheet("emxUIMenu");
<%
}
%>
  </script>


<script language="JavaScript">
   var printDialog = null;
   // Call printer friendly page
   function openPrinterFriendlyPage(){
    strURL = "";
    var strFilterit="";
    var filteringValue="";
    currentURL = document.location.href;

    if (currentURL.indexOf("?") == -1){
      strURL = currentURL + "?PrinterFriendly=true";
    }else{
      strURL = currentURL + "&PrinterFriendly=true";
    }
    iWidth = "700";
    iHeight = "600";
    bScrollbars = true;
      //make sure that there isn't a window already open
    if (!printDialog || printDialog.closed) {

      //build up features string
      var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=yes";

      //calculate center of the screen
      var winleft = parseInt((screen.width - iWidth) / 2);
      var wintop = parseInt((screen.height - iHeight) / 2);

      if (isIE)
        strFeatures += ",left=" + winleft + ",top=" + wintop;
      else
        strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;

      strFeatures +=  ",toolbar=yes";

      //are there scrollbars?
      if (bScrollbars) strFeatures += ",scrollbars=yes";

      //open the window
      printDialog = window.open(strURL, "printDialog" + (new Date()).getTime(), strFeatures);

      //set focus to the dialog
      printDialog.focus();

    } else {
      if (printDialog) printDialog.focus();
    }
  }
</script>

<script language="javaScript">
  var cnt=0;
  function hidediv()
  {
     if(document.getElementById('filter').value != 'All')
     {
       for(var i = 1; i<= cnt ; i++)
       {
         if(document.getElementById('filter').value == i)
         {
            document.getElementById(i).style.display="block";
         }
         else
         {
           document.getElementById(i).style.display="none";
         }
       }
     }
    else
    {
       for(var i = 1; i<= cnt ; i++)
         document.getElementById(i).style.display="block";
    }
  }
</script>
</head>
<body onload="turnOffProgress();" class="no-footer">
<!-- content begins here -->
<%
    Hashtable systemData = FrameworkUtil.getSystemData(context);

   String sHelpMarker ="emxhelpadminmonitor";
   String suiteDir="common";
   String strLanguage = request.getHeader("Accept-Language");
String MatrixINISettings = i18nNow.getI18nString("emxFramework.SystemData.CurrentMatrixINISettings", "emxFrameworkStringResource", strLanguage);

     String[] UpgradeValidArray = new String[3];
     UpgradeValidArray[0] = i18nNow.getI18nString("emxFramework.SystemData.MatrixUpgradeValidation", "emxFrameworkStringResource", strLanguage);
     UpgradeValidArray[1] = i18nNow.getI18nString("emxFramework.SystemData.Administrationtables", "emxFrameworkStringResource", strLanguage);
     UpgradeValidArray[2] = i18nNow.getI18nString("emxFramework.SystemData.Tablesforvaultsandstores", "emxFrameworkStringResource", strLanguage);

%>
<div id="pageHeadDiv" >
<%
String header = "emxFramework.AdminTool.SystemDataPage";
if (isPrinterFriendly) {
	header = "emxFramework.AdminTool.SystemDataPage";
}

String progressImage = "images/utilProgressBlue.gif";
String languageStr = request.getHeader("Accept-Language");
String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
%>
      <table>
       <tr>
      <td class="page-title">
        <!-- //XSSOK -->
        <h2><emxUtil:i18n localize="i18nId"><%=header%></emxUtil:i18n></h2>
      </td>
    <td class="functions">
        <table>
            <tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
    <%
    String strToken= "";
    String mainKey = "";
    if (!isPrinterFriendly) {
    %>
    <td class="filter">
      <select onchange="hidediv()" id="filter" name="filter">
        <option value="All"><emxUtil:i18n localize="i18nId">emxFramework.SystemData.All</emxUtil:i18n></option>
    <%
        int i1=0;
        String optionKey = "";
        for (Enumeration e = systemData.keys() ; e.hasMoreElements() ;)
        {
            mainKey   = (String)e.nextElement();
            optionKey = i18nNow.getI18nString("emxFramework.SystemData."+replace(mainKey), "emxFrameworkStringResource", strLanguage);
           if(optionKey==null || "null".equals(optionKey) || "".equals(optionKey))
            {
               optionKey = mainKey;
            }
        %>
        <option value=<%=++i1%>><%=optionKey%></option>
        <%
           }
        %>
      </select></td>
      <script language="Javascript">
      cnt = <%=i1%>;
      </script>
<%
    }
%>
	              </tr>
	        </table>
        </td>
        </tr>
        </table>
<%
if (!isPrinterFriendly) {
%>

<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="export" value="false"/>
    <jsp:param name="helpMarker" value="emxhelpsystemdata"/>
</jsp:include>
<%
}
%>
</div>
<div id="divPageBody">
    <%
       int count=0;
       String Key   ="";
       String Value = "";
       String internationalizedKey = "";
        String headingKey = "";
        Hashtable data = new Hashtable();

        for (Enumeration e1 = systemData.keys() ; e1.hasMoreElements() ;)
        {
            mainKey   = (String)e1.nextElement();
            data = (Hashtable)systemData.get(mainKey);

            if(mainKey.equals(MatrixINISettings))
            {
              data.remove(MatrixINISettings);
            }
           headingKey = i18nNow.getI18nString("emxFramework.SystemData."+replace(mainKey), "emxFrameworkStringResource", strLanguage);
           if(headingKey==null || "null".equals(headingKey) || "".equals(headingKey))
           {
               headingKey = mainKey;
           }
    %>
      <table class="form" id='<%=++count%>' width="100%">
        <tr>
          <td colspan="2" class="heading1" align="left"><%=headingKey%>:</td>
        </tr>
    <%
         if(!mainKey.equals(UpgradeValidArray[0])){
            Vector keyList = new Vector(data.keySet());
            Collections.sort(keyList);

           for (Enumeration e2 = keyList.elements() ; e2.hasMoreElements() ;)
           {
             Key   = (String)e2.nextElement();
             Value = (String)data.get(Key);
             internationalizedKey = i18nNow.getI18nString("emxFramework.SystemData."+replace(Key), "emxFrameworkStringResource", strLanguage);

    %>
        <tr>
          <!-- //XSSOK -->
          <td class="label" nowrap="nowrap"><%=((!internationalizedKey.equals(""))?internationalizedKey:Key)%></td>
          <!-- //XSSOK -->
          <td class="field"><%=((Value.equals("") || Value.equals("<not set>"))?"&nbsp;":Value)%></td>
        </tr>
    <%
           }
    }else{
			   for(int i=0; i < UpgradeValidArray.length; i++){
				     Key   = (String)UpgradeValidArray[i];
	 				   Value = (String)data.get(Key);
 				 		 if(Value != null){
						 internationalizedKey = i18nNow.getI18nString("emxFramework.SystemData."+replace(Key), "emxFrameworkStringResource", strLanguage);

						 if(Key.equals(UpgradeValidArray[0])){
							 internationalizedKey = "";
							 Key = "";
						 }
						 StringTokenizer resultToken = new StringTokenizer(Value,"~");

				   %>
						<tr>
						  <!-- //XSSOK -->
						  <td class="label" nowrap="nowrap" rowspan = <%=resultToken.countTokens()%>><%=((!internationalizedKey.equals(""))?internationalizedKey:Key)%></td>
						  <td class="field">
					<%
						 while(resultToken.hasMoreTokens()){
							 Value = resultToken.nextToken();
					%>

						  <!-- //XSSOK -->
						  <table><tr><td class="field"><%=((Value.equals("") || Value.equals("<not set>"))?"&nbsp;":Value)%></td></tr></table>
					<%
						 }
%>
						  </td>
						</tr>
					<%
				  }
			   }
		  }
    %>
    </table>
    <%
       }
    MatrixINISettings = null;
       UpgradeValidArray = null;
    %>

</div>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
<%!
  public String replace(String str)
  {
     StringTokenizer stk = new StringTokenizer(str," ");
     StringBuffer sBuf = new StringBuffer();
     while (stk.hasMoreTokens())
     {
       sBuf.append(stk.nextToken());
     }
    return sBuf.toString();
  }

%>
