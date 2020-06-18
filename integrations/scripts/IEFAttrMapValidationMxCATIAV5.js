/*  IEFAttrMapValidationMxCATIAV5.js

   Copyright Dassault Systemes, 2012. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
*/

// Global data
// Prefix supported
var gAllPrefix = ["sys","cus","param","text","table","2DComponent"];

// Generic system attributes
var gAttrGenSystem = ["Part Number","Revision","Definition","Nomenclature","Source","Description","Material"];

// Specific system attributes
var gAttrSpeSystem = [
    "Density",
    "Mass",
    "Centerofgravity",
    "Inertiamatrix",
    "Volume",
    "Surfacearea",
    "Boundingbox",
    "Version"
    ];

// Types that support Specific system attributes    
var gTypeSpeSystem = [
    "component",
    "shape",
    "assembly",
    "embeddedComponent"
];

// Types that support attribute mappings    
var gValidTypeForAttrMap = [
    "component",
    "shape",
    "assembly",
    "embeddedComponent",
    "drawing",
    "catalog",
    "process",
    "analysis",
    "material",
    "3dxml",
    "analysisComputations",
    "analysisResults",
    "cgr",
    "designTable",
    "v4model",
    "iges",
    "vrml",
    "multiCADinvasm",
    "multiCADinvprt",
    "multiCADsldasm",
    "multiCADsldprt",
    "multiCADsleasm",
    "multiCADsleprt",
    "multiCADslepsm",
    "multiCADstep"
    ];
    
//Mapping direction
var gE2C = "ENOVIAToCAD";
var gC2E = "CADToENOVIA";

// IR-174848V6R2013x & IR-175994V6R2013x Correction
// Following two arrays are synchronus
var gKeyWords = ["create"];
var gMappingDirections = [gE2C];

//Error Messages
var gErrorGeneric   = "false|IEF0341130340";
var gNoFailure      = "true|0";
var gError          = "true|0";
var separator       = "~";
//------------------------------------------------------------------------
// Method validateCADAttrData(cadType,cadAttribute, enoviaType,enoviaAttribute, mappingDirection)
// This function validates data entered by user in CAD Attribute text box.
//
// Parameters:
//   cadType          : CAD type to be mapped 
//   cadAttribute     : CAD attribute for the above cadType
//   enoviaType       : ENOVIA type to be mapped
//   enoviaAttribute  : ENOVIA Attribute for the enoviaType 
//   mappingDirection : ENOVIAToCAD or CADToENOVIA
// Returns:
//   $status|$errorcode,$param
//   Examples: 
//      ‘true|0’ 
//      'False| IEF0341100329,texte,sys:text:param'
//------------------------------------------------------------------------
function validateCADAttrData (cadType,cadAttribute, enoviaType,enoviaAttribute, mappingDirection) {
    // Validate Input parameters
    if  (mappingDirection != gE2C && mappingDirection != gC2E) 
        return gErrorGeneric + separator;
    
    // Validate cadAttribute syntax
    if (searchNonAuthorizedCharacter(cadAttribute))
      return "false|IEF0341100330" + separator;
    
    // Check whether Mapping is allowed selected Type
    var bAttrMappingAllowed = 0;     
    for (k=0;k<gValidTypeForAttrMap.length;k++)
    {        
       if (cadType == gValidTypeForAttrMap[k])
         bAttrMappingAllowed = 1;
    } 
              
    if (bAttrMappingAllowed == 0) {
         var sPrefix = getAttributePrefix (cadAttribute);
         gError = "false|IEF0341100334"+separator+sPrefix+separator+cadType;                 
         return gError + separator;
    }
     
    // Get & Validate the prefix 
    var sPrefix = getAttributePrefix (cadAttribute);
    if (sPrefix == "")
      return gErrorGeneric+separator;
    if (isPrefixValid (sPrefix,cadType) == false)
      return gError + separator;
      
    // Validate sys attributes
    if (sPrefix == "sys" && isAValidSystemAttribute (cadAttribute,mappingDirection,cadType) == false)
      return gError + separator;  

    //IR-174848V6R2013x & IR-175994V6R2013x Correction
    if (((sPrefix == "cus" || sPrefix == "param") &&
        isAValidKeyword(cadAttribute,mappingDirection)) == false)
      return gError + separator;

    return gNoFailure + separator;
      
}

//------------------------------------------------------------------------
// Method searchNonAuthorizedCharacter (cString)
// This function checks the string contains invalid characters
//
// Parameters:
//   cString      : Input String (= CAD Attribute)
//
// Returns:
//   true         : OK
//   false        : KO
//------------------------------------------------------------------------
function searchNonAuthorizedCharacter (cString) {
    if (cString.search("\\|") != -1 || cString.search(",") != -1) 
      return true;
    else 
     return false;
}

//------------------------------------------------------------------------
// IR-174848V6R2013x & IR-175994V6R2013x Correction
// Method isAValidKeyword (cFullName,cDirection)
// This function checks the key word validity and mapping direction
//
// Parameters:
//   cName        : CAD attribute (supported syntax is Prefix:Name:detail)
//   cDirection   : ENOVIAToCAD

// Returns:
//   true         : OK
//   false        : KO
//------------------------------------------------------------------------
function isAValidKeyword(cFullName,cDirection) 
{
    var iPos1 = cFullName.search(":");
    var cInfo = "";
    
    if (iPos1  > -1)
       cInfo = cFullName.substring(iPos1 + 1, cFullName.length);
       
    var iPos2 = cInfo.search(":");
    var strKeyWord = "";
    var cName = cFullName.substring(iPos1 + 1, cFullName.length);
    
    if (iPos2 > -1)
    {
        strKeyWord = cInfo.substring(0, iPos2);
        var validKeyWord = 0;
        var pos = -1;
        for (i = 0; i < gKeyWords.length ; i++)
        {        
            if (strKeyWord == gKeyWords[i])
            {
                validKeyWord = 1;
                pos = i;
                break;
                
            }
        }
        
        if (validKeyWord == 0)
        {
            gError = "false|IEF0341100329"+separator+strKeyWord+separator+gKeyWords.join(",");
            return false;
        }
        else if (pos > -1 && cDirection != gMappingDirections[pos])
        {
            // Attribute found, direction KO 
            gError = "false|IEF0341130361 "+ separator + strKeyWord;
            return false;
        }
    }
    
    return true;
}

//------------------------------------------------------------------------
// Method isAValidSystemAttribute (cName,cDirection,cType)
// This function checks the system attribute is valid 
//   - Attribute name valid
//   - Attribute valid for the given direction
//   - Attribute valid for the given CAD type
//
// Parameters:
//   cName        : CAD attribute (supported syntax is Prefix:Name;detail)
//   cDirection   : ENOVIAToCAD or CADToENOVIA
//   cType        : CAD Type
//
// Returns:
//   true         : It's a valid system attribute
//   false        : It's an invalid  system attribute
//                  set the global error string  gError
//------------------------------------------------------------------------
function isAValidSystemAttribute (cFullName,cDirection,cType) 
{     
    var cBodyMain = "body=main";      
    var cBodyAll  = "body=all";
    
    var iPos1 = cFullName.search(":");
    var iPos2 = cFullName.search(";");
    var cInfo = "";
    if (iPos2 == -1) 
       iPos2 = cFullName.length;
    else
       cInfo = cFullName.substring(iPos2+1,cFullName.length); 
       
    var cName = cFullName.substring(iPos1+1,iPos2);    
    
    for (i=0;i<gAttrGenSystem.length;i++)
    {
      if (cName == gAttrGenSystem[i])
      {
        if (cInfo == "")
         return true;   // Generic system attr valid for both dir and all types
        else
        {
           gError = "false|IEF0341100335" + separator + "sys:" + cName;
           return false;  // Attribute found, direction KO
        }        
      }
    }
    
    for (i=0;i<gAttrSpeSystem.length;i++)
    {
      if (cName == gAttrSpeSystem[i]) {
        if (cDirection == gE2C ) {
           gError = "false|IEF0341100333" + separator + cName + separator + gE2C;
           return false;  // Attribute found, direction KO
         }
        for (j=0;j<gTypeSpeSystem.length;j++)
        {
           if (cType == gTypeSpeSystem[j]) {
            if (cInfo == "" || cInfo == cBodyAll || cInfo == cBodyMain)
               return true;
            else {
              gError = "false|IEF0341100335"+separator+"sys:"+cName+";"+cBodyMain;
              return false;  // Attribute found, direction KO
            }
           }
        } 
        // Attribute found, direction OK, but type NA
        gError = "false|IEF0341100331"+separator+cName+separator+ gC2E; //+cType;
        for (j=0;j<gTypeSpeSystem.length;j++)
        {
           gError = gError+","+gTypeSpeSystem[j];         
        } 
        gError = gError + separator;
        return false;         
      }        
    }
    
    // cName not recognized as a system attribute
    gError = "false|IEF0341100332"+separator+cName;
    return false;
}

//------------------------------------------------------------------------
// Method getAttributePrefix (cFullName)
// This function returns the attribute prefix 
//
// Parameters:
//   cFullName        : CAD attribute (supported syntas is Prefix:Name)
//
// Returns:
//   prefix 
//------------------------------------------------------------------------

function getAttributePrefix (cFullName)
{
   var iPos = cFullName.search(":");
   if (iPos == -1)
      return "";
   else
    return cFullName.substring(0,iPos);
}

//------------------------------------------------------------------------
// Method isPrefixValid (cPrefix)
// This function check:
//   1. the prefix  is a valid one
//   2. the prefix is supported by the CAD type
//
// Parameters:
//   cPrefix        : CAD attribute prefix
//   cCADType       : CAD Type
//
// Returns:
//   true           : Prefix valid
//   false          : Prefix invalid and gError updated
//                    IEF0341100329 : prefix unknown 
//                    IEF0341100334 : prefix not supported for the given type
//    
//------------------------------------------------------------------------

function isPrefixValid (cPrefix,cCADType)
{
    for (i=0;i<gAllPrefix.length;i++)
    {
      if (cPrefix == gAllPrefix[i])      // known prefix
      {
        if (cPrefix == "table" || cPrefix == "text" ||cPrefix == "2DComponent")
        {
          if (cCADType.search("drawing") == 0)
             return true;
          else
          {
            gError = "false|IEF0341100334"+separator+cPrefix+separator+cCADType;
            return false;
          }       
        }
        else if (cPrefix == "cus" && cCADType.search("assembly") == -1 &&
                 cCADType.search("component") == -1 &&
                 cCADType.search("embeddedComponent") == -1)
        {
            gError = "false|IEF0341100334"+separator+cPrefix+separator+cCADType;
            return false;
        }
        else
          return true;
      }
    }
    gError = "false|IEF0341100329"+separator+cPrefix+separator+gAllPrefix.join(",");
    return false;
}
