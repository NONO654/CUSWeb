<%--
  TreeDisplaySettings.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%-- @quickreview HAT1 ZUD 14:12:22    HL Requirement Specification Dependency 
     @quickreview HAT1 ZUD 15:04:24   : Modifications to check null value.
     @quickreview HAT1 ZUD 15:10:12   : IR-393850-3DEXPERIENCER2017x: R418:FUN048478-"|" Field separator is not getting applied between title and revision on tree display.
     @quickreview KIE1 ZUD  16:07:19  : IR-448762-3DEXPERIENCER2017x: Tree preferences not applicable on Structure browser 
     @quickreview KIE1 ZUD  16:12:13  :	IR-484700-3DEXPERIENCER2018x: R419-FUN055951: In Envoia Preferences user is unable to unselect options in Tree Display section once they are selected by user.
     @quickreview HAT1 ZUD  17:03:07  : TSK3433119: needs to add tree display user preference for spec folder, also needs to render the tree display preferences in a table
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
      
      function validateSettings(attribute, nameId, titleId)
      {
    	  //alert("into validateSettings = " + nameId + " --- " + titleId);
    	  switch(attribute)
    	  {		
    	  		case "name":
    	  			  if(document.getElementById(nameId).checked == true)
    	     		  {
    	      		      //alert(titleId + " = " + document.getElementById(titleId).checked);
	    	      		  document.getElementById(titleId).checked = true;
    	     		  }
    	  			  break;
    	  			
    	  		case "title":
    	  			  if(document.getElementById(titleId).checked == true)
    	     		  {
	    	      		    //alert(nameId + " = " + document.getElementById(nameId).checked);
    	      		  		document.getElementById(nameId).checked = true;
    	     		  }
    	  			  break;
    	  
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
    <FORM name="TreeDisplay" method="post" action="TreeDisplaySettingsProcessing.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    </br>
   		<TABLE>
	    	<TR>
				<TD class='sceheader' colspan='3'><emxUtil:i18n localize="i18nId">emxRequirements.Heading.columnManagement</emxUtil:i18n>:</TD>
			</TR>
			</TABLE>
			
			<TABLE>
			<TR>
			 <TD width="150" class="label" colspan='2'>
	            	<emxUtil:i18n localize="i18nId">emxRequirements.Heading.columnToDisplayed</emxUtil:i18n>
	         </TD>
	         <%
          // ++KIE1 ZUD added for Structure Browser and Dyna Tree
          	String selectedColumnDisplayName         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedColumnDisplayName");		
	        String selectedColumnDisplayTitle        = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedColumnDisplayTitle");
	        
	        if((selectedColumnDisplayName == null || selectedColumnDisplayName.equalsIgnoreCase("null") || selectedColumnDisplayName.equalsIgnoreCase("")) 
	        		&& ((selectedColumnDisplayTitle == null || selectedColumnDisplayTitle.equalsIgnoreCase("null") || selectedColumnDisplayTitle.equalsIgnoreCase(""))))
	        {
	        	selectedColumnDisplayName		  ="";
	        	selectedColumnDisplayTitle        ="checked";
	        }else{
	        	if(selectedColumnDisplayName.equalsIgnoreCase("ColumnDisplayName")) 
		        {
	        		selectedColumnDisplayName="checked";
		        }
		        if(selectedColumnDisplayTitle.equalsIgnoreCase("ColumnDisplayTitle")) 
		        {
		        	selectedColumnDisplayTitle="checked";
		        }	
	        }
	      // --KIE1 ZUD added for Structure Browser and Dyna Tree
          %>
          	<TD class="inputField">
				<input type="checkbox" id="ColumnDisplayName" name="ColumnDisplayName" value="ColumnDisplayName"  onmouseup="validateSettings('name', 'ColumnDisplayName', 'ColumnDisplayTitle')" <xss:encodeForHTMLAttribute><%=selectedColumnDisplayName%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Name</emxUtil:i18n><br>
				<input type="checkbox" id="ColumnDisplayTitle" name="ColumnDisplayTitle" value="ColumnDisplayTitle"  onmouseup="validateSettings('title', 'ColumnDisplayName', 'ColumnDisplayTitle')" <xss:encodeForHTMLAttribute><%=selectedColumnDisplayTitle%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Title</emxUtil:i18n><br>
			</TD>
			</TR>
        </TABLE>
        </br></br></br>
            	
		<TABLE>
	        <TR>
			<TD width="150" class='sceheader'>
	           <emxUtil:i18n localize="i18nId">emxRequirements.SCE.Settings.Heading.TreeDisplaySettings</emxUtil:i18n>
	        </TD>
		    </TR>
		</TABLE>
		
			<!-- Specification Folders -->
						
			<%
			String selectedTreeDisplaySpecFoldersName         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersName");		
	        String selectedTreeDisplaySpecFoldersTitle        = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersTitle");		
	        String selectedTreeDisplaySpecFoldersShowRevision = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersShowRevision");		
	        String selectedTreeDisplaySpecFoldersSeparator    = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersSeparator");		
            // HAT1 ZUD Modification to check null value.
	        if((selectedTreeDisplaySpecFoldersName == null || selectedTreeDisplaySpecFoldersName.equalsIgnoreCase("null") || selectedTreeDisplaySpecFoldersName.equalsIgnoreCase("")) 
	        		&& ((selectedTreeDisplaySpecFoldersTitle == null || selectedTreeDisplaySpecFoldersTitle.equalsIgnoreCase("null") || selectedTreeDisplaySpecFoldersTitle.equalsIgnoreCase(""))))
	        {
	        	selectedTreeDisplaySpecFoldersName="";
	        	selectedTreeDisplaySpecFoldersTitle        ="checked";
	        	selectedTreeDisplaySpecFoldersShowRevision ="checked";
	        	selectedTreeDisplaySpecFoldersSeparator    ="";
	        }
	        else 
	       {
	        	if(selectedTreeDisplaySpecFoldersName.equalsIgnoreCase("TreeDisplaySpecFoldersName")) 
		        {
		        	selectedTreeDisplaySpecFoldersName="checked";
		        }
		        if(selectedTreeDisplaySpecFoldersTitle.equalsIgnoreCase("TreeDisplaySpecFoldersTitle")) 
		        {
		        	selectedTreeDisplaySpecFoldersTitle="checked";
		        }	        
		        if(selectedTreeDisplaySpecFoldersShowRevision.equalsIgnoreCase("TreeDisplaySpecFoldersRevision")) 
		        {
		        	selectedTreeDisplaySpecFoldersShowRevision="checked";
		        }
		        if(selectedTreeDisplaySpecFoldersSeparator.equalsIgnoreCase("TreeDisplaySpecFoldersSeperator")) 
		        {
		        	selectedTreeDisplaySpecFoldersSeparator="checked";
		        }
	       }
			
			%>
							
			<!-- Requirements Specification -->
			<%
			
			String selectedTreeDisplayReqSpecName         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecName");		
	        String selectedTreeDisplayReqSpecTitle        = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecTitle");		
	        String selectedTreeDisplayReqSpecShowRevision = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecShowRevision");		
	        String selectedTreeDisplayReqSpecSeperator    = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecSeperator");		
	          
                // HAT1 ZUD Modification to check null value.
	        if((selectedTreeDisplayReqSpecName == null || selectedTreeDisplayReqSpecName.equalsIgnoreCase("null") || selectedTreeDisplayReqSpecName.equalsIgnoreCase("")) 
	        		&& ((selectedTreeDisplayReqSpecTitle == null || selectedTreeDisplayReqSpecTitle.equalsIgnoreCase("null") || selectedTreeDisplayReqSpecTitle.equalsIgnoreCase(""))))
	        {
	        	selectedTreeDisplayReqSpecName="";
	        	selectedTreeDisplayReqSpecTitle        ="checked";
	        	selectedTreeDisplayReqSpecShowRevision ="checked";
	        	selectedTreeDisplayReqSpecSeperator    ="";
	        }
	        else 
	       {
	        	if(selectedTreeDisplayReqSpecName.equalsIgnoreCase("TreeDisplayReqSpecName")) 
		        {
	        		selectedTreeDisplayReqSpecName="checked";
		        }
		        if(selectedTreeDisplayReqSpecTitle.equalsIgnoreCase("TreeDisplayReqSpecTitle")) 
		        {
		        	selectedTreeDisplayReqSpecTitle="checked";
		        }	        
		        if(selectedTreeDisplayReqSpecShowRevision.equalsIgnoreCase("TreeDisplayReqSpecRevision")) 
		        {
		        	selectedTreeDisplayReqSpecShowRevision="checked";
		        }
		        if(selectedTreeDisplayReqSpecSeperator.equalsIgnoreCase("TreeDisplayReqSpecSeperator")) 
		        {
		        	selectedTreeDisplayReqSpecSeperator="checked";
		        }
	       }
	        
			%>
					
			<!-- Chapters -->
			<%
			
			String selectedTreeDisplayChaptersName         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersName");		
	        String selectedTreeDisplayChaptersTitle        = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersTitle");		
	        String selectedTreeDisplayChaptersShowRevision = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersShowRevision");		
	        String selectedTreeDisplayChaptersSeperator    = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersSeperator");		
	        // HAT1 ZUD Modification to check null value.
	        if((selectedTreeDisplayChaptersName == null || selectedTreeDisplayChaptersName.equalsIgnoreCase("null") || selectedTreeDisplayChaptersName.equalsIgnoreCase("")) 
	        		&& ((selectedTreeDisplayChaptersTitle == null || selectedTreeDisplayChaptersTitle.equalsIgnoreCase("null") || selectedTreeDisplayChaptersTitle.equalsIgnoreCase(""))))
	        {
	        	selectedTreeDisplayChaptersName="";
	        	selectedTreeDisplayChaptersTitle        ="checked";
	        	selectedTreeDisplayChaptersShowRevision ="checked";
	        	selectedTreeDisplayChaptersSeperator    ="";
	        }
	        else 
	       {
	        	if(selectedTreeDisplayChaptersName.equalsIgnoreCase("TreeDisplayChaptersName")) 
		        {
	        		selectedTreeDisplayChaptersName="checked";
		        }
		        if(selectedTreeDisplayChaptersTitle.equalsIgnoreCase("TreeDisplayChaptersTitle")) 
		        {
		        	selectedTreeDisplayChaptersTitle="checked";
		        }	        
		        if(selectedTreeDisplayChaptersShowRevision.equalsIgnoreCase("TreeDisplayChaptersRevision")) 
		        {
		        	selectedTreeDisplayChaptersShowRevision="checked";
		        }
		        if(selectedTreeDisplayChaptersSeperator.equalsIgnoreCase("TreeDisplayChaptersSeperator")) 
		        {
		        	selectedTreeDisplayChaptersSeperator="checked";
		        }
	       }
	        	        
			%>

			<!-- Requirements -->
			<%
			
			String selectedTreeDisplayRequirementsName         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsName");		
	        String selectedTreeDisplayRequirementsTitle        = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsTitle");		
	        String selectedTreeDisplayRequirementsShowRevision = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsShowRevision");		
	        String selectedTreeDisplayRequirementsSeperator    = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsSeperator");		
	        // HAT1 ZUD Modification to check null value.
	        if((selectedTreeDisplayRequirementsName == null  || selectedTreeDisplayRequirementsName.equalsIgnoreCase("null") || selectedTreeDisplayRequirementsName.equalsIgnoreCase("")) 
	        		&& ((selectedTreeDisplayRequirementsTitle == null || selectedTreeDisplayRequirementsTitle.equalsIgnoreCase("null") || selectedTreeDisplayRequirementsTitle.equalsIgnoreCase(""))))
	        {
	        	selectedTreeDisplayRequirementsName         ="";
	        	selectedTreeDisplayRequirementsTitle        ="checked";
	        	selectedTreeDisplayRequirementsShowRevision ="checked";
	        	selectedTreeDisplayRequirementsSeperator    ="";
	        }
	        else 
	       {
	        	if(selectedTreeDisplayRequirementsName.equalsIgnoreCase("TreeDisplayRequirementsName")) 
		        {
	        		selectedTreeDisplayRequirementsName="checked";
		        }
		        if(selectedTreeDisplayRequirementsTitle.equalsIgnoreCase("TreeDisplayRequirementsTitle")) 
		        {
		        	selectedTreeDisplayRequirementsTitle="checked";
		        }	        
		        if(selectedTreeDisplayRequirementsShowRevision.equalsIgnoreCase("TreeDisplayRequirementsRevision")) 
		        {
		        	selectedTreeDisplayRequirementsShowRevision="checked";
		        }
		        if(selectedTreeDisplayRequirementsSeperator.equalsIgnoreCase("TreeDisplayRequirementsSeperator")) 
		        {
		        	selectedTreeDisplayRequirementsSeperator="checked";
		        }
	       }
	        
			%>
				
			<!-- Comments -->
			<%
			
			String selectedTreeDisplayCommentsName          = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsName");		
	        String selectedTreeDisplayCommentsTitle         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsTitle");		
	        String selectedTreeDisplayCommentsShowRevision  = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsShowRevision");		
	        String selectedTreeDisplayCommentsSeperator     = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsSeperator");		
	        // HAT1 ZUD Modification to check null value.
	        if((selectedTreeDisplayCommentsName == null  || selectedTreeDisplayCommentsName.equalsIgnoreCase("null") || selectedTreeDisplayCommentsName.equalsIgnoreCase("")) 
	        		&& ((selectedTreeDisplayCommentsTitle == null || selectedTreeDisplayCommentsTitle.equalsIgnoreCase("null") || selectedTreeDisplayCommentsTitle.equalsIgnoreCase(""))))
	        {
	        	selectedTreeDisplayCommentsName         ="";
	        	selectedTreeDisplayCommentsTitle        ="checked";
	        	selectedTreeDisplayCommentsShowRevision ="checked";
	        	selectedTreeDisplayCommentsSeperator    ="";
	        }
	        else 
	       {
	        	if(selectedTreeDisplayCommentsName.equalsIgnoreCase("TreeDisplayCommentsName")) 
		        {
	        		selectedTreeDisplayCommentsName="checked";
		        }
		        if(selectedTreeDisplayCommentsTitle.equalsIgnoreCase("TreeDisplayCommentsTitle")) 
		        {
		        	selectedTreeDisplayCommentsTitle="checked";
		        }	        
		        if(selectedTreeDisplayCommentsShowRevision.equalsIgnoreCase("TreeDisplayCommentsRevision")) 
		        {
		        	selectedTreeDisplayCommentsShowRevision="checked";
		        }
		        if(selectedTreeDisplayCommentsSeperator.equalsIgnoreCase("TreeDisplayCommentsSeperator")) 
		        {
		        	selectedTreeDisplayCommentsSeperator="checked";
		        }
	       }
	        
	        
			%>

		<!-- Test Cases -->
			<%
			// ++ KIE1 IR-448762-3DEXPERIENCER2017x: for adding Test Case and Parameters
			String selectedTreeDisplayTestCasesName          = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesName");		
	        String selectedTreeDisplayTestCasesTitle         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesTitle");		
	        String selectedTreeDisplayTestCasesShowRevision  = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesShowRevision");		
	        String selectedTreeDisplayTestCasesSeperator     = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesSeperator");		
	        // HAT1 ZUD Modification to check null value.
	        if((selectedTreeDisplayTestCasesName == null  || selectedTreeDisplayTestCasesName.equalsIgnoreCase("null") || selectedTreeDisplayTestCasesName.equalsIgnoreCase("")) 
	        		&& ((selectedTreeDisplayTestCasesTitle == null || selectedTreeDisplayTestCasesTitle.equalsIgnoreCase("null") || selectedTreeDisplayTestCasesTitle.equalsIgnoreCase(""))))
	        {
	        	selectedTreeDisplayTestCasesName         ="";
	        	selectedTreeDisplayTestCasesTitle        ="checked";
	        	selectedTreeDisplayTestCasesShowRevision ="checked";
	        	selectedTreeDisplayTestCasesSeperator    ="";
	        }
	        else 
	       {
	        	if(selectedTreeDisplayTestCasesName.equalsIgnoreCase("TreeDisplayTestCasesName")) 
		        {
	        		selectedTreeDisplayTestCasesName="checked";
		        }
		        if(selectedTreeDisplayTestCasesTitle.equalsIgnoreCase("TreeDisplayTestCasesTitle")) 
		        {
		        	selectedTreeDisplayTestCasesTitle="checked";
		        }	        
		        if(selectedTreeDisplayTestCasesShowRevision.equalsIgnoreCase("TreeDisplayTestCasesRevision")) 
		        {
		        	selectedTreeDisplayTestCasesShowRevision="checked";
		        }
		        if(selectedTreeDisplayTestCasesSeperator.equalsIgnoreCase("TreeDisplayTestCasesSeperator")) 
		        {
		        	selectedTreeDisplayTestCasesSeperator="checked";
		        }
	       }
	        
	        
			%>
			
	<!-- Parameters -->
			<%
			
			String selectedTreeDisplayParametersName          = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersName");		
	        String selectedTreeDisplayParametersTitle         = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersTitle");		
	        String selectedTreeDisplayParametersShowRevision  = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersShowRevision");		
	        String selectedTreeDisplayParametersSeperator     = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersSeperator");		
	        // HAT1 ZUD Modification to check null value.
	        if((selectedTreeDisplayParametersName == null  || selectedTreeDisplayParametersName.equalsIgnoreCase("null") || selectedTreeDisplayParametersName.equalsIgnoreCase("")) 
	        		&& ((selectedTreeDisplayParametersTitle == null || selectedTreeDisplayParametersTitle.equalsIgnoreCase("null") || selectedTreeDisplayParametersTitle.equalsIgnoreCase(""))))
	        {
	        	selectedTreeDisplayParametersName         ="";
	        	selectedTreeDisplayParametersTitle        ="checked";
	        	selectedTreeDisplayParametersShowRevision ="checked";
	        	selectedTreeDisplayParametersSeperator    ="";
	        }
	        else 
	       {
	        	if(selectedTreeDisplayParametersName.equalsIgnoreCase("TreeDisplayParametersName")) 
		        {
	        		selectedTreeDisplayParametersName="checked";
		        }
		        if(selectedTreeDisplayParametersTitle.equalsIgnoreCase("TreeDisplayParametersTitle")) 
		        {
		        	selectedTreeDisplayParametersTitle="checked";
		        }	        
		        if(selectedTreeDisplayParametersShowRevision.equalsIgnoreCase("TreeDisplayParametersRevision")) 
		        {
		        	selectedTreeDisplayParametersShowRevision="checked";
		        }
		        if(selectedTreeDisplayParametersSeperator.equalsIgnoreCase("TreeDisplayParametersSeperator")) 
		        {
		        	selectedTreeDisplayParametersSeperator="checked";
		        }
	       }
	        // -- KIE1 IR-448762-3DEXPERIENCER2017x: for adding Test Case and Parameters
	        
			%>
			<!-- Start HAT1 ZUD HL: TSK3433119 -->
			<TABLE class="TreeDisplay" style="width: 70%">
				  <tr>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.TypesFields</emxUtil:i18n>
				    </th>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Name</emxUtil:i18n>
				    </th>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Title</emxUtil:i18n>
				    </th>
				    
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Revision</emxUtil:i18n>
				    </th>
				    <th>
				    	<emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.FieldSeparator</emxUtil:i18n>
				    </th>
				  </tr>
				  
			<!-- Specification Folders -->
				  <tr>
				  
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.SpecificationFolders</emxUtil:i18n><br>
					</TD>
					
					<TD  align=center >
					     <input type="checkbox" id="TreeDisplaySpecFoldersName" name="TreeDisplaySpecFoldersName" value="TreeDisplaySpecFoldersName" onmouseup="validateSettings('name', 'TreeDisplaySpecFoldersName', 'TreeDisplaySpecFoldersTitle')"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplaySpecFoldersName%></xss:encodeForHTMLAttribute> />
					</TD>

					<TD align=center>
					     <input type="checkbox" id="TreeDisplaySpecFoldersTitle" name="TreeDisplaySpecFoldersTitle" value="TreeDisplaySpecFoldersTitle" onmouseup="validateSettings('title', 'TreeDisplaySpecFoldersName', 'TreeDisplaySpecFoldersTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplaySpecFoldersTitle%></xss:encodeForHTMLAttribute> />
					</TD>

					<TD  align=center>
					     <input type="checkbox" id="TreeDisplaySpecFoldersRevision" name="TreeDisplaySpecFoldersRevision" value="TreeDisplaySpecFoldersRevision" <xss:encodeForHTMLAttribute><%=selectedTreeDisplaySpecFoldersShowRevision%></xss:encodeForHTMLAttribute> />
					</TD>

					<TD align=center>
					     <input type="checkbox" id="TreeDisplaySpecFoldersSeperator" name="TreeDisplaySpecFoldersSeperator" value="TreeDisplaySpecFoldersSeperator" <xss:encodeForHTMLAttribute><%=selectedTreeDisplaySpecFoldersSeparator%></xss:encodeForHTMLAttribute> />
					</TD>
				  </tr>
				  
			<!-- Requirement Specification -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.RequirementSpecifications</emxUtil:i18n><br>
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayReqSpecName" name="TreeDisplayReqSpecName" value="TreeDisplayReqSpecName"  onmouseup="validateSettings('name', 'TreeDisplayReqSpecName', 'TreeDisplayReqSpecTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayReqSpecName%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayReqSpecTitle" name="TreeDisplayReqSpecTitle" value="TreeDisplayReqSpecTitle"  onmouseup="validateSettings('title', 'TreeDisplayReqSpecName', 'TreeDisplayReqSpecTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayReqSpecTitle%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayReqSpecRevision" name="TreeDisplayReqSpecRevision" value="TreeDisplayReqSpecRevision"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayReqSpecShowRevision%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayReqSpecSeperator" name="TreeDisplayReqSpecSeperator" value="TreeDisplayReqSpecSeperator"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayReqSpecSeperator%></xss:encodeForHTMLAttribute> />
					</TD>
				  </tr>
				  
			<!-- Chapters -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Chapters</emxUtil:i18n><br>
					</TD>
				  	<TD align=center>
						<input type="checkbox" id="TreeDisplayChaptersName" name="TreeDisplayChaptersName" value="TreeDisplayChaptersName" onmouseup="validateSettings('name', 'TreeDisplayChaptersName', 'TreeDisplayChaptersTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayChaptersName%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayChaptersTitle" name="TreeDisplayChaptersTitle" value="TreeDisplayChaptersTitle" onmouseup="validateSettings('title', 'TreeDisplayChaptersName', 'TreeDisplayChaptersTitle')"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayChaptersTitle%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayChaptersRevision" name="TreeDisplayChaptersRevision" value="TreeDisplayChaptersRevision"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayChaptersShowRevision%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayChaptersSeperator" name="TreeDisplayChaptersSeperator" value="TreeDisplayChaptersSeperator"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayChaptersSeperator%></xss:encodeForHTMLAttribute> />
					</TD>
				  </tr>
				  
			<!-- Requirements -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Requirements</emxUtil:i18n><br>
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayRequirementsName" name="TreeDisplayRequirementsName" value="TreeDisplayRequirementsName" onmouseup="validateSettings('name', 'TreeDisplayRequirementsName', 'TreeDisplayRequirementsTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayRequirementsName%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayRequirementsTitle" name="TreeDisplayRequirementsTitle" value="TreeDisplayRequirementsTitle"  onmouseup="validateSettings('title', 'TreeDisplayRequirementsName', 'TreeDisplayRequirementsTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayRequirementsTitle%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayRequirementsRevision" name="TreeDisplayRequirementsRevision" value="TreeDisplayRequirementsRevision"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayRequirementsShowRevision%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayRequirementsSeperator" name="TreeDisplayRequirementsSeperator" value="TreeDisplayRequirementsSeperator"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayRequirementsSeperator%></xss:encodeForHTMLAttribute> />
					</TD>
				  </tr>
				  
			<!-- Comments -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Comments</emxUtil:i18n><br>
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayCommentsName" name="TreeDisplayCommentsName" value="TreeDisplayCommentsName" onmouseup="validateSettings('name', 'TreeDisplayCommentsName', 'TreeDisplayCommentsTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayCommentsName%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayCommentsTitle" name="TreeDisplayCommentsTitle" value="TreeDisplayCommentsTitle" onmouseup="validateSettings('title', 'TreeDisplayCommentsName', 'TreeDisplayCommentsTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayCommentsTitle%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayCommentsRevision" name="TreeDisplayCommentsRevision" value="TreeDisplayCommentsRevision"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayCommentsShowRevision%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayCommentsSeperator" name="TreeDisplayCommentsSeperator" value="TreeDisplayCommentsSeperator"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayCommentsSeperator%></xss:encodeForHTMLAttribute> />
					</TD>
				  </tr>
				  
			<!-- Test Cases -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.TestCases</emxUtil:i18n><br>
					</TD>
				  	<TD align=center>
						<input type="checkbox" id="TreeDisplayTestCasesName" name="TreeDisplayTestCasesName" value="TreeDisplayTestCasesName" onmouseup="validateSettings('name', 'TreeDisplayTestCasesName', 'TreeDisplayTestCasesTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayTestCasesName%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayTestCasesTitle" name="TreeDisplayTestCasesTitle" value="TreeDisplayTestCasesTitle" onmouseup="validateSettings('title', 'TreeDisplayTestCasesName', 'TreeDisplayTestCasesTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayTestCasesTitle%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayTestCasesRevision" name="TreeDisplayTestCasesRevision" value="TreeDisplayTestCasesRevision"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayTestCasesShowRevision%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayTestCasesSeperator" name="TreeDisplayTestCasesSeperator" value="TreeDisplayTestCasesSeperator"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayTestCasesSeperator%></xss:encodeForHTMLAttribute> />
					</TD>
				</tr>
			<!-- Parameter -->
				  <tr>
				  	<TD style="font-size: 85%;  font-color: black; padding-left:20px; padding-top:10px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Parameter</emxUtil:i18n><br>
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayParametersName" name="TreeDisplayParametersName" value="TreeDisplayParametersName" onmouseup="validateSettings('name', 'TreeDisplayParametersName', 'TreeDisplayParametersTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayParametersName%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayParametersTitle" name="TreeDisplayParametersTitle" value="TreeDisplayParametersTitle" onmouseup="validateSettings('title', 'TreeDisplayParametersName', 'TreeDisplayParametersTitle')" <xss:encodeForHTMLAttribute><%=selectedTreeDisplayParametersTitle%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayParametersRevision" name="TreeDisplayParametersRevision" value="TreeDisplayParametersRevision"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayParametersShowRevision%></xss:encodeForHTMLAttribute> />
					</TD>
					<TD align=center>
						<input type="checkbox" id="TreeDisplayParametersSeperator" name="TreeDisplayParametersSeperator" value="TreeDisplayParametersSeperator"  <xss:encodeForHTMLAttribute><%=selectedTreeDisplayParametersSeperator%></xss:encodeForHTMLAttribute> />
					</TD>
				  </tr>

			</TABLE>
			</br></br>
			<p>
				<b><emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Help</emxUtil:i18n></b><br>
			- <b><emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.Revision</emxUtil:i18n></b>: <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.HelpShowRevision</emxUtil:i18n><br></br>
			- <b><emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.FieldSeparator</emxUtil:i18n></b>: <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.HelpChooseSeparator</emxUtil:i18n></br>
			- *  <emxUtil:i18n localize="i18nId">emxRequirements.TreeDisplaySettings.HelpMaxWidth</emxUtil:i18n>  50   
			</p>
			<!-- End HAT1 ZUD HL: TSK3433119 -->
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>

