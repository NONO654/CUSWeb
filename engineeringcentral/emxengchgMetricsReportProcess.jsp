<%--  emxengchgMetricsReportProcess.jsp   - Processing page for generating Metrics report for ECR/ECO.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants" %>

<%
  String url = "";

  // Get the lookup namkes for attributes
  String sTypeECR        = PropertyUtil.getSchemaProperty(context, "type_ECR");
  String sTypeECO        = PropertyUtil.getSchemaProperty(context, "type_ECO");
  //ECM
  
  String attrOriginator  = PropertyUtil.getSchemaProperty(context, "attribute_Originator");
  String attrCatOfChange = PropertyUtil.getSchemaProperty(context, "attribute_CategoryofChange");
  String attrRDesEng     = PropertyUtil.getSchemaProperty(context, "attribute_ResponsibleDesignEngineer");
  String attrECREval     = PropertyUtil.getSchemaProperty(context, "attribute_ECREvaluator");
  String attrChangeBoard = PropertyUtil.getSchemaProperty(context, "attribute_ChangeBoard");
  String relEMPA         = PropertyUtil.getSchemaProperty(context, "relationship_ECRMainProductAffected");

  String language        = request.getHeader("Accept-Language");
  //String strCancelledStateECO = PropertyUtil.getSchemaProperty(context,"policy",DomainConstants.POLICY_ECO_STANDARD,"state_Cancelled");
  String POLICY_ECO = PropertyUtil.getSchemaProperty(context, "policy_ECO");
  String strCancelledStateECO = PropertyUtil.getSchemaProperty("policy", POLICY_ECO, "state_Cancelled");
  
  String POLICY_ECR = PropertyUtil.getSchemaProperty(context, "policy_ECR");
  String strCancelledStateECR = PropertyUtil.getSchemaProperty("policy", POLICY_ECR, "state_Cancelled");
  
  //ECM
  String POLICY_CO = PropertyUtil.getSchemaProperty(context, "policy_FormalChange");
  String strCancelledStateCO = PropertyUtil.getSchemaProperty("policy", POLICY_CO, "state_Cancelled");
  String attrSeverity                        = PropertyUtil.getSchemaProperty(context, "attribute_Severity");
  String strSeverity                          = i18nNow.getAttributeI18NString(attrSeverity,language);
  
  // Get the parameters from the Passing form:
  String sType          = emxGetParameter(request,"type");
    
  String sDel           = emxGetParameter(request,"textfieldDel");
  String sPolicy        = emxGetParameter(request,"policy");
  String sFileExtension = emxGetParameter(request,"fileExtension");

  String strType       = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Type", language);
  String sName         = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Name", language);
  String sRevision     = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Revision", language);
  String sDescription  = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Description", language);
  String sCurrentState = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.CurrentState", language);

  String typeProductLine                      = PropertyUtil.getSchemaProperty(context, "type_ProductLine");
  String attrPriority                         = PropertyUtil.getSchemaProperty(context, "attribute_Priority");
  String attrReleaseDistributionGroup         = PropertyUtil.getSchemaProperty(context, "attribute_ReleaseDistributionGroup");
  String attrResponsibleManufacturingEngineer = PropertyUtil.getSchemaProperty(context, "attribute_ResponsibleManufacturingEngineer");

  String prefix = "metricsreport";
  String filename = prefix + (new Date().getTime()) + sFileExtension;

  java.io.OutputStreamWriter osw = null;
  String fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);

  String strOriginator                        = i18nNow.getAttributeI18NString(attrOriginator,language);
  String strPriority                          = i18nNow.getAttributeI18NString(attrPriority,language);
  String strRDesEng                           = i18nNow.getAttributeI18NString(attrRDesEng,language);
  //String strReleaseDistributionGroup          = i18nNow.getAttributeI18NString(attrReleaseDistributionGroup,language);
  String strResponsibleManufacturingEngineer  = i18nNow.getAttributeI18NString(attrResponsibleManufacturingEngineer,language);
  String strCatOfChange                       = i18nNow.getAttributeI18NString(attrCatOfChange,language);
  String strECREval                           = i18nNow.getAttributeI18NString(attrECREval,language);
 // String strProductLine                       = i18nNow.getTypeI18NString(typeProductLine,language);
 // String strChangeBoard                       = i18nNow.getAttributeI18NString(attrChangeBoard,language);

  try
  {
    Class objectTypeArray2[] = new Class[2];
    objectTypeArray2[0] = Class.forName("javax.servlet.http.HttpSession");
    objectTypeArray2[1] = filename.getClass();

    Object objectArray2[] = new Object[2];
    objectArray2[0] = session;
    objectArray2[1] = filename;

    java.lang.reflect.Method _method = (Class.forName("com.matrixone.servlet.Framework")).getMethod("createTemporaryFile", objectTypeArray2);
    //Modified for the IR-027867V6R2011 to support all the local scripts
    //osw = new OutputStreamWriter((OutputStream)_method.invoke(null,objectArray2),  fileEncodeType);
    osw = new OutputStreamWriter((OutputStream)_method.invoke(null,objectArray2),"UTF-8");
  }
  catch(NoSuchMethodException nex)
  {
    String sTransPath = JSPUtil.getCentralProperty(application, session, "emxEngineeringCentral", "InstallPath");
    if(sTransPath==null || "null".equals(sTransPath)){
      sTransPath="";
    }
    java.io.File root = new java.io.File(sTransPath);

    java.io.File metrixFile = new java.io.File(root,filename);
    FileOutputStream fio = new FileOutputStream(metrixFile);
    //Modified for the IR-027867V6R2011 to support all the local scripts
    //osw = new OutputStreamWriter(fio,  fileEncodeType);
    osw = new OutputStreamWriter(fio,"UTF-8");
  }

  StringBuffer metrixStringBuffer = new StringBuffer();
  StringBuffer headerStringBuffer = new StringBuffer();

  char carriageReturn ='\r';
  char newLine ='\n';
  String sWhereExp="";
  MQLCommand mqlCommand = new MQLCommand();

  String strMqlQuery1="";
  String strMqlQuery2="";
  String strMqlQuery3="";
  String strQueryResult1="";
  String strQueryResult2="";
  String strQueryResult3="";
  String strQueryError1="";
  String strQueryError2="";
  StringList statesList = new StringList();
  Enumeration stateEnum;

  //
  // Create the header according to type.
  //

  String strStateNames = "";
  StringTokenizer strtok = null;
  StringTokenizer strtok1 = null;
  if (sType.equalsIgnoreCase(sTypeECR))
  {

    sWhereExp = "policy ==  \"" +  sPolicy + "\"";

    String mqlCmd = "print policy '" + sPolicy + "' select state dump |";
    mqlCommand.open(context);
    mqlCommand.executeCommand(context,"print policy $1 select $2 dump $3",sPolicy,"state","|");
    strStateNames = mqlCommand.getResult().trim();
    mqlCommand.close(context);

    strtok = new StringTokenizer(strStateNames, "|");
    headerStringBuffer.append(strType);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sName);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sRevision);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sDescription);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strOriginator);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strCatOfChange);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strRDesEng);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strECREval);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sCurrentState);
    headerStringBuffer.append(sDel);

    while(strtok.hasMoreTokens()) {
      String stateName = strtok.nextToken();
      statesList.add(stateName);
      stateName = i18nNow.getStateI18NString(sPolicy,stateName,language);
      headerStringBuffer.append(stateName);
      headerStringBuffer.append(sDel);
    }

   // headerStringBuffer.append(strProductLine);
    headerStringBuffer.append(sDel);
   // headerStringBuffer.append(strChangeBoard);
    headerStringBuffer.append(carriageReturn);
    headerStringBuffer.append(newLine);

  }
  else if(sType.equalsIgnoreCase(sTypeECO))
  {
    sWhereExp = "policy ==  \"" + sPolicy +  "\"";

    String mqlCmd = "print policy '" + sPolicy + "' select state dump |";
    mqlCommand.open(context);
    mqlCommand.executeCommand(context,"print policy $1 select $2 dump $3",sPolicy,"state","|");
    strStateNames = mqlCommand.getResult().trim();
    mqlCommand.close(context);

    strtok = new StringTokenizer(strStateNames, "|");

    headerStringBuffer.append(strType);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sName);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sRevision);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sDescription);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strOriginator);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strPriority);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strRDesEng);
    headerStringBuffer.append(sDel);
  //  headerStringBuffer.append(strReleaseDistributionGroup);
   // headerStringBuffer.append(sDel);
    headerStringBuffer.append(strResponsibleManufacturingEngineer);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sCurrentState);

    while(strtok.hasMoreTokens()) {
      String stateName = strtok.nextToken();
      statesList.add(stateName);
      stateName = i18nNow.getStateI18NString(sPolicy,stateName,language);
      headerStringBuffer.append(sDel);
      headerStringBuffer.append(stateName);
    }

    headerStringBuffer.append(carriageReturn);
    headerStringBuffer.append(newLine);
}
  else if(sType.equalsIgnoreCase(ChangeConstants.TYPE_CHANGE_ORDER) || sType.equalsIgnoreCase(ChangeConstants.TYPE_CHANGE_REQUEST))
  {
    sWhereExp = "policy ==  \"" + sPolicy +  "\"";


    mqlCommand.open(context);
    mqlCommand.executeCommand(context,"print policy $1 select state dump $2",sPolicy,"|");
    strStateNames = mqlCommand.getResult().trim();
    mqlCommand.close(context);

    strtok = new StringTokenizer(strStateNames, "|");

    headerStringBuffer.append(strType);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sName);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sRevision);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sDescription);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strOriginator);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strSeverity);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sCurrentState);

    while(strtok.hasMoreTokens()) {
      String stateName = strtok.nextToken();
      statesList.add(stateName);
      stateName = i18nNow.getStateI18NString(sPolicy,stateName,language);
      headerStringBuffer.append(sDel);
      headerStringBuffer.append(stateName);
    }

    headerStringBuffer.append(carriageReturn);
    headerStringBuffer.append(newLine);
}
  else if(sType.equalsIgnoreCase(ChangeConstants.TYPE_CHANGE_ACTION))
  {
    sWhereExp = "policy ==  \"" + sPolicy +  "\"";

    mqlCommand.open(context);
    mqlCommand.executeCommand(context,"print policy $1 select state dump $2",sPolicy,"|");
    strStateNames = mqlCommand.getResult().trim();
    mqlCommand.close(context);

    strtok = new StringTokenizer(strStateNames, "|");

    headerStringBuffer.append(strType);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sName);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sRevision);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sDescription);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strOriginator);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(strSeverity);
    headerStringBuffer.append(sDel);
    headerStringBuffer.append(sCurrentState);

    while(strtok.hasMoreTokens()) {
      String stateName = strtok.nextToken();
      statesList.add(stateName);
      stateName = i18nNow.getStateI18NString(sPolicy,stateName,language);
      headerStringBuffer.append(sDel);
      headerStringBuffer.append(stateName);
    }

    headerStringBuffer.append(carriageReturn);
    headerStringBuffer.append(newLine);
}

  // Execute a query to get all ECR's or ECO's
  String sWildPattern  = "*";
  String revFirstinSeq = "";

  //restrict vaults
  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
  String vaultPattern = person.getCompany(context).getAllVaults(context, true);

  matrix.db.Query queryPartBO = new matrix.db.Query();
  queryPartBO.setBusinessObjectType(sType);
  queryPartBO.setBusinessObjectName(sWildPattern);
  queryPartBO.setBusinessObjectRevision(sWildPattern);
  queryPartBO.setVaultPattern(vaultPattern);
  queryPartBO.setOwnerPattern(sWildPattern);
  queryPartBO.setWhereExpression(sWhereExp);
  queryPartBO.setExpandType(true);
  if (session.getValue("queryLimit") != null) {
    try
    {
      queryPartBO.setObjectLimit(Short.parseShort((String)session.getValue("queryLimit")));
    }
    catch (Exception exp) {}
  }

  BusinessObjectList bObjList =   queryPartBO.evaluate(context);
  BusinessObjectItr bObjItr = new BusinessObjectItr(bObjList);

  // If type is ECR
  if (sType.equalsIgnoreCase(sTypeECR))
  {

     while (bObjItr.next())
    {
       BusinessObject bObj = (BusinessObject)bObjItr.obj();
       bObj.open(context);

       String objId = bObj.getObjectId(context);
       String currentState = mxBus.getCurrentState(context, objId).getName();

       matrix.db.Policy partPolicy = bObj.getPolicy(context);
       partPolicy.open(context);
       if (partPolicy.hasSequence()) {
         revFirstinSeq = partPolicy.getFirstInSequence();
       }

       partPolicy.close(context);
       String strName = bObj.getName();
       

       mqlCommand.open(context);

       mqlCommand.executeCommand(context,"print bus $1 $2 $3 select $4 $5 $6 $7 $8 $9 $10 $11 $12 dump $13",    
                                                sType,strName,revFirstinSeq,
                                                "type","name","revision","description","attribute["+attrOriginator+"]","attribute["+attrCatOfChange+"]",
                                                "attribute["+attrRDesEng+"]","attribute["+attrECREval+"]","current","$");


       strQueryResult1 = mqlCommand.getResult().trim();
       StringList sListQueryResult = FrameworkUtil.split(strQueryResult1, "$");
       StringList formatedQueryResult = new StringList();
 	  for(int i = 0; i < sListQueryResult.size(); i++){
 	      String strFormated = (String) sListQueryResult.get(i);
 	     if(i == 0){
	     		strFormated = "\"" + i18nNow.getTypeI18NString(strFormated,language) + "\"";
	     	}
	     else if(i == 5){
	     		strFormated = "\"" + i18nNow.getRangeI18NString(attrCatOfChange, strFormated, language) + "\"";
	     	}
	     else if(i == 8){
	     		strFormated = "\"" + i18nNow.getStateI18NString(sPolicy,strFormated,language) + "\"";
	     	}
	     else {
	     	 strFormated = "\"" + strFormated + "\"";
	     	}
 	      strFormated = strFormated.replace('\r',' ');
 	      strFormated = strFormated.replace('\n',' ');
 	      if(strFormated.indexOf(",") != -1 && ",".equals(sDel)){
 	      	 strFormated = strFormated.replace("\"","\"\"");
 	     	 strFormated = "\"" + strFormated + "\"";
 	      }
 	      formatedQueryResult.add(strFormated);
 	  }
       strQueryResult1 = FrameworkUtil.join(formatedQueryResult, sDel);
       
       
      // strQueryResult1 = mqlCommand.getResult().trim();
       strQueryError1 = mqlCommand.getError().trim();

       String datesList = "";
       boolean currentReached = false;
       mqlCommand.executeCommand(context,"print bus $1 $2 $3 select $4 dump $5",sType,strName,revFirstinSeq,"state.actual",sDel);
       strQueryResult2 = mqlCommand.getResult().trim();

       if(strCancelledStateECR.equalsIgnoreCase(currentState))
       {
           strQueryResult2=FrameworkUtil.findAndReplace(strQueryResult2,sDel+sDel,sDel+" "+sDel);
           strQueryResult2=FrameworkUtil.findAndReplace(strQueryResult2,sDel+sDel,sDel+" "+sDel);
       }
       
       strtok1 = new StringTokenizer(strQueryResult2, sDel);
       stateEnum = statesList.elements();
        while(stateEnum.hasMoreElements()) {
          String stateName = (String)stateEnum.nextElement();
          if(stateName.equals(currentState)){
            currentReached = true;
          }
          if(currentReached && (!stateName.equals(currentState))){
            datesList += sDel;
          }else{
            datesList += sDel+strtok1.nextToken();
          }
        }


       strQueryError2 = mqlCommand.getError().trim();

       /*if (strQueryResult3.equalsIgnoreCase("")) {
         strQueryResult3=sDel;
       }*/
       mqlCommand.close(context);

       // Replace the Carriage Return and New line character with spaces.
       strQueryResult1 = strQueryResult1.replace('\r',' ');
       strQueryResult1 = strQueryResult1.replace('\n',' ');

       metrixStringBuffer.append(strQueryResult1).append(datesList).append(sDel).append(strQueryResult3);
       metrixStringBuffer.append(carriageReturn).append(newLine);
       bObj.close(context);
    }
  }

  // If Type is ECO
  if (sType.equalsIgnoreCase(sTypeECO))
  {
    while(bObjItr.next())
    {
      BusinessObject bObj = (BusinessObject)bObjItr.obj();
      bObj.open(context);

      String objId = bObj.getObjectId(context);
      String currentState = mxBus.getCurrentState(context, objId).getName();

      String strName = bObj.getName();
      
      mqlCommand.open(context);
      mqlCommand.executeCommand(context,"print bus $1 $2 $3 select $4 $5 $6 $7 $8 $9 $10 $11 $12 dump $13",
                                                   sType,strName,"-",
                                                   "type","name","revision","description",
                                                   "attribute[" + attrOriginator + "]","attribute[" + attrPriority + "]","attribute[" + attrRDesEng + "]",
                                                   "attribute[" + attrResponsibleManufacturingEngineer + "]","current","$");


      strQueryResult1 = mqlCommand.getResult().trim();
      StringList sListQueryResult = FrameworkUtil.split(strQueryResult1, "$");
      StringList formatedQueryResult = new StringList();
	  for(int i = 0; i < sListQueryResult.size(); i++){
	      String strFormated = (String) sListQueryResult.get(i);
	      if(i == 0){
	     		strFormated = "\"" + i18nNow.getTypeI18NString(strFormated,language) + "\"";
	     	}
	     else if(i == 5){
	     		strFormated = "\"" + i18nNow.getRangeI18NString(attrPriority, strFormated, language) + "\"";
	     	}
	     else if(i == 8){
	     		strFormated = "\"" + i18nNow.getStateI18NString(sPolicy,strFormated,language) + "\"";
	     	}
	     else {
	     	 strFormated = "\"" + strFormated + "\"";
	     	}
	      strFormated = strFormated.replace('\r',' ');
	      strFormated = strFormated.replace('\n',' ');
	      if(strFormated.indexOf(",") != -1 && ",".equals(sDel)){
 	     	strFormated = strFormated.replace("\"","\"\"");
	     	 strFormated = "\"" + strFormated + "\"";
	      }
	      formatedQueryResult.add(strFormated);
	  }
      strQueryResult1 = FrameworkUtil.join(formatedQueryResult, sDel);
      



       String datesList = "";
       boolean currentReached = false;
       mqlCommand.executeCommand(context,"print bus $1 $2 $3 select $4 dump $5",sType,strName,"-","state.actual",sDel);
       strQueryResult2 = mqlCommand.getResult().trim();
       //fix for metrix report when ECO is cancelled
       if(strCancelledStateECO.equalsIgnoreCase(currentState))
        {
            strQueryResult2=FrameworkUtil.findAndReplace(strQueryResult2,sDel+sDel,sDel+" "+sDel);
            strQueryResult2=FrameworkUtil.findAndReplace(strQueryResult2,sDel+sDel,sDel+" "+sDel);
        }
       strtok1 = new StringTokenizer(strQueryResult2, sDel);
       stateEnum = statesList.elements();
        while(stateEnum.hasMoreElements()) {
          String stateName = (String)stateEnum.nextElement();
          if(stateName.equals(currentState)){
            currentReached = true;
          }
          if(currentReached && (!stateName.equals(currentState))){
            datesList += sDel;
          }else{
            datesList += sDel+strtok1.nextToken();
          }
        }

      strQueryResult3 ="";
      mqlCommand.close(context);

      // Replace the Carriage Return and New line character with spaces.
      strQueryResult1 = strQueryResult1.replace('\r',' ');
      strQueryResult1 = strQueryResult1.replace('\n',' ');

      metrixStringBuffer.append(strQueryResult1).append(datesList);
      metrixStringBuffer.append(carriageReturn).append(newLine);

      bObj.close(context);
    }
  }
  if (sType.equalsIgnoreCase(ChangeConstants.TYPE_CHANGE_ORDER) || sType.equalsIgnoreCase(ChangeConstants.TYPE_CHANGE_REQUEST) || sType.equalsIgnoreCase(ChangeConstants.TYPE_CHANGE_ACTION))
  {
    while(bObjItr.next())
    {
      BusinessObject bObj = (BusinessObject)bObjItr.obj();
      bObj.open(context);

      String objId = bObj.getObjectId(context);
      String currentState = mxBus.getCurrentState(context, objId).getName();

      String strName = bObj.getName();
      //String severity = (String)bObj.getAttributeValues(context, "attribute[Severity]").getValue();

      //String Sev="Low";
      mqlCommand.open(context);
      mqlCommand.executeCommand(context,"print bus $1 $2 $3 select $4 $5 $6 $7 $8 $9 $10 dump $11",
                                                   sType,strName,"-",
                                                   "type","name","revision","description",
                                                   "attribute[" + attrOriginator + "]","attribute[" + attrSeverity + "]",
                                                   "current","$");


      strQueryResult1 = mqlCommand.getResult().trim();
      StringList sListQueryResult = FrameworkUtil.split(strQueryResult1, "$");
      StringList formatedQueryResult = new StringList();
	  for(int i = 0; i < sListQueryResult.size(); i++){
	      String strFormated = (String) sListQueryResult.get(i);
	     if(i == 0){
	     		strFormated = "\"" + i18nNow.getTypeI18NString(strFormated,language) + "\"";
	     	}
	     else if(i == 5){
	     		strFormated = "\"" + i18nNow.getRangeI18NString(attrSeverity, strFormated, language) + "\"";
	     	}
	     else if(i == 6){
	     		strFormated = "\"" + i18nNow.getStateI18NString(sPolicy,strFormated,language) + "\"";
	     	}
	     else {
	     	 strFormated = "\"" + strFormated + "\"";
	     	}
	      strFormated = strFormated.replace('\r',' ');
	      strFormated = strFormated.replace('\n',' ');
	      if(strFormated.indexOf(",") != -1 && ",".equals(sDel)){
 	     	strFormated = strFormated.replace("\"","\"\"");
	     	 strFormated = "\"" + strFormated + "\"";
	      }
	      formatedQueryResult.add(strFormated);
	  }
      strQueryResult1 = FrameworkUtil.join(formatedQueryResult, sDel);
      



       String datesList = "";
       boolean currentReached = false;
       mqlCommand.executeCommand(context,"print bus $1 $2 $3 select $4 dump $5",sType,strName,"-","state.actual",sDel);
       strQueryResult2 = mqlCommand.getResult().trim();
       //fix for metrix report when ECO is cancelled
       if(strCancelledStateECO.equalsIgnoreCase(currentState))
        {
            strQueryResult2=FrameworkUtil.findAndReplace(strQueryResult2,sDel+sDel,sDel+" "+sDel);
            strQueryResult2=FrameworkUtil.findAndReplace(strQueryResult2,sDel+sDel,sDel+" "+sDel);
        }
       strtok1 = new StringTokenizer(strQueryResult2, sDel);
       stateEnum = statesList.elements();
        while(stateEnum.hasMoreElements()) {
          String stateName = (String)stateEnum.nextElement();
          if(stateName.equals(currentState)){
            currentReached = true;
          }
          if(currentReached && (!stateName.equals(currentState))){
            datesList += sDel;
          }else{
            datesList += sDel+strtok1.nextToken();
          }
        }

      strQueryResult3 ="";
      mqlCommand.close(context);

      // Replace the Carriage Return and New line character with spaces.
      strQueryResult1 = strQueryResult1.replace('\r',' ');
      strQueryResult1 = strQueryResult1.replace('\n',' ');

      metrixStringBuffer.append(strQueryResult1).append(datesList);
      metrixStringBuffer.append(carriageReturn).append(newLine);

      bObj.close(context);
    }
  }

  String outputString = headerStringBuffer.append(metrixStringBuffer.toString()).toString();

  BufferedWriter bw1 = new BufferedWriter( osw );
//XSSOK
  bw1.write(outputString);
  bw1.flush();
  bw1.close();
//   url="emxengchgMetricsReportConfirm.jsp?type="+sType+"&filename="+filename;
  url="emxengchgMetricsReportConfirm.jsp";
%>

<%@include file = "emxDesignBottomInclude.inc"%>
<html>
<body>
<form name="metrixReport" method="post" action="emxengchgMetricsReportConfirm.jsp">
<!-- XSSOK -->
<input type="hidden" name="type" value="<%=sType%>"/>
<!-- XSSOK -->
<input type="hidden" name="filename" value="<%=filename%>"/>
<script language="Javascript">
//XSSOK
document.metrixReport.action="<%=XSSUtil.encodeForJavaScript(context,url)%>";
document.metrixReport.submit();
<%-- //window.location.href = "<%=XSSUtil.encodeForJavaScript(context,url)%>"; --%>
</script>
</form>
</body>
</html>
