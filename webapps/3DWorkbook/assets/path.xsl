<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
  <xsl:output method="html" encoding="utf-8"/>    


<xsl:template match="NodeList" >
	<table >
<xsl:for-each select="Occurrence" >
	<xsl:variable name="idpath" select="Path"/>
  <tr>
    
    <xsl:attribute name="id"><xsl:value-of select="substring-after($idpath, '#')"/></xsl:attribute>
	<xsl:attribute name="name"><xsl:value-of select="Name" /></xsl:attribute>
      <td>
        &#160; <xsl:value-of select="Name" />
      </td>
    </tr>
</xsl:for-each>
     </table>
</xsl:template >
</xsl:stylesheet >
