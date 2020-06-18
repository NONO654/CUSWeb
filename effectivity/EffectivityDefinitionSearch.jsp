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
  boolean bIsError = false;
  boolean bLoadSelectedContext = true;
  String targetIframe = "";
  String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
  String selectedContext = emxGetParameter(request,"selectedContext");
  String objectId = emxGetParameter(request,"objectId");
  String RELID = emxGetParameter(request,"RELID");
  String ROOTID = emxGetParameter(request,"ROOTID");
  String FromGlobalContextFO = emxGetParameter(request,"FromGlobalContextFO");
  String fromCaller = emxGetParameter(request,"fromCaller");
  
  String strExpandLevel = EnoviaResourceBundle.getProperty(context,"Effectivity.ExpandLevel.All");
  try
  {
     //get the selected Objects from the Full Search Results page
     
     String expandProgram = emxGetParameter(request,"expandProgramCFF");
     String strRelationship = emxGetParameter(request,"relationshipCFF");
     String strformatType = emxGetParameter(request,"formatType");
     String strEffType = emxGetParameter(request,"effectivityType");
     String strCffTable = emxGetParameter(request,"cffTable");
     String strSelection = emxGetParameter(request,"CFFselection");
     String strcategoryType = request.getParameter("categoryType");
     String strSelectionToolBar = emxGetParameter(request,"selectorToolbar");
     targetIframe = emxGetParameter(request,"targetIframe");
     String fromOperation = emxGetParameter(request,"fromOperation");
     String effectivityDiscipline = emxGetParameter(request,"effectivityDiscipline");
     String fromFilterToolbar = emxGetParameter(request,"fromFilterToolbar");
     String strMode = emxGetParameter(request,"mode");
     
     if("search".equalsIgnoreCase(fromOperation)){
         bLoadSelectedContext = false;
     } else if(selectedContext != null && !"null".equalsIgnoreCase(selectedContext) && selectedContext.length() > 0){
         StringList oidList = FrameworkUtil.split(selectedContext, "|");         
         emxTableRowId = new String[oidList.size()];
         for(int n=0; n < oidList.size(); n++){
            emxTableRowId[n] = (String)oidList.get(n);               
         }       
     }
     
     if (strMode != null && !strMode.equalsIgnoreCase("null") && strMode.length() > 0)
     {
     %>
         <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>"/>
     <%        
     }   
     if (fromFilterToolbar != null && !fromFilterToolbar.equalsIgnoreCase("null") && fromFilterToolbar.length() > 0)
     {
     %>
         <input type="hidden" name="fromFilterToolbar" value="<xss:encodeForHTMLAttribute><%=fromFilterToolbar%></xss:encodeForHTMLAttribute>"/>
     <%        
     }    
     if(effectivityDiscipline != null && !"null".equalsIgnoreCase(effectivityDiscipline) && effectivityDiscipline.length() > 0)
     {         
     %>
         <input type="hidden" name="effectivityDiscipline" value="<xss:encodeForHTMLAttribute><%=effectivityDiscipline%></xss:encodeForHTMLAttribute>"/>
     <%       
     }     
     if (RELID != null && !RELID.equalsIgnoreCase("null") && RELID.length() > 0)
     {
     %>
         <input type="hidden" name="relationshipId" value="<xss:encodeForHTMLAttribute><%=RELID%></xss:encodeForHTMLAttribute>"/>
     <%        
     }     
     if (FromGlobalContextFO != null && !FromGlobalContextFO.equalsIgnoreCase("null") && FromGlobalContextFO.length() > 0)
     {
     %>
         <input type="hidden" name="FromGlobalContextFO" value="<xss:encodeForHTMLAttribute><%=FromGlobalContextFO%></xss:encodeForHTMLAttribute>"/>
     <%        
     }      
     
     if (objectId != null && !objectId.equalsIgnoreCase("null") && objectId.length() > 0)
     {
     %>
         <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
     <%        
     }
     if (strEffType != null && !strEffType.equalsIgnoreCase("null") && strEffType.length() > 0)
     {
     %>
         <input type="hidden" name="effectivityType" value="<xss:encodeForHTMLAttribute><%=strEffType%></xss:encodeForHTMLAttribute>"/>
     <%        
     }
     if (expandProgram != null && !expandProgram.equalsIgnoreCase("null") && expandProgram.length() > 0)
     {
     %>
         <input type="hidden" name="expandProgram" value="<xss:encodeForHTMLAttribute><%=expandProgram%></xss:encodeForHTMLAttribute>"/>
     <%        
     }
     else if (strRelationship != null && !strRelationship.equalsIgnoreCase("null") && strRelationship.length() > 0)
     {
     %>
         <input type="hidden" name="relationship" value="<xss:encodeForHTMLAttribute><%=strRelationship%></xss:encodeForHTMLAttribute>"/>
     <%  
     }
     if (strformatType != null && !strformatType.equalsIgnoreCase("null") && strformatType.length() > 0)
     {
     %>
         <input type="hidden" name="formatType" value="<xss:encodeForHTMLAttribute><%=strformatType%></xss:encodeForHTMLAttribute>"/>
     <%        
     }
     if (strcategoryType != null && !strcategoryType.equalsIgnoreCase("null") && strcategoryType.length() > 0)
     {
     %>
         <input type="hidden" name="categoryType" value="<xss:encodeForHTMLAttribute><%=strcategoryType%></xss:encodeForHTMLAttribute>"/>
     <%        
     }
     if (strCffTable != null && !strCffTable.equalsIgnoreCase("null") && strCffTable.length() > 0)
     {
     %>
         <input type="hidden" name="cffTable" value="<xss:encodeForHTMLAttribute><%=strCffTable%></xss:encodeForHTMLAttribute>"/>
     <%        
     }
     if (strSelection != null && !strSelection.equalsIgnoreCase("null") && strSelection.length() > 0)
     {
     %>
         <input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=strSelection%></xss:encodeForHTMLAttribute>"/>
     <%        
     }
     
     if (strSelectionToolBar != null && !strSelectionToolBar.equalsIgnoreCase("null") && strSelectionToolBar.length() > 0)
     {
     %>
         <input type="hidden" name="selectionToolBar" value="<xss:encodeForHTMLAttribute><%=strSelectionToolBar%></xss:encodeForHTMLAttribute>"/>
     <%        
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
                 StringList mrsrList = (StringList)CacheUtil.getCacheObject(context, "MostRecentContextSearchResults");
                 
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
                         
                 if(mrsrList != null && mrsrList.size() > 0){
                     CacheUtil.setCacheObject(context, "MostRecentContextSearchResults", mrsrList);
                 }               
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
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>
</form>
   <script language="JavaScript" type="text/javascript">
   var selectedContext = "<%=XSSUtil.encodeForJavaScript(context,selectedContext)%>";
   var loadSelectedContext = "<%=XSSUtil.encodeForJavaScript(context,String.valueOf(bLoadSelectedContext))%>";
   
   function updateContextPanel(docObj){
       if(!docObj){
       return;          
       }          
  
        var cachedContextUL = docObj.getElementById("cachedContextList");
        var currInnerHTML = cachedContextUL.innerHTML;
        if(currInnerHTML == null || currInnerHTML == 'undefined'){
            currInnerHTML = "";
        }
         
        var idArray = new Array();
        //get a list of current contexts' id
        if(cachedContextUL && cachedContextUL.hasChildNodes()){
            var liArray = cachedContextUL.getElementsByTagName("li");       
            
            if(liArray && liArray.length > 0){              
                for(var i=0; i < liArray.length; i++){
                    var liObject = liArray[i];
                    var objArray = liObject.getElementsByTagName("input");
                    if(objArray && objArray.length == 1){
                        idArray[i] = objArray[0].id; 
                    }                                   
                }
            }           
        }   
        
        //get contexts' id from search results
        var url =  "../effectivity/EffectivityUtil.jsp?mode=getContextsFromSavedSearchResults";
        var contextIds = emxUICore.getDataPost(url);
    
        //get contexts' info for context panel display
        url="../effectivity/EffectivityUtil.jsp?mode=getContextsForSelect&includeContextList="+contextIds; 
        var effContexts = emxUICore.getDataPost(url);
            
        if(effContexts != null){
            var effContextsArray = effContexts.parseJSON();
            var liStrElement = "";
            for(var j=0; j < effContextsArray.length; j++){             
                var effContext = effContextsArray[j];               
                if(idArray.length > 0 && idArray.indexOf(effContext.physicalid) > -1){
                    continue;
                }               
                
                var typeIcon = effContext.typeIcon;
                var imgSrc = "../common/images/";
                if(typeIcon != null && typeIcon != ""){
                    imgSrc += typeIcon;
                }
                effContext.displayValue=effContext.displayValue.htmlEncode();
                //construct li element
                liStrElement += "<li>";
                liStrElement += "<span class=\"icon\">";
                liStrElement += "<input id=\"" + effContext.physicalid + "\" ";
                liStrElement += "onclick=\"javascript:updateContextSelection(\'" + effContext.physicalid + "\');\" ";
                liStrElement += "value=\"" + effContext.displayValue.htmlEncode() + "\" ";                   
                liStrElement += "type=\"radio\">";
                liStrElement += "</span>";
                liStrElement += "<span><img src=\"" + imgSrc + "\" width=\"16\" height=\"16\"></span>";
                liStrElement += "<label>&nbsp;" + effContext.displayValue + "</label>";
                liStrElement += "</li>";
                
                var newInnerHTML = currInnerHTML + liStrElement;
                try{
                    cachedContextUL.innerHTML = newInnerHTML;
                } catch(e){
                    alert("error: " + e.message);
                }
            } //end for
            
        } //end if
    }
   
    function doSubmit(){
       if(loadSelectedContext != "true"){
           var intWindow = getTopWindow().getWindowOpener().document; 
           if(intWindow && intWindow.getElementById("cachedContextList")){                 
               updateContextPanel(intWindow);                  
           }
           
           if(isIE){        
               getTopWindow().open('','_self','');  
               getTopWindow().closeWindow();
           }
           else{
                getTopWindow().closeWindow();
           }
       } else { // load selected contexts
           
           var targetIframe = "<%=XSSUtil.encodeForJavaScript(context,targetIframe)%>";
           var vURL = "../common/emxIndentedTable.jsp?";    
           var vFormatType = document.EffectivitySearch.formatType.value;
           var vcategoryType = "";
           var vExpandAllLevel =  "<%=XSSUtil.encodeForJavaScript(context,strExpandLevel)%>";
           if (document.EffectivitySearch.categoryType)
           {
               vcategoryType = document.EffectivitySearch.categoryType.value;
           }
           if (vFormatType == 'list')
           {
               vURL = "../common/emxTable.jsp?";
           }           
           
           switch(vcategoryType){
               case "relational":
                   // vURL += "expandProgram=emxEffectivityFramework:getSelectorSearchResultsRelationalRelView";
                   vURL += "expandProgram=ConfigurationFeature:getModelConfigurationDictionaryForEffectivity";
                   break;
               case "branching":
                   vURL += "program=emxEffectivityFramework:getSelectorSearchResultsBranching";
                   break;
               case "milestone":
                   vURL += "expandProgram=emxEffectivityFramework:getModelMilestoneDictionary";
                   break;
               default:
                   vURL += "program=emxEffectivityFramework:getSelectorSearchResults";
           }
           
           if(document.EffectivitySearch.objectId){
                vURL = vURL + "&objectId="+document.EffectivitySearch.objectId.value;
                vURL = vURL + "&relationshipId="+document.EffectivitySearch.relationshipId.value;
           }
           
           //table: if one is defined, use i, else use default one.
           if(document.EffectivitySearch.cffTable){
               vURL += "&table=" + document.EffectivitySearch.cffTable.value;
           } else {//might no be used as default values are set in effectivity setting managers
               switch(vcategoryType){
                   case "relational":
                       vURL += "&table=CFFRelationalDefinitionTable";
                       break;
                   case "milestone":
                       vURL += "&table=CFFMilestoneDefinitionTable";
                       break;                       
                   case "branching":
                       vURL += "&table=CFFBranchingDefinitionTable";
                       break;
                   default:
                    vURL = vURL + "&table=CFFDefinitionTable";
               }
           }               
 
           vURL += "&selection=";
           if(vcategoryType == "milestone" && document.EffectivitySearch.fromFilterToolbar != null && document.EffectivitySearch.fromFilterToolbar.value == "true"){
               vURL += "single";
           } else {
               vURL += (document.EffectivitySearch.selection)?document.EffectivitySearch.selection.value:"multiple";       
           }
           
           //sort column
           switch(vcategoryType){
               case "branching":
                   vURL += "&sortColumnName=Rev";
                   break;
               case "milestone":
                   vURL += "&sortColumnName=none";
                   break;                   
               default:
                   vURL += "&sortColumnName=SequenceSelectable";
           }               
       
           if (document.EffectivitySearch.selectionToolBar)
           {
               vURL = vURL + "&toolbar=" + document.EffectivitySearch.selectionToolBar.value;
           }
           
           if(vcategoryType == "milestone"){
               
               vURL += "&disableRootSelection=true";
           }           
           
           vURL = vURL + "&PrinterFriendly=false";
           vURL = vURL + "&objectCompare=false";
           vURL = vURL + "&customize=true";
           vURL = vURL + "&export=false";
           vURL = vURL + "&showClipboard=false";
           vURL = vURL + "&multiColumnSort=false";
           vURL = vURL + "&massPromoteDemote=false";
           vURL = vURL + "&showPageURLIcon=false";
           vURL = vURL + "&autoFilter=false";
           vURL = vURL + "&direction=from";
           vURL = vURL + "&hideHeader=true";
           vURL = vURL + "&sortDirection=ascending";
           vURL = vURL + "&suiteKey=Effectivity";
           vURL = vURL + "&editRootNode=true";
           vURL = vURL + "&showApply=false";
           vURL = vURL + "&autoFilter=false";
           
 			if(vcategoryType == "milestone"){
		        vURL = vURL + "&toolbar=CFFFilterToolbar";
                vURL += "&disableRootSelection=true";
 				vURL = vURL + "&freezePane=Name,ActionIcon";
	 	        vURL = vURL + "&expandLevelFilterMenu=CFFExpandAllLevelFilter";           
 				
 	       }else if(vcategoryType == "relational"){
		        vURL = vURL + "&toolbar=CFFFilterToolbar";
	        	vURL = vURL + "&freezePane=Display Name,ActionIcon"; 
	    		if(vExpandAllLevel == "true"){
	    	 		vURL = vURL + "&expandLevelFilterMenu=CFFExpandAllLevelFilter";           
	    	 	}    	   
 	       }
 			

           vURL = vURL + "&objectId=" +  "<%=XSSUtil.encodeForJavaScript(context,selectedContext)%>";
           vURL = vURL + "&massUpdate=" + "false";
           
           //expandProgram takes precedence over relationship
           if (document.EffectivitySearch.expandProgram && (vcategoryType != "milestone" && vcategoryType != "relational") )
           {
               vURL = vURL + "&expandProgram=" + document.EffectivitySearch.expandProgram.value;
               
           } else if (document.EffectivitySearch.relationship)
           {
               vURL = vURL + "&relationship=" + document.EffectivitySearch.relationship.value;
           }  
           
           if (document.EffectivitySearch.effectivityType)
           {
               vURL = vURL + "&effectivityType=" + document.EffectivitySearch.effectivityType.value;
           }

           if (document.EffectivitySearch.FromGlobalContextFO)
           {
               vURL = vURL + "&FromGlobalContextFO=" + document.EffectivitySearch.FromGlobalContextFO.value;
           }
           
           if (document.EffectivitySearch.effRelationship)
           {
               vURL = vURL + "&effectivityDiscipline=" + document.EffectivitySearch.effectivityDiscipline.value;
           }

           if (document.EffectivitySearch.mode)
           {
               vURL += "&mode=" + document.EffectivitySearch.mode.value;
           }           
           vURL = vURL + "&fromCaller=" +  "<%=XSSUtil.encodeForJavaScript(context,fromCaller)%>";
          // alert(vURL);
           document.EffectivitySearch.target = targetIframe;
           document.EffectivitySearch.action = vURL;
           document.EffectivitySearch.submit();     
       }
    }
   
   </script>
</body>
</html>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
