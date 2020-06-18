<%--
  EffectivityDefinitionSearch.jsp
  Copyright (c) 1993-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@page import="com.matrixone.apps.effectivity.EffectivitySettingsManager"%>
<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>

<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.TreeSet,java.util.Iterator"%>
<%@ page import="com.matrixone.apps.domain.util.mxType " %>

<%@page import="com.matrixone.apps.domain.util.BackgroundProcess"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="javascript" src="../common/scripts/emxUIJson.js"></script>

<html>
<body onload="doSubmit();">

   <form name="EffectivitySearch" method="post" id="EffectivitySearch" >
   <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<%
  boolean bLoadSelectedContext = true;
  String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
  String selectedContext = emxGetParameter(request,"selectedContext");
   String commaseperatedlist = "";
   StringList mrsrList = null;
   String targetIframe = emxGetParameter(request,"targetIframe");
  try
  {
     //get the selected Objects from the Full Search Results page
     
    //String targetIframe = emxGetParameter(request,"targetIframe");
     String fromOperation = emxGetParameter(request,"fromOperation");
     
     if("search".equalsIgnoreCase(fromOperation)){
         bLoadSelectedContext = false;
     } else if(selectedContext != null && !"null".equalsIgnoreCase(selectedContext) && selectedContext.length() > 0){
         StringList oidList = FrameworkUtil.split(selectedContext, "|");         
         emxTableRowId = new String[oidList.size()];
         for(int n=0; n < oidList.size(); n++){
            emxTableRowId[n] = (String)oidList.get(n);               
         }       
     }
        

     //If the selection is empty give an alert to user
     String strRowId;
     if(emxTableRowId==null){   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("ENTER VALUE");
       </script>
     <%}
     //If the selection are made in Search results page then add fields on hidden form    
     else{
         try{
            //save contexts from search results
             if(!bLoadSelectedContext){              
                 //mrsrList = (StringList)CacheUtil.getCacheObject(context, "MostRecentContextSearchResults");
                 
                 if(mrsrList == null){
                    mrsrList = new StringList();
                 }
                 
                 String[] idsArray = new String[emxTableRowId.length];  
                 for (int i=0; i < emxTableRowId.length; i++ )
                 {
                    //if this is coming from the Full Text Search, have to parse out |objectId|relId|                   
                    StringList oidList = FrameworkUtil.split(emxTableRowId[i], "|");
                    idsArray[i] = (String)oidList.get(0);
                 }
                 
                 StringList selList = new StringList();
                 selList.add(DomainObject.SELECT_ID);
                 selList.add("physicalid");
                 MapList physicalIdML = DomainObject.getInfo(context, idsArray, selList);
                 if(physicalIdML != null && physicalIdML.size() > 0){
                    for(int n=0; n < physicalIdML.size(); n++){
                        Map cxtMap = (Map)physicalIdML.get(n);
                        String physicalId = (String)cxtMap.get("physicalid");
                        if(!mrsrList.contains(physicalId)){
                            mrsrList.add(physicalId);                   
                        }
                    }
                 }
                         
                 //if(mrsrList != null && mrsrList.size() > 0){
                 //    CacheUtil.setCacheObject(context, "MostRecentContextSearchResults", mrsrList);
                // }      
                 commaseperatedlist = String.join(",",mrsrList);
             } //end save
                                 
             for (int i = 0; i < emxTableRowId.length; i++)
             {
                 strRowId = emxTableRowId[i];                
                 %>
                 <input type="hidden" name="EFFTableRowId" value="<xss:encodeForHTMLAttribute><%=strRowId%></xss:encodeForHTMLAttribute>"/>
                 <%         
             }
             
         }   
         catch (Exception e){
              session.putValue("error.message", e.getMessage());  
         }
      }
  }
  catch(Exception e)
  {
   
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>
</form>
   <script language="JavaScript" type="text/javascript">

   var selectedContext = "<%=XSSUtil.encodeForJavaScript(context,selectedContext)%>";
   var loadSelectedContext = "<%=XSSUtil.encodeForJavaScript(context,String.valueOf(bLoadSelectedContext))%>";
   
   
    function doSubmit(){
    	var list = "<%=XSSUtil.encodeForJavaScript(context,commaseperatedlist)%>";

var targetIframe = "<%=XSSUtil.encodeForJavaScript(context,targetIframe)%>";
           //document.EffectivitySearch.target = "ApplicabilitySummary";
           //document.EffectivitySearch.action = vURL;
          // document.EffectivitySearch.submit(); 
		if(getTopWindow()){
getTopWindow().getWindowOpener().getTopWindow().sessionStorage.setItem("searchList", list);
}
		else 
			sessionStorage.setItem("searchList", list);

           //var intWindow = getTopWindow().getWindowOpener().document; 
           	//console.log(getTopWindow().getWindowOpener().document.onSearchOk(list));
           
           if(isIE){        
               getTopWindow().open('','_self','');  
               getTopWindow().closeWindow();
           }
           else{
                getTopWindow().closeWindow();
           }
       } 
    
   
   </script>
</body>
</html>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
