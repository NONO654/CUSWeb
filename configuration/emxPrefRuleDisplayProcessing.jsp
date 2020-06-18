<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%
    // check if change has been submitted or just refresh mode
    // Get language
    String prefRuleDisplay = emxGetParameter(request, "prefRuleDisplay");
		if( (prefRuleDisplay == null) || ("".equals(prefRuleDisplay)) )
        {
            prefRuleDisplay="";
        }
    // if change has been submitted then process the change
        try
        {
            ContextUtil.startTransaction(context, true);
            if(prefRuleDisplay !=null)
                PersonUtil.setRuleDisplayPreference(context,prefRuleDisplay.trim());
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);

            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("emxprefRuleDisplay:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }
%>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

