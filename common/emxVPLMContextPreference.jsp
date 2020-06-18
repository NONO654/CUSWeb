<%--  emxPrefLanguage.jsp -
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefLanguage.jsp.rca 1.5.1.1 Mon Aug  6 15:29:10 2007 przemek Experimental $
--%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page import="java.util.List"%>

<HTML>
    <%@include file = "emxNavigatorInclude.inc"%>
    <%@include file = "emxNavigatorTopErrorInclude.inc"%>
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
        <FORM method="post" action="emxVPLMContextPreferenceProcessing.jsp">
            <TABLE border="0" cellpadding="5" cellspacing="2" width="100%">
                <TR>
                    <TD width="150" class="label">
                        <emxUtil:i18n localize="i18nId">emxVPLMSynchro.Preferences.VPLMContext</emxUtil:i18n>
                    </TD>
                    <TD class="inputField">
                        <SELECT name="vplmContext" id="vplmContext">
                            <%
                                try
                                {
                                    // Get User Roles
                                    List userRoles = PersonUtil.getUserRoles(context);
                                    
                                    final String token_pre = "ctx::";

                                    String userRole = PropertyUtil.getAdminProperty(context, "person", context.getUser(), VPLMIntegrationConstants.PREFERENCE_VPLMINTEG_VPLMCONTEXT);

                                    // for each userRole choice
                                    for (int i = 0; i < userRoles.size(); i++)
                                    {
                                        // get choice
                                        String choice = (String)userRoles.get(i);

                                        //keep only those values which have a "ctx::VPLM"
                                        if (!choice.contains(token_pre))
                                            continue;
                                        choice = choice.substring(token_pre.length());

                                        // if choice is equal to default then
                                        // mark it selected
                                        if (choice.equals(userRole))
                                        {
                            %>
                                            <OPTION value="<%=choice%>" selected>
                                            <%=choice%>
                                            </OPTION>
                            <%
                                        }
                                        else
                                        {
                            %>
                                            <OPTION value="<%=choice%>">
                                            <%=choice%>
                                            </OPTION>
                            <%
                                        }
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
                        </SELECT>
                    </TD>
                </TR>
            </TABLE>
        </FORM>
    </BODY>
    <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</HTML>

