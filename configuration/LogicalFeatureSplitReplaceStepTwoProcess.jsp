<%--  LogicalFeatureSplitReplaceStepTwoProcess.jsp
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


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="java.util.Map"%>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<%

try
{   
    String strMode    = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request,"jsTreeID");  
    String suiteKey = emxGetParameter(request,"suiteKey");    
    String initSource = emxGetParameter(request,"initSource");
    String strObjectId    = emxGetParameter(request, "objectId");
    String strProductId = emxGetParameter(request, "prodId");    
    LogicalFeature logicalFeature = new LogicalFeature();
     if(strMode.equalsIgnoreCase("SplitReplace"))
   {
      String step = emxGetParameter(request, "Step");
      if(step!=null && step.equals("SelectParts") )
      {           
          String masterFeatureID = emxGetParameter(request, "ParentID");
          String[] strTableRowIds = (String[])session.getAttribute("selectedParts");
          int numberOfInstance = Integer.parseInt(emxGetParameter(request,"NumberOfInstances"));
          String strHeader = i18nNow.getI18nString("emxProduct.Heading.SelectParts",
                  "emxConfigurationStringResource",
                  request.getHeader("Accept-Language"));
          
          Map urlData = new HashMap();
          urlData.put("strProductId",strProductId);
          urlData.put("initSource",initSource);
          urlData.put("jsTreeID",jsTreeID);
          urlData.put("strObjectId",strObjectId);
          urlData.put("masterFeatureID",masterFeatureID);
          urlData.put("strHeader",strHeader);
          urlData.put("strTableRowIds",strTableRowIds);
          urlData.put("suiteKey",suiteKey);
          
          //Specify URL to come in middle of frameset
          String url =logicalFeature.URLforSplitReplace(context,urlData,"PartTable");
          StringBuffer contentURL = new StringBuffer(url);                   
          for(int i=0; i<numberOfInstance ; i++)          
              contentURL.append( "&TargetID"+i+"="+emxGetParameter(request,"TargetID"+i));
          contentURL.append( "&NumberOfInstances=" +emxGetParameter(request,"NumberOfInstances").trim());          
          contentURL.append( "&program=emxFTRPart:getActiveGBOMStructure");
         
          
          //target URL
          String urltarget =logicalFeature.URLforSplitReplace(context,urlData,"StepThree");
          StringBuffer targetURL =new StringBuffer(urltarget);
          for(int i =0; i<numberOfInstance;i++)
              targetURL.append("&TargetID"+i+"="+emxGetParameter(request,"TargetID"+i));
          targetURL.append( "&NumberOfInstances=" +emxGetParameter(request,"NumberOfInstances"));  
          
          
          
          //Cancel URL
          String urlCancel = logicalFeature.URLforSplitReplace(context,urlData,"CancelURL");
          StringBuffer cancelURL =new StringBuffer(urlCancel);           
          for(int i =0; i<numberOfInstance;i++)
              cancelURL.append("&TargetID"+i+"="+emxGetParameter(request,"TargetID"+i));
          cancelURL.append( "&NumberOfInstances=" +emxGetParameter(request,"NumberOfInstances")); 
          if(strTableRowIds != null)
          {
          %>
              <form name="MyForm" method="post" target="FeatureReplace" action="<xss:encodeForHTMLAttribute><%=contentURL.toString()%></xss:encodeForHTMLAttribute>" style="height:1%;min-height:1%">
               <%for(int k=0 ; k<strTableRowIds.length;k++)
              {%>
                 <input type="hidden" name="selectedParts<%=k%>" value="<xss:encodeForHTMLAttribute><%=strTableRowIds[k]%></xss:encodeForHTMLAttribute>"/>
              <%}
                  session.removeAttribute("selectedParts");
              %>              
            </form>
            <html>
              <body style="height:100%" >
	           <iframe src="" height="90%" width="100%" frameborder="0" scrolling="no" name="FeatureReplace">
	           </iframe>
	          </body>
	        </html>
           <script type="text/javascript">
           getTopWindow().window.frames['pagecontent'].document.forms[0].submit();
            </script>
           <%}else{%>
           <html>
           <body style="height:100%">
           <iframe src="<%=XSSUtil.encodeForHTMLAttribute(context, contentURL.toString())%>" height="90%" width="100%" frameborder="0" scrolling="no" name="FeatureReplace">
           </iframe>
	          </body>
	        </html>           
           <%} 
          
           %>
              <script>
              function moveNext()
              {
                try
                {
                var frame = getTopWindow().window.frames['pagecontent'].frames['FeatureReplace'].document;
                var frm = frame.forms[0]; 
                frm.method='post';   
                frm.target='listHidden';                      
                frm.action="<%=XSSUtil.encodeForJavaScript(context,targetURL.toString())%>"; 
                frm.submit();
                }
                catch(err)
                {
                  alert(err.message);
                }
              }              

              function closeWindow()
              {
            	 var frame = getTopWindow().window.frames['pagecontent'].frames['FeatureReplace'].document;
                 var frm = frame.forms[0];             
                 frm.method='post';   
                 frm.target='listHidden';                      
                 frm.action="<%=XSSUtil.encodeForJavaScript(context,cancelURL.toString())%>"; 
                 frm.submit();
                 getTopWindow().window.closeWindow();
              }               
              </script>
           <%     
      
      
      }
   }
}
catch(Exception ex) 
{
        session.putValue("error.message", ex.getMessage());
} 
%>
</body>

