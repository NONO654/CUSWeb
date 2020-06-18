<%--emxFreezePaneInlineProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneInlineProcess.jsp.rca 1.1 Wed Nov 19 02:55:22 2008 ds-ss Experimental $
--%>
<%@ page import = "matrix.db.*,com.matrixone.servlet.Framework,com.matrixone.util.*,java.util.*,java.io.*,com.matrixone.apps.domain.util.*,
com.matrixone.jdom.*,com.matrixone.apps.framework.ui.*,com.matrixone.jdom.Document,com.matrixone.jdom.input.*,com.matrixone.jdom.output.*" %>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>
<%
	Context context 	   = Framework.getContext(session);

	try
	{   
	    ContextUtil.startTransaction(context, false);
	    
	    response.setHeader("Content-Type", "text/xml; charset=UTF-8");
		response.setContentType("text/xml; charset=UTF-8");
		response.setHeader("Cache-Control", "no-cache");
		response.setHeader("Pragma", "no-cache");
	    
	    String language    	= request.getHeader("Accept-Language");

	    SAXBuilder builder  = new SAXBuilder();	
	    builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
	    builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
	    builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);

	    Document lookupXml  = builder.build(request.getInputStream());	   	
		String timeStamp 	= Request.getParameter(request, "timeStamp");
		String program  	= Request.getParameter(request, "program");
		String function 	= Request.getParameter(request, "function");
		String timeZone		=(String)session.getAttribute("timeZone");
		
		Element mxRoot 		= lookupXml.getRootElement();
		MapList lookupList	= new MapList();
		
		List objectList 	= mxRoot.getChildren("object");
        Iterator itr  		= objectList.iterator();
        while(itr.hasNext()) 
        {
            Element object   = (Element)itr.next();
            String parentId  = object.getAttributeValue("parentId");
            /*String objectId= object.getAttributeValue("objectId");
            String relId     = object.getAttributeValue("relId");
            String markup    = object.getAttributeValue("markup");
            String rowId     = object.getAttributeValue("rowId");*/
            HashMap lookup   = indentedTableBean.getChangedColumnMapFromElement(context, object);
            
            lookup.put("ParentId", parentId);           
            lookup.put("direction", object.getAttributeValue("direction"));
            lookup.put("rowId", object.getAttributeValue("rowId"));
            lookupList.add(lookup);
            
        }
		
	    HashMap requestMap = indentedTableBean.getRequestMap(timeStamp);	   
	    requestMap.put("languageStr",language);
        
		HashMap lookupMap = new HashMap(2);		
		lookupMap.put("requestMap",requestMap);
		lookupMap.put("objectList",lookupList);
	    
	    String[] lookupArgs  = JPO.packArgs(lookupMap);
	    MapList resultList   = null;
		
		try {
			FrameworkUtil.validateMethodBeforeInvoke(context, program, function,"lookupJPO");
		    resultList	     = (MapList) JPO.invoke(context, program, null, function, lookupArgs, MapList.class);
		}catch (Exception exJPO) {
		   throw (new FrameworkException(exJPO.toString()));
		}
		
		MapList oList = new MapList();
		MapList eList = new MapList();
		
		if(resultList != null && lookupList.size() == resultList.size())
		{
	        for(int i = 0 ; i < resultList.size() ; i++) 
	        {
	            Map objectMap	= (Map)resultList.get(i);
	            Element object  = (Element)objectList.get(i);
	            //object.removeChildren("column");
	            object.removeAttribute("relId");
	            object.removeAttribute("objectId");
	            object.removeAttribute("selection");
	            object.removeAttribute("direction");
	            object.removeAttribute("markup");
	            
	            if(objectMap.containsKey("Error"))
	            {
	                object.setAttribute("status","fail");
	                Element error = new Element("error");
	                error.addContent((String)objectMap.get("Error"));
		            object.addContent(error);
	            }else
	            {
	            	object.setAttribute("id",(String)objectMap.get("id"));
	            	Map lookup = (Map)lookupList.get(i);
	            	Map oMap = new HashMap();
	            	oMap.put("id",(String)objectMap.get("id"));
	            	oMap.put("id[connection]","");
	            	String rowId  = (String)lookup.get("rowId");
	            	int lastindex = rowId.lastIndexOf(",");
	            	String pid    = lastindex != -1 ? rowId.substring(0,lastindex) : "";
	            	oMap.put("pid",pid);
	            	oMap.put("direction",(String)lookup.get("direction"));
	            	oList.add(oMap);
	            	object.setAttribute("status","success");
	            	eList.add(object);
	            }
	        }
	        
	        if(oList.size() > 0)
	        {
	            UIFormCommon uif = new UIFormCommon();
	                HashMap reqMap = indentedTableBean.getRequestMap(timeStamp);
	                reqMap.put("dataStatus","pending");
		        Document columnValues = indentedTableBean.getXML(context,oList,timeStamp,timeZone);
		        reqMap.remove("dataStatus");
		        MapList columns		  = indentedTableBean.getColumns(timeStamp);
		        Element rows = columnValues.getRootElement().getChild("rows");
		        List rowList = rows.getChildren("r");
		        MapList rList = new MapList();
		        for(int i  = 0; i < rowList.size(); i++)
		        {
		            rList.add(rowList.get(i));
		        }
		        
		        for(int i  = 0; i < eList.size(); i++)
		        {
		        	Element object = (Element)eList.get(i);
		        	Element rElem  = (Element)rList.get(i);
		        	//object.setAttribute("t",rElem.getAttributeValue("t"));
		        	//object.setAttribute("nId",rElem.getAttributeValue("id"));
		        	List children  = rElem.getChildren("c");
		        	List ochildren  = object.getChildren("column");
		        	MapList cList = new MapList();
			        for(int l  = 0; l < children.size(); l++)
			        {
			            Map column      = (Map)columns.get(l);
			            Element child   = (Element)children.get(l);			            
			            String lookup   = uif.getSetting(column, "Lookup Input Type");
			            String editable = uif.getSetting(column, "Editable");
			            String editMask = child.getAttributeValue("editMask");
			            if((lookup == null || lookup.length() == 0) && "true".equalsIgnoreCase(editable) && !"false".equalsIgnoreCase(editMask))
			            {
			                String text    = child.getTextTrim();
			                Element ochild = (Element)ochildren.get(l);
			                String value   = ochild.getText();
			                text  = FrameworkUtil.findAndReplace(text," ","_SPACE_");
			                value = FrameworkUtil.findAndReplace(value," ","_SPACE_");
			                
				            if(uif.isRelationshipExpressionField(column))
		                    {
				                Map defaultMap  = (Map)column.get("_default_");
				                String defValue = "";
				                if(defaultMap != null)
				                {
				                  defValue = (String)defaultMap.get("Default_ExistingRow");
				                }
				                
				                if((defValue != null && defValue.length() > 0 && !defValue.equals(value)))
				                {
				                    child.setAttribute("edited","true");
				                    child.setAttribute("editedAfterAdd","true");
				                    child.setAttribute("d", defValue);
				                    child.setAttribute("newA",value);
				                }
				                else if("".equals(defValue))
		                        {
				                    child.setAttribute("edited","true");
				                    child.setAttribute("editedAfterAdd","true");
		                        }
				                child.setText(value);
				        	} else
				        	{
					            if(value != null && value.length() > 0 && !value.equals(text))
					            {
					                child.setAttribute("edited","true");
					                child.setAttribute("editedAfterAdd","true");
				                    child.setAttribute("d", text);
				                    child.setAttribute("newA",value);
				                    child.setText(value);
					            }
					            else if("".equals(value) && "".equals(text))
		                        {
				                    child.setAttribute("edited","true");
				                    child.setAttribute("editedAfterAdd","true");
		                        }
				        	}
			            }
			            cList.add(child);
			        }
			        object.removeChildren("column");
		        	for(int l = 0; l < cList.size(); l++)
		        	{
		        	    Element child = (Element)cList.get(l);
		        	    object.addContent(child.detach());
		        	}
		        }
		        
		        columnValues = indentedTableBean.updateCacheData(context,timeStamp,oList,timeZone);
		        rows = columnValues.getRootElement().getChild("rows");
		        rowList = rows.getChildren("r");
		        rList = new MapList();
		        for(int i  = 0; i < rowList.size(); i++)
		        {
		            rList.add(rowList.get(i));
		        }
		        for(int i  = 0; i < eList.size(); i++)
		        {
		        	Element object = (Element)eList.get(i);
		        	Element rElem  = (Element)rList.get(i);
		        	object.setAttribute("nId",rElem.getAttributeValue("id"));
		        }
	        }
	        
		}else
		{
		   throw new Exception("should be same size");
		}
		
	    out.clear();
	    //MxXMLUtils.getOutputter(true).output(lookupXml, out);
	    String outString = MxXMLUtils.getOutputter(true).outputString(lookupXml);
	    outString = FrameworkUtil.findAndReplace(outString, "<![CDATA[", "");
    	outString = FrameworkUtil.findAndReplace(outString, "]]>", "");
    	outString 		 = FrameworkUtil.findAndReplace(outString,"_SPACE_","&#160;");
	    out.write(outString);
	    ContextUtil.commitTransaction(context);
	    
	} catch (Exception ex)
	{
	    ContextUtil.abortTransaction(context);
	    ex.printStackTrace();
	    out.clear();
	    SAXBuilder builder  = new SAXBuilder();
	    Document errorXxml  = builder.build(new StringReader("<mxRoot/>"));
	    Element mxRoot 		= errorXxml.getRootElement();
	    Element error 		= new Element("error");
        error.addContent(ex.getMessage());
	    mxRoot.addContent(error);
	    MxXMLUtils.getOutputter(true).output(errorXxml, out);
	    out.print(ex.getMessage());
	}
%>
