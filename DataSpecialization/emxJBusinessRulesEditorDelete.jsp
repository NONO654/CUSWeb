<%--  emxJBusinessRulesEditorDelete.jsp - delete a business Rule 
  Copyright (c) 2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  by S63
--%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.StringTokenizer" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.dassault_systemes.JBusinessRulesEditor.BusinessRulesEditorServices" %>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>	
<%@page import="java.util.ArrayList"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%        

String parmValue = "";
String currentId = "";
String parentId = "";
String level = "";
String root = "";
String errMsg1 = "";
String errMsg2 = "";
String errMsg3 = "";
Map paramMap = new HashMap();
Map programMap = new HashMap();

String param = emxGetParameter(request, "emxTableRowId");
if ((null != param) )
{	
	if (param.startsWith("|") == true ) 
	{
		param = param.substring(1);
	}
	//System.out.println(" - param : " + param);
	
	int idxPipes = param.indexOf("|");
	if (idxPipes > 0 ) 
	{	
		if (!context.isTransactionActive())
			ContextUtil.startTransaction(context, true);
		StringTokenizer st = new StringTokenizer(param, "|");
		currentId = st.nextToken();
		//System.out.println("current target : " + currentId);
		parentId = st.nextToken();
		if(!st.hasMoreTokens())
		{
			try
			{
				errMsg1 = BusinessRulesEditorServices.getNLSMessage(context,"emxDataSpecialization.ErrMsg.InvalidDelChoiceOs", null, null);
			}
			catch (Exception e) 
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			} 
		%>
			<SCRIPT language="Javascript">	
			alert("<%=errMsg1%>");
			</SCRIPT>				
		<%
		}
		else
		{
			//System.out.println("parent target : " + parentId);
			level = st.nextToken();
			root = level;
			if (level!=null)
			{
				String[] listString3 = level.split(",");
				level = String.valueOf(listString3.length);
				if(level.equals("3"))
				{
					try
					{
						errMsg2 = BusinessRulesEditorServices.getNLSMessage(context,"emxDataSpecialization.ErrMsg.InvalidDelChoiceO", null, null);
					}
					catch (Exception e) 
					{
						// TODO Auto-generated catch block
						e.printStackTrace();
					} 
					%>
						<SCRIPT language="Javascript">	
						alert("<%=errMsg2%>");
						</SCRIPT>
							
					<%
				}
				else if(level.equals("4"))
				{
					paramMap.put("objectId",currentId);
					paramMap.put("openingId",parentId);
				//	System.out.println("level : " + level);
					programMap.put("paramMap", paramMap);
					String[] args = JPO.packArgs(programMap);
					JPO.invoke(context,"emxBusinessRulesEditorProgram",null,"deleteBusinessRule",args,String.class);
					%>
					<script language="javascript">
					var sbWindow = findFrame(getTopWindow(), "content");
					if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort)
					{
						window.parent.location.href = window.parent.location.href ;
					}
					<%--
						var arrRows = sbWindow.getCheckedRows();
						getTopWindow().refreshTablePage();
						
						var row = arrRows[0].getAttribute("id");
						var tabRes = row.split(",");
						var res = tabRes[0]+","+tabRes[1]+","+tabRes[2];
						var arrIds=[]
						arrIds.push(res);
						setTimeout(sbWindow.emxEditableTable.expand(arrIds,"1"),9000);
					   sbWindow.emxEditableTable.refreshStructureWithOutSort();
					   sbWindow.refreshRows();
					   sbWindow.expandAll();
					   --%>
					</script> 
					<%
				}
				else if(level.equals("5"))
				{
					try
					{
						errMsg3 = BusinessRulesEditorServices.getNLSMessage(context,"emxDataSpecialization.ErrMsg.InvalidDelChoiceCr", null, null);
					}
					catch (Exception e) 
					{
						// TODO Auto-generated catch block
						e.printStackTrace();
					} 
					%>
						<SCRIPT language="Javascript">	
						alert("<%=errMsg3%>");
						</SCRIPT>
							
					<%
				}
			}
		}
	}
}
%>
