<%-- DesignEffectivityHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program   
--%>
<html>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
//Define request Parameters for toolbar
String toolbar = emxGetParameter(request, "toolbar");
String strFunctionality = emxGetParameter(request, "functionality");
String HelpMarker = emxGetParameter(request, "HelpMarker");
boolean bPrinterFriendly = true;
%>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>         
        <script type="text/javascript">		
            addStyleSheet("emxUIToolbar");
             addStyleSheet("emxUIDialog"); 
        </script>		
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<div id="pageHeadDiv">
<form name="mx_filterselect_hidden_form" method=post>
<input type="hidden" name="pheader" value=""/>
  <table>
          <tr>          
			<%
			String pageHeader;
			
			//Header of Product Revision ......page
			
			if(strFunctionality.equals("ProductRevisionCreateFlatViewContentFSInstance"))
			{			    
			    pageHeader = "DMCPlanning.Heading.ProductRevisionFlatViewContentFSDialog";
			    bPrinterFriendly = false;
			}			
			else if(strFunctionality.equals("ProductVariantCreateFlatViewContentFSInstance"))
			{
			    pageHeader = "DMCPlanning.Heading.ProductVariantSelectFeature";
			    bPrinterFriendly = false;
			}
			else if(strFunctionality.equals("ProductRevisionEditOptionsContentFSInstance"))
			{
			    pageHeader = "DMCPlanning.Heading.ProductRevisionEditOptionsContentFSInstance";
			    bPrinterFriendly = false;			    
			}
			else
            {           
                pageHeader = "emxProduct.Heading.ProductVariantEdit";
                bPrinterFriendly = false;               
            }
			
			
			%>
			<td class="page-title">  
			<h2> <emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,pageHeader)%></emxUtil:i18n></h2>
            </td>
              </tr>
        </table>
           
		

		<jsp:include page = "../common/emxToolbar.jsp" flush="true">
			<jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context,toolbar)%>"/>
			<jsp:param name="suiteKey" value="DMCPlanning"/>
			<jsp:param name="export" value="false"/>
			<jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, String.valueOf(bPrinterFriendly))%>"/>
			<jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context,HelpMarker)%>"/>	
		</jsp:include>

</form>       
</div>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%> 
</html>
