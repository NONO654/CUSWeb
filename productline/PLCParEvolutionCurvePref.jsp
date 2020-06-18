<%--  PLCParEvolutionCurvePref.jsp
  Copyright (c) 2005-2018 Dassault Systemes.  All Rights Reserved.
 --%>
 
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
    

  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no">
    <meta http-equiv="pragma" content="no-cache">
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
        type="text/javascript">
    </SCRIPT>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <script type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
    </script>
  </head>
  <%
  	String preferred = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.TestCase.ParEvolutionCurve");
	String titleBased = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.TestCase.Title");
	String executionTime = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.TestCase.ActualEndDate");
	String pageHeader = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.TestCase.header");
	String chooseFields = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.TestCase.chooseFields");
	
	String ParEvolutionWithTitle         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedEvolutionCurveTypeTitle");		
    String ParEvolutionWithEndDate        = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedEvolutionCurveTypeActualEndDate");		
    
  %>
   <BODY onload="turnOffProgress()">
   	<style type="text/css">
.sceheader{
	background-color: #31659C;
	color: white;
	font-weight: bold;
}
TD.sceheader{
	width: 60%;
	height:40px;
}
	</style>
    <FORM method="post" action="PLCParEvolutionCurvePrefProcess.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
    
    <TABLE>
	        <TR>
			<TD width="200" class='sceheader'>
	           <emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context, preferred) %></emxUtil:i18n>
	        </TD>
		    </TR>
	</TABLE>
		
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
       
       <%
       if(ParEvolutionWithTitle.equalsIgnoreCase("ParEvolutionWithTitle")) 
       {
    	   ParEvolutionWithTitle="checked";
       }
       if(ParEvolutionWithEndDate.equalsIgnoreCase("ParEvolutionWithEndDate")) 
       {
    	   ParEvolutionWithEndDate="checked";
       }
       %>
       
       <TR><TD class="inputField">
					<TR>
		 			<TD style="font-size: 110%; font-weight: bold; font-color: black; padding-left:20px; padding-top:10px; text-decoration: underline;" >
						 <emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context, pageHeader) %></emxUtil:i18n><br>
					</TD>
					</TR>
					
					<TR>
		 			<TD style="font-size: 90%; font-weight: bold; font-color: black; padding-left:90px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context, chooseFields) %></emxUtil:i18n><br>
					</TD>
					</TR>
					
					<TR height="30">
				    <TD  style="padding-left:180px;">
					     <input type="checkbox" name="ParEvolutionWithTitle" id="ParEvolutionWithTitle" value="ParEvolutionWithTitle" <%=("checked".equals(ParEvolutionWithTitle)) ? "checked" : "" %> /> <%=XSSUtil.encodeForHTML(context, titleBased) %>
					</TD>
				    </TR>
					
					<TR height="30">
					<TD  style="padding-left:180px;">
                       <input type="checkbox" name="ParEvolutionWithEndDate" id="ParEvolutionWithEndDate" value="ParEvolutionWithEndDate" <%=("checked".equals(ParEvolutionWithEndDate)) ? "checked" : "" %> /> <%=XSSUtil.encodeForHTML(context, executionTime) %>
               	   </TD>
               	   </TR>
		</TD></TR>
       
      </TABLE>
    </FORM>
  </BODY>
 
</html>



