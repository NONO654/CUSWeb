<%--  emxProgramCentralFolderCreatePreProcess.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxProgramCentralFolderCreatePreProcess.jsp.rca 1.1.1.3.3.2.2.1 Wed Dec 24 10:59:12 2008 ds-ksuryawanshi Experimental $

 --%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file= "emxProgramCentralCommonUtilAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%

     com.matrixone.apps.program.ProjectSpace project =
   (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, "PROGRAM");

     String parentObjectId    = emxGetParameter(request,"parentOID");
     String objectId    = emxGetParameter(request,"emxTableRowId");
     
  // Added:12-Feb-09:NZF:R207:Bug :367017
     String isClone = emxGetParameter(request,"IsClone");
     //Added:4-June-2010:rg6:R210 PRG:IR-053998V6R2011x
     boolean isCloneOperation = "true".equalsIgnoreCase(isClone); //15-Jun-2011:PRG:RG6:110242V6R2012x/112931V6R2012x
   //Added 6-July-2010:rg6:IR-058924
    String strLanguage = request.getHeader("Accept-Language");//Modified :PRG:RG6:R212:30-Jun-2011
    Map map =request.getParameterMap();
    String [] selctedObjList = (String [])map.get("emxTableRowId");
    if(selctedObjList != null) {
        if(selctedObjList.length > 1){
            String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
      			  "emxProgramCentral.Common.CannotPerformAction", strLanguage);
               %>
               
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><script language="JavaScript" type="text/javascript">
                                               alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                               getTopWindow().closeSlideInDialog(); // [MODIFIED::PRG:RG6:Mar 8, 2011:IR-098164V6R2012 :R211::change for slidein window]
                                           </script>
               <%return;     
       }
    
    }
    
  //End 6-July-2010:rg6:IR-058924
  // Added PRG:RG6:R212:10-May-2011:IR-106716V6R2012x
  
  Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,objectId);
  String rowId = "";
  String sClonnedParentOId = ""; //PRG:RG6:R212:110242V6R2012x/112931V6R2012x
  if(null != mParsedObject)
    {
	 objectId = (String)mParsedObject.get("objectId");
	 parentObjectId = XSSUtil.encodeURLForServer(context,(String)mParsedObject.get("parentOId"));
	 sClonnedParentOId = parentObjectId;  //PRG:RG6:R212:110242V6R2012x/112931V6R2012x 
	 rowId = (String)mParsedObject.get("rowId");
	 if("0".equalsIgnoreCase(rowId) && isCloneOperation)  // root folder can not be cloned
        {
         String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
   			  "emxProgramCentral.Folders.CloneFolder.RootFolderClone", strLanguage);
  %>
        <script language="JavaScript" type="text/javascript">
                                         alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                         getTopWindow().closeSlideInDialog(); // [MODIFIED::PRG:RG6:Mar 8, 2011:IR-098164V6R2012 :R211::change for slidein window]
        </script>
  <%      return;   
    }
  }
  else
        {
	   objectId = emxGetParameter(request, "objectId"); 
    }
    
//End Added PRG:RG6:R212:10-May-2011:IR-106716V6R2012x
    
    DomainObject  dmoObject = null;
    if(ProgramCentralUtil.isNotNullString(objectId))	
    {
    dmoObject = DomainObject.newInstance(context,objectId);
    boolean hasFromConnectAccess = dmoObject.checkAccess(context, (short)AccessConstants.cFromConnect); // IR-503291
	if(!hasFromConnectAccess){  
		String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.Folder.NoFromConnectAccess", strLanguage);
		%>
		<script language="JavaScript" type="text/javascript">
		alert("<%=sErrMsg%>");
		getTopWindow().closeSlideInDialog();
		</script>
		<%return;
	}
    if (! (dmoObject.isKindOf(context, DomainConstants.TYPE_WORKSPACE_VAULT) || dmoObject.isKindOf(context, DomainConstants.TYPE_PROJECT_MANAGEMENT))) 
    {     
          String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
    			  "emxProgramCentral.Folders.SelectProjectOrFoldersOnly", strLanguage);
             %>
                      
       <script language="JavaScript" type="text/javascript">
                                             alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                             getTopWindow().closeSlideInDialog(); // [MODIFIED::PRG:RG6:Mar 8, 2011:IR-098164V6R2012 :R211::Slidein Window related]
                                         </script>
             <%return;
    }
    }
    
     String suiteKey    = emxGetParameter(request,"suiteKey");
     
     String isFromRMB = emxGetParameter(request,"isFromRMB");
     
     boolean isRMB=false;
     if("true".equalsIgnoreCase(isFromRMB)){
    	 isRMB=true; 
     }
     if(! isCloneOperation){ //15-Jun-2011:PRG:RG6
         parentObjectId=objectId;
         objectId=null;
     }
   //End:4-June-2010:rg6:R210 PRG:IR-053998V6R2011x 
     String strprojectObjectId = XSSUtil.encodeURLForServer(context,emxGetParameter(request, "objectId"));
    if(ProgramCentralUtil.isNullString(parentObjectId))
   {
    	 parentObjectId = strprojectObjectId;
    }
     // Added:21-Apr-109:nzf:R207:PRG:Bug:371737
     String[] folders = emxGetParameterValues(request,"emxTableRowId");
     
     String strIsValidAction = "true";
     if(isCloneOperation && folders.length>1) //15-Jun-2011:PRG:RG6
     {
         strIsValidAction = "false";
     }
     // End:R207:PRG:Bug:371737
     
     if(isClone==null)
     {
         isClone="";
     }
     //End:R207:Bug :367017
     //Added for bug 360499
     String strSuiteDirectory = emxGetParameter(request,"SuiteDirectory");
     strSuiteDirectory = XSSUtil.encodeURLForServer(context, strSuiteDirectory);
     //End
     
     com.matrixone.apps.domain.DomainObject  parentType = new com.matrixone.apps.domain.DomainObject();     
	 parentType.newInstance(context);
	 parentType.setId(parentObjectId);
	 //Modified:12-Feb-09:NZF:R207:Bug :367017
    
     String strCurrentType = null;
     if(ProgramCentralUtil.isNotNullString(objectId))
	 {
	 dmoObject = DomainObject.newInstance(context,objectId);
	 strCurrentType = dmoObject.getInfo(context, parentType.SELECT_TYPE);
     }
	 
   //Added 29-June-2010:rg6:IR-054295
     if(ProgramCentralUtil.isNotNullString(parentObjectId)){
     // if controlled folder is in release state can't perform create new subfolder 
     // or delete the subfolder inside the controlled folder or parent folder itself  
     if(parentType.isKindOf(context, DomainConstants.TYPE_CONTROLLED_FOLDER)){
        String strControlledFolderCurrState = parentType.getInfo(context,DomainConstants.SELECT_CURRENT);
        if("release".equalsIgnoreCase(strControlledFolderCurrState)){
            //display error message if operation is create or clone as parent id is filtered correctly 
        
                   String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
             			  "emxProgramCentral.Common.InvalidOperation", strLanguage);
                      %>
                                     
                <script language="JavaScript" type="text/javascript">
                                                      alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                                      getTopWindow().closeSlideInDialog();   // [MODIFIED::PRG:RG6:Mar 8, 2011:IR-098164V6R2012 :R211::Slidein Window related]
                                                  </script>
                      <%return;     
            }
	 }
     }     
   //End 29-June-2010:rg6:IR-054295
   
	 String parentsType = parentType.getInfo(context, parentType.SELECT_TYPE);
	 //
     String strMQL = "print type \"" + DomainConstants.TYPE_CONTROLLED_FOLDER +"\" select derivative dump |"; //PRG:RG6:R213:Mql Injection:Static Mql:14-Oct-2011
     String strResult = MqlUtil.mqlCommand(context, strMQL, true);
     StringList slControlledFolderTypeHierarchy = FrameworkUtil.split(strResult, "|");
     
     // Dont forget to add Controlled Folder type itself into this listing
     slControlledFolderTypeHierarchy.add(DomainConstants.TYPE_CONTROLLED_FOLDER);
     
     StringBuffer contentURL =new StringBuffer();
     //PRG:RG6:R212:22-Jun-2011:Folder delete issue:110242V6R2012x/112931V6R2012x:Start     
     String sRelTypeName = DomainConstants.RELATIONSHIP_PROJECT_VAULTS;
     String sRelDir = "from"; 
     boolean isWorkspaceVaultType = parentType.isKindOf(context,DomainConstants.TYPE_WORKSPACE_VAULT); 
     if(isWorkspaceVaultType)
     {
         sRelTypeName = DomainConstants.RELATIONSHIP_SUB_VAULTS;
     }
   
     boolean isAnDInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionAerospaceProgramManagementAccelerator",false,null,null);
     String TYPE_CONTRACT = PropertyUtil.getSchemaProperty("type_Contract");
     String TYPE_CONTRACT_TEMPLATE = PropertyUtil.getSchemaProperty("type_ContractTemplate");
     
     
     //[Modified::Feb 21, 2011:MS9:2012:IR-054191::Start]
     if(strCurrentType!=null && slControlledFolderTypeHierarchy.contains(strCurrentType) && isCloneOperation){
    	 contentURL.append("../common/emxCreate.jsp?type=type_ControlledFolder&typeChooser=false&nameField=None&form=PMCProjectVaultCreateForm&mode=create&submitAction=nothing&createJPO=emxProjectFolder:createNewFolder&showApply=true&postProcessURL=../" + strSuiteDirectory + "/emxProjectManagementUtil.jsp?mode=BookmarkFolderRefresh&findMxLink=false");
     }else{
	     if(parentType.isKindOf(context, DomainConstants.TYPE_PROJECT_SPACE)){ 
		 	 contentURL.append("../common/emxCreate.jsp?type=type_ProjectVault&typeChooser=true&copyObjectId="+objectId+"&nameField=None&form=PMCProjectVaultCreateForm&mode=create&submitAction=nothing&createJPO=emxProjectFolder:createNewFolder&showApply=true&postProcessURL=../" + strSuiteDirectory + "/emxProjectManagementUtil.jsp?mode=BookmarkFolderRefresh&findMxLink=false");
	     }else if(parentType.isKindOf(context, DomainConstants.TYPE_PROJECT_TEMPLATE)){
	         contentURL.append("../common/emxCreate.jsp?type=type_ProjectVault&typeChooser=true&nameField=None&form=PMCProjectVaultCreateForm&submitAction=nothing&mode=create&createJPO=emxProjectFolder:createNewFolder&showApply=true&postProcessURL=../" + strSuiteDirectory + "/emxProjectManagementUtil.jsp?mode=BookmarkFolderRefresh&findMxLink=false");
	     }else if(DomainConstants.TYPE_PROJECT_CONCEPT.equals(parentsType)){
	         contentURL.append("../common/emxCreate.jsp?type=type_ProjectVault&typeChooser=true&nameField=None&form=PMCProjectVaultCreateForm&submitAction=nothing&mode=create&createJPO=emxProjectFolder:createNewFolder&showApply=true&postProcessURL=../" + strSuiteDirectory + "/emxProjectManagementUtil.jsp?mode=BookmarkFolderRefresh&findMxLink=false");  
	     }else if(DomainConstants.TYPE_CONTROLLED_FOLDER.equals(parentsType)){
	         contentURL.append("../common/emxCreate.jsp?type=type_ControlledFolder&typeChooser=false&nameField=None&form=PMCProjectVaultCreateForm&submitAction=nothing&mode=create&createJPO=emxProjectFolder:createNewFolder&showApply=true&postProcessURL=../" + strSuiteDirectory + "/emxProjectManagementUtil.jsp?mode=BookmarkFolderRefresh&findMxLink=false");
	     }else if(isAnDInstalled && (parentType.isKindOf(context, TYPE_CONTRACT) || parentType.isKindOf(context, TYPE_CONTRACT_TEMPLATE))){
    		 contentURL.append("../common/emxCreate.jsp?type=type_ProjectVault&typeChooser=true&ExclusionList=type_ControlledFolder&nameField=None&form=PMCProjectVaultCreateForm&mode=create&submitAction=nothing&createJPO=emxProjectFolder:createNewFolder&showApply=true&postProcessURL=../" + strSuiteDirectory + "/emxProjectManagementUtil.jsp?mode=BookmarkFolderRefresh&findMxLink=false");
	     }else{
	         contentURL.append("../common/emxCreate.jsp?type=type_ProjectVault&typeChooser=false&nameField=None&form=PMCProjectVaultCreateForm&mode=create&submitAction=nothing&createJPO=emxProjectFolder:createNewFolder&showApply=true&postProcessURL=../" + strSuiteDirectory + "/emxProjectManagementUtil.jsp?mode=BookmarkFolderRefresh&findMxLink=false");
	     }
     }
     //[Modified::Feb 21, 2011:MS9:2012:IR-054191::End]
    //PRG:RG6:R212:22-Jun-2011:Folder delete issue:110242V6R2012x/112931V6R2012x : End    
     //End:R207:Bug :367017
     String PageHeading = "";
     String HelpMarker = "";
     Enumeration enumParams=emxGetParameterNames(request);
     while(enumParams.hasMoreElements())
     {
          String param=(String)enumParams.nextElement();
          String paramValue=emxGetParameter(request,param);
          paramValue = XSSUtil.encodeURLForServer(context, paramValue);
          if(! "type".equalsIgnoreCase(param))
          {
        //Added:4-June-2010:rg6:R210 PRG:IR-053998V6R2011x
	          if(isRMB ==true  && ! isCloneOperation){ //15-Jun-2011:PRG:RG6
                if(!("rootObjectId".equalsIgnoreCase(param)|| "objectId".equalsIgnoreCase(param) || "categoryTreeName".equalsIgnoreCase(param))){
               contentURL.append("&"+param+"="+paramValue);
       
              }
          }else{
        	//PRG:RG6:R212:22-Jun-2011:Folder delete issue:110242V6R2012x/112931V6R2012x : Start
        	  /*
        	  if any form field is added in PMCWorkspaceVaultCreateForm webform for displaying value of ir for clone operation 'oldObjectId' parameter should be used
        	  as object id for clone is changed to the selected object's parent id and also exmtablerowid parameter is modified as create page creates the object as child and for clone
        	  we need to create the object at the same level as of the selected object.
        	  */
	        	  if(isCloneOperation)   
	        	  {
	        		  if(! ( "categoryTreeName".equalsIgnoreCase(param) || "objectId".equalsIgnoreCase(param) || "HelpMarker".equalsIgnoreCase(param)  )) //15-Jun-2011:PRG:RG6
	                  {
	        			  if( "emxTableRowId".equalsIgnoreCase(param))
	        			  {
	        				if(null != mParsedObject)
	        				{
	        					String sRelId = (String)mParsedObject.get("relId");
	        					String sObjId =XSSUtil.encodeURLForServer(context,(String)mParsedObject.get("objectId"));
	        					String sParenId = (String)mParsedObject.get("parentOId");
	        					String sRwId = (String)mParsedObject.get("rowId");
	        					String emxTableRowId = sRelId+"|"+sParenId+"|"+sParenId+"|"+sRwId;
	        					//contentURL.append("&"+param+"="+emxTableRowId);
	        					contentURL.append("&"+"oldObjectId"+"="+sObjId);
	        				}
	        			  }
	                      contentURL.append("&"+param+"="+paramValue);
	                  } 
	        	  } //PRG:RG6:R212:22-Jun-2011:Folder delete issue:110242V6R2012x/112931V6R2012x : End
	        	  else
                  {//Modified:19-Jul-2011:NZF:R211 PRG:IR-088994V6R2012x (Fix By QEF)
                      if(!"categoryTreeName".equalsIgnoreCase(param) && !"HelpMarker".equalsIgnoreCase(param)) //15-Jun-2011:PRG:RG6
              {//End:19-Jul-2011:NZF:R211 PRG:IR-088994V6R2012x
          contentURL.append("&"+param+"="+paramValue);
     }
     }
	        }
        //End:4-June-2010:rg6:R210 PRG:IR-053998V6R2011x 
     }
     }
     
   //Added:4-June-2010:rg6:R210 PRG:IR-053998V6R2011x
     if(isRMB==true && ! isCloneOperation){
         contentURL.append("&"+"objectId="+parentObjectId);
     }
     else  //PRG:RG6:R212:22-Jun-2011:Folder delete issue:110242V6R2012x/112931V6R2012x : Start
     {
         if(isCloneOperation)
         {
             if(ProgramCentralUtil.isNotNullString(sClonnedParentOId))
             {
                    contentURL.append("&"+"objectId="+sClonnedParentOId);
             }
         }
     } //PRG:RG6:R212:22-Jun-2011:Folder delete issue:110242V6R2012x/112931V6R2012x : End

      String clonedFromVaultId =objectId;
     if (clonedFromVaultId != null && !"".equals(clonedFromVaultId)) 
     {

     PageHeading = "emxProgramCentral.Common.CloneOf";
     HelpMarker = "emxhelpfoldercreatedialog";
     //PageHeading = UINavigatorUtil.parseHeader(context, pageContext,PageHeading, objectId, suiteKey, request.getHeader("Accept-Language"));
     }
     else
     {
     project.setId(parentObjectId);
     String parentObjectType = project.getInfo(context, project.SELECT_TYPE);
//   Added:11-Feb-09:nr2:R207:PRG Bug :367062
     if ( parentObjectType.equals(project.TYPE_WORKSPACE_VAULT) || parentObjectType.equals(project.TYPE_CONTROLLED_FOLDER))
//END R207:PRG Bug :367062
     {
               PageHeading = "emxProgramCentral.Common.CreateNewSubFolder";
          }
     else {
               PageHeading = "emxProgramCentral.Common.CreateNewFolder";
          }
     HelpMarker = "emxhelpfoldercreatedialog";
     } //end determining page header
  // Help Page

contentURL.append("&header="+PageHeading+"&HelpMarker="+HelpMarker);


%>
<!-- Modified:21-Apr-109:nzf:R207:PRG:Bug:371737 -->

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script>
<%if("false".equalsIgnoreCase(strIsValidAction)){ 
%>
 	var strErrorMsg = "<emxUtil:i18nScript localize='i18nId'>emxProgramCentral.CopyClone.CannotPerformAction</emxUtil:i18nScript>"+"\n";
	alert(strErrorMsg);
    parent.window.closeWindow();
<%}else{ %>
<%-- XSSOK--%> document.location.href="<%=contentURL%>";
<%} %>
</script>
<!-- End:R207:PRG:Bug:371737 -->
