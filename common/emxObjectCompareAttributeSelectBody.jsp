<%--  emxObjectCompareAttributeSelectBody.jsp  
      Copyright (c) 1992-2018 Dassault Systemes.
      All Rights Reserved. 
      This program contains proprietary and trade secret information of MatrixOne,Inc.
      Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program  

    static const char RCSID[] = $Id: emxObjectCompareAttributeSelectBody.jsp.rca 1.7 Wed Oct 22 15:47:47 2008 przemek Experimental przemek $
--%>
 
<jsp:useBean id="compare" class="com.matrixone.apps.domain.util.ObjectCompare" scope="session"/>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
    try
    {
       boolean exists=false;
       boolean previous=false;
       boolean hasAttributes = false;

       String attributes[];
       attributes =(String[]) compare.getselectedAttributes();
       String sAttrName  ="";

       String previousPage=emxGetParameter(request,"previous");
       if (previousPage != null && previousPage.equals("true") && attributes!= null)
       {
         previous=true;
       }
       // Getting the Attribute list on Base Object Type
       MapList attrList=compare.getAttrList();
       if (attrList!= null && attrList.size() > 0)
       {
         hasAttributes=true;
       }

       String [] basicAttributes=new String[5];
       basicAttributes[0]=DomainObject.SELECT_DESCRIPTION;
       basicAttributes[1]=DomainObject.SELECT_MODIFIED;
       basicAttributes[2]=DomainObject.SELECT_ORIGINATED;
       basicAttributes[3]=DomainObject.SELECT_OWNER;
       basicAttributes[4]=DomainObject.SELECT_CURRENT;

%>
      
    <script language="javascript">

      function doCheck(obj)
      {
            if (obj.name == "attrList") 
            {
               var list= document.getElementsByName("attrList")[0];
               var id= document.getElementsByName("attrItem");
            }
            else
            {
               var list=  document.getElementsByName("basicList")[0];
               var id=  document.getElementsByName("basicItem");
             }

             for (var i=0; i < id.length; i++)
             {
                 id[i].checked = list.checked;
              }
      }


      function updateCheck(obj) 
      {
              var checkAll = true;

              if (obj.name == "attrItem") 
              {
                 var list=document.getElementsByName("attrList")[0];
                 var id=document.getElementsByName("attrItem");
              }
              else 
              {
                 var list=document.getElementsByName("basicList")[0];
                 var id=document.getElementsByName("basicItem");
               }

              for (var i = 0; i < id.length; i++)
              {
                if(!id[i].checked)
                {
                  checkAll=false;
                  break;
                }
              }

              list.checked = checkAll;
      }

      function goBack() 
      {
            window.parent.location.href = "emxObjectCompareBaseObjectSelect.jsp?previous=true";
      }

      function submit() 
      {
             document.objcompattrselect.action = "emxObjectCompareReport.jsp";
             document.objcompattrselect.submit();
      }

    </script>


    <form name="objcompattrselect" id="objcompattrselect" method="post" action = "emxObjectCompareReport.jsp" target="_top">

   <TABLE class="list" width="100%">
        <TR>
          <TH>
            <emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.PivotOption</emxUtil:i18n>
          </TH>
        </TR>
        <TR class="even">
          <TD>
             <INPUT type="radio" name="objectview" id="objectview" value="default" checked />  <emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.PivotOption1</emxUtil:i18n> &nbsp; &nbsp;  &nbsp;
             <INPUT type="radio" name="objectview" id="objectview" value="pivot" <%=compare.pivot?"checked":""%> />  <emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.PivotOption2</emxUtil:i18n>
          </TD>
        </TR>
   </TABLE>

      <table class="list" border="0" cellpadding="3" cellspacing="2" width="100%">
          <tr>
            <th width="5%" style="text-align:center"><input type="checkbox" name="basicList" id="basicList" onclick="doCheck(this)" /></th>
            <th nowrap><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.BasicAttributes</emxUtil:i18n> </th>
          </tr>

<% 
          for(int i=0; i<basicAttributes.length; i++)
          {
             sAttrName  = basicAttributes[i];
             // logic for handling previous button for basic attributes.
             exists=false;
             if (previous)
             {
                 for( int j=0;j<attributes.length;j++)
                 {
                    if (sAttrName.equals(attributes[j]))
                      {
                        exists=true;
                      }
                 }
              }
%>

          <tr class='<framework:swap id ="1" />'>
              <td align="center"><input type="checkbox" name ="basicItem" id="basicItem" value = "<xss:encodeForHTMLAttribute><%=sAttrName%></xss:encodeForHTMLAttribute>" onclick="updateCheck(this)" <%=exists?"checked":""%> /></td>
              <td><xss:encodeForHTML><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.<%=sAttrName%></emxUtil:i18n></xss:encodeForHTML>&nbsp;</td>
          </tr>
<%
          }
%>
         <tr>
            <th width="5%" style="text-align:center"><input type="checkbox" name="attrList" id="attrList" onclick="doCheck(this)" /></th>
            <th nowrap><emxUtil:i18n localize="i18nId"> emxFramework.ObjectCompare.AttributeName</emxUtil:i18n></th>
         </tr>

         <framework:mapListItr mapList="<%=attrList%>" mapName="templateMap">
         <tr class='<framework:swap id ="1" />'>
<%
            sAttrName  = (String)templateMap.get("attrName");
            // logic for handling previous button  for attributes.
            exists=false;
            if (previous)
            {
               for( int i=0;i<attributes.length;i++)
               {
                   if (sAttrName.equals(attributes[i]))
                   {
                      exists=true;
                   }
               }
            }
%>
            <td align="center"><input type="checkbox" name ="attrItem" id="attrItem" value = "<xss:encodeForHTMLAttribute><%=sAttrName%></xss:encodeForHTMLAttribute>" onclick="updateCheck(this)" <%=exists?"checked":""%> /></td>
            <td><xss:encodeForHTML><%=EnoviaResourceBundle.getAttributeI18NString(context, sAttrName, request.getHeader("Accept-Language"))%></xss:encodeForHTML>&nbsp;</td>

         </tr>
         </framework:mapListItr>

<%
         // If object type has no attributes, display message.
         if (!hasAttributes)
         {
%>
           <tr class="odd">
              <td class="noresult"  align="center" colspan="4"><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.NoAttributes</emxUtil:i18n></td>
            </tr>
<%
         }
%>

    </table>
    </form>

<%
    }
    catch (Exception ex)
    { 
      if (ex.toString()!=null && ex.toString().length()>0)
        { 
          emxNavErrorObject.addMessage(ex.toString());
        }
    }
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc" %>

