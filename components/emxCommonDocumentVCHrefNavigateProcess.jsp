
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@ page import = "com.matrixone.apps.common.CommonDocument" %>

<html>
<body>
<%
    String hrefType=emxGetParameter(request,"type");
    String storeName = "";
    String storeType="";   
    String storePath="";
    String storeHost="";
    String storePort="";
    String hrefHost="";
    String hrefPort=""; 
    String hrefName="";
    String objectIdModule="";
   
    String fromPage = emxGetParameter(request, "fromPage");
    String hrefPath=emxGetParameter(request,"hrefPath");
    String name=emxGetParameter(request,"name");
    String version=emxGetParameter(request,"version");
    String tags=emxGetParameter(request,"tags");
    String globalType=emxGetParameter(request,"globalType");
    
    
    hrefName=hrefPath.substring(hrefPath.indexOf("Modules/")+8);
        
     StringList hrefPathList = FrameworkUtil.split(hrefPath, ":");
     Iterator hrefPathItr = hrefPathList.iterator();
     
     while(hrefPathItr.hasNext())
     {
         hrefPathItr.next();
         
         hrefHost=(String)hrefPathItr.next();
         hrefHost=hrefHost.substring(hrefHost.lastIndexOf("/")+1);
                          
         hrefPort=(String)hrefPathItr.next();
         hrefPort=hrefPort.substring(0,hrefPort.indexOf("/"));
     }
          
      String stores = MqlUtil.mqlCommand(context, "list store" );
      StringList storeList = FrameworkUtil.split(stores, "\n");
      Iterator storeItr = storeList.iterator();
      StringList servers = new StringList();
     
      
      while(storeItr.hasNext())
      {
          storeName = (String) storeItr.next();
          storeType = MqlUtil.mqlCommand(context, "print store '" + storeName + "' select type dump;" );
          if( "designsync".equalsIgnoreCase(storeType) )
          {
             servers.add(storeName);
          }
      }
      
      Iterator serverItr = servers.iterator();
      
      while(serverItr.hasNext())
      {
          storeName = (String) serverItr.next();
          storeHost=MqlUtil.mqlCommand(context, "print store '" + storeName + "' select host dump;" );
          storePort=MqlUtil.mqlCommand(context, "print store '" + storeName + "' select port dump;" );
          storePath=MqlUtil.mqlCommand(context, "print store '" + storeName + "' select path dump;" );
          
          String dsfaHolderType = PropertyUtil.getSchemaProperty(context, "type_mxsysDSFAHolder");
          String dsfaHolderPolicy = PropertyUtil.getSchemaProperty(context, "policy_mxsysDSFAHolder");
          DomainObject dObjModule = null;
          BusinessObject bObjModule=null;
          
          if (storePath.equals("")){
              storePath="/";  
          }
          
          if (storePath.indexOf("/")==0 && !storePath.equals("/")){
              storePath=storePath.substring(1);
          }
          
          if(storeHost.equals(hrefHost) && storePort.equals(hrefPort) && (storePath.equals("/") || storePath.equals("Modules")) ){
                    
              objectIdModule=processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
              break;
          }
          
          if(storeHost.equals(hrefHost) && storePort.equals(hrefPort) && !storePath.equals("Modules") && storePath.contains("Modules")) {
              
              storePath=storePath.substring(storePath.indexOf("/")+1);
              
              if(hrefName.indexOf("/")==-1){
                  
                  if(storePath.equals(hrefName)){
                  objectIdModule=processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
                  break;
                  }
                  
                  else{
                      objectIdModule="";
                  }
              }
              
              else{
              
              if(storePath.equals(hrefName) || storePath.equals(hrefName.substring(0,hrefName.lastIndexOf("/")))){
                  objectIdModule=processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
                  break;
              	}
              
              else{
                  objectIdModule="";
              }
              
              }  
              
          }
      }
      
      if(objectIdModule==null || objectIdModule.length()==0 ){
  %>         
          <script language="javascript" type="text/javascript">
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.NoStoreAlert</emxUtil:i18nScript>");
          window.closeWindow();
     </script>
          
 <%       
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


%>
   <form name="VCStore" method="post" target="_parent" action="../common/emxIndentedTable.jsp">
       <input type="hidden" name="expandProgram" value="emxVCDocumentUI:getVCModuleContents"/>
       <input type="hidden" name="program" value="emxVCDocumentUI:getVCModuleHrefsNavigate"/>
       <input type="hidden" name="table" value="APPVCHrefContentsSummary"/>
       <input type="hidden" name="storePath" value="<xss:encodeForHTMLAttribute><%=storePath%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="storeName" value="<xss:encodeForHTMLAttribute><%=storeName%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="name" value="<xss:encodeForHTMLAttribute><%=name%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="version" value="<xss:encodeForHTMLAttribute><%=version%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="tags" value="<xss:encodeForHTMLAttribute><%=tags%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="globalType" value="module"/>
       <input type="hidden" name="hrefType" value="<xss:encodeForHTMLAttribute><%=hrefType%></xss:encodeForHTMLAttribute>"/>       
       <input type="hidden" name="header" value="emxComponents.VersionControl.NavigateVCFileFolder"/>
       <input type="hidden" name="toolbar" value="APPVCFolderContentActions"/>
       <input type="hidden" name="suiteKey" value="Components"/>
       <input type="hidden" name="jsTreeID" value="root"/>
       <input type="hidden" name="sortColumnName" value="Name"/>
       <input type="hidden" name="sortDirection" value="ascending"/>
       <input type="hidden" name="PrinterFriendly" value="true"/>
       <input type="hidden" name="pageCalledFrom" value="Navigate"/>
       <input type="hidden" name="selection" value="single"/>
       <input type="hidden" name="objectBased" value="false"/>
      
       <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectIdModule%></xss:encodeForHTMLAttribute>"/>
     
       <input type="hidden" name="appendParameters" value="true"/>
      
      
       <input type="hidden" name="Style" value="dialog"/>
       <input type="hidden" name="fromPage" value="Navigate"/>
       <input type="hidden" name="cancelLabel" value="emxFramework.GlobalSearch.Close"/>
       <input type="hidden" name="calledPage" value="Navigate"/>
       <input type="hidden" name="helpMarker" value="emxhelpdsfanavigateds"/>
      <!-- added for the bog no 340039 -->
   <input type="hidden" name="editRootNode" value="false"/>
   <input type="hidden" name="showClipboard" value="false"/>
 
<script language="javascript" type="text/javascript">
 document.VCStore.submit();
</script>
</form>
</body>
</html>

