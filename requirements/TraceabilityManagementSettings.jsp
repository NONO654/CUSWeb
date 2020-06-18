<%--
  TraceabilityManagementSettings.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%-- @quickreview HAT1 ZUD 14:12:10  : HL Requirement Specification Dependency 
     @quickreview HAT1 ZUD 15:04:24  : IR-364538-3DEXPERIENCER2016x- FUN048478:By default no option selected in Traceability Management section in Preferences tab. Modification to check null value.
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

   //Called on mouseup form radiobutton and checkbox.
   function TraceabilityManagement(value)
   {
          switch(value)
          {
          	case "0":
          		//alert("into 0");
	          		document.getElementById("AlwaysPromptTargets").disabled=false;
	          		document.getElementById("AlwaysPromptRelationship").disabled=false;
          			
          			document.getElementById("AlwaysPromptTargets").checked = true;
          			document.getElementById("AlwaysPromptRelationship").checked = false;
          			
          	     break;
          	
          	case "0a":
          		//alert("into 0a");
				 if(document.getElementById("AlwaysPromptTargets").checked == true)
				 {
		          	//alert("into 0a if ");
	          		document.getElementById("AlwaysPromptRelationship").checked = true;
				 }
          	     break;
          	     
          	case "0b":
          		//alert("into 0b");
				 if(document.getElementById("AlwaysPromptRelationship").checked == true)
				 {
			        //alert("into 0b if ");
	          		document.getElementById("AlwaysPromptTargets").checked = true;
				 }
          		
          	     break;
   
          	case "1":
          		//alert("into 1");
      			document.getElementById("AlwaysPromptTargets").checked = false;
      			document.getElementById("AlwaysPromptRelationship").checked = false;
          		
          		document.getElementById("AlwaysPromptTargets").disabled=true;
          		document.getElementById("AlwaysPromptRelationship").disabled=true;
          	     break;
          	     
          	case "2":
          		//alert("into 2");
    			document.getElementById("AlwaysPromptTargets").checked = false;
    			document.getElementById("AlwaysPromptRelationship").checked = false;
        		
          		document.getElementById("AlwaysPromptTargets").disabled=true;
          		document.getElementById("AlwaysPromptRelationship").disabled=true;
          	     break;
          	     
          }
   }
   
   function disableCheckBoxes()
   {
		document.getElementById("AlwaysPromptTargets").disabled=true;
  		document.getElementById("AlwaysPromptRelationship").disabled=true;
   }
   
   
/*    function validateFrom()
   {
	   alert("into validate");
	   var isDisabledTargets      = document.getElementById("AlwaysPromptTargets").disabled;
	   var isDisabledRelationship = document.getElementById("AlwaysPromptRelationship").disabled;
	   
	   var isCheckedTargets      = document.getElementById("AlwaysPromptTargets").checked;
	   var isCheckedRelationship = document.getElementById("AlwaysPromptRelationship").checked;
	   
	   if((isDisabledTargets == false || isDisabledRelationship == false) && (isCheckedTargets == false && isCheckedRelationship == false))
	   {
	  		alert("Please select atlest one option under 'Always prompt for persistent dependencies creation/deletion when adding/removing Target(s).'"); 
	   }

   } */
   
    </SCRIPT>
  </HEAD>
 <%
		String traceabilitySettingsAlwaysPrompt="";
	    String traceabilitySettingsAlwaysPromptTargets="";
		String traceabilitySettingsAlwaysPromptRelationship="";    
    
		String traceabilitySettingsNeverPrompt="";
		String traceabilitySettingsAlwaysCreateDelete="";
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
	height:40px;
}

	</style>
    <FORM name="TraceabilityMgt" method="post" action="TraceabilityManagementSettingsProcessing.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>    	
		<TABLE>
	        <TR>
			<TD width="200" class='sceheader'>
	           <emxUtil:i18n localize="i18nId">emxRequirements.SCE.Settings.Heading.TraceabilityManagementSettings</emxUtil:i18n>
	        </TD>
		    </TR>
		</TABLE>
			<%
			String selectedTraceabilityMgtSettings = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTraceabilityMgtSettings");		
            // HAT1 ZUD IR-364538-3DEXPERIENCER2016x
	        if(null == selectedTraceabilityMgtSettings || selectedTraceabilityMgtSettings.equalsIgnoreCase("null") || selectedTraceabilityMgtSettings.equalsIgnoreCase(""))
			{
		    	selectedTraceabilityMgtSettings="AlwaysPrompt";
			} 
	        
	        //Checks saved settings.
	        if(selectedTraceabilityMgtSettings.equalsIgnoreCase("AlwaysPrompt"))
	        {
	        	traceabilitySettingsAlwaysPrompt="checked";
	        	traceabilitySettingsNeverPrompt="";
	    		traceabilitySettingsAlwaysCreateDelete="";
	    		
				String selectedAlwaysPromptTargets      = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptTargets");		
				String selectedAlwaysPromptRelationship = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptRelationship");		

				// HAT1 ZUD IR-364538-3DEXPERIENCER2016x
				if((null == selectedAlwaysPromptTargets || selectedAlwaysPromptTargets.equalsIgnoreCase("null") || selectedAlwaysPromptTargets.equalsIgnoreCase("")) &&  (null == selectedAlwaysPromptRelationship || selectedAlwaysPromptRelationship.equalsIgnoreCase("null") || selectedAlwaysPromptRelationship.equalsIgnoreCase("")))
				{
					selectedAlwaysPromptTargets="AlwaysPromptTargets";
				} 
		        
		        if(selectedAlwaysPromptTargets.equalsIgnoreCase("AlwaysPromptTargets") && !selectedAlwaysPromptRelationship.equalsIgnoreCase("AlwaysPromptRelationship"))
		        {
		        	traceabilitySettingsAlwaysPromptTargets="checked";
		    		traceabilitySettingsAlwaysPromptRelationship="";
		        }
		        
		        else if(selectedAlwaysPromptRelationship.equalsIgnoreCase("AlwaysPromptRelationship") && !selectedAlwaysPromptTargets.equalsIgnoreCase("AlwaysPromptTargets"))
		        {
		    		traceabilitySettingsAlwaysPromptRelationship="checked";
		        	traceabilitySettingsAlwaysPromptTargets="";
		        }
		        else if(!selectedAlwaysPromptTargets.equalsIgnoreCase("AlwaysPromptTargets") && !selectedAlwaysPromptRelationship.equalsIgnoreCase("AlwaysPromptRelationship"))
		        {
		        	traceabilitySettingsAlwaysPromptTargets="";
		    		traceabilitySettingsAlwaysPromptRelationship="";
		        }
		        
		        else if(selectedAlwaysPromptRelationship.equalsIgnoreCase("AlwaysPromptRelationship") && selectedAlwaysPromptTargets.equalsIgnoreCase("AlwaysPromptTargets"))
		        {
		    		traceabilitySettingsAlwaysPromptRelationship="checked";
		        	traceabilitySettingsAlwaysPromptTargets="checked";
		        }
		        
	        }
	        else if(selectedTraceabilityMgtSettings.equalsIgnoreCase("NeverPrompt"))
	        {
	        	traceabilitySettingsAlwaysPrompt="";
	    		traceabilitySettingsNeverPrompt="checked";
	    		traceabilitySettingsAlwaysCreateDelete="";
	    		
	        }
	        else if(selectedTraceabilityMgtSettings.equalsIgnoreCase("AlwaysCreateDelete"))
	        {
	        	traceabilitySettingsAlwaysPrompt="";
	    		traceabilitySettingsNeverPrompt="";
	    		traceabilitySettingsAlwaysCreateDelete="checked";
	    		
	        }
	        
			%>
		<TABLE>
			<TABLE style="float: left; width:40%; ">
				<TR height="180">
		 			<TD style="font-size: 130%; padding-left:30px;" >
						 <emxUtil:i18n localize="i18nId">emxRequirements.TraceabilityManagementSettings.ReqSpecDependecy</emxUtil:i18n>
					</TD>
				</TR>	
			</TABLE>
			<TABLE style="display: inline-block; width:60%;">
				<TR>
		 			<TD class="inputField">
						<TR height="60">
					    <TD>
						     <input type="radio" id="TraceabilityManagementSettings" name="TraceabilityManagementSettings" value="AlwaysPrompt" onmouseup="TraceabilityManagement('0')" <xss:encodeForHTMLAttribute><%=traceabilitySettingsAlwaysPrompt%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.TraceabilityManagementSettings.AlwaysPrompt</emxUtil:i18n><br>
							 
						</TD>
					    </TR>
		 					    <TR height="30" >
							    <TD style="padding-left:100px;">
								     <input type="checkbox" id="AlwaysPromptTargets" name="AlwaysPromptTargets" value="AlwaysPromptTargets" onmouseup="TraceabilityManagement('0a')" <xss:encodeForHTMLAttribute><%=traceabilitySettingsAlwaysPromptTargets%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.TraceabilityManagementSettings.AlwaysPromptTargets</emxUtil:i18n><br>
									 
								</TD>
							    </TR>
							    
							   <TR height="30">
							    <TD style="padding-left:100px;">
								     <input type="checkbox" id="AlwaysPromptRelationship" name="AlwaysPromptRelationship" value="AlwaysPromptRelationship"  onmouseup="TraceabilityManagement('0b')" <xss:encodeForHTMLAttribute><%=traceabilitySettingsAlwaysPromptRelationship%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.TraceabilityManagementSettings.AlwaysPromptRelationship</emxUtil:i18n><br>
									 
								</TD>
							    </TR>
							    
						<TR height="60">
					    <TD>
							<input type="radio" id="TraceabilityManagementSettings" name="TraceabilityManagementSettings" value="NeverPrompt" onmouseup="TraceabilityManagement('1')" <xss:encodeForHTMLAttribute><%=traceabilitySettingsNeverPrompt%></xss:encodeForHTMLAttribute>  /><emxUtil:i18n localize="i18nId">emxRequirements.TraceabilityManagementSettings.NeverPrompt</emxUtil:i18n><br>
						</TD>
					    </TR>
					    
						<TR height="60">
			    		<TD>
							<input type="radio" id="TraceabilityManagementSettings" name="TraceabilityManagementSettings" value="AlwaysCreateDelete" onmouseup="TraceabilityManagement('2')" <xss:encodeForHTMLAttribute><%=traceabilitySettingsAlwaysCreateDelete%></xss:encodeForHTMLAttribute>  /><emxUtil:i18n localize="i18nId">emxRequirements.TraceabilityManagementSettings.AlwaysCreateDelete</emxUtil:i18n><br>			
						</TD>
						</TR>
					</TD>
				</TR>	
			</TABLE>
		
		</TABLE>
		
		<%
        if(selectedTraceabilityMgtSettings.equalsIgnoreCase("NeverPrompt"))
        {
    		%>
    		<script type="text/javascript">
    			disableCheckBoxes();
    		</script>
    		<%
        }
        if(selectedTraceabilityMgtSettings.equalsIgnoreCase("AlwaysCreateDelete"))
        {
    		%>
    		<script type="text/javascript">
    		disableCheckBoxes();
    		</script>
    		<%
        }
		%>	
	
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>

