<!-- emxTriggerValidationProcess.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
-->

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="lifecycleBeanNew" class="com.matrixone.apps.framework.lifecycle.CalculateSequenceNumber" scope="session"/>
<%
	String strSelectedId = (String)emxGetParameter(request, "emxTableRowId");
	StringList strSelectObjList = FrameworkUtil.split(strSelectedId,",");
	StringBuffer strResults = new StringBuffer();
	strResults.append("<mxRoot><data><![CDATA[");
	//Context con = new Context("localhost:1099");
	for(int i=0;i<strSelectObjList.size();i++)
	{
		StringList strIdList = FrameworkUtil.split((String)strSelectObjList.get(i),"|");
		StringList strObjectList = FrameworkUtil.split((String)strIdList.get(0),"~");
		String strTriggerId = (String) strIdList.get(1);
		if(i!=0)
		{
			strResults.append("|");
		}
		//loop to execute the list of trigger for list of objects that user have selected to Validate
		for(int j=0;j<strObjectList.size();j++)
		{
			if(j!=0)
			{
				strResults.append("|");
			}
			String strObjectId = (String)strObjectList.get(j);

			String strSelectedObjects = strObjectId+"|"+strTriggerId;
			String[] methodArgs = JPO.packArgs(strSelectedObjects);
			//Map map = new HashMap();
			//map.put("id",strObjectId);
			strResults.append(XSSUtil.encodeForXML(context,strObjectId));
			strResults.append("~");
			String strJPOResults = (String) JPO.invoke(context,"emxTriggerValidationResults",new String[1],"executeTriggers",methodArgs,String.class);
			strResults.append(strJPOResults);
			StringList strCommentsList = lifecycleBeanNew.getClientTasks(context);
			strResults.append("~");
			strResults.append(" ");
			String strTempComments = "";
			for(int k=0; k<strCommentsList.size(); k++)
			{
			    strTempComments += (String) strCommentsList.get(k)+"  ";
			}
			strResults.append(strTempComments);
		}
	}
	
	strResults.append("]]></data></mxRoot>");
	
	System.out.println("strResults--------->"+strResults.toString());
	out.clear();
	response.setContentType("text/xml; charset=UTF-8");
	out.write(strResults.toString());	
%>  
