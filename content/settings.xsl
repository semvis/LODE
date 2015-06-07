<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0"
    xmlns:f="http://www.essepuntato.it/xslt/function"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#">
   

<xsl:variable name="forum-url-prefix" as="xs:string+" select="'http://141.76.68.42/question2answer/index.php?qa=discuss&amp;'" />	
<!--<xsl:variable name="server-url-prefix" as="xs:string+" select="'http://141.76.68.42:8080/lode/extract?url='" />-->
<xsl:variable name="server-url-prefix" as="xs:string+" select="'http://localhost:8080/lode/extract?url='" />
<xsl:variable name="source-location-hardcoded" as="xs:string+" select="'http://localhost:8080/lode/source'" />
<xsl:variable name="static-files-location" select="''" as="xs:string" />

</xsl:stylesheet>