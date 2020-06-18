<%--
  emxPrefOwnershipInheritance.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
     @quickreview qyg      17:07:12  :  preference for Ownership Inheritance
--%>

<HTML>
<%@ page import="com.matrixone.apps.requirements.ui.*,java.text.*"%> 
<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%!
boolean getPreference(Context context, String pref) throws FrameworkException{
	return !"false".equalsIgnoreCase(PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), pref)); //default is true
}
boolean getResetPreference(Context context, String pref) throws FrameworkException{
	return "true".equalsIgnoreCase(PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), pref)); //default is false
}

%>
<emxUtil:localize id="i18nId" bundle="emxRequirementsStringResource" locale='<%= request.getHeader("Accept-Language")%>' />
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
    <!-- Start HAT1 ZUD HL: TSK3433119 -->
    <style type="text/css">
    
    td
    {
    	border: 1px solid #dddddd;
    	/* text-align: centre; */
    	padding: 8px;
	}
	
	table 
	{
    	font-family: arial, sans-serif;
    	border-collapse: collapse;
    	width: 70%;
	}
	
	tr:nth-child(even) 
	{
    	background-color: #dddddd;
	}
    
    table.TreeDisplay TR TD
    {
    	width: 20%;
    }
    
    table.TreeDisplay TR th
    {
    	font-size: 85%;
	   	border: 1px solid #dddddd;
    	text-align: center;
    	font-weight: bold;
    	height:40px;
    }
   
    
    </style>
    <!-- End HAT1 ZUD HL: TSK3433119 -->
    
    
  </HEAD>
 <%
		String treeDisplay ="";
  %>
  <BODY onload="doLoad(), turnOffProgress(), firstDisplay()">
  	<style type="text/css">
.sceheader{
	background-color: #31659C;
	color: white;
	font-weight: bold;
}
TD.sceheader{
	width: 60%;
}
	</style>
    <FORM name="TreeDisplay" method="post" action="emxPrefOwnershipInheritanceProcessing.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    </br>
		<TABLE>
	        <TR>
			<TD width="150" class='sceheader'>
	           <emxUtil:i18n localize="i18nId">emxRequirements.OwnershipInheritance.Settings.DefaultBehavior</emxUtil:i18n>
	        </TD>
		    </TR>
		</TABLE>
<%
	boolean isPropagateAccessAllowed = RequirementsUtil.isPropagateAccessAllowed(context);
	boolean isInheritAccessAllowed = RequirementsUtil.isInheritAccessAllowed(context);
	if(RequirementsUtil.isAdmin(context)) {
%>		
	       <input type="checkbox" name="pref_RMTAllowPropagateAccess" value="true" <%=isPropagateAccessAllowed ? "checked" : ""%>  />
	       <emxUtil:i18n localize="i18nId">emxRequirements.ActionLink.OwnershipInheritance.AllowPropagateAccess</emxUtil:i18n><br>
	       <input type="checkbox" name="pref_RMTAllowInheritAccess" value="true" <%=isInheritAccessAllowed ? "checked" : ""%>  />
	       <emxUtil:i18n localize="i18nId">emxRequirements.ActionLink.OwnershipInheritance.AllowInheritAccess</emxUtil:i18n>
<%
	}
	else {
%>		
			<TABLE class="TreeDisplay" style="width: 90%">
				  <tr>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.OwnershipInheritance.Settings.Types</emxUtil:i18n>
				    </th>
<%if(isPropagateAccessAllowed){ %>				    
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxFramework.Attribute.Propagate_Access</emxUtil:i18n>
				    </th>
<%}
  if(isInheritAccessAllowed){ 
%>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.Attribute.Access_Type</emxUtil:i18n>
				    </th>
<%}%>				    
				  </tr>
				  
			<!-- Specification Folders -->
				  <tr>
				  
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.SpecificationFolders</emxUtil:i18n><br>
					</TD>
<%if(isPropagateAccessAllowed){ %>				    
					<TD  align=center >
					     <input type="checkbox" id="pref_PropagateAccess_RequirementGroup" name="pref_PropagateAccess_RequirementGroup" value="true" <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_PropagateAccess_RequirementGroup") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}
  if(isInheritAccessAllowed){ 
%>
					<TD align=center>
					     <input type="checkbox" id="pref_InheritAccess_RequirementGroup" name="pref_InheritAccess_RequirementGroup" value="true" <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_InheritAccess_RequirementGroup") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}%>				    
				  </tr>
				  
			<!-- Requirement Specification -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.RequirementSpecifications</emxUtil:i18n><br>
					</TD>
<%if(isPropagateAccessAllowed){ %>				    
					<TD align=center>
						<input type="checkbox" id="pref_PropagateAccess_RequirementSpecification" name="pref_PropagateAccess_RequirementSpecification" value="true"  <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_PropagateAccess_RequirementSpecification") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}
  if(isInheritAccessAllowed){ 
%>
					<TD align=center>
						<input type="checkbox" id="pref_InheritAccess_RequirementSpecification" name="pref_InheritAccess_RequirementSpecification" value="true"  <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_InheritAccess_RequirementSpecification") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}%>				    
				  </tr>
				  
			<!-- Chapters -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Chapters</emxUtil:i18n><br>
					</TD>
<%if(isPropagateAccessAllowed){ %>				    
				  	<TD align=center>
						<input type="checkbox" id="pref_PropagateAccess_Chapter" name="pref_PropagateAccess_Chapter" value="true" <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_PropagateAccess_Chapter") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}
  if(isInheritAccessAllowed){ 
%>
					<TD align=center>
						<input type="checkbox" id="pref_InheritAccess_Chapter" name="pref_InheritAccess_Chapter" value="true" <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_InheritAccess_Chapter") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}%>				    
				  </tr>
				  
			<!-- Requirements -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Requirements</emxUtil:i18n><br>
					</TD>
<%if(isPropagateAccessAllowed){ %>				    
					<TD align=center>
						<input type="checkbox" id="pref_PropagateAccess_Requirement" name="pref_PropagateAccess_Requirement" value="true" <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_PropagateAccess_Requirement") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}
  if(isInheritAccessAllowed){ 
%>
					<TD align=center>
						<input type="checkbox" id="pref_InheritAccess_Requirement" name="pref_InheritAccess_Requirement" value="true"  <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_InheritAccess_Requirement") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}%>				    
				  </tr>
				  
			<!-- Comments -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Comments</emxUtil:i18n><br>
					</TD>
<%if(isPropagateAccessAllowed){ %>				    
					<TD align=center>
						
					</TD>
<%}
  if(isInheritAccessAllowed){ 
%>
					<TD align=center>
						<input type="checkbox" id="pref_InheritAccess_Comment" name="pref_InheritAccess_Comment" value="true" <xss:encodeForHTMLAttribute><%=getPreference(context, "pref_InheritAccess_Comment") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}%>				    
				  </tr>
				  
			</TABLE>
<br>
		<TABLE>
	        <TR>
			<TD width="150" class='sceheader'>
			<emxUtil:i18n localize="i18nId">emxRequirements.OwnershipInheritance.Settings.DefaultBehaviorOnClone</emxUtil:i18n>
	        </TD>
		    </TR>
		</TABLE>
			<TABLE class="TreeDisplay" style="width: 90%">
				  <tr>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.OwnershipInheritance.Settings.Events</emxUtil:i18n>
				    </th>
<%if(isPropagateAccessAllowed){ %>				    
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxFramework.Attribute.Propagate_Access</emxUtil:i18n>
				    </th>
<%}
  if(isInheritAccessAllowed){ 
%>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.Attribute.Access_Type</emxUtil:i18n>
				    </th>
<%}%>				    
				  </tr>
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.OwnershipInheritance.Settings.Events.Clone</emxUtil:i18n><br>
					</TD>
<%if(isPropagateAccessAllowed){ %>				    
					<TD  align=center >
					     <input type="checkbox" id="pref_ResetPropagateAccessOnClone" name="pref_ResetPropagateAccessOnClone" value="true" <xss:encodeForHTMLAttribute><%=getResetPreference(context, "pref_ResetPropagateAccessOnClone") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}
  if(isInheritAccessAllowed){ 
%>
					<TD align=center>
					     <input type="checkbox" id="pref_ResetInheritAccessOnClone" name="pref_ResetInheritAccessOnClone" value="true" <xss:encodeForHTMLAttribute><%=getResetPreference(context, "pref_ResetInheritAccessOnClone") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}%>				    
				  </tr>
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.OwnershipInheritance.Settings.Events.MajorRevise</emxUtil:i18n><br>
					</TD>
<%if(isPropagateAccessAllowed){ %>				    
					<TD  align=center >
					     <input type="checkbox" id="pref_ResetPropagateAccessOnMajorRevise" name="pref_ResetPropagateAccessOnMajorRevise" value="true" <xss:encodeForHTMLAttribute><%=getResetPreference(context, "pref_ResetPropagateAccessOnMajorRevise") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}
  if(isInheritAccessAllowed){ 
%>
					<TD align=center>
					     <input type="checkbox" id="pref_ResetInheritAccessOnMajorRevise" name="pref_ResetInheritAccessOnMajorRevise" value="true" <xss:encodeForHTMLAttribute><%=getResetPreference(context, "pref_ResetInheritAccessOnMajorRevise") ? "checked" : ""%></xss:encodeForHTMLAttribute> />
					</TD>
<%}%>				    
				  </tr>
				    
			</TABLE>
<%
	}
%>			
			</br></br>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>

