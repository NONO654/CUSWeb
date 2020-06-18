<!-- emxMassPromoteDemoteProcess.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
-->

<%@page import="com.matrixone.apps.cache.CacheManager"%>
<%@page import="com.matrixone.apps.framework.lifecycle.LifeCyclePolicyDetails"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxToolbarInclude.inc"%>
<%@page import="matrix.util.MatrixException,com.matrixone.apps.domain.util.SetUtil,java.util.HashMap,java.util.Enumeration,java.util.Vector,java.util.Iterator,matrix.util.StringList,com.matrixone.apps.domain.util.MapList,com.matrixone.apps.framework.lifecycle.CalculateSequenceNumber,com.matrixone.apps.domain.util.PolicyUtil,com.matrixone.apps.domain.util.XSSUtil"%>

<jsp:useBean id="lifecycleBeanNew" class="com.matrixone.apps.framework.lifecycle.CalculateSequenceNumber" scope="session"/>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUITableUtil.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%  String curState=null; 
String sFirstState=null;
String curPolicy="";
    String arrTableRowIds = emxGetParameter(request, "emxTableRowId");
    StringList strlFirstOids = FrameworkUtil.split(arrTableRowIds,",");
    StringList tempIdList = new StringList();
    String uiType = emxGetParameter(request,"uiType");
    String cmd = emxGetParameter(request,"cmd");
    boolean bvariable = true;
    DomainObject dObj = DomainObject.newInstance(context);
    StringList excludedTypeList = new StringList();
    HashMap errorMap = new HashMap();
    MapList errorList = new MapList();
    
	ContextUtil.startTransaction(context, true);
    try 
    {   
        String strExcludedTypeList = UINavigatorUtil.getI18nString(
                "emxFramework.Lifecycle.MassPromoteDemote.ExcludeTypeList",
                "emxSystem", "en");
        
        //added for bug : 347090
        String checkObjectsStates = "";
        if(cmd.equalsIgnoreCase("Promote")){
            checkObjectsStates      = UINavigatorUtil.getI18nString("emxFramework.MassPromoteDemote.checkObjectStatesForPromote","emxFrameworkStringResource",request.getHeader("Accept-Language"));
        }else{
            checkObjectsStates      = UINavigatorUtil.getI18nString("emxFramework.MassPromoteDemote.checkObjectStatesForDemote","emxFrameworkStringResource",request.getHeader("Accept-Language"));
        }
        StringTokenizer sTokenizer = new StringTokenizer(strExcludedTypeList,",");
        while(sTokenizer.hasMoreTokens())
        {
            String  ExcludedTypeName= sTokenizer.nextToken();
            String strRelationship=PropertyUtil.getSchemaProperty(context,ExcludedTypeName);
            excludedTypeList.add(ExcludedTypeName);
         }  
        MapList finalMap = null;
        bvariable=lifecycleBeanNew.checkForObjectStates(context,strlFirstOids); 
        if(!bvariable)
        {
%>
            <script language="JavaScript">
            	parent.callback("NoAlert");
                //XSSOK
                alert("<%=checkObjectsStates%>");               
            </script>   
<%    
        }   
        else
        {
            //To remove excluded types from the selected object ids
            int totalSelectedObj = 0;
            totalSelectedObj = strlFirstOids.size();
            String strKindOfPLMEntity = "type.kindof["+ PropertyUtil.getSchemaProperty(context, "type_PLMEntity") +"]";
            tempIdList = (StringList) strlFirstOids.clone();
            // Add map to store first state for all the policies being used.
            HashMap objectIDAndState =  new HashMap();
            HashMap firstStateMap =  new HashMap();
            StringList selectList = new StringList();
            selectList.addElement(DomainConstants.SELECT_CURRENT);
            selectList.addElement(DomainConstants.SELECT_POLICY);
            selectList.addElement(DomainConstants.SELECT_TYPE);
            selectList.addElement(DomainConstants.SELECT_ID);
            selectList.addElement(DomainConstants.SELECT_STATES);
            selectList.addElement(strKindOfPLMEntity);
            String[] oids = new String[strlFirstOids.size()];
            for(int i=0;i < strlFirstOids.size();i++)
            {
				oids[i] = (String)strlFirstOids.get(i);
			}
            MapList objInfoList = DomainObject.getInfo(context, oids, selectList);
            Iterator<Map> objItr = objInfoList.iterator();
            Map objMap = null;
            String finalState = "";
            while(objItr.hasNext()){
            	objMap = objItr.next();

                String objectId= (String) objMap.get(DomainConstants.SELECT_ID);
                DomainObject dObject1 = new DomainObject(objectId);
                // Shifted this block ahead
                String objType = (String) objMap.get(DomainConstants.SELECT_TYPE);
                String TypeRegName = FrameworkUtil.getAliasForAdmin(context,"Type", objType, true);
                String sIsVPLMEntity  = (String)objMap.get(strKindOfPLMEntity); 
                if(excludedTypeList.contains(TypeRegName))
                {
                    errorMap = new HashMap();
                    errorMap.put("id",objectId);
                    errorMap.put("error","Excluded Type");
                    errorList.add(errorMap);
                    tempIdList.remove(objectId);
                    continue;
                }else if("TRUE".equalsIgnoreCase(sIsVPLMEntity)){
                	String strCantDeleteType  = UINavigatorUtil.getI18nString("emxFramework.Type.PLMEntity.Engineering","emxFrameworkStringResource",request.getHeader("Accept-Language"));
                	errorMap = new HashMap();
                    errorMap.put("id",objectId);
                    errorMap.put("error",strCantDeleteType);
                    errorList.add(errorMap);
                    tempIdList.remove(objectId);
                    continue;
                }
                curState         = (String) objMap.get(DomainConstants.SELECT_CURRENT);
                curPolicy        = (String) objMap.get(DomainConstants.SELECT_POLICY);
                objectIDAndState.put(objectId, curState);
                StringList hiddenStates = LifeCyclePolicyDetails.getHiddenStatesName(context, curPolicy);
                if(cmd.equalsIgnoreCase("Demote")){
                	if(hiddenStates.size() > 0){
                		StateList statesList  = LifeCyclePolicyDetails.getStateList(context, dObject1, curPolicy);
                		sFirstState = ((State)statesList.get(0)).getName();
                	}else if(firstStateMap.containsKey(curPolicy)){
	                	sFirstState = (String)firstStateMap.get(curPolicy);	                	
	                }else{
	                	sFirstState = (String)((StringList)objMap.get(DomainConstants.SELECT_STATES)).get(0);
	                	firstStateMap.put(curPolicy, sFirstState);
	                }	                
                if(curState.equalsIgnoreCase(sFirstState)){
                    errorMap = new HashMap();
                    errorMap.put("id",objectId);
                    errorMap.put("error",UINavigatorUtil.getI18nString("emxFramework.Issue.State.InitialState","emxFrameworkStringResource",request.getHeader("Accept-Language")));
                    errorList.add(errorMap);
                    tempIdList.remove(objectId);                      
                 }else if(hiddenStates.contains(curState)){
                	 errorMap = new HashMap();
                     errorMap.put("id",objectId);
                     errorMap.put("error",UINavigatorUtil.getI18nString("emxFramework.Issue.State.HiddenState","emxFrameworkStringResource",request.getHeader("Accept-Language")));
                     errorList.add(errorMap);
                     tempIdList.remove(objectId); 
                 }
                } else if (hiddenStates.size() > 0) {
                	StateList statesList  = LifeCyclePolicyDetails.getStateList(context, dObject1, curPolicy);
                	finalState = ((State)statesList.get(statesList.size() -1 )).getName();
                	 if(curState.equalsIgnoreCase(finalState)){
                         errorMap = new HashMap();
                         errorMap.put("id",objectId);
                         errorMap.put("error",UINavigatorUtil.getI18nString("emxFramework.MassPromoteDemote.ErrorMessage4.heading","emxFrameworkStringResource",request.getHeader("Accept-Language")));
                         errorList.add(errorMap);
                         tempIdList.remove(objectId);                      
                      }else if(hiddenStates.contains(curState)){
                    	  errorMap = new HashMap();
                          errorMap.put("id",objectId);
                          errorMap.put("error",UINavigatorUtil.getI18nString("emxFramework.Issue.State.HiddenState","emxFrameworkStringResource",request.getHeader("Accept-Language")));
                          errorList.add(errorMap);
                          tempIdList.remove(objectId);  
                      }
                }
            }

            strlFirstOids = tempIdList; 
            MapList mpFinal = null;
         if(strlFirstOids !=null && strlFirstOids.size() > 0)
         {
            finalMap = lifecycleBeanNew.orderParentChild(context,strlFirstOids);
         }    
        //Sort the Map based on sequence number to get the order promotion/demotion
        MapList valueMapList  = new MapList();      
        String sortdir = (cmd.equalsIgnoreCase("Promote"))?"descending":"ascending";
        
        if(finalMap!= null && finalMap.size() > 0)
        {
            Iterator itr=finalMap.iterator();
            while(itr.hasNext())
            {
                Map valueMap=(Map)itr.next();
                String objectId=(String)valueMap.get("id");
                Integer  compNo=(Integer)valueMap.get("sequence");
                HashMap hmp=new HashMap();
                hmp.put("sequence",compNo.toString());
                hmp.put("id",objectId);
                valueMapList.add(hmp);  
            }
            valueMapList.sort("sequence",sortdir,"integer");
            String exceptionMessage = "";           
            for(int i=0;i < valueMapList.size();i++)
            {
            	String error = "";             	   
                Map orderList=(Map)valueMapList.get(i);
                String objectId=(String)orderList.get("id");
	            try{
                DomainObject dObject = new DomainObject(objectId);
				String curStateTemp = dObject.getInfo(context,DomainConstants.SELECT_CURRENT);
				String currentState = (String)objectIDAndState.get(objectId);
	       		if(!curStateTemp.equals(currentState)){
	       			continue;
	       		} 
                if("promote".equalsIgnoreCase(cmd))
                com.matrixone.apps.framework.lifecycle.LifeCycleUtil.checksToPromoteObject(context, dObject);                
                
                if(cmd.equalsIgnoreCase("Promote"))
                {
                    try
                    {
						ContextUtil.setSavePoint(context, "promote");
                        dObject.promote(context);
                    }       
                    catch(MatrixException me)
                    {
                        StringList promotiontask = lifecycleBeanNew.getClientTasks(context);
                        
                        String task = com.matrixone.apps.domain.util.FrameworkUtil.join(promotiontask,"");                      
                        
                        int errCode = 0;
						ErrorMessage mxErrMsg = null;
						Vector meMessages = me.getMessages();
						if (meMessages != null) {
							mxErrMsg = (ErrorMessage) meMessages.get(0);
							if (mxErrMsg != null){
								errCode = mxErrMsg.getErrorCode();
							}
						}
						String exceptionMsg = me.toString();  
						if(errCode == 1500304){
							exceptionMsg = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(),"emxFramework.MassPromoteDemote.ErrorMessage4.heading")+"\n";
						}                  
						
						if(errCode == 5000001){
							exceptionMsg = exceptionMsg.substring(exceptionMsg.indexOf("#5000001:")+9).trim();
						}
						task = task.replace("\"", "\'").trim();
						if(exceptionMsg.contains(task)){
							task ="";
						}
						
                        exceptionMessage= exceptionMsg + "\n" + task;
                        error = objectId+"|"+exceptionMessage;
						ContextUtil.abortSavePoint(context, "promote");
                    }
                }       
                else
                { 
                    try
                    {
						ContextUtil.setSavePoint(context, "demote");
                        dObject.demote(context);
                    }
                    catch(MatrixException me)
                    {
                        StringList demotiontask = lifecycleBeanNew.getClientTasks(context);
                        
                        String task = com.matrixone.apps.domain.util.FrameworkUtil.join(demotiontask,"");                       
                        
                        
                        String exceptionMsg = me.toString();
                        if(exceptionMsg.contains("#5000001:")){
                        	exceptionMsg = exceptionMsg.substring(exceptionMsg.indexOf("#5000001:")+9).trim();
                        	
                        }
                        
                        task = task.replace("\"", "\'").trim();
                        if(exceptionMsg.contains(task.trim())){
                        	task = "";
                        }
                                                                                            
                        exceptionMessage= exceptionMsg + "\n" + task;                      
                        error = objectId+"|"+exceptionMessage;
						ContextUtil.abortSavePoint(context, "demote");
                    }   
                }
            }catch(MatrixException me)
            {
            	String stringPromotionErrorMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.PromotionFailed.ErrorMessage", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
                String stringPromotionMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.PromotionFailed","emxFrameworkStringResource",request.getHeader("Accept-Language"));

                int errCode = 0;
                ErrorMessage mxErrMsg = null;
                Vector meMessages = me.getMessages();
                if (meMessages != null) {
                    mxErrMsg = (ErrorMessage) meMessages.get(0);
                    if (mxErrMsg != null)
                        errCode = mxErrMsg.getErrorCode();
                }

                if (errCode == 5000001) {
                	exceptionMessage = mxErrMsg.getMessage();
                    int pos = exceptionMessage.indexOf("#5000001:");
                    if (pos > -1) {
                    	exceptionMessage = exceptionMessage.substring(pos + 9).trim();
                    }
                }
                if (exceptionMessage == null || exceptionMessage.length() == 0) {
                	exceptionMessage = stringPromotionErrorMsg;
                } else {
                	exceptionMessage = stringPromotionMsg + exceptionMessage;
                }

                if ((exceptionMessage.toString() != null)
                        && (exceptionMessage.toString().trim()).length() > 0) {
                    emxNavErrorObject.addMessage(exceptionMessage.toString()
                            .trim());
                }
                error = objectId+"|"+exceptionMessage;
	
            }
                if(error!=null && error.length() != 0)
                {
                    errorMap = new HashMap();
                    errorMap.put("id",objectId);
                    errorMap.put("error",exceptionMessage);
                    errorList.add(errorMap);
                }
                    
            }

        }      

        
            String timeStamp  = CalculateSequenceNumber.getErrorStamp();
            lifecycleBeanNew.setErrorReportData(timeStamp,errorList);
    %>
            <script language="JavaScript">
                //XSSOK
                var strURL="emxErrorReportDialog.jsp?totalCount="+'<%=totalSelectedObj%>'+"&timeStamp="+'<%=XSSUtil.encodeForURL(context, timeStamp)%>'+"&cmd="+'<%=XSSUtil.encodeForURL(context,cmd)%>';
                parent.callback(strURL);
            </script>
    <%
    
    }
		ContextUtil.commitTransaction(context);
        
    }
    catch(Exception e)
    {
		ContextUtil.abortTransaction(context);
        e.printStackTrace(); 
    }
%>
