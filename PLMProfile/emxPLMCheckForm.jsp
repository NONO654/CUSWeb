<%--	emxParseBusinessRule.jsp	-	Search summary frameset

	Copyright (c) 1992-2011 Dassault Systemes.
	All Rights Reserved.
	This program contains proprietary and trade secret information of MatrixOne, Inc.
	Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

	 static const char RCSID[] = $Id: emxEngrCommonPartSearchResultsFS.jsp.rca 1.22 Wed Oct 22 15:51:49 2008 przemek Experimental przemek $
--%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List"%>
<%@ page import="java.lang.String" %>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@	include file = "../emxUICommonHeaderBeginInclude.inc" %>
<jsp:useBean id="emxPLMCheck" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
	System.out.println("Begin emxPLMCheckForm.jsp");
	
	String mode = emxGetParameter(request,"mode");
	System.out.println("mode "+mode);
	if(mode == null) {
		mode = "edit";
	}

	String languageStr      = request.getHeader("Accept-Language");
	String HelpMarker = "emxhelpfindselect";
	
	String roleList ="role_GlobalUser";
	String formHeader = null;
	String commandStr = null;
	String formId = emxGetParameter(request,"formId");
	System.out.println("formId "+formId);
	if(formId == null) {
		formId = "PLMCheckModifyWebForm";
	}

	String custo = "";
	
	
	String parentId = emxGetParameter(request,"parentOID");
	System.out.println("parentId "+parentId);
	String objectId = emxGetParameter(request,"objectId");
	System.out.println("objectId "+objectId);
	
	String contentURL = "emxPLMRuleEditorWithAjax.jsp"; 
	contentURL += "?mode=" + mode;
	contentURL += "&form=" + formId;
	String typeEdit = "";
	String typeModel = "";

	if(mode.equals("edit")) {
		HashMap programMap = new HashMap();
		HashMap paramMap = new HashMap();
		programMap.put("paramMap", paramMap);
		paramMap.put("objectId",objectId);
		StringList retour = (StringList)JPO.invoke(context, "emxPLMRuleEditor", null, "getListType", JPO.packArgs(programMap), StringList.class);
		typeEdit = (String)retour.firstElement();
		typeModel = (String)retour.lastElement();
		commandStr = EnoviaResourceBundle.getProperty(context, "emxComponents.Common.Done", "emxComponentsStringResource", languageStr);
		contentURL += "&typeModel=" + typeModel;
		contentURL += "&objectId=" + objectId;
		//kindof
	} else if(mode.equals("create")){
		String sRelId = "";
		String sObjId = "";
		String onCreate = emxGetParameter(request,"onCreate");
		System.out.println("onCreate "+onCreate);
		if(onCreate == null){
			onCreate = "close";
		}
		contentURL += "&onCreate=" + onCreate;
		String rootMode = emxGetParameter(request,"root");
		typeEdit = emxGetParameter(request,"typeEdit");
		typeModel = typeEdit;
		/*if(rootMode != null && rootMode.equals("true")){
			sRelId = "";
		} else {*/
			String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
			/*for(int i=0;i<selectedId.length;i++) {
				System.out.println("selectedId "+selectedId[i]);
			}*/
			if(selectedId != null ) {
				if(selectedId[0].indexOf("|") != -1) {
					StringTokenizer st = new StringTokenizer(selectedId[0], "|");
					sRelId = st.nextToken();
					sObjId = st.nextToken();
				} else {
					sObjId = selectedId[0];
				}
				HashMap programMap = new HashMap();
				HashMap paramMap = new HashMap();
				programMap.put("paramMap", paramMap);
				paramMap.put("objectId",sRelId);
				StringList retour = (StringList)JPO.invoke(context, "emxPLMRuleEditor", null, "getListType", JPO.packArgs(programMap), StringList.class);
				if(!retour.contains("PLMRuleSet")) {
					sRelId = sObjId;
				}
			}
		//}
		
		commandStr = UINavigatorUtil.getI18nString("emxComponents.Common.Create", "emxComponentsStringResource", languageStr);
		contentURL += "&typeEdit="+typeEdit;
		parentId = sRelId;
	} else if(mode.equals("attach")) {
		//que me faut t'il ? ID du nouvel attachement (father), id de l'objet courant à attacher
		// check si déjà attaché au même endroit (à vérifier : attacher à lui même ?)
		commandStr = "Attacher";
	}
	
		String img = "";
		if(typeEdit.equals("PLMCheck")) {
			img = "<img border='0' src='../common/images/I_Kwe2_ExpertCheck.png' width='22' height='22'></img>";
		} else if(typeEdit.equals("PLMRule")) {
			img = "<img border='0' src='../common/images/I_Kwe2_ExpertRule.png' width='22' height='22'></img>";
		} else if(typeEdit.equals("PLMRuleSet")) {
			img = "<img border='0' src='../common/images/I_Kwe2_ExpertRuleSet.png' width='22' height='22'></img>";
		} else {
			img = "<img border='0' src='../common/images/I_Kwe2_Unknow.png' width='22' height='22'></img>";
		}
		
		formHeader = img+" "+commandStr+" "+typeModel+".";
		
		contentURL += "&formHeader=" + formHeader;
		
		contentURL += "&parentId="+parentId;
		
		framesetObject fs = new framesetObject();
		fs.removeDialogWarning();
		fs.setStringResourceFile("emxComponentsStringResource");
		fs.initFrameset(formHeader,HelpMarker,contentURL,false,true,false,false);
		if(mode.equals("edit")) {
			fs.createFooterLink("emxComponents.Button.Approve","check(false, 0)",roleList,false,true,"common/images/buttonDialogApply.gif",1);
			fs.createFooterLink("emxComponents.Button.Modify","check(true, 1)",roleList,false,true,"common/images/buttonDialogDone.gif",0);
			fs.createFooterLink("emxComponents.Common.Cancel","close(false)",roleList,false,true,"common/images/buttonDialogCancel.gif",5);
		} else if (mode.equals("create")) {
			fs.createFooterLink("emxComponents.Button.Create","createEntity()",roleList,false,true,"common/images/buttonDialogDone.gif",0);
			fs.createFooterLink("emxComponents.Common.Cancel","close(true)",roleList,false,true,"common/images/buttonDialogCancel.gif",5);
		} else if(mode.equals("attach")) {
			fs.createFooterLink("Attach","attachEntity()",roleList,false,true,"common/images/buttonDialogDone.gif",0);
			fs.createFooterLink("emxComponents.Common.Cancel","close(true)",roleList,false,true,"common/images/buttonDialogCancel.gif",5);
		}
		
		
		System.out.println("contentUrl "+contentURL);
		System.out.println("End emxPLMCheckForm.jsp");
		
		fs.writePage(out);
	
%>
