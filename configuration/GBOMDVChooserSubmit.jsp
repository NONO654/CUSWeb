<%-- 
      GBOMDVChooserSubmit.jsp
      Copyright (c) 1993-2018 Dassault Systemes.
      All Rights Reserved.
      This program contains proprietary and trade secret information of Dassault Systemes.
      Copyright notice is precautionary only and does not evidence any actual
      or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.configuration.RuleProcess"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="matrix.util.StringList"%>   
<%@page import="java.util.Map"%>
<html>
<head>
    <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
    <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
</head>
 <body>
      <%
	  String strMode = emxGetParameter(request,"mode");
	  %>
      <%
      if ("submitDVChoice".equalsIgnoreCase(strMode))
        {           
            String selectedOption      = emxGetParameter(request, "selectedOption");  
            String selName             = null;
            String selRelObjId         = null;
            String selObjId            = null;
            String featureListId       = "";
            String[] strTableRowIds    = emxGetParameterValues(request, "emxTableRowId");
            if(strTableRowIds!=null && strTableRowIds.length!=0){
            StringTokenizer strRowIdTZ = new StringTokenizer(strTableRowIds[0],"|");
            if(strRowIdTZ.hasMoreElements())
            {
                selRelObjId = strRowIdTZ.nextToken();
            }
            if(strRowIdTZ.hasMoreElements())
            {
                selObjId = strRowIdTZ.nextToken(); 
            }
            if(selRelObjId!=null && !selRelObjId.equals("null") &&  selRelObjId.indexOf(",") == -1 && selObjId.indexOf(",") == -1)
            {
                DomainRelationship relationship = new DomainRelationship(selRelObjId);
                com.matrixone.apps.domain.util.MapList lstFeatureListObjs = 
                                                        relationship.getInfo(context,
                                                        new String[]{selRelObjId},
                                                        new matrix.util.StringList("from."+ConfigurationConstants.SELECT_ID));
                
                featureListId =(String) ((Map)lstFeatureListObjs.get(0)).get("from."+ConfigurationConstants.SELECT_ID);
                           
                if("ConfigurationOption".equalsIgnoreCase(selectedOption))
                {   
                	
                    DomainObject obj = new DomainObject(selObjId);
                    StringList slObjSel= new StringList(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
                    slObjSel.add(ConfigurationConstants.SELECT_NAME);
                    slObjSel.add(ConfigurationConstants.SELECT_REVISION);
                    slObjSel.add(ConfigurationConstants.SELECT_TYPE);
                    Map mp=obj.getInfo(context,slObjSel);
                    
                    String strConfOptionRev = "";
                    if (mp.containsKey(ConfigurationConstants.SELECT_REVISION)
                        && mp.get(ConfigurationConstants.SELECT_REVISION) != null)
                        strConfOptionRev = (String) mp.get(ConfigurationConstants.SELECT_REVISION);
                    
                    String strConfOptionType = (String) mp.get(ConfigurationConstants.SELECT_TYPE);
                    String strConfOptionName = (String) mp.get(ConfigurationConstants.SELECT_NAME);
                    String displayNameAttr = (String) mp.get(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
                    
                    selName = obj.getAttributeValue(context,ConfigurationConstants.ATTRIBUTE_DISPLAY_NAME);

                    int ruleDisplay=RuleProcess.getRuleDisplaySetting(context);
                    if(ruleDisplay==RuleProcess.RULE_DISPLAY_FULL_NAME){
                    	String selName1 = ConfigurationUtil.geti18FrameworkString(context,strConfOptionType) + " " ;                    	
                    	selName = selName1 + strConfOptionName + " " + strConfOptionRev; 
                    }else if(ruleDisplay==RuleProcess.RULE_DISPLAY_MARKETING_NAME){
                    	selName = displayNameAttr;
                    }else{
                    	selName = displayNameAttr+" "+strConfOptionRev;
                    }
                    
                	
                }
                else
                {      //TODO -- This neeed tp remove/Updated, used in for CG
                        DomainRelationship domCGRelObj = new DomainRelationship(selRelObjId);
                        selName = domCGRelObj.getAttributeValue(context , ConfigurationConstants.ATTRIBUTE_COMMON_GROUP_NAME);
                        if (selName == null ){
                            selName  = "";
                        }             
                }
            if(selName!=null && !selName.equals(""))
            {
                selName = LogicalFeature.putEscapeCharacter(selName);
            }
            }else
                selName  = "-";  

            %>
             <script language="javascript" type="text/javaScript">  
            
               var len = getTopWindow().window.getWindowOpener().document.getElementsByTagName("input").length;
               var objList = getTopWindow().window.getWindowOpener().document.getElementsByTagName("input");
               var btnElement = "";
               var i =0;
               for(i=0; i<len; i++)
               {
                    var elemnt = objList[i];                    
                    if(elemnt.getAttribute("name") == "btnType")
                    {                      
                       btnElement = elemnt;
                       break;
                    }                                       
               }                
            
               var parentDiv        = btnElement.parentNode;                        
               var varFieldName     = parentDiv.firstChild.name;            
               var varHiddenFieldId = varFieldName+"_Actual";
               var btnHiddenElement = "";
               parentDiv.firstChild.value = "<%=XSSUtil.encodeForJavaScript(context,selName)%>";
               for(var j=0; j<len; j++)
               {               
                    var elemnt = objList[j];
                    if(elemnt.getAttribute("name") == varHiddenFieldId)
                    {                      
                       btnHiddenElement = elemnt;
                       break;
                    }               
               }
                if("<%=XSSUtil.encodeForJavaScript(context,selectedOption)%>" == "ConfigurationOption")
                {   
                     if("<%=XSSUtil.encodeForJavaScript(context,selName)%>" == "-"){
                     btnHiddenElement.value = "-";
                     }
                     else{
                     btnHiddenElement.value = "<%=XSSUtil.encodeForJavaScript(context,selObjId)%>"+"|"+"<%=XSSUtil.encodeForJavaScript(context,selRelObjId)%>";
                     }
                }
                else
                {
                     if("<%=XSSUtil.encodeForJavaScript(context,selName)%>" == "-")
                     btnHiddenElement.value = "-";
                     else
                     btnHiddenElement.value = "<%=XSSUtil.encodeForJavaScript(context,selRelObjId)%>"+"|"+"<%=XSSUtil.encodeForJavaScript(context,featureListId)%>";
                }
            if(isIE)
            {       
              getTopWindow().open('','_self','');   
              getTopWindow().closeWindow();
            }
            else
            {
              getTopWindow().closeWindow();
            }
         
          </script>          
          <%          
            }else
            {%>
                <script language="javascript" type="text/javaScript">
                 var msg = "<emxUtil:i18n localize='i18nId'>emxProduct.Alert.SelectOption</emxUtil:i18n>";
                 alert(msg);
                </script>
         <%}}%>
      </body>  
 </html>
