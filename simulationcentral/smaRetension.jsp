
<%-- (c) Dassault Systemes, 2007-2012 --%>
<%--
      Simulation Retention
      author: Vineeth Kumar K E
    --%>

<%@page import="com.matrixone.apps.domain.Image"%>
<%@page import="com.matrixone.apps.domain.ImageHolder"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="matrix.db.FormatList"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="matrix.db.Format"%>
<%@page import="java.util.Map"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.common.util.ObjectAccess"%>
<%@page import="matrix.db.Access"%>
<%@page import="matrix.db.AccessList"%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    String objectId  = emxGetParameter(request, "objectId");
    String objectId2[]  =request.getParameterValues("emxTableRowId");
    // the archive functionality requires a string objectid which it passes
    // to the emxCommonDocumentPreCheckout.jsp
    // this is merely for some internal processing. 
    
    // Read objectId2 as "objectIds" which is the list of object ids 
    // that correspond to the documents which needs to be purged or archived.
    // the objectId usually turns up null so it is given
    // the first value in objectId2 array
    if(objectId==null && objectId2!=null)
        objectId=SimulationUIUtil.getObjectID(objectId2[0]);
        
    String action  = emxGetParameter(request, "action");
    String refreshFrame = emxGetParameter(request, "refreshFrame");
    Map mp=null;
    String result=null;
    String formatedErrMsg=null;
    String subject=SimulationUtil.getI18NString(context,"smaSimulationCentral.Retention.MailSubject");
    String message=SimulationUtil.getI18NString(context,"smaSimulationCentral.Retention.MailMessage");
    
    final String SIMDOC_TYPE = SimulationUtil
    .getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationDocument);
    
    final String IMAGEHOLDER_TYPE =SimulationUtil
    .getSchemaProperty(DomainSymbolicConstants.SYMBOLIC_type_ImageHolder);
    
    final String SEL_TYPE=SimulationConstants.XML_ATTRIBUTE_TYPE;

    final String SEL_ID=SimulationConstants.XML_PARAMETER_ROW_ID;
    Boolean refreshAfterPurge=false;
    
    if(action!=null)
    {
        //purge code***********************************
        
        if("purge".equalsIgnoreCase(action) && objectId!=null)
        {
            ContextUtil.pushContext(context);                    //super user access for searching and purging
           //validating the files 
           for(int i=0;i<objectId2.length;i++)
               result=validateFiles(context, SimulationUIUtil.getObjectID(objectId2[i]));
           // go on and purge if files have been checked
           if(result.equals(""))
           {
             for(int i=0;i<objectId2.length;i++)
             {
               result=purge(context, SimulationUIUtil.getObjectID(objectId2[i]));
             }
           }
           
           ContextUtil.popContext(context);
        }
        
        if("notify".equalsIgnoreCase(action) && objectId!=null)
        {
            ContextUtil.pushContext(context); 
            HashMap programMap = new HashMap();
            HashMap noifyMap = new HashMap();
            StringBuffer emxTableRowId=new StringBuffer();
            for(int i=0;i<objectId2.length;i++)
            {
                emxTableRowId.append(SimulationUIUtil.getObjectID(objectId2[i]));
                if(i==objectId2.length-1)
                break;
                emxTableRowId.append(",");
            }
            programMap.put("emxTableRowId", emxTableRowId.toString());
            String[] args = JPO.packArgs(programMap);
            noifyMap=(HashMap)JPO.invoke( context, 
                "jpo.simulation.SimulationRetention", null, 
                "getOwner", args, HashMap.class);
            
            
            StringList objectIdList= new StringList();
            StringList toList= new StringList();
            StringList tempIDList= new StringList();
            StringList tempTOList= new StringList();
            String temp="";
            
           if(!noifyMap.isEmpty())
            {
                objectIdList=(StringList)noifyMap.get("id");
                toList=(StringList)noifyMap.get("to");
            }
            
          for(int i=0;i<objectIdList.size();i++)
          {   
           HashMap note = new HashMap();
           temp=(String)toList.get(i);
           tempTOList.addElement(temp);
           note.put("toList", tempTOList);
           note.put("subject", subject);
           note.put("message", message);
           temp=(String)objectIdList.get(i);
           tempIDList.addElement(temp);
           note.put("objectIdList", tempIDList);
           String[] args2 = JPO.packArgs(note);
           JPO.invoke(context, "emxMailUtil", null,
           "sendMessage", args2);
           tempTOList.clear();
           tempIDList.clear();
           
          }
           
           
           result="smaSimulationCentral.Retention.MailSent";
        
       
            ContextUtil.popContext(context);     
        }
        
        if("purgeSimulation".equalsIgnoreCase(action)&&objectId!=null)
        {
            HashMap programMap = new HashMap();
            MapList purgeList =new MapList();
            StringBuffer emxTableRowId=new StringBuffer();
            int j=0;int k=0;
            String[] oidDOC=null;
            String[] oidIMAGE=null;
            
            for(int i=0;i<objectId2.length;i++)
            {
                emxTableRowId.append(SimulationUIUtil.getObjectID(objectId2[i]));
                if(i==objectId2.length-1)
                break;
                emxTableRowId.append(",");
            }
            programMap.put("objectId", objectId);
            programMap.put("emxTableRowId", emxTableRowId.toString());
            String[] args = JPO.packArgs(programMap);
            purgeList=(MapList)JPO.invoke( context, 
                "jpo.simulation.SimulationRetention", null, 
                "purgeOutput", args, MapList.class);
            
            
            if(!purgeList.isEmpty())
            {
               oidDOC=new String[purgeList.size()];
               oidIMAGE=new String[purgeList.size()];
                
                for(int i=0;i<purgeList.size();i++)
                {
                 mp = new HashMap();
                 mp=(Map)purgeList.get(i);
                 String typeofobj=(String)mp.get(SEL_TYPE);
                 if(typeofobj!=null&&typeofobj.contains(SIMDOC_TYPE))
                 {
                  oidDOC[j]=(String)mp.get(SEL_ID);
                  j++;
                  continue;
                 }
                 if(typeofobj!=null&&typeofobj.contains(IMAGEHOLDER_TYPE))
                 {
                  oidIMAGE[k]=(String)mp.get(SEL_ID);
                  k++;
                  continue;
                 }
                /*if(typeofobj!=null&&type.equals(""))
                 {
                  result="smaSimulationCentral.DataRetention.notSupported";
                  break;
                 }*/
                }  
                
            }
         ContextUtil.pushContext(context);         
          for(int i=0;i<oidDOC.length;i++)
          {
              if(oidDOC[i]!=null)
                  result=validateFiles(context,oidDOC[i]); 

              
          }
              
          if(result==null)
              result="smaSimulationCentral.DataRetention.purgedempty"; 
         if(result.equals("")||result.equals("smaSimulationCentral.DataRetention.empty"))
         {
              for(int i=0;i<oidDOC.length;i++)
              {
                  if(oidDOC[i]!=null)
                  result=purge(context,oidDOC[i]);
                
              }
              for(int i=0;i<oidIMAGE.length;i++)
              {
                  if(oidIMAGE[i]!=null)
                  {
                      
                   DomainObject object = DomainObject.newInstance(context,oidIMAGE[i]);
                   StringList objSelects = new StringList();
                   objSelects.add(DomainConstants.SELECT_ID);

                   MapList relatedList= object.getRelatedObjects(
                          context, "Image Holder" ,"*" , objSelects,null, false, true, (short)1, null, null, 0, null, null, null);
                      
                   if(!relatedList.isEmpty())
                   {
                    Map mp2= (Map)relatedList.get(0);
                    String id=(String)mp2.get("id");
                    if(id!=null)
                     object.setId(id);
                   }
                   Image image = object.getImageObject(context);
                   object.setId(oidIMAGE[i]);
                   //object.deleteObject(context,true);
                   StringList selectList = new StringList(1);
                   selectList.add(Image.SELECT_FORMAT_GENERIC);
                   Map om=object.getInfo(context,selectList );
                   StringList format=(StringList)om.get("format[generic].file.name");
                   int wat= format.size();
                   String [] delFilesArray = new String [wat];
                   for (int iii=0; iii < wat; iii++)
                   {
                     delFilesArray[iii] = (String)format.get(iii);
                   }
                   image.deleteImages(context, delFilesArray);
                      /*
                      String[] args2 = new String[1];
                      args2[0]=oidIMAGE[i];
                      JPO.invoke(context, "emxImageManagerBase", null,
                      "deleteImageHolder", args2);
                      */
                      
                  }
              }
        }
         if(result.equals("smaSimulationCentral.DataRetention.purged"))
         { result="smaSimulationCentral.DataRetention.purgedout";refreshAfterPurge=true;}   
        
         ContextUtil.popContext(context); 
          
        }
        
        //archive code***********************************
      
        if("archive".equalsIgnoreCase(action)&&objectId!=null)
        {
           Boolean empty=false;
           MapList rel=null;
           CommonDocument doc= new CommonDocument();
            for(int i=0;i<objectId2.length;i++)
            {
                doc.setId(SimulationUIUtil.getObjectID(objectId2[i]));
                rel=(MapList)doc.getAllFiles(context);
                if(rel.isEmpty())
                {empty=true;break;}
            }

        
           if(!empty)
           {
               StringBuffer emxTableRowId=new StringBuffer();
               for(int i=0;i<objectId2.length;i++)
               {
                   emxTableRowId.append(SimulationUIUtil.getObjectID(objectId2[i]));
                   if(i==objectId2.length-1)
                   break;
                   emxTableRowId.append(",");
               }
               Map emxCommonDocumentCheckoutData =new HashMap();
               emxCommonDocumentCheckoutData.put("forceApplet","true");
               emxCommonDocumentCheckoutData.put("refresh","true");
               emxCommonDocumentCheckoutData.put("objectId",objectId);
               emxCommonDocumentCheckoutData.put("emxTableRowId",emxTableRowId.toString());
               emxCommonDocumentCheckoutData.put("action","download");
               session.setAttribute("emxCommonDocumentCheckoutData",emxCommonDocumentCheckoutData);
               
             StringBuffer contentURL=new StringBuffer();
             contentURL.append(
             "../components/emxCommonDocumentPreCheckout.jsp")
             .append("?action=download")
             .append("&forceApplet=true")
             .append("&getCheckoutMapFromSession=true")
             .append("&fromDataSessionKey=").append("emxCommonDocumentCheckoutData");
             %>


<script language="javascript">
                getTopWindow().location.href = "<%=contentURL.toString()%>";
             </script>
<%
             result="smaSimulationCentral.DataRetention.archived";
           }
           else
               result="smaSimulationCentral.DataRetention.empty";
        }
      
      //none selected ***********************************
        if(objectId==null&&objectId2==null)
            result="smaSimulationCentral.DataRetention.noneselected";
      
      //formattted output after the operations are done
        formatedErrMsg=SimulationUtil.getI18NString(context,result);
    }
    %>


<%!   
    public String validateFiles(Context context,String objectId)
    throws Exception
    {
        CommonDocument doc = (CommonDocument)DomainObject.newInstance(context,objectId);
        CommonDocument docCheckedIn= new CommonDocument();
        
        //access check**********************************************
        AccessList accessList=doc.getAccessForGrantee(context,context.getUser());
        Boolean userAccess=false;
        if(!accessList.isEmpty())
        {
        Access access=(Access)accessList.get(0);
        userAccess   = ObjectAccess.hasAccess(access, "Add Remove",context.getUser())||
                       ObjectAccess.hasAccess(access, "Remove",context.getUser())||
                       ObjectAccess.hasAccess(access, "Add",context.getUser())||
                       ObjectAccess.hasAccess(access, "Read Write",context.getUser());
        }
        else
        {
            String owner=doc.getOwner(context).toString();
            if(context.getUser().equalsIgnoreCase(owner)||"User Agent".equals(context.getUser()))
                userAccess=true;
        }
          
        
        if(!userAccess)
            return "smaSimulationCentral.DataRetention.noacc";
        
        // variable declarations************************************
        
        MapList relatedList = new MapList();
        MapList refList=new MapList();
        StringList objSelects = new StringList();
        objSelects.add(DomainConstants.SELECT_ID);
        objSelects.add(DomainConstants.SELECT_NAME);
        StringBuilder relpattern=new StringBuilder();
        StringBuilder relpatt=new StringBuilder();
        

        final String REL_ACT=SimulationUtil.getSchemaProperty
        (SimulationConstants.SYMBOLIC_relationship_SimulationContent_Referenced);
        relpattern.append(REL_ACT);

       
        final String REL_LATVER=SimulationUtil.getSchemaProperty
        ("relationship_LatestVersion");
        relpatt.append(REL_LATVER);
        
        final String REL_ACTVER=SimulationUtil.getSchemaProperty
        ("relationship_ActiveVersion");
        relpatt.append(",");
        relpatt.append(REL_ACTVER);

        

        // checking if content is refrenced*****************************
       
        refList= doc.getRelatedObjects(
            context, relpattern.toString() , "*", objSelects,null, true, false, (short)0, null, null, 0, null, null, null);
        if(!refList.isEmpty())
            return "smaSimulationCentral.DataRetention.ref";
        
        
        //searching for files(versioned docs)******************************* 
        
        if(SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationDocument_Versioned).
            equals(doc.getInfo(context, "type")))
        relatedList= doc.getRelatedObjects(
            context, relpatt.toString() , "*", objSelects,null, false, true, (short)0, null, null, 0, null, null, null);
       
        
        //searching for files(non-vers. docs)***************************
        else
            relatedList = doc.getAllFiles(context); 
        
        
       //lock check for non-versioned docs*****************************
        
        if(!SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationDocument_Versioned).
            equals(doc.getInfo(context, "type"))&&doc.isLocked(context))
            return "smaSimulationCentral.DataRetention.locked";
        
       //lock check for versioned docs**********************************
       
        if(SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationDocument_Versioned).
            equals(doc.getInfo(context, "type"))&&relatedList!=null)
        {
            for(int i=0;i<relatedList.size();i++)
            {
                Map mp= new HashMap();
                mp=(Map)relatedList.get(i);
                docCheckedIn.setId((String)mp.get(SimulationConstants.XML_PARAMETER_ROW_ID));
                if(docCheckedIn.isLocked(context))
                {
                    return "smaSimulationCentral.DataRetention.locked";
                }
            }
        }
      if(relatedList.isEmpty())
          return "smaSimulationCentral.DataRetention.empty";

          return "";

    }
    public String purge(Context context,String objectId)
    throws Exception
     {
        CommonDocument doc = (CommonDocument)DomainObject.newInstance(context,objectId);
          try
          {
            String title=(String)doc.getAttributeValue(context,"Title");
            title="Simulation Document "+title+" purged";
                doc.purge(context,null);
                StringList selectList = new StringList(12);
                selectList.add(CommonDocument.SELECT_ID);
                selectList.add(CommonDocument.SELECT_FILE_NAME);
                selectList.add(CommonDocument.SELECT_FILE_FORMAT);
                selectList.add(CommonDocument.SELECT_FILE_SIZE);
                Map objectMap = doc.getInfo(context,selectList);
                StringList format=(StringList)objectMap.get(SimulationConstants.SELECT_FILE_FORMAT);
                StringList name=(StringList)objectMap.get(SimulationConstants.SELECT_FILE_NAME);
                if(!"".equals(format.get(0).toString()))
                {
                    for(int i=0;i<format.size();i++)
                    {

                        doc.deleteFile(context,name.get(i).toString(), format.get(i).toString());
                    }  
                }
               
            

          }
           catch(Exception e){e.printStackTrace();}
     
        return "smaSimulationCentral.DataRetention.purged";
     }
    %>
<script type="text/javascript"> 
            
            
            alert("<%=formatedErrMsg%>");
            if("<%=refreshAfterPurge%>")
            getTopWindow(). refreshTablePage();
            
            </script>

