<%--  emxEngEBOMAddExistingProcess.jsp  - 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	String strLanguage = context.getSession().getLanguage();
	String I18NResourceBundle = "emxFrameworkStringResource";
	String objectId = emxGetParameter(request, "objectId");
	String table = emxGetParameter(request,"table");
	String hideHeader = emxGetParameter(request,"hideHeader");
	String selection = emxGetParameter(request,"selectionWizardMultiple");
	String excludeOIDWizardProgram = emxGetParameter(request,"excludeOIDWizardProgram");
	String cancelLabel = emxGetParameter(request,"cancelLabel");
	String submitLabel = emxGetParameter(request,"submitLabel");
	String submitURL = emxGetParameter(request,"submitWizardURL");
	String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");
	//Bug:370536 Starts
	String strRegSuite = emxGetParameter(request, "suiteKey");
	//Bug:370536 Ends
	boolean processFailed = false;
	String bomId= emxGetParameter(request,"parentOID");
	String sRelId="";
	String sEBOMPartId ="";
	String sEBOMRelId="";

	String sParentResult="";
	//Added variables for  IR-008697
	String type ="";
	String parentAlias ="";
try{
	if(selPartIds != null){
		for (int i=0; i < selPartIds.length ;i++){
			StringTokenizer strTokens = new StringTokenizer(selPartIds[i],"|");
			if (strTokens.hasMoreTokens()){
				
			    //Modified code for  IR-037432V6R2011-Starts
			    int count = strTokens.countTokens();
			    if(count==4){
			        sRelId = strTokens.nextToken();
			        sEBOMPartId = strTokens.nextToken();
			        //sEBOMPartId = strTokens.nextToken();
			        submitLabel = "emxEngineeringCentral.Common.Done";
			        cancelLabel = "emxEngineeringCentral.Common.Cancel";
			        
			    }else{
			    	sEBOMPartId = strTokens.nextToken();
			    }
				//Added for the IR-008697
				type = (DomainObject.newInstance(context,sEBOMPartId).getInfo(context,DomainConstants.SELECT_TYPE));
			    parentAlias  = FrameworkUtil.getAliasForAdmin(context, "type", type, true);
				// IR-008697 ends

				String sEBOMManuResRelIdResult=MqlUtil.mqlCommand(context,"print bus $1 select $2 dump $3",sEBOMPartId,"relationship[EBOM].id","|");
                                //Getting one by one all connected EBOM Rel Id in final StringList.
				StringList slEBOMRelId = FrameworkUtil.split(sEBOMManuResRelIdResult, "|");
				int size=slEBOMRelId.size();
					
				if(count!=4){
					for (i=0; i<size; i++){
						sEBOMRelId = (String)slEBOMRelId.get(i);

						sParentResult=MqlUtil.mqlCommand(context,"print connection $1 select $2 dump $3",sEBOMRelId,"from.id","|");
						if(sParentResult.equals(bomId)){
							sRelId=sEBOMRelId;
							break;
						}//End of if loop
					}//End of for loop
				}//End of count check loop
				//Modified code for  IR-037432V6R2011 -Ends
				}//End of if loop
			}//End of for loop
		}//End of if loop
		else{
			processFailed = true;
%>
<script language="Javascript">
alert("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18n>");
</Script>
<%
		}//End of else loop
	}//End of try Block
	catch(Exception ex)
	{

	processFailed = true;
	session.putValue("error.message", ex.toString());
	}//End of Catch Block
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript">
	//XSSOK
	var processFailed = <%=processFailed%>;
	//XSSOK
	var bomId = "<%=XSSUtil.encodeForJavaScript(context,bomId)%>";
	//XSSOK
	var sRelId = "<%=sRelId%>";
	//XSSOK
	var objectId = "<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
	//XSSOK
	var table = "<%=XSSUtil.encodeForJavaScript(context,table)%>";
	//XSSOK
	var hideHeader = "<%=XSSUtil.encodeForJavaScript(context,hideHeader)%>";
	//XSSOK
	var selection = "<%=XSSUtil.encodeForJavaScript(context,selection)%>";
	//XSSOK
	var excludeOIDWizardProgram = "<%=XSSUtil.encodeForJavaScript(context,excludeOIDWizardProgram)%>";
	//XSSOK
	var submitLabel = "<%=XSSUtil.encodeForJavaScript(context,submitLabel)%>";
	//XSSOK
	var submitURL = "<%=XSSUtil.encodeForJavaScript(context,submitURL)%>";
	//XSSOK
	var cancelLabel = "<%=XSSUtil.encodeForJavaScript(context,cancelLabel)%>";
	//XSSOK
	var sEBOMPartId = "<%=XSSUtil.encodeForJavaScript(context,sEBOMPartId)%>";
	//Bug:370536 Starts
	//XSSOK
	var strRegSuite = "<%=XSSUtil.encodeForJavaScript(context,strRegSuite)%>";
	//Added for  IR-008697
	//XSSOK
	var type = "<%=parentAlias%>";
	//Bug:370536 Ends
	if(!processFailed){
	//Added a Spare Part field for IR-008370
	//Modified the url for  IR-008697
	       //var sURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:SPARE_PART=No:Policy!=policy_ManufacturingPart:VERSION=FALSE&HelpMarker=emxhelpfullsearch&table="+table+"&hideHeader="+hideHeader+"&selection="+selection+"&submitURL="+submitURL+"&submitLabel="+submitLabel+"&cancelLabel="+cancelLabel+"&objectId="+objectId+"&bomId="+bomId+"&sRelId="+sRelId+"&sEBOMPartId="+sEBOMPartId+"&excludeOID="+sEBOMPartId+","+bomId+"&suiteKey="+strRegSuite;
	      var sURL = "../common/emxFullSearch.jsp?field=TYPES="+type+":SPARE_PART=No:Policy!=policy_ManufacturingPart,policy_ConfiguredPart,policy_ManufacturerEquivalent:VERSION=FALSE&HelpMarker=emxhelpfullsearch&table=ENCAffectedItemSearchResult&hideHeader="+hideHeader+"&selection="+selection+"&submitURL="+submitURL+"&submitLabel="+submitLabel+"&cancelLabel="+cancelLabel+"&objectId="+objectId+"&bomId="+bomId+"&sRelId="+sRelId+"&sEBOMPartId="+sEBOMPartId+"&excludeOID="+sEBOMPartId+","+bomId+"&suiteKey="+strRegSuite+"&header=emxEngineeringCentral.Search.SelectSubstitutePart&excludeOIDprogram=emxENCFullSearch:excludeOIDsForSub";    
	      //IR-008697 fix ends
	//getTopWindow().frames.location.href =sURL;
	parent.showModalDialog(sURL);
	parent.setSubmitURLRequestCompleted();
	//parent.close();
	}//End of if loop
</script>
