<%--  LogicalFeatureSplitReplaceStepThreePreProcess.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<html>
<body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="java.util.Map"%>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
  <jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%

try
{
    String strMode    = emxGetParameter(request, "mode");
    String jsTreeID = XSSUtil.encodeForURL(context,emxGetParameter(request,"jsTreeID"));  
    String suiteKey = XSSUtil.encodeForURL(context,emxGetParameter(request,"suiteKey"));    
    String initSource = XSSUtil.encodeForURL(context,emxGetParameter(request,"initSource"));
    String strObjectId    = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
    String strProductId = XSSUtil.encodeForURL(context,emxGetParameter(request, "prodId"));  
    String masterFeatureID = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
    String timeStamp = emxGetParameter(request, "timeStamp");
    String strnumberInstances = XSSUtil.encodeForURL(context,emxGetParameter(request,"NumberOfInstances"));

    LogicalFeature logicalFeature = new LogicalFeature();
    if(strMode.equalsIgnoreCase("SplitReplace"))
    {
        com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
        //Processing the form using FormBean.processForm
        formBean.processForm(session,request);
        //Instantiating the LogicalFeature bean
        String step = emxGetParameter(request,"Step");
        
            if(step!=null && step.equals("AssignFeatureToProduct"))
            {

                String[] strTableRowIds = emxGetParameterValues(request, "emxTablePartRowIds");
                try
                {
                    MapList partList  =  indentedTableBean.getObjectList(timeStamp);
                    Map tableDataMap =  indentedTableBean.getTableData(timeStamp);

                    boolean partChk = false;
                    if(partList!=null && partList.size()!=0 )
                    {
                        if(strTableRowIds!=null)
                        {
                            for(int j=0 ; j<partList.size(); j++)
                            {
                                Map part = (Map) partList.get(j);
                                partChk =false;
                                for(int i= 0;i< strTableRowIds.length;i++)
                                {
                                   if(strTableRowIds[i].indexOf(part.get("id").toString())>-1 && partChk==false)
                                       partChk = true;
                                }
                                if(!partChk)
                                    j = partList.size()-1;
                            }
                        }
                        else
                        {
                            partChk = false;
                        }
                      
                        if(partChk)
                        {
                        	 
                        	String[] emxTablePartRowIds = new String[strTableRowIds.length];
                        	for(int i= 0;i< strTableRowIds.length;i++)
                            {
                               
                                emxTablePartRowIds[i]=strTableRowIds[i];
                                
                            }
                            session.setAttribute("emxTablePartRowIds",emxTablePartRowIds);
                            
                        	Map urlData = new HashMap();
                        	urlData.put("strProductId",strProductId);
                            urlData.put("initSource",initSource);
                            urlData.put("jsTreeID",jsTreeID);
                            urlData.put("strObjectId",strObjectId);
                            urlData.put("masterFeatureID",masterFeatureID);                            
                            urlData.put("strTableRowIds",strTableRowIds);
                            urlData.put("suiteKey",suiteKey);
                            urlData.put("strnumberInstances",strnumberInstances);
                            urlData.put("Parts","Yes");
                             
                            String targetURL = logicalFeature.URLforSplitReplace(context,urlData ,"stepThreeProcess");
                            
                            for(int i =0; i<Integer.parseInt(emxGetParameter(request,"NumberOfInstances"));i++)
                                targetURL +="&TargetID"+i+"="+XSSUtil.encodeForURL(context,emxGetParameter(request,"TargetID"+i));
                            
                            %>     
                            <body>   
                            <form name="FTRConfigurationLogicalFeatureStepThreeplitReplace" method="post">
                            <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=strTableRowIds%></xss:encodeForHTMLAttribute>" />         
                            <script language="Javascript">        
                                //window.open('about:blank','newWin','height=575,width=575');
                                //document.FTRConfigurationLogicalFeatureStepThreeplitReplace.target="newWin";                      
                                //document.FTRConfigurationLogicalFeatureStepThreeplitReplace.action='<%=targetURL%>';
                                //document.FTRConfigurationLogicalFeatureStepThreeplitReplace.submit();
                                //alert("3");
                                getTopWindow().location.href = "<%=XSSUtil.encodeForJavaScript(context,targetURL)%>";                          
                            </script>     
                            </form>
                            </body>         
                            <%
                            
                          
                        }
                        else
                        {
                            if(!partChk)
                            {
                                %>
                                <Script>
                                alert("<emxUtil:i18nScript localize="i18nId">emxProduct.alert.PartIncludeFeature</emxUtil:i18nScript>");
                                </Script>
                                <%
                            }
                        }
                    }
                    else
                    {
                    	Map urlData = new HashMap();
                        urlData.put("strProductId",strProductId);
                        urlData.put("initSource",initSource);
                        urlData.put("jsTreeID",jsTreeID);
                        urlData.put("strObjectId",strObjectId);
                        urlData.put("masterFeatureID",masterFeatureID);                            
                        urlData.put("strTableRowIds",strTableRowIds);
                        urlData.put("suiteKey",suiteKey);
                        urlData.put("strnumberInstances",strnumberInstances);
                        urlData.put("Parts","No");
                        String targetURL = logicalFeature.URLforSplitReplace(context,urlData ,"stepThreeProcess");
                        
                        for(int i =0; i<Integer.parseInt(emxGetParameter(request,"NumberOfInstances"));i++)
                            targetURL +="&TargetID"+i+"="+XSSUtil.encodeForURL(context,emxGetParameter(request,"TargetID"+i));
                    	
                    	%>     
                        <body>   
                        <form name="FTRConfigurationLogicalFeatureStepThreeplitReplace" method="post">
                        <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=strTableRowIds%></xss:encodeForHTMLAttribute>" />         
                        <script language="Javascript">        
                            //window.open('about:blank','newWin','height=575,width=575');
                            //document.FTRConfigurationLogicalFeatureStepThreeplitReplace.target="newWin";                      
                            //document.FTRConfigurationLogicalFeatureStepThreeplitReplace.action='<%=targetURL%>';
                            //document.FTRConfigurationLogicalFeatureStepThreeplitReplace.submit();
                            //alert("3- IF par not there");
                            getTopWindow().location.href = "<%=XSSUtil.encodeForJavaScript(context,targetURL)%>";                           
                        </script>     
                        </form>
                        </body>         
                        <%
                    }
                }
                catch(Exception e)
                {
                    e.printStackTrace();
                }
            
            	
            }
            	
       
    else{
    	ENOCsrfGuard.validateRequest(context, session, request, response);
        String[] strTableRowIds = emxGetParameterValues(request, "emxTableProdFeatureSelection");
        String[] strPartRowIds =(String[]) session.getAttribute("emxTablePartRowIds");
        session.removeAttribute("emxTablePartRowIds");
        boolean split = false;
        try
        {   
            Map mpProductDetails = (Map)session.getAttribute("ProductDetails");
            
            String strLogicalFeatureRelId = (String)mpProductDetails.get("Features  RelID");
            String strProductID = (String)mpProductDetails.get("ProductID");
            
            split=logicalFeature.splitReplaceFeature(context,strTableRowIds,strPartRowIds,masterFeatureID,strLogicalFeatureRelId,
            		strProductID);
            
            session.removeAttribute("ProductDetails");               
               
            
            if(split)
            {
                %>
              <script language="javascript" type="text/javaScript">
//            <![CDATA[
                        var openerParent=getTopWindow().getWindowOpener().parent;
                        //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                        getTopWindow().closeWindow();
                        openerParent.location =openerParent.location;
//            ]]>
              </script>
                <%
            }
            else
            {
                %>
                <Script>
                  alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.CannotSplit</emxUtil:i18nScript>");
                </Script>
                <%
                int noOfInstaces = Integer.parseInt(emxGetParameter(request,"NumberOfInstances"));
                for(int i =0; i<noOfInstaces;i++)
                {
                    String  strTarId = emxGetParameter(request,"TargetID"+i);
                    DomainObject newFeatureDomObj = new DomainObject(strTarId);
                    newFeatureDomObj.deleteObject(context, true);
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    
    }
        
            }
}
catch(Exception e)
{
    e.printStackTrace();
    %>
    <Script>
    alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.Exception</emxUtil:i18nScript>");
    </Script>
    <%
}
%>
</body>
</html>

