<%-- emxValidateMappingCustomizationObject.jsp
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefLanguage.jsp.rca 1.5.1.1 Mon Aug  6 15:29:10 2007 przemek Experimental $
--%>

<HTML>
    <%@include file = "emxNavigatorInclude.inc"%>
    <%@include file = "emxNavigatorTopErrorInclude.inc"%>

    <%@ page import = "com.matrixone.jsystem.util.StringUtils,matrix.db.MQLCommand" %>
    <emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
	
    <HEAD>
	<TITLE>Synchronize Custom Mapping Validation </TITLE>
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
		<script type="text/javascript">
			function openErrorPage()
			{
	
				var dropdownValue = document.getElementById('vplmSynchParamid').value;
				if(dropdownValue!="" && dropdownValue!=null)
				{
				var url="../common/emxValidateMappingCustomizationObjectReportFS.jsp?ObjId="+dropdownValue;
				
				myWindow= window.open(url,'errorPage','width=600,height=600,resizable=yes,scrollbars=yes,status=yes');
				myWindow.focus();
				}
				else 
				{
				   alert("<emxUtil:i18nScript localize="i18nId">emxVPLMSynchro.CustomSync.NoObjToValidate</emxUtil:i18nScript>");
				   
				}
			}
		</script>
    </HEAD>
    <BODY>
        <FORM method="post" onSubmit="openErrorPage()">
            <TABLE border="0" cellpadding="5" cellspacing="2" width="100%">
                <TR>
                    <TD width="200" class="label">
                        <emxUtil:i18n localize="i18nId">emxVPLMSynchro.CustomSync.SyncMappingObject</emxUtil:i18n>
                    </TD>
                    <TD class="inputField">
                        <SELECT name="vplmSynchParam" id="vplmSynchParamid">
                            <%
try
{
	String busType = "VPLMInteg-SynchParameters";

	String StrMQLresult="";
	int tokenCount= 0;
	StringTokenizer tempStringTokenizer = null;
	String[] tokArray= null;
	MQLCommand mqlCmd = new MQLCommand();
	//get all the Sync mapping objects using the MQL Query
	if(mqlCmd.executeCommand(context,"temp query bus $1 $2 $3 select $4 dump $5 recordsep $6",
					       busType,"*","*","id","%","@"))
		{
			StrMQLresult = mqlCmd.getResult();
		}
	if(StrMQLresult!="" && StrMQLresult!=null)
		{
	tempStringTokenizer = new StringTokenizer(StrMQLresult,"@");
	tokenCount = tempStringTokenizer.countTokens();
		}
	if(tokenCount!= 0)
		{
			tokArray = new String[tokenCount];
			//put all the tokens in the string array.
			for (int i = 0; i < tokenCount; i++) 
			{
				tokArray[i] = tempStringTokenizer.nextToken();
			}
		
				// for each Object Options
				 for (int i = 0; i < tokArray.length; i++)
				   {
					// get the choices from the string array
					String choice = (String)tokArray[i];
					String type="";
					String name="";
					String rev="";
					String id="";
					//again tokenize the choices with "%"
					StringTokenizer tempRealStringTokenizer = new StringTokenizer(choice,"%");
					//Store the type,name, revision and id of each object
					//display the object name in the drop down menu
					while (tempRealStringTokenizer.hasMoreTokens()) 
						{
							type= tempRealStringTokenizer.nextToken();
							name= tempRealStringTokenizer.nextToken();
							rev= tempRealStringTokenizer.nextToken();
							id=tempRealStringTokenizer.nextToken();
						}
			   %>
			   <!-- SM7 July 11, 2012 -  // SM7 -July 11, 2012 - Multi Synch Param object Support HL - Displaying the revisons of the Synch param objs, which are different solutions -->
				 <OPTION value="<%=id%>" id="<%=id%>"><%=rev%></OPTION>
			   <%
				   }  
			   }
		   }catch (Exception ex)
                                {
									ex.printStackTrace();                  
								} 
                                finally
                                {
                                }
                            %>
                        </SELECT>
                    </TD>
                </TR>
				<TR>
					<TD class="label">
					</TD>
					<TD align="left" class="inputField">
						<input type="submit" value="Validate" >
					</TD>
				</TR>
            </TABLE>
        </FORM>
    </BODY>
    <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</HTML>

