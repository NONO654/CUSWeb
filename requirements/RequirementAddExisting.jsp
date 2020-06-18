<%--
  RequirementAddExisting.jsp

  Performs actions that modify the Specification Structure.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
* @quickreview QYG  	   	13:02:21	(IR-216193V6R2014  treat PopupLauncher.jsp as a component page for popups)
* @quickreview LX6 	QYG 	13:03:04 	IR-221725V6R2014   "STP: Rearranging of RMT object in Requirement structure view and Requriement specification view is KO.  "
* @quickreview QYG	     	13:03:05	(IR-221842V6R2014  Custom View creation KO)
* @quickreview T25 	DJH 	13:10:25    HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) . Created tokens to be used in js files
* @quickreview T25 	DJH 	13:10:31 	Correction of IR-236909V6R2014x.Created tokens to be used in RichTextEditorStructure.js file.
* @quickreview JX5			14:04:07 	HL Create Derivation Links Between Requirements	
* @quickreview JX5			14:06:23    IR-305271-3DEXPERIENCER2015x : Embedded SB in CATIA	
* @quickreview JX5     		14:09:01 	IR-319817-3DEXPERIENCER2015x, IR-319809-3DEXPERIENCER2015x	
* @quickreview JX5			14:10:03	IR-327198-3DEXPERIENCER2015x : VNLS: Covers and Refined into pop up winow not translated into Specific language
* @quickreview HAT1 ZUD		15:02:11	HL - Requirement Specification dependency. Tabs and buttons support in checkConsistency dialog.
* @quickreview HAT1 ZUD 	15:03:02    IR-342686-3DEXPERIENCER2014x : Cut paste operation fails when user select two object and click on paste as Above command. 
* @quickreview LX6       	15:04:02    IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement.
* @quickreview HAT1 ZUD     15:07:15  : IR-379618-3DEXPERIENCER2016x - NLS transformation is not getting applied to “Solving Warning and inconsistency”  and “solving error  inconsistency pop up” . 
* @quickreview HAT1 ZUD     15:07:15  : IR-379609-3DEXPERIENCER2016x - NLS transformation is not getting applied on Check Consistency pop up window.
* @quickreview QYG			15:08:04  : fix fromWebForm value for IE 11.0.21 regression
* @quickreview HAT1 ZUD     15:08:19  : IR-363246-3DEXPERIENCER2016x FUN048478:No option available to remove the target Requirement Specification from Create likn to cover\refine requirement pop upso that persistent dependencies can be deleted.
* @quickreview KIE1 ZUD     24:08:15  : IR-386290-3DEXPERIENCER2016x: PLM Parameter migration 
* @quickreview HAT1 ZUD     15:10:12  : IR-398721-3DEXPERIENCER2017x: Any labels on the Test Case validation status  window are not translated.
* @quickreview QYG          16:05:03  : javascript refactoring
* @quickreview HAT1 ZUD     17:02:16  : IR-437663-3DEXPERIENCER2017x: Please translate the word of some tooltips into Japanese version 2.
* @quickreview KIE1 ZUD     17:02:16  : IR-492924-3DEXPERIENCER2018x: Tooltip of Change Order is not translated
* @quickreview HAT1 ZUD     17:07:06  : IR-531749-3DEXPERIENCER2018x: R20-FUN067990-NLS:Tooltip of objects on Links Creation window is not translated. 
* @quickreview KIE1 ZUD     23:08:17  : IR-541421-3DEXPERIENCER2018x: Export to Word option Window is not translated.
 --%>
 
<%@page contentType="text/javascript; charset=UTF-8"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@page import="com.matrixone.apps.domain.util.Request"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import = "java.util.*,com.matrixone.apps.domain.util.*"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%@page import="com.dassault_systemes.requirements.UnifiedAutonamingServices"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%
response.setHeader("Cache-Control", "no-cache");
// Create context variable for use in pages
matrix.db.Context context = Framework.getFrameContext(session);
String doReconcile = EnoviaResourceBundle.getProperty(context, "emxRequirements.ImplementLink.DoReconcile");
// Is Cloud
boolean iscloud = UINavigatorUtil.isCloud(context);

String referer = request.getHeader("Referer"); 
// Only for the editable Web Form
boolean fromWebForm = (request.getRequestURI().indexOf("emxForm.jsp") >= 0 || request.getRequestURI().indexOf("emxFormEditDisplay.jsp") >= 0)&& "Edit".equalsIgnoreCase(request.getParameter("mode"));
boolean fromCreateForm = referer.indexOf("emxCreate.jsp") >= 0;		
boolean fromLegacyTable = referer.indexOf("emxTable.jsp") >= 0 || request.getRequestURI().indexOf("emxTableBody.jsp") >= 0;
boolean isEmbedded = referer.indexOf("isEmbedded=true") > 0;

String reqbundle = "emxRequirementsStringResource";
String CKEDITORLang = context.getLocale().toString(); //request.getHeader("Accept-Language");

if(fromWebForm || fromLegacyTable) {
%>
    <script language="JavaScript">
<%
}
%>
	if(localStorage['debug.AMD']) {
		var _RequirementAddExisting_js = _RequirementAddExisting_js || 0;
		_RequirementAddExisting_js++;
		console.info("RequirementAddExisting.jsp loaded " + _RequirementAddExisting_js + " times"); //, windows is " + window.location.href);
	}
	var doReconcile = <%=doReconcile%>;
    var isCloud = <%=iscloud%>;
    var bClickToSelect = true;
	var formatContentPreview = true;
	var autonameSeparator = "<%=UnifiedAutonamingServices.getAutonameSeparator(context)%>";
//    var TIMEOUT_VALUE = 50;
//   var RTF_FORMAT = 'rtf.gz.b64';
//    var HTML_FORMAT = 'html';


    var rmm_debug = <xss:encodeForJavaScript><%="true".equalsIgnoreCase(Request.getParameter(request, "rmm_debug"))%></xss:encodeForJavaScript>;
    var rmt_timeStamp = typeof timeStamp == "undefined" ? jQuery("#timeStamp").value : timeStamp;
//	var serverURLWithRoot = window.location.protocol + "//" + window.location.host + "/" + window.location.pathname.split( '/' )[1];
	
	var referer = "<%=XSSUtil.encodeForJavaScript(context, referer)%>";
	var fromWebForm = <%=fromWebForm%>;
	var fromCreateForm = <%=fromCreateForm%>;
    // JX5 Embedded SB & CATIA creation form
    var isSBEmbedded = <%=isEmbedded%>;
    
	var RMTConstants = new Object();
	RMTConstants.noSelectionWarning = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.ImportStructure.Alert.NoSelection") %>";
	var SBNextButtonText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Button.Next")%></xss:encodeForJavaScript>";
    <%--
       RichTextEditorStructure.js
    --%>
    
    var SBEditButtonText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Button.SBEdit")%></xss:encodeForJavaScript>";
    var SBEnableEditText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Button.SBEnableEdit")%></xss:encodeForJavaScript>";
    var SBEnableViewText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Button.SBEnableView") %></xss:encodeForJavaScript>";
    var SBOnlyOnePasteAllowedText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.CutPaste.OnlyOnePasteAllowed")%></xss:encodeForJavaScript>";
    var SBRecycleConnectionsOnReorderText = "<%=EnoviaResourceBundle.getProperty(context, "emxRequirements.CutPasteFeature.RecycleConnectionsOnReorder")%>"
    var SBCouldNotFindSourceSelectionText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Alert.CouldNotFindSourceSelection")%></xss:encodeForJavaScript>";
    var SBPleaseSelectOneItemOnlyText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", 
            context.getLocale(), "emxFramework.Common.PleaseSelectOneItemOnly")%></xss:encodeForJavaScript>";
    
    var labelPromoteToolBar = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Label.Promote")%></xss:encodeForJavaScript>";
     var labelDemoteToolBar = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Label.Demote")%></xss:encodeForJavaScript>";
    
    <%-- HAT1 ZUD IR-342686-3DEXPERIENCER2014x fix --%>     
     var SBOnlyOneTargetPasteAllowedText = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.CutPaste.OnlyOneTargetPasteAllowed")%></xss:encodeForJavaScript>";
    
    <%-- KIE1 ZUD PLM Parameter Migration --%>
    
    var NominalErrorAlert = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Parameter.NominalErrorAlert")%></xss:encodeForJavaScript>";
    var MinMaxErrorAlert = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Parameter.MinMaxErrorAlert")%></xss:encodeForJavaScript>";
    var MaximalStringValueError = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Parameter.MaximalStringValueError")%></xss:encodeForJavaScript>";
    var MinimalStringValueError = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Parameter.MinimalStringValueError")%></xss:encodeForJavaScript>";
    var NominalStringValueError = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.Parameter.NominalStringValueError")%></xss:encodeForJavaScript>";

<%-- Translation Issue KIE1 ZUD Start++ 
--%>
	var dragAndDrop = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", 
            context.getLocale(), "emxRequirements.Parameter.DragAndDrop")%></xss:encodeForJavaScript>";
    var doubleClickToEditType = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", 
            context.getLocale(), "emxRequirements.Parameter.doubleClickToEditType")%></xss:encodeForJavaScript>";
    <%--
        ++ IR-398721-3DEXPERIENCER2017x fix
    --%>
     var TestCaseNotValidated = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TestCaseValidationColumn.PromptTitle.TestCaseNotValidated")%></xss:encodeForJavaScript>";
     var TestCaseNotFullyValidated = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TestCaseValidationColumn.PromptTitle.TestCaseNotFullyValidated")%></xss:encodeForJavaScript>";
     var TestCaseValidationFailed = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TestCaseValidationColumn.PromptTitle.TestCaseValidationFailed")%></xss:encodeForJavaScript>";
     var TestCaseValidationPassed = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TestCaseValidationColumn.PromptTitle.TestCaseValidationPassed")%></xss:encodeForJavaScript>";    
     var TestCaseTableHeader = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TestCaseValidationColumn.PromptTitle.TestCaseTableHeader")%></xss:encodeForJavaScript>";    
    var TestCaseTableButtonOK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TestCaseValidationColumn.PromptButton.OK")%></xss:encodeForJavaScript>";    
    var TestCaseTableButtonCancel = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TestCaseValidationColumn.PromptButton.Cancel")%></xss:encodeForJavaScript>";    
    
    <%--
       Inline Data Entry Vars + Scripts loader
    --%>
    
    var strChapterRMT = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Type.Chapter")%>";
    var strCommentRMT = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Type.Comment")%>";
    var strRequirementRMT = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Type.Requirement")%>";
    var strRSRMT = "NOP";
    var strSRRMT = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Relationship.Sub_Requirement")%>";
    var strDRRMT = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Relationship.Derived_Requirement")%>";
    var strSSRMT = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Relationship.Specification_Structure")%>";
    var strNoneRMT = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.ImportStructure.Label.None")%>";
    var strErrorApplyRMT = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Alert.MustSelectType")%>";
    var strCannotCreateObjectInlineRMT = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Alert.CannotCreateObjectInline")%>";
	
	<%--
		Create Derivation Links between Requirements
	--%>
	var RefdlgTitle = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.derivationcmd.dlg.title.refinedinto")%></xss:encodeForJavaScript>";
	var CovDlgTitle = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.derivationcmd.dlg.title.coveredby")%></xss:encodeForJavaScript>";
	var SourceDlgLabel = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.derivationCmd.dlg.source")%></xss:encodeForJavaScript>";
	var TargetDlgLabel = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.derivationCmd.dlg.target")%></xss:encodeForJavaScript>";
	var AddTargetButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.derivationCmd.dlg.addTarget")%></xss:encodeForJavaScript>";
	var DeleteLinksButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.derivationCmd.dlg.DeleteDerLinks")%></xss:encodeForJavaScript>";
    var LegendDlgLabel  = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.derivationCmd.dlg.Legend")%></xss:encodeForJavaScript>"; 
    var refineLegLabel  = "<xss:encodeForJavaScript><%=MessageUtil.getMessage(context, null, "emxRequirements.derivationCmd.dlg.Legend.refine",
            new String[] {"R<sub>child</sub> ", " R<sub>parent</sub>"}, null, context.getLocale(), reqbundle)%></xss:encodeForJavaScript>";  
    var isRefinedLegLabel  = "<xss:encodeForJavaScript><%=MessageUtil.getMessage(context, null, "emxRequirements.derivationCmd.dlg.Legend.isrefined",
            new String[] {"R<sub>parent</sub> ", "  R<sub>child</sub>"}, null, context.getLocale(), reqbundle)%></xss:encodeForJavaScript>";      
	var coverLegLabel  = "<xss:encodeForJavaScript><%=MessageUtil.getMessage(context, null, "emxRequirements.derivationCmd.dlg.Legend.cover",
            new String[] {"R<sub>child</sub> ", " R<sub>parent</sub>"}, null, context.getLocale(), reqbundle)%></xss:encodeForJavaScript>";
    var isCoveredLegLabel  = "<xss:encodeForJavaScript><%=MessageUtil.getMessage(context, null, "emxRequirements.derivationCmd.dlg.Legend.iscovered",
            new String[] {"R<sub>parent</sub> ", " R<sub>child</sub>"}, null, context.getLocale(), reqbundle)%></xss:encodeForJavaScript>";    		
	var ReqSpecDependecyAlertTitle = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.ReqSpecDependecy")%></xss:encodeForJavaScript>";
	var ReqSpecDependecyCreateDependencyDlg = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.Alert.CreateDependency")%></xss:encodeForJavaScript>";
	var CreateDependencyYesButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.Alert.CreateDependencyYesButton")%></xss:encodeForJavaScript>";
	var CreateDependencyNoButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.Alert.CreateDependencyNoButton")%></xss:encodeForJavaScript>";
	var ExpandAllButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.ContextMenu.ExpandAll")%></xss:encodeForJavaScript>";
	var CollapseAllButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.ContextMenu.CollapseAll")%></xss:encodeForJavaScript>";
	var DeleteDependencylinkButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.ContextMenu.DeleteDependencylink")%></xss:encodeForJavaScript>";
    var DeleteDependencylinkAlert = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.ContextMenu.DeleteDependencylinkAlert")%></xss:encodeForJavaScript>";
	var DeletedDependencyAlert = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.ContextMenu.DeletedDependencyAlert")%></xss:encodeForJavaScript>";
	var NoDependencyAlert = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.TraceabilityManagementSettings.ContextMenu.NoDependencyAlert")%></xss:encodeForJavaScript>";
            
	var ManageReqSpecDependencies = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirements", 
            context.getLocale(), "emxRequirements.ManageReqSpecDependencies")%></xss:encodeForJavaScript>";
	
	<%-- HAT1 ZUD : IR-531749-3DEXPERIENCER2018x fix --%> 
	var strTitle = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            			context.getLocale(), "emxFramework.Attribute.Title")%></xss:encodeForJavaScript>";
	var strRevision = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
	           			context.getLocale(), "emxFramework.Basic.Revision")%></xss:encodeForJavaScript>";
	var strContent_Text = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
	           			context.getLocale(), "emxFramework.Attribute.Content_Text")%></xss:encodeForJavaScript>";

	<%-- Export To Word Option 
	--%>
	var wholeStructure = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", 
            context.getLocale(), "emxRequirements.ExportToWOrd.wholeStructure")%></xss:encodeForJavaScript>";
    var diplayedItems  = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", 
            context.getLocale(), "emxRequirements.ExportToWOrd.diplayedItems")%></xss:encodeForJavaScript>";
     <%--
       CheckConsistencyCmd.js //HL - Requirement Specification dependency. checkConsistency dialog buttons name.
     --%>   
     
	var CreateLinkButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.dlg.CreateLinksButton")%></xss:encodeForJavaScript>";

	var DeleteLinkButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.dlg.DeleteLinkButton")%></xss:encodeForJavaScript>";

	var CheckConsistencyTitle = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.SCE.Label.CheckConsistencyCmd")%></xss:encodeForJavaScript>";

	var CoveredRequirements = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.dlg.CoveredRequirements")%></xss:encodeForJavaScript>";

	var RefiningRequirements = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.dlg.RefiningRequirements")%></xss:encodeForJavaScript>";
            
    var SolveWarningInConsistencyAlert = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.Alert.SolveWarningInConsistencyAlert")%></xss:encodeForJavaScript>";

    var SolveErrorInConsistencyAlert = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.Alert.SolveErrorInConsistencyAlert")%></xss:encodeForJavaScript>";

    var SolveWarningInConsistencyDlgTitle = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.Alert.SolveWarningInConsistencyDlgTitle")%></xss:encodeForJavaScript>";

    var SolveErrorInConsistencyDlgTitle = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.Alert.SolveErrorInConsistencyDlgTitle")%></xss:encodeForJavaScript>";

	var ConsistencyDlgSolveButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.Alert.DlgSolveButton")%></xss:encodeForJavaScript>";
			
	var ConsistencyDlgCancelButton = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.checkConsistencyCmd.Alert.DlgCancelButton")%></xss:encodeForJavaScript>";
     
    var isSimplifiedForm = "<%=EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm")%>";
     
    
    var msg = "<%=EnoviaResourceBundle.getProperty(context,reqbundle, context.getLocale(),"emxRequirements.Alert.InvalidChars")%>";
    var arrBadChars = "<%= EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.NameBadChars").trim() %>";
    
    var exportTOWordOption = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            context.getLocale(), "emxRequirements.StructureBrowser.ExportToWordOption")%></xss:encodeForJavaScript>";

     <%--
       STRUCTURE EXPLORER
    --%>      
    var structureExplorerCloseSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.Close")%>";
    var structureExplorerOpenSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.Open")%>";
    var structureExplorerSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.Title")%>";
    var structureExplorerTooltipSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.Tooltip")%>";
    var structureExplorerDetailsSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.ContextMenu.Details")%>";
    var structureExplorerEditSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.ContextMenu.Edit")%>";
    var structureExplorerExpandSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.ContextMenu.Expand")%>";
    var structureExplorerCutSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.ContextMenu.Cut")%>";
    var structureExplorerCopySB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.ContextMenu.Copy")%>";
    var structureExplorerPasteSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.ContextMenu.Paste")%>";
    var structureExplorerDeleteSB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.StructureExplorer.ContextMenu.Delete")%>";
    var structureExplorerIssueMessage = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.GenericDelete.ErrorMessage")%>";

    var structureBrowserEditButton = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Toolbar.EditCells")%>";
    var structureBrowserViewButton = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Toolbar.BrowseCells")%>";
    var structureBrowserInsertNew =  "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Menu.RMTStructureBrowserCreate")%>";
    
    var strAllocationStatus = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Table.AllocationStatus")%>";
    var strPriority = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Table.Priority")%>";
    var strDifficulty = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Table.Difficulty")%>";
    var strLockState = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Form.Label.LockState")%>";
    var strActiveEC = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Table.ActiveEC")%>";
    var strStatus = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Table.Status")%>";
    var strCovered = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Label.CoveredBy")%>";
    var strRefining = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Label.Refined")%>";
    var strActiveCO = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Table.ActiveCO")%>";

    var strDndPasteOperation = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.DnDSB.PasteOperation")%>";
    var strDndPasteLocation = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.DnDSB.PasteLocation")%>";
    var strDndPasteTarget = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.DnDSB.Target")%>";
    var strDndPasteC = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.DnDSB.PasteC")%>";
    var strDndPasteB = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.DnDSB.PasteB")%>";
    
    var strdashBoardCmdLabel= "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.dashboard.RequirementsDashboard")%>";
    var strQuickCharts = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.dashboard.dashboard")%>";
    
    var childrenReqTypes = "<%=ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getRequirementType(context)).toString()%>";
    
    <%--
    	TOOLBAR BUTTONS   // HAT1 ZUD: IR-437663-3DEXPERIENCER2017x: fix
    --%>
    var requirementType = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
    			        context.getLocale(), "emxRequirements.RequirementStructureBrowser.Requirement")%></xss:encodeForJavaScript>";
    var commentType = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
    			        context.getLocale(), "emxRequirements.RequirementStructureBrowser.Comment")%></xss:encodeForJavaScript>";
    var testCaseType = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
    			        context.getLocale(), "emxRequirements.RequirementStructureBrowser.TestCase")%></xss:encodeForJavaScript>";
    var dblclkString = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
    			        context.getLocale(), "emxRequirements.tooltipButton.dblclkString")%></xss:encodeForJavaScript>";
    var strMaximize = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
    			        context.getLocale(), "emxRequirements.toolbarButton.maximize")%></xss:encodeForJavaScript>";
    var strMinimize = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            			context.getLocale(), "emxRequirements.toolbarButton.minimize")%></xss:encodeForJavaScript>";
    var strClose    = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            			context.getLocale(), "emxRequirements.toolbarButton.close")%></xss:encodeForJavaScript>";
    var strRestore  = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, reqbundle, 
            			context.getLocale(), "emxRequirements.toolbarButton.restore")%></xss:encodeForJavaScript>";
            			
            			
       <%--
       KIE1 ++IR-648590-3DEXPERIENCER2020x : Parameter Edit Dialog Translation
       --%>
       
       var minimalValue = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.SBParameter.MinimalParameter")%>";
       var maximalValue = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.SBParameter.MaximalParameter")%>";
       var parameterValue = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.SBParameter.ParameterValue")%>";
       var textOk = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.SBParameter.PromptButton.OK")%>";
       var textCancel = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.SBParameter.PromptButton.Cancel")%>";
       var displayUnit = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.SBParameter.PromptButton.DisplayUnit")%>";
    
    <%--
       CUSTOMIZED EXPAND
    --%>  
    var allLabel = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Filter.All")%>"
    var applyLabel = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.SCE.Button.Apply")%>" 
    var RMTLabels = new Array();
    RMTLabels.push("<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Label.SubRequirements")%>");
    RMTLabels.push("<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Tree.TestCase")%>");
    RMTLabels.push( "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.Label.Parameters")%>");
    var expandHint        = "<%=EnoviaResourceBundle.getProperty(context, reqbundle, context.getLocale(), "emxRequirements.customizeExpand.hint")%>";

    <%
    String[] parameters = referer.split("[&]");
    String table = "";
    String rootId = "";
    String rootType = "";
    for(int i=0;i<parameters.length;i++){
    	String param = parameters[i];
    	if(param.contains("table=")){
    		table = param.split("[=]")[1];
    	}
    	if(param.contains("objectId=")){
    		String[] splitted = param.split("[=]");
    		if(splitted.length>1){
    			rootId = param.split("[=]")[1];
    		}else{
    			rootId="";
    		}
    		
    		
    	}
    }
	
    if(rootId!=null&&rootId.length()>0){
    	DomainObject root = DomainObject.newInstance(context, rootId);
    	rootType = root.getType(context);
    }

    String selectedexpandFilter = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_expandFilter");
    if(selectedexpandFilter == null || selectedexpandFilter.isEmpty()){
  	  selectedexpandFilter = "All";
    }
    String selectedExpandTypes = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_expandTypes");
    if(selectedExpandTypes == null || selectedExpandTypes.isEmpty()){
    	selectedExpandTypes = "SubRequirements,TestCases,Parameters";
    }
    %>
    var RMTexpandTypes = ["SubRequirements","TestCases","Parameters"];
    var displayExpandAllFirstTime = true;
    var currentTable = "<%=table%>";
    var rootType = "<%=rootType%>";
    getTopWindow().RMTExpandFilter =  "<%=selectedexpandFilter%>";
	//START : LX6 : IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement.
    getTopWindow().expandFilterTypes = "<%=selectedExpandTypes%>";
    if("setRequestSetting" in window){
        getTopWindow().setRequestSetting = setRequestSetting;
    }
	//END : LX6 : IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement.

    
    if(window.emxEditableTable && isIE) {
    	//defer SB divToolbar drawing until it's instrumented
    	 var _init_original = toolbars.init;
    	
    	toolbars.init = function (toolbar) { //or instrument emxUIToolbar.prototype.init
    		if(toolbar != "divToolbar") {
    			toolbars.init['_deferred'].apply(toolbars, [toolbar]);
    		}
    		else{
			 	if(localStorage['debug.AMD']) {
					console.info("AMD: draw blank toolbar.");
				}
    		}
    		
    	} 
    	toolbars.init['_deferred'] = _init_original;

		jQuery(function(){ //hack: SB looks for 'find-in-wrapper' during init.
	    	jQuery('head').append('<div class="find-in-wrapper" ></div>');
		});
    }
    
    if(fromWebForm) {
    	//defer doLoad execution until it's instrumented
    	var _doLoad_original = doLoad;
    	doLoad = function () {
    		console.info("AMD: skip doLoad.");
    	}
    	
    	doLoad['_deferred'] = _doLoad_original;
    }

 
	require(['DS/RichEditor/RichEditor',               //EditInWord preferences
	         'DS/RichEditorCusto/Util',                //emxUICore.instrument
	         'DS/RichEditorCusto/RichEditorCusto',
	         'DS/ENORMTCusto/ENORMTCusto']);
	
    if(fromWebForm || fromCreateForm) {
    	require(['DS/ENORMTCustoForm/ENORMTCustoForm'], function(){
    		if(fromWebForm) {
    			doLoad = doLoad['_deferred'];
    			doLoad();
    		}
    	});
    }

    if(window.emxEditableTable)
    {
    	/* JS SCRIPTS for Dynatree */
		var jqueryUIJSLoader = document.createElement('script');
		jqueryUIJSLoader.src = "../requirements/scripts/plugins/jquery.ui-RMT.js";
		document.getElementsByTagName('head')[0].appendChild(jqueryUIJSLoader);
		jqueryUIJSLoader.onload = function() {
		    var dynatreeJSLoader = document.createElement('script');
		    dynatreeJSLoader.src = "../plugins/dynatree/1.2.6/jquery.dynatree.min.js";
		    document.getElementsByTagName('head')[0].appendChild(dynatreeJSLoader);
		};
		
		var cookieJSLoader = document.createElement('script');
		cookieJSLoader.src = "../common/scripts/jquery.cookie.js";
		document.getElementsByTagName('head')[0].appendChild(cookieJSLoader); 
		/* - JS SCRIPTS for Dynatree - */
		
		//make sure it's loaded before onLoad event
		var tooltipJSLoader = document.createElement('script');
		tooltipJSLoader.src = "../requirements/scripts/plugins/jquery.tooltip-RMT.js";
		document.getElementsByTagName('head')[0].appendChild(tooltipJSLoader);
		
    	require(['DS/ENORMTCustoSB/expandall',                 //expand all button custo
    			 'DS/ENORMTCustoSB/TestCase',                  //validation column loading
    			 'DS/ENORMTCustoSB/panelRightContext', 
    			 'DS/ENORMTCustoSB/toolbar',                   //toolbar and table header
    			 'DS/ENORMTCustoSB/tooltip', 
    			 'DS/ENORMTCustoSB/catia',                     //toolbar customization
    			 'DS/ENORMTCustoSB/explorerPanel',
    			 'DS/ENORMTCustoSB/SBRichEdit',                //rich text loading
    			 'DS/ENORMTCustoSB/parameter', 
    			 'DS/ENORMTCustoSB/RichTextEditorStructure'    //attach event handlers
    			], function() {
    				if(isIE) {
	    				jQuery(window).ready(function() {
		    				toolbars.init = toolbars.init['_deferred'];
		    				toolbars.init("divToolbar", true);
	    				});
    				}
    				
    			}); 
    	
    	//not time sensitive
    	require(['DS/ENORMTCustoSB/derivation', 'DS/ENORMTCustoSB/reorder']);
    	
    	if(referer && referer!= "null" && referer.indexOf("fromImportStructure") > 0) {
    		require(['DS/ENORMTCustoSB/ThreeStateCheckbox']);
    	}
    	
    }

    var csrfParams = "";
 <%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
	Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
	String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
%>
	var csrfTokenName = "<%=csrfTokenName%>";
	var csrfTokenValue = "<%=csrfTokenMap.get(csrfTokenName)%>";
    var csrfName = "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>";
    csrfParams = csrfName + "=" + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue;

	if(localStorage['debug.AMD']) {
		console.info("RequirementAddExisting.jsp finish"); 
	}

<%}

if(fromWebForm || fromLegacyTable) {%>
    </script>
<%}%>

 

