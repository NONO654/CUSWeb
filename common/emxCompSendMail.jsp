<%--  emxCompSendMail.jsp   -  This page sends mail to the specified matrix users.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxCompSendMail.jsp.rca 1.15 Wed Oct 22 15:48:27 2008 przemek Experimental przemek $
--%>

<%@page import = "java.util.*"%>
<%@page import="com.matrixone.apps.domain.util.*"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file ="emxCompCommonUtilAppInclude.inc" %>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<!-- content begins here -->
<%    StringBuffer invalidPersons = new StringBuffer(80);
  String serrorString = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.iconMail.PeopleNotFound", new Locale(request.getHeader("Accept-Language")));  
  String ssubjecterror = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.iconMail.SubjectTooLong", new Locale(request.getHeader("Accept-Language")));  
  String sIconMailMessage ="";
  String sPageHeading= emxGetParameter(request, "page");    
  try {

    //Get the message details
    sIconMailMessage   = emxGetParameter(request, "Message");
    String sToAddress = emxGetParameter(request, "txtToAddress");
    String sCcAddress = emxGetParameter(request, "txtCcAddress");
    String sSubject   = emxGetParameter(request, "txtSubject");
    String sArrayBusId = emxGetParameter(request, "busId");
    String sPersonType=PropertyUtil.getSchemaProperty(context, "type_Person");

    
    if (sToAddress == null)
      sToAddress = "";
    else
      sToAddress = sToAddress.trim();

    if (sCcAddress == null)
      sCcAddress = "";
    else
      sCcAddress = sCcAddress.trim();

    IconMail iconMailObj = new IconMail();
    iconMailObj.create(context);

    //Set the Message for the mail
    if (sIconMailMessage != null) {
      iconMailObj.setMessage(sIconMailMessage);
    }

    //Set the 'To' address
    if ((sToAddress != null) && !(sToAddress.equals(""))) {
      StringList sListToString = tokenize(sToAddress);
      iconMailObj.setToList(sListToString);
      
      
 for (int j=0; j<sListToString.size();j++)
 {
      String sItem=(String)sListToString.elementAt(j).toString();
      boolean isValid=(boolean)isValidPerson(sItem,sPersonType,context);
      if(!isValid)
      {
        if(invalidPersons.length()==0)
        {
           invalidPersons.append(sItem);
        }else{
           invalidPersons.append(",");
           invalidPersons.append(sItem);
        }
      }
    }      
 }
    

    //Set the 'Cc' address.
 if ((sCcAddress != null) && !(sCcAddress.equals(""))) 
 {
    StringList sListCcString = tokenize(sCcAddress);
    iconMailObj.setCcList(sListCcString);      
    for (int y=0; y<sListCcString.size();y++)
    {
      String sItem2=(String)sListCcString.elementAt(y).toString();
      boolean isValid2=(boolean)isValidPerson(sItem2,sPersonType,context);
      if(!isValid2)
      {
        if(invalidPersons.length()==0)
        {
           invalidPersons.append(sItem2);
        }else{
           invalidPersons.append(",");
           invalidPersons.append(sItem2);
        }
      }
    }      
  }

    //Set the attached objects
    if(sArrayBusId != null && !sArrayBusId.equals("")) {
      BusinessObjectList boListAttachment = new BusinessObjectList();
            
        //315195
        StringTokenizer sTokObjId = new StringTokenizer(sArrayBusId, ",");
        while(sTokObjId.hasMoreElements())
        {            
            String sbosItem=(String)sTokObjId.nextToken();
            if(sbosItem != null && !"null".equals(sbosItem) && !"".equals(sbosItem))
            {
                BusinessObject boAttachment = new BusinessObject(sbosItem);
                boAttachment.open(context);
                boListAttachment.addElement(boAttachment);
                boAttachment.close(context);              
            }
        }
     
      iconMailObj.setObjects(boListAttachment);
    }

    if (sSubject == null) {
      sSubject = "";
    }
    //Send the mail
    iconMailObj.send(context, sSubject);

    String canRead = (String)session.getAttribute("canIconMailInbox");

    if("true".equals(canRead)) {
                context.shutdown();
%>
      <jsp:forward page="emxCompInboxDialog.jsp" />

<%
    }else {
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
      <script>
      try
      {
        if (getTopWindow().getWindowOpener()) {
            getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
        }
      } catch (e) {
      
      }
      getTopWindow().closeWindow();
      </script>
<%
    }
  } catch(MatrixException exception) {
	request.setAttribute("mailerror", "false");
    if((exception.toString()).contains("ORA-12899")){
    	emxNavErrorObject.addMessage(ssubjecterror);
    }
    else{
    	emxNavErrorObject.addMessage(serrorString+invalidPersons.toString());	
    }
	
  }
%>

<%!
  //returns true is person is valid, false otherwise
  public boolean isValidPerson(String sPerson,String sPersonType,Context context) {
  String slResult="";
  try{
 
  String sCmd = "print bus $1 $2 $3 select $4 dump $5";
  slResult = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,sCmd,sPersonType,sPerson,"-","exists","|");

  StringTokenizer stok = new StringTokenizer(slResult, "|");
  }catch(MatrixException mxError){
   System.out.println("error occurred Trying to valid Person");
  }
  if(slResult.startsWith("TRUE"))
    return true;
  else 
    return false;
  }
%>


<%!
  //This method tokenizes the string, puts all the elements in
  //the stringList and returns back the stringList.
  public StringList tokenize(String sList) {
    StringList sListTokens = new StringList();
    StringTokenizer sTokGeneric = new StringTokenizer(sList, ";");
    while(sTokGeneric.hasMoreElements()) {
      sListTokens.addElement(sTokGeneric.nextToken());
    }
    return sListTokens;
  }
%>
<!-- content ends here -->
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
