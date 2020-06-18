<%--  emxengrMergeMarkupProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.*"%>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil"%>


<%
String mode   = emxGetParameter(request, "mode");
try
{

	//ContextUtil.pushContext(context);
	String changeObjectId=(String)session.getAttribute("changeObjectId");	
	String[] emxTableRowIds=(String[])session.getAttribute("emxTableRowIds");
	//Use this variable to check if similar type of markups are selected
	String sResPrevType = null;
	String sPrevPlantId = null;
	String sCurrPlantId = null;
	String sResPrevChangeId = null; //Added for ENG Convergence
	String RELATIONSHIP_APPLIED_MARKUP = PropertyUtil.getSchemaProperty(context,"relationship_AppliedMarkup");
		
	String  currentState = "";
	 String POLICY_ECO = PropertyUtil.getSchemaProperty(context, "policy_ECO");
	 String POLICY_ECR = PropertyUtil.getSchemaProperty(context, "policy_ECR");
	 String createState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Create");
	 String submitState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Submit");
	 String evaluateState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Evaluate");
	 String reviewState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Review");
	 String defineState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECO, "state_DefineComponents");
	 String designState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECO, "state_DesignWork");
	String TYPE_BOMMARKUP=PropertyUtil.getSchemaProperty(context,"type_BOMMarkup");
	String TYPE_ITEMMARKUP=PropertyUtil.getSchemaProperty(context,"type_ItemMarkup");//Added ENG Convergence
	
	String POLICY_PARTMARKUP=PropertyUtil.getSchemaProperty("policy_PartMarkup");
	String MARKUP_STATE_PROPOSED = PropertyUtil.getSchemaProperty("policy", POLICY_PARTMARKUP, "state_Proposed");
	String MARKUP_STATE_APPROVED = PropertyUtil.getSchemaProperty("policy", POLICY_PARTMARKUP, "state_Approved");
	String ATTRIBUTE_RELEASE_PHASE = PropertyUtil.getSchemaProperty("attribute_ReleasePhase");
	String ATTRIBUTE_RELEASE_PHASE_VALUE = "attribute["+ATTRIBUTE_RELEASE_PHASE+"].value";
	
        String TYPE_EBOMMARKUP=PropertyUtil.getSchemaProperty(context,"type_EBOMMarkup");
	String TYPE_PLANTBOMMARKUP=PropertyUtil.getSchemaProperty(context,"type_PlantBOMMarkup");
	String strAttrPlantID = PropertyUtil.getSchemaProperty(context,"attribute_PlantID");
	String language  = request.getHeader("Accept-Language");

	 DomainObject dObj = new DomainObject(changeObjectId);
	 
	 currentState = dObj.getInfo(context,DomainConstants.SELECT_CURRENT);
	 String strTypeName = dObj.getTypeName();
	 String strObjectName = dObj.getName();
	
	String strPolicy = dObj.getInfo(context,DomainConstants.SELECT_POLICY);
	String strPolicyClass = EngineeringUtil.getPolicyClassification(context, strPolicy);

	StringList changeIds=new StringList(1);
	changeIds.addElement(changeObjectId);
	
	String strRelPhasevalue = dObj.getInfo(context,ATTRIBUTE_RELEASE_PHASE_VALUE);
	HashMap finalMap=new HashMap();

if(DomainConstants.TYPE_ECR.equalsIgnoreCase(strTypeName)||DomainConstants.TYPE_ECO.equalsIgnoreCase(strTypeName))
{	
  if(((strTypeName.equals(DomainConstants.TYPE_ECR))&&(currentState.equals(createState)||currentState.equals(submitState)||currentState.equals(evaluateState)||currentState.equals(reviewState))) ||
	 ((strTypeName.equals(DomainConstants.TYPE_ECO))&&(currentState.equals(createState)||currentState.equals(defineState)||currentState.equals(designState))))
	{
			StringList objectList = new StringList();
			StringList programMap =new StringList();
			String partObjectId = "";
			String temp = "";
			int sRowIdsCount = emxTableRowIds.length;
			String mkpBase="";
			String MkpId="";
			boolean bflag=true;
		    if (sRowIdsCount > 0)
			{
					for(int count=0; count < sRowIdsCount; count++)
					{
						 temp =  emxTableRowIds[count];
						 objectList = FrameworkUtil.split(temp,"|");
						 partObjectId = (String)objectList.elementAt(1) ;				 
						 programMap.addElement(partObjectId);
					}	
					
					mkpBase=(String)programMap.get(0);
					DomainObject mkpBaseObject = new DomainObject(mkpBase);
					
					String sResult=mkpBaseObject.getInfo(context,"to["+DomainConstants.RELATIONSHIP_EBOM_MARKUP+"].from.id");
					
					Iterator mkpBaseItr=programMap.iterator();
					while(mkpBaseItr.hasNext())
					{	
						MkpId = (String)mkpBaseItr.next();
						DomainObject markupdObj = new DomainObject(MkpId);
						
						String sRes=markupdObj.getInfo(context,"to["+DomainConstants.RELATIONSHIP_EBOM_MARKUP+"].from.id");
						String sResType=markupdObj.getInfo(context,DomainConstants.SELECT_TYPE);
						
						String sResChangeId = markupdObj.getInfo(context,"to["+RELATIONSHIP_APPLIED_MARKUP+"].from.id"); //Added for ENG Convergence					
						String sMarkupState = markupdObj.getInfo(context,DomainConstants.SELECT_CURRENT); //Added for ENG Convergence
						
						if(!sResult.equalsIgnoreCase(sRes))
						{ 
							bflag=false;
								// Written to Show if selected Rows are for Different affected Items 
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.MergeMarkup</emxUtil:i18nScript>");
						</script>
							
						<%}

							// Added if selected Rows are of different Type,Dev Parts Dosent require this check as they do not have Imarkup
						//if(!TYPE_BOMMARKUP.equalsIgnoreCase(sResType) && !TYPE_EBOMMARKUP.equalsIgnoreCase(sResType))
						if(sResPrevType!= null && !sResPrevType.equals(sResType))
						{
							bflag=false;
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.SelectSameTypeMarkups</emxUtil:i18nScript>");
						</script>
							<%
                                                       break;
							
						} //Added for ENG Convergence start
						else if(sResPrevType!= null && sResPrevType.equals(sResType) && ("Item Markup").equals(sResPrevType)){ 							
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeItemMarkups</emxUtil:i18nScript>");
						</script>
							<%
							break;
						}
						if(UIUtil.isNullOrEmpty(sResChangeId))
						{						
							bflag=false;
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeNoCRConnected</emxUtil:i18nScript>");
						</script>
							<%
                                                       break;
							
						}
							
						if(sResPrevChangeId!= null && !sResPrevChangeId.equals(sResChangeId))
						{						
							bflag=false;
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeDifferentCRMarkups</emxUtil:i18nScript>");
						</script>
							<%
                                                       break;
							
						}
						
						if(sMarkupState!= null && !"".equals(sMarkupState) 
								&& (!sMarkupState.equals(MARKUP_STATE_PROPOSED) && !sMarkupState.equals(MARKUP_STATE_APPROVED)))
						{						
							bflag=false;
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeRejectedMarkup</emxUtil:i18nScript>");
						</script>
							<%
                                                       break;
							
						}
							
						//Added for ENG Convergence End
						
						//Added check for Plant BOM Markups of same plant
						if(sResType.equals(TYPE_PLANTBOMMARKUP))
						{
							sCurrPlantId = markupdObj.getInfo(context,"attribute["+strAttrPlantID+"]");
							if(sPrevPlantId != null && !sCurrPlantId.equals(sPrevPlantId)) {
								bflag=false;
								
								//Multitenant
								//String strSamePlantBOMsMsg = i18nNow.getI18nString("emxMBOM.Markup.SelectPlantBOMMarkupsOfSamePlant","emxMBOMStringResource", language);
								String strSamePlantBOMsMsg =EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Markup.SelectPlantBOMMarkupsOfSamePlant"); 

							%>
								<script>
								//XSSOK
								alert('<%=strSamePlantBOMsMsg%>');
								</script>
							<%
							}
							sPrevPlantId = sCurrPlantId;
						}
						//store the previous type for checking in the next loop
						sResPrevType = sResType;
						sResPrevChangeId = sResChangeId; //Added for ENG Convergence						
					}
				    if(bflag)
				    {
						if(sResPrevType.equals(TYPE_BOMMARKUP) || sResPrevType.equals(TYPE_EBOMMARKUP)) {
							String jpoName = "emxPartMarkup";
							String methodName = "";
							methodName = "mergeMarkup";
							finalMap.put("chhId",changeIds);
							finalMap.put("programMap",programMap);
							
							finalMap.put("COId",sResPrevChangeId);//Add for ENG Convergence							
							finalMap.put("mode",mode);
							//JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(programMap),void.class);
							JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(finalMap),void.class);
						} else if(sResPrevType.equals(TYPE_PLANTBOMMARKUP)) {
							String jpoName = "emxPartMarkup";
							String methodName = "mergePlantBOMMarkups";
							finalMap.put("chhId",changeIds);
							finalMap.put("programMap",programMap);
							JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(finalMap),void.class);						
						} else { 
							//no-use else. use for merge of Plant Item Markup
						}
				   }
				   
			   }
	}
}

// For Dev Parts
	else
	{
		StringList objectList = new StringList();
		StringList programMap =new StringList();
		String partObjectId = "";
		String temp = "";
		int sRowIdsCount = emxTableRowIds.length;
		String mkpBase="";
		String MkpId="";
		boolean bflag=true;
		if (sRowIdsCount > 0)
		{
					 for(int count=0; count < sRowIdsCount; count++)
					 {
						 temp =  emxTableRowIds[count];
						 objectList = FrameworkUtil.split(temp,"|");
						 partObjectId = (String)objectList.elementAt(1) ;					 
						 programMap.addElement(partObjectId);
					 }
					mkpBase=(String)programMap.get(0);
					DomainObject mkpBaseObject = new DomainObject(mkpBase);
					
					String sResult=mkpBaseObject.getInfo(context,"to["+DomainConstants.RELATIONSHIP_EBOM_MARKUP+"].from.id");
					
					Iterator mkpBaseItr=programMap.iterator();
					while(mkpBaseItr.hasNext())
					{
						MkpId = (String)mkpBaseItr.next();
						DomainObject markupdObj = new DomainObject(MkpId);
						String sResType=markupdObj.getInfo(context,DomainConstants.SELECT_TYPE);					
						String sRes=markupdObj.getInfo(context,"to["+DomainConstants.RELATIONSHIP_EBOM_MARKUP+"].from.id");
						
						String sResChangeId = markupdObj.getInfo(context,"to["+RELATIONSHIP_APPLIED_MARKUP+"].from.id"); //Added for ENG Convergence
						String sMarkupState = markupdObj.getInfo(context,DomainConstants.SELECT_CURRENT); //Added for ENG Convergence
												
						if(!sResult.equalsIgnoreCase(sRes))
						{ 
							bflag=false;

							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.MergeMarkup</emxUtil:i18nScript>");
						</script>
							
						<%
                                                break;}
						if(sResPrevType!= null && !sResPrevType.equals(sResType))
						{
							bflag=false;
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.SelectSameTypeMarkups</emxUtil:i18nScript>");
						</script>
							<%
							break;
						}
						//Add for ENG Convergence Start
						else if(sResPrevType!= null && sResPrevType.equals(sResType) && ("Item Markup").equals(sResPrevType)){ 						
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeItemMarkups</emxUtil:i18nScript>");
						</script>
							<%
							break;
						}
						if(UIUtil.isNotNullAndNotEmpty(strPolicyClass) && !strPolicyClass.equalsIgnoreCase("Development") && !strRelPhasevalue.equalsIgnoreCase("Development")) { //Added for IR-266941
							if(UIUtil.isNullOrEmpty(sResChangeId))
							{							
								bflag=false;
								%>
								<script>
							alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeNoCRConnected</emxUtil:i18nScript>");
							</script>
								<%
														   break;
								
							}
						}
						
						if(sResPrevChangeId!= null && !sResPrevChangeId.equals(sResChangeId))
						{							
							bflag=false;
							%>
							<script>
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeDifferentCRMarkups</emxUtil:i18nScript>");
						</script>
							<%
                                                       break;							
						}
						if(sMarkupState!= null && !"".equals(sMarkupState) 
								&& (!sMarkupState.equals(MARKUP_STATE_PROPOSED) && !sMarkupState.equals(MARKUP_STATE_APPROVED)))
						{						
								bflag=false;
								%>
								<script>
							alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.CannotMergeRejectedMarkup</emxUtil:i18nScript>");
							</script>
								<%
	                                                       break;								
						}							
						 //Add for ENG Convergence End
						//store the previous type for checking in the next loop
						sResPrevType = sResType;
						sResPrevChangeId = sResChangeId;						
						
					}
					if(bflag)
				   {
						if(sResPrevType.equals(TYPE_BOMMARKUP)|| sResPrevType.equals(TYPE_EBOMMARKUP)) {
							String jpoName = "emxPartMarkup";
							String methodName = "";
							methodName = "mergeMarkup";
							finalMap.put("chhId",changeIds);
							finalMap.put("programMap",programMap);
							
							finalMap.put("COId",sResPrevChangeId);//Add for ENG Convergence
							finalMap.put("mode",mode);
							
							//JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(programMap),void.class);
							JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(finalMap),void.class);
						} else if(sResPrevType.equals(TYPE_PLANTBOMMARKUP)) {
							String jpoName = "emxPartMarkup";
							String methodName = "mergePlantBOMMarkups";
							finalMap.put("chhId",changeIds);
							finalMap.put("programMap",programMap);
							JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(finalMap),void.class);						
						} else { 
							//no-use else. use for merge of Plant Item Markup
						}
				   }
			}
	}
//ContextUtil.popContext(context);	
}
catch (Exception ex)
{
}
%>
<%@ include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<Script language="JavaScript">
//top.refreshTablePage();
//Added for IR-146926


if ("mergeFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>") {
	parent.closeWindow();
	parent.window.getWindowOpener().location = parent.window.getWindowOpener().location;
} else {
	parent.window.location = parent.window.location;
}

</Script>
<%@ include file = "../emxUICommonEndOfPageInclude.inc"%>
