<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes" />

  <xsl:template match="CompositeDocument">
<html>
<head>
  <title><xsl:value-of select="Parameters/Parameter[@name='header']" /></title>

  <style type="text/css">
ul {
  margin-bottom: 5;
  list-style: none;
  margin-left: 25px;
  padding-left: 0px;
}
li {
  margin: 5 5 5 0;
}
li h3 {
  margin: 0;
  /* margin-bottom: 5; */
  padding: 5 10;
  border: inherit;
  border-style: outset;
}
table {
  margin-left: 10;
  margin-right: 10;
}
table td {
  padding-left: 10;
  padding-right: 10;
}

.function, .RFLPLMFunctionalReferenceDS, .RFLPLMFunctionalReferenceCusto1, .RFLPLMFunctionalInstanceDS {
  background-color: #CFCFFF;
  border: thin solid blue;
}
.logical, .RFLVPMLogicalReferenceDS, .RFLVPMLogicalReferenceCusto1, .RFLVPMLogicalInstanceDS{
  background-color: #FFCFFF;
  border: thin solid purple;
}
.physical, .PLMProductDS{
  background-color: #728FCE;
  border: thin solid blue;
}
.Chapter, .flow, .type, .RFLPLMFlowReferenceDS, .RFLPLMFlowReferenceCusto1, .RFLPLMFlowInstanceDS, .RFLVPMSystemTypeReferenceDS, .RFLVPMSystemTypeInstanceDS {
  background-color: #CFCFCF;
  border: thin solid gray;
}
.Comment, .port, .RFLPLMFunctionalConnectorDS, .RFLPLMFunctionalConnectorCusto1, .RFLVPMLogicalPortDS  {
  background-color: #FFFFCF;
  border: thin solid gold;
}
.Requirement {
  background-color: #CFFFCF;
  border: thin solid green;
}
.Specification, .representation {
  background-color: #FFFFFF;
  border: thin solid gray;
}
.PlmParameter {
  background-color: #3399FF;
  border: thin solid green;
}
.communication{
  background-color: #DEB887;
  border: thin solid chocolate;
}

.connection{
  background-color: #90EE90;
  border: thin solid DarkSeaGreen;
}

.content {
  background-color: white;
  border: thin inset #CFCFCF;
  margin: 0;
  padding: 0;
  width: 600;
  overflow: scroll;
}

.content h6 {
  margin: 0;
}
.content pre {
  margin: 10;
}

.relationship{
  margin: 10;
}

a.clpbox, a.expbox{
	width: 12px; height: 12px;
	/* margin-left:3px; margin-top:2px; */
	overflow:hidden;
	float: left;
}
a.clpbox{
	background-image:url("images/buttonRTESectionCollapse.gif");
	background-position: 0px 0px;
}
a.expbox{
	background-image:url("images/buttonRTESectionExpand.gif");
	background-position: 0px 0px;
}
  </style>
  <script src="CompositeDocument.js" type="text/javascript"> 
  </script>
</head>
      
<body>
  <h2><xsl:value-of select="Parameters/Parameter[@name='header']" /></h2>
  <xsl:apply-templates select="StructureData/ObjectReference" />
  <script type="text/javascript">
  	//JX5 start IR-375534-V6R2013x
  	onLoadXMLReport(); 
  	//JX5 end IR-375534-V6R2013x
  </script>
</body>
</html>
  </xsl:template>


  <xsl:template match="ObjectReference">
    <xsl:variable name="id" select="@id" />

    <ul >
      <li class="{@type} {@category}" id="{@id}" title="{@name}">
	      <xsl:apply-templates select="/CompositeDocument/InstanceData/ObjectInstance[@id=$id][1]" />
	      <xsl:apply-templates select="Relationship[@type='Derived Requirement' or @type='Sub Requirement' or @type='ParameterUsage']" />
	      <xsl:apply-templates select="Relationship[@type!='Derived Requirement' and @type!='Sub Requirement' and @type!='ParameterUsage']" />
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="Relationship">
  		<xsl:apply-templates select="ObjectReference" />
  </xsl:template>
  <xsl:template match="Relationship[@type='Derived Requirement' or @type='Sub Requirement' or @type='ParameterUsage']">
  		<hr/>
  		<div class="relationship">
  		<b> Relationship Type</b>: <xsl:value-of select="@type" /> <br/>
		<xsl:if test="@type!='ParameterUsage'">
			<b> Status</b>: <xsl:value-of select="@status" /> 
		</xsl:if>
  		</div>
  		<xsl:apply-templates select="ObjectReference" />
  		
  </xsl:template>
  <xsl:template match="ObjectInstance">
        <h3><a class="clpbox" href="#" onclick="flipNode(event); return false;"></a><xsl:value-of select="@alias" /></h3>
        <table>
          <xsl:apply-templates select="Attribute[@name!='Content Type' and @name!='Content Text' and @name!='Content Data']" />
          <xsl:apply-templates select="Attribute[@name='Content Text']" />
	    </table>
  </xsl:template>

  <xsl:template match="Attribute">
    <tr>
      <th width="30%" align="right"><xsl:value-of select="@name" /></th>
      <td><xsl:value-of select="text()" /></td>
	</tr>
  </xsl:template>

  <xsl:template match="Attribute[@name='Content Text']">
    <tr>
      <td colspan="2">
        <div class="content"><h6>Content:</h6>
          <pre><xsl:value-of select="." /></pre>
	    </div>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
