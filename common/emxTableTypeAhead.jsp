<%@ page import = "matrix.db.*, matrix.util.* , com.matrixone.servlet.*, java.util.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*,
                   java.io.BufferedReader, java.io.StringReader,com.matrixone.jdom.*,com.matrixone.jdom.output.XMLOutputter,com.matrixone.util.MxXMLUtils,com.matrixone.apps.framework.taglib.*" %>
<%@include file="../emxRequestWrapperMethods.inc"%> 
<%
    response.setHeader("Content-Type", "text/html; charset=UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    
    Context context = Framework.getContext(session);
    String xml = "";
    String filter = "";
    Document _document=null;
    Element _values=null;
    String _form=null;
    String _field=null;
    String _language=null;
    HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
    String strtable =(String)paramMap.get("table");
    String strcolumn =(String)paramMap.get("column");
    String language = Request.getLanguage(request);
    String program = (String)paramMap.get("program");
    String function =(String)paramMap.get("function");
    
    //JOE -BEGIN(Fix for IR-117673V6R2012x)
    String rowObjectId = (String)paramMap.get("rowObjectId");
    String rowRelId = (String)paramMap.get("rowRelId");
    Map typeAheadMap = new HashMap();
    if(rowObjectId != null && !"null".equalsIgnoreCase(rowObjectId) && rowObjectId.length() > 0 ){
    	typeAheadMap.put("rowObjectId", rowObjectId);
    }
    
    if(rowRelId != null && !"null".equalsIgnoreCase(rowRelId) && rowRelId.length() > 0 ){    
    	typeAheadMap.put("rowRelId", rowRelId);
    }
    //JOE -END
    
    // build empty document
    Enumeration itr = emxGetParameterNames(request); 
    while(itr.hasMoreElements())
    { 
        String paramName = (String)itr.nextElement(); 

        if (paramName.startsWith("type_ahead"))
        {
            filter = (String)paramMap.get(paramName);
            break;
        } 
    }  
    
    if (context != null && program==null && function==null)
    {
    	 // build empty document
        Element root = new Element("table");
        root.setAttribute("name", strtable);
        _document = new Document(root);

        Element field = new Element("column");
        field.setAttribute("name", strcolumn);
        root.addContent(field);
        
        _values = new Element("values");
        _values.setAttribute("count", "0");
        _values.setAttribute("all", "false");
        field.addContent(_values);
      
        try
        {
                     
            if(strtable!=null && strcolumn!=null){
                FieldValueStore fvs = new FieldValueStore(strtable,"table");
                FieldValue[] typeAheadValues = fvs.getSubmittedValues(context, strcolumn);        
                for(int i=0;i<typeAheadValues.length;i++){  
                    // add new value to list of submitted
                    Element value = new Element("v");
                    
                    Element elementDisplay = new Element("d");
                    elementDisplay.setText(typeAheadValues[i].getDisplayValue());
                    Element elementHidden = new Element("h");
                    elementHidden.setText(typeAheadValues[i].getDisplayValue());
                        
                    value.addContent(elementDisplay);
                    value.addContent(elementHidden);
                    _values.addContent(value);
                
                    // update value count
                    _values.setAttribute("count", Integer.toString(_values.getChildren().size()));
                }
                }
            XMLOutputter xmlOut = MxXMLUtils.getOutputter();
            xml = xmlOut.outputString(_document);
        }
        catch (Exception e)
        {
            throw (new JspException(e));
        }
    }
    else{
    	try
        {
            HashMap map = new HashMap();
            map.put("form", strtable);
            map.put("field", strcolumn);
            map.put("language", language);
            
            //JOE - BEGIN(Fix for IR-117673V6R2012x)
    		map.put("typeAheadMap", typeAheadMap);            
            //JOE - END            
            FrameworkUtil.validateMethodBeforeInvoke(context, program, function, "Program");
            xml = (String) JPO.invoke(context, program, JPO.packArgs(map), function, JPO.packArgs(filter), String.class);
        }
        catch (Exception e)
        {
            throw (new JspException(e));
        }
    }
%>
<%= xml.trim() %><!-- XSSOK -->
