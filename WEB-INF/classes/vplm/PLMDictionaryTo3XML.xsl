<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:metadata="PLMDictionaryCusto">
<xsl:output indent="yes" encoding="utf-8"/>
<xsl:template match="/">

	<xsl:variable name="ModelerName" select='metadata:Package/attribute::UseNames' />
	<xsl:variable name="CustoName" select='metadata:Package/attribute::Name' />
	
	<xs:schema attributeFormDefault="unqualified" version="1.0" targetNamespace="http://www.3ds.com/xsd/3DXML/{$ModelerName}/{$CustoName}"  xmlns:xs3d="http://www.3ds.com/xsd/3DXML" xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
	  
	  <!-- This dummy attribute is a trick to dynamically generate  the xmlns:tns="{$variable}"    ({$variable} is not interpreted for the xmlns attribute) -->
	  <xsl:attribute name="tns:dummy" namespace="http://www.3ds.com/xsd/3DXML/{$ModelerName}/{$CustoName}" />

	  <xs:import schemaLocation="3DXML.xsd" namespace="http://www.3ds.com/xsd/3DXML"/>
	  
	  <!-- For each Package that has at least one 3DXML Attribute, we define a Complex Type for the resutling XSD -->
	  <xsl:for-each select="metadata:Package/metadata:Class[@CAAExposition='L1']">
	  
	      <xs:complexType name="{attribute::Name}">
		    <xs:complexContent>
			
			  <!-- We extend the  XSD Type of the Syper Type of the Custo-->
		      <xs:extension base="xs3d:{attribute::SuperName}Type">
		        <xs:sequence>
				
				  <!-- For each Simple with CAAExposition='L1' we define a new element -->
				  <xsl:for-each select="metadata:Simple[@CAAExposition='L1']">
					<xs:element type="xs:{translate(attribute::Type,'ABCDEFGHIJKLNMOPQRSTUVWXYZ','abcdefghijklnmopqrstuvwxyz')}" name="{attribute::Name}" minOccurs="0"/>
		          </xsl:for-each>
				  
		        </xs:sequence>
		      </xs:extension>
		    </xs:complexContent>
		  </xs:complexType>
		
	
	 </xsl:for-each>
	 
	 </xs:schema>

</xsl:template>
</xsl:stylesheet>
