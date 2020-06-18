<%--  IEFTableExport.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %><%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*"%><%!
	public String replaceCharacters(String source, char[] charList, char replacementChar)
	{
		String retString = source;
		if(retString==null)
		{
			retString="";
		}

		if(charList !=null && charList.length>0 )
		{
			for (int index = 0; index < charList.length; index++)
			{
				char sElement = charList[index];

				retString=retString.replace(sElement,replacementChar);
			}
		}

		return retString;
	}
%><%
	String timeStamp	=Request.getParameter(request,"timeStamp");
	String fromPage		=Request.getParameter(request,"fromPage");
	String fromTable	=Request.getParameter(request,"fromTable");
	String charSet		= request.getCharacterEncoding();

	if(charSet==null || charSet.trim().equals(""))
		charSet = "UTF-8";
	
	String fileName	= "IEF" + timeStamp;

	response.setContentType("application/csv; charset=" + charSet);
	response.setHeader ("Content-Disposition","attachment; filename=" + fileName + ".csv");
	response.setLocale(request.getLocale());
	
	String badChars		= ",:><[]|*/\\\n";
	char[] charArray	= badChars.toCharArray();
	char repchar		= ' ';

	String fieldSeparator	= ",";
	String recordSeparator	= "\r\n";

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	if(fromPage!= null && fromPage.equalsIgnoreCase("tabless")) 
	{
		MapList relBusObjPageList	= (MapList)session.getAttribute("PageBusObjList" + timeStamp);
		String colHeading[]			= (String[])session.getAttribute("ColHeading"+ timeStamp);
		Hashtable dataTable			= (Hashtable)session.getAttribute("DataTable"+ timeStamp);
		
		if(colHeading==null || (colHeading!=null && colHeading.length == 0))
		{
			out.print(integSessionData.getStringResource("mcadIntegration.Server.Message.CouldNotGetColumns"));
		}

		if(fromTable!=null && fromTable.equals("WS"))
		{
			out.print(integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Object"));
			out.print(fieldSeparator);
		}

		String colHeader = null;
		if (colHeading!=null && colHeading.length > 0)	
		{
			for (int j=0; j<colHeading.length; j++)
			{
				colHeader = colHeading[j];
				if (colHeader!=null && !"&nbsp;".equals(colHeader.trim()))
				{
					colHeader = replaceCharacters(colHeader, charArray, repchar);
					out.print(colHeader);
					out.print(fieldSeparator);
				}
			}
		}

		out.print(recordSeparator);

		if(relBusObjPageList != null && relBusObjPageList.size() > 0)
		{
			for ( int i=0; i< relBusObjPageList.size(); i++ )
			{		
				HashMap elementMap	= (HashMap)relBusObjPageList.get(i);
				String keyName = "";
				String elementOID	= (String)elementMap.get("id");
				String elementRELID = (String)elementMap.get("id[connection]");

				String type		= (String)elementMap.get("type");
				String name		= (String)elementMap.get("name");
				String revision = (String)elementMap.get("revision");

				String objectName = type + " " + name + " " + revision;

				if(fromTable!=null && fromTable.equals("WS"))
				{
					out.print(objectName);
					out.print(fieldSeparator);
				}
				if (elementRELID == null || elementRELID.trim().length() == 0 || elementRELID.equals("null"))
					keyName = elementOID;
				else
					keyName = elementOID + "|" + elementRELID;

				
				Vector rowData = (Vector) dataTable.get(keyName);

				if(rowData != null && rowData.size() > 0 )
				{
					for (int k=0; k<rowData.size(); k++)
					{
						String data = (String)rowData.elementAt(k);
						if(data.equalsIgnoreCase("&nbsp;"))
							data = "";

						data = replaceCharacters(data, charArray, repchar);
						out.print(data);
						out.print(fieldSeparator);
					}
				}
				else
				{
					out.print(integSessionData.getStringResource("mcadIntegration.Server.Message.CouldNotGetRowDataForObject") + objectName);			
				}

				out.print(recordSeparator);
			}
		}
		else
		{
			out.print(integSessionData.getStringResource("mcadIntegration.Server.Message.NoDataFound"));	
		}
	}
	else
	{
		Vector dataVector = (Vector)integSessionData.getSessionObjectByKey("csvData" + timeStamp);
		if(dataVector != null && dataVector.size() > 0)
		{
			for(int i=0; i < dataVector.size() ; i++)
			{
				Vector objVector = (Vector)dataVector.elementAt(i);
				for(int j=0; j < objVector.size() ; j++)
				{
					String data = (String)objVector.elementAt(j);
					data = replaceCharacters(data, charArray, repchar);
					
					out.print(data);
					out.print(fieldSeparator);
				}

				out.print(recordSeparator);
			}
		}
		else
		{
			out.print(integSessionData.getStringResource("mcadIntegration.Server.Message.NoDataFound"));
		}

		if(dataVector != null )
		{
			integSessionData.removeSessionObjectByKey("csvData" + timeStamp);
		}
	}
%>
