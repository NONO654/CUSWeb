 <%-- emxToolbarJavaScript.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxToolbarJavaScript.jsp.rca 1.34.2.1 Fri Nov  7 09:42:24 2008 ds-kvenkanna Experimental $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%@page import="javax.json.*"%>


<% request.setAttribute("useScriptTags", "false"); %>
<%@include file = "emxToolbarInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.DateUtil,com.matrixone.apps.domain.util.FrameworkLicenseUtil,com.matrixone.apps.domain.util.eMatrixDateFormat,java.util.Locale,com.matrixone.apps.framework.ui.UIUtil"%>
<%@ page import = "com.matrixone.apps.domain.* " %>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean"	class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>
<%!
  // Added for Bug : 347729
  // gets parameter from the requestMap
  //
  static public String emxGetParameter(HashMap requestMap, String parameter) throws Exception
  {
       String value = (String) requestMap.get(parameter);
       return ((value != null) ? value.trim() : null);
  }
%>
<%
out.clear();

String timeStamp 	 	= emxGetParameter(request, "timeStamp");
String uiType    	 	= emxGetParameter(request, "uiType");
String hasAutoFilter 	= emxGetParameter(request, "AutoFilter");
String rowBuffer     	= emxGetParameter(request, "rowBuffer");
String isLayoutRequest  = emxGetParameter(request, "isLayoutRequest");
String defaultSearch  = emxGetParameter(request, "defaultSearch");
String parentOID        = emxGetParameter(request, "parentOID");
String logPerformance 	= emxGetParameter(request, "logPerformance");
String showMenuItemInToolBar = emxGetParameter(request, "showmenuinToolbar");
long totalTimeToolbar = 0L;
boolean isLoggingEnabled = false;
if(UIUtil.isNotNullAndNotEmpty(logPerformance) && "true".equalsIgnoreCase(logPerformance)) {
	isLoggingEnabled = true;
	totalTimeToolbar = System.currentTimeMillis();
}
String targetLocn=emxGetParameter(request,"targetLocation");

boolean isUserTable = false;
String inlineIcons = "";
String treeLabel = "";
HashMap requestMap   	= new HashMap();
String isStructCompare  = emxGetParameter(request, "IsStructureCompare");
if("true".equalsIgnoreCase(isStructCompare)){
	indentedTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;
}

if("structureBrowser".equalsIgnoreCase(uiType) && timeStamp != null && "true".equals(isLayoutRequest)){
    requestMap = indentedTableBean.getRequestMap(timeStamp);
    isUserTable = ((Boolean)requestMap.get("userTable")).booleanValue();
	inlineIcons = (String)requestMap.get("inlineIcons");
	treeLabel = (String)requestMap.get("treeLabel");
    requestMap.put("timeStamp",timeStamp);
    requestMap.put("uiType",uiType);
    requestMap.put("hasAutoFilter",hasAutoFilter);
    requestMap.put("rowBuffer",rowBuffer);
    requestMap.put("IsStructureCompare",isStructCompare);
    if(UIUtil.isNullOrEmpty(treeLabel)) {
    requestMap.put("treeLabel","");
    }
    if(UIUtil.isNullOrEmpty((String)requestMap.get("parentOID"))){
        requestMap.put("parentOID",parentOID);	
    }
}

/* Commented to fix IR-025050V6R2011
else if ("table".equals(uiType)) {
	HashMap temprequestMap = tableBean.getRequestMap(timeStamp);
	requestMap.putAll(temprequestMap);
}*/

else{
    requestMap =  UINavigatorUtil.getRequestParameterMap(request,session);
    treeLabel = (String)requestMap.get("treeLabel");
    if(!UIUtil.isNullOrEmpty(uiType) && UIUtil.isNullOrEmpty(treeLabel)) {
    requestMap.put("treeLabel","");
 	}
}
if ("table".equals(uiType) && timeStamp != null) {
	HashMap temprequestMap = tableBean.getRequestMap(timeStamp);
	String category = (String)temprequestMap.get("category");
	requestMap.put("category",category);
}
response.setContentType("text/javascript;");
%>

var mode = true;
if((typeof editableTable) == "object"){
    mode = false;
}

var objMainToolbar = null;
var objContextToolbar = null;
var strUIType = "<xss:encodeForJavaScript><%=uiType%></xss:encodeForJavaScript>";
var strTimeStamp = "<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>";

objMainToolbar = new emxUIToolbar(mode,"main");
objContextToolbar = new emxUIToolbar(mode,"context");


var src=null;

var contentFrame=findFrame(getTopWindow(),"emxUITreeFrame");
var targetLocation="<xss:encodeForJavaScript><%=targetLocn%></xss:encodeForJavaScript>";
if(contentFrame != null) {
src=contentFrame.frameElement.src;
}


 
objMainToolbar.setWidth(0.8);
objContextToolbar.setWidth(0.8);
objMainToolbar.setMaxLabelChars(<%=defaultLength%>);
objContextToolbar.setMaxLabelChars(<%=defaultLength%>);
var objOrigMenu;
var objMenu;
var objStack = new Array;
 //Added to support Structure Browser - Edit Mode Toolbar
var tempMenuItem;

//This is the Default Menu which contains all the lesser used toolbar items
var toolsMenu = new emxUIToolbarMenu();

var addToMenu ="false";
<%
String IsStructureCompare = emxGetParameter(requestMap, "IsStructureCompare");
String transactionType    = emxGetParameter(requestMap, "TransactionType");
String genericDelete 	= emxGetParameter(requestMap, "genericDelete");
boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));
String sCode="";
StringList sCodeList=new StringList();
String isImageManager 	= emxGetParameter(requestMap, "isImageManager");
Vector userRoleList = PersonUtil.getAssignments(context);
String stToolbar = emxGetParameter(requestMap, "toolbar");
//added for FullSearch Begin
String fullTextSearch = emxGetParameter(requestMap, "fullTextSearch");
boolean isFullSearchToolbar = false;
if((stToolbar == null || "".equals(stToolbar)) && fullTextSearch != null && "true".equalsIgnoreCase(fullTextSearch)) {
    stToolbar = "AEFFullSearchMenu";
    isFullSearchToolbar = true;
}
//added for FullSearch End
boolean hasAnyFilters = requestMap.containsKey("tableMenu") || requestMap.containsKey("expandProgramMenu");
boolean nonObjBasedSB =  requestMap.containsKey("hideCustomViewCommand");
String portalMode = emxGetParameter(requestMap, "portalMode");
String hideLaunchButton = emxGetParameter(requestMap, "hideLaunchButton");
String language = request.getHeader("Accept-Language");
String customize = emxGetParameter(requestMap,"customize");
//Trigger Validation Report
String strTriggerValidation = emxGetParameter(requestMap,"triggerValidation");
//Mass Promote Demote
//Added for Bug 338536
String customExpandLevelMenu = "";
String customExpandFilterToolbar = "";
boolean useCustomExpandFilter = false;
String massPromoteDemoteEnable = "";
String selection = emxGetParameter(requestMap, "selection");
String massPromoteDemote = emxGetParameter(requestMap,"massPromoteDemote");
boolean showMassPromote  = true;
if("TRUE".equalsIgnoreCase(IsStructureCompare)){
	massPromoteDemote = "false";
}
if ("false".equals(massPromoteDemote))
{
    showMassPromote = false;
}
else if ("true".equals(massPromoteDemote))
{
    showMassPromote = true;
}
else
{
    	try{
    		massPromoteDemoteEnable = EnoviaResourceBundle.getProperty(context, "emxFramework.Lifecycle.MassPromoteDemote.Enable");
    	}catch(Exception e){
    	    showMassPromote = true;
    	}

    	if ("false".equals(massPromoteDemoteEnable))
    	{
    	    showMassPromote = false;
    	}
    	else if ("true".equals(massPromoteDemoteEnable))
    	{
    	    showMassPromote = true;
    	}


}

StringList columnNames = new StringList();
//Mass Promote Demote ends
String objectId = emxGetParameter(requestMap, "objectId");
String findMxLink = emxGetParameter(requestMap, "findMxLink");
String relId = emxGetParameter(requestMap, "relId");
String sPrinterFriendly = emxGetParameter(requestMap, "PrinterFriendly");
String sPageURL = emxGetParameter(requestMap, "showPageURLIcon");
String submitMethod = emxGetParameter(requestMap, "submitMethod");

HashMap tableData=null;
MapList tableColumns=null;
HashMap columnSettings =null;
Boolean isDraggable =  false;

if (sPrinterFriendly == null || sPrinterFriendly.trim().length() == 0 ) {
    sPrinterFriendly = emxGetParameter(requestMap, "printerFriendly");
}

String tipPage = emxGetParameter(requestMap,"TipPage");
String validMenuName="";
if (tipPage == null || tipPage.trim().length() == 0) {
    tipPage = emxGetParameter(requestMap,"tipPage");
}
String mode = emxGetParameter(requestMap, "mode");
String targetLocation = emxGetParameter(requestMap, "targetLocation");

 if (mode == null)
 {

     mode = "";

 }
 if (targetLocation == null)
 {
	 targetLocation = "";
 }

String showClipboard = "false";
String topActionbar = emxGetParameter(requestMap, "topActionbar");
String bottomActionbar = emxGetParameter(requestMap, "bottomActionbar");

String preProcessJPO = emxGetParameter(requestMap, "preProcessJPO");
String preProcessURL = emxGetParameter(requestMap, "preProcessURL");
String postProcessJPO = emxGetParameter(requestMap, "postProcessJPO");
String postProcessURL = emxGetParameter(requestMap, "postProcessURL");
String preProcessJavaScript = emxGetParameter(requestMap, "preProcessJavaScript");

String cancelProcessJPO = emxGetParameter(requestMap, "cancelProcessJPO");
String cancelProcessURL = emxGetParameter(requestMap, "cancelProcessURL");

if (topActionbar == null)
{
    topActionbar = "";
}

if (bottomActionbar == null)
{
    bottomActionbar = "";
}
boolean isToolbarPassedIn = (stToolbar == null || stToolbar.trim().length() == 0) ? false : true;
boolean isCustomTBPassedIn = false;
if(isToolbarPassedIn){
	isCustomTBPassedIn = stToolbar.indexOf(",") != -1 ? true : false;
}
boolean isActionbarPassedIn = (topActionbar.trim().length() == 0 && bottomActionbar.trim().length() == 0) ? false : true;

String export = emxGetParameter(requestMap, "Export");
if (export == null || export.trim().length() == 0) {
    export = emxGetParameter(requestMap, "export");
}

String disableSorting = emxGetParameter(requestMap,"disableSorting");
if(disableSorting == null || disableSorting.trim().length() == 0){
    disableSorting = "false";
}
String multiColumnSort=emxGetParameter(requestMap,"multiColumnSort");
if (multiColumnSort == null || multiColumnSort.trim().length() == 0) {
    multiColumnSort = emxGetParameter(requestMap, "MultiColumnSort");
  }

String rowGrouping=emxGetParameter(requestMap,"rowGrouping");
if (rowGrouping == null || rowGrouping.trim().length() == 0) {
    rowGrouping = "true";
}  
//For IR-064590V6R2011x

boolean doCheckEnablingMultiSort = multiColumnSort == null || "".equals(multiColumnSort) || "true".equalsIgnoreCase(multiColumnSort) || (multiColumnSort.trim().length()==0) && (!("true".equalsIgnoreCase(disableSorting)));
if("true".equalsIgnoreCase(disableSorting)){
	doCheckEnablingMultiSort = false;
}
int iSortColCount=0;

String navButton = null; 
if("table".equals(uiType)){
	tableData = tableBean.getTableData(timeStamp);
	tableColumns = tableBean.getColumns(timeStamp);
	HashMap tableRequestMap = tableBean.getRequestMap(tableData);
	navButton = (String)tableRequestMap.get("navButton");
    isUserTable = ((Boolean)tableRequestMap.get("userTable")).booleanValue();
	for(int i=0;i<tableColumns.size();i++)
	{
		columnSettings = (HashMap)tableColumns.get(i);
	
		if(doCheckEnablingMultiSort && !"false".equalsIgnoreCase((String)((HashMap)columnSettings.get("settings")).get("Sortable"))) {
			iSortColCount++;
		}

		//String columnName = (String)columnSettings.get("name");
		//Modified for bug 345045
		String columnName = (String)columnSettings.get("expression_businessobject");
		columnNames.add(columnName);
	}

}

if("structureBrowser".equals(uiType) && !"TRUE".equalsIgnoreCase(IsStructureCompare)){
	tableData = indentedTableBean.getTableData(timeStamp);
	tableColumns = indentedTableBean.getColumns(timeStamp);
	for(int i=0;i<tableColumns.size();i++){
		columnSettings = (HashMap)tableColumns.get(i);
		
		if(doCheckEnablingMultiSort && !"false".equalsIgnoreCase((String)((HashMap)columnSettings.get("settings")).get("Sortable"))) {
            iSortColCount++;
        }
		String draggable = (String)((HashMap)columnSettings.get("settings")).get("Draggable");
		if (draggable != null && "true".equalsIgnoreCase(draggable)) {
			isDraggable = true;
		}
	
		//String columnName = (String)columnSettings.get("name");
		//Modified for bug 345045
		String columnName = (String)columnSettings.get("expression_businessobject");
		columnNames.add(columnName);
	}
}

//for IR-064801V6R2011x
multiColumnSort = (iSortColCount>1) ? "true" : "false";

String showChartOptions = emxGetParameter(requestMap, "showChartOptions");
String showTableCalcOptions = emxGetParameter(requestMap, "showTableCalcOptions");
String calculations = emxGetParameter(requestMap,"calculations");
if ("false".equalsIgnoreCase(calculations)){
    showTableCalcOptions = "false";
}
String sHelpMarker = emxGetParameter(requestMap, "HelpMarker");
if (sHelpMarker == null || sHelpMarker.trim().length() == 0) {
    sHelpMarker = emxGetParameter(requestMap, "helpMarker");
}
String suiteKey = emxGetParameter(requestMap, "suiteKey");
String header = emxGetParameter(requestMap, "header");
String formHeader = emxGetParameter(requestMap, "formHeader");
String editLink = emxGetParameter(requestMap, "editLink");
String form = emxGetParameter(requestMap, "form");
//modified for IR-028606V6R2011
String appendFields = emxGetParameter(requestMap, "appendFields");
    String strStringResourceFile = "emxFrameworkStringResource";

// backwards compatibility fix
String suiteDirParam = emxGetParameter(requestMap, "suiteDir");

String suiteDir = "";
if ((suiteKey != null) && (suiteKey.trim().length() > 0))
{
    suiteDir = UINavigatorUtil.getRegisteredDirectory(context,suiteKey);
        strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
}

if (suiteDir == null || "".equals(suiteDir))
{
    suiteDir = suiteDirParam;
}
    try
    {
        ContextUtil.startTransaction(context, false);

//String resource IDs
String strEdit = UINavigatorUtil.getI18nString("emxFramework.TableEdit.Edit",
                                               "emxFrameworkStringResource", language);
//added for bug :345105
String strMode = UINavigatorUtil.getI18nString("emxFramework.TableEdit.Mode","emxFrameworkStringResource", language);
String strEnableEdit = UINavigatorUtil.getI18nString("emxFramework.TableEdit.Enable_Edit","emxFrameworkStringResource", language);

String strHelp = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Help",
                                               "emxFrameworkStringResource", language);
String strPrinter = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Print",
                                                  "emxFrameworkStringResource", language);
//PageURL
String strPageURL = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.PageURL",
                                                  "emxFrameworkStringResource", language);
String strExport = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Export",
                                                 "emxFrameworkStringResource", language);
String strMultiColumnSort= UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.MultiColumnSort",
                                                     "emxFrameworkStringResource", language);
String strRowGrouping= UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.RowGrouping",
                                                     "emxFrameworkStringResource", language);
//modified for bug 344215
String strMassPromote = UINavigatorUtil.getI18nString("emxFramework.Common.MassPromote",
                                                          "emxFrameworkStringResource", language);
String strMassDemote = UINavigatorUtil.getI18nString("emxFramework.Common.MassDemote",
                                                     "emxFrameworkStringResource",language);
String strTriggerValidationToolTip = UINavigatorUtil.getI18nString("emxFramework.Command.Tooltip.TriggerValidation",
        "emxFrameworkStringResource",language);

String errorLabel = UINavigatorUtil.getI18nString("emxFramework.Toolbar.ConfigurationError",
                                                  "emxFrameworkStringResource", language);

String strLaunch = UINavigatorUtil.getI18nString("emxFramework.Toolbar.Launch",
                                                  "emxFrameworkStringResource", language);
String strChartOptions = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.ChartOptions",
                                                 "emxFrameworkStringResource", language);
String strTableCalcOptions = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.TableCalcOptions",
                                                "emxFrameworkStringResource", language);
String strDisplayMode = UINavigatorUtil.getI18nString("emxFramework.DisplayMode.Tooltip",
        "emxFrameworkStringResource", language);
String strDisplayThumbnail = UINavigatorUtil.getI18nString("emxFramework.DisplayMode.Thumbnail",
        "emxFrameworkStringResource", language);
String strDisplayTree = UINavigatorUtil.getI18nString("emxFramework.DisplayMode.Tree",
        "emxFrameworkStringResource", language);
String strDisplayDetails = UINavigatorUtil.getI18nString("emxFramework.DisplayMode.Details",
        "emxFrameworkStringResource", language);
String strNavigatorClose = UINavigatorUtil.getI18nString("emxFramework.StructureNavigator.Close",
		"emxFrameworkStringResource", request.getHeader("Accept-Language"));
String strNavigatorOpen = UINavigatorUtil.getI18nString("emxFramework.StructureNavigator.Open",
		"emxFrameworkStringResource", request.getHeader("Accept-Language"));
String strNavigatorCloseFTS = UINavigatorUtil.getI18nString("emxFramework.StructureNavigatorFTS.Close",
		"emxFrameworkStringResource", request.getHeader("Accept-Language"));

String strTools = UINavigatorUtil.getI18nString("emxFramework.Menu.Tools",
        "emxFrameworkStringResource", language);


String displayModeWrap = UINavigatorUtil.getI18nString("emxFramework.DisplayMode.Wrap","emxFrameworkStringResource", language);
String displayModeUnWrap = UINavigatorUtil.getI18nString("emxFramework.DisplayMode.UnWrap","emxFrameworkStringResource", language);

String displayModeCopy = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.DisplayMode.Copy");
String displayModeMove = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.DisplayMode.Move");

//check user for CPF license

Boolean bCpfUser = (Boolean)session.getAttribute("isCPFUser");
boolean cpfUser = false;
if(bCpfUser !=null)
{
	cpfUser = bCpfUser.booleanValue();
}
else
{
try {
		FrameworkLicenseUtil.checkLicenseReserved(context, "ENO_BPS_TP");
    cpfUser = true;
	}catch(Exception e)
{
    cpfUser = false;
		}
}

if (!cpfUser)
{
    showMassPromote = false;
    strTriggerValidation = "false";
    editLink = "false";    
}
        
String sSBDisplayView   = emxGetParameter(requestMap, "displayView");
//  PDF Rendering to Form Component Begin
boolean showRenderPDFIcon=false;
boolean useAdlibSetup=false;
boolean showRenderPDFIconSB=false;
boolean showRenderPDFIconFT=false;
String sRenderPDF = emxGetParameter(requestMap, "renderPDF");
String renderSoftwareInstalled = EnoviaResourceBundle.getProperty(context, "emxFramework.RenderPDF");
String strIsApplet = EnoviaResourceBundle.getProperty(context, "emxFramework.UseApplet");
String renderShowIconByDefault=EnoviaResourceBundle.getProperty(context, "emxFramework.RenderPDF.ShowIconByDefault");
String strRenderPDF = UINavigatorUtil.getI18nString("emxFramework.RenderPDF.Tooltip","emxFrameworkStringResource", language);

if(renderSoftwareInstalled==null || "null".equals(renderSoftwareInstalled) || renderSoftwareInstalled.length()==0 ) {
    renderSoftwareInstalled="false";
}

if(renderShowIconByDefault==null || "null".equals(renderShowIconByDefault) || renderShowIconByDefault.length()==0 || "false".equalsIgnoreCase(sRenderPDF)||(UINavigatorUtil.isMobile(context))) {
    renderShowIconByDefault="false";
}

if ("true".equalsIgnoreCase(sRenderPDF))
{
    renderShowIconByDefault="true";
    showRenderPDFIconSB=true;
}

if ( "true".equalsIgnoreCase(renderSoftwareInstalled) && "true".equalsIgnoreCase(renderShowIconByDefault) )
{
    showRenderPDFIcon=true;
    showRenderPDFIconFT=true;
    showRenderPDFIconSB=true;
    useAdlibSetup=true;
}else if( "false".equalsIgnoreCase(renderSoftwareInstalled) && "true".equalsIgnoreCase(renderShowIconByDefault)){
	
	 showRenderPDFIcon=true;
	 showRenderPDFIconSB=true;
}

// for displaying PDF Rendering icon only on form component.
//if(form ==null || "null".equals(form) || form.length()==0)
if(!"form".equalsIgnoreCase(uiType) || ("create".equalsIgnoreCase(mode)))
{
  showRenderPDFIcon=false;
}

if(!"structureBrowser".equalsIgnoreCase(uiType))
{
  showRenderPDFIconSB=false;
}

if(!"table".equalsIgnoreCase(uiType))
{
  showRenderPDFIconFT=false;
}

String pageURL = request.getRequestURL().toString();
if(!UIUtil.isNullOrEmpty(pageURL) && pageURL.indexOf("emxForm.jsp")==-1 && pageURL.indexOf("emxIndentedTable.jsp")==-1)
{
	showRenderPDFIcon=false;
	showRenderPDFIconSB=false;
	showRenderPDFIconFT=false;
}

if(!UIUtil.isNullOrEmpty(pageURL) && pageURL.indexOf("emxForm.jsp")>-1 )
{
	if("edit".equalsIgnoreCase(mode) || (UIUtil.isNotNullAndNotEmpty(form) && "AEFDynamicAttributesForm".equals(form)))
	{	
		showRenderPDFIcon=false;
		showRenderPDFIconFT=false;
	}
}

//added for FullSearch Begin
String firstTimeFormBased = emxGetParameter(requestMap, "firstTimeFormBased");
String allowSwitch = emxGetParameter(requestMap, "allowSwitch");
if(allowSwitch == null || "".equals(allowSwitch)) {
	allowSwitch = EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.AllowModeSwitch");
}
String searchCollectionEnabled = emxGetParameter(requestMap, "searchCollectionEnabled");
String showSavedQuery = emxGetParameter(requestMap, "showSavedQuery");
String submitURL = emxGetParameter(requestMap, "submitURL");
MapList fullSearchChildrenList = null;
if (fullTextSearch != null && "true".equalsIgnoreCase(fullTextSearch)){
    HashMap fullSearchMenuMap = UIToolbar.getToolbar(context,
                                         "AEFFullSearchMenu",
                                          userRoleList,
                                          objectId,
                                          requestMap,
                                          language);
    fullSearchChildrenList = UIToolbar.getChildren(fullSearchMenuMap);
    if(fullSearchChildrenList != null){
        Iterator itr = fullSearchChildrenList.iterator();
            while(itr.hasNext()){
            HashMap fullSearchChild = (HashMap)itr.next();
            String commandName = (String)fullSearchChild.get("name");
            boolean addFullSearchToggle = (UISearchUtil.isAutonomySearch(context, requestMap) && "true".equalsIgnoreCase(allowSwitch));
            
            if(commandName != null && "AEFFullSearchView".equalsIgnoreCase(commandName) && !UISearchUtil.isAutonomySearch(context, requestMap)){
				itr.remove();				
            }
            if(commandName != null && "AEFFullSearchToggle".equalsIgnoreCase(commandName)){
				if("false".equalsIgnoreCase(emxGetParameter(requestMap, "switchedNavMode"))){
				    itr.remove();
				}
				else if(!"true".equalsIgnoreCase(emxGetParameter(requestMap, "switchedNavMode"))){
	                 if(!addFullSearchToggle){
	                    itr.remove();
	                }
				}
            }
            else if(commandName != null && "AEFFullSearchCollection".equalsIgnoreCase(commandName)){
                if(searchCollectionEnabled != null && "false".equalsIgnoreCase(searchCollectionEnabled)){
                    itr.remove();
                }
            }
            else if(commandName != null && "AEFFullSearchSave".equalsIgnoreCase(commandName)){
                if(showSavedQuery != null && "false".equalsIgnoreCase(showSavedQuery)){
                    itr.remove();
                }
            }
		    else if(commandName != null && "AEFGenericDelete".equalsIgnoreCase(commandName)){
		    	if(genericDelete == null || !"true".equalsIgnoreCase(genericDelete)){
					itr.remove();
		    	}
			}
        }
    }
}
//added for FullSearch End
  %>
var portalMode  = "<xss:encodeForJavaScript><%=portalMode%></xss:encodeForJavaScript>";
var navButton = "<xss:encodeForJavaScript><%=navButton%></xss:encodeForJavaScript>";

 var button;
 var src=null;
 <!-- //XSSOK -->
 var navigatorOpen="<%=strNavigatorOpen%>";
 <!-- //XSSOK -->
 var navigatorClose="<%=strNavigatorClose%>";
 if(getTopWindow().StructureNavigator) {
 button=getTopWindow().StructureNavigator.getCurrButton();
 }
 var contentFrame=findFrame(getTopWindow(),"emxUITreeFrame");
 var targetLocation="<xss:encodeForJavaScript><%=targetLocn%></xss:encodeForJavaScript>";
 if(contentFrame != null) {
 src=contentFrame.frameElement.src;
 }
 
 var navMode = "<xss:encodeForJavaScript><%=mode%></xss:encodeForJavaScript>";


if(contentFrame != null && targetLocation != "slidein" &&  src != null && portalMode!="true" ) {
  if(( src.indexOf("emxBlank.jsp")<0 && src.indexOf("about:blank")<0 ) && button == navigatorClose && navMode != "insert" && navButton != "false"){
       <!-- //XSSOK -->
       var contlrButton = new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionClosePanel.gif","<%=strNavigatorClose%>", "javascript:closeStructureNavigatorFrame()");
       objMainToolbar.addItem(contlrButton);
       contlrButton.setViewMode("detail"); contlrButton.enabled = true;
    } else if(( src.indexOf("emxBlank.jsp")<0 && src.indexOf("about:blank")<0 ) && button == navigatorOpen) {
      <!-- //XSSOK -->
      var contlrButton = new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionOpenPanel.gif","<%=strNavigatorOpen%>", "javascript:openStructureNavigatorFrame()");
      objMainToolbar.addItem(contlrButton);
      contlrButton.setViewMode("detail"); contlrButton.enabled = true;
       closeFrame();
    } else if(( src.indexOf("emxBlank.jsp")<0 && src.indexOf("about:blank")<0 ) && button == navigatorClose &&  navMode != null && navMode == "insert") {
      <!-- //XSSOK -->
      var contlrButton = new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionClosePanel.gif","<%=strNavigatorClose%>", "javascript:closeStructureNavigatorFrame()");
       objMainToolbar.addItem(contlrButton);
       contlrButton.setViewMode("detail"); contlrButton.enabled = true;
       openFrame();
    } 
 }
 

 	<%
 	if("true".equalsIgnoreCase(fullTextSearch)){	%> 
			<!-- //XSSOK -->
			var contlrButton = new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionClosePanel.gif","<%=strNavigatorCloseFTS%>", "javascript:closeorOpenRefinments()");
       		objMainToolbar.addItem(contlrButton);       	 
       		contlrButton.enabled = true;         
   <%} %>    

 <%

// Pdf Rendering End
    StringList toolbarList=new StringList();
    if (isToolbarPassedIn){
        toolbarList = FrameworkUtil.split(stToolbar,",");
        if("false".equalsIgnoreCase(fullTextSearch)){ //Auto Filter in SlideIn, not applicabe for Search as it allready has a SlideIn panal 
        	// To create the JSON for the custom toolbar passed in other than the 1st toolbar
            JsonArrayBuilder toolbarJsonArrBuilder  = Json.createArrayBuilder();
            
            for(int itr=1;itr<toolbarList.size();itr++) {
            	JsonArray objectJsonArr  = null;
            	JsonObjectBuilder toolbarJson = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
            	String custToolbar=(String)toolbarList.get(itr);
            	JsonArray collectioArr = UIToolbar.getCustomToolbarJson(context,objectId, custToolbar, userRoleList, requestMap, language, objectJsonArr);
            	toolbarJson.add("name",custToolbar);
            	toolbarJson.add("items",collectioArr);   
            	toolbarJsonArrBuilder.add(toolbarJson.build());
            }
            
           %>
           	var custToolbarJson = '<%=XSSUtil.encodeForJavaScript(context, toolbarJsonArrBuilder.build().toString())%>';
			initCustomToolbar(custToolbarJson);
           <%	
        }
    }else if (!"".equals(topActionbar)) {
        toolbarList = FrameworkUtil.split(topActionbar,",");
    }else if (!"".equals(bottomActionbar)){
        toolbarList = FrameworkUtil.split(bottomActionbar,",");
    }

    for(int itr=0;itr<toolbarList.size();itr++)
    {
        /*
        Configuring more than one menu for toolbar URL parameter is supported only for structure browser.
        So following if condition is added to come out of the loop if the component is not structure browser.
        */
         //Modified for Form Custom Filter Bar
        if(itr > 0 && !"structureBrowser".equals(uiType) && !"form".equals(uiType)) {
            break;
        }

        String currToolbar = "";
        String strToolbar = "";
        //Added to Support Structure Browser - Edit Mode Toolbar
        String  currToolbarMode = "";
        String currToolbarDisplayMode ="";
        String expanded="";

        currToolbar=(String)toolbarList.get(itr);
        strToolbar = getJSVariableName(currToolbar);
        String jsstrToolbar = XSSUtil.encodeForJavaScript(context,strToolbar);
        if (itr>0){

            String str = currToolbar.replaceAll("\\W","_");
            validMenuName=str.equals(strToolbar) ? "true" : "false";

            if ("true".equals(validMenuName)) {
            %>
		        var <%=jsstrToolbar%>=null;
		        <%=jsstrToolbar%> = new emxUIToolbar(mode,"<%=currToolbar%>");
		        <%=jsstrToolbar%>.setWidth(0.95);
		    <%
            }else{
                continue;
            }
        }
        else
        {
        %>
	        var <%=jsstrToolbar%>=null;
	        <%=jsstrToolbar%> = new emxUIToolbar(mode,"<xss:encodeForJavaScript><%=currToolbar%></xss:encodeForJavaScript>");
	    <%
        }

     // The parameter isFSToolbar is passed from Frameset object while passing the dynamic toolbar
     // As the dynamic commands and menus are maintained in a separate cache is Frameset object 
     // so this paramer will indicate whether to read the command/menus from framesetObject cache 
     // or from Cachemanager
     // XSSOK
     String isFSToolbar = emxGetParameter(requestMap, "isFSToolbar");
     isFSToolbar = "true".equalsIgnoreCase(isFSToolbar)? isFSToolbar : "false";
     
if (isToolbarPassedIn || isActionbarPassedIn)
{

        HashMap toolbar;

        if (isToolbarPassedIn)
        {
            toolbar = UIToolbar.getToolbar(context,
                                                         currToolbar,
                                          userRoleList,
                                          objectId,
                                          requestMap,
                                          language,
                                          isFSToolbar);
             //To set Mode on Toolbar[Added to support Structure Browser - Edit Mode Toolbar]
             if(toolbar!=null){
           		currToolbarMode = UIToolbar.getSetting(toolbar,"Mode");
           		currToolbarDisplayMode = UIToolbar.getSetting(toolbar,"Display View");
           		expanded = UIToolbar.getSetting(toolbar,"Expanded");
             }
             %>
                <%=XSSUtil.encodeForHTML(context,strToolbar)%>.setMode("<xss:encodeForJavaScript><%=currToolbarMode %></xss:encodeForJavaScript>");
             <%=XSSUtil.encodeForHTML(context,strToolbar)%>.setDisplayMode("<xss:encodeForJavaScript><%=currToolbarDisplayMode %></xss:encodeForJavaScript>");
             <%=XSSUtil.encodeForHTML(context,strToolbar)%>.setExpanded("<xss:encodeForJavaScript><%=expanded %></xss:encodeForJavaScript>");
             <%=XSSUtil.encodeForHTML(context,strToolbar)%>.displayMode=<%=XSSUtil.encodeForHTML(context,strToolbar)%>.getDisplayMode();
             <%=XSSUtil.encodeForHTML(context,strToolbar)%>.expanded=<%=XSSUtil.encodeForHTML(context,strToolbar)%>.getExpanded();
             <%

        }
        else
        {
            toolbar = UIToolbar.getToolbar(context,
                                          topActionbar,
                                          bottomActionbar,
                                          userRoleList,
                                          objectId,
                                          requestMap,
                                          language);
        }


        if (toolbar != null)
        {
            MapList children = UIToolbar.getChildren(toolbar);
			String horizontalIcons = "false";
            //Added for IR-102268V6R2012x : Begin, To remove save button in saved search toolbar
           if(children != null){
	        		Iterator itr1 = children.iterator();
	        		while(itr1.hasNext()){
	            		HashMap saveSearchChild = (HashMap)itr1.next();
	            		String cmdName = (String)saveSearchChild.get("name");
	            		if(cmdName != null && "AEFSaveSearch".equalsIgnoreCase(cmdName)&& defaultSearch != null && "AEFSavedSearches".equals(defaultSearch)){
	                		itr1.remove();
	            		}
	            	}
	       		}
           //Added for IR-102268V6R2012x : End


            //added for FullSearch Begin
            if (fullTextSearch != null && "true".equalsIgnoreCase(fullTextSearch) && itr == 0){
                if(isFullSearchToolbar){
                    children = fullSearchChildrenList;
                 }
                 else{
                    children.addAll(fullSearchChildrenList);
                 }
            }

            if (fullTextSearch != null && "true".equalsIgnoreCase(fullTextSearch) && UISearchUtil.isAutonomySearch(context, requestMap)){
                HashMap fullSearchModeMap = UIToolbar.getToolbar(context, "AEFFullSearchView", userRoleList,objectId,requestMap,language);
                
                if(fullSearchModeMap!=null)
    			{
					fullSearchModeMap.put(UICache.ALT, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(language), UINavigatorUtil.htmlEncode(UIComponent.getAlt(fullSearchModeMap))));
           			%>
           			<!-- //XSSOK -->
            		<%=loadToolbar(context, fullSearchModeMap, requestMap, 0, errorLabel, false)%>
            		<%	
    			}	
            }
              
            //added for FullSearch End
            if (children != null)
            {
                    boolean canPivot = false;
                    //Check if the pivot functionality is enabled and can be
                    //applied to this menu
                    canPivot = canPivotCommands(toolbar);
					if(!UIUtil.isNotNullAndNotEmpty(showMenuItemInToolBar) || !"true".equalsIgnoreCase(showMenuItemInToolBar)){
						horizontalIcons = UIToolbar.getSetting(toolbar,"Horizontal ToolBar");
						if("false".equalsIgnoreCase(showMenuItemInToolBar)){
							horizontalIcons = "true" ;
						}
					}
                    matrix.util.StringList duplicateCommandLabels = null;
                    matrix.util.StringList toolbarCommandNms = null;
                  
                    if(canPivot || "true".equalsIgnoreCase(horizontalIcons) ){
                        //Getting the list of labels of commands which are having the same labels
                        duplicateCommandLabels = getDuplicateCommandLabels(context,toolbar,null,null);
                        //Getting the list of toolbar command
                        MapList toolBarCommands = UIMenu.getOnlyCommands(context,
                                                                        UIComponent.getName(toolbar),
                                                                        userRoleList,
                                                                        language);
                        //Getting the list of command names present directly under the toolbar
                        toolbarCommandNms = new matrix.util.StringList();
                        if(toolBarCommands != null){
                            HashMap cmd = null;
                            for (int j = 0; j < toolBarCommands.size(); j++){
                                cmd = (HashMap) toolBarCommands.get(j);
                                toolbarCommandNms.add(UIComponent.getName(cmd));
                            }
                        }
                    }

                boolean bPrevItmIsSeparator = false;
                for (int i = 0; i < children.size(); i++)
                {
                    HashMap child = (HashMap) children.get(i);
                    String isExpandFilterMenu = UIToolbar.getSetting(child,"Expand Menu");

                    if( i != 0 && UIToolbar.isSeparator((HashMap) children.get(i-1)) ) {
                        bPrevItmIsSeparator = true;
                    } else {
                        bPrevItmIsSeparator = false;
                    }
                    //if the first item to display is a separator, skip it
                    if (i == 0 && UIToolbar.isSeparator(child))
                    {
                        continue;
                    }
                    
                    // To declare the variables if scommandcode is not null                    
                    if(itr > 0 && "structureBrowser".equalsIgnoreCase(uiType)){
                    	String sCommandCode = getValue(child, "code");
                    	String itemName = UIToolbar.getName(child);
                    	String varName = getJSVariableName(itemName);
                    	if(UIUtil.isNotNullAndNotEmpty(varName)){
                    		varName=varName+"mxcommandcode";
                    	}
                        if(sCommandCode == null){
                            sCommandCode = "";
                        }
						boolean isCommandExists = true;
						if(UIUtil.isNullOrEmpty(sCommandCode)){
							isCommandExists = false;
						}
                        %>
						if(<%=isCommandExists%>) {
                        var <%=varName%> = eval(<%=sCommandCode%>);
						}
                    	<%
                    }
                    
                    
                      //Added for Toolbar enhancements - Begin
                      String javascriptInclude="";
                       String commandFormat="";
                    if(UIToolbar.isMenu(child))
                    {
                        if(!"true".equalsIgnoreCase(isExpandFilterMenu))
                    	{
	                        //If Menu has a Javascript Include setting, include the jsp or js file in the toolbar
	                        javascriptInclude=   UINavigatorUtil.parseHREF(context,UIToolbar.getSetting(child,"JavaScript Include"),UIToolbar.getSetting(child,"Registered Suite"));
	                        if(javascriptInclude!=null && !"".equals(javascriptInclude))
	                        {
%>
                            <jsp:include page ="<%=javascriptInclude%>" flush="true" />
<%
                             javascriptInclude=""; // If command doesnt have Javascript Include setting, then the same file shouldn't  be included again.
	                        }
	                        MapList menuChildren = UIToolbar.getChildren(child);
	                        if(menuChildren != null)
	                        {
	                            HashMap component = null;
	                            for (int j = 0; j < menuChildren.size(); j++)
	                            {
	                                component = (HashMap) menuChildren.get(j);
	                                javascriptInclude =   UINavigatorUtil.parseHREF(context,UIToolbar.getSetting(component,"JavaScript Include"),UIToolbar.getSetting(component,"Registered Suite"));
	                                commandFormat = UIToolbar.getSetting(component,"format");
	                               if(javascriptInclude!=null && !"".equals(javascriptInclude))
	                                {
%>
                                    <!-- //XSSOK -->
                                    <jsp:include page = "<%=javascriptInclude%>" flush="true" />
<%
	                                }
	                            }
	                        }
	                    }else{
	                        if("structureBrowser".equalsIgnoreCase(uiType)){//Added for Bug 338536
		                        customExpandLevelMenu = UIComponent.getName(child);
		                        customExpandFilterToolbar = strToolbar;
		                        useCustomExpandFilter = true;
		                        }
	                        }
                    }
                    else
                    {
                            javascriptInclude=   UINavigatorUtil.parseHREF(context,UIToolbar.getSetting(child,"JavaScript Include"),UIToolbar.getSetting(child,"Registered Suite"));

                            commandFormat = UIToolbar.getSetting(child,"format");

                           if(javascriptInclude!=null && !"".equals(javascriptInclude))
                            {
%>
                                <!-- //XSSOK -->
                                <jsp:include page = "<%=javascriptInclude%>" flush="true" />
<%
                            }
                    }
                    //Added for Toolbar enhancements - End
                    //if the menu does not have any commands to display, don't display it
                    if (UIToolbar.isMenu(child))
                    {
                        if (isDisplayItem(child) == false)
                        {
                            continue;
                        }
                            //If the menu can be pivoted then call the loadMenuCommandsPivoted method
                            if(canPivot || "true".equalsIgnoreCase(horizontalIcons)) {
                                if(itr == 0){
                                    %>
                                    <!-- //XSSOK -->
                                    <%=loadMenuCommandsPivoted(context, child, requestMap, 0, errorLabel, false, new StringBuffer(UIToolbar.getLabel(child)),duplicateCommandLabels,toolbarCommandNms,bPrevItmIsSeparator,"objMainToolbar")%>
                                    <%
                                } else if("true".equalsIgnoreCase(fullTextSearch) || !"structureBrowser".equalsIgnoreCase(uiType)){ //Custom toolbars will remain in the toolbar container only, for Search and Non SB pages
                                    %>
                                    <!-- //XSSOK -->
                                    <%=loadMenuCommandsPivoted(context, child, requestMap, 0, errorLabel, false, new StringBuffer(UIToolbar.getLabel(child)),duplicateCommandLabels,toolbarCommandNms,bPrevItmIsSeparator,strToolbar)%>
                                    <%
                                }
                                continue;
                            }

                    }
                    if(!"true".equalsIgnoreCase(isExpandFilterMenu))
                    {
                    	if((canPivot || "true".equalsIgnoreCase(horizontalIcons)) && !UIToolbar.isSeparator(child)){
                    		if(itr == 0){

%>
<!-- //XSSOK -->
<%=loadToolbar(context, child, requestMap, 0, errorLabel, false, null, true)%>
<%
                    		}else if("true".equalsIgnoreCase(fullTextSearch) || !"structureBrowser".equalsIgnoreCase(uiType)){ //Custom toolbars will remain in the toolbar container only, for Search and Non SB pages
%>
<!-- //XSSOK -->
<%=loadToolbar(context, child, requestMap, 0, errorLabel, false, null, true,strToolbar)%>
<%
                    		}
	                        continue;
	                    }
	                        if(itr == 0){
            %>
<!-- //XSSOK -->
<%=loadToolbar(context, child, requestMap, 0, errorLabel, false)%>
    						<%
    					} else if("true".equalsIgnoreCase(fullTextSearch) || !"structureBrowser".equalsIgnoreCase(uiType)){ //Custom toolbars will remain in the toolbar container only, for Search and Non SB pages
    %>
<!-- //XSSOK -->
                          <%=loadToolbar(context, child, requestMap, 0, errorLabel, false,null,true,strToolbar)%>
    						<%
    					}
                    }
                    sCode = (String)child.get("code");
                    if (sCode != null && !"".equals(sCode) && !"null".equals(sCode))
                        {
                            sCodeList.add(sCode);
                        }
                      }
                   }
                }

            }
    }//End For

// Added for bug 353402
String strLifecycleApprovalsActionsMenu = PropertyUtil.getSchemaProperty(context,"menu_AEFLifecycleApprovalsSummaryToolbar");
String strEmpRole = PropertyUtil.getSchemaProperty(context,"role_Employee");
String securityContext = PersonUtil.getActiveSecurityContext(context);
boolean isVPLMViewer = securityContext.contains(PropertyUtil.getSchemaProperty(context,"role_VPLMViewer"));

if(toolbarList.size() > 0 && toolbarList.contains(strLifecycleApprovalsActionsMenu))
{
	if(isVPLMViewer || (userRoleList.size() == 2 && userRoleList.contains(strEmpRole)&& userRoleList.contains(context.getUser())))
	{
		editLink = "false";
	}
}
//Ended

if("structureBrowser".equals(uiType))
{
	if( !("false".equals(inlineIcons)) ){
	HashMap editInline = UIToolbar.getToolbar(context,"AEFSBEditInline",userRoleList,objectId,requestMap,language);

		if(editInline != null){
	   MapList children = UIToolbar.getChildren(editInline);
			for(int i = 0; i < children.size(); i++){
	        HashMap child = (HashMap)children.get(i);
%>
<!-- //XSSOK -->
	        <%=loadToolbar(context, child, requestMap, 0, errorLabel, false)%>
<%
		}
	 }
	}	
}

//Beginning add separator at the beginning of generic commands
%>
if(objMainToolbar.items.length!=0){
	objMainToolbar.addItem(new emxUIToolbarSeparator());
}
<% 
String strEditIcon = "";
if ("true".equalsIgnoreCase(editLink)) 
{
    StringBuffer editLinkHref =  new StringBuffer(100);
    if ("form".equals(uiType)){
    	//IR-066280V6R2011x
        DomainObject domainObject = DomainObject.newInstance(context,objectId);
        Access contextAccess = domainObject.getAccessMask(context);
        Boolean hasUserModifyAccess = contextAccess.hasModifyAccess();
        if(hasUserModifyAccess){
        
    	StringBuffer strEditURL = new StringBuffer();
    	if("edit".equals(mode)){
        	strEditURL.append("../common/emxForm.jsp?mode=view&form=");
        }else{
        	strEditURL.append("../common/emxForm.jsp?mode=edit&form=");
        }
        strEditURL.append(form);
        strEditURL.append("&timeStamp=");
        strEditURL.append(XSSUtil.encodeForURL(context, timeStamp));
        strEditURL.append("&toolbar=");
        strEditURL.append(XSSUtil.encodeForURL(context, stToolbar));
        strEditURL.append("&editLink=");
        strEditURL.append(XSSUtil.encodeForURL(context, editLink));
        strEditURL.append("&targetLocation=");
        strEditURL.append(XSSUtil.encodeForURL(context, targetLocation));
        strEditURL.append("&formHeader=");
        strEditURL.append(XSSUtil.encodeForURL(context, formHeader));
        strEditURL.append("&objectId=");
        strEditURL.append(XSSUtil.encodeForURL(context, objectId));
        strEditURL.append("&relId=");
        strEditURL.append(XSSUtil.encodeForURL(context, relId));
        strEditURL.append("&suiteKey=");
        strEditURL.append(XSSUtil.encodeForURL(context, suiteKey));
        strEditURL.append("&HelpMarker=");
        strEditURL.append(XSSUtil.encodeForURL(context, sHelpMarker));
        strEditURL.append("&findMxLink=");
        strEditURL.append(XSSUtil.encodeForURL(context, findMxLink));
        strEditURL.append("&appendFields=");
        strEditURL.append(XSSUtil.encodeForURL(context, appendFields));
        strEditURL.append("&preProcessJPO=");
        strEditURL.append(XSSUtil.encodeForURL(context, preProcessJPO));
        strEditURL.append("&preProcessURL=");
        strEditURL.append(preProcessURL);
        strEditURL.append("&postProcessJPO=");
        strEditURL.append(XSSUtil.encodeForURL(context, postProcessJPO));
        strEditURL.append("&postProcessURL=");
        strEditURL.append(postProcessURL);
        strEditURL.append("&cancelProcessJPO=");
        strEditURL.append(XSSUtil.encodeForURL(context, cancelProcessJPO));
        strEditURL.append("&preProcessJavaScript=");
        strEditURL.append(XSSUtil.encodeForURL(context, preProcessJavaScript));
        strEditURL.append("&cancelProcessURL=");
        strEditURL.append(cancelProcessURL);
        strEditURL.append("&portalMode=");
        strEditURL.append(XSSUtil.encodeForURL(context, portalMode));
        //if(!"popup".equals(targetLocation)){
        	editLinkHref.append("javascript:toggleMode('"+strEditURL.toString()+"','"+targetLocation+"')");
            //strEdit = strMode;
            if("edit".equals(mode)){
                strEditIcon = "iconActionDisableEdit.gif";
            }else{
                strEditIcon = "iconActionEdit.png";
            }
        /*}else{
        	editLinkHref.insert(0,"javascript:showModalDialog(\\\""+strEditURL.toString());
            editLinkHref.append("\\\",\\\"750\\\",\\\"600\\\",true)");
            strEditIcon = "iconActionEdit.gif";
        }*/
%>
<!-- //XSSOK -->
objMainToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, "iconActionEdit.png", "<%=strEdit%>", "<%=editLinkHref.toString()%>"));
<%  
		}
	}
    else if ("structureBrowser".equals(uiType))
    {
        editLinkHref.append("javascript:editMode()");
        //strEdit = strMode;
        strEdit= strEnableEdit;
        strEditIcon = "iconActionEdit.png";
%>
		<!-- //XSSOK -->      
		objMainToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, "iconActionEdit.png", "<%=strEdit%>", "<%=editLinkHref.toString()%>","","","","","","","","","","","editButttonId"));
<%   
    }
    else
    {
        editLinkHref.append("../common/emxTableEdit.jsp?header=");
        editLinkHref.append(XSSUtil.encodeForURL(context, header));
        editLinkHref.append("&timeStamp=");
        editLinkHref.append(XSSUtil.encodeForURL(context, timeStamp));
        editLinkHref.append("&suiteKey=");
        editLinkHref.append(XSSUtil.encodeForURL(context, suiteKey));
        editLinkHref.append("&findMxLink=");
        editLinkHref.append(XSSUtil.encodeForURL(context, findMxLink));
        editLinkHref.append("&preProcessJavaScript=");
        editLinkHref.append(XSSUtil.encodeForURL(context, preProcessJavaScript));

        editLinkHref.insert(0,"javascript:submitList(\\\"");
        editLinkHref.append("\\\", \\\"listHidden\\\",\\\"none\\\",\\\"true\\\",\\\"750\\\",\\\"600\\\")");
        strEditIcon = "iconActionEdit.png";
%>
        <!-- //XSSOK -->
		objMainToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, "iconActionEdit.png", "<%=strEdit%>", "<%=editLinkHref.toString()%>","","","","","","","","","","","editButttonId"));
<%
    }
}

// Changes for Launch window   - start
if( portalMode != null && "true".equalsIgnoreCase(portalMode) && !"true".equalsIgnoreCase(hideLaunchButton))
{
    // width & heights for Form page
    String sWidth = "570";
    String sHeight = "520";

    // default width & heights for Table & custom page
    if (!"form".equals(uiType))
    {
      sWidth = "700";
      sHeight = "500";
    }
%>
    var contextHRF = document.location.href;
    /* Fix for IR-031300V6R2011x */ 
    if( "structureBrowser" === strUIType || "table" === strUIType )
    {
        var urlParam =  contextHRF;
        var baseUrl = "";
        if(urlParam.indexOf("?")>0) {
            baseUrl =  urlParam.substring(0,urlParam.indexOf("?"));
        }
        else {
            baseUrl = urlParam;
        }
    
        if(urlParam.indexOf("?")>0 && urlParam.indexOf("&")>0) {
            urlParam = urlParam.substring(urlParam.indexOf("?")+1,urlParam.length);
        }
        else {
            urlParam = emxUICore.getData("emxCustomTableUtility.jsp?mode=postRefresh&uiType="+strUIType+"&timeStamp="+strTimeStamp);
            urlParam=urlParam.substring(0,urlParam.indexOf('@'));
        }
        var fullUrl = baseUrl + "?" + urlParam ;
        contextHRF = fullUrl;
    }
  
    /* End of Fix */
	contextHRF = contextHRF.replace("persist=true", "persist=false");
    contextHRF = contextHRF.replace("portalMode=true", "portalMode=false");
    contextHRF += "&launched=true";

    var launchLinkHref = "javascript:showModalDialog(contextHRF, <%=sWidth%>, <%=sHeight%>, true)";

    objMainToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, "iconActionNewWindow.png", "<%=strLaunch%>", launchLinkHref));

<%
}
%>
// Added for bug no 345310
var customTableURL=this.document.location.href;
// Till Here

<%
//Added for user defined table
String strCustomize = EnoviaResourceBundle.getProperty(context, "emxFramework.UITable.Customization");
String strViewLabel = UINavigatorUtil.getI18nString("emxFramework.CustomTable.DynamicCommand.View", "emxFrameworkStringResource", language);
String menuLabel = UINavigatorUtil.getI18nString("emxNavigator.UIMenuBar.Loading", "emxFrameworkStringResource", language);
String dynamicMenuLabel = UINavigatorUtil.getI18nString("emxFramework.DynamicMenu.Loading", "emxFrameworkStringResource", language);
if(cpfUser){
if(("table".equalsIgnoreCase(uiType) || "structureBrowser".equalsIgnoreCase(uiType)) && !"TRUE".equalsIgnoreCase(IsStructureCompare))
{
    if((customize!=null && "true".equalsIgnoreCase(customize)) || (customize==null && strCustomize.contains("enable"))||("".equalsIgnoreCase(customize) && strCustomize.contains("enable")) )
	{
    	StringBuffer strBuffNewURL = new StringBuffer(100);
    	if(!nonObjBasedSB){	    
	    strBuffNewURL.append("../common/emxCustomizeTablePopup.jsp?timeStamp=");
	    strBuffNewURL.append(XSSUtil.encodeForURL(context, timeStamp));
	    strBuffNewURL.append("&uiType=");
	    strBuffNewURL.append(XSSUtil.encodeForURL(context, uiType));
	    strBuffNewURL.append("&objectId=");
	    strBuffNewURL.append(XSSUtil.encodeForURL(context, objectId));
	    strBuffNewURL.append("&expandLevelFilter=false");
	    strBuffNewURL.append("&mode=New");
	    strBuffNewURL.insert(0,"javascript:showModalDialog(\\\"");
	    strBuffNewURL.append("\\\",\\\"658\\\",\\\"750\\\",true)");
    	}
    	else{
    		strBuffNewURL.append("");
    		%>
    		addToMenu ="true";
    		<%
    	}
	    // till here
%>
		if((customTableURL.match("emxTable") && !customTableURL.match("emxTableEdit"))||customTableURL.match("emxIndentedTable")||customTableURL.match("emxTablePortal"))
		{
			if("true"===addToMenu){
			    var customizeMenu = new emxUIToolbarMenu();
				customizeMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "", "<%=dynamicMenuLabel%>", "","", "", "", "", "", "", "", "", false,"","","DynamicCommand"));
				var customizeMenuItem = objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionSystemColumns.png","<%=strViewLabel %>", "","","","","","","","","","","","","emxCustomTableDynamicMenu","getCustomCommands","DynamicCommand"));
				customizeMenuItem.addMenu(customizeMenu);
			}
			else{
			objMenuItem = objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, "iconActionSystemColumns.png", "<%=strViewLabel %>", '<%=strBuffNewURL.toString()%>',"","","","","","","","","","","customTableSplitButton","emxCustomTableDynamicMenu","getCustomCommands","DynamicCommand"));
			objMenuItem.addMenu(new emxUIToolbarMenu());
			objMenu = objMenuItem.menu;
			objStack.push(objMenu);
			objMenu.addItem(new emxUIToolbarMenuItem(1, "", "<%=menuLabel%>", "","", "", "", "", "", "", "", "", false,"emxCustomTableDynamicMenu","getCustomCommands","DynamicCommand"));
			objMenu = objStack.pop();
			}
		}
<%
	}else if(hasAnyFilters){
%>
		objMenuItem = objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionSystemColumns.png", "<%=strViewLabel %>", "","","","","","","","","","","","","","",""));
		objMenuItem.addMenu(new emxUIToolbarMenu());
		objMenu = objMenuItem.menu;
		objStack.push(objMenu);
		objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "", "<%=dynamicMenuLabel%>", "","", "", "", "", "", "", "", "", false,"emxCustomTableDynamicMenu","getCustomCommands","DynamicCommand"));
		objMenu = objStack.pop();
<%
}
}
}

%>

<%if("structureBrowser".equals(uiType)) {
	String cellWrap = emxGetParameter(requestMap,"cellwrap");
	// Default SB View
	String displayViews = "details";
	
	// View passed from URL Parameter
	if(!UIUtil.isNullOrEmpty(sSBDisplayView)) {
		displayViews = sSBDisplayView;
	} else {
	    try{
	        displayViews = EnoviaResourceBundle.getProperty(context, "emxFramework.Freezepane.view");
	    } catch(Exception ex){}
	}
	Vector vDisplayView = new Vector();
	StringTokenizer tokens = new StringTokenizer(displayViews,",");
	String program = emxGetParameter(requestMap,"program");
	String programMenu = emxGetParameter(requestMap,"programMenu");
	while(tokens.hasMoreTokens()){
		String token = tokens.nextToken().trim();
		if (token.equals("tree") && (program != null || programMenu != null)) {
			continue;
		}
		vDisplayView.add(token);
	}
	//IR-085817V6R2012	- dummy checkin
	if(vDisplayView.size() > 1){
%>
    //var tnButton = new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionChangeTableView.gif", "Thumbnails", "javascript:toggleDisplayView()");
    //objContextToolbar.addItem(tnButton);
    //tnButton.setMode("view"); tnButton.enabled = true;
    if(customTableURL.match("emxIndentedTable")) {
    objMenuItem = objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionChangeTableView.png","<%=strDisplayMode%>", "","","","","","","","","","","","displayModeMenu","","",""));
    objMenuItem.addMenu(new emxUIToolbarMenu());
    objMenu = objMenuItem.menu;
    objStack.push(objMenu);
    <% if(vDisplayView.contains("details") ||  vDisplayView.contains("detail")) {%>
  	 	objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_AND_TEXT, "iconActionTreeListView.png", "<%=strDisplayDetails%>", "javascript:showDisplayView('detail')","", "", "", "", "", "", "", "", false,"","",""));
    <%} %>
    <% if(vDisplayView.contains("thumbnails") ||  vDisplayView.contains("thumbnail")) {%>
    	objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_AND_TEXT, "iconActionThumbnail-view.png", "<%=strDisplayThumbnail%>", "javascript:showDisplayView('thumbnail')","", "", "", "", "", "", "", "", false,"","",""));
    <%} %>
    <% if(vDisplayView.contains("tree")) {%>
   		 objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_AND_TEXT, "iconActionGraphView.png", "<%=strDisplayTree%>", "javascript:showDisplayView('tree')","", "", "", "", "", "", "", "", false,"","",""));
    <%} %>
    objMenuItem.enabled = true; objMenuItem.setMode("view");
    objMenu = objStack.pop();
    }
<%  } 
		if("true".equalsIgnoreCase(cellWrap)){%>
			objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionWordWrapOff.png", "<%= displayModeUnWrap%>", "javascript:toggleSBWrap()"));
	<%	}else{%>
			objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionWordWrapOn.png", "<%= displayModeWrap%>", "javascript:toggleSBWrap()"));
<%  }
	if (isDraggable) { %>
	    var tablename = '<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(requestMap,"table"))%>';
	    var storage = $.localStorage;
		var dropAction = 'Copy';
		if (storage.isEmpty('SB',tablename, 'dropAction')) {
			storage.set('SB',tablename, 'dropAction', 'Copy');
		} else {
			dropAction = storage.get('SB',tablename, 'dropAction');
		}
		console.log("dropAction = " + dropAction);
        if (dropAction == "Move")
			objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionDropActionMove.png", "<%= displayModeMove%>", "javascript:toggleDrop()"));
		else
			objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionDropActionAdd.png", "<%= displayModeCopy %>", "javascript:toggleDrop()"));
<%
	}
}
%>

<%
//End for User Defined Table

// Changes for Launch window   - end

        String expandLevelMenu = emxGetParameter(requestMap, "expandLevelFilterMenu");
        String strInquiry = emxGetParameter(requestMap, "inquiry");
        String strExpandFilter = emxGetParameter(requestMap, "expandLevelFilter");
        String strProgram = emxGetParameter(requestMap, "program");
        String strExpandProgram = emxGetParameter(requestMap, "expandProgram");
        String strexpandProgramMenu = emxGetParameter(requestMap, "expandProgramMenu");
        String strRelationship = emxGetParameter(requestMap, "relationship");
        String strRelationshipFilter = emxGetParameter(requestMap, "relationshipFilter");
        if (expandLevelMenu == null || "".equals(expandLevelMenu) || "null".equalsIgnoreCase(expandLevelMenu)) {
           //Not show the expand filter in flat mode. Check for program URL parameter
            if((strProgram != null && !strProgram.equals("") && !"null".equals(strProgram))
            || (strInquiry != null && !strInquiry.equals("") && !"null".equals(strInquiry))){
                  if (!"*".equals(strRelationship)|| strexpandProgramMenu != null|| strExpandProgram != null){
                        expandLevelMenu = "AEFFreezePaneExpandLevelFilterMenu";
                 } else{ //IF only program URL parameter is passed and none of the expand parameters
                     expandLevelMenu = "";//are passed then set the expand menu to blank as result expand filter will not be displayed.
                }
            }else{ //Check for if program URL parameter is not passed then set the expand menu
                 expandLevelMenu = "AEFFreezePaneExpandLevelFilterMenu"; //to default one. Show it will behave as normal structure browser.
            }
        }
        if(useCustomExpandFilter){
            expandLevelMenu = customExpandLevelMenu;
        }
        if (!"false".equalsIgnoreCase(strExpandFilter) && "structureBrowser".equalsIgnoreCase(uiType))
        {
            HashMap expandLevelToolbar = UIToolbar.getToolbar(context,
                                                  expandLevelMenu,
                                                  userRoleList,
                                                  objectId,
                                                  requestMap,
                                                  language);
            
            if (expandLevelToolbar != null && UIToolbar.isMenu(expandLevelToolbar))
            {
            	expandLevelToolbar.put("expandMenu", "true");
            	String expandLevelFilterLabel = getValue(expandLevelToolbar, "label");
            	if ("".equals(expandLevelFilterLabel))
                {
            		expandLevelFilterLabel = UINavigatorUtil.getI18nString("emxFramework.FreezePane.Expand",
                            "emxFrameworkStringResource", language);
            		expandLevelToolbar.put("label",expandLevelFilterLabel);
                }
                String strRegisteredSuite = UIToolbar.getSetting(expandLevelToolbar,"Registered Suite");
                String expandFilterJSInclude=   UINavigatorUtil.parseHREF(context,UIToolbar.getSetting(expandLevelToolbar,"JavaScript Include"), strRegisteredSuite);
                if(expandFilterJSInclude != null && !"".equals(expandFilterJSInclude))
                {
%>
                    <jsp:include page = "<%=expandFilterJSInclude%>" flush="true" />
<%
                    expandFilterJSInclude = "";
                }

                MapList expandLevelCommands = UIToolbar.getChildren(expandLevelToolbar);
                if (expandLevelCommands != null && expandLevelCommands.size() > 0)
                {
                    HashMap expandFilterMap = expandLevelToolbar;
                    StringList levelPattern = new StringList();
                    StringList labelPattern = new StringList();
                    String strExpandFilterValues = "";
                    String strExpandLabelValues = "";

                    for (int levelItr = 0; levelItr < expandLevelCommands.size(); levelItr++)
                    {
                        HashMap levelMap = (HashMap) expandLevelCommands.get(levelItr);
                        String strSuite = UIToolbar.getSetting(levelMap,"Registered Suite");
                        String resourceFile = "emxFrameworkStringResource";
                        if (strSuite != null && !"".equals(strSuite.trim()))
                        {
                            resourceFile = UINavigatorUtil.getStringResourceFileId(context, strSuite);
                        }

                        String strLevelId = UIToolbar.getSetting(levelMap,"Level");
                        String strLabel = getValue(levelMap, "label");
                        if (!"".equals(strLabel))
                        {
                            strLabel = UINavigatorUtil.getI18nString(strLabel, resourceFile, language);
                            StringList labelList = FrameworkUtil.split(strLabel, ",");
                            for (int labelsItr=0; labelsItr < labelList.size(); labelsItr++)
                            {
                                strLabel = UINavigatorUtil.getI18nString((String)labelList.get(labelsItr), resourceFile, language);
                                labelPattern.addElement(strLabel);
                            }
                        }
                        if (!"".equals(strLevelId))
                        {
                            //If Level setting contains duplicant values we need to eliminate duplicants
                            StringList levelList = FrameworkUtil.split(strLevelId, ",");
                            for (int itr = 0; itr < levelList.size(); itr++)
                            {
                                strLevelId = (String) levelList.get(itr);
                                if (!levelPattern.contains(strLevelId))
                                {
                                    levelPattern.addElement(strLevelId);
                                }
                                if ("".equals(strLabel))
                                {
                                    labelPattern.addElement(strLevelId);
                                }
                            }
                        }
                    }

                    if (levelPattern.size() > 0)
                    {
                        strExpandFilterValues = FrameworkUtil.join(levelPattern, ",");
                        strExpandLabelValues = FrameworkUtil.join(labelPattern, ",");
                    }

                    expandFilterMap.remove("Children");
                    expandFilterMap.remove("children");
                    expandFilterMap.put("type", "command");
                    expandFilterMap.put("name", "emxExpandFilter");
                    expandFilterMap.put("href", "javascript:selectMoreLevel()");
                    UIToolbar.modifySetting(expandFilterMap, "Range Values", strExpandFilterValues);
                    UIToolbar.modifySetting(expandFilterMap, "Label Range Values", strExpandLabelValues);
                    UIToolbar.modifySetting(expandFilterMap, "Input Type", "combobox");
                    UIToolbar.modifySetting(expandFilterMap, "Range Display Values", strExpandLabelValues);

                    requestMap.put("toolbarExpandFilter", "true");
                    String strExpandFilterLabel = getValue(expandFilterMap, "label");
                    strExpandFilterLabel = UINavigatorUtil.getI18nString(strExpandFilterLabel, "emxFrameworkStringResource", language);
                    strExpandFilterLabel = UINavigatorUtil.getI18nString(strExpandFilterLabel, strStringResourceFile, language);
                    //strExpandFilterLabel = "<b>" + strExpandFilterLabel + "</b>";
                    expandFilterMap.remove("label");
                    if(useCustomExpandFilter){
%>
					<%=loadToolbar(context, expandFilterMap, requestMap, 0, errorLabel, false, strExpandFilterLabel, true,customExpandFilterToolbar)%>
<%
                    }else{
%>
                    <%=loadToolbar(context, expandFilterMap, requestMap, 0, errorLabel, false, strExpandFilterLabel, true)%>
<%
                    }
                    String expandLevel = (String)levelPattern.get(0);
                    if (expandLevel == null || "".equals(expandLevel))
                    {
                        expandLevel = "1";
                    }
                    requestMap.put("Expand Level", expandLevel);
                }

            }
        }
// To display the AEF Collections menu in tables / forms / structure browser
HashMap hmTemp = new HashMap();
showClipboard = emxGetParameter(requestMap,"showClipboard");

// To validate object based or not for flat table
String strObjectBased = emxGetParameter(requestMap,"objectBased");
if(strObjectBased==null || "null".equals(strObjectBased) || strObjectBased.length()==0) {
    strObjectBased="true";
}

//Modified for Bug : 345935
if(selection!=null && ("multiple".equals(selection) || "single".equals(selection)))
{
%>
	if(!(getTopWindow().FullSearch) && !(getTopWindow().document.getElementById("windowshade") && getTopWindow().document.getElementById("windowshade").style.display != "none" && getTopWindow().findFrame(getTopWindow(),"windowShadeFrame") && getTopWindow().findFrame(getTopWindow(),"windowShadeFrame").FullSearch))
	{
<% 
		if((showClipboard!=null && showClipboard.equals("true")) || (uiType!=null && (uiType.equalsIgnoreCase("form") || uiType.equalsIgnoreCase("StructureBrowser") || (uiType.equalsIgnoreCase("table") && strObjectBased.equals("true")))))
	{
	    if((showClipboard==null || showClipboard.equalsIgnoreCase("true")))
		{
		    showClipboard = "true";
			 	String toolTipShortcuts = UINavigatorUtil.getI18nString("emxFramework.ShortcutPanel.Shortcuts", "emxFrameworkStringResource", language);
				
			%>
			if(getTopWindow().location.href.indexOf('emxNavigatorDialog.jsp') != -1){
			 		objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionOpenShortcuts.png", "<%=toolTipShortcuts%>", "javascript:showShortcutPanel()"));
			}
				<%			 	
				//Added for shortcut icon ends
			 					
			hmTemp = UIToolbar.getToolbar(context,"AEFClipboardCollections",userRoleList,objectId,requestMap,language);
			if(hmTemp!=null)
			{
			%>
			  <%=loadToolbar(context, hmTemp, requestMap, 0, errorLabel, false)%>
			<%
			}
				
		}
	}
%>
	}
<%	
}

if ("true".equalsIgnoreCase(hasAutoFilter) || ("false".equalsIgnoreCase(fullTextSearch) && "structureBrowser".equalsIgnoreCase(uiType) && isCustomTBPassedIn))
{
   if("structureBrowser".equalsIgnoreCase(uiType))
   {
        String toolTipAutoFilter = UINavigatorUtil.getI18nString("emxFramework.AutoFilter.Selections", "emxFrameworkStringResource", language);
%>
		objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionFilter.png", "<%=toolTipAutoFilter%>", "javascript:showAutoFilterDisplay()"));
<%
   }else if("table".equalsIgnoreCase(uiType)){
        String autoFilterURL = "emxTableAutoFilter.jsp?timeStamp=" + timeStamp;
        String toolTipAutoFilter = UINavigatorUtil.getI18nString("emxFramework.TableComponent.AutoFilter", "emxFrameworkStringResource", language);
%>
   	    objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionFilter.png", "<%=toolTipAutoFilter%>", "javascript:showModalDialog(\"<%=autoFilterURL%>\",\"750\",\"600\",true)"));
<%
   }
}

//hasCurrencyConverter
String hasCurrencyConverter = emxGetParameter(requestMap, "CurrencyConverter");
if ("true".equalsIgnoreCase(hasCurrencyConverter))
{
        String toolTipConvert = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Convert", "emxFrameworkStringResource", language);
        String currencyConvertURL = "javascript:callConversionPage()";
%>
   toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "buttonContextConvert.gif", "<%=toolTipConvert%>", "<%= currencyConvertURL %>","", "", "", "", "", "", "", "", false,"","","DynamicCommand"));
<%
}

%>
var sMethod;
<%
//objectComparison

String objCompare=emxGetParameter(requestMap, "objectCompare");
String objectBased=emxGetParameter(requestMap, "objectBased");

if (cpfUser)
{
	if(!"form".equalsIgnoreCase(uiType)){
    if(objCompare==null || "null".equals(objCompare) || objCompare.length()==0) {
        objCompare="true";
    }
    if(objectBased==null || "null".equals(objectBased) || objectBased.length()==0) {
        objectBased="true";
    }
}
}
else
{
    objCompare = "false";
}

if((strTriggerValidation==null || "True".equalsIgnoreCase(strTriggerValidation) || "".equalsIgnoreCase(strTriggerValidation))){
	if("structureBrowser".equals(uiType))
	{
		if(columnNames.contains("type") && columnNames.contains("current"))
		{
    %>
	    	sMethod="post";

			toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionValidate.png", "<%=strTriggerValidationToolTip%>", "javascript:triggerValidation()","popup", "", "", "700", "600", "", "", "", false,"","","Validate","",""));
    <%
		}
	}
	if("table".equals(uiType))
    {
        if(columnNames.contains("type") && columnNames.contains("current"))
		{
    %>
			toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionValidate.png", "<%=strTriggerValidationToolTip%>", "javascript:submitList(\"../common/emxTable.jsp?table=AEFValidateTrigger&program=emxTriggerValidationBase:getCheckTriggers&header=emxFramework.Label.TriggerValidation&customize=false&multiColumnSort=false&objectBased=false&SubmitURL=../common/emxTriggerIntermediatePage.jsp&SubmitLabel=emxFramework.Button.Next&Style=dialog&CancelLabel=emxFramework.Button.Cancel&CancelButton=true&multipleObjects=false&selection=multiple&triggerValidation=false&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common\", \"popup\",\"none\",\"true\",\"800\",\"600\",\"\")","popup", "", "", "", "", "", "", "", false,"","",""));
   <%
		}
    }
}
if("true".equalsIgnoreCase(objCompare) && "true".equalsIgnoreCase(objectBased) && "multiple".equalsIgnoreCase(selection))
{
    String toolTipCompare = UINavigatorUtil.getI18nString("emxFramework.ObjectCompare.ObjectCompare", "emxFrameworkStringResource", language);
%>
    var frame="listHidden";

<%
    if("structureBrowser".equals(uiType)) {
%>
        sMethod = "post";
		toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionCompare.gif",     "<%=toolTipCompare%>", "javascript:submitFreezePaneData(\"../common/emxObjectCompareProcess.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common\",\"listHidden\",\"multi\",\"\",\"false\",\"600\",\"600\",\"\")","", "", "", "", "", "", "", "", false,"","","DynamicCommand"));
<%
    } else {
%>
   toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionCompare.gif", "<%=toolTipCompare%>", "javascript:submitList(\"../common/emxObjectCompareProcess.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common\",\"listHidden\",\"multi\",\"\",\"600\",\"600\",\"\")","", "", "", "", "", "", "", "", false,"","","DynamicCommand"));
<%
	}
}

if( !(UINavigatorUtil.isMobile(context)) && (export == null || export.trim().length()==0 || export.equalsIgnoreCase("true")))
{
%>
toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionExcelExport.png", "<%=strExport%>", "javascript:exportData(\"<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>\" , '<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')","", "", "", "", "", "", "", "", false,"","","DynamicCommand"));
<%
}

if ("table".equals(uiType) && "true".equalsIgnoreCase(showChartOptions))
{
%>
    toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionChart.png", "<%=strChartOptions%>", "javascript:showChartOptions(\"<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
<%
}

if ("true".equalsIgnoreCase(showTableCalcOptions))
{
%>
    toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionCalculations.gif", "<%=strTableCalcOptions%>", "javascript:showTableCalcOptions(\"<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
<%}%>

<%if( (sPrinterFriendly == null || sPrinterFriendly.trim().length() == 0 || sPrinterFriendly.equalsIgnoreCase("true"))){
%>
toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionPrint.png", "<%=strPrinter%>", "javascript:openPrinterFriendlyPage(\"<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>\" , '<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')","", "", "", "", "", "", "", "", false,"","",""));

<%}
//	PageURLIcon
String showPageURLSysProp = "";
boolean bShowPageURL = false;
try{
	showPageURLSysProp = EnoviaResourceBundle.getProperty(context, "emxFramework.Toolbar.ShowPageURLIcon");
}catch(Exception e){
    showPageURLSysProp = "true";
}
if("true".equalsIgnoreCase(sPageURL)){
    bShowPageURL = true;
}else if("false".equalsIgnoreCase(sPageURL)){
    bShowPageURL = false;
}else if("true".equalsIgnoreCase(showPageURLSysProp)){
    bShowPageURL = true;
}

if(!"true".equalsIgnoreCase(fullTextSearch))
{
if(bShowPageURL && "GET".equalsIgnoreCase(submitMethod)){
	 if((portalMode != null && "true".equals(portalMode)) || (targetLocn != null && "slidein".equals(targetLocn))){
%>
			objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionPageURL.png", "<%=strPageURL%>", "javascript:showPageURL()"));
<%
	}else{
		%>
		if(getTopWindow().getWindowOpener() && getTopWindow().document.getElementById('globalToolbar') == null){
			objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionPageURL.png", "<%=strPageURL%>", "javascript:showPageURL()"));
		}
		<%
	}
}
}



//  PDF Rendering to Form Component Begin


if(showRenderPDFIconSB || showRenderPDFIcon || showRenderPDFIconFT)
{
%>
     toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionPDF.png", "<%=strRenderPDF%>", "javascript:openRenderPDFPage(\"<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>\",\"<xss:encodeForJavaScript><%=useAdlibSetup%></xss:encodeForJavaScript>\",\"<xss:encodeForJavaScript><%=uiType%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
<%
}

//For IR-064590V6R2011x

if("structureBrowser".equals(uiType) || "table".equals(uiType)){

	if ( "true".equalsIgnoreCase(multiColumnSort)){
%>
		toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionColSortMulti.gif", "<%=strMultiColumnSort%>", "javascript:multiColumnSortData(\"<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>\",\"<xss:encodeForJavaScript><%=uiType%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
<%
	}
	else {
		//do not dispay the multiColumnSort icon
	}
}
//For IR-064590V6R2011x


if("structureBrowser".equals(uiType)){

	if ( !"false".equalsIgnoreCase(rowGrouping)){
%>
        objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionGroupBy.png", "<%=strRowGrouping%>", "javascript:processRowGroupingToolbarCommand('open/close')"));
<%
	}
}

if (tipPage != null && tipPage.trim().length() > 0)
{%>
toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "buttonContextTip.gif", "<xss:encodeForJavaScript><%=tipPage%></xss:encodeForJavaScript>", "javascript:openTipWindow(\"<xss:encodeForJavaScript><%=tipPage%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
<%}

String enableMxLink =  EnoviaResourceBundle.getProperty(context, "emxFramework.DynamicURLEnabled");

String helpSuiteDir = suiteDir;
//to get the folder name in directory structure as english
String helpLanguage = "";
helpLanguage = "emxFramework.OnlineHelp.Language.";
helpLanguage = helpLanguage.concat(langStr);
String strHelpLang = EnoviaResourceBundle.getProperty(context, helpLanguage);
if (helpSuiteDir == null || "".equals(helpSuiteDir))
{
    helpSuiteDir = "common";
}


if(!"false".equals(enableMxLink) && !"false".equals(findMxLink)) {
    String SearchURL = "../common/emxSearch.jsp?mxLink=true&toolbar=AEFGenericSearch";
    String toolTipMxLink = UINavigatorUtil.getI18nString("emxFramework.DynamicURL.MxLink", "emxFrameworkStringResource", language);
     if(!"false".equalsIgnoreCase(findMxLink) && "form".equalsIgnoreCase(uiType) && ( "edit".equalsIgnoreCase(mode) || "create".equalsIgnoreCase(mode))) {
%>

        toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionMXLink.gif", "<%=toolTipMxLink%>", "javascript:showModalDialog(\"<%=SearchURL%>\",\"750\",\"600\")","", "", "", "", "", "", "", "", false,"","",""));
<%
}else if("structureBrowser".equalsIgnoreCase(uiType) && "true".equalsIgnoreCase(editLink)) {
%>
          toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionMXLink.gif", "<%=toolTipMxLink%>", "javascript:showModalDialog(\"<%=SearchURL%>\",\"750\",\"600\")","", "", "", "", "", "", "", "", false,"","",""));
<%
     }
}
if(!"false".equalsIgnoreCase(sHelpMarker)){
	if((portalMode != null && "true".equals(portalMode)) || (targetLocn != null && ("slidein".equals(targetLocn) || "windowshade".equals(targetLocn)))){	
%> 
       toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", "<%=strHelp%>", "javascript:openHelp(\"<xss:encodeForJavaScript><%=sHelpMarker%></xss:encodeForJavaScript>\",\"<xss:encodeForJavaScript><%=helpSuiteDir%></xss:encodeForJavaScript>\",\"<%=langStr%>\",\"<%=langOnlineStr%>\",'', \"<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
<%		
	}else{
		%>
		if(getTopWindow().getWindowOpener() && getTopWindow().document.getElementById('globalToolbar') == null){
			var isApplet = "<%=strIsApplet%>";
			if (isApplet == "true"){
				objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.png", "<%=strHelp%>", "javascript:openHelp(\"<xss:encodeForJavaScript><%=sHelpMarker%></xss:encodeForJavaScript>\",\"<xss:encodeForJavaScript><%=helpSuiteDir%></xss:encodeForJavaScript>\",\"<%=langStr%>\",\"<%=langOnlineStr%>\",'', \"<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
			} 
			else{
			toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", "<%=strHelp%>", "javascript:openHelp(\"<xss:encodeForJavaScript><%=sHelpMarker%></xss:encodeForJavaScript>\",\"<xss:encodeForJavaScript><%=helpSuiteDir%></xss:encodeForJavaScript>\",\"<%=langStr%>\",\"<%=langOnlineStr%>\",'', \"<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>\")","", "", "", "", "", "", "", "", false,"","",""));
			}
		}
		<%
	}
}
	

  
//<--------Mass Promote Demote Starts--------->
%>
	var arrayCommands = new Array();
	for(var i = 0; i < objMainToolbar.items.length ; i++)
	{
		arrayCommands[i]= objMainToolbar.items[i].dynamicName;
	}
	var strCommands = arrayCommands.toString();
	if(strCommands.search("AEFLifecycleMassPromote")==-1 && strCommands.search("AEFLifecycleMassDemote")==-1)
	{
<%
		if("structureBrowser".equals(uiType)|| "table".equals(uiType))
		{
			if (showMassPromote){
			{
				//if((columnNames.contains("Type") || columnNames.contains("type") )
				  //      && (columnNames.contains("State") || columnNames.contains("state")))
				  //Modified for bug 345045
				  if(columnNames.contains("type") && columnNames.contains("current"))
				{
					if("structureBrowser".equals(uiType))
					{
%>
						toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionPromote.png", "<%=strMassPromote%>", "javascript:submitFreezePaneData(\"../common/emxMassPromoteDemote.jsp?cmd=Promote&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common\", \"listHidden\",\"multi\",\"\",\"false\",\"600\",\"600\",\"\")","", "", "", "", "", "", "", "", false,"","",""));
						toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionDemote.png", "<%=strMassDemote%>", "javascript:submitFreezePaneData(\"../common/emxMassPromoteDemote.jsp?cmd=Demote&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common\", \"listHidden\",\"multi\",\"\",\"false\",\"600\",\"600\",\"\")","", "", "", "", "", "", "", "", false,"","",""));
<%
					}
					else if("table".equals(uiType))
					{
%>
						toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionPromote.png", "<%=strMassPromote%>", "javascript:submitList(\"../common/emxMassPromoteDemote.jsp?cmd=Promote&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common\", \"listHidden\",\"multi\",\"\",\"600\",\"600\",\"\")","", "", "", "", "", "", "", "", false,"","",""));
						toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "iconActionDemote.png", "<%=strMassDemote%>", "javascript:submitList(\"../common/emxMassPromoteDemote.jsp?cmd=Demote&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common\", \"listHidden\",\"multi\",\"\",\"600\",\"600\",\"\")","", "", "", "", "", "", "", "", false,"","",""));
<%
					}
				}
			}
		}
	}
//<--------Mass Promote Demote Ends--------->
%>
    }
<% if(cpfUser){ %>
	if(toolsMenu.items.length > 0) {
		objMenuItem = objContextToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconSmallAdministration.png","<%=strTools%>", "","","","","","","","","","","","","","","DynamicCommand"));
		objMenuItem.addMenu(toolsMenu);
    }
<% }
		if("structureBrowser".equals(uiType) && (UIUtil.isNotNullAndNotEmpty(logPerformance) && "true".equalsIgnoreCase(logPerformance))) {
%>
				toolsMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_ONLY, "", "Log Performance", "javascript:launchPerformanceLog(timeStamp)","", "", "", "", "", "", "", "", false,"","",""));
<%
	}
}
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if(ex.toString() != null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("Toolbar: " + ex.toString().trim());

        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }

%>

var isFullSearch = "<xss:encodeForJavaScript><%=fullTextSearch%></xss:encodeForJavaScript>";
var toolbarResizeTimeout = null;

function redrawToolbar() {

    clearTimeout(toolbarResizeTimeout);
    var timeOutDelay = 2000;
    toolbarResizeTimeout = setTimeout(function _delayed_redraw() {
       if((getTopWindow().isMobile || getTopWindow().isPCTouch) && jQuery(".menu-panel:visible") && jQuery(".menu-panel:visible").length == 1){
event.stopPropagation();
event.preventDefault();
}
        var div = "divToolbar"; 
        var divToolbar = document.getElementById(div);
	    if(!divToolbar){
	    	return;
	    }
	   
	   //Capture all the input controls
	   var frmvalmap = new HashMap();
	   
	   var inpelems = document.getElementsByTagName("input");
	   for(var k = 0; k < inpelems.length; k++){
	   		if(inpelems[k].name == "timeStamp" || inpelems[k].name == "emxTableRowId" || inpelems[k].id == "tdYear"){
	   			continue;	
	   		}
	   		if(inpelems[k].type == "hidden" || inpelems[k].type == "textbox" || inpelems[k].type == "text") {
	   			frmvalmap.Put(inpelems[k].name, inpelems[k].value);
	   		}else if(inpelems[k].type == "checkbox" || inpelems[k].type == "radio") {
          var key = inpelems[k].name + ":" + inpelems[k].value;
          frmvalmap.Put(key, inpelems[k].checked);
	   		}
		   	if(inpelems[k].type == "button" || inpelems[k].type == "textbox" || inpelems[k].type == "text") {
				var key = inpelems[k].name + ":disabled";
				frmvalmap.Put(key, inpelems[k].disabled);
			}else if(inpelems[k].type == "checkbox" || inpelems[k].type == "radio") {
	   			var key = inpelems[k].name + ":" + inpelems[k].value + ":disabled";
	   			frmvalmap.Put(key, inpelems[k].disabled);
	   		}
	   }
	   
	   var imgelems = document.getElementsByTagName("img");
	   for(var k = 0; k < imgelems.length; k++){
	   		if(imgelems[k].parentNode.tagName == "TD"){ 
	   			if(imgelems[k].parentNode.getAttribute("itemid") && (imgelems[k].parentNode.className.indexOf("overflow-button") < 0)){
	   				frmvalmap.Put(imgelems[k].parentNode.getAttribute("itemid"), imgelems[k].parentNode.className);
	   			}
	   		}
	   	}
	   
	   var seleelems = document.getElementsByTagName("select");
	   for(k = 0; k < seleelems.length; k++){
	   		if(seleelems[k].name == "timeStamp"){
	   			continue;
	   		}
	   		if(seleelems[k].multiple){
	   		 var valueArray = [];
	   		 for(var i=0; i<seleelems[k].length; i++){
	   		      valueArray[i] = seleelems[k][i].value;	   		
	   		 }
	   		 
	   		 frmvalmap.Put(seleelems[k].name, valueArray);
	   		
	   		}else{
	   		
	   		frmvalmap.Put(seleelems[k].name, seleelems[k].value);
	   		}	   		
	   }
	   /*Clearing the Toolbar content*/
	   
	   divToolbar.innerHTML = "";
	   var toolLength = toolbars.length;
       for(var i = 0; i < toolLength; i++){ 
           var itemLength = (toolbars[i].items && toolbars[i].items.length) || 0; 
           for(var j = 0; j < itemLength; j++) { 
               if (toolbars[i].items[j].menu && toolbars[i].items[j].menu.layer){
                    jQuery(toolbars[i].items[j].menu.layer).remove();
                }
            }
        }    
	   
	   var divs = document.getElementsByTagName("div");
	   var divarray = [];
	   for(var i = 0; i < divs.length; i++)
	     divarray.push(divs[i]);
	   
	   for(var l = 0; l < divarray.length; l++)
	     {
		   //condition for reload the toolbar container div except in full search (full search can be opened in popup and windowshade).
	     if(divarray[l].className == "toolbar-container" && divarray[l].id != "divToolbarContainer" && divarray[l].id != "divRevisionHistoryFilter" && !(getTopWindow().FullSearch) && !(parent.FullSearch) && !(getTopWindow().document.getElementById("windowshade") && getTopWindow().document.getElementById("windowshade").style.display != "none" && getTopWindow().findFrame(getTopWindow(),"windowShadeFrame").FullSearch))
	     { 
	       divarray[l].innerHTML = "";
	       divarray[l].parentNode.removeChild(divarray[l]);
	     }
	     
	     if(divarray[l].className == "mmenu" || divarray[l].className == "mmenu page" || divarray[l].className == "mmenu dialog"){
	        divarray[l].innerHTML = "";
            divarray[l].parentNode.removeChild(divarray[l]); 
         }
            
         if(divarray[l].id == "ieMenuCoverForObjectTag"){
            divarray[l].innerHTML = "";
            divarray[l].parentNode.removeChild(divarray[l]); 
         } 
	   }
	   toolbars.redraw = true;
	   toolbars.init(div, true);
	   if(isRowSelected) {
	       toolbars.setListLinks(isRowSelected(strUIType));
	   } else {
	       toolbars.setListLinks((isAnyRowSelectedInSB(this.oXML) && (parent.ids && parent.ids.length > 1)));
	   }
	   // reset all the input controls
	   inpelems = document.getElementsByTagName("input");
	   for(var n = 0; n < inpelems.length; n++){
	   		if(inpelems[n].name == "timeStamp" || inpelems[n].name == "emxTableRowId" || inpelems[n].id == "tdYear"){
	   			continue;	
	   		}
	   		if(inpelems[n].type == "hidden" || inpelems[n].type == "textbox" || inpelems[n].type == "text") {
	   			inpelems[n].value = frmvalmap.Get(inpelems[n].name);
	   		}else if(inpelems[n].type == "checkbox" || inpelems[n].type == "radio") {
          var key = inpelems[n].name + ":" + inpelems[n].value;
          inpelems[n].checked = frmvalmap.Get(key);
	   		}
	   		if(inpelems[n].type == "button" || inpelems[n].type == "textbox" || inpelems[n].type == "text"){
	   			var key = inpelems[n].name + ":disabled";
	   			inpelems[n].disabled = frmvalmap.Get(key);
	   		}else if(inpelems[n].type == "checkbox" || inpelems[n].type == "radio"){
	   		    var key = inpelems[n].name + ":" + inpelems[n].value + ":disabled";
	   			inpelems[n].disabled = frmvalmap.Get(key);
	   		}	   		
	   }
	   
	   imgelems = document.getElementsByTagName("img");
	   for(var n = 0; n < imgelems.length; n++){
	   		if(imgelems[n].parentNode.tagName == "TD") {
	   			if(imgelems[n].parentNode.getAttribute("itemid") && (imgelems[n].parentNode.className.indexOf("overflow-button") < 0)){
				   if(frmvalmap.Get(imgelems[n].parentNode.getAttribute("itemid")))
	   				{
	   				imgelems[n].parentNode.className = frmvalmap.Get(imgelems[n].parentNode.getAttribute("itemid"));
					}
	   			}
	   		}
	   }
	   
<%
       if("structureBrowser".equalsIgnoreCase(uiType) || "table".equalsIgnoreCase(uiType)){
%> 
		   if(customTableURL.match("emxTable")||customTableURL.match("emxIndentedTable")||customTableURL.match("emxTablePortal")){
			   setTimeout(function() {showIcon('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=uiType%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=IsStructureCompare%></xss:encodeForJavaScript>')},5);
	       }
<%
       }
%>
	   seleelems = document.getElementsByTagName("select");
	   for(k = 0; k < seleelems.length; k++){
	   		if(seleelems[k].name == "timeStamp"){
	   			continue;
	   		}
	   		var valueOfSelect = frmvalmap.Get(seleelems[k].name);
	   		
	   		if(Array.isArray(valueOfSelect)){
	   			for(var i=0;i<valueOfSelect.length;i++){
	   			  seleelems[k][i].value = valueOfSelect[i];
	   			}
	   		
	   		}else{
	   		seleelems[k].value = valueOfSelect;
	   		}
	   }
	   if(isRowSelected) {
	       toolbars.setListLinks(isRowSelected(strUIType));
	   } else {
       	   toolbars.setListLinks((isAnyRowSelectedInSB(this.oXML) && (parent.ids && parent.ids.length > 1)));
	   }
	   
<%
	   if("structureBrowser".equalsIgnoreCase(uiType)){
%>
			sbToolbarResize();
<%
	   }
%>
    },timeOutDelay); 
    var func = "";
    if(getTopWindow().FullSearch){
            func = "getTopWindow().FullSearch";
        } else if(parent.FullSearch) {
            func = "parent.FullSearch";
        }
        if(func){
	        func += ".setToggleButtonLabel()";
	        setTimeout(func,timeOutDelay);
		}
}

emxUICore.addEventHandler(window, "resize", function () { redrawToolbar(); });

function readjustBodytop(){
	var phd = document.getElementById("pageHeadDiv");
	var dpb = document.getElementById("divPageBody");
	
	var ht;	
    if(phd) {
      ht = phd.clientHeight;
    }
	if(ht <= 0){
		ht = phd.offsetHeight;
	}
    if(dpb) {
     dpb.style.top = ht + "px";
  }
	
}

function initiate(){
  setTimeout(function(){
<%
	if("structureBrowser".equalsIgnoreCase(uiType)){
%>  
      toolbars.init("divToolbar", true);
<%
  } else {
%>
      toolbars.init("divToolbar");
<%
  }
%>
  toolbars.setListLinks((parent.ids && parent.ids.length > 1));
<%
   if(!"edit".equals(mode)) {
%>
      var toolbar = document.getElementById("mxlinkiconId");
      if(toolbar) {
        toolbar.style.display = "none";
        }
<%
	if(!"structureBrowser".equalsIgnoreCase(uiType) && !UIUtil.isNullOrEmpty(uiType)){
%>      
      if(readjustBodytop()){
      	readjustBodytop();
      }
<%
	}
   }
%>
  },100);
<%
if("structureBrowser".equalsIgnoreCase(uiType) || "table".equalsIgnoreCase(uiType)){
%> 
 if(customTableURL.match("emxTable")||customTableURL.match("emxIndentedTable")||customTableURL.match("emxTablePortal")){
 		setTimeout(function() {showIcon('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=uiType%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=IsStructureCompare%></xss:encodeForJavaScript>')},200);
 }
<%
 }
if(isLoggingEnabled) {
	totalTimeToolbar = System.currentTimeMillis()-totalTimeToolbar;
	if(tableData!=null && tableData.get("logBuffer")!=null) {
		UITableIndentedUtil.sbLogEntry(context, (StringBuilder)tableData.get("logBuffer"), "&emsp;&emsp;Time taken for loading Toolbar : " + totalTimeToolbar);
	}
	if(tableData.get("totalServerTime")!=null) {
		totalTimeToolbar+=(Long)tableData.get("totalServerTime");
		tableData.put("totalServerTime", totalTimeToolbar);

	} else {
		tableData.put("totalServerTime", totalTimeToolbar);

	}

}
%>
}

emxUICore.addEventHandler(window, "load", initiate);
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

