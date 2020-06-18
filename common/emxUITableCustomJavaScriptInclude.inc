<%--  emxUITableCustomJavaScriptInclude.inc - The static include file for Admin property registration
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    
    static const char RCSID[] = $Id: emxRegistrationAdminInclude.inc.rca 1.4 Mon May 14 20:49:52 2007 przemek Experimental przemek $
--%>


<%
// String Resource file to be used
String lanStr = request.getHeader("Accept-Language");
String strSelectBoxMove = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.SelectTextBox.Move", new Locale(lanStr));
String strVisibleColumnLength = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.VisibleColumn.Length", new Locale(lanStr));
String columnNoSB = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.VisibleColumn.StructureBrowser.ColumnNumber", new Locale(lanStr));
String validColumn = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.VisibleColumn.ValidColumn", new Locale(lanStr));
String sbFirstColumn = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.StructureBrowser.Firstcolumn", new Locale(lanStr));
String strTableNameError = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.TableName.Alert", new Locale(lanStr));
String strSetWidth = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.SelectTextBox.Setwidth", new Locale(lanStr));
String strViewName = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.CustomizeTable.View.Name.Alert", new Locale(lanStr));
String strInvalidChars = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Alert.InvalidChars", new Locale(lanStr));
String noneLabel = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.SortColumn.Default", new Locale(lanStr));
String tableNameLength = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.TableName.Length", new Locale(lanStr));
String freezePaneColumn =EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UITable.FreezePane.Column", new Locale(lanStr));
%>
<script language="JavaScript">
//XSSOK
var SELECTBOX_MOVE_MSG = "<%=strSelectBoxMove%>" ;
//XSSOK
var VISIBLECOLUMN_LENGTH_MSG = "<%=strVisibleColumnLength %>";
//XSSOK
var TABLENAME_ALERT_MSG = "<%=strTableNameError%>" ;
//XSSOK
var WIDTH_MESSAGE_MSG = "<%=strSetWidth %>" ;
//XSSOK
var INVALID_CHAR_MSG = "<%=strInvalidChars %>" ;
//XSSOK
var VIEW_NAME_MSG = "<%=strViewName %>" ;
//XSSOK
var SB_COLUMN_NO = "<%=columnNoSB %>" ;
//XSSOK
var VALID_COLUMN = "<%=validColumn %>" ;
//XSSOK
var SB_FIRST_COLUMN = "<%=sbFirstColumn%>";
//XSSOK
var NONE_LABEL = "<%=noneLabel%>";
//XSSOK
var TABLE_NAME_LENGTH = "<%=tableNameLength%>";
//XSSOK
var FREEZE_PANE_COLUMN = "<%=freezePaneColumn%>";
</script>
