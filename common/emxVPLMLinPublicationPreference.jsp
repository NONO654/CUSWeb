<HTML>
    <%@include file = "emxNavigatorInclude.inc"%>
    <%@include file = "emxNavigatorTopErrorInclude.inc"%>
    <%@ page import = "com.matrixone.vplmintegrationitf.util.*" %>
    <emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
    <HEAD>
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
        <FORM method="post" action="emxVPLMLinPublicationPreferenceProcessing.jsp">
        	<TABLE border="0" cellpadding="5" cellspacing="2" width="100%">
               <TR>
                    <TD width="150" class="label">
                        <emxUtil:i18n localize="i18nId">emxVPLMSynchro.Preferences.VPLMLinPublication</emxUtil:i18n>
                    </TD>
                    <TD class="inputField">
                    	<%
                                try
                                {
                                    String LinPubType = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), VPLMIntegrationConstants.PREFERENCE_VPLMINTEG_LINPUBLICATION);
                                    
                                    // if LinPubtype is equal to true then
                                    // check the CheckBox
                                    if (LinPubType.equals("true"))
                                    {
                            %>
                                        <input type="CheckBox" name="chkLinPubType" id="chkLinPubType" checked></font><br>
                            <%
                                    }
                                    else
                                    {
                            %>
                                        <input type="CheckBox" name="chkLinPubType" id="chkLinPubType" ></font><br>
                            <%
                                    }
                                }
                                catch (Exception ex)
                                {
                                    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
                                    {
                                        emxNavErrorObject.addMessage("emxPrefConversions:" + ex.toString().trim());
                                    }
                                } 
                                finally
                                {
                                }
                            %>
                     </TD>
                 </TR>
            </TABLE>
		</FORM>
    </BODY>
    <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</HTML>
