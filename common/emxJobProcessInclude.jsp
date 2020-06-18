<%-- emxJobProcessInclude.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxJobProcessInclude.jsp.rca 1.1.2.2.1.5 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxNavigatorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>

<%!

    public static final String attrBeg="attribute[";
    public static final String attrEnd="]";
    public static final String stringResource="emxFrameworkStringResource";
%>
<%

    String nextStepURL  = "" ; 
    String sLanguage =  request.getHeader("Accept-Language");
    StringBuffer linkBuffer=new StringBuffer("");

    String currentActivity,nextHREF,completionStatus,current,abortRequested,statusIcon,errorMessage;
    currentActivity=nextHREF=current=completionStatus=abortRequested=statusIcon=errorMessage=null;
    int progressPercent=0;
    try
    {
        String attrCurrentActivity  =   PropertyUtil.getSchemaProperty(context,"attribute_CurrentActivity");
        String attrProgressPercnet  =   PropertyUtil.getSchemaProperty(context,"attribute_ProgressPercent");
        String attrNextCommand      =   PropertyUtil.getSchemaProperty(context,"attribute_NextStepCommand");
        String attrCompletionStatus =   PropertyUtil.getSchemaProperty(context,"attribute_CompletionStatus");
        String attrAbortRequested   = PropertyUtil.getSchemaProperty(context,"attribute_AbortRequested");
        String attrErrorMessage     = PropertyUtil.getSchemaProperty(context,"attribute_ErrorMessage");

        String objectId=emxGetParameter(request,"objectId");
        String submitURL=emxGetParameter(request,"submitURL");
        

        DomainObject jobObj=new DomainObject(objectId);
        StringList objectSelects = new StringList();
        objectSelects.add(attrBeg+attrCurrentActivity+attrEnd);
        objectSelects.add(attrBeg+attrProgressPercnet+attrEnd);
        objectSelects.add(attrBeg+attrNextCommand+attrEnd);
        objectSelects.add(attrBeg+attrCompletionStatus+attrEnd);
        objectSelects.add(attrBeg+attrAbortRequested+attrEnd);
        objectSelects.add(attrBeg+attrErrorMessage+attrEnd);
        objectSelects.add(DomainConstants.SELECT_CURRENT);
        objectSelects.add(DomainConstants.SELECT_NAME);
  
        Map resultMap=jobObj.getInfo(context,objectSelects);
        String nextStepCommand=(String) resultMap.get(attrBeg+attrNextCommand+attrEnd);
        String sName=(String)resultMap.get(DomainConstants.SELECT_NAME);
        String errorAbortMsg= EnoviaResourceBundle.getProperty(context, stringResource, context.getLocale(), "emxFramework.Aborted.ErrorMessage"); 
        errorAbortMsg = MessageUtil.substituteValues(context,errorAbortMsg,objectId,sLanguage);
        //till this
        String commandLabel = "";
        String windowHeight =  null;
        String windowWidth = null;
        String popupSize = null;
        if(nextStepCommand!=null && !"".equals(nextStepCommand) && !"null".equals(nextStepCommand))
        {
          Map commandMap=UICache.getCommand(context,nextStepCommand);
          nextHREF=(String)commandMap.get("href");
          String registeredSuite=(String)((Map)commandMap.get("settings")).get("Registered Suite");
          windowHeight = (String) ((Map)commandMap.get("settings")).get("Window Height");
          windowWidth  = (String) ((Map)commandMap.get("settings")).get("Window Width");
          popupSize  = (String) ((Map)commandMap.get("settings")).get("Popup Size");
          try
          {
             nextHREF=UINavigatorUtil.parseHREF(context,nextHREF,registeredSuite);
             if(nextHREF.contains("?")) {
                 nextHREF += "&";
             } else {
                 nextHREF += "?";            	 
             }
             nextHREF += "suiteKey=" + registeredSuite;
             if((submitURL != null && !"null".equalsIgnoreCase(submitURL) && !"".equalsIgnoreCase(submitURL) && "true".equalsIgnoreCase(submitURL))) { 
            	   nextStepURL = nextHREF + "&oid="+XSSUtil.encodeForJavaScript(context, objectId) +"&objectId="+XSSUtil.encodeForJavaScript(context, objectId) ;
             }
             

         
           }catch(FrameworkException fe){}

          commandLabel=(String)commandMap.get("label");
          commandLabel=EnoviaResourceBundle.getProperty(context, "emx"+registeredSuite+"StringResource", context.getLocale(), commandLabel);
        }
        try
        {
            progressPercent = Integer.parseInt((String) resultMap.get(attrBeg+attrProgressPercnet+attrEnd));
        }
        catch(NumberFormatException e){progressPercent=0;}
        currentActivity = (String)resultMap.get(attrBeg+attrCurrentActivity+attrEnd);
        current         = (String)resultMap.get(DomainConstants.SELECT_CURRENT);
        completionStatus= (String)resultMap.get(attrBeg+attrCompletionStatus+attrEnd);
        abortRequested  = (String)resultMap.get(attrBeg+attrAbortRequested+attrEnd);
        errorMessage    = (String)resultMap.get(attrBeg+attrErrorMessage+attrEnd);
        String linkLabel="";
        StringBuffer dataBuffer = new StringBuffer("");
        String strCompletionStatusDisVal = EnoviaResourceBundle.getProperty(context, stringResource, context.getLocale(), "emxFramework.Range.Completion_Status."+completionStatus);
        if(current.equals("Completed") || current.equals("Archived"))
        {
        	if(submitURL != null && !"null".equalsIgnoreCase(submitURL) && !"".equalsIgnoreCase(submitURL)&& "true".equalsIgnoreCase(submitURL) ) {
        		
                if(completionStatus.equals("Succeeded"))
                {
        		linkBuffer.append("Status=Completed;URL="+nextStepURL);
                } // to put abort specific error msg if user manually aborts the job
                else if(completionStatus.equals("Aborted"))
                {
                	  linkBuffer.append(sName);
                	  linkBuffer.append(" ");
                	  linkBuffer.append(errorAbortMsg);
                }
                //else block for any exception cause while background job is runnining
                else
                {
                	linkBuffer.append(strCompletionStatusDisVal);
                	linkBuffer.append(".");
                	linkBuffer.append(errorMessage);
                }
        	}
        	else {        	
            String nextStep = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

            if(completionStatus.equals("Succeeded") && nextHREF != null)
            {
                nextStep = EnoviaResourceBundle.getProperty(context, stringResource, context.getLocale(), "emxFramework.BackgroundProcess.ViewResult");
                linkLabel=commandLabel;
                dataBuffer.append("<a href=\"javascript:showModalDialog('");
                dataBuffer.append(nextHREF);
                if(nextHREF.indexOf("?")==-1)
                {
                    dataBuffer.append("?");
                }
                else
                {
                    dataBuffer.append("&");
                }
                dataBuffer.append("oid=");
                dataBuffer.append(XSSUtil.encodeForJavaScript(context, objectId));
                dataBuffer.append("&objectId=");
                dataBuffer.append(XSSUtil.encodeForJavaScript(context, objectId));

                if (windowHeight == null || "".equals(windowHeight) || "null".equals(windowHeight))
                	windowHeight = "600";
                if (windowWidth == null || "".equals(windowWidth) || "null".equals(windowWidth))
                	windowWidth = "600";
                if(null == popupSize || "".equals(popupSize) || "null".equals(popupSize))
                	popupSize = "Medium";
                dataBuffer.append("',"+windowWidth+","+windowHeight+",true,'"+popupSize+"')\" >");
                dataBuffer.append(XSSUtil.encodeForHTML(context, linkLabel));
                dataBuffer.append("</a>");
            }
            else
            {
                        	  
                if(completionStatus.equals("Succeeded"))
                {
					dataBuffer.append(strCompletionStatusDisVal);
					dataBuffer.append(".");
					dataBuffer.append(errorMessage);
                } // to put abort specific error msg if user manually aborts the job
                else if(completionStatus.equals("Aborted"))
                {
                    dataBuffer.append(sName);
                    dataBuffer.append(" ");
                    dataBuffer.append(errorAbortMsg);
                }
                     //else block for any exception cause while background job is runnining
                else
                {
                	 dataBuffer.append(strCompletionStatusDisVal);
                     dataBuffer.append(".");
                     dataBuffer.append(errorMessage);
                }
            }
            linkBuffer.append("<tr>");
            linkBuffer.append("<td class=\"label\">");
            linkBuffer.append(nextStep);
            linkBuffer.append("</td><td class=\"inputField\">");
            linkBuffer.append(dataBuffer.toString());
            linkBuffer.append("&nbsp;&nbsp;&nbsp;");
            linkBuffer.append("</td>");
            linkBuffer.append("</tr>");
        }
        }
        else
        {
            String strCurrentActivity = EnoviaResourceBundle.getProperty(context, stringResource, context.getLocale(), "emxFramework.Attribute.Current_Activity");
            StringBuffer progressBuffer = new StringBuffer("");
            for(int index=0;index<progressPercent;index+=2)
            {
                progressBuffer.append("|");
            }
            linkLabel=EnoviaResourceBundle.getProperty(context, stringResource, context.getLocale(), "emxFramework.JobMonitor.Abort"); 
            linkBuffer.append("<tr><td class=\"progressWrapper\"><div id=\"progressWrapper1\"><div ");
            linkBuffer.append("id=\"progressWrapper2\"><div id=\"progressBar\">");
            linkBuffer.append(progressBuffer.toString());
            linkBuffer.append("</div></div><br/>");
            linkBuffer.append(XSSUtil.encodeForHTML(context, strCurrentActivity));
            linkBuffer.append(":");
            linkBuffer.append(XSSUtil.encodeForHTML(context, currentActivity));
            linkBuffer.append("<br/><br/>");
            linkBuffer.append("<a href=\"javascript:abortPage('");
            linkBuffer.append(XSSUtil.encodeForJavaScript(context, objectId));
            linkBuffer.append("')\">");
            linkBuffer.append(XSSUtil.encodeForHTML(context, linkLabel));
            linkBuffer.append("</a>");
            linkBuffer.append("</div></td></tr>");
        }

    }catch(Exception e)
    {}

%>


<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.common.Message"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>
<br/><br/>
<table align="center">
<!-- //XSSOK -->
<%=linkBuffer.toString()%>
</table>

