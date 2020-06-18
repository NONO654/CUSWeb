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

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><html>
<body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

  <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<%

try
{
    String strMode    = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request,"jsTreeID");  
    String initSource = emxGetParameter(request,"initSource");
    String strContext    = emxGetParameter(request, "context");
    String strProductId = emxGetParameter(request, "prodId"); 
    String strPrentOId = emxGetParameter(request, "parentOID");
    
   if(strMode.equalsIgnoreCase("SplitReplace"))
   {
      String step = emxGetParameter(request, "Step");
      if(step!=null && step.equals("AssignFeatureToProduct") )
      { 

          String masterFeatureID = emxGetParameter(request, "objectId");
          StringList lstStringTarObjIds = new StringList();
          
          String[] selectedParts =(String[]) session.getAttribute("emxTablePartRowIds");
          
          int numberOfInstance = Integer.parseInt(emxGetParameter(request,"NumberOfInstances"));
          String strHeader = i18nNow.getI18nString("emxProduct.Heading.AssignFeature",
                  "emxConfigurationStringResource",
                  request.getHeader("Accept-Language"));
          //Specify URL to come in middle of frameset
          StringBuffer contentURL = new StringBuffer("../common/emxIndentedTable.jsp?table=FTRSplitReplaceProducts");

          // add these parameters to each content URL, and any others the App needs
          contentURL.append( "&suiteKey=Configuration&initSource=" + initSource + "&jsTreeID=" + jsTreeID);
          contentURL.append( "&objectId=" + masterFeatureID);
          contentURL.append( "&hideHeader=true");
          contentURL.append( "&ParentID=" + masterFeatureID);
          contentURL.append("&parentOID="+masterFeatureID+"&prodId="+strProductId);
          contentURL.append( "&SuiteDirectory=Configuration");
          contentURL.append( "&autoFilter=false");
          contentURL.append( "&displayView=details" );
          for(int i=0; i<numberOfInstance ; i++)   
          {
              contentURL.append( "&TargetID"+i+"="+emxGetParameter(request,"TargetID"+i));
              lstStringTarObjIds.add("'"+emxGetParameter(request,"TargetID"+i)+"'");
          }
          if(selectedParts!=null && selectedParts.length!=0)
          {
               
              contentURL.append( "&NumberOfParts="+Integer.toString(selectedParts.length)); 
          }
          contentURL.append( "&NumberOfInstances=" +emxGetParameter(request,"NumberOfInstances"));               
          contentURL.append( "&program=LogicalFeature:getImidiateParentWithProductDetails"); // Modified for IR-054384V6R2011x
          contentURL.append( "&header="+strHeader);
          contentURL.append( "&massUpdate=true");
          contentURL.append( "&sortColumnName=Name");
          contentURL.append( "&freezePane=Name");               
          contentURL.append( "&HelpMarker=emxhelpsplitandreplaceuse");
          StringBuffer targetURL = new StringBuffer("../configuration/LogicalFeatureSplitReplaceStepThreePreProcess.jsp?mode=SplitReplace");
          targetURL.append( "&Step=Done");
          targetURL.append( "&objectId=" + masterFeatureID);
          targetURL.append( "&ParentID=" + masterFeatureID);
          targetURL.append("&parentOID="+masterFeatureID+"&prodId="+strProductId);
          for(int i =0; i<numberOfInstance;i++)
              targetURL.append("&TargetID"+i+"="+emxGetParameter(request,"TargetID"+i)); 
          if(selectedParts!=null && selectedParts.length!=0)
          {
              targetURL.append( "&NumberOfParts="+Integer.toString(selectedParts.length)); 
          }
          targetURL.append( "&NumberOfInstances=" +emxGetParameter(request,"NumberOfInstances"));               
          targetURL.append( "&suiteKey=Configuration&initSource=" + initSource + "&jsTreeID=" + jsTreeID);
          targetURL.append( "&SuiteDirectory=Configuration" ); 
          targetURL.append("&parentOID="+masterFeatureID+"&prodId="+strProductId);
          StringBuffer previousURL = new StringBuffer("../components/emxCommonFS.jsp?functionality=LogicalFeatureStepTwoSplitAndReplace&mode=SplitReplace");
          previousURL.append( "&Step=SelectParts");
          previousURL.append( "&objectId=" + masterFeatureID);
          previousURL.append( "&ParentID=" + masterFeatureID);
          for(int i =0; i<numberOfInstance;i++)
              previousURL.append("&TargetID"+i+"="+emxGetParameter(request,"TargetID"+i));
          previousURL.append( "&NumberOfInstances=" +emxGetParameter(request,"NumberOfInstances")); 
          previousURL.append( "&suiteKey=Configuration&initSource=" + initSource + "&jsTreeID=" + jsTreeID);
          previousURL.append( "&SuiteDirectory=Configuration" ); 
          previousURL.append("&parentOID="+strPrentOId);
          previousURL.append("&Previous=yes");
          previousURL.append("&context="+strContext);
          
          session.setAttribute("selectedParts",selectedParts);
          StringBuffer cancelURL =new StringBuffer("../configuration/LogicalFeatureSplitReplaceStepOnePreProcess.jsp?mode=SplitReplace");
          cancelURL.append( "&Step=CancelSplit");
          cancelURL.append( "&objectId=" + masterFeatureID);
          cancelURL.append( "&ParentID=" + masterFeatureID);
          cancelURL.append( "&SuiteDirectory=Configuration"); 
          for(int i =0; i<numberOfInstance;i++)
              cancelURL.append("&TargetID"+i+"="+emxGetParameter(request,"TargetID"+i));
          cancelURL.append( "&NumberOfInstances=" +emxGetParameter(request,"NumberOfInstances")); 
          
          %>
          <html>
          <body style="height:100%" >
           <iframe  src="<%=XSSUtil.encodeURLwithParsing(context,contentURL.toString())%>" height="90%" width="100%" frameborder="0" scrolling="no" name="FeatureSplitDone">
           </iframe>
          </body>
	      </html> 
          <script>
          function submit()
          {
            try
            {
            var frm = getTopWindow().window.frames['pagecontent'].frames['FeatureSplitDone'].document.forms[0];       
            var tableRowData = frm.emxTableProdFeatureSelection;
            var tarObjIds = '<%=XSSUtil.encodeForJavaScript(context,lstStringTarObjIds.toString())%>';
            
            var isNewObjUsed  = new Array(tarObjIds.length);
            var showConfirm = false;
            var submit = true;
            var i=0; 
            var j=0;
            var k=0;
            
            for(i=0; i<tarObjIds.length;i++ )
            {                
                for(j=0;j< tableRowData.length ;j++)
                {
                  var rowVal = tableRowData[j];
                  if(rowVal.selected == null)
                  {
                      var rowValSplitArr = rowVal.value.split('|');
                      var tokenzedVal = rowValSplitArr[0]; 
                      if(tokenzedVal != tarObjIds[i] && !isNewObjUsed[i])                    
                      {
                       isNewObjUsed[i] = false;
                       }
                       else
                       {
                       isNewObjUsed[i] = true;
                       }
                  }
                  else
                  {
                       if(rowVal.selected)
                       {
                          var rowValSplitArr = rowVal.value.split('|');
                          var tokenzedVal = rowValSplitArr[0]; 
                          if(tokenzedVal != tarObjIds[i] && !isNewObjUsed[i])                    
                          {
                          isNewObjUsed[i] = false;
                          }
                          else
                          {
                          isNewObjUsed[i] = true;
                          }
                       }
                  }
                                                           
                }
            }
            for(k=0;k<isNewObjUsed.length ;k++)
            {
              if(!isNewObjUsed[k])
              {
                 showConfirm = true;
              }
            }
            if(showConfirm)
            {
              submit = confirm("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.NewFeatureNotAssisgned</emxUtil:i18nScript>");                 
            }
            
            frm.method='post';                         
            frm.action= "<%=XSSUtil.encodeURLwithParsing(context,targetURL.toString())%>"; 
            if(submit)
             {
            addSecureToken(frm);
            frm.submit();
          	removeSecureToken(frm);
            
             }
            }
            catch(err)
            {                 
             alert(err.message);
            }
          }              
          </script>
          <script>
          function movePrevious()
          {
              getTopWindow().location.href =  "<%=XSSUtil.encodeURLwithParsing(context,previousURL.toString())%>";                             
          }              
          </script>
            <script>
          function closeWindow()
          {
            var frm = getTopWindow().window.frames['pagecontent'].frames['FeatureSplitDone'].document.forms[0];               
            frm.method='post';   
            frm.target='listHidden';                      
            frm.action="<%=XSSUtil.encodeURLwithParsing(context,cancelURL.toString())%>"; 
            frm.submit();
            getTopWindow().window.closeWindow();
          }              
          </script>
          <%
  
      }
      
    }
     
}
catch(Exception e)
{
    e.printStackTrace();
    %>
    <Script>
    alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.Exception</emxUtil:i18nScript>");
    </Script>
    <%
}
%>
</body>
</html>


