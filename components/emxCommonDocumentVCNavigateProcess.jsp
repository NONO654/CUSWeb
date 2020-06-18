<%-- emxCommonDocumentVCIntermediateProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentVCNavigateProcess.jsp.rca 1.11.2.5.2.1 Tue Dec 23 05:50:28 2008 ds-hkarthikeyan Experimental $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@ page import = "com.matrixone.apps.common.CommonDocument" %>

<html>
<body>
<%
    String objectId = emxGetParameter(request, "objectId");
    String parentId = emxGetParameter(request, "parentOID");
    String fromPage = emxGetParameter(request, "fromPage");
    if(parentId == null || "".equals(parentId))
    {
       parentId = emxGetParameter(request,"parentId");
    }
    String sSuiteKey = emxGetParameter(request,"suiteKey");
    String jsTreeID   = emxGetParameter(request,"jsTreeID");
    String testingCommand = emxGetParameter(request,"APPNavigateServerCommand");
    if (testingCommand == null)
      testingCommand = "";

    String storeName = "";
    String storeType="";
    String storePath="";
    // Loop through the request elements and
    // stuff into emxCommonDocumentCheckinData
    Map emxCommonDocumentNavigateData = (Map) session.getAttribute("emxCommonDocumentNavigateData");
    if(emxCommonDocumentNavigateData == null || "NavigateFirst".equalsIgnoreCase(fromPage) )
    {
         emxCommonDocumentNavigateData = new HashMap();
         Enumeration enumParam = request.getParameterNames();
         while (enumParam.hasMoreElements())
         {
           String name  = (String) enumParam.nextElement();
           String value = emxGetParameter(request, name);
           emxCommonDocumentNavigateData.put(name, value);
         }
         session.setAttribute("emxCommonDocumentNavigateData", emxCommonDocumentNavigateData);
   }
   else {
       parentId = (String)emxCommonDocumentNavigateData.get("parentOID");
       sSuiteKey = (String)emxCommonDocumentNavigateData.get("suiteKey");
       if(testingCommand == null || "".equals(testingCommand)){
          testingCommand = (String)emxCommonDocumentNavigateData.get("StoreName");
       }
   }
    if(testingCommand == null || "".equals(testingCommand))
    {
      String stores = MqlUtil.mqlCommand(context, "list store" );
      StringList storeList = FrameworkUtil.split(stores, "\n");
      Iterator storeItr = storeList.iterator();
      StringList servers = new StringList(1);
      
      while(storeItr.hasNext())
      {
          storeName = (String) storeItr.next();
          storeType = MqlUtil.mqlCommand(context, "print store '" + storeName + "' select type dump;" );
          if( "designsync".equalsIgnoreCase(storeType) )
          {
             servers.add(storeName);
          }
      }
      if(servers.size() >1) {
          storeName = "";
         // objectId = "";
          emxCommonDocumentNavigateData.put("StoreName",storeName);
      }
      else {
          storeName = servers.get(0).toString();
          storePath = MqlUtil.mqlCommand(context, "print store '" + storeName + "' select path dump;" );
          emxCommonDocumentNavigateData.put("StoreName",storeName);
       }
    }
    else {
   emxCommonDocumentNavigateData.put("StoreName",testingCommand);
   storeName = testingCommand;
   storePath = MqlUtil.mqlCommand(context, "print store '" + storeName + "' select path dump;" );
    }
    String dsfaHolderType = PropertyUtil.getSchemaProperty(context, "type_mxsysDSFAHolder");
    String dsfaHolderPolicy = PropertyUtil.getSchemaProperty(context, "policy_mxsysDSFAHolder");
    DomainObject dObj = null;
    DomainObject dObjModule = null;
    BusinessObject bObj=null;
    BusinessObject bObjModule=null;
    String objectIdModule="";

    if(!"".equals(storeName)){
        
        if (storePath.equals("/") || storePath.equals("")){            
            
            
           objectId= processFolders(context,bObj,dObj,dsfaHolderType,dsfaHolderPolicy,storeName,objectId);
            
           objectIdModule=processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
        }
        
        if(storePath.indexOf("/")==-1 && !storePath.equals("")){
            
            if (storePath.equals("Modules")){
               
                
                objectIdModule= processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
            }
            
            else{
               
                
                objectId=processFolders(context,bObj,dObj,dsfaHolderType,dsfaHolderPolicy,storeName,objectId);
            }
        }
        
        if(!storePath.equals("/") && !storePath.equals("")){
            java.util.StringTokenizer strtk= new java.util.StringTokenizer(storePath,"/");
            storePath=strtk.nextToken();
            
            if (storePath.equals("Modules")){
                              
                objectIdModule=processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
                
            }
            
            else {
                              
                objectId=processFolders(context,bObj,dObj,dsfaHolderType,dsfaHolderPolicy,storeName,objectId);
            }
        }
        
             
         
    }  
        
                  
%>

<%!
public String processModules(Context context, BusinessObject bObjModule,DomainObject dObjModule,String dsfaHolderType,String dsfaHolderPolicy,String storeName,String objectIdModule )throws Exception
{
    try{
    bObjModule=new BusinessObject(dsfaHolderType, storeName, "Modules", context.getVault().getName());
    
    if (!bObjModule.exists(context)){
        
        String vcDocument = CommonDocument.INTERFACE_VC_DOCUMENT;
        dObjModule = DomainObject.newInstance(context);
        dObjModule.createObject(context, dsfaHolderType, storeName, "Modules", dsfaHolderPolicy, context.getVault().getName());
        StringBuffer cmd = new StringBuffer(128);
        cmd.append("connect bus \"");
        cmd.append(dObjModule.getObjectId());
        cmd.append("\" vcmodule \" ");
        cmd.append("\" selector Trunk:Latest complete store \"");
        cmd.append(storeName);
        cmd.append("\" format generic");
        MqlUtil.mqlCommand(context, cmd.toString() );
        cmd = new StringBuffer(250);
        cmd.append("modify bus '");
        cmd.append(dObjModule.getObjectId());
        cmd.append("' add interface '");
        cmd.append(vcDocument);
        cmd.append("';");
        MqlUtil.mqlCommand(context, cmd.toString() );
        objectIdModule=dObjModule.getInfo(context,"id");
    }
	
	else
       {
	    bObjModule.open(context);
	    bObjModule.close(context);
	    dObjModule = DomainObject.newInstance(context, bObjModule);
	    objectIdModule=dObjModule.getInfo(context,"id");
       } 
    } catch(Exception e){} 
    return objectIdModule;
}

public String processFolders(Context context, BusinessObject bObj,DomainObject dObj,String dsfaHolderType,String dsfaHolderPolicy,String storeName,String objectId)throws Exception
{
    try{
    bObj = new BusinessObject(dsfaHolderType, storeName, "-", context.getVault().getName());
    
    if (!bObj.exists(context)){
        
        String vcDocument = CommonDocument.INTERFACE_VC_DOCUMENT;
        dObj = DomainObject.newInstance(context);
        dObj.createObject(context, dsfaHolderType, storeName, "-", dsfaHolderPolicy, context.getVault().getName());
        StringBuffer cmd = new StringBuffer(128);
        cmd.append("connect bus \"");
        cmd.append(dObj.getObjectId());
        cmd.append("\" vcfolder \"");
        cmd.append("\" config Trunk:Latest complete store \"");
        cmd.append(storeName);
        cmd.append("\" format generic");
        MqlUtil.mqlCommand(context, cmd.toString() );
        cmd = new StringBuffer(250);
        cmd.append("modify bus '");
        cmd.append(dObj.getObjectId());
        cmd.append("' add interface '");
        cmd.append(vcDocument);
        cmd.append("';");
        MqlUtil.mqlCommand(context, cmd.toString() );
        
        objectId = dObj.getInfo(context,"id");
        
    }
else
{
         bObj.open(context);
         bObj.close(context);
         dObj = DomainObject.newInstance(context, bObj);
         
         objectId = dObj.getInfo(context,"id");
    }
    }catch(Exception e){} 
    return objectId;
    
}
%>
   <form name="VCStore" method="post" target="_parent" action="../common/emxIndentedTable.jsp">
       <input type="hidden" name="expandProgram" value="emxVCDocumentUI:getVCAllContents"/>
       <input type="hidden" name="table" value="APPVCFolderContentsSummary"/>
       <input type="hidden" name="type" value="type_Document"/>
       <input type="hidden" name="storeName" value="<xss:encodeForHTMLAttribute><%=storeName%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="storeType" value="<xss:encodeForHTMLAttribute><%=storeType%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="storePath" value="<xss:encodeForHTMLAttribute><%=storePath%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="header" value="emxComponents.VersionControl.NavigateVCFileFolder"/>
       <input type="hidden" name="toolbar" value="APPVCNavigateToolBar"/>
       <input type="hidden" name="sortColumnName" value="Name"/>
       <input type="hidden" name="sortDirection" value="ascending"/>
       <input type="hidden" name="PrinterFriendly" value="true"/>
       <input type="hidden" name="pageCalledFrom" value="Navigate"/>
       <input type="hidden" name="selection" value="single"/>
       <input type="hidden" name="objectBased" value="false"/>
       <input type="hidden" name="showClipboard" value="false"/>
       <%
       if(!"".equals(objectIdModule) && !storePath.equals("/") && !storePath.equals("")){
           objectId=objectIdModule;
       }
       %>
       <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="objectIdModule" value="<xss:encodeForHTMLAttribute><%=objectIdModule%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="parentId" value="<xss:encodeForHTMLAttribute><%=parentId%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="appendParameters" value="true"/>
       <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=sSuiteKey%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute>%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="Style" value="dialog"/>
       <input type="hidden" name="fromPage" value="Navigate"/>
       <input type="hidden" name="cancelLabel" value="emxComponents.Button.Close"/>
       <input type="hidden" name="calledPage" value="Navigate"/>
       <input type="hidden" name="helpMarker" value="emxhelpdsfanavigateds"/>
      <!-- added for the bog no 340039 -->
   <input type="hidden" name="editRootNode" value="false"/>
   <!-- Bug 368788 -->
      <input type="hidden" name="customize" value="false"/>
 
<script language="javascript" type="text/javascript">
 document.VCStore.submit();
</script>
</form>
</body>
</html>


