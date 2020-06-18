<%--  emxValidateMappingCustomizationObjectReport.jsp -
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefLanguage.jsp.rca 1.5.1.1 Mon Aug  6 15:29:10 2007 przemek Experimental $
--%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>

<HTML>
    <%@include file = "emxNavigatorInclude.inc"%>
    <%@include file = "emxNavigatorTopErrorInclude.inc"%>
	<%@ page import="com.dassault_systemes.vplmintegration.sdk.VPLMIntegException"%>
	<%@ page import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
	  <emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
    <HEAD>
	<TITLE>Synchronize Custom Mapping Validation Report</TITLE>
	  <style type="text/css">
		td.tableHeader {
    background-color: #336699; 
	color: white; 
	text-align: left; 
	font-weight: bold;}
  </style>
        <META http-equiv="imagetoolbar" content="no">
    <META http-equiv="pragma" content="no-cache">
        <SCRIPT language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript">
        </SCRIPT>
        <SCRIPT language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript">
        </SCRIPT>
        <SCRIPT language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript">
        </SCRIPT>
        <SCRIPT type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIForm");
        </SCRIPT>
    </HEAD>
    <BODY>
        <FORM>
		<TABLE border="0" cellpadding="5" cellspacing="2" width="100%">
                <TR>
                    <TD width="200" class="tableHeader"><emxUtil:i18n localize="i18nId">emxVPLMSynchro.CustomSync.MappingAttribute</emxUtil:i18n>
                    </TD>
					<TD  class="tableHeader"><emxUtil:i18n localize="i18nId"> emxVPLMSynchro.CustomSync.Errors</emxUtil:i18n>
                    </TD>
                </TR>
		</TABLE>
            <TABLE border="0" cellpadding="5" cellspacing="2" width="100%">
                <%
//get the details of validation in the java method
try
{
		Map validationErrorData = null;
		VPLMBusObject busObj = new VPLMBusObject(context,request.getParameter("ObjId"));
			
			//CRK 9/10/09: Correct error due to Integer present in the result data
			Integer numWarn = (Integer) validationErrorData.get("Validator Warning Count");
			Integer numError = (Integer) validationErrorData.get("Validator Error Count");
			validationErrorData.remove("Validator Warning Count");
			validationErrorData.remove("Validator Error Count");
			
	int j=0;
	if(validationErrorData!=null && validationErrorData.size()>0)
		{
			String errorAtt[]= new String[validationErrorData.size()];
			for (final Object key : validationErrorData.keySet()) {
				errorAtt[j]= (String)key;
				j++;
			}
			List vErrorData = new ArrayList(); 
	
			for(int i=0;i<errorAtt.length;i++)
			{
			if(errorAtt[i]!= "" && errorAtt[i]!= null )
				{
				//get the error data inside the vector obj from the hashtable
				vErrorData = (List)validationErrorData.get(errorAtt[i]);
				//creating the number of rows for the mapping attribute
				int noOfRows = vErrorData.size()+1;
				   %>
				   <TR>
				   <TD width="200" rowspan="<%=noOfRows%>" class="inputField"><B><%= errorAtt[i] %> </B></TD>
				   </TR>
					<%
					   if(vErrorData!=null && vErrorData.size()!=0)
						{
							for(int k=0;k<vErrorData.size();k++)
							{
								%>
								<TR>
								<TD class="inputField">
								<%
								String errorData = (String)vErrorData.get(k);
								//Get the error data elements from the vector
								String maps[] = errorData.split("\n");
								//put the vector elements inside a string array 
								if(maps!=null || maps.length>0)
								{
									//display the mapping attribute, as it is the first value of the array
									%>
									<B> <%=maps[0]%> </B></BR>
									<%
									for(int l=0;l<maps.length;l++)
									{
									//display the errors for the particular mapping attribute
								%>
									<% if(maps.length>l+1)
										{
									%>
									<%= l+1 %>)<%=maps[l+1] %> </BR>
									<%
										}
									}
								}
								%>
							  </TD>
							  </TR>
						   <%
							}
						}
					
				}                    
			}
		}
	else if(validationErrorData.size()==0){
		//diplay "No Errors "Message  when there are no errors in the validation
		%>
		
				<TR>
				<TD width="100%" class="inputField">
				<emxUtil:i18n localize="i18nId">emxVPLMSynchro.CustomSync.NoError</emxUtil:i18n> </TD>
				</TR>	
		<%
		}
}catch (Exception ex)
		{
			ex.printStackTrace();
		} 
		finally
		{
		}
	%>
            </TABLE>
        </FORM>
    </BODY>
    <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</HTML>

