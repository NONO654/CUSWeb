<%-- ProductConfigurationHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program   
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
//Define request Parameters for toolbar
String toolbar = emxGetParameter(request, "toolbar");
String strFunctionality = emxGetParameter(request, "functionality");
String HelpMarker = emxGetParameter(request, "HelpMarker");
String strpcName = emxGetParameter(request, "pcName");
String strpcType = emxGetParameter(request, "pcType");
boolean bPrinterFriendly = true;
%>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>         
        <script type="text/javascript">		
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
             addStyleSheet("emxUIDialog"); 
        </script>		
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><html>
<head>
</head>
<body>
<form name="mx_filterselect_hidden_form" method="post">
<input type="hidden" name="pheader" value=""/>
<div id="pageHeadDiv">
  <table>
          <tr>           
      <td class="page-title">
		     <h2>
			<%
			String pageHeader;
			if(strFunctionality.equals("ProductConfigurationEditOptionsContentFSInstance"))
			{
			    pageHeader = "emxProduct.Heading.ProductConfigurationEditOptionsContentFSDialog";
			    bPrinterFriendly = false;
			}
			else if(strFunctionality.equals("ProductConfigurationView"))
			{
			    pageHeader = "emxProduct.Heading.ProductConfigurationViewOptions";
			    bPrinterFriendly = false;
			}else if(strFunctionality.equals("ProductConfigurationMarketingRuleValidationReportFSInstance")){
			    pageHeader = "emxProduct.Heading.ProductConfiguration.MarketingRuleValidationReport";
			    bPrinterFriendly = false;
			    %>
			    
		    <%=XSSUtil.encodeForHTML(context,strpcType)%>
            <%=strpcName+ ":"%>
            <%
			}
			else
			{
			    pageHeader = "emxProduct.Heading.ProductConfigurationFlatViewContentFSDialog";
			    bPrinterFriendly = false;
			}
			%>
			
			<emxUtil:i18n localize="i18nId">
            <%=XSSUtil.encodeForHTML(context,pageHeader)%>
			</emxUtil:i18n>
			</h2>
			</td>
			<td class="functions">
                <table>
          <tr>
                        <td class="progress-indicator"><div id="imgProgressDiv">Loading...</div></td>
          </tr>
        </table>
             </td>

           </tr>
        </table>
         <table>      
         <tr>
                  <td>
		<jsp:include page = "../common/emxToolbar.jsp" flush="true">
			<jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context,toolbar)%>"/>
			<jsp:param name="suiteKey" value="Configuration"/>
			<jsp:param name="export" value="false"/>
			<jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context,String.valueOf(bPrinterFriendly))%>"/>
			<jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context,HelpMarker)%>"/>	
		</jsp:include>
      </td>
    </tr>
                
  </table>
        
       </div> 
</form>      
<%@include file = "../emxUICommonEndOfPageInclude.inc"%> 
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
