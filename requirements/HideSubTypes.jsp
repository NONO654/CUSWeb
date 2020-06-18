
<%--
  HideSubTypes.jsp

 Creates Preference Export Word Format Display.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program


<%-- @Fullreview KIE1 ZUD   16:02:24  :  HL Hide OOTB useless inherited Types.
     	 
--%>

<HTML>
<%@ page import="com.matrixone.apps.requirements.ui.*,java.text.*"%> 
<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<emxUtil:localize id="i18nId" bundle="emxRequirementsStringResource" locale='<%= request.getHeader("Accept-Language")%>' />
<jsp:useBean id="tableBean" class="com.matrixone.apps.requirements.ui.UITableRichText" scope="page"/> 
  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
    <script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
    type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
                                
      function doLoad() {
        if (document.forms[0].elements.length > 0) {
          var objElement = document.forms[0].elements[0];
                                                                
          if (objElement.focus) objElement.focus();
          if (objElement.select) objElement.select();
        }
      }

    </SCRIPT>
  </HEAD>
 
  <BODY onload="doLoad(), turnOffProgress()">
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
    <FORM method="post" action="HideSubTypesProcess.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>    	
		<TABLE>
	        <TR>
			<TD width="200" class='sceheader'>
	           <emxUtil:i18n localize="i18nId">emxRequirements.Settings.Heading.hideSubTypes</emxUtil:i18n>
	        </TD>
		    </TR>
		</TABLE>
			<%
			
			String selectedCustomerRequirementSpecification 		= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_CustomerRequirementSpecification");		
			String selectedCustomerResponseRequirementSpecification = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_CustomerResponseRequirementSpecification");
			String selectedFeatureRequirementSpecification 			= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_FeatureRequirementSpecification");
			String selectedProductRequirementSpecification 			= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_ProductRequirementSpecification");		
			String selectedSubSystemRequirementSpecification 		= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_SubSystemRequirementSpecification");
			String selectedSystemRequirementSpecification 			= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_SystemRequirementSpecification");
			String selectedCustomerSpecification 					= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_CustomerSpecification");	
			String selectedCustomerRequirement 						= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_CustomerRequirement");
			String selectedUserRequirement 							= PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_UserRequirement");
		    
			
	        if(selectedCustomerRequirementSpecification == null || selectedCustomerRequirementSpecification.equals("")) 
			{
	        	selectedCustomerRequirementSpecification="";
			}
	        
	        if(selectedCustomerResponseRequirementSpecification == null || selectedCustomerResponseRequirementSpecification.equals("")) 
			{
	        	selectedCustomerResponseRequirementSpecification="";

			}
	        
	        if(selectedFeatureRequirementSpecification == null || selectedFeatureRequirementSpecification.equals("")) 
			{
	        	selectedFeatureRequirementSpecification="";
			}
	        
	        if(selectedProductRequirementSpecification == null || selectedProductRequirementSpecification.equals("")) 
			{
	        	selectedProductRequirementSpecification="";
			}
	        
	        if(selectedSubSystemRequirementSpecification == null || selectedSubSystemRequirementSpecification.equals("")) 
			{
	        	selectedSubSystemRequirementSpecification="";
			}
	        
	        if(selectedSystemRequirementSpecification == null || selectedSystemRequirementSpecification.equals("")) 
			{
	        	selectedSystemRequirementSpecification="";
			}
	        
	        if(selectedCustomerSpecification == null || selectedCustomerSpecification.equals("")) 
			{
	        	selectedCustomerSpecification="";
			}
	        
	        if(selectedCustomerRequirement == null || selectedCustomerRequirement.equals("")) 
			{
	        	selectedCustomerRequirement="";
			}
	        
	        if(selectedUserRequirement == null || selectedUserRequirement.equals("")) 
			{
	        	selectedUserRequirement="";
			}
	     
	        	
			%>
		<TABLE>

			<TABLE >
				<TR>
		 			<TD class="inputField">
			 			<TR>
			 			<TD style="font-size: 110%; font-weight: bold; font-color: black; padding-left:20px; padding-top:10px; text-decoration: underline;" >
							 <emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.RequirementSpecification</emxUtil:i18n><br>
						</TD>
						</TR>
						
						<TR height="30" >
					    <TD  style="padding-left:180px;">
						     <input type="checkbox" id="CustomerRequirementSpecification" name="CustomerRequirementSpecification" value="Customer Requirement Specification" <xss:encodeForHTMLAttribute><%=selectedCustomerRequirementSpecification%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.CustomerRequirementSpecification</emxUtil:i18n><br>
						</TD>
					    </TR>
					    
					   <TR height="30">
					    <TD style="padding-left:180px;">
						     <input type="checkbox" id="CustomerResponseRequirementSpecification" name="CustomerResponseRequirementSpecification" value="Customer Response Requirement Specification" <xss:encodeForHTMLAttribute><%=selectedCustomerResponseRequirementSpecification%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.CustomerResponseRequirementSpecification</emxUtil:i18n><br>
						</TD>
					    </TR>
					    				    
					    <TR height="30">
					    <TD  style="padding-left:180px;">
						     <input type="checkbox" id="FeatureRequirementSpecification" name="FeatureRequirementSpecification" value="Feature Requirement Specification"  <xss:encodeForHTMLAttribute><%=selectedFeatureRequirementSpecification%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.FeatureRequirementSpecification</emxUtil:i18n><br>
						</TD>
					    </TR>
					    
					    <TR height="30">
					    <TD style="padding-left:180px;">
						     <input type="checkbox" id="ProductRequirementSpecification" name="ProductRequirementSpecification" value="Product Requirement Specification"  <xss:encodeForHTMLAttribute><%=selectedProductRequirementSpecification%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.ProductRequirementSpecification</emxUtil:i18n><br>
						</TD>
						</TR>
						
						<TR height="30">
					    <TD style="padding-left:180px;">
						     <input type="checkbox" id="SubSystemRequirementSpecification" name="SubSystemRequirementSpecification" value="Sub System Requirement Specification"  <xss:encodeForHTMLAttribute><%=selectedSubSystemRequirementSpecification%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.SubSystemRequirementSpecification</emxUtil:i18n><br>
						</TD>
						</TR>
						
						<TR height="30">
					    <TD style="padding-left:180px;">
						     <input type="checkbox" id="SystemRequirementSpecification" name="SystemRequirementSpecification" value="System Requirement Specification"  <xss:encodeForHTMLAttribute><%=selectedSystemRequirementSpecification%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.SystemRequirementSpecification</emxUtil:i18n><br>
						</TD>
						</TR>
						
						<TR height="30">
					    <TD style="padding-left:180px;">
						     <input type="checkbox" id="CustomerSpecification" name="CustomerSpecification" value="Customer Specification"  <xss:encodeForHTMLAttribute><%=selectedCustomerSpecification%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.CustomerSpecification</emxUtil:i18n><br>
						</TD>
						</TR>
	
										
						<TR>
			 			<TD style="font-size: 110%; font-weight: bold; font-color: black; padding-left:20px; padding-top:10px; text-decoration: underline;" >
							 <emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.Requirements</emxUtil:i18n><br>
						</TD>
						</TR>
					
						<TR height="30">
					    <TD style="padding-left:180px;">
						     <input type="checkbox" id="CustomerRequirement" name="CustomerRequirement" value="Customer Requirement"  <xss:encodeForHTMLAttribute><%=selectedCustomerRequirement%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.CustomerRequirement</emxUtil:i18n><br>
						</TD>
						</TR>
						
						<TR height="30">
					    <TD style="padding-left:180px;">
						     <input type="checkbox" id="UserRequirement" name="UserRequirement" value="User Requirement"  <xss:encodeForHTMLAttribute><%=selectedUserRequirement%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.hideSubTypes.UserRequirement</emxUtil:i18n><br>
						</TD>
						</TR>
						
						</TD>
				</TR>	
			</TABLE>
		
		</TABLE>
			
	
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>

