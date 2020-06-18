<%--  emxUIConstantsJavascriptInclude.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@page import="javax.json.JsonObject"%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUICore.js"></script>

<%
out.clear();
response.setContentType("text/javascript;");
response.addHeader("Cache-Control", "no-cache");
// String Resource file to be used
String ResFileId = "emxFrameworkStringResource";

//TO BE CHANGED USING THE PREPOERTUES FILE
Locale strLocale = context.getLocale();
String sRelEmployee = PropertyUtil.getSchemaProperty(context, "relationship_Employee");
BusinessObject personObject   = PersonUtil.getPersonObject(context);
String viewMyCompanyURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + FrameworkUtil.getOrganization(context, personObject, sRelEmployee).getObjectId()  +"&mode=insert";

String STR_ICON_TEXT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Switch.Icon_Text");
String STR_ICON_ONLY = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Switch.Icon_Only");
String STR_MOVE_TO_TOP=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TreeComponent.MoveToTop");
String STR_CLOSE=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TreeComponent.Close");
String STR_BACK=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TreeComponent.Back");
String SEARCH_ALL=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalSearch.All");
String SEARCH=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalSearch.Search");
String STR_URL_SUBMITTED = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.Submit.Progress");
String STR_BACK_TOOLTIP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.BackToolbarMenu.label");
String STR_FORWARD_TOOLTIP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.ForwardToolbarMenu.label");
String STR_CATEGORIES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.UICategoryTree.Label");
String STR_STRUCTURE_VIEW = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.UIStructureTree.Label");
String STR_HIDE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.String.Hide");
String STR_SHOW = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.String.Show");
String STR_COPY_PASTE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.GlobalToolbar.CopyPaste");

// Intenationalization of Javascript contants
String STR_NAME = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Basic.Name");
String STR_TYPE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Basic.Type");
String STR_REV = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.IconMail.Common.Rev");
String STR_STATUS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.IconMail.Common.Status");
String STR_LOADING = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxNavigator.UIMenuBar.Loading");
String STR_REASON = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.Reason");
String STR_REPLY = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.IconMail.Common.Reply");
String STR_ERROR_HEADER = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Login.Error");
String STR_SUBSCRIPTION = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.Subscription");
String STR_SUBSCRIBE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.Subscribe");
String STR_ATTACH = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.IconMail.Common.Attachments");
String STR_DELETE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.IconMail.Common.Delete");

String ERR_SELECT_ONLY_ONE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.PleaseSelectOneItemOnly");
String ERR_NONE_SELECTED = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.PleaseSelectitem");
String ERR_REQUIRED_FIELD = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableEdit.ColumnsInRedAreRequired");

String STR_EDIT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableEdit.Edit");
String STR_VIEW = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableEdit.View");
String STR_ENABLE_EDIT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableEdit.Enable_Edit");
String STR_DISABLE_EDIT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableEdit.Disable_Edit");
String STR_WRAP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.DisplayMode.Wrap");
String STR_SB_EDIT_TOOLTIP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.SB.RowEditToolTip");
String STR_SB_MESSAGEBODY = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.SBEditdialog.MessageBody");
String STR_SB_MESSAGEBODY_NOSAVE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.SBEditdialog.MessageBodyNoSave");
String STR_SB_ROW_REMOVETOOLTIP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.SB.RowRemoveToolTip");
String STR_SB_NEW_ROWTOOLTIP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.SB.NewRowToolTip");
String STR_SBEDITDIALOG_MESSAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.SBEditdialog.Message");
String STR_UNWRAP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.DisplayMode.UnWrap");

String STR_CLOSE_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.Action.CloseMessage");
String STR_FILTER_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.Action.FilterMessage");
String STR_VIEW_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.Action.ViewMessage");
String ERR_SELECT_DIRECTION = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.Direction.SelectError");
String STR_CUSTOMIZE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.UITable.Tooltip.Customize");
String STR_SHOW_SYSTEM_COLUMNS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.UITable.Tooltip.SystemColumns");
String STR_SHOW_CUSTOM_COLUMNS= EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.UITable.Tooltip.CustomColumns");
String STR_GRAPH_MODE_ALERT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.DisplayMode.GraphModeAlert");
String STR_GRAPH_MODE_WARNING = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.DisplayMode.GraphModeWarning");
String STR_GRAPH_MODE_ALERT_LIMIT = EnoviaResourceBundle.getProperty(context, "emxFramework.StructureBrowser.GraphModeAlertLimit");
String STR_GRAPH_MODE_WARNING_LIMIT = EnoviaResourceBundle.getProperty(context, "emxFramework.StructureBrowser.GraphModeWarningLimit");
String STR_FILE_UPLOAD_IN_PROGRESS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FileUploadInprogress");

//months to display on the calendar popup
String January = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.January");
String February = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.February");
String March = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.March");
String April = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.April");
String May = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.May");
String June = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.June");
String July = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.July");
String August = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.August");
String September = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.September");
String October = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.October");
String November = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.November");
String December = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.December");

//months (short name) to display on the calendar popup
String Jan = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Jan");
String Feb = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Feb");
String Mar = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Mar");
String Apr = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Apr");
String Jun = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Jun");
String Jul = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Jul");
String Aug = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Aug");
String Sep = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Sep");
String Oct = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Oct");
String Nov = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Nov");
String Dec = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Dec");

String FW_EDIT = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.RMBEdit");
String FW_CREATE = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.RMBCreate");
String FW_DELETE = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.RMBDelete");
String DND_TYPE_VALIDATION = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.DNDTypeValidation");

String DND_DROPPEDSUCCESS = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.DroppedSuccess");
String DND_DROPPEDFAILURE = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.DroppedFailure");
String DND_DROPPEDMOVED = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.DroppedMoved");
String DND_DROPPEDCOPIED = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.DroppedCopied");
String DND_DROPPEDCREATED = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.Created");
String DND_DROPPEDRENAMED = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.Renamed");
String DND_DROPPEDREMOVED = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.Removed");

String DND_AreYouSure = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.Confirm");
String DND_DeleteMessage = EnoviaResourceBundle.getProperty(context,"enoFolderManagementStringResource",strLocale, "enoFolderManagement.FolderWidget.DeleteMessage");

String enoFWBadChars =EnoviaResourceBundle.getProperty(context,"enoFolderManagement",strLocale, "enoFolderManagement.Javascript.BadChars"); 
String enoFWNameBadChars = EnoviaResourceBundle.getProperty(context,"enoFolderManagement",strLocale, "enoFolderManagement.Javascript.NameBadChars");
String enoFWFileNameBadChars = EnoviaResourceBundle.getProperty(context,"enoFolderManagement",strLocale, "enoFolderManagement.Javascript.FileNameBadChars");
String enoFWFileNameBadCharsALERT = EnoviaResourceBundle.getProperty(context,"enoFolderManagement",strLocale, "enoFolderManagement.FolderWidget.BadNameChars");

//regular day names
String Sunday = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Sunday");
String Monday = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Monday");
String Tuesday = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Tuesday");
String Wednesday = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Wednesday");
String Thursday = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Thursday");
String Friday = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Friday");
String Saturday = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Saturday");

//day abbreviation needed for inputting into a textbox from the calendar popup
String Sun = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Sun");
String Mon = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Mon");
String Tue = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Tue");
String Wed = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Wed");
String Thu = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Thu");
String Fri = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Fri");
String Sat = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.Sat");


//day abbreviations shown in calendar popup
String Su = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.SundayAbbr");
String Mo = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.MondayAbbr");
String Tu = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.TuesdayAbbr");
String We = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.WednesdayAbbr");
String Th = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.ThursdayAbbr");
String Fr = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.FridayAbbr");
String Sa = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Calendar.SaturdayAbbr");

// Improved calendar properties
String yearsAfter = EnoviaResourceBundle.getProperty(context, "emxFramework.CalendarDisplay.YearsAfter");
String yearsBefore = EnoviaResourceBundle.getProperty(context, "emxFramework.CalendarDisplay.YearsBefore");
String customYears = EnoviaResourceBundle.getProperty(context, "emxFramework.CalendarDisplay.CustomYears");

// Type Chooser specific constants/properties
String maxTypesDisplay = EnoviaResourceBundle.getProperty(context, "emxFramework.TypeChooser.MaximumDisplayLimit");
String maxTypesMsg = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TypeChooser.MaximumDisplayLimitMessage");

String decimalQtySetting = Character.toString(PersonUtil.getDecimalSymbol(context));
String browserVariables = request.getHeader("Accept-Language");
String browserLanguage = request.getLocale().getLanguage();
String uiAutomation = "false";
try {
	//This key will not be available in emxSystem.properties file by default. It should be added explicitly by the UI tester for Selenium/WatiN tool to get the "aid" attribute on the HTML elements
	uiAutomation = EnoviaResourceBundle.getProperty(context, "emxFramework.UIAutomation.Test");
} catch(Exception msgException) {
	uiAutomation = "false";
}

String fastloadSBinIE = "false";
try {
	fastloadSBinIE = EnoviaResourceBundle.getProperty(context, "emxFramework.fastloadSBinIE");
} catch(Exception msgException){
	fastloadSBinIE = "false";
}

String newTabCheckTimeWin7 = "-1";
try {
	newTabCheckTimeWin7 = EnoviaResourceBundle.getProperty(context, "emxFramework.IE11.Win7.LaunchNewTab.ThresholdMinutes");
} catch(Exception msgException){
	newTabCheckTimeWin7 = "-1";
}

String newTabCheckTimeWin10 = "-1";
try {
	newTabCheckTimeWin10 = EnoviaResourceBundle.getProperty(context, "emxFramework.IE11.Win10.LaunchNewTab.ThresholdMinutes");
} catch(Exception msgException){
	newTabCheckTimeWin10 = "-1";
}

String chromeJSHeapMemoryThreshold = "-1";
try {
	chromeJSHeapMemoryThreshold = EnoviaResourceBundle.getProperty(context, "emxFramework.Chrome.JSHeap.memoryThreshold");
} catch(Exception msgException){
	chromeJSHeapMemoryThreshold = "-1";
}

String chromeShowExceededJSHeapMemoryAlert = "false";
try {
	chromeShowExceededJSHeapMemoryAlert = EnoviaResourceBundle.getProperty(context, "emxFramework.Chrome.JSHeap.showMemoryExceededAlert");
} catch(Exception msgException){
	chromeShowExceededJSHeapMemoryAlert = "-1";
}
String chromeSuccessiveRefreshDelay = "60000";
try {
	chromeSuccessiveRefreshDelay = EnoviaResourceBundle.getProperty(context, "emxFramework.Chrome.refreshProcess.DelayTime");
} catch(Exception msgException){
	chromeSuccessiveRefreshDelay = "60000";
}


String mxApplyToSelected = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ApplyToSelected");
String mxApplyToAll = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ApplyToAll");
String mxCancel = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.Cancel");
String mxDone = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.Done");
String mxSortAlert = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SortAlert");
String mxExpandAllAlert = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.mxExpandAllAlert");

String strObjectsMessage1 = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ObjectsMessage");
String strObjectsMessage1a = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ObjectsMessageAlt");
String strObjectsMessage2 = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandLevel");
String strMoreLevelError = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.MoreLevel.ErrorMsg");
String strAllLevelError = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.AllLevel.ErrorMsg");
String strEnterValue = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.MoreLevel.EnterValue");
String strExpandAborted1 = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandAborted1");
String strExpandAborted2 = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandAborted2");
String strExpandStop = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandStop");
String strExpandWait = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandWait");
String strHeaderMsg1 = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandHeaderMessage1");
String strHeaderMsg2 = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandHeaderMessage2");
String strExpandTooltip = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandToolTip");
String strExpandAll = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandAll");
String strExpandNLevels = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.ExpandNLevels");

String STR_SBEDIT_NO_SELECT_NODES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoSelectNodes");
String STR_SBEDIT_ROOT_NODE_OPERATION = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.RootNodeOperation");
String STR_SBEDIT_NO_EDIT_OPERATION = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoEditOperation");
String STR_SBEDIT_NO_NODES_COPIED = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoNodesCopied");
String STR_SBEDIT_NO_RESEQ_OPERATION = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoReseqOperation");
String STR_SBEDIT_NO_MATCH_EDITREL_URL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoMatchEditRelUrl");
String STR_SBEDIT_NO_EDITREL_URL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoEditRelUrl");
String STR_SBEDIT_ALLOWEDIT_FLAG_FALSE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.AllowEditFlagFalse");
String STR_SBEDIT_NO_MATCH_RESEQREL_URL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoMatchReseqRelUrl");
String STR_SBEDIT_NO_RESEQREL_URL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoReseqUrl");
String STR_SBEDIT_NO_CONNECTJPO_URL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoConnectJpoUrl");
String STR_SBEDIT_NO_POSSIBLE_REL_SCHEMA = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoPossibleRelSchema");
String STR_PENDING_EDITS_MESSAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.AutoFilter.PendingEditsMessage");
String STR_PENDING_EDITS_PAGINATION_MESSAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.Pagination.PendingEditsMessage");
String STR_PENDING_EDITS_PAGINATION_OFF = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableComponent.PaginationOff");
String STR_PENDING_EDITS_PAGINATION_ON = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableComponent.PaginationOn");
String STR_PENDING_EDITS_PAGINATION_NEXT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableComponent.NextPage");
String STR_PENDING_EDITS_PAGINATION_PREVIOUS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableComponent.PreviousPage");
String STR_PENDING_EDITS_PAGINATION_PAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableComponent.Page");
String STR_PENDING_EDITS_PAGINATION_OF = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableComponent.Of");
String STR_PENDING_EDITS_PAGINATION_OBJECTS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TableComponent.Objects");

String STR_SBEDIT_UNDO_SELECT_NODES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.UndoSelectedItem");
String STR_SBEDIT_NO_EDIT_OF_BASIC_NEWROW = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.NoEditOfBasicNewRow");
String STR_SBEDIT_SAVE_THE_CHANGES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEdit.SaveTheChanges");

//Added for ListBoxManual
String STR_LISTBOXMANUAL_NO_MULTIPLE_VALUES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBListBoxManual.MultipleValuesNotAllowed");
String STR_LISTBOXMANUAL_DONE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBListBoxManual.Done");
String STR_LISTBOXMANUAL_CANCEL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBListBoxManual.Cancel");
String STR_LISTBOXMANUAL_CTRLCLICK = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBListBoxManual.CtrlClick");

//Added for SB MarkUp
String STR_SBMARKUP_SELECT_TO_LOADMARKUP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBMarkUp.LoadMarkUp");
String STR_SBMARKUP_NO_OBJ_TO_CUT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBMarkUp.NoObjToCut");
String STR_SBMARKUP_SELECT_TO_GETMARKUP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBMarkUp.GetMarkUp");

//Added for Structure Compare
String STR_SBCOMPARE_NOOBJ_TO_APPLY = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.NotModified");
String STR_SBCOMPARE_ROOT_OBJ_CANT_SYNC = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.RootObjectCantSync");
String STR_SBCOMPARE_NOOBJ_TO_RESET = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.NoReset");
String STR_SYNC_RESET_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.ResetConfirmMessage");
String STR_FIRST_OBJ_SELECT_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.FirstObjectSelectMessage");
String STR_SECOND_OBJ_SELECT_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.SecondObjectSelectMessage");
String STR_COMPARE_CRITERIA_ERROR_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.CompareCriteriaErrorMessage");
String STR_DIALOG_CONFIG_ERROR_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.DialogConfigErrorMessage");
String STR_COMPARE_SELECT_MINOBJECT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBCompare.SelectMinObjects");

String slideInAnimationType = EnoviaResourceBundle.getProperty(context, "emxFramework.SlideIn.AnimationType");
String slideInAnimationSpeed = EnoviaResourceBundle.getProperty(context, "emxFramework.SlideIn.AnimationSpeed");
String windowShadeAnimationType = EnoviaResourceBundle.getProperty(context, "emxFramework.WindowShade.AnimationType");
String windowShadeAnimationSpeed = EnoviaResourceBundle.getProperty(context, "emxFramework.WindowShade.AnimationSpeed");

//Wider slideIn Value
String WIDER_SLIDEIN_VALUE = EnoviaResourceBundle.getProperty(context, "emxFramework.widerslideIn.size");

StringBuffer customList = new StringBuffer();
if(customYears != null && !"".equals(customYears)) {
    StringList customYrList = FrameworkUtil.split(customYears, ",");
    for(int ci =0; ci<customYrList.size(); ci++) {
        if(ci != 0) {
          customList.append(", ");
        }
        customList.append("\"");
        customList.append(customYrList.get(ci));
        customList.append("\"");
    }
}
String STR_PICKAUTONAME=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Create.PickAutoNameSeries");
String STR_NAMECOLUMN=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Create.NameColumn");

String STR_SEARCH_CONTAINEDIN_EMPTY = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalSearch.ErrorMsg.ContainedInFieldEmpty");
//Added for RMB START
String strLoading = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.DynamicMenu.Loading");
//Added for RMB END
//Added for FullSearch
String STR_NAVIGATIONVIEW =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.PlatformFullTextSearch.NavigationView");
String STR_FORMBASEDVIEW =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.PlatformFullTextSearch.FormBasedView");
String STR_DISPLAY_MESSAGE_NAVIGATIONVIEW =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.SelectCriteriaMessage.NavigationView");
String STR_DISPLAY_MESSAGE_FORMBASEDVIEW =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.SelectCriteriaMessage.FormBasedView");
String STR_DISPLAY_MESSAGE_REALTIME_FORMBASEDVIEW =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.SelectCriteriaMessage.RealTime");
String STR_RESULTOBJECTS =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.Results");

String STR_ALERT_NUMERIC =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.PowerSearch.LimitMustBeNumeric");
String STR_ALERT_MAXLIMIT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalSearch.ErrorMsg.QueryLimitMaxAllowed");
String STR_ALERT_NUMBER =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalSearch.ErrorMsg.QueryLimitNumberFormat");


String STR_QUERY_TYPE =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.QueryType");
String STR_REFRESH_WINDOW_SHADE =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.RefreshWindowShade");
String STR_MAX_QUERY_LIMIT =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.MaxQueryLimit");
String STR_LEGACY_MAX_QUERY_LIMIT =EnoviaResourceBundle.getProperty(context, "emxFramework.Search.UpperQueryLimit");
String REFRESH_TAXONOMIES =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.RefreshTaxonomies");
String STR_SUBMIT_GLOBAL_SEARCH = "false";
try {
	//This key will not be available in emxSystem.properties file by default. It should be added explicitly.
	STR_SUBMIT_GLOBAL_SEARCH = EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.SubmitGlobalSearch");
} catch(Exception msgException) {
	//do nothing
}

String STR_MAX_QUERY_ALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.MaxQueryAlert");
String STR_RESULTS_OF =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.Results.of");
String STR_PAGE_SIZE =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.PageSize");
String STR_FASTSORT_THRESHOLD =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.FastSortThreshold");
String STR_SHOW_PAGINATION =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.ShowPagination");

String STR_VALID_NUMBER_ALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.ValidNumberAlert");
String STR_ZEROORLESS_ALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.ZeroOrLessAlert");
String STR_MAX_LIMIT_ALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.MaxLimitAlert");

String STR_OF = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.Of");
String STR_RESULTS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.Results");
String STR_PREV = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.Prev");
String STR_NEXT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.Next");

String STR_FILL_PAGES = EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.FillPages");

String STR_PAGESIZE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.PageSize");
String STR_LOADING_PAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.LoadingPage");
String STR_LOADING_ATTRIBUTES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.LoadingAttribites");
String STR_LOADING_TAXONOMIES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.LoadingTaxonomies");
String STR_LOADING_CHILD_TAXONOMIES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.LoadingChildTaxonomies"); 
String STR_TAXONOMIES = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.Taxonomies");

//Added for RMB END
String STR_CALLBACK_MSG = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.Action.CallBackMessage");
String STR_CALLBACK_ERR =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Consolidate.CallbackError");
String STR_SUGGESTIONS =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.Suggestions");

String STR_WILDCHARALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.WildCharAlert");
String STR_WILDCHARCONFIRM =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.WildCharConfirm");
String STR_WILDCHARCONFIRMSTR =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullSearch.WildCharAlertSearchText");

String STR_NONWILDCHARALERT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.FullSearch.NonWildCharAlert");
String STR_NONWILDCHARCONFIRM = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale,"emxFramework.FullSearch.NonWildCharConfirm");


String STR_REFINEMENT_SEPARATOR =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.RefinementSeparator");
//String NUM_ALLOW_SEARCHTERMS = EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.TextRefinement.SearchTermsAllowed");
String STR_DEC_SYM=Character.toString(PersonUtil.getDecimalSymbol(context));
//String NUM_LENGTH_SEARCHTERMS = EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.TextRefinement.SearchTermsLength");
String FTS_MINIUM_SEARCHCHARS = EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.MinRequiredChars");
String FTS_CHAR_VIOLATION = EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.MinRequiredChars.AllowSearchWithViolation");

// help directory
String STR_HELP_URL =EnoviaResourceBundle.getProperty(context, "emxFramework.Help.URL");
String STR_IS_CLOUD = ((Boolean)UINavigatorUtil.isCloud(context)).toString();

/*String[] messageValues = new String[2];
messageValues[0] = NUM_ALLOW_SEARCHTERMS;
messageValues[1] = NUM_LENGTH_SEARCHTERMS;
String STR_SEARCHTERMS_INVAIDMESSAGE = MessageUtil.getMessage(context,null,
                                 "emxFramework.FullTextSearch.TextRefinement.SearchTermsInvalidMessage",
                                 messageValues,null,
                                 request.getLocale(),ResFileId);*/

String STR_SEARCH_SEARCH = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalSearch.Search");
String STR_SEARCH_CLEAR = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalSearch.SearchClear");
String STR_SEARCH_SAVED = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.TextRefinement.SearchSaved");
String ERR_SELECTION = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEditActions.SelectionError");
String ERR_REMOVE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEditActions.RemoveError");
String STR_TYPEAHEAD_CHARACTERCOUNT =EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead.RunProgram.CharacterCount");
String ERR_REQUIRED = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEditActions.RequiredError");
String STR_TYPEAHEAD_RUNPROGRAM =EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead.RunProgram");
String STR_TYPEAHEAD_SYSTEM =EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead");
String ERR_ROW_SELECTION = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEditActions.RowSelectError");
String ERR_MANDATORY = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.SBEditActions.MandatoryError");


String STR_VALID_DATE_ALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.ValidDateAlert");
String STR_VALID_NUMERIC_ALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.ValidNumericAlert");
String STR_NotEnoughStorageMsg = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Warning.NotEnoughStorageForOperation");
String STR_TODAY =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.String.Today");
String STR_INTEGER_SAVED_WARNING =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FreezePane.IntegerValue");

String STR_JS_Error = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Error");
String STR_JS_FromServer = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.FromServer");
String STR_JS_ErrorOWTTT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ErrorOWTTT");
String STR_JS_AttOrMethod = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.AttOrMethod");
String STR_JS_Type = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Type");
String STR_JS_Name = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Name");
String STR_JS_Rev = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Rev");
String STR_JS_Value = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Value");
String STR_JS_AnErrorOWEDTBSTTS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.AnErrorOWEDTBSTTS");
String STR_JS_AnErrorOWTTLTD = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFrameworkJ.avaScript.AnErrorOWTTLTD");
String STR_JS_Description = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Description");
String STR_JS_NoDataFor = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.NoDataFor");
String STR_JS_NoResults = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.NoResults");
String STR_JS_MaxValue = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.MaxValue");
String STR_JS_AnExceptionOccurred = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.AnExceptionOccurred");
String STR_JS_ErrorName = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ErrorName");
String STR_JS_ErrorDescription = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ErrorDescription");
String STR_JS_ErrorNumber = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ErrorNumber");
String STR_JS_ErrorMessage = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ErrorMessage");
String STR_JS_ObjectManagerCNBL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ObjectManagerCNBL");
String STR_JS_InvalidChannelName = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.InvalidChannelName");
String STR_JS_RefreshFailed = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.RefreshFailed");
String STR_JS_MultiValueColumnNotFiltered = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.MultiValueColumnNotFiltered");
String STR_JS_AnErrorOWCDMR = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.AnErrorOWCDMR");
String STR_JS_Init = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Init");
String STR_JS_FilteredNodes = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.FilteredNodes");
String STR_JS_ShowAllRootNodes = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ShowAllRootNodes");
String STR_JS_ExceptionIs = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ExceptionIs");
String STR_JS_ErrorPrefetch = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.ErrorPrefetch");
String STR_JS_APreciseBOMGenerated = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.APreciseBOMGenerated");

String STR_JS_ConfirmRemoveMessage = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.ConfirmRemoveMessage");
String STR_JS_ConfirmDeleteMessage = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.ConfirmDeleteMessage");
String STR_JS_ConfirmAddTaskComplete = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.ConfirmAddTaskComplete");
String STR_JS_ConfirmDisconnect = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.ConfirmDisconnect");
String STR_JS_ReviseSelected = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.ReviseSelected");
String STR_JS_Revise = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.Revise");
String STR_JS_Version = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.Version");
String STR_JS_ValidateConfiguration = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Confirm.ValidateConfiguration");

String STR_JS_AnErrorOICM = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.AnErrorOICM");
String STR_JS_AssertionFailed = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.AssertionFailed");
String STR_JS_Actual = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.Actual");
String STR_JS_InvalidResult = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.JavaScript.InvalidResult");

String STR_SEARCH_IN_PROGRESS_ALERT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FullTextSearch.SearchInProgressAlert");

String STR_SB_DESCR_WIDTH =EnoviaResourceBundle.getProperty(context, "emxFramework.FreezePane.Column.DescriptionWidth");
String STR_SB_IMAGE_WIDTH =EnoviaResourceBundle.getProperty(context, "emxFramework.FreezePane.Column.ImageWidth");
String STR_SB_MIN_WIDTH =EnoviaResourceBundle.getProperty(context, "emxFramework.FreezePane.Column.MinimumWidth");
String STR_SB_WRAP_STYLE =EnoviaResourceBundle.getProperty(context, "emxFramework.FreezePane.Wrap.Style");
String STR_PORTAL_MIN_HEIGHT = EnoviaResourceBundle.getProperty(context,"emxFramework.Portal.Height.Minimum");

String FOMAT_THUMBNAIL_SIZE= PropertyUtil.getAdminProperty(context, "format", PropertyUtil.getSchemaProperty(context, "format_mxThumbnailImage"), "mxImageSize");
String FOMAT_SMALL_SIZE    = PropertyUtil.getAdminProperty(context, "format", PropertyUtil.getSchemaProperty(context, "format_mxSmallImage"), "mxImageSize");
String FOMAT_MEDIUM_SIZE   = PropertyUtil.getAdminProperty(context, "format", PropertyUtil.getSchemaProperty(context, "format_mxMediumImage"), "mxImageSize");
String FOMAT_LARGE_SIZE    = PropertyUtil.getAdminProperty(context, "format", PropertyUtil.getSchemaProperty(context, "format_mxLargeImage"), "mxImageSize");

String STR_HISTORY_LIMIT = EnoviaResourceBundle.getProperty(context, "emxSystem.pageHistory.limit");

String STR_VIEW_ALL_SEARCH_RESULTS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.TypeAheadFullTextSearch.ViewAllSearchResults");

String STR_BC_LABEL_HOME = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.BreadCrumb.Label.Home");
//Added for Structure Navigator close/open
String NAVIGATOR_CLOSE=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.StructureNavigator.Close");
String NAVIGATOR_OPEN=EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.StructureNavigator.Open");

String strContinue = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Menu.Label.Continued");

// GSB
String GSB_ROTATE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GSB.Rotate");
String GSB_FIT_TO_PAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GSB.FitToPage");
String GSB_IMAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GSB.Image");
String GSB_MINI_MAP = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GSB.MiniMap");
String GSB_FIND = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GSB.Find");
String GSB_FIND_TXT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GSB.FindTxt");

//Auto Filter
String STR_AUTO_FILTER_SELECTIONS =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.Selections");
String STR_AUTO_FILTER_RESET =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.Reset");
String STR_AUTO_FILTER_APPLY =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.Apply");
String STR_AUTO_FILTER_CLOSE =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.Close");
String STR_AUTO_FILTER_MORE =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.More");
String STR_AUTO_FILTER_SELECT_ALL =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.SelectAll");
String STR_AUTO_FILTER_MULTI_SELECT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.MultiSelect");
String STR_AUTO_FILTER_DONE =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.Done");
String STR_AUTO_FILTER_BLANK =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AutoFilter.Blank");
String STR_COMPASS_FACET_WHO =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Compass.Facet.Who");
String STR_COMPASS_FACET_WHAT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Compass.Facet.What");
String STR_COMPASS_FACET_WHERE =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Compass.Facet.Where");
String STR_COMPASS_FACET_WHEN =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Compass.Facet.When");
String STR_COMPASS_FACET_WHY =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Compass.Facet.Why");
String STR_HELP_ICON = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Common.Help");
String STR_HELP_LANGUAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.HelpDirectory");
String STR_HELP_ONLINE_LANGUAGE = EnoviaResourceBundle.getProperty(context,ResFileId,new Locale(STR_HELP_LANGUAGE), "emxFramework.OnlineXML.HelpDirectory");

//Added for Toolbar command's tooltip of Rich Text Editor
String RTE_BOLD = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Bold");
String RTE_ITALIC = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Italic");
String RTE_UNDERLINE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Underline");
String RTE_STRIKETHROUGH = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Strikethrough");
String RTE_SUPERSCRIPT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Superscript");
String RTE_SUBSCRIPT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Subscript");
String RTE_SPECIALCHARACTER = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Specialcharacter");
String RTE_OK = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.OK");
String RTE_CANCEL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.RTE.Tooltip.Cancel");
//spell checker
String SPELL_CHECK = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.spellchecker.Button.Spellcheck");
//Bad chars
String STR_SEARCH_BADCHAR = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.AdminProperty.BadChars");
String STR_BADCHAR = EnoviaResourceBundle.getProperty(context, "emxNavigator.UIMenuBar.FullSearchBadCharList").trim();

String SELECT_ONE_ITEM = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Message.Select.OneItem");
String STR_NO_COLUMNS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Table.NoColumns"); 

//Channel UI
String ChannelUI_SEEALL = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ChannelUI.SeeAll");
String ChannelUI_LATE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ChannelUI.Late");
String ChannelUI_TASKS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ChannelUI.Tasks");
String ChannelUI_FILTERS = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ChannelUI.Filters");
String ChannelUI_APPLY = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ChannelUI.Apply");
String ChannelUI_RESET = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ChannelUI.Reset");

// Shortcuts
String STR_SHORTCUTS =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ShortcutPanel.Shortcuts");
String NO_OBJECT_ERROR = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Shortcut.NoObjectFound");
String SHORTCUT_REMOVE_BUTTON = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Shortcut.Button.Remove");
String SHORTCUT_REMOVEALL_BUTTON = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Shortcut.Button.RemoveAll");
String SHORTCUT_REMOVEALL_MESSAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.Collections.RemoveAllClipboard");

String LEARN_MORE_ABOUT = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.MyDesk.LearnMoreAbout");
String MYDESK_SWYM = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.MyDesk.SWYM");



String SixWTagging_EXALEAD_MESSAGE = EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.GlobalToolbar.Tagging.ExaleadNotification");

String UnSupportedContentMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.Mobile.UnsupportedContent");
//Category tab width
String categoryTabWidth = EnoviaResourceBundle.getProperty(context, "emxFramework.categoryMenu.tab.size");
String selectedFilter = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.String.Selected",request.getLocale());
String hidePanelStr = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.String.HidePanel",request.getLocale());

String RESTRICTED_FILE_FORMATS = EnoviaResourceBundle.getProperty(context, "emxComponents.Commondocument.RestrictedFormats"); 
String SUPPORTED_FILE_FORMATS = EnoviaResourceBundle.getProperty(context, "emxComponents.Commondocument.SupportedFormats");
String RESTRICTED_FORMATS_ALERT = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", strLocale, "emxComponents.CommonDocument.NotSupportedFormat");        
String SUPPORTED_FORMATS_ALERT = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", strLocale, "emxComponents.CommonDocument.SupportedFormat");
String FILENAME_BAD_CHARACTERS = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.FileNameBadChars");
String INVALID_FILENAME_INPUTCHAR = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", strLocale, "emxComponents.ErrorMsg.InvalidInputMsg");
String FILENAME_CHAR_NOTALLOWED = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", strLocale, "emxComponents.Common.AlertInvalidInput");
String FILENAME_INVALIDCHAR_ALERT = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", strLocale, "emxComponents.Common.AlertRemoveInValidChars");
String INVALID_IMAGE_EXTENSION = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxFramework.String.ErrorImageExtension");
String IMAGE_ALLOWED_FORMATS = EnoviaResourceBundle.getProperty(context, "emxComponents.ImageManager.AllowedFormats");
String IMAGE_COMMAND_DNDUPLOAD = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", request.getLocale(), "emxComponents.Command.DnDUpload"); 
String IMAGE_COMMAND_SETASPRIMARY = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", request.getLocale(), "emxComponents.Command.SetAsPrimary"); 
String IMAGE_COMMAND_DELETE = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", request.getLocale(), "emxComponents.Command.Delete"); 
String IMAGE_COMMAND_HELP = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.Common.Tooltip.Help"); 
String IMAGE_NO_IMAGE_ASSOC = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", request.getLocale(), "emxComponents.Image.NoImageAssociated"); 
String UPDATE_FILES_MISSING = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", request.getLocale(), "emxComponents.Applet.UpdateFilesError"); 
String ADVANCED_ROW_GROUPING_ENABLED = EnoviaResourceBundle.getProperty(context, "emxFramework.RowGrouping.AdvancedRowGrouping.enabled");
String UNSUPPORTED_OPERATION = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", request.getLocale(), "emxComponents.Unsupported");
String MESSAGE_TYPE_PRIVATE=  EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", strLocale, "emxComponents.Discussion.PrivateMessage");

String DRAG_COPY = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.DisplayMode.Copy");
String DRAG_MOVE = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.DisplayMode.Move");
boolean topFrameEnabled = UINavigatorUtil.isTopFrameEnabled(context);
String closeSearch = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.3DSearch.CloseSearch");
String searchHelp = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.3DSearch.Help");

String copyrightInfo = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.About.3DEXPERIENCEPlatform");
String applicaionMyDeskMenu = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxNavigator.UIMenu.ApplicationMyDeskMenu");


String SBEditDialog_SAVE = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.SBEditDialog.Save");
String SBEditDialog_DONT_SAVE = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.SBEditDialog.DontSave");
String SBEditDialog_CANCEL = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.SBEditDialog.Cancel");

//DragAndDrop
String DRAG_DROP_INVALIDTYPE = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.DragDrop.InvalidType");
String DRAG_DROP_INVALIDACTION = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.DragDrop.InvalidAction");
String DRAG_DROP_MULTIPLEDROP = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.DragDrop.MultipleDrop");
String DRAG_DROP_INVALIDRELATION = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.DragDrop.InvalidRelation");
//Search window title
String SEARCH_WINDOW_TITLE_SEPERATOR = EnoviaResourceBundle.getProperty(context,  "emxFramework.WindowTitle.NameSeparator");
String SEARCH_TITLE = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.FullTextSearch.Window.Title");


// CSRF
boolean isCSRFEnabled = ENOCsrfGuard.isCSRFEnabled(context);
boolean isPageTokenEnabled = ENOCsrfGuard.isPageTokenEnabled(context);
String CSRF_TOKEN_KEY = ENOCsrfGuard.CSRF_TOKEN_NAME;
String CSRF_TOKEN_NAME="";
String CSRF_TOKEN_VALUE ="";
String STR_AUTOLOGOUT_POLLTIMER =EnoviaResourceBundle.getProperty(context, "emxFramework.SessionTimeout.AutoLogout.PollTimer");
String STR_AUTOLOGOUT_SERVEREXPIRYTIME =EnoviaResourceBundle.getProperty(context, "emxFramework.SessionTimeout.AutoLogout.Cookie.ServerExpiryTime");
String STR_AUTOLOGOUT_SERVERTIME =EnoviaResourceBundle.getProperty(context, "emxFramework.SessionTimeout.AutoLogout.Cookie.ServerTime");
String STR_AUTOLOGOUT_CLIENTTIMEOFFSET =EnoviaResourceBundle.getProperty(context, "emxFramework.SessionTimeout.AutoLogout.Cookie.ClientTimeOffset");

if(isCSRFEnabled){
	JsonObject tokenJson=  ENOCsrfGuard.getCSRFTokenJson_New(context,session);
	CSRF_TOKEN_NAME = tokenJson.getString(CSRF_TOKEN_KEY);
	CSRF_TOKEN_VALUE = tokenJson.getString(CSRF_TOKEN_NAME);	
}
String MMY_RELOAD = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.MMY.Reload");
String CHROME_MMY_RELOAD = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.Chrome.MMY.Reload");

// MSF
String USEMSF =EnoviaResourceBundle.getProperty(context, "emxFramework.UseMSF");

//Inbox Task Comment key for required
String TASK_COMMENT_REQUIRED = EnoviaResourceBundle.getProperty(context, "emxComponents.Routes.EnforceAssigneeApprovalComments");
String TASK_OWNER_COMMENT_REQUIRED = EnoviaResourceBundle.getProperty(context, "emxComponents.Routes.EnforceOwnerReviewComments");
//3dsearch
String ADD_TO_CLIPBOARD_LABEL = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.Collections.AddToClipboardCollection");
String ADD_TO_COLLECTION_LABEL = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.Collections.NewAddToCollections");
String SELECTION_ALERT = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", request.getLocale(), "emxComponents.AddContent.SelectOneObj");

//session expire
String sessionExpirationTitle = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.sessiontimeout.sessionExpirationTitle");
String sessionExpirationMessage = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), "emxFramework.sessiontimeout.sessionExpirationMessage");

String STR_JS_TypeAheadNoResults = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", strLocale, "emxFramework.TypeAheadFullTextSearch.NoResultsFound");

//App HOME Page 
String STR_APPHOMEPAGE =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.ShortcutPanel.AppHomePage");

//For Range Value Attributes
String INVALID_RANGE_FORMAT =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FormValidate.InvalidRangeFormat");
String INVALID_RANGE_VALUE =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FormValidate.InvalidRangeValue");
String MINIMUM_NOT_LESS_THAN_MAXIMUM =EnoviaResourceBundle.getProperty(context,ResFileId,strLocale, "emxFramework.FormValidate.MinimumNotLessThanMaximum");
%>

var emxUIConstants = new Object;

//this block will be deprecated in future versions
var STR_NAME = "<%=STR_NAME%>";
var STR_TYPE = "<%=STR_TYPE%>";
//XSSOK
var STR_STATUS = "<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(STR_STATUS)%>";
var STR_LOADING = "<%=STR_LOADING%>";
//XSSOK
var STR_REASON = "<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(STR_REASON)%>";
var ERR_SELECT_ONLY_ONE = "<%=ERR_SELECT_ONLY_ONE%>";
var ERR_NONE_SELECTED = "<%=ERR_NONE_SELECTED%>";
var ERR_REQUIRED_FIELD = "<%=ERR_REQUIRED_FIELD%>";
var STR_ERROR_HEADER = "<%=STR_ERROR_HEADER%> ";
//badchar
var BAD_CHAR =  "<%= STR_SEARCH_BADCHAR %>";
var STR_BADCHAR = '<%= STR_BADCHAR %>';



var STR_REV = "<%=STR_REV%>";
var STR_REPLY = "<%=STR_REPLY%>";
var STR_SUBSCRIPTION = "<%=STR_SUBSCRIPTION%>";
var STR_SUBSCRIBE = "<%=STR_SUBSCRIBE%>";
var STR_ATTACH    = "<%=STR_ATTACH%>";
var STR_DELETE = "<%=STR_DELETE%>";

//months to display on the calendar popup
var ARR_LONG_MONTH_NAMES = new Array("<%=January%>",
        "<%=February%>",
        "<%=March%>",
        "<%=April%>",
        "<%=May%>",
        "<%=June%>",
        "<%=July%>",
        "<%=August%>",
        "<%=September%>",
        "<%=October%>",
        "<%=November%>",
        "<%=December%>");

//month abbreviations needed for inputting into a textbox from the calendar popup
var ARR_SHORT_MONTH_NAMES = new Array( "<%=Jan%>",
        "<%=Feb%>",
        "<%=Mar%>",
        "<%=Apr%>",
        "<%=May%>",
        "<%=Jun%>",
        "<%=Jul%>",
        "<%=Aug%>",
        "<%=Sep%>",
        "<%=Oct%>",
        "<%=Nov%>",
        "<%=Dec%>");

//regular day names
var ARR_LONG_DAY_NAMES = new Array("<%=Sunday%>",
        "<%=Monday%>",
        "<%=Tuesday%>",
        "<%=Wednesday%>",
        "<%=Thursday%>",
        "<%=Friday%>",
        "<%=Saturday%>");

//day abbreviation needed for inputting into a textbox from the calendar popup
var ARR_DB_DAY_NAMES = new Array("<%=Sun%>",
        "<%=Mon%>",
        "<%=Tue%>",
        "<%=Wed%>",
        "<%=Thu%>",
        "<%=Fri%>",
        "<%=Sat%>");

//day abbreviations shown in calendar popup
var ARR_SHORT_DAY_NAMES = new Array("<%=Su%>",
        "<%=Mo%>",
        "<%=Tu%>",
        "<%=We%>",
        "<%=Th%>",
        "<%=Fr%>",
        "<%=Sa%>");

var STR_MOVE_TO_TOP ="<%=STR_MOVE_TO_TOP%>";
var STR_BACK ="<%=STR_BACK%>";
var SEARCH_ALL ="<%=SEARCH_ALL%>";
var SEARCH ="<%=SEARCH%>";
var STR_CLOSE ="<%=STR_CLOSE%>";
var STR_PICKAUTONAME = "<%=STR_PICKAUTONAME%>";
var STR_SUGGESTIONS = "<%=STR_SUGGESTIONS%>";

emxUIConstants.ADVANCED_ROW_GROUPING_ENABLED = <%=ADVANCED_ROW_GROUPING_ENABLED%>;
emxUIConstants.TOPFRAME_ENABLED = <%=topFrameEnabled %>;
//Folder Widget
emxUIConstants.FWEDIT = "<%=FW_EDIT%>";
emxUIConstants.FWCREATE = "<%=FW_CREATE%>";
emxUIConstants.FWDELETE = "<%=FW_DELETE%>";
emxUIConstants.DND_TYPE_VALIDATION = "<%=DND_TYPE_VALIDATION%>";

emxUIConstants.DND_DROPPEDSUCCESS = "<%=DND_DROPPEDSUCCESS%>";
emxUIConstants.DND_DROPPEDFAILURE = "<%=DND_DROPPEDFAILURE%>";
emxUIConstants.DND_DROPPEDMOVED = "<%=DND_DROPPEDMOVED%>";
emxUIConstants.DND_DROPPEDCOPIED = "<%=DND_DROPPEDCOPIED%>";
emxUIConstants.DND_DROPPEDCREATED = "<%=DND_DROPPEDCREATED%>";
emxUIConstants.DND_DROPPEDRENAMED = "<%=DND_DROPPEDRENAMED%>";
emxUIConstants.DND_DROPPEDREMOVED = "<%=DND_DROPPEDREMOVED%>";
emxUIConstants.DND_DeleteMessage = "<%=DND_DeleteMessage%>";
emxUIConstants.DND_AreYouSure = "<%=DND_AreYouSure%>";


emxUIConstants.FW_BADCHARS = "<%=enoFWBadChars%>";
emxUIConstants.FW_NAMEBADCHARS = "<%=enoFWNameBadChars%>";
emxUIConstants.FW_FILENAMEBADCHARS = "<%=enoFWFileNameBadChars%>";
emxUIConstants.FW_ALERT_FILENAMEBADCHARS = "<%=enoFWFileNameBadCharsALERT%>";

emxUIConstants.STR_URL_SUBMITTED = "<%=STR_URL_SUBMITTED%>";
emxUIConstants.LEARN_MORE_ABOUT = "<%=LEARN_MORE_ABOUT%>";
emxUIConstants.MYDESK_SWYM = "<%=MYDESK_SWYM%>";

emxUIConstants.STR_BACK_TOOLTIP = "<%=STR_BACK_TOOLTIP%>";
emxUIConstants.STR_FORWARD_TOOLTIP = "<%=STR_FORWARD_TOOLTIP%>";
emxUIConstants.STR_CATEGORIES = "<%=STR_CATEGORIES%>";
emxUIConstants.STR_STRUCTURE_VIEW = "<%=STR_STRUCTURE_VIEW%>";
emxUIConstants.STR_HIDE = "<%=STR_HIDE%>";
emxUIConstants.STR_SHOW = "<%=STR_SHOW%>";
emxUIConstants.STR_COPY_PASTE = "<%=STR_COPY_PASTE%>";

//for the future: all constants are properties of emxUIConstants
//these are duplicates now for forward-compatibility
emxUIConstants.STR_NAME = STR_NAME;
emxUIConstants.STR_TYPE = STR_TYPE;
emxUIConstants.STR_STATUS = STR_STATUS;
emxUIConstants.STR_LOADING = STR_LOADING;
emxUIConstants.STR_REASON = STR_REASON;
emxUIConstants.ERR_SELECT_ONLY_ONE = ERR_SELECT_ONLY_ONE;
emxUIConstants.ERR_NONE_SELECTED = ERR_NONE_SELECTED;
emxUIConstants.ERR_REQUIRED_FIELD = ERR_REQUIRED_FIELD;
emxUIConstants.STR_ERROR_HEADER = STR_ERROR_HEADER;


//Added for Structure Navigator close/open
emxUIConstants.STR_NAV_CLOSE="<%=NAVIGATOR_CLOSE %>";
emxUIConstants.STR_NAV_OPEN="<%=NAVIGATOR_OPEN %>";
emxUIConstants.STR_CLOSE="<%=NAVIGATOR_CLOSE %>";
emxUIConstants.STR_OPEN="<%=NAVIGATOR_OPEN %>";


emxUIConstants.STR_REV = STR_REV;
emxUIConstants.STR_REPLY = STR_REPLY;
emxUIConstants.STR_SUBSCRIPTION = STR_SUBSCRIPTION;
emxUIConstants.STR_SUBSCRIBE = STR_SUBSCRIBE;
emxUIConstants.STR_ATTACH = STR_ATTACH;
emxUIConstants.STR_DELETE = STR_DELETE;

emxUIConstants.STR_MOVE_TO_TOP = STR_MOVE_TO_TOP;
emxUIConstants.STR_BACK = STR_BACK;
emxUIConstants.SEARCH_ALL = SEARCH_ALL;
emxUIConstants.SEARCH = SEARCH; 
emxUIConstants.STR_CLOSE = STR_CLOSE;

emxUIConstants.ARR_LONG_MONTH_NAMES = ARR_LONG_MONTH_NAMES;
emxUIConstants.ARR_SHORT_MONTH_NAMES = ARR_SHORT_MONTH_NAMES;
emxUIConstants.ARR_LONG_DAY_NAMES = ARR_LONG_DAY_NAMES;
emxUIConstants.ARR_SHORT_DAY_NAMES = ARR_SHORT_DAY_NAMES;
emxUIConstants.ARR_DB_DAY_NAMES = ARR_DB_DAY_NAMES;

emxUIConstants.CALENDAR_START_DOW = 0;
emxUIConstants.CALENDAR_YEARS_BEFORE = <%=yearsBefore%>;
emxUIConstants.CALENDAR_YEARS_AFTER = <%=yearsAfter%>;
//XSSOK
emxUIConstants.CALENDAR_CUSTOM_YEARS = [<%=customList.toString()%>];

emxUIConstants.TYPE_CHOOSER_MAX = <%=maxTypesDisplay%>;
emxUIConstants.ERR_TOO_MANY_TYPES = "<%=maxTypesMsg%>";

emxUIConstants.ERR_SELECT_DIRECTION = "<%=ERR_SELECT_DIRECTION%>";
emxUIConstants.STR_EDIT = "<%=STR_EDIT%>";
emxUIConstants.STR_VIEW = "<%=STR_VIEW%>";
emxUIConstants.STR_ENABLE_EDIT ="<%=STR_ENABLE_EDIT%>";
emxUIConstants.STR_DISABLE_EDIT ="<%=STR_DISABLE_EDIT%>";
emxUIConstants.STR_WRAP ="<%=STR_WRAP%>";
emxUIConstants.STR_SB_EDIT_TOOLTIP = "<%=STR_SB_EDIT_TOOLTIP%>";
emxUIConstants.STR_SB_ROW_REMOVETOOLTIP = "<%=STR_SB_ROW_REMOVETOOLTIP%>";
emxUIConstants.STR_SB_MESSAGEBODY= "<%=STR_SB_MESSAGEBODY%>";
emxUIConstants.STR_SB_MESSAGEBODY_NOSAVE= "<%=STR_SB_MESSAGEBODY_NOSAVE%>";
emxUIConstants.STR_SB_NEW_ROWTOOLTIP = "<%=STR_SB_NEW_ROWTOOLTIP %>";
emxUIConstants.STR_SBEDITDIALOG_MESSAGE = "<%=STR_SBEDITDIALOG_MESSAGE%>";
emxUIConstants.STR_UNWRAP ="<%=STR_UNWRAP%>";
emxUIConstants.STR_GRAPH_MODE_ALERT="<%=STR_GRAPH_MODE_ALERT%>";
emxUIConstants.STR_GRAPH_MODE_WARNING="<%=STR_GRAPH_MODE_WARNING%>";
emxUIConstants.STR_GRAPH_MODE_ALERT_LIMIT="<%=STR_GRAPH_MODE_ALERT_LIMIT%>";
emxUIConstants.STR_GRAPH_MODE_WARNING_LIMIT="<%=STR_GRAPH_MODE_WARNING_LIMIT%>";
emxUIConstants.STR_FILE_UPLOAD_IN_PROGRESS="<%=STR_FILE_UPLOAD_IN_PROGRESS%>";

emxUIConstants.STR_VIEW_MSG = "<%=STR_VIEW_MSG%>";
emxUIConstants.STR_CLOSE_MSG = "<%=STR_CLOSE_MSG%>";
emxUIConstants.STR_FILTER_MSG = "<%=STR_FILTER_MSG%>";
emxUIConstants.STR_PICKAUTONAME = "<%=STR_PICKAUTONAME%>";
emxUIConstants.STR_NAMECOLUMN="<%=STR_NAMECOLUMN%>";
emxUIConstants.STR_APPLYTOSELECTED = "<%=mxApplyToSelected%>";
emxUIConstants.STR_APPLYTOALL = "<%=mxApplyToAll%>";
emxUIConstants.STR_FPDONE = "<%=mxDone%>";
emxUIConstants.STR_FPCANCEL = "<%=mxCancel%>";
emxUIConstants.STR_SORTALERT = "<%=mxSortAlert%>";
emxUIConstants.STR_EXPANDALLALERT = "<%=mxExpandAllAlert%>";
emxUIConstants.STR_SEARCH_CONTAINEDIN_EMPTY = "<%=STR_SEARCH_CONTAINEDIN_EMPTY%>";
emxUIConstants.STR_OBJMSG1 = "<%=strObjectsMessage1%>";
emxUIConstants.STR_OBJMSG1A = "<%=strObjectsMessage1a%>";
emxUIConstants.STR_OBJMSG2 = "<%=strObjectsMessage2%>";
emxUIConstants.STR_MORELEVEL_ERROR = "<%=strMoreLevelError%>";
emxUIConstants.STR_ALLLEVEL_ERROR = "<%=strAllLevelError%>";
emxUIConstants.STR_MORELEVEL_ENTERVALUE = "<%=strEnterValue %>";
emxUIConstants.STR_EXPAND_ABORTED1 = "<%=strExpandAborted1 %>";
emxUIConstants.STR_EXPAND_ABORTED2 = "<%=strExpandAborted2 %>";
emxUIConstants.STR_EXPAND_STOP = "<%=strExpandStop %>";
emxUIConstants.STR_EXPAND_WAIT = "<%=strExpandWait %>";
emxUIConstants.STR_EXPAND_HEADERNSG1 = "<%=strHeaderMsg1 %>";
emxUIConstants.STR_EXPAND_HEADERNSG2 = "<%=strHeaderMsg2 %>";
emxUIConstants.STR_EXPAND_TOOLTIP = "<%=strExpandTooltip %>";
emxUIConstants.STR_EXPAND_ALL = "<%=strExpandAll %>";
emxUIConstants.STR_EXPAND_N_LEVELS = "<%=strExpandNLevels %>";
//Added for RMB START
emxUIConstants.STR_LOADING_MENU = "<%=strLoading %>";
//Added for RMB END
emxUIConstants.STR_SBEDIT_NO_SELECT_NODES = "<%=STR_SBEDIT_NO_SELECT_NODES %>";
emxUIConstants.STR_SBEDIT_ROOT_NODE_OPERATION = "<%=STR_SBEDIT_ROOT_NODE_OPERATION %>";
emxUIConstants.STR_SBEDIT_NO_EDIT_OPERATION = "<%=STR_SBEDIT_NO_EDIT_OPERATION %>";
emxUIConstants.STR_SBEDIT_NO_NODES_COPIED = "<%=STR_SBEDIT_NO_NODES_COPIED %>";
emxUIConstants.STR_SBEDIT_NO_RESEQ_OPERATION = "<%=STR_SBEDIT_NO_RESEQ_OPERATION %>";
emxUIConstants.STR_SBEDIT_NO_MATCH_EDITREL_URL = "<%=STR_SBEDIT_NO_MATCH_EDITREL_URL %>";
emxUIConstants.STR_SBEDIT_NO_EDITREL_URL = "<%=STR_SBEDIT_NO_EDITREL_URL %>";
emxUIConstants.STR_SBEDIT_ALLOWEDIT_FLAG_FALSE = "<%=STR_SBEDIT_ALLOWEDIT_FLAG_FALSE %>";
emxUIConstants.STR_SBEDIT_NO_MATCH_RESEQREL_URL = "<%=STR_SBEDIT_NO_MATCH_RESEQREL_URL %>";
emxUIConstants.STR_SBEDIT_NO_RESEQREL_URL = "<%=STR_SBEDIT_NO_RESEQREL_URL %>";
emxUIConstants.STR_SBEDIT_NO_CONNECTJPO_URL = "<%=STR_SBEDIT_NO_CONNECTJPO_URL %>";
emxUIConstants.STR_SBEDIT_NO_POSSIBLE_REL_SCHEMA = "<%=STR_SBEDIT_NO_POSSIBLE_REL_SCHEMA %>";
emxUIConstants.STR_PENDING_EDITS_MESSAGE = "<%=STR_PENDING_EDITS_MESSAGE%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_MESSAGE = "<%=STR_PENDING_EDITS_PAGINATION_MESSAGE%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_OFF = "<%=STR_PENDING_EDITS_PAGINATION_OFF%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_ON = "<%=STR_PENDING_EDITS_PAGINATION_ON%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_NEXT = "<%=STR_PENDING_EDITS_PAGINATION_NEXT%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_PREVIOUS = "<%=STR_PENDING_EDITS_PAGINATION_PREVIOUS%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_PAGE = "<%=STR_PENDING_EDITS_PAGINATION_PAGE%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_OF = "<%=STR_PENDING_EDITS_PAGINATION_OF%>";
emxUIConstants.STR_PENDING_EDITS_PAGINATION_OBJECTS = "<%=STR_PENDING_EDITS_PAGINATION_OBJECTS%>";

emxUIConstants.STR_SBEDIT_UNDO_SELECT_NODES =  "<%=STR_SBEDIT_UNDO_SELECT_NODES %>";
emxUIConstants.STR_SBEDIT_NO_EDIT_OF_BASIC_NEWROW =  "<%=STR_SBEDIT_NO_EDIT_OF_BASIC_NEWROW %>";
emxUIConstants.STR_SBEDIT_SAVE_THE_CHANGES =  "<%= STR_SBEDIT_SAVE_THE_CHANGES %>";

//Added for MarkUp Starts
emxUIConstants.STR_SBMARKUP_SELECT_TO_LOADMARKUP= "<%=STR_SBMARKUP_SELECT_TO_LOADMARKUP %>";
emxUIConstants.STR_SBMARKUP_SELECT_TO_GETMARKUP = "<%=STR_SBMARKUP_SELECT_TO_GETMARKUP %>";
emxUIConstants.STR_SBMARKUP_NO_OBJ_TO_CUT = "<%=STR_SBMARKUP_NO_OBJ_TO_CUT %>";
//Added for MarkUp Ends

//Added for ListBoxManual
emxUIConstants.STR_LISTBOXMANUAL_NO_MULTIPLE_VALUES = "<%=STR_LISTBOXMANUAL_NO_MULTIPLE_VALUES %>";
emxUIConstants.STR_LISTBOXMANUAL_DONE = "<%=STR_LISTBOXMANUAL_DONE %>";
emxUIConstants.STR_LISTBOXMANUAL_CANCEL = "<%=STR_LISTBOXMANUAL_CANCEL %>";
emxUIConstants.STR_LISTBOXMANUAL_CTRLCLICK = "<%=STR_LISTBOXMANUAL_CTRLCLICK %>";


//Added for Compare Starts
emxUIConstants.STR_SBCOMPARE_NOOBJ_TO_APPLY = "<%=STR_SBCOMPARE_NOOBJ_TO_APPLY %>";
emxUIConstants.STR_SBCOMPARE_ROOT_OBJ_CANT_SYNC = "<%=STR_SBCOMPARE_ROOT_OBJ_CANT_SYNC %>";
emxUIConstants.STR_SBCOMPARE_NOOBJ_TO_RESET = "<%=STR_SBCOMPARE_NOOBJ_TO_RESET %>";
emxUIConstants.STR_SYNC_RESET_MSG = "<%=STR_SYNC_RESET_MSG%>";
emxUIConstants.STR_FIRST_OBJ_SELECT_MSG = "<%=STR_FIRST_OBJ_SELECT_MSG%>";
emxUIConstants.STR_SECOND_OBJ_SELECT_MSG = "<%=STR_SECOND_OBJ_SELECT_MSG%>";
emxUIConstants.STR_COMPARE_CRITERIA_ERROR_MSG = "<%=STR_COMPARE_CRITERIA_ERROR_MSG%>";
emxUIConstants.STR_DIALOG_CONFIG_ERROR_MSG = "<%=STR_DIALOG_CONFIG_ERROR_MSG%>";
emxUIConstants.STR_COMPARE_SELECT_MINOBJECT = "<%=STR_COMPARE_SELECT_MINOBJECT%>";
//Added for Custom Tables

emxUIConstants.STR_CUSTOMIZE = "<%=STR_CUSTOMIZE %>";
emxUIConstants.STR_SHOW_SYSTEM_COLUMNS = "<%=STR_SHOW_SYSTEM_COLUMNS%>";
emxUIConstants.STR_SHOW_CUSTOM_COLUMNS = "<%=STR_SHOW_CUSTOM_COLUMNS %>";

emxUIConstants.STR_NAVIGATIONVIEW = "<%=STR_NAVIGATIONVIEW%>";
emxUIConstants.STR_FORMBASEDVIEW = "<%=STR_FORMBASEDVIEW%>";
emxUIConstants.STR_DISPLAY_MESSAGE_NAVIGATIONVIEW = "<%=STR_DISPLAY_MESSAGE_NAVIGATIONVIEW%>";
emxUIConstants.STR_DISPLAY_MESSAGE_FORMBASEDVIEW = "<%=STR_DISPLAY_MESSAGE_FORMBASEDVIEW%>";
emxUIConstants.STR_DISPLAY_MESSAGE_REALTIME_FORMBASEDVIEW = "<%=STR_DISPLAY_MESSAGE_REALTIME_FORMBASEDVIEW%>";
emxUIConstants.STR_CALLBACK_MSG = "<%=STR_CALLBACK_MSG%>";
emxUIConstants.STR_CALLBACK_ERR = "<%=STR_CALLBACK_ERR%>";
emxUIConstants.STR_RESULTOBJECTS = "<%=STR_RESULTOBJECTS%>";

emxUIConstants.STR_ALERT_NUMBER = "<%=STR_ALERT_NUMBER%>";
emxUIConstants.STR_ALERT_NUMERIC = "<%=STR_ALERT_NUMERIC%>";
emxUIConstants.STR_ALERT_MAXLIMIT = "<%=STR_ALERT_MAXLIMIT%>";

emxUIConstants.STR_QUERY_TYPE = "<%=STR_QUERY_TYPE%>";
emxUIConstants.REFRESH_TAXONOMIES = <%=REFRESH_TAXONOMIES%>;
emxUIConstants.STR_REFRESH_WINDOW_SHADE = <%=STR_REFRESH_WINDOW_SHADE%>;
emxUIConstants.STR_SUBMIT_GLOBAL_SEARCH = "<%=STR_SUBMIT_GLOBAL_SEARCH%>";

emxUIConstants.STR_PAGE_SIZE = <%=STR_PAGE_SIZE%>;
emxUIConstants.STR_FASTSORT_THRESHOLD = <%=STR_FASTSORT_THRESHOLD%>;
emxUIConstants.STR_SHOW_PAGINATION = <%=STR_SHOW_PAGINATION%>;
emxUIConstants.STR_VALID_NUMBER_ALERT = "<%=STR_VALID_NUMBER_ALERT%>";
emxUIConstants.STR_INTEGER_SAVED_WARNING = "<%=STR_INTEGER_SAVED_WARNING%>";
emxUIConstants.STR_ZEROORLESS_ALERT = "<%=STR_ZEROORLESS_ALERT%>";
emxUIConstants.STR_MAX_LIMIT_ALERT = "<%=STR_MAX_LIMIT_ALERT%>";
emxUIConstants.STR_OF = "<%=STR_OF%>";
emxUIConstants.STR_RESULTS = "<%=STR_RESULTS%>";
emxUIConstants.STR_PREV = "<%=STR_PREV%>";
emxUIConstants.STR_NEXT = "<%=STR_NEXT%>";
emxUIConstants.STR_MAX_QUERY_LIMIT = "<%=STR_MAX_QUERY_LIMIT%>";
emxUIConstants.STR_LEGACY_MAX_QUERY_LIMIT = "<%=STR_LEGACY_MAX_QUERY_LIMIT%>";
emxUIConstants.STR_MAX_QUERY_ALERT = "<%=STR_MAX_QUERY_ALERT %>";
emxUIConstants.STR_SUGGESTIONS = "<%=STR_SUGGESTIONS%>";
emxUIConstants.STR_RESULTS_OF = "<%=STR_RESULTS_OF%>";
emxUIConstants.STR_WILDCHARALERT = "<%=STR_WILDCHARALERT%>";
emxUIConstants.STR_WILDCHARCONFIRM = "<%=STR_WILDCHARCONFIRM%>";
emxUIConstants.STR_WILDCHARCONFIRMSTR = "<%=STR_WILDCHARCONFIRMSTR%>";
emxUIConstants.STR_NONWILDCHARALERT="<%=STR_NONWILDCHARALERT%>";
emxUIConstants.STR_NONWILDCHARCONFIRM="<%=STR_NONWILDCHARCONFIRM%>";

emxUIConstants.STR_REFINEMENT_SEPARATOR="<%=STR_REFINEMENT_SEPARATOR%>";
//XSSOK
emxUIConstants.STR_DEC_SYM="<%=STR_DEC_SYM%>";


emxUIConstants.FTS_MINIUM_SEARCHCHARS = parseInt("<%=FTS_MINIUM_SEARCHCHARS%>");
emxUIConstants.FTS_CHAR_VIOLATION = "<%=FTS_CHAR_VIOLATION%>";
// help dir
emxUIConstants.HELP_URL = "<%=STR_HELP_URL%>";
emxUIConstants.STR_IS_CLOUD = "<%=STR_IS_CLOUD%>";
emxUIConstants.STR_SEARCH_SAVED = "<%=STR_SEARCH_SAVED%>";
emxUIConstants.STR_SEARCH_SEARCH = "<%=STR_SEARCH_SEARCH%>";
emxUIConstants.STR_SEARCH_CLEAR = "<%=STR_SEARCH_CLEAR%>";
emxUIConstants.ERR_SELECTION = "<%=ERR_SELECTION%>";
emxUIConstants.ERR_REMOVE    = "<%=ERR_REMOVE%>";
emxUIConstants.STR_TYPEAHEAD_CHARACTERCOUNT= "<%=STR_TYPEAHEAD_CHARACTERCOUNT%>";
emxUIConstants.ERR_REQUIRED  = "<%=ERR_REQUIRED%>";
emxUIConstants.ERR_ROW_SELECTION  = "<%=ERR_ROW_SELECTION%>";
emxUIConstants.STR_TYPEAHEAD_RUNPROGRAM="<%=STR_TYPEAHEAD_RUNPROGRAM%>";
emxUIConstants.STR_TYPEAHEAD_SYSTEM="<%=STR_TYPEAHEAD_SYSTEM%>";
emxUIConstants.ERR_MANDATORY  = "<%=ERR_MANDATORY%>";
emxUIConstants.STR_VALID_DATE_ALERT  = "<%=STR_VALID_DATE_ALERT%>";
emxUIConstants.STR_VALID_NUMERIC_ALERT  = "<%=STR_VALID_NUMERIC_ALERT%>";
emxUIConstants.STR_SEARCH_IN_PROGRESS_ALERT  = "<%=STR_SEARCH_IN_PROGRESS_ALERT%>";
emxUIConstants.STR_SB_DESCR_WIDTH = parseInt("<%=STR_SB_DESCR_WIDTH%>");
emxUIConstants.STR_SB_IMAGE_WIDTH = parseInt("<%=STR_SB_IMAGE_WIDTH%>")
emxUIConstants.STR_SB_MIN_WIDTH = parseInt("<%=STR_SB_MIN_WIDTH%>")
emxUIConstants.STR_SB_WRAP_STYLE = "<%=STR_SB_WRAP_STYLE%>"
emxUIConstants.STR_PORTAL_MIN_HEIGHT =parseInt("<%= STR_PORTAL_MIN_HEIGHT%>");
emxUIConstants.STR_TODAY ="<%=STR_TODAY%>";
//XSSOK
emxUIConstants.FOMAT_THUMBNAIL_SIZE= parseInt("<%=FOMAT_THUMBNAIL_SIZE%>");
//XSSOK
emxUIConstants.FOMAT_SMALL_SIZE    = parseInt("<%=FOMAT_SMALL_SIZE%>");
//XSSOK
emxUIConstants.FOMAT_MEDIUM_SIZE   = parseInt("<%=FOMAT_MEDIUM_SIZE%>");
//XSSOK
emxUIConstants.FOMAT_LARGE_SIZE    = parseInt("<%=FOMAT_LARGE_SIZE%>");
emxUIConstants.STR_NotEnoughStorageMsg = "<%=STR_NotEnoughStorageMsg%>";
emxUIConstants.STR_JS_Error = "<%=STR_JS_Error %>";
emxUIConstants.STR_JS_FromServer= "<%=STR_JS_FromServer %>";
emxUIConstants.STR_JS_ErrorOWTTT = "<%=STR_JS_ErrorOWTTT %>";
emxUIConstants.STR_JS_AttOrMethod = "<%=STR_JS_AttOrMethod %>";
emxUIConstants.STR_JS_Type = "<%=STR_JS_Type %>";
emxUIConstants.STR_JS_Name = "<%=STR_JS_Name %>";
emxUIConstants.STR_JS_Rev = "<%=STR_JS_Rev %>";
emxUIConstants.STR_JS_Value = "<%=STR_JS_Value %>";
emxUIConstants.STR_JS_AnErrorOWEDTBSTTS = "<%=STR_JS_AnErrorOWEDTBSTTS %>";
emxUIConstants.STR_JS_AnErrorOWTTLTD = "<%=STR_JS_AnErrorOWTTLTD %>";
emxUIConstants.STR_JS_Description = "<%=STR_JS_Description %>";
emxUIConstants.STR_JS_NoDataFor = "<%=STR_JS_NoDataFor %>";
emxUIConstants.STR_JS_NoResults = "<%=STR_JS_NoResults %>";
emxUIConstants.STR_JS_MaxValue = "<%=STR_JS_MaxValue %>";
emxUIConstants.STR_JS_AnExceptionOccurred = "<%=STR_JS_AnExceptionOccurred %>";
emxUIConstants.STR_JS_ErrorName = "<%=STR_JS_ErrorName %>";
emxUIConstants.STR_JS_ErrorDescription = "<%=STR_JS_ErrorDescription %>";
emxUIConstants.STR_JS_ErrorNumber = "<%=STR_JS_ErrorNumber %>";
emxUIConstants.STR_JS_ErrorMessage = "<%=STR_JS_ErrorMessage %>";
emxUIConstants.STR_JS_ObjectManagerCNBL = "<%=STR_JS_ObjectManagerCNBL %>";
emxUIConstants.STR_JS_InvalidChannelName = "<%=STR_JS_InvalidChannelName %>";
emxUIConstants.STR_JS_RefreshFailed = "<%=STR_JS_RefreshFailed %>";
emxUIConstants.STR_JS_MultiValueColumnNotFiltered = "<%=STR_JS_MultiValueColumnNotFiltered %>";
emxUIConstants.STR_JS_AnErrorOWCDMR = "<%=STR_JS_AnErrorOWCDMR %>";
emxUIConstants.STR_JS_Init = "<%=STR_JS_Init %>";
emxUIConstants.STR_JS_FilteredNodes = "<%=STR_JS_FilteredNodes %>";
emxUIConstants.STR_JS_ShowAllRootNodes = "<%=STR_JS_ShowAllRootNodes %>";
emxUIConstants.STR_JS_ExceptionIs = "<%=STR_JS_ExceptionIs %>";
emxUIConstants.STR_JS_ErrorPrefetch = "<%=STR_JS_ErrorPrefetch %>";
emxUIConstants.STR_JS_APreciseBOMGenerated = "<%=STR_JS_APreciseBOMGenerated %>";
emxUIConstants.STR_JS_AnErrorOICM = "<%=STR_JS_AnErrorOICM %>";
emxUIConstants.STR_JS_AssertionFailed = "<%=STR_JS_AssertionFailed %>";
emxUIConstants.STR_JS_Actual = "<%=STR_JS_Actual %>";
emxUIConstants.STR_JS_InvalidResult = "<%=STR_JS_InvalidResult %>";
emxUIConstants.STR_JS_ConfirmRemoveMessage = "<%=STR_JS_ConfirmRemoveMessage%>";
emxUIConstants.STR_JS_ConfirmDeleteMessage = "<%=STR_JS_ConfirmDeleteMessage%>";
emxUIConstants.STR_JS_ConfirmAddTaskComplete = "<%=STR_JS_ConfirmAddTaskComplete%>";
emxUIConstants.STR_JS_ConfirmDisconnect = "<%=STR_JS_ConfirmDisconnect%>";
emxUIConstants.STR_JS_ReviseSelected = "<%=STR_JS_ReviseSelected%>";
emxUIConstants.STR_JS_Revise = "<%=STR_JS_Revise%>";
emxUIConstants.STR_JS_Version = "<%=STR_JS_Version%>";
emxUIConstants.STR_JS_ValidateConfiguration = "<%=STR_JS_ValidateConfiguration%>";

//XSSOK
emxUIConstants.DECIMAL_QTY_SETTING = "<%=decimalQtySetting%>";
//XSSOK
emxUIConstants.BROWSER_LANGUAGE = "<%=browserLanguage%>";
//XSSOK
emxUIConstants.UI_AUTOMATION = "<%=uiAutomation%>";
emxUIConstants.SWITCH_ICON_ONLY = "<%=STR_ICON_ONLY%>";
emxUIConstants.SWITCH_ICON_TEXT = "<%=STR_ICON_TEXT%>";

emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED = parseInt("<%=slideInAnimationSpeed%>");
emxUIConstants.NUM_WINDOWSHADE_ANIMATIONSPEED = parseInt("<%=windowShadeAnimationSpeed%>");
emxUIConstants.STR_SLIDEIN_ANIMATIONTYPE = "<%=slideInAnimationType%>";
emxUIConstants.STR_WINDOWSHADE_ANIMATIONTYPE = "<%=windowShadeAnimationType%>";
//XSSOK

//STR_UITREE_OLDUI constant is no more supported.
emxUIConstants.STR_UITREE_OLDUI="false";

emxUIConstants.NUM_HISTORY_LIMIT=<%=STR_HISTORY_LIMIT%>;
emxUIConstants.STR_VIEW_ALL_SEARCH_RESULTS="<%=STR_VIEW_ALL_SEARCH_RESULTS%>";
emxUIConstants.STR_BC_LABEL_HOME = "<%= STR_BC_LABEL_HOME%>";

emxUIConstants.ARR_PopupWidth = {};
emxUIConstants.ARR_PopupHeight = {};
emxUIConstants.ARR_PopupDimensions = {};
emxUIConstants.STR_FILL_PAGES = "<%=STR_FILL_PAGES%>";
emxUIConstants.STR_PAGESIZE	= "<%=STR_PAGESIZE%>";
emxUIConstants.STR_LOADING_PAGE = "<%=STR_LOADING_PAGE%>";
emxUIConstants.STR_LOADING_ATTRIBUTES = "<%=STR_LOADING_ATTRIBUTES%>";
emxUIConstants.STR_LOADING_TAXONOMIES = "<%=STR_LOADING_TAXONOMIES%>";
emxUIConstants.STR_LOADING_CHILD_TAXONOMIES = "<%=STR_LOADING_CHILD_TAXONOMIES%>";
emxUIConstants.STR_TAXONOMIES = "<%=STR_TAXONOMIES%>";

emxUIConstants.STR_CONTINUE = "<%=strContinue %>";

// GSB
emxUIConstants.GSB_ROTATE = "<%= GSB_ROTATE %>";
emxUIConstants.GSB_FIT_TO_PAGE = "<%= GSB_FIT_TO_PAGE %>";
emxUIConstants.GSB_IMAGE = "<%= GSB_IMAGE %>";
emxUIConstants.GSB_MINI_MAP = "<%= GSB_MINI_MAP %>";
emxUIConstants.GSB_FIND = "<%= GSB_FIND %>";
emxUIConstants.GSB_FIND_TXT = "<%= GSB_FIND_TXT %>";

//Auto Filter
emxUIConstants.STR_AUTO_FILTER_SELECTIONS = "<%= STR_AUTO_FILTER_SELECTIONS %>";
emxUIConstants.STR_AUTO_FILTER_RESET ="<%= STR_AUTO_FILTER_RESET %>";
emxUIConstants.STR_AUTO_FILTER_APPLY ="<%= STR_AUTO_FILTER_APPLY %>";
emxUIConstants.STR_AUTO_FILTER_CLOSE ="<%= STR_AUTO_FILTER_CLOSE %>";
emxUIConstants.STR_AUTO_FILTER_MORE ="<%= STR_AUTO_FILTER_MORE %>";
emxUIConstants.STR_AUTO_FILTER_SELECT_ALL ="<%= STR_AUTO_FILTER_SELECT_ALL %>";
emxUIConstants.STR_AUTO_FILTER_MULTI_SELECT = "<%= STR_AUTO_FILTER_MULTI_SELECT %>";
emxUIConstants.STR_AUTO_FILTER_DONE ="<%= STR_AUTO_FILTER_DONE %>";
emxUIConstants.STR_AUTO_FILTER_BLANK ="<%= STR_AUTO_FILTER_BLANK %>";
emxUIConstants.STR_COMPASS_FACET_WHO ="<%= STR_COMPASS_FACET_WHO %>";
emxUIConstants.STR_COMPASS_FACET_WHAT ="<%= STR_COMPASS_FACET_WHAT %>";
emxUIConstants.STR_COMPASS_FACET_WHERE ="<%= STR_COMPASS_FACET_WHERE %>";
emxUIConstants.STR_COMPASS_FACET_WHEN ="<%= STR_COMPASS_FACET_WHEN %>";
emxUIConstants.STR_COMPASS_FACET_WHY ="<%= STR_COMPASS_FACET_WHY %>";
emxUIConstants.STR_HELP_ICON ="<%= STR_HELP_ICON %>";
emxUIConstants.STR_HELP_LANGUAGE ="<%= STR_HELP_LANGUAGE %>";
emxUIConstants.STR_HELP_ONLINE_LANGUAGE ="<%= STR_HELP_ONLINE_LANGUAGE %>";

//For Rich Text Editor
emxUIConstants.RTE_BOLD = "<%=RTE_BOLD %>";
emxUIConstants.RTE_ITALIC = "<%=RTE_ITALIC %>";
emxUIConstants.RTE_UNDERLINE = "<%=RTE_UNDERLINE %>";
emxUIConstants.RTE_STRIKETHROUGH = "<%=RTE_STRIKETHROUGH %>";
emxUIConstants.RTE_SUPERSCRIPT = "<%=RTE_SUPERSCRIPT %>";
emxUIConstants.RTE_SUBSCRIPT = "<%=RTE_SUBSCRIPT %>";
emxUIConstants.RTE_SPECIALCHARACTER = "<%=RTE_SPECIALCHARACTER %>";
emxUIConstants.RTE_OK = "<%=RTE_OK %>";
emxUIConstants.RTE_CANCEL = "<%=RTE_CANCEL %>";
//spell checker
emxUIConstants.SPELL_CHECK = "<%=SPELL_CHECK %>";
//badchar
emxUIConstants.STR_BADCHAR =STR_BADCHAR.split(" ");
emxUIConstants.BAD_CHAR = BAD_CHAR;
emxUIConstants.SELECT_ONE_ITEM = "<%=SELECT_ONE_ITEM%>";
emxUIConstants.STR_NO_COLUMNS = "<%=STR_NO_COLUMNS %>";

//Channel UI
emxUIConstants.ChannelUI_SEEALL = "<%=ChannelUI_SEEALL %>";
emxUIConstants.ChannelUI_LATE = "<%=ChannelUI_LATE %>";
emxUIConstants.ChannelUI_TASKS = "<%=ChannelUI_TASKS %>";
emxUIConstants.ChannelUI_FILTERS = "<%=ChannelUI_FILTERS %>";
emxUIConstants.ChannelUI_APPLY = "<%=ChannelUI_APPLY %>";
emxUIConstants.ChannelUI_RESET = "<%=ChannelUI_RESET %>";

//Shortcuts
emxUIConstants.STR_SHORTCUTS = "<%= STR_SHORTCUTS %>";
emxUIConstants.NO_OBJECT_ERROR ="<%= NO_OBJECT_ERROR %>";
emxUIConstants.SHORTCUT_REMOVE_BUTTON = "<%=SHORTCUT_REMOVE_BUTTON%>";
emxUIConstants.SHORTCUT_REMOVEALL_BUTTON = "<%=SHORTCUT_REMOVEALL_BUTTON%>";
emxUIConstants.SHORTCUT_REMOVEALL_MESSAGE = "<%=SHORTCUT_REMOVEALL_MESSAGE%>";

emxUIConstants.SixWTagging_EXALEAD_MESSAGE = "<%=SixWTagging_EXALEAD_MESSAGE%>";

emxUIConstants.UnSupportedContentMsg = "<%=UnSupportedContentMsg%>";

//Category tab width
emxUIConstants.CATEGORY_TAB_Width = parseInt("<%=categoryTabWidth%>");
//CSRF

emxUIConstants.isCSRFEnabled = <%=isCSRFEnabled%>;
emxUIConstants.isPageTokenEnabled = <%=isPageTokenEnabled%>;
//XSSOK
emxUIConstants.CSRF_TOKEN_NAME = "<%=CSRF_TOKEN_NAME%>";
//XSSOK
emxUIConstants.CSRF_TOKEN_KEY = "<%=CSRF_TOKEN_KEY%>";
//XSSOK
emxUIConstants.CSRF_TOKEN_VALUE = "<%=CSRF_TOKEN_VALUE%>";
emxUIConstants.fastloadSBinIE = <%=fastloadSBinIE%>

// For range value attributes
emxUIConstants.INVALID_RANGE_FORMAT = "<%=INVALID_RANGE_FORMAT%>";
emxUIConstants.INVALID_RANGE_VALUE = "<%=INVALID_RANGE_VALUE%>";
emxUIConstants.MINIMUM_NOT_LESS_THAN_MAXIMUM = "<%=MINIMUM_NOT_LESS_THAN_MAXIMUM%>";

<%
StringList sizeList = FrameworkProperties.getTokenizedProperty(context,"emxFramework.PopupSize", ",");
String defaultSize = "Medium";

try{
defaultSize = EnoviaResourceBundle.getProperty(context, "emxFramework.PopupSize.Default");
}catch(Exception ex){}

for(int i = 0; i < sizeList.size(); i++){
	String sizeName = (String)sizeList.get(i);
	try{
		StringList dimList = FrameworkProperties.getTokenizedProperty(context,"emxFramework.PopupSize." + sizeName , "x");%>
		emxUIConstants.ARR_PopupWidth['<%=sizeName %>'] = parseInt('<%=dimList.get(0)%>');
		emxUIConstants.ARR_PopupHeight['<%=sizeName %>'] = parseInt('<%=dimList.get(1)%>');
		emxUIConstants.ARR_PopupDimensions ['<%=dimList.get(0)%>x<%=dimList.get(1)%>'] = '<%=sizeName %>';
		<% if(defaultSize.equals(sizeName)){ %>
	        emxUIConstants.ARR_PopupWidth['Default'] = parseInt('<%=dimList.get(0)%>');
	        emxUIConstants.ARR_PopupHeight['Default'] = parseInt('<%=dimList.get(1)%>');
	    <% }  %>
<%  }catch(Exception ex){
        //do nothing
    }
}%>

emxUIConstants.DIR_COMMON = "../common/";
emxUIConstants.DIR_IMAGES = emxUIConstants.DIR_COMMON + "images/";
emxUIConstants.DIR_STYLES = emxUIConstants.DIR_COMMON + "styles/";
emxUIConstants.DIR_SCRIPTS = emxUIConstants.DIR_COMMON + "scripts/";
emxUIConstants.DIR_SMALL_ICONS = emxUIConstants.DIR_IMAGES;
emxUIConstants.IMG_SPACER = emxUIConstants.DIR_IMAGES + "utilSpacer.gif";
emxUIConstants.IMG_LOADING = emxUIConstants.DIR_SMALL_ICONS + "iconStatusLoading.gif";
emxUIConstants.CSS_DEFAULT = "emxUIDefault";
emxUIConstants.HTML_LOADING = "<table border=\"0\"><tr><td><img src=\"" + emxUIConstants.IMG_LOADING + "\" border=\"0\" /></td><td>" + emxUIConstants.STR_LOADING + "</td></tr></table>";
emxUIConstants.HTML_SEARCHING = "<table border=\"0\"><tr><td><img src=\"" + emxUIConstants.IMG_LOADING + "\" border=\"0\" /></td><td>" + emxUIConstants.STR_SEARCHING + "</td></tr></table>";
emxUIConstants.CALENDAR_START_DOW = 0;
if(typeof(sessionStorage)!=="undefined")
{
	emxUIConstants.STORAGE_SUPPORTED=true;
}
//XSSOK
emxUIConstants.SELECTED = "<%=selectedFilter%>";
//XSSOK
emxUIConstants.HIDEPANEL = "<%=hidePanelStr%>";
emxUIConstants.RESTRICTED_FILE_FORMATS = "<%=RESTRICTED_FILE_FORMATS%>";
emxUIConstants.SUPPORTED_FILE_FORMATS = "<%=SUPPORTED_FILE_FORMATS%>";
emxUIConstants.RESTRICTED_FORMATS_ALERT = "<%=RESTRICTED_FORMATS_ALERT%>";
emxUIConstants.SUPPORTED_FORMATS_ALERT = "<%=SUPPORTED_FORMATS_ALERT%>";
emxUIConstants.FILENAME_BAD_CHARACTERS = "<%=FILENAME_BAD_CHARACTERS%>";
emxUIConstants.INVALID_FILENAME_INPUTCHAR = "<%=INVALID_FILENAME_INPUTCHAR%>";
emxUIConstants.FILENAME_CHAR_NOTALLOWED   = "<%=FILENAME_CHAR_NOTALLOWED%>";
emxUIConstants.FILENAME_INVALIDCHAR_ALERT = "<%=FILENAME_INVALIDCHAR_ALERT%>";
emxUIConstants.INVALID_IMAGE_EXTENSION_MESSAGE = "<%=INVALID_IMAGE_EXTENSION%>";
emxUIConstants.IMAGE_ALLOWED_FORMATS = "<%=IMAGE_ALLOWED_FORMATS%>";
emxUIConstants.IMAGE_ALLOWED_FORMATS = emxUIConstants.IMAGE_ALLOWED_FORMATS.toLowerCase();
emxUIConstants.IMAGE_COMMAND_DNDUPLOAD = "<%=IMAGE_COMMAND_DNDUPLOAD%>";
emxUIConstants.IMAGE_COMMAND_SETASPRIMARY = "<%=IMAGE_COMMAND_SETASPRIMARY%>";
emxUIConstants.IMAGE_COMMAND_DELETE = "<%=IMAGE_COMMAND_DELETE%>";
emxUIConstants.IMAGE_COMMAND_HELP = "<%=IMAGE_COMMAND_HELP%>";
emxUIConstants.IMAGE_NO_IMAGE_ASSOC = "<%=IMAGE_NO_IMAGE_ASSOC%>";
emxUIConstants.UPDATE_FILES_ERROR = "<%=UPDATE_FILES_MISSING%>";
emxUIConstants.VIEWMYCOMPANYURL = "<%=viewMyCompanyURL %>";
emxUIConstants.UNSUPPORTED_OPERATION = "<%=UNSUPPORTED_OPERATION%>";
emxUIConstants.MESSAGE_TYPE_PRIVATE="<%=MESSAGE_TYPE_PRIVATE %>";

emxUIConstants.DRAG_MOVE = "<%=DRAG_MOVE%>";
emxUIConstants.DRAG_COPY = "<%=DRAG_COPY%>";
emxUIConstants.STR_AUTOLOGOUT_SERVEREXPIRYTIME = "<%=STR_AUTOLOGOUT_SERVEREXPIRYTIME%>";
emxUIConstants.STR_AUTOLOGOUT_SERVERTIME = "<%=STR_AUTOLOGOUT_SERVERTIME%>";
emxUIConstants.STR_AUTOLOGOUT_CLIENTTIMEOFFSET = "<%=STR_AUTOLOGOUT_CLIENTTIMEOFFSET%>";
emxUIConstants.STR_AUTOLOGOUT_POLLTIMER = <%=STR_AUTOLOGOUT_POLLTIMER%>;

emxUIConstants.WIDER_SLIDEIN_VALUE = "<%=WIDER_SLIDEIN_VALUE%>";
emxUIConstants.USEMSF = "<%=USEMSF%>";
emxUIConstants.CLOSESEARCH = "<%=closeSearch%>";
emxUIConstants.SEARCH_HELP = "<%=searchHelp%>";
emxUIConstants.COPYRIGHT_INFO = "<%=copyrightInfo%>";
emxUIConstants.APPLICATION_MY_DESK_MENU = "<%=applicaionMyDeskMenu%>";

emxUIConstants.SBEditDialog_SAVE = "<%=SBEditDialog_SAVE %>";
emxUIConstants.SBEditDialog_DONT_SAVE = "<%=SBEditDialog_DONT_SAVE %>";
emxUIConstants.SBEditDialog_CANCEL =  "<%=SBEditDialog_CANCEL %>";
//3dSearch
emxUIConstants.ADD_TO_CLIPBOARD_LABEL =  "<%=ADD_TO_CLIPBOARD_LABEL%>";
emxUIConstants.ADD_TO_COLLECTION_LABEL =  "<%=ADD_TO_COLLECTION_LABEL%>";
emxUIConstants.SELECTION_ALERT =  "<%=SELECTION_ALERT%>";
emxUIConstants.TASK_COMMENT_REQUIRED = <%=TASK_COMMENT_REQUIRED %>;
emxUIConstants.TASK_OWNER_COMMENT_REQUIRED = <%=TASK_OWNER_COMMENT_REQUIRED %>;
//DragAndDrop
emxUIConstants.DRAG_DROP_INVALIDTYPE="<%=DRAG_DROP_INVALIDTYPE%>";
emxUIConstants.DRAG_DROP_INVALIDACTION="<%=DRAG_DROP_INVALIDACTION%>";
emxUIConstants.DRAG_DROP_MULTIPLEDROP="<%=DRAG_DROP_MULTIPLEDROP%>";
emxUIConstants.DRAG_DROP_INVALIDRELATION="<%=DRAG_DROP_INVALIDRELATION%>";

//Search window title
emxUIConstants.SEARCH_WINDOW_TITLE_SEPERATOR =  "<%=SEARCH_WINDOW_TITLE_SEPERATOR %>";
emxUIConstants.SEARCH_TITLE =  "<%=SEARCH_TITLE %>";

emxUIConstants.TYPEAHEAD_NORESULTS =  "<%=STR_JS_TypeAheadNoResults %>";
emxUIConstants.CURRENT_ID = "<%=XSSUtil.encodeForJavaScript(context,context.getUser())%>";

//session timeout
emxUIConstants.sessionExpirationTitle =  "<%=sessionExpirationTitle%>";
emxUIConstants.sessionExpirationMessage =  "<%=sessionExpirationMessage%>";

//App Home Page 
emxUIConstants.STR_APPHOMEPAGE = "<%= STR_APPHOMEPAGE %>";
emxUIConstants.MMY_RELOAD = "<%=MMY_RELOAD%>";

var clientUserAgent = navigator.userAgent.toLowerCase();
var isIEBrowser = /(msie|trident)/i.test(clientUserAgent);
var isIE11Browser = false;
if(isIEBrowser){
		var regexp = new RegExp("msie (\\S*);");
        var regResult = regexp.exec(clientUserAgent);
		var fVersion;
		if(!regResult){
			regexp = new RegExp("rv:(\\d*)");	
			fVersion = parseFloat(regexp.exec(clientUserAgent)[1]);
		}
		else{
			fVersion = parseFloat(regResult[1]);
		}
		isIE11Browser = fVersion == 11;
}

if (isIE11Browser && navigator.userAgent.indexOf("Windows NT 6.1") >= 0) {
    emxUIConstants.CHECK_NEW_TAB_TIME = "<%=newTabCheckTimeWin7%>";
} else if (isIE11Browser && navigator.userAgent.indexOf("Windows NT 10.0") >= 0) {
    emxUIConstants.CHECK_NEW_TAB_TIME = "<%=newTabCheckTimeWin10%>";
}

emxUIConstants.CHROME_MMY_RELOAD = "<%=CHROME_MMY_RELOAD%>";
emxUIConstants.CHROME_REFRESH_DELAY_inMS = "<%=chromeSuccessiveRefreshDelay%>";

//Chrome Browser JS Heap check 
var isChromeBrowser = /Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor);

if(isChromeBrowser)
{
	emxUIConstants.CHROME_JS_HEAP_THRESHOLD = <%=chromeJSHeapMemoryThreshold%>;
	emxUIConstants.CHROME_SHOW_JS_HEAP_THRESHOLD_EXCEEDED_ALERT = "<%=chromeShowExceededJSHeapMemoryAlert%>";
}

<%
String disableAutoLogin = (String)session.getAttribute("disableAutoLogin");
if(UIUtil.isNotNullAndNotEmpty(disableAutoLogin) && disableAutoLogin.equalsIgnoreCase("true")){
	return;
}
%>
//This must be last block of statements in this file, since we are adding emxUIConstants object into the sessionStorage
if(emxUIConstants.STORAGE_SUPPORTED){
	var uiconstantscache = sessionStorage.getItem('uiConstantsCache');
	if(typeof uiconstantscache =="undefined" || !uiconstantscache){
		sessionStorage.setItem('uiConstantsCache',JSON.stringify(emxUIConstants));
	}
	uiconstantscache = null; // Added //
}

