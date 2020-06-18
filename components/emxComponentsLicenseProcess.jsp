<%--  emxComponentsLicenseProcess.jsp  -  

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  Licence Process jsp to Assign and Remove license.
  	
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@ page import = "java.util.Map,
                   java.util.HashMap,
                   com.matrixone.apps.common.Person,
                   com.matrixone.apps.common.Company,
                   matrix.util.StringList,
                   com.matrixone.apps.domain.util.FrameworkUtil,
                   com.matrixone.apps.framework.ui.UIUtil,
                   java.util.StringTokenizer,
                   com.matrixone.apps.common.util.ComponentsUIUtil,
                   com.matrixone.jsystem.util.StringUtils,
                   com.matrixone.apps.common.util.ComponentsUtil,
                   com.matrixone.apps.domain.DomainObject,
                   com.matrixone.apps.domain.DomainConstants,
                   com.matrixone.apps.domain.util.MqlUtil,
                   matrix.db.JPO"%>
                   
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
	String action = emxGetParameter(request, "action");
	String actionPage = null;
	String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	boolean showError = false;
	String errMsg = null;
	String lang = request.getHeader("Accept-Language");
	boolean isAddLicense = "addLicense".equalsIgnoreCase(action);
	boolean isRemoveLicense = !isAddLicense && "removeLicense".equalsIgnoreCase(action);
	boolean isAddCasualLicense = "addCasualLicense".equalsIgnoreCase(action);
	boolean isMixedLic =false;

	if(UIUtil.isNullOrEmpty(action) || "showPersonSearch".equalsIgnoreCase(action)) {
	    StringBuffer sb = new StringBuffer();
	    String oldLicType = "";
		for(int i =0; !showError && i < arrTableRowIds.length; i++) {
			String strProductId = arrTableRowIds[i];
			StringList strList = FrameworkUtil.split(strProductId, "|");
			//Validate if the Row Id has any parent then user has selected persons also need to throw alert
			String _id = (String) strList.get(0);
			if(_id.indexOf("#") != -1){
				StringList licInfo = FrameworkUtil.split(_id, "#");
				_id = (String)licInfo.get(0);
				String licType = (String)licInfo.get(1);
				if(i>0 && !oldLicType.equals(licType)){
					isMixedLic = true;	
					showError = true;
					break;
				}
				oldLicType = licType;
			}
			String parentId = (String) strList.get(1);
			
			showError = !UIUtil.isNullOrEmpty(parentId);
			if(!showError) {
			    sb.append(_id).append(',');
			}
	  	}
		if(!showError) {
		    Map params = new HashMap();
		    if(FrameworkLicenseUtil.CASUAL_LICENSE.equalsIgnoreCase(oldLicType)){
		    	params.put("submitURL","../components/emxComponentsLicenseProcess.jsp?action=addCasualLicense");
		    }else{
		    params.put("submitURL","../components/emxComponentsLicenseProcess.jsp?action=addLicense");
		    }

		    Person contextPerson = Person.getPerson(context);
		    Company company = contextPerson.getCompany(context);
		    params.put("field", "TYPES=type_Person:CURRENT=policy_Person.state_Active:LICENSEDHOURS="+("CL".equalsIgnoreCase(oldLicType)?"40":"0"));    
		    if(sb.length() > 0)
		        sb.deleteCharAt(sb.length() - 1);
		    params.put("products", sb.toString());
		    actionPage = ComponentsUIUtil.getPersonSearchFTSURL(params);
		} else {
			errMsg = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.Common.PleaseSelectProduct", lang);
		    if(isMixedLic){
		    	errMsg = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.Common.PleaseSelectOneTypeProduct", lang);
		    }
		}
	} else if(isAddLicense) {
	    
	    arrTableRowIds = ComponentsUIUtil.getSplitTableRowIds(arrTableRowIds);
	    String []userNames = StringUtils.split(ComponentsUtil.getPersonNameAndFullName(context, arrTableRowIds)[0], ",");
	    String[] products = StringUtils.split(emxGetParameter(request, "products"), ",");
	    try {
	        ComponentsUtil.assignLicenses(context, products, userNames);
	    } catch (Exception exp) {
	        showError = true;
	        errMsg = exp.getMessage();
	    }
	} else if(isAddCasualLicense) {
	    
	    arrTableRowIds = ComponentsUIUtil.getSplitTableRowIds(arrTableRowIds);
	    String []userNames = StringUtils.split(ComponentsUtil.getPersonNameAndFullName(context, arrTableRowIds)[0], ",");
	    String[] products = StringUtils.split(emxGetParameter(request, "products"), ",");
	    try {
	        ComponentsUtil.assignCasualLicenses(context, products, userNames);
	    } catch (Exception exp) {
	        showError = true;
	        errMsg = exp.getMessage();
	    }
	} else if(isRemoveLicense) {
	    try {
	        ComponentsUtil.removeLicenses(context, arrTableRowIds, lang);
	    } catch (Exception exp) {
	        showError = true;
	        errMsg = exp.getMessage();
	    }
	}
	    
%>
 <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
	<script language="JavaScript">
		//XSSOK
		var showError = "true" == "<%=showError%>";
		var isMixedLic = "true" == "<%=isMixedLic%>";
		//XSSOK
		var pageRedirect = "false" == "<%=UIUtil.isNullOrEmpty(XSSUtil.encodeForJavaScript(context, actionPage))%>";
		var isAddLicense = "true" == "<%=isAddLicense%>";
		var isAddCasualLicense = "true" == "<%=isAddCasualLicense%>";
		var isRemoveLicense = "true" == "<%=isRemoveLicense%>";
		
		if(showError) {
			alert('<%=XSSUtil.encodeForJavaScript(context, errMsg)%>');
			if(!isRemoveLicense){
				if(!isMixedLic)  
				parent.closeWindow();
			}
		} else {
			if(pageRedirect) {
				showModalDialog('<%=XSSUtil.encodeForJavaScript(context, actionPage)%>');
			} else {
				if(isAddLicense || isAddCasualLicense) {
					var frameToRefresh = openerFindFrame(getTopWindow(), "content");
					frameToRefresh.location.href = frameToRefresh.location.href;
					getTopWindow().close();
				} else if(isRemoveLicense) {
					var rowsSelected = "<%=XSSUtil.encodeForJavaScript(context, ComponentsUIUtil.arrayToString(arrTableRowIds, "~"))%>";
					parent.emxEditableTable.removeRowsSelected(rowsSelected.split("~"));
				}
			}
		}
	</script>

