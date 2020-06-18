<!--
//=================================================================
// JavaScript emxengchgValidationUtil.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of Dassault Systemes
// Copyright notice is precautionary only and does not evidence any actual or
// intended publication of such program
//=================================================================
-->
<script language="Javascript">
  var fnArray = new Array();
  var rdArray = new Array();
  var TNRArray = new Array();
  var TNRDArray = new Array();
<%   
String accLanguage  = request.getHeader("Accept-Language");
String fnLength  =   JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberLength");
String rdLength     = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorLength");
String fnUniqueness = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberUnique");
String rdUniqueness = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorUnique");
String ebomUniquenessOperator = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","EBOMUniquenessOperator");
String fnDisplayLeadingZeros = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberDisplayLeadingZeros");

%>
//var INVALID_FORMAT_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.InvalidFormat", "emxEngineeringCentralStringResource",accLanguage)%>";
//var MULTI_PREFIX_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.MultiplePrefix", "emxEngineeringCentralStringResource",accLanguage)%>";
//var INVALID_CHAR_MSG ="<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.InvalidChar","emxEngineeringCentralStringResource",accLanguage)%>";
//var INVALID_QUANTITY = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.SingleQuantity","emxEngineeringCentralStringResource",accLanguage)%>";
//var NOT_UNIQUE_MSG= "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.NotUnique","emxEngineeringCentralStringResource",accLanguage)%>";
//var SINGLE_RANGE_MSG= "<%=i18nNow.getI18nString(" emxEngineeringCentral.ReferenceDesignator.Range","emxEngineeringCentralStringResource",accLanguage)%>";
//var INVALID_MSG= "<%=i18nNow.getI18nString(" emxEngineeringCentral.ReferenceDesignator.Invalid","emxEngineeringCentralStringResource",accLanguage)%>";
//var VALUE_SEPARATOR_MSG= "<%=i18nNow.getI18nString(" emxEngineeringCentral.ReferenceDesignator.DiffValues","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var INVALID_FORMAT_MSG = "<%=EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.InvalidFormat")%>";
//XSSOK
var MULTI_PREFIX_MSG = "<%=EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.MultiplePrefix")%>";
//XSSOK
var INVALID_CHAR_MSG ="<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.InvalidChar")%>";
//XSSOK
var INVALID_QUANTITY = "<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.SingleQuantity")%>";
//XSSOK
var NOT_UNIQUE_MSG= "<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.NotUnique")%>";
//XSSOK
var SINGLE_RANGE_MSG= "<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale()," emxEngineeringCentral.ReferenceDesignator.Range")%>";
//XSSOK
var INVALID_MSG= "<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale()," emxEngineeringCentral.ReferenceDesignator.Invalid")%>";
//XSSOK
var VALUE_SEPARATOR_MSG= "<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale()," emxEngineeringCentral.ReferenceDesignator.DiffValues")%>";
//XSSOK
var RANGE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","RangeReferenceDesignatorSeparator")%>";
//XSSOK
var SINGLE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","DelimitedReferenceDesignatorSeparator")%>";


 /******************************************************************************/ 
 /* function isEmpty() - checks whether the value is blank or not              */
 /*                                                                            */
 /******************************************************************************/ 

    function isEmpty(s)  
    {
      return ((s == null)||(s.length == 0));
    }

 /******************************************************************************/ 
 /* function trim() - removes any leading spaces                               */
 /*                                                                            */
 /******************************************************************************/ 

    function trim(str)
    {
      while(str.length != 0 && str.substring(0,1) == ' ')
      {
        str = str.substring(1);
      }
      while(str.length != 0 && str.substring(str.length -1) == ' ')
      {
        str = str.substring(0, str.length -1);
      }
      return str;
    }


 /******************************************************************************/ 
 /* function chkLength() - returns true is length of the text field             */
 /* is below the specified length.                                              */
 /******************************************************************************/ 
        
 function chkLength(validLength,txtLength)
 {
      return((validLength!=0 && txtLength.length>validLength));

 }
 
 
  /******************************************************************************/   
  /* function isFNUnique() - returns true if the supplied value                 */
  /* is unique with respect to the other values on the form.			*/
  /* takes value and its corresponding rownumber as arguments			*/
  /* rownumber is used to filter the inputted element from checking		*/
  /* against itself								*/
  /******************************************************************************/   
 
 function isFNUnique(inputFN,rowNumber)
  {
  
      var totcount = document.editForm.selCount.value;
      //checking for uniqueness among the user inputted values
      for(var i = totcount-1; i >-1 ; i--)
          {
          var fnobj = eval('document.editForm.FindNumber'+ i );
          if(fnobj!=null)
          {
              var fnvalue=fnobj.value;
              if(fnvalue!="" && i!=rowNumber && inputFN==fnvalue)
              {
                  return false;
              }
  
          }
      }
      
      return true;
  
  }
 
 /******************************************************************************/   
 /* function getNonUniqueFN() - returns a concatenated string containing      */
 /* comma seperated values of TNR. This function checks the form values	       */
 /* with the Array containing database values to validate uniqueness 	       */
 /* on client side.							       */
  /******************************************************************************/   
  
  function getNonUniqueFN(totCount)
  {
   //checking for uniqueness against db values. fnArray contains the db Find Number Values
   var nonUniqueFNs ="";
   var fnobj = "";
   var k=0;
   for(var i=0;i<totCount;i++)
   {
      fnobj = eval('document.editForm.FindNumber' + i);
      if(fnobj!=null)
      {
         for(j=0;j<fnArray.length;j++)
          {
              if(fnArray[j].length>0 && fnArray[j]==fnobj.value)
              {
                if(nonUniqueFNs.length>0)
                {
                   nonUniqueFNs=nonUniqueFNs+","+TNRArray[i];
                   k=i;
                }
                else
                {
                   nonUniqueFNs=nonUniqueFNs+TNRArray[i];
                   k=i;
                }
              }
          }
      }//if(fnobj)
   }
   nonUniqueFNs = nonUniqueFNs+"~"+k;
     return nonUniqueFNs;
  }
  
  
  
      /***************************************************************************** / 
     /* function getRDQuantity(string) - returns the no. of Reference Designator   */
    /*   components. It returns 1 if the RD is a single value else returns        */
   /*   the no. of RD components.This function has to be used when the           */
  /*  RD value is given.                                                        */
  /*****************************************************************************/
   function getRDQuantity(string)
   {
       var str1=string;
       var tot=0;
       if((str1.indexOf(",") !=-1) && (str1.indexOf("-") != -1))
       {
          hyp = str1.split(",");
          for(var i=0,diff=0,delimct=0;i<hyp.length;i++)
          {
            st=hyp[i];
            
            if(st.indexOf("-")!=-1)
            {
               ctr= (st.indexOf("-"));
               num1=st.substring(0,st.indexOf("-"));
               num2=st.substring(st.indexOf("-")+1);
               diff= sumRDRange(num1,num2);
               tot=tot+diff;
             }
             else 
             {
               delimct++;
             }
        }
       
      	return (tot+delimct);
      
      }
      else if(str1.indexOf(",")!=-1)
      { 
           ctr=str1.split(",");
           return ctr.length;
      }
      else if(str1.indexOf("-")!=-1)
      {
           num1=str1.substring(0,str1.indexOf("-"));
           num2=str1.substring(str1.indexOf("-")+1);
           diff1=sumRDRange(num1,num2);
           return diff1;
      }
      else
      {
           return 1;
      }
	return ;
   }
  
  
  
     /********************************************************************* / 
    /* function sumRDRange(num1,num2) - returns the no. of Reference      */
    /*  Designator components in a range . It returns the range of the RD*/
   /*********************************************************************/
  function sumRDRange(num1,num2)
  {
      
     var txt1=num1.match(/[0-9]*$/g);
     var txt2=num2.match(/[0-9]*$/g);
     arr1=txt1.toString().split(",");
     arr2=txt2.toString().split(",");
     diff=parseInt(arr2[0]) -parseInt(arr1[0]);
     return ++diff;
  }
  
  
    /********************************************************************************* / 
    /* function isRDAlphaNumeric(string) - returns the valid format of alphaNumeric  */
   /* value of Reference Designator  . It returns true if it is valid else false    */
   /********************************************************************************/
  function isRDAlphaNumeric(string)
  {
      var format=string.match(/^[a-zA-Z]+[0-9]+$/g);
  
      if(format)
      {
        return true;
      }
      else
      {
        return false;
      }
  
      return;
  }
  
  
      /****************************************************************************** / 
     /* function isRDFormatCorrect(str)(stralpha) - returns the well formed value of*/
    /* Reference Designator. The format depends on the forma rules .               */
   /*  It returns true if well formed else returns false.                         */
  /*******************************************************************************/
  
  function isRDFormatCorrect(stralpha)
  {
   
      var string= stralpha;
      var check = new Array();
      var delim=false;
      var merge=true;
      finalstr=string;
  
    if((string.lastIndexOf(RANGE_SEPARATOR)==(string.length-1)) || (string.indexOf(RANGE_SEPARATOR)==0))
    {
         alert(INVALID_FORMAT_MSG);
         return false;
    
    }
    else if((string.indexOf(RANGE_SEPARATOR)==string.lastIndexOf(RANGE_SEPARATOR)) && string.indexOf(SINGLE_SEPARATOR)<=-1)
    { 
       range=string.split(RANGE_SEPARATOR);
       
       if(range.length<=2)
       {
           string=range.join();
       }
    }
   
    check=string.split(SINGLE_SEPARATOR);
    
   for(var i=0;i < check.length;i++)
   {
     var str=check[i].toString();
   
     if ((str.lastIndexOf(RANGE_SEPARATOR)) > (str.indexOf(RANGE_SEPARATOR)))
     {
       alert(SINGLE_RANGE_MSG);
       return false;
     }
   }
  
     
  if((string.indexOf(SINGLE_SEPARATOR)> 0) && (string.lastIndexOf(SINGLE_SEPARATOR)!=(string.length-1)))
  {
    var hyphenval=new Array()
    for(var j=0;j < check.length;j++)
    {
        st=check[j].toString();
        if (st.indexOf(RANGE_SEPARATOR) > -1) 
        {
            var temp=st.split(RANGE_SEPARATOR);
            hyphenval.push(temp[0])
            hyphenval.push(temp[1])
          }
        else
        {
            hyphenval.push(st);
        }
    }

        if(hyphenval.length > 1)
        {
             prevstr = hyphenval[0].match(/^[a-zA-Z]*/g);
             for(var k=0;k<hyphenval.length;k++)
             {
                newstr = hyphenval[k].match(/^[a-zA-Z]*/g);
                if(prevstr.toString()==newstr.toString())
                 {
                      delim=true;
                      continue ;
                 }
                 else
                 {
                     alert(MULTI_PREFIX_MSG);
                     delim=false;
                     return false; 
                 }
             } // for 
        } //if 
      } // if string.indexOf

      if (delim)
      {
          for(i=0;i<hyphenval.length;i++)
          {
             var str=hyphenval[i];
             bol=isRDAlphaNumeric(str);
             if (!bol)
                 {
                    break; 
                  }
             else 
                 {
                    qty=1;
                 }
              } //for
          }
          else
          {
              qty=0;
              bol=isRDAlphaNumeric(string);
          }

          if(!bol)
          {
                  alert(INVALID_CHAR_MSG);
                  return false;
          }

          return true;
  }// end of function
  
  
  /****************************************************************/ 
  /* function flattenRD(strarr) - returns the RD string flattened */
  /* Reference Designator. The format depends on the format rules */
  /*  It returns the string with each RD vale.                    */
  /****************************************************************/

function flattenRD(strarr)
{
    var arr = strarr;
    var longstr="";
    var dbval;    
    for(i=0;i < arr.length;i++)
    { 
           var newarr=new Array();
           newstr=arr[i];
           if(newstr.indexOf(RANGE_SEPARATOR) != -1) 
           {
                 var st=arr[i];
                str=st.split(RANGE_SEPARATOR);
                ctr=sumRDRange(str[0],str[1]);
                if(ctr > 0)
                {
                    var  val=str[0].toString().match(/[0-9]*$/g);
                    var alpha=str[0].toString().match(/^[a-zA-Z]*/g);
                    num = val.toString().substring(0,val.toString().indexOf(SINGLE_SEPARATOR));
                    st=arr[i];
                   for(var k=0,m=i+1;ctr > 1;k++,ctr--,m++)
                   {
                         st1=st.substring(0,st.indexOf(RANGE_SEPARATOR));
                         if(k==0)
                         {
                              n = parseInt(num)+1;
                            }
                        else
                        {
                              n++;
                        }
                newarr[k]=alpha + n.toString();
                 }  //end of for
             longstr=longstr + "," + str[0] + "," + newarr.join();
             arr[i]=st1;
           }
        }
        else
        {
             if (i==0)
             {
                 longstr=newstr;
             }
             else
             {
                longstr = longstr + "," + newstr ;
             }
           }
        } // end of for
        return longstr;
  }


   /****************************************************************/ 
   /* function isRDUnique(refarray,strval) returns true if         */
   /* Reference Designator. is unique                              */
   /*  It returns false if teh RD is not unique                    */
   /****************************************************************/
  
  function isRDUnique(refarray,strval)
  {
  
     refstr=strval.split(SINGLE_SEPARATOR);
     refval=refarray.split(SINGLE_SEPARATOR);
       
     var strflat = "";
     if(!checkUnique(refstr))
     {
         return false;
     }
     else
     {
          var strarr = flattenRD(refval);
  
          if(strarr.indexOf(SINGLE_SEPARATOR)==0)
          {
             strarr=strarr.substring(1);
          }
  
          var refarr = strarr.split(SINGLE_SEPARATOR);
          var strflat = flattenRD(refstr);
          strcheck = strflat.split(",");
          
          for (i=0;i < strcheck.length;i++)
          {
              if (strcheck[i].toString().length!=0)
              {
                for(j=0 ; j < refarr.length; j++)
                {
                    if (strcheck[i].toString()==refarr[j].toString())
                    {
                        return false;
                    }
                }
              }
          }
  
      }
      return true;
  }
  
   /**********************************************************************/ 
   /* function checkUnique() - returns true if the Rd value is unique    */
   /*  Used by the checkRefUnique() method for validating the rd value   */
   /*  This function have to be used when the property of unique         */
   /*  is set to true for a Part.                                        */
  /***********************************************************************/
  function checkUnique(refvalue) 
  {
	var uniqueRDO = true;
    var longstr = flattenRD(refvalue);    
    var finalarr = longstr.split(",");
    finalarr.sort();    
    var iLength = finalarr.length - 1;
    
    for (i = 0; i < iLength; i++) {
        if (finalarr[i].toString() == finalarr[i + 1].toString()) {
            alert(NOT_UNIQUE_MSG);
            uniqueRDO = false;
            break;
        }
    }
      
    return uniqueRDO;
}


    var fnLength               = "<%=fnLength%>";
    var rdLength               = "<%=rdLength%>";
    var ebomUniquenessOperator = "<%=ebomUniquenessOperator%>";
    var fnUniqueness           = "<%=fnUniqueness%>";
    var rdUniqueness           = "<%=rdUniqueness%>";
    var fnDisplayLeadingZeros  = "<%=fnDisplayLeadingZeros%>";
    
/**********************************************************************************/
/* function validateFNRD - validates the Find number and Reference Designator     */
/* for empty,length,RD Format and returns false if any value violates             */
/*                                                                                */ 
/**********************************************************************************/
   
function validateFNRD(fnObj,rdObj,fnRequired,rdRequired,i,totcount)
{
    var findNumberValue = trim(fnObj.value);
    var rdvalue 	    = rdObj.value;
    if(fnRequired=="true" && fnUniqueness=="true" && rdRequired=="true" && rdUniqueness=="true")
    {  
        if(ebomUniquenessOperator=="and" || ebomUniquenessOperator=="AND")
        {
             if(isEmpty(findNumberValue))
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                fnObj.focus();
                return false;
            }
            if(isEmpty(rdvalue))
           {
               alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
               rdObj.focus();
               return false;
            }
            if (!isRDFormatCorrect(rdvalue))
           {
               rdObj.focus();
               return false;
            }
        }
            if(ebomUniquenessOperator=="or" || ebomUniquenessOperator=="OR")
            {
            	var num = "0123456789";
            	for(var i=0;i<findNumberValue.length;i++)
            	{
            		if(num.indexOf(findNumberValue.charAt(i))==-1)
            		{
            		  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotValid</emxUtil:i18nScript>");
            		  fnObj.focus();
            		  return false;
            		}
            	}
            	
                if(isEmpty(findNumberValue) && isEmpty(rdvalue))
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNAndRDfieldemptypleaseenterAnyOne</emxUtil:i18nScript>");
                     fnObj.focus();
                     return false;
                }
                if(!isEmpty(rdvalue))
                {
                    if(!isRDFormatCorrect(rdvalue))
                    {
                       rdObj.focus();
                       return false; 
                    }
                }
            }
        }
        else
        {
        ///when any of the fn and rd values are false it will not enter the above condition
        ///below code handles such condition for fn required.
            if(fnRequired!="false")
            {
                if(isEmpty(findNumberValue))
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                    fnObj.focus();
                    return false;
                }
            }
            if(rdRequired!="false")
            {
                if(isEmpty(rdvalue))
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                    rdObj.focus();
                    return false;
                }
			}
               if(rdvalue!="")
                {
                    if(!isRDFormatCorrect(rdvalue))
                    {
                        rdObj.focus();
                        return false;
                    }
                }
            }
            if(chkLength(fnLength,findNumberValue))
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldLengthExceedsMaxLimit</emxUtil:i18nScript>"+fnLength);
                fnObj.focus();
                return false;
            }
            if(chkLength(rdLength,rdvalue))
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.Length </emxUtil:i18nScript>"+rdLength);
                rdObj.focus();
                return false;
            }
    return true;
}
/**********************************************************************************/
/* function checkRefUnique - checks whether the Reference Designator is           */
/* unique or not                                                                  */
/*                                                                                */ 
/**********************************************************************************/
function checkRefUnique()
{
    var elementsSize =document.editForm.selCount.value;
    var refArray=new Array();
     for(var i = 0; i < elementsSize; i++)
     {
    	 //XSSOK
       var rdobj= document.editForm.elements["<%=DomainObject.ATTRIBUTE_REFERENCE_DESIGNATOR%>"+i];
          if(rdobj!=null)
            {
               refArray[i]=rdobj.value;
           }
     }
  var unique = checkUnique(refArray);

  return unique;
}

 /************************************************************************************/   
 /* function getNonUniqueFNFromSelected() - returns a concatenated string containing */
 /* comma seperated values of TNR. This function checks the selected form values     */
 /* with the Array containing database values to validate uniqueness              */
 /* on client side.         */
  /***********************************************************************************/   

function getNonUniqueFNFromSelected(totcount)
{
    var nonUniqueFNs="";
    var k=0;
    for(var i=0; i<totcount;i++)
    {
        var checkObj = eval("document.editForm.selId" + i);
        var chkStatus = eval("document.editForm.selId" + i +".checked");
        if(chkStatus)
        {
            var fnobj = eval("document.editForm.elements[\"FindNumber"+i+"\"]");
            if (fnobj.value.length!=0)
            {
                for(var j=0;j<fnArray.length;j++)
                    {
                        if(fnArray[j]==fnobj.value)
                        {
                            if(nonUniqueFNs.length>0)
                            {
                                nonUniqueFNs=nonUniqueFNs+","+TNRArray[i];
                                k=i;
                            }
                            else
                            {
                                nonUniqueFNs=nonUniqueFNs+TNRArray[i];
                                k=i;
                            }
                        }
                    }
            }
        }
    }
    nonUniqueFNs = nonUniqueFNs+"~"+k;
    return nonUniqueFNs;
}


</script>
