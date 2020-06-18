<%
	response.setContentType("text/xml");
	response.setContentType("charset=UTF-8");
	response.setHeader("Content-Type", "text/xml");
	response.setHeader("Cache-Control", "no-cache");
	response.getWriter().write("<?xml version='1.0' encoding='iso-8859-1'?>");
%>
<%--
	//@fullReview  YXJ 12/01/01 Extraction from emxPLMOnlineAdminXPAjaxParam.jsp
--%>
<%@ page import="java.util.*"%>
<%@ page import="java.lang.Integer"%>

<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.TeamAttributeCustomize"%>
<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.AttributeProperties"%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%
	String finalNameString = "<root>";
	String iObjectType = emxGetParameter(request,"iObjectType");
	String iDeployType = emxGetParameter(request,"iDeployType");
	String retmessageDM = "0";
	String errorMessage = "";

	int nbnewattributes = Integer.parseInt(emxGetParameter(request, "nbaddedattributes"));
	int nbmodattributes = Integer.parseInt(emxGetParameter(request, "nbmodattributes"));
	if (nbnewattributes>=0)
	{
		TeamAttributeCustomize TAC = new TeamAttributeCustomize(context);
		AttributeProperties[] listofNewAttributes;
		listofNewAttributes = new AttributeProperties[nbnewattributes];
		for (int i=0; i<listofNewAttributes.length;i++)
			listofNewAttributes[i] = new AttributeProperties();

		for (int i=0 ; i<nbnewattributes ; i++)
		{
			listofNewAttributes[i].setContext(context);
			listofNewAttributes[i].setCollectionID(iObjectType);
			listofNewAttributes[i].setAttributeType(	emxGetParameter(request, "iType_"     + i));
			listofNewAttributes[i].setAttributeLength(	emxGetParameter(request, "iLen_"      + i));
			listofNewAttributes[i].setUserName(	        emxGetParameter(request, "iName_"     + i));
			listofNewAttributes[i].setDefaultValue(		emxGetParameter(request, "iValue_"    + i));
			listofNewAttributes[i].setAuthorizedValues( "true".equalsIgnoreCase(emxGetParameter(request, "iAuthOrHelpFlag_" + i)));
			listofNewAttributes[i].setValuesListString( emxGetParameter(request, "iAuthOrHelpValues_" + i));
			listofNewAttributes[i].setReadOnly(         "true".equalsIgnoreCase(emxGetParameter(request, "iReadOnlyStatus_" + i)));
			listofNewAttributes[i].setMandatory(        "true".equalsIgnoreCase(emxGetParameter(request, "iMandatoryStatus_" + i)));
			listofNewAttributes[i].setIndexed(          "true".equalsIgnoreCase(emxGetParameter(request, "iIndexedStatus_" + i)));
			listofNewAttributes[i].setSixWTag(          emxGetParameter(request, "iSixWTag_"  + i));
		}
		int iretDM = 0;
		if ("StoreAndDeploy".equalsIgnoreCase(iDeployType))
			iretDM = TAC.setAddedAttributes(iObjectType,listofNewAttributes, nbmodattributes);
		else
			iretDM = TAC.saveAddedAttributes(iObjectType,listofNewAttributes);
		retmessageDM = String.valueOf(iretDM);
		errorMessage = TAC.getErrorMessage();
	}

	finalNameString += "<dataModelUpdate>" + retmessageDM + "</dataModelUpdate>";
	finalNameString += "<dataModelSetType>" + iDeployType + "</dataModelSetType>";
	finalNameString += "<dataModelErrorMessage>" + errorMessage + "</dataModelErrorMessage>";
	
	String commandtofreeze = "ParameterizationAttributeDef_" + iObjectType;
	if ("true".equalsIgnoreCase(emxGetParameter(request,"frzStatus")) && "SUCCESS".equals(retmessageDM))
	{
		FreezeServerParamsSMB Frz4 = new FreezeServerParamsSMB();
		int iret4 = Frz4.SetServerFreezeStatusDB(context,commandtofreeze);
		if (iret4 == Frz4.S_SUCCESS)
			finalNameString += "<Freezeret>S_OK</Freezeret>";
		else if (iret4 == Frz4.E_INTERNAL_ERROR)
			finalNameString += "<Freezeret>E_Internal</Freezeret>";
		else
			finalNameString += "<Freezeret>E_Frozen</Freezeret>";
	}
	finalNameString += "</root>";
	response.getWriter().write(finalNameString);

%>
