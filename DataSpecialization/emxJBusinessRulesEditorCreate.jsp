<%--  emxJBusinessRulesEditorCreate.jsp - Add a new business Rule
  Copyright (c) 2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  by S63
--%>
<%@page import="java.util.HashMap"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="java.util.ArrayList" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.dassault_systemes.JBusinessRulesEditor.BusinessRulesEditorServices" %>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%

String parmValue = "";
String currentId = "";
String parentId = "";
String level = "";
String openingId = "";
String resourceSetId = "";
String errMsg1 = "", errMsg2 = "", errMsg3 = "", errMsg4 = "";
Map paramMap = new HashMap();
Map programMap = new HashMap();
HashMap<String,String> Result = new HashMap<String,String>();

String paramValue = "";
// boolean isCreated = false;
String param = emxGetParameter(request, "emxTableRowId");
if ((null != param) )
{
	if (param.startsWith("|") == true ) 
	{
		param = param.substring(1);
	}
	
	int idxPipes = param.indexOf("|");
	if (idxPipes > 0 ) 
	{	
		if (!context.isTransactionActive())
			ContextUtil.startTransaction(context, true);
		StringTokenizer st = new StringTokenizer(param, "|");
		currentId = st.nextToken();
		parentId = st.nextToken();
		if(!st.hasMoreTokens())
		{
			try
			{
				errMsg1 = BusinessRulesEditorServices.getNLSMessage(context,"emxDataSpecialization.ErrMsg.InvalidAddChoiceOs", null, null);
			}
			catch (Exception e) 
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			} 
		%>
			<script language="Javascript">
			var errMsg1="<%=errMsg1%>";
			alert(errMsg1);
			</script>		
		<%
		}
		else
		{
			level = st.nextToken();
			if (level!=null)
			{
				String[] listString3 = level.split(",");
				level = String.valueOf(listString3.length);
				if(level.equals("3"))
				{
					resourceSetId = parentId;
					openingId = currentId;
					paramMap.put("openingId",openingId);
					paramMap.put("resourceSetId",resourceSetId);
					//System.out.println("level : " + level);
					
					programMap.put("paramMap", paramMap);
					String[] args = JPO.packArgs(programMap);
					Result = JPO.invoke(context,"emxBusinessRulesEditorProgram",null,"createBusinessRule",args,HashMap.class);
// 					if(isCreated.equals("false"))
					if(Result.isEmpty())
					{
						try
						{
							errMsg2 = BusinessRulesEditorServices.getNLSMessage(context,"emxDataSpecialization.ErrMsg.BrCreation", null, null);
						}
						catch (Exception e) 
						{
							// TODO Auto-generated catch block
							e.printStackTrace();
						} 
						%>
							<script language="Javascript">
							var errMsg2="<%=errMsg2%>";
							alert(errMsg2);
							</script>		
						<%
					}
					else if(Boolean.valueOf((String)Result.get("isCreated"))&&Result.get("ancienModel")!=null)
					{
						%>
						<script language="Javascript">	
						alert("L'Objet a été créé mais un ResourceSet ancien model est déja bindé");
						</script>		
						<%
					}
					else if(!Boolean.valueOf((String)Result.get("isCreated"))&&Result.get("ancienModel")!=null)
					{
						try
						{
							Object[] formatArgs = {Result.get("ancienModel")};
							errMsg3 = BusinessRulesEditorServices.getNLSMessage(context,"emxDataSpecialization.ErrMsg.OldModel",formatArgs,null);
						}
						catch (Exception e) 
						{
							// TODO Auto-generated catch block
							e.printStackTrace();
						} 
						%>
							<script language="Javascript">
							var errMsg3="<%=errMsg3%>";
							alert(errMsg3);
							</script>		
						<%
					}
					else
					{
					%>
						<script language="javascript">
						debugger;
						var sbWindow = findFrame(getTopWindow(), "content");
						if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort)
						{
						   sbWindow.emxEditableTable.refreshStructureWithOutSort();
						   sbWindow.refreshRows();
						   sbWindow.expandNLevels();
						}
						</script> 
					<%
					}
				}
				else
				{
					try
					{
						errMsg4 = BusinessRulesEditorServices.getNLSMessage(context,"emxDataSpecialization.ErrMsg.InvalidAddChoiceBr", null, null);
					}
					catch (Exception e) 
					{
						// TODO Auto-generated catch block
						e.printStackTrace();
					} 
				%>
					<script language="Javascript">
					var errMsg4="<%=errMsg4%>";
					alert(errMsg4);
					</script>		
				<%
				}
			}
		}
	}
}
%>
