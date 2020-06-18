<%--  emxMetricsReportConstantsInclude.inc

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   static const char RCSID[] = $Id: emxMetricsConstantsInclude.inc.rca 1.26 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>

<%
    // String Resource file to be used
    String strResFileId = "emxMetricsStringResource";
    String STR_METRICS_EMPTY_NAME              = EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.EmptyNameField");
    String STR_METRICS_SELECT_TYPE             = EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.SelectType");
    String STR_METRICS_SELECT_POLICY           = EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.SelectPolicy");
    String STR_METRICS_FROM_POLICY             =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.FromState");
    String STR_METRICS_SELECTDATE              =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.SelectDate");
    String STR_METRICS_FROMDATE                =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.FromDate");
    String STR_METRICS_PERIODVALUE             =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.PeriodValue");
    String STR_METRICS_POSITIVEVALUE           =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.EnterPositive");
    String STR_SELECT_POLICIESWITHSAMESTATE    =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.SelectPolicyWithSameStates");
    String STR_INVALID_INPUT_MSG               =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.ErrorMsg.InvalidInputMsg");
    String STR_METRICS_DASHBOARD_UNASSIGN_MSG  =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Dashboard.UnassignAlert");
    String STR_METRICS_DASHBOARD_CHANGELAYOUT_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Dashboard.ChangeLayout");
    String STR_METRICS_DASHBOARD_SELECT_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Dashboard.SelectReportMsg");
    String STR_METRICS_NO_POLICY           =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.NoPolicy");
    String STR_METRICS_NO_STATES           =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.NoStates");
    String STR_METRICS_CHANGELAYOUT_MSG    =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Dashboard.ChangeLayout");
    String STR_METRICS_UNASSIGNED_SELECTION_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Dashboard.MakeUnassignedSelection");
    String STR_METRICS_SELECT_GROUPBY =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.GroupBy");
    String STR_METRICS_WRAP_SIZE =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.WrapSize");
    String STR_METRICS_RESULTS =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Results");
    String STR_METRICS_DONE =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Done");
    String STR_METRICS_CANCEL =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Cancel");
    String STR_METRICS_CLOSE =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Close");
    String STR_METRICS_ERROR_NAME_FIELD =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.ErrorMsg.NameField");
    String STR_METRICS_INVALID_INPUT_FIELD =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.ErrorMsg.InvalidInputMsg");
    String STR_METRICS_LABEL_SAVE_AS =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.SaveAs");
    String STR_METRICS_LABEL_NAME =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Name");
    String STR_METRICS_LABEL_TITLE =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Title");
    String STR_METRICS_SAVE_REPORT_TITLE =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.SaveReportsTitle");
    String STR_METRICS_SAVE_REPORT =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.SaveReport");
    
    String STR_METRICS_LIMITREACHED_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Dashboard.LimitReached");
    String STR_METRICS_DELETE_REPORT_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.WarnMsg.DeleteReport");
    String STR_METRICS_SAVE_REPORT_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.ConfirmSave");
    String STR_METRICS_SAVE_AS_DIALOG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.ConfirmSaveAsDialog");
    String STR_METRICS_SAVE_AS_NOT_SHARED_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.ConfirmSaveAsNotShared");
    String STR_METRICS_SAVE_AS_SHARED_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.ConfirmSaveAsShared");
    String STR_METRICS_SHARED_DEF_CHANGE_MSG =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.SharedCanNotModify");
    String STR_METRICS_NEGATIVE_NUMBER =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.NegativeNumber");
    String STR_METRICS_LARGE_NUMBER =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.LargeNumber");
    String STR_METRICS_CHANGED_DISPLAY_FORMAT =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.ChangedDisplayFormat");
    String STR_METRICS_SELECTVAULT =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.SelectVault");
    String STR_METRICS_DEFINITION_CHANGED =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.DefinitionChanged");
    String STR_METRICS_TYPE_WITH_NO_POLICY =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.TypeWithNoPolicy");
    String STR_METRICS_POLICY_WITH_NO_STATE =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.PolicyWithNoState");
    String STR_METRICS_SAVE_COMMAND =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.Save");
    String STR_METRICS_SAVE_AS_COMMAND =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.SaveAs");
    String STR_METRICS_DELETE_COMMAND =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.DeleteReport");
    String STR_METRICS_VIEW_DEFINITION_COMMAND =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.ViewDefinition");
    String STR_METRICS_VIEW_RESULTS_COMMAND =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.ViewResults");
    String STR_METRICS_DISPLAYFORMAT =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.label.DisplayFormat");
    String STR_METRICS_OBJECT_DETAILS_SAVED =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.ObjectsDetailsSaved");
    String STR_REPORT_OWNER = context.getUser();
    String STR_METRICS_INVALIDXML =EnoviaResourceBundle.getProperty(context, strResFileId,context.getLocale(), "emxMetrics.ErrorMsg.InvalidXml");
    if(STR_METRICS_LARGE_NUMBER.indexOf("$")>=0){
        StringBuffer sbNewMessage = new StringBuffer();
        String firstPart = STR_METRICS_LARGE_NUMBER.substring(0,STR_METRICS_LARGE_NUMBER.indexOf("$"));
        String secondPart = STR_METRICS_LARGE_NUMBER.substring(STR_METRICS_LARGE_NUMBER.indexOf(">")+1,STR_METRICS_LARGE_NUMBER.length());
        String macroName = STR_METRICS_LARGE_NUMBER.substring(STR_METRICS_LARGE_NUMBER.indexOf("$"),STR_METRICS_LARGE_NUMBER.indexOf(">"));
        if(macroName.startsWith("$")){
            macroName = "500";
        }
        sbNewMessage.append(firstPart);
        sbNewMessage.append(macroName);
        sbNewMessage.append(secondPart);
        STR_METRICS_LARGE_NUMBER = sbNewMessage.toString();
    }
%>

<script language="javascript">
    var STR_METRICS_EMPTY_NAME           = "<%= STR_METRICS_EMPTY_NAME %> ";                       
    var STR_METRICS_SELECT_TYPE          = "<%= STR_METRICS_SELECT_TYPE %> ";                       
    var STR_METRICS_SELECT_POLICY        = "<%= STR_METRICS_SELECT_POLICY %> ";                       
    var STR_METRICS_FROM_POLICY          = "<%= STR_METRICS_FROM_POLICY %> ";                       
    var STR_METRICS_SELECTDATE           = "<%= STR_METRICS_SELECTDATE %> ";                       
    var STR_METRICS_FROMDATE             = "<%= STR_METRICS_FROMDATE %> ";                       
    var STR_METRICS_PERIODVALUE          = "<%= STR_METRICS_PERIODVALUE %> ";                       
    var STR_METRICS_POSITIVEVALUE        = "<%= STR_METRICS_POSITIVEVALUE %> ";                       
    var STR_SELECT_POLICIESWITHSAMESTATE = "<%= STR_SELECT_POLICIESWITHSAMESTATE %> ";
    var STR_INVALID_INPUT_MSG            = "<%= STR_INVALID_INPUT_MSG %> ";
    var STR_METRICS_DASHBOARD_UNASSIGN_MSG = "<%= STR_METRICS_DASHBOARD_UNASSIGN_MSG %> ";
    var STR_METRICS_DASHBOARD_CHANGELAYOUT_MSG = "<%= STR_METRICS_DASHBOARD_CHANGELAYOUT_MSG %> ";
    var STR_METRICS_DASHBOARD_SELECT_MSG = "<%= STR_METRICS_DASHBOARD_SELECT_MSG %> ";    
    var STR_METRICS_NO_POLICY = "<%= STR_METRICS_NO_POLICY %> ";
    var STR_METRICS_NO_STATES = "<%= STR_METRICS_NO_STATES %> ";
    var STR_METRICS_CHANGELAYOUT_MSG = "<%= STR_METRICS_CHANGELAYOUT_MSG %> ";
    var STR_METRICS_UNASSIGNED_SELECTION_MSG = "<%= STR_METRICS_UNASSIGNED_SELECTION_MSG %> ";
    var STR_METRICS_SELECT_GROUPBY = "<%= STR_METRICS_SELECT_GROUPBY %> ";
    var STR_METRICS_LIMITREACHED_MSG = "<%= STR_METRICS_LIMITREACHED_MSG %> ";
    var STR_METRICS_DELETE_REPORT_MSG = "<%= STR_METRICS_DELETE_REPORT_MSG %>";  
    var STR_METRICS_SAVE_REPORT_MSG = "<%= STR_METRICS_SAVE_REPORT_MSG %>";
    var STR_METRICS_SAVE_AS_DIALOG = "<%= STR_METRICS_SAVE_AS_DIALOG %>";
    var STR_METRICS_SAVE_AS_SHARED_MSG = "<%= STR_METRICS_SAVE_AS_SHARED_MSG %>";
    var STR_METRICS_SHARED_DEF_CHANGE_MSG = "<%= STR_METRICS_SHARED_DEF_CHANGE_MSG %>";    
    var STR_METRICS_SAVE_AS_NOT_SHARED_MSG = "<%= STR_METRICS_SAVE_AS_NOT_SHARED_MSG %>";
    var STR_METRICS_NEGATIVE_NUMBER = "<%= STR_METRICS_NEGATIVE_NUMBER %>";
    //XSSOK
    var STR_METRICS_LARGE_NUMBER = "<%= STR_METRICS_LARGE_NUMBER %>";    
    var STR_METRICS_CHANGED_DISPLAY_FORMAT = "<%= STR_METRICS_CHANGED_DISPLAY_FORMAT %>";
    var STR_METRICS_SELECTVAULT = "<%= STR_METRICS_SELECTVAULT %>";
    var STR_METRICS_DEFINITION_CHANGED = "<%= STR_METRICS_DEFINITION_CHANGED %>";
    var STR_METRICS_TYPE_WITH_NO_POLICY = "<%= STR_METRICS_TYPE_WITH_NO_POLICY %>";
    var STR_METRICS_POLICY_WITH_NO_STATE = "<%= STR_METRICS_POLICY_WITH_NO_STATE%>";
    var STR_METRICS_SAVE_COMMAND = "<%=STR_METRICS_SAVE_COMMAND%>";
    var STR_METRICS_SAVE_AS_COMMAND = "<%=STR_METRICS_SAVE_AS_COMMAND%>";
    var STR_METRICS_DELETE_COMMAND = "<%=STR_METRICS_DELETE_COMMAND%>";
    var STR_METRICS_VIEW_DEFINITION_COMMAND = "<%=STR_METRICS_VIEW_DEFINITION_COMMAND%>";
    var STR_METRICS_VIEW_RESULTS_COMMAND = "<%=STR_METRICS_VIEW_RESULTS_COMMAND%>";
    var STR_METRICS_DISPLAYFORMAT = "<%=STR_METRICS_DISPLAYFORMAT%>";
    var STR_FROM_PORTAL_MODE = false;
    //XSSOK
    var STR_REPORT_OWNER = "<%=STR_REPORT_OWNER%>";
    var STR_METRICS_OBJECT_DETAILS_SAVED = "<%=STR_METRICS_OBJECT_DETAILS_SAVED%>";
    var WINDOW_REF = null;
    var STR_METRICS_INVALIDXML = "<%=STR_METRICS_INVALIDXML%>";
</script>
