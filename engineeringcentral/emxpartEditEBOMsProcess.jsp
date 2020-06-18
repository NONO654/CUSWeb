<%--  emxpartEditEBOMsProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
    session.removeAttribute("finalRestoreMap");
    session.removeAttribute("finalremovalMap");
    session.removeAttribute("SelEbomIds");

  String relType      = DomainObject.RELATIONSHIP_EBOM;
  Map finalremovalMap = new HashMap();
  String txtName      = "";
  String txtRev       = "";
  String type         = "";
  String timeStamp    = emxGetParameter(request,"timeStamp");
  String objectId     = emxGetParameter(request,"objectId");
  String SelEbomIds   = "";
  String removalFlag  = emxGetParameter(request,"removalFlag");
  removalFlag         = (removalFlag==null)?"":removalFlag;

  // execute this code only for removal of EBOM relationship.
  if(removalFlag.equals("true"))
  {
    Part part = (Part)DomainObject.newInstance(context,objectId,DomainConstants.ENGINEERING);
    // not selected ids.
    String NotSelectedRowIds=emxGetParameter(request,"NotSelectedRowIds");
    // selected ids to get removed.
    String RemovalRowIds=emxGetParameter(request,"RemovalRowIds");
    StringTokenizer stringTokenizerForSelected    = new StringTokenizer(RemovalRowIds, ",");
    StringTokenizer stringTokenizerForNotSelected = new StringTokenizer(NotSelectedRowIds, ",");
    int count         = stringTokenizerForNotSelected.countTokens();
    int removalCount  = stringTokenizerForSelected.countTokens();
    String removalNamesrelId="";
    for(int k=0;k<removalCount;k++)
    {
      int i=Integer.parseInt(stringTokenizerForSelected.nextToken());
      i=i-1;
      removalNamesrelId=emxGetParameter(request, "srelId"+String.valueOf(i));
      part.removeEBOM(context, removalNamesrelId);
    }
    Map attrMap = DomainRelationship.getTypeAttributes(context,relType);
    String namesrelId="";
    // to restore the values after the screen gets refreshed after the removal.
    for(int j=0;j<count;j++)
    {
      Map removalMap=new HashMap();
      int i=Integer.parseInt(stringTokenizerForNotSelected.nextToken());
      i=i-1;
      namesrelId=emxGetParameter(request, "srelId"+String.valueOf(i));
      txtName=emxGetParameter(request, "txtName"+String.valueOf(i));
      txtRev=emxGetParameter(request, "txtRev"+String.valueOf(i));
      type=emxGetParameter(request, "type"+String.valueOf(i));
      Vector attrNames = new Vector();
      Iterator mapIterator = attrMap.keySet().iterator();
      while(mapIterator.hasNext())
      {
        Map mapinfo = (Map)attrMap.get((String)mapIterator.next());
        attrNames.addElement(mapinfo.get("name"));
      }
      Enumeration enumeration = attrNames.elements();
      while(enumeration.hasMoreElements())
      {
        String attrName = (String)enumeration.nextElement();
		if(attrName.equalsIgnoreCase(DomainObject.ATTRIBUTE_FIND_NUMBER))
        {
			attrName = removeWhiteSpace(attrName);
		}
        String attribute = emxGetParameter(request, attrName+i);
        removalMap.put(attrName,attribute);
      }
      removalMap.put("name",txtName);
      removalMap.put("revision",txtRev);
      removalMap.put("type",type);
      finalremovalMap.put(namesrelId,removalMap);
      SelEbomIds += namesrelId + ",";
    }
    session.setAttribute("finalremovalMap",finalremovalMap);
    session.setAttribute("SelEbomIds",SelEbomIds);
    // javscript code to refresh the parent window and for calling the FS page
%>
      <script language="Javascript">
      //XSSOK
        document.location.href = "emxpartEditEBOMsFS.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&removalFlag=true";
      </script>
<%
    }
    // execute this code only after Done is clicked in the Summary page.
    else
    {
      DomainObject selObj             = DomainObject.newInstance(context);
      Part part                       = new Part(objectId);
      String returnFlag               = "false";
      String errortxtName             = "";
      boolean exceptionMessage        = false;
      SelectList resultSelects        = new SelectList(1);
      Map finalRestoreMap             = new HashMap();
      String sCount   = emxGetParameter(request, "selCount");
      String SelEbomIdsSubmit         = emxGetParameter(request,"SelEbomIdsSubmit");
      resultSelects.add(DomainObject.SELECT_ID);
      Map storedMap             = (Map)session.getAttribute("storedMap");
      StringTokenizer stSubmit  = new StringTokenizer(SelEbomIdsSubmit, ",");
      //StringTokenizer stringTokenizer = new StringTokenizer(SelEbomIds, ",");
      //int count                 = stringTokenizer.countTokens();
      int count = Integer.parseInt(sCount);
      String namesrelId         = "";
      boolean equalsFlag        = false;
      Vector submitVector       = new Vector();
      while(stSubmit.hasMoreTokens())
      {
      submitVector.addElement(stSubmit.nextToken());
      }
      Map attributeMap = DomainRelationship.getTypeAttributes(context,relType);
      // storing the values for restoring it later if the page has to be shown again.
      for(int i=0;i<count;i++)
      {
        equalsFlag=false;
        Map restoreMap  = new HashMap();
        txtName         = emxGetParameter(request, "txtName"+String.valueOf(i));
        namesrelId      = emxGetParameter(request, "srelId"+String.valueOf(i));
        txtRev          = emxGetParameter(request, "txtRev"+String.valueOf(i));
        type            = emxGetParameter(request, "type"+String.valueOf(i));
        restoreMap.put("name",txtName);
        restoreMap.put("revision",txtRev);
        restoreMap.put("type",type);
        Iterator iterator = attributeMap.keySet().iterator();
        while(iterator.hasNext())
        {
          String attribName  = (String)iterator.next();
          String attribVal="";
           if(attribName.equalsIgnoreCase(DomainObject.ATTRIBUTE_FIND_NUMBER))
		   {
 			   attribName = removeWhiteSpace(attribName);
   	           attribVal = emxGetParameter(request, attribName+i);
	           restoreMap.put(DomainObject.ATTRIBUTE_FIND_NUMBER,attribVal);
		   }
		   else
		   {
				 attribVal = emxGetParameter(request, attribName+i);
          restoreMap.put(attribName,attribVal);

		   }

        }
        Map oldValueMap=(Map)storedMap.get(namesrelId);
        for(int yy=0;yy<submitVector.size();yy++)
        {
          if(namesrelId.equals((String)submitVector.elementAt(yy)))
          {
          equalsFlag=true;
          break;
          }
        }
        // checking if the name,type and revision attribute has been changed by the user
        if(equalsFlag==true)
        {
          if(!(txtName.equals((String)oldValueMap.get("name"))) || !(txtRev.equals((String)oldValueMap.get("revision"))) || !(type.equals((String)oldValueMap.get("type"))))
          {
              try
              {
                String newObjectId = EngineeringUtil.getBusIdForTNR(context,type,txtName,txtRev);
                selObj.setId(newObjectId);
                Map map = new HashMap();
                map.putAll(restoreMap);
                map.remove("name");
                map.remove("revision");
                map.remove("type");

                //Start the transaction
                ContextUtil.startTransaction(context, true);

                DomainRelationship dr = part.connect(context,relType, selObj, false);
                dr.setAttributeValues(context, map);
                part.removeEBOM(context, namesrelId);

                //Commit the transaction
                ContextUtil.commitTransaction(context);
              }
              catch(FrameworkException e)
              {
                //abort the transaction
                ContextUtil.abortTransaction(context);
                returnFlag="true";
                // form the error text message
                if(errortxtName.equals(""))
                {
                  errortxtName += type+ "," + txtName+","+txtRev;
                }
                else
                {
                  errortxtName += ";"+type+ "," + txtName+","+txtRev;
                }
              }
              catch(Exception Ex)
              {
                //abort the transaction
                ContextUtil.abortTransaction(context);
                returnFlag="true";
                exceptionMessage=true;
                errortxtName=Ex.toString();
              }

          }
          else
          {
            String flag="";
            HashMap attrmap = new HashMap();
            Iterator attIterator = attributeMap.keySet().iterator();
            double tz = (new Double((String)session.getValue("timeZone"))).doubleValue();

            while(attIterator.hasNext())
            {
              String key = (String)attIterator.next();
              Map info = (Map) attributeMap.get(key);
              String attrName = (String) info.get("name");
		      if(attrName.equalsIgnoreCase(DomainObject.ATTRIBUTE_FIND_NUMBER))
		      {
 			     attrName = removeWhiteSpace(attrName);
		      }

              String attrValue = emxGetParameter(request, attrName+i);
              if(!(attrValue.equals((String)oldValueMap.get(attrName))))
              {
                flag="changed";
              }
              String sDataType = "";
               try {
                 AttributeType attrTypeGeneric = new AttributeType(attrName);
                 attrTypeGeneric.open(context);
                 sDataType = attrTypeGeneric.getDataType();
                 attrTypeGeneric.close(context);
               } catch (Exception ex ) {
                 // Ignore the exception
                 sDataType = "";
               }
               if (sDataType.equals("timestamp"))
               {
                  attrValue=com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,attrValue,tz,request.getLocale());
			   }
              if(attrName.equalsIgnoreCase("FindNumber"))
              {
				  attrName = DomainObject.ATTRIBUTE_FIND_NUMBER;
			  }
              attrmap.put(attrName, attrValue);
            }
            if(flag.equals("changed"))
            {
              try
              {
                //Start the transaction
                ContextUtil.startTransaction(context, true);

                DomainRelationship ebomRel = DomainRelationship.newInstance(context,namesrelId);
                ebomRel.setAttributeValues(context,attrmap);

                //Commit the transaction
                ContextUtil.commitTransaction(context);

              }
              catch(Exception Ex)
              {
                //abort the transaction
                ContextUtil.abortTransaction(context);

                returnFlag="true";
                exceptionMessage=true;
                errortxtName=Ex.toString();
              }
            }
          }
        }
        finalRestoreMap.put(namesrelId,restoreMap);
        SelEbomIds += namesrelId + ",";
      }
      session.setAttribute("finalRestoreMap",finalRestoreMap);
      session.setAttribute("SelEbomIds",SelEbomIds);
      // display the error message if the new entered Part type,name and revision does not exist.
      if(returnFlag.equals("true"))
      {
        //String DisplayErrMsg  = i18nNow.getI18nString("emxEngineeringCentral.Common.DoesNotExist", "emxEngineeringCentralStringResource",request.getHeader("Accept-Language"));
        String DisplayErrMsg  = EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Common.DoesNotExist");
        String url = "emxpartEditEBOMsFS.jsp?objectId="+objectId+"&timeStamp="+timeStamp;
        if(exceptionMessage==false)
        {
          DisplayErrMsg=errortxtName+" "+DisplayErrMsg;
        }
        else
        {
          DisplayErrMsg=errortxtName;
        }
          session.putValue("error.message", DisplayErrMsg);
%>
      <script language="Javascript">
      //XSSOK
        document.location.href = "<xss:encodeForURL><%=url%></xss:encodeForURL>";
      </script>
<%
         return;
      }
      session.removeAttribute("finalRestoreMap");
      session.removeAttribute("finalremovalMap");
      session.removeAttribute("SelEbomIds");
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
      <script language="Javascript">

      /* Modiifed below code for edit all of ebom and avl report */
     // var objWin = getTopWindow().getWindowOpener().parent;
      var objWin = getTopWindow().getWindowOpener();
      if(getTopWindow().getWindowOpener().parent.name == "treeContent")
      {
         objWin=getTopWindow().getWindowOpener();
      }
      objWin.document.location.href = objWin.document.location.href;
      parent.closeWindow();
      </script>
<%
   }
%>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%!
/**
      * This method is used for removing whitespaces from the Attribute Name
      * @param String - Name of the Attribute
      * @return Attribute name without whitespaces
      * @exception java.lang.Exception The exception description
      **/
    public String removeWhiteSpace(String str) throws Exception
    {
        String whiteSpace = " ";
        String newstr = "";
        try{
            for(int i=0;i<str.length();i++){
                String chstr  =  str.charAt(i)+"";
                if (chstr.equals(whiteSpace)){
                    newstr = str.substring(0,i) + str.substring(i+1, str.length());
                    str=newstr;
                }
            }
        }
        catch(Exception e){
                throw e;
        }
        return str;
    }
%>
