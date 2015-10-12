<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#x00A0;">
  <!ENTITY middot "&#183;">
  <!ENTITY laquo "&#171;">
  <!ENTITY raquo "&#187;">
  <!ENTITY bull "&#8226;">
]>
<!--
Copyright (c) 2011, Silvio Peroni <essepuntato@gmail.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd dc rdfs swrl owl2xml owl xsd swrlb rdf f dct"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:swrl="http://www.w3.org/2003/11/swrl#"
    xmlns:owl2xml="http://www.w3.org/2006/12/owl2-xml#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
                

   	xmlns:bixt="http://purl.org/viso/bibo-extension/"
   	xmlns:bibo="http://purl.org/ontology/bibo/"
   	xmlns:foaf="http://xmlns.com/foaf/spec/"
   	xmlns:swstatus="http://www.w3.org/2003/06/sw-vocab-status/ns#"
                
  	xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  	xmlns:swrlb="http://www.w3.org/2003/11/swrlb#"
  	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  	xmlns:f="http://www.essepuntato.it/xslt/function"
  	xmlns:dct="http://purl.org/dc/terms/"
  	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
 	xmlns="http://www.w3.org/1999/xhtml">

  	<xsl:include href="swrl-module.xsl" />
    <xsl:include href="common-functions.xsl"/>
   	<!-- added by Jan: Distinguish remote and local settings by multiple settings-files: -->
	<xsl:include href="settings.xsl"/>
    
    <xsl:output encoding="UTF-8" indent="yes" method="xhtml" />
    
    <xsl:param name="lang" select="'en'" as="xs:string" />
    <!-- next line changed by Jan: Hack! The source location passed by the servlet contained the wrong host when used for generating static files (localhost). Now set in the settings.xsl: -->
    <xsl:variable name="source" as="xs:string" select="$source-location-hardcoded" />
    <xsl:param name="ontology-url" as="xs:string" select="''" />
	<xsl:param name="lode-parameters" as="xs:string+" select="'&amp;closure=true'" />
	<!-- added by Jan: Allow for displaying only the stable resources, or all -->
	<xsl:param name="ignore-stable" select="false()" as="xs:boolean" />
	<!-- added by Jan: Allow for displaying only the resources that have a uri starting like the ontology-url (this is usually not the case for imports)  -->
	<xsl:param name="render-imports" select="false()" as="xs:boolean" />
	
    
    <xsl:variable name="def-lang" select="'en'" as="xs:string" />
    <xsl:variable name="n" select="'\n|\r|\r\n'" />
    <xsl:variable name="rdf" select="/rdf:RDF" as="element()" />
    <xsl:variable name="root" select="/" as="node()" />
    
    <xsl:variable name="default-labels" select="document(concat($def-lang,'.xml'))" />
    <xsl:variable name="labels" select="document(concat($lang,'.xml'))" />
    <xsl:variable name="possible-ontology-urls" select="($ontology-url,concat($ontology-url,'/'),concat($ontology-url,'#'))" as="xs:string+" />
    
    <xsl:template match="rdf:RDF">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <xsl:choose>
                <xsl:when test="owl:Ontology">
                    <xsl:apply-templates select="owl:Ontology" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="structure" />
                </xsl:otherwise>
            </xsl:choose>
        </html>
    </xsl:template>
    
    <xsl:template name="htmlhead">
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
        
    	<link href="{$static-files-location}owl.css" rel="stylesheet" type="text/css" />
	    <link href="{$static-files-location}Primer.css" rel="stylesheet" type="text/css" />
        <link href="{$static-files-location}rec.css" rel="stylesheet" type="text/css" />
        <link href="{$static-files-location}extra.css" rel="stylesheet" type="text/css" />
    	<link href="{$static-files-location}viso.lode.css" rel="stylesheet" type="text/css"/>
		<link rel="shortcut icon" href="{$static-files-location}favicon.ico" />
     	<link rel="icon" href="{$static-files-location}favicon.ico" sizes="16x16 24x24 32x32 48x48 64x64 110x110 114x114" type="image/vnd.microsoft.icon"/>
     	
     	<script src="{$static-files-location}jquery.js" type="text/javascript"><!-- Comment for compatibility --></script>
      	<script src="{$static-files-location}jquery.scrollTo.js" type="text/javascript"><!-- Comment for compatibility --></script>
        <script>
                $(document).ready(
                    function () {
                        var list = $('a[name="<xsl:value-of select="$ontology-url" />"]');
                        if (list.size() != 0) {
                        	var element = list.first();
                        	$.scrollTo(element);
                        }
                    });
        </script>
    </xsl:template>
    
    <xsl:template name="structure">
        <xsl:variable name="titles" select="dc:title|dct:title" as="element()*" />
        <head>
            <xsl:choose>
                <xsl:when test="$titles">
                    <xsl:apply-templates select="$titles" mode="head" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="rdfs:label" mode="head" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="head" />
            <xsl:call-template name="htmlhead" />
        </head>
        <body>
            <div class="head">
                <xsl:choose>
                    <xsl:when test="$titles">
                        <xsl:apply-templates select="$titles" mode="ontology" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="rdfs:label" mode="ontology" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="get.ontology.url" />
                <xsl:call-template name="get.version" />
                <xsl:call-template name="get.author" />
                <xsl:call-template name="get.imports" />	
                <!--dl>
                    <dt><xsl:value-of select="f:getDescriptionLabel('visualisation')" />:</dt>
                    <dd>
                        <a href="{$source}?url={$ontology-url}"><xsl:value-of select="f:getDescriptionLabel('ontologysource')" /></a>
                    </dd>
                    <dd>
                        <a href="http://owl.cs.manchester.ac.uk/browser/ontologies/?action=load&amp;clear=true&amp;uri={$ontology-url}" title="Open this ontology using the Machester Ontology Browser">
                            Machester Ontology Browser
                        </a>
                    </dd>
                </dl-->
                <dl>
                    <dt>Download / Source view:</dt>
                    <dd>
                        <!--<a title="Try right-clicking + save as .." href="{$source}?url={$ontology-url}"> Ontology source code</a>-->
                        <a title="Show the source code of the ontology ..." href="{$source}?url={$ontology-url}"> Ontology source code</a>
                    </dd>
                    <dd>
	                	<xsl:choose>
				            <xsl:when test="contains($ontology-url,'rvl')">
								<a href="http://github.com/semvis/rvl/wiki/Download" title="Download the RVL vocabulary from GitHub ...">
								    Download
               		 			</a>
               		 			<span id="forkongithub"><a href="https://github.com/semvis/rvl/">Fork me on GitHub</a></span>
				            </xsl:when>
				            <xsl:otherwise>
								<a href="http://github.com/viso-ontology/viso-ontology/wiki/Download" title="Download the VISO Ontologies from GitHub ...">
								    Download
               		 			</a>
               		 			<span id="forkongithub"><a href="https://github.com/viso-ontology/viso-ontology/">Fork me on GitHub</a></span>
				            </xsl:otherwise>
			        	</xsl:choose>
                    </dd>
                </dl>
                <br/>
                <xsl:choose>
		            <xsl:when test="contains($ontology-url,'rvl')">
		              	<!--More on RVL can be found in the 
		                <a href="https://github.com/semvis/rvl/wiki" title="The RVL-Wiki on GitHub ...">Wiki</a>.-->
		            </xsl:when>
		            <xsl:otherwise>
		        		More on <a href="http://purl.org/viso/" title="Open the main module of the Visualization Ontology (VISO) ...">
		                	http://purl.org/viso/</a> can be found in the   
		                <a href="https://github.com/viso-ontology/viso-ontology/wiki" title="The VISO-Wiki on GitHub ...">Wiki</a>.
		            </xsl:otherwise>
		        </xsl:choose>
                
                <xsl:apply-templates select="dc:rights|dct:rights" />
            </div>
            <hr />
            <!-- added by Jan -->
            <xsl:call-template name="get.stableinfo" />
            <xsl:call-template name="get.toc" />
            <xsl:apply-templates select="dct:description[normalize-space() != ''] , dct:description[@rdf:resource]" mode="ontology" />
             <!-- Editing start: Comment now after description -->
             <xsl:apply-templates select="rdfs:comment" mode="ontology" />
             <!--  Editing End -->
            <xsl:call-template name="get.classes" />
            <xsl:call-template name="get.objectproperties" />
            <xsl:call-template name="get.dataproperties" />
            <xsl:call-template name="get.namedindividuals" />
            <xsl:call-template name="get.annotationproperties" />
            <xsl:call-template name="get.generalaxioms" />
            <xsl:call-template name="get.swrlrules" />            
            <xsl:call-template name="get.namespacedeclarations" />
            
            <p class="endnote">
	  Work on this project received financial support from the European Union and the 
	  Free State of Saxony.<br/><img alt="Logo of the sponsors" src="{$static-files-location}sponsoren-logos.png"/></p>
            <p class="endnote"><xsl:value-of select="f:getDescriptionLabel('endnote')" /> <a href="http://lode.sourceforge.net"> LODE</a>, <em>Live OWL Documentation Environment</em>, <xsl:value-of select="f:getDescriptionLabel('developedby')" /> <a href="http://palindrom.es/phd/whoami/"> Silvio Peroni</a>.</p>
        </body>
    </xsl:template>
    
    <xsl:template match="owl:Ontology">
        <xsl:call-template name="structure" />
    </xsl:template>
    
    <!-- Editing start: changed DC to DCT here as everywhere else. 
    Additionally changed decsription to be displayed as the abstract, not the comment (Jan) -->
    
    <!-- Display the description on the ontology as the abstract -->
    <xsl:template match="dct:description[f:isInLanguage(.)][normalize-space() != '']" mode="ontology">
        <!--<h2 id="introduction"><xsl:value-of select="f:getDescriptionLabel('introduction')" /></h2>-->
        <h2><xsl:value-of select="f:getDescriptionLabel('abstract')" /></h2>
        <xsl:call-template name="get.content" />
    </xsl:template>
	
    <xsl:template match="dct:description[@rdf:resource]" mode="ontology">
        <p class="image">
            <object data="{@rdf:resource}" />
        </p>
    </xsl:template>
	
    <xsl:template match="dct:description[f:isInLanguage(.)][normalize-space() != '']">
        <div class="info">
            <xsl:call-template name="get.content" />
        </div>
    </xsl:template>
	
    <xsl:template match="dct:description[@rdf:resource]">
        <p class="image">
            <object data="{@rdf:resource}" />
        </p>
    </xsl:template>
	
	<!-- Display a comment on the ontology like any other comment -->
    <xsl:template match="rdfs:comment[f:isInLanguage(.)]" mode="ontology">
        <!--<h2><xsl:value-of select="f:getDescriptionLabel('abstract')" /></h2>
        <xsl:call-template name="get.content" />-->
        <div class="comment_ontology">
            <xsl:call-template name="get.content" />
        </div>
    </xsl:template>
    
    <!-- Editing end (Jan) -->
    
    <xsl:template match="rdfs:comment[f:isInLanguage(.)]">
        <div class="comment">
            <xsl:call-template name="get.content" />
        </div>
    </xsl:template>
    
    <!--  Editing start (Jan) -->
    <xsl:template match="skos:example[f:isInLanguage(.)]">
        <div class="example"><b>Example </b> 
            <xsl:call-template name="get.content" />
        </div>
    </xsl:template>
    <xsl:template match="skos:editorialNote[f:isInLanguage(.)]">
        <div class="editorialNote">
            <xsl:call-template name="get.content" />
        </div>
    </xsl:template>
    
    <xsl:template match="skos:related | rdfs:seeAlso">
         <xsl:apply-templates select="attribute() | element()" />
        	<xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
          </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.resource.related">
        <xsl:if test="exists(skos:related | rdfs:seeAlso)">
            <div class="related_see_also">Related / see also: 
                 <xsl:apply-templates select="skos:related | rdfs:seeAlso" />
			</div>
        </xsl:if>
    </xsl:template>
    
     <!-- <xsl:template name="get.resource.related.short">
        <xsl:variable name="about" select="@rdf:about|@rdf:ID" as="xs:string" />
        <xsl:variable name="related-terms" as="attribute()*" select="/rdf:RDF/owl:Class[some $res in rdfs:subClassOf/@rdf:resource satisfies $res = $about]/(@rdf:about|@rdf:ID)" />
        <xsl:if test="exists($sub-classes)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hassubclasses')" /></dt>
            <dd>
                <xsl:for-each select="$sub-classes">
                    <xsl:sort select="f:getLabel(.)" data-type="text" order="ascending" />
                    <xsl:apply-templates select="." />
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>
        </xsl:if>
    </xsl:template>
    
        <xsl:template match="skos:related">
    	<xsl:param name="list" select="true()" tunnel="yes" as="xs:boolean" />
            <xsl:apply-templates select="attribute() | element()" />
        	<xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
            </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.resource.related">
        <xsl:if test="exists(skos:related)">
            Related terms: <xsl:apply-templates select="skos:related" />
        </xsl:if>
    </xsl:template>
    
    -->
    
    

    
    
    <!--  Editing end (Jan) -->
    
    <xsl:template match="dc:rights|dct:rights[ancestor::owl:Ontology]">
        <div class="copyright">
            <xsl:call-template name="get.content" />
        </div>
    </xsl:template>
    
    <xsl:template match="dc:title[f:isInLanguage(.)] | dct:title[f:isInLanguage(.)]" mode="ontology">
        <h1>
            <xsl:call-template name="get.title" />
        </h1>
    </xsl:template>
    
    <xsl:template match="rdfs:label[f:isInLanguage(.)]" mode="ontology">
        <h1>
            <xsl:call-template name="get.title" />
        </h1>
    </xsl:template>
    
    <xsl:template match="owl:imports">
        <dd>
            <a href="{@rdf:resource}">
                <xsl:value-of select="@rdf:resource" />
            </a>
			<!-- Editing start (Jan) -->
			<!--<xsl:text> (</xsl:text>
            <a title="For performance reasons this docu is cached. This will show you the live-generated version of this module instead (may take up to one minute)."
            	 href="{$server-url-prefix}{@rdf:resource}{$lode-parameters}">live</a>)
            <xsl:text></xsl:text>-->
			<!-- Editing end (Jan) -->
        </dd>
    </xsl:template>
    
    <xsl:template match="dc:title[f:isInLanguage(.)]">
        <xsl:call-template name="get.title" />
    </xsl:template>
    
    <xsl:template match="dc:date|dct:date[ancestor::owl:Ontology]">
        <dt><xsl:value-of select="f:getDescriptionLabel('date')" />:</dt>
        <dd>
            <xsl:choose>
                <xsl:when test="matches(.,'\d\d\d\d-\d\d-\d\d')">
                    <xsl:variable name="tokens" select="tokenize(.,'-')" />
                    <xsl:value-of select="$tokens[3],$tokens[2],$tokens[1]" separator="/" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </dd>
    </xsl:template>
    
    <xsl:template match="owl:versionInfo">
        <dt><xsl:value-of select="f:getDescriptionLabel('currentversion')" />:</dt>
        <dd><xsl:apply-templates /></dd>
    </xsl:template>
    
    <xsl:template match="owl:priorVersion">
        <dt><xsl:value-of select="f:getDescriptionLabel('previousversion')" />:</dt>
        <dd>
            <xsl:choose>
                <xsl:when test="exists(@rdf:resource)">
                    <a href="{@rdf:resource}">
                        <xsl:value-of select="@rdf:resource" />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </dd>
    </xsl:template>
    
    <xsl:template match="dc:creator|dc:contributor|dct:creator[ancestor::owl:Ontology]|dct:contributor[ancestor::owl:Ontology]">
        <xsl:choose>
            <xsl:when test="@rdf:resource">
                <dd>
                    <a href="{@rdf:resource}">
                        <xsl:value-of select="@rdf:resource" />
                    </a>
                </dd>
            </xsl:when>
            <xsl:otherwise>
                <dd>
                    <xsl:apply-templates />
                </dd>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dc:title[f:isInLanguage(.)]|dct:title[f:isInLanguage(.)]" mode="head">
        <title><xsl:value-of select="tokenize(.//text(),$n)[1]" /></title>
    </xsl:template>
    
    <xsl:template match="rdfs:label[f:isInLanguage(.)]" mode="head">
        <title><xsl:value-of select="tokenize(.//text(),$n)[1]" /></title>
    </xsl:template>
    
    <xsl:template match="element()|text()" mode="head" />
    <xsl:template match="element()" mode="ontology" />
    <xsl:template match="element()|text()[normalize-space() = '']" />
    
    <xsl:template match="owl:Class">
    	<!--<xsl:choose>
    		<xsl:when test=""></xsl:when>
    	</xsl:choose>-->
        <div id="{generate-id()}" class="entity">
            <xsl:call-template name="get.entity.name">
            	<xsl:with-param name="toc" select="'classes'" tunnel="yes" as="xs:string" />
            	<xsl:with-param name="toc.string" select="f:getDescriptionLabel('classtoc')" tunnel="yes" as="xs:string" />
            </xsl:call-template>
            <xsl:call-template name="get.entity.metadata" />
			<!-- Edited Start (Jan): dct -->
            <xsl:apply-templates select="dct:description[normalize-space() != ''] , dct:description[@rdf:resource]" />
			<!-- Edited End (Jan: dct -->
			<xsl:apply-templates select="skos:example" />

	          <!-- Edited Start: annotations-->
			  <div class="citations">
	
		          <!--xsl:if test="exists(bixt:considersSource | bixt:followsSource | bixt:contradictsSource)">
	            <b>This concept was created, based on the following Quotations:</b>
		          </xsl:if-->
	          
	          <xsl:if test="exists(bixt:followsSource)">
		            <!-- dt>
	              <h3>following:</h3>
	            </dt>
		            <dd>-->
		              <ul class="quote_follows" title="The term was defined following this quotation">
	                <xsl:apply-templates select="bixt:followsSource" />
	              </ul>
		            <!--/dd-->
	          </xsl:if>
	          <xsl:if test="exists(bixt:contradictsSource)">
		            <!--dt>
	              <h3>contradicting:</h3>
	            </dt>
		            <dd>-->
		              <ul class="quote_contradicts" title="The term was defined in contradiction to this quotation">
		                <xsl:apply-templates select="bixt:contradictsSource" />
	              </ul>
		            <!--/dd-->
	          </xsl:if>
				  
			  <xsl:if test="exists(bixt:considersSource)">
		            <!--dt>
	              <h3>considering:</h3>
	            </dt>
		            <dd>-->
		              <ul class="quote_considers" title="The term was defined considering this quotation">
	                <xsl:apply-templates select="bixt:considersSource" />
	              </ul>
		            <!--/dd>-->
	          </xsl:if>
		  
          </div>

           <xsl:apply-templates select="rdfs:comment" />
           <xsl:apply-templates select="skos:editorialNote" />
           <xsl:call-template name="get.resource.related" />
           <xsl:call-template name="get.class.description" />
		   
           <!-- Edited End-->
		   
			<!-- Edited Start (Jan): discuss-button 
			<div style="height:2em">
            	<div class="discuss">
            		<a href="{$forum-url-prefix}q={@rdf:about|@rdf:ID}" target="_blank">
			    	discuss
		 			</a>
		 		</div>
		 	</div>
			 Edited End (Jan: discuss-button -->
			
			<!-- Edited Start (Fabi): discuss-button
			<div style="height:2em">
            	<div class="discuss">
            		<a>
					<xsl:attribute name="href">					
					<xsl:value-of select="$forum-url-prefix"/>
					<xsl:text>q=</xsl:text>
					<xsl:value-of select="@rdf:about|@rdf:ID"/>
					<xsl:text>&amp;title=</xsl:text>
					<xsl:value-of select="f:getLabel(@rdf:about|@rdf:ID)" />
					<xsl:text>&amp;descr=</xsl:text>
					<xsl:apply-templates select="dct:description[normalize-space() != ''] , dct:description[@rdf:resource]" />
					<xsl:text>&amp;tag=</xsl:text>
					<xsl:value-of select="f:getPrefixFromIRI(@rdf:about|@rdf:ID)"/>
					</xsl:attribute>
					<xsl:attribute name="target">					
					<xsl:text>_blank</xsl:text>
			    	</xsl:attribute>
					<xsl:text>discuss</xsl:text>
		 			</a>
		 		</div>
		 	</div>
			 Edited End (Fabi: discuss-button -->
			
			<!-- Edited Start (Jan): discuss-button GitHub wiki -->
			<!--<div style="height:2em">
            	<div class="discuss">
            		<a>
					<xsl:attribute name="href">					
					<xsl:text>https://github.com/viso-ontology/viso-ontology/wiki/</xsl:text>
					<xsl:value-of select="f:getLabel(@rdf:about|@rdf:ID)"/>
					</xsl:attribute>
					<xsl:attribute name="target">					
					<xsl:text>_blank</xsl:text>
			    	</xsl:attribute>
					<xsl:text>discuss</xsl:text>
		 			</a>
		 		</div>
		 	</div>-->
			<!-- Edited End (Fabi: discuss-button -->
			
        </div>
    </xsl:template>
  
  
  
    
    <xsl:template match="owl:NamedIndividual">
        <div id="{generate-id()}" class="entity">
            <xsl:call-template name="get.entity.name">
                <xsl:with-param name="toc" select="'namedindividuals'" tunnel="yes" as="xs:string" />
                <xsl:with-param name="toc.string" select="f:getDescriptionLabel('namedindividualtoc')" tunnel="yes" as="xs:string" />
            </xsl:call-template>
            <xsl:call-template name="get.entity.metadata" />
			<xsl:call-template name="get.individual.description" />
            <xsl:apply-templates select="dct:description[normalize-space() != ''] , dct:description[@rdf:resource]" />
			<xsl:apply-templates select="skos:example" />
            <xsl:apply-templates select="rdfs:comment" />
            <xsl:apply-templates select="skos:editorialNote" />
            <xsl:call-template name="get.resource.related" />
          
          <!-- Edited Start: including references to documents -->
          <!-- Edited Jan: seems to be forgotten code. Delete?
          <xsl:call-template name="get.documentReference" />
          -->
          <!-- Edited End-->
          
        </div>
    </xsl:template>
    
    <xsl:template match="owl:ObjectProperty | owl:DatatypeProperty | owl:AnnotationProperty">
        <div id="{generate-id()}" class="entity">
            <xsl:call-template name="get.entity.name">
                <xsl:with-param name="toc" select="if (self::owl:ObjectProperty) then 'objectproperties' else if (self::owl:AnnotationProperty) then 'annotationproperties' else 'dataproperties'" tunnel="yes" as="xs:string" />
                <xsl:with-param name="toc.string" select="if (self::owl:ObjectProperty) then f:getDescriptionLabel('objectpropertytoc') else if (self::owl:AnnotationProperty) then f:getDescriptionLabel('annotationpropertytoc') else f:getDescriptionLabel('datapropertytoc')" tunnel="yes" as="xs:string" />
            </xsl:call-template>
            <xsl:call-template name="get.entity.metadata" />
            <xsl:call-template name="get.property.description" />
            <xsl:apply-templates select="dct:description[normalize-space() != ''] , dct:description[@rdf:resource]" />
			<xsl:apply-templates select="skos:example" />
            <xsl:apply-templates select="rdfs:comment" />
            <xsl:apply-templates select="skos:editorialNote" />
            <xsl:call-template name="get.resource.related" />
        </div>
    </xsl:template>
    
    <xsl:template match="rdfs:range | rdfs:domain">
        <li>
            <xsl:apply-templates select="@rdf:resource | element()">
                <xsl:with-param name="type" select="'class'" as="xs:string" tunnel="yes" />
            </xsl:apply-templates>
        </li>
    </xsl:template>
    
    <xsl:template match="owl:propertyChainAxiom">
        <li>
            <xsl:for-each select="element()">
                <xsl:apply-templates select="." />
                <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                    <span class="logic">o</span>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </li>
    </xsl:template>
    
    <xsl:template match="owl:inverseOf[parent::owl:ObjectProperty|parent::owl:DatatypeProperty]">
        <li>
            <xsl:apply-templates select="@rdf:resource" />
        </li>
    </xsl:template>
    
    <xsl:template match="owl:inverseOf">
        <span class="logic">inverse</span>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="@rdf:resource" />
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="rdfs:label[f:isInLanguage(.)]">
        <h2 class="title">
            <xsl:apply-templates />
            <xsl:call-template name="get.entity.type.descriptor">
                <xsl:with-param name="iri" select="ancestor::element()/(@rdf:about|@rdf:ID)" />
            </xsl:call-template>
            <xsl:if test="exists(dc:title[f:isInLanguage(.)])">
                <br />
                <xsl:apply-templates select="dc:title" />
            </xsl:if>
            <xsl:call-template name="get.backlink" />
        </h2>
    </xsl:template>
    
    <xsl:template match="element()" mode="toc">
        <li>
            <a href="#{generate-id()}" title="{@rdf:about|@rdf:ID}">
                <xsl:choose>
                    <xsl:when test="exists(rdfs:label)">
                        <xsl:value-of select="rdfs:label[f:isInLanguage(.)]" />
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:value-of select="f:getLabel(@rdf:about|@rdf:ID)" />
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </li>
    </xsl:template>
    
    <xsl:template match="owl:equivalentClass | rdfs:subClassOf | rdfs:subPropertyOf">
    	<xsl:param name="list" select="true()" tunnel="yes" as="xs:boolean" />
    	<xsl:choose>
    		<xsl:when test="$list">
    			<li>
            		<xsl:apply-templates select="attribute() | element()" />
        		</li>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:apply-templates select="attribute() | element()" />
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:template>
    
    <xsl:template match="owl:hasKey">
        <li>
            <xsl:for-each select="element()">
                <xsl:if test="exists(preceding-sibling::element())">
                    <xsl:text> , </xsl:text>
                </xsl:if>
                <xsl:apply-templates select=".">
                    <xsl:with-param name="type" select="'property'" as="xs:string" tunnel="yes" />
                </xsl:apply-templates>
            </xsl:for-each>
        </li>
    </xsl:template>
    
    <xsl:template match="owl:disjointWith | owl:sameAs | rdf:type">
        <li>
            <xsl:apply-templates select="@rdf:resource" />
        </li>
    </xsl:template>
    
    <!-- Edited (Jan). Template edited to allow linking not only to internal ids, but also to other modules entities on differerent pages -->
    <xsl:template match="@rdf:about | @rdf:resource | @rdf:ID | @rdf:datatype">
        <xsl:param name="type" select="''" as="xs:string" tunnel="yes" />
        
        <xsl:variable name="anchor" select="f:findEntityId(.,$type)" as="xs:string" />
        <xsl:variable name="label" select="f:getLabel(.)" as="xs:string" />
		<!-- Attention: can only handle /-URIs not #-URIs for now !! -->
		<xsl:variable name="extLink" select="concat($server-url-prefix, substring(.,1,f:string-last-index-of(.,'/')),$lode-parameters,'#',.)" as="xs:string" />
		
        <xsl:choose>
            <xsl:when test="$anchor = ''">
                <span class="dotted" title="{.}">
                    <xsl:value-of select="$label" />
                </span>
            </xsl:when>
            <xsl:otherwise>
				<!-- Edited (Fabi). If the entry isn't stable it should show a blank text with a mouseover notification instead of a link-->
				<xsl:choose>
				<xsl:when test="f:isStable(.) or $ignore-stable">
					<xsl:choose>
		         		<xsl:when  test="starts-with(.,$ontology-url)" >
			 				<a href="#{.}" title="{.}">
	                    		<xsl:value-of select="$label" />
	                		</a> 
		         		</xsl:when>
			         	<xsl:otherwise>            
			        	     <a href="{$extLink}" title="{.} (view in extra module)">
			        	     	<xsl:value-of select="$label" />
							</a>
			   			</xsl:otherwise>
					</xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    	<a title="not yet stable"><xsl:value-of select="$label" /></a>
            </xsl:otherwise>
        </xsl:choose>
				<!--- Edited End-->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get.entity.type.descriptor">
            <xsl:with-param name="iri" select="." as="xs:string" />
        </xsl:call-template>
    </xsl:template>
    
    <!--xsl:template match="@rdf:about | @rdf:resource | @rdf:ID | @rdf:datatype">
        <xsl:param name="type" select="''" as="xs:string" tunnel="yes" />
        
        <xsl:variable name="anchor" select="f:findEntityId(.,$type)" as="xs:string" />
        <xsl:variable name="label" select="f:getLabel(.)" as="xs:string" />
        <xsl:variable name="label" select="f:getLabel(.)" as="xs:string" />
        <xsl:choose>
            <xsl:when test="$anchor = ''">
                <span class="dotted" title="{.}">
                    <xsl:value-of select="$label" />
                </span>
            </xsl:when>
            <xsl:otherwise>
                <a href="#{$anchor}" title="{.}">here?
                    <xsl:value-of select="$label" />
                </a>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get.entity.type.descriptor">
            <xsl:with-param name="iri" select="." as="xs:string" />
        </xsl:call-template>
    </xsl:template-->
    
	<!-- Edited (Fabi). a function to get the stable state of an entry, parameter "iri"= iri of the entry-->
	<xsl:function name="f:isStable" as="xs:boolean">
		<xsl:param name="iri" as="xs:string" />
		<xsl:variable name="el" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(element())]" as="element()*" />
		
        <xsl:choose>
        	<xsl:when test="$ignore-stable">
        		<xsl:value-of select="true()" />
        	</xsl:when>
            <xsl:when test="exists($el)">
					<xsl:choose>
                    <xsl:when test="$el/swstatus:term_status = 'stable'">
					<xsl:value-of select="true()" />
					</xsl:when>
					<xsl:otherwise>
                        <xsl:value-of select="false()" />
                    </xsl:otherwise>
					</xsl:choose>
            </xsl:when>
            <xsl:otherwise>
			<xsl:value-of select="false()"/>
			</xsl:otherwise>
        </xsl:choose>
        
	</xsl:function>
	<!--- Edited End-->
	
    <xsl:function name="f:findEntityId" as="xs:string">
        <xsl:param name="iri" as="xs:string" />
        <xsl:param name="type" as="xs:string" />
        
        <xsl:variable name="el" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(element())]" as="element()*" />
        <xsl:choose>
            <xsl:when test="exists($el)">
                <xsl:choose>
                    <xsl:when test="$type = 'class'">
                        <xsl:value-of select="generate-id($el[local-name() = 'Class'][1])" />
                    </xsl:when>
                    <xsl:when test="$type = 'property'">
                        <xsl:value-of select="generate-id($el[local-name() = 'ObjectProperty' or local-name() = 'DatatypeProperty'][1])" />
                    </xsl:when>
                    <xsl:when test="$type = 'annotation'">
                        <xsl:value-of select="generate-id($el[local-name() = 'AnnotationProperty'][1])" />
                    </xsl:when>
                    <xsl:when test="$type = 'individual'">
                        <xsl:value-of select="generate-id($el[local-name() = 'NamedIndividual'][1])" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id($el[1])" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:getLabel" as="xs:string">
        <xsl:param name="iri" as="xs:string" />
        
        <xsl:variable name="node" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(rdfs:label)][1]" as="element()*" />
        <xsl:choose>
            <xsl:when test="exists($node/rdfs:label)">
                <xsl:value-of select="$node/rdfs:label[f:isInLanguage(.)]" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="prefix" select="f:getPrefixFromIRI($iri)" as="xs:string*" />
                <xsl:choose>
                    <xsl:when test="empty($prefix)">
                        <xsl:value-of select="$iri" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($prefix,':',substring-after($iri, namespace-uri-for-prefix($prefix,$rdf)))" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="owl:Class[not(parent::rdf:RDF)] | rdfs:Datatype[not(parent::rdf:RDF)] | owl:DataRange[not(parent::rdf:RDF)]">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="owl:Restriction">
        <xsl:call-template name="exec.owlRestriction" />
    </xsl:template>
    
    <xsl:template match="owl:oneOf">
        <xsl:text>{ </xsl:text>
        <xsl:for-each select="element()">
            <xsl:apply-templates select="." />
            <xsl:if test="position() != last()">
                <xsl:text> , </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text> }</xsl:text>
    </xsl:template>
    
    <xsl:template match="rdf:Description[rdf:type/@rdf:resource = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#List'] | rdf:List">
        <xsl:apply-templates select="rdf:first , rdf:rest" />
    </xsl:template>
    
    <xsl:template match="rdf:first">
        <xsl:choose>
            <xsl:when test="normalize-space()">
                <xsl:text>&quot;</xsl:text>
                <xsl:value-of select="normalize-space()" />
                <xsl:text>&quot;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="@rdf:resource" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="rdf:rest">
        <xsl:if test="rdf:Description[rdf:type/@rdf:resource = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#List'] | rdf:List">
            <xsl:text> , </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#List'] | rdf:List" />
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/rdf:Description[exists(rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#AllDisjointClasses'])]">
        <div id="{generate-id()}" class="entity">
            <h3><xsl:value-of select="f:getDescriptionLabel('disjointclasses')" /><xsl:text> </xsl:text><xsl:call-template name="get.backlink" /></h3>
            <p>
                <xsl:for-each select="owl:members/rdf:Description/(@rdf:about|@rdf:ID)">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="type" select="'class'" as="xs:string" tunnel="yes" />
                    </xsl:apply-templates>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </p>
        </div>
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/owl:Restriction[exists(rdfs:subClassOf)]">
        <div id="{generate-id()}" class="entity">
            <h3><xsl:value-of select="f:getDescriptionLabel('subclassdefinition')" /><xsl:text> </xsl:text><xsl:call-template name="get.backlink" /></h3>
            <p>
                <xsl:call-template name="exec.owlRestriction" />
                <strong><xsl:text> </xsl:text><xsl:value-of select="f:getDescriptionLabel('issubclassof')" /></strong>
            </p>
            <p style="text-align:right">
                <xsl:apply-templates select="rdfs:subClassOf">
                    <xsl:with-param name="list" select="false()" tunnel="yes" />
                </xsl:apply-templates>
            </p>
        </div>
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/owl:Restriction[exists(owl:equivalentClass)]">
        <div id="{generate-id()}" class="entity">
            <h3><xsl:value-of select="f:getDescriptionLabel('equivalentdefinition')" /><xsl:text> </xsl:text><xsl:call-template name="get.backlink" /></h3>
            <p>
                <xsl:call-template name="exec.owlRestriction" />
                <strong><xsl:text> </xsl:text><xsl:value-of select="f:getDescriptionLabel('isequivalentto')" /></strong>
            </p>
            <p style="text-align:right">
                <xsl:apply-templates select="owl:equivalentClass">
                    <xsl:with-param name="list" select="false()" tunnel="yes" />
                </xsl:apply-templates>
            </p>
        </div>
    </xsl:template>
    
    <xsl:template name="exec.owlRestriction">
        <xsl:apply-templates select="owl:onProperty" />
        <xsl:apply-templates select="element()[not(self::owl:onProperty|self::owl:onClass|self::rdfs:subClassOf|self::owl:equivalentClass)]" />
        <xsl:apply-templates select="owl:onClass" />
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/owl:Class[empty(@rdf:about | @rdf:ID) and exists(rdfs:subClassOf)]">
        <div id="{generate-id()}" class="entity">
            <h3><xsl:value-of select="f:getDescriptionLabel('subclassdefinition')" /><xsl:text> </xsl:text><xsl:call-template name="get.backlink" /></h3>
            <p>
            	<xsl:apply-templates select="element()[not(self::rdfs:subClassOf)]" />
                <strong><xsl:text> </xsl:text><xsl:value-of select="f:getDescriptionLabel('issubclassof')" /></strong>
           	</p>
           	<p style="text-align:right">
            	<xsl:apply-templates select="rdfs:subClassOf">
            		<xsl:with-param name="list" select="false()" tunnel="yes" />
            	</xsl:apply-templates>
            </p>
        </div>
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/owl:Class[empty(@rdf:about | @rdf:ID) and exists(owl:equivalentClass)]">
        <div id="{generate-id()}" class="entity">
            <h3><xsl:value-of select="f:getDescriptionLabel('equivalentdefinition')" /><xsl:text> </xsl:text><xsl:call-template name="get.backlink" /></h3>
            <p>
            	<xsl:apply-templates select="element()[not(self::owl:equivalentClass)]" />
                <strong><xsl:text> </xsl:text><xsl:value-of select="f:getDescriptionLabel('isequivalentto')" /></strong>
           	</p>
           	<p style="text-align:right">
            	<xsl:apply-templates select="owl:equivalentClass">
            		<xsl:with-param name="list" select="false()" tunnel="yes" />
            	</xsl:apply-templates>
            </p>
        </div>
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#FunctionalProperty']">
        <xsl:value-of select="f:getDescriptionLabel('functional')" />
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#InverseFunctionalProperty']">
        <xsl:value-of select="f:getDescriptionLabel('inversefunctional')" />
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#ReflexiveProperty']">
        <xsl:value-of select="f:getDescriptionLabel('reflexive')" />
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#IrreflexiveProperty']">
        <xsl:value-of select="f:getDescriptionLabel('irreflexive')" />
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#SymmetricProperty']">
        <xsl:value-of select="f:getDescriptionLabel('symmetric')" />
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#AsymmetricProperty']">
        <xsl:value-of select="f:getDescriptionLabel('asymmetric')" />
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#TransitiveProperty']">
        <xsl:value-of select="f:getDescriptionLabel('transitive')" />
    </xsl:template>
    
    <xsl:template match="owl:hasValue">
        <xsl:call-template name="get.cardinality.formula">
            <xsl:with-param name="op" select="'value'" as="xs:string" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="owl:cardinality | owl:qualifiedCardinality">
        <xsl:call-template name="get.cardinality.formula">
            <xsl:with-param name="op" select="'exactly'" as="xs:string" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="owl:maxCardinality | owl:maxQualifiedCardinality">
        <xsl:call-template name="get.cardinality.formula">
            <xsl:with-param name="op" select="'max'" as="xs:string" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="owl:minCardinality | owl:minQualifiedCardinality">
        <xsl:call-template name="get.cardinality.formula">
            <xsl:with-param name="op" select="'min'" as="xs:string" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="get.cardinality.formula">
        <xsl:param name="op" as="xs:string" />
        <xsl:text> </xsl:text>
        <span class="logic"><xsl:value-of select="$op" /></span>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="@rdf:resource">
                <xsl:apply-templates select="@rdf:resource" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="owl:onClass">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="@rdf:resource">
            <xsl:with-param name="type" as="xs:string" tunnel="yes" select="'class'" />
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="owl:onProperty">
        <xsl:apply-templates select="@rdf:resource|rdf:Description/owl:inverseOf">
            <xsl:with-param name="type" as="xs:string" tunnel="yes" select="'property'" />
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="owl:allValuesFrom | owl:someValuesFrom">
        <xsl:variable name="logic" select="if (self::owl:allValuesFrom) then 'only' else 'some'" as="xs:string" />
        <xsl:text> </xsl:text>
        <span class="logic"><xsl:value-of select="$logic" /></span>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="exists(@rdf:resource)">
                <xsl:apply-templates select="@rdf:resource" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="rdf:Description">
        <xsl:apply-templates select="@rdf:about|@rdf:ID" />
    </xsl:template>
    
    <xsl:template match="owl:intersectionOf">
        <xsl:call-template name="get.logical.formula">
            <xsl:with-param name="op" select="'and'" as="xs:string" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="owl:unionOf">
        <xsl:call-template name="get.logical.formula">
            <xsl:with-param name="op" select="'or'" as="xs:string" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="owl:complementOf">
        <span class="logic">not</span>
        <xsl:text> (</xsl:text>
        <xsl:apply-templates select="element() | @rdf:resource" />
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template name="get.logical.formula">
        <xsl:param name="op" as="xs:string" />
        <xsl:for-each select="element()">
            <xsl:choose>
                <xsl:when test="self::rdf:Description">
                    <xsl:apply-templates select="." />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>(</xsl:text>
                    <xsl:apply-templates select="." />
                    <xsl:text>)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
                <span class="logic"><xsl:value-of select="$op" /></span>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="get.entity.metadata">
        <xsl:call-template name="get.entity.url" />
        <xsl:call-template name="get.version" />
        <xsl:call-template name="get.author" />
        <xsl:call-template name="get.original.source" />
    </xsl:template>

  <!-- Edited Begin: template to get the entry of an annotation -->
  <xsl:template name="get.annotation">
    <xsl:param name="node" as="element()" />
  </xsl:template>
<!--
  <xsl:template match="dct:creator">
          <xsl:variable name="iri" select="attribute() | element()" as="xs:string*" />
          <xsl:variable name="el" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(element())]" as="element()*" />
          <xsl:choose>
            <xsl:when test="exists($el)">
			creator
			</xsl:when>
			<xsl:otherwise>
			no creator
			</xsl:otherwise>
			</xsl:choose>

</xsl:template>
	-->		
  <xsl:template match="bixt:considersSource | bixt:followsSource | bixt:contradictsSource">
    <xsl:param name="list" select="true()" tunnel="yes" as="xs:boolean" />
    <xsl:choose>
      <xsl:when test="$list">
        <li class="citation" >
          <xsl:variable name="iri" select="attribute() | element()" as="xs:string*" />
          <xsl:variable name="el" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(element())]" as="element()*" />
          <xsl:choose>
            <xsl:when test="exists($el)">
			  
                <xsl:choose>
			<xsl:when test="exists($el/dct:title)">
								  <div class="citation_content_as_booksection">
								  <xsl:apply-templates select="$el/dct:creator" />
								  in 
						<span class="quote_symbol">&raquo;</span>
							<xsl:value-of select="$el/dct:title"/>
						<span class="quote_symbol">&laquo;</span>
						<xsl:choose>
	                  <xsl:when test="exists($el/bibo:pages)">
	                    (p. <xsl:value-of select="$el/bibo:pages"/>)
	                  </xsl:when>
	                  <xsl:otherwise>
	                  </xsl:otherwise>
	                </xsl:choose>
				</div>
				</xsl:when>
				<xsl:otherwise>
                <xsl:choose>
                <xsl:when test="exists($el/bixt:documentContent)">
                	<div class="citation_content">
                		<span class="quote_symbol">&raquo;</span>
							<xsl:value-of select="$el/bixt:documentContent"/>
						<span class="quote_symbol">&laquo;</span>
					</div>
                </xsl:when>
                <xsl:otherwise>
                	<div class="citation_no_content">
                		[General note on the topic, no concrete quotation given]
                	</div>
                </xsl:otherwise>
                </xsl:choose>
              
			  <div style="height:1em">
	              <div class="citation_metadata">
	              	
	                <xsl:choose>
	                  <xsl:when test="exists($el/bixt:isDocumentPartOf)">
	                    <xsl:apply-templates select="$el/bixt:isDocumentPartOf" />
	                  </xsl:when>
	                  <xsl:otherwise>
	                  </xsl:otherwise>
	                </xsl:choose>
	                <xsl:choose>
	                  <xsl:when test="exists($el/bibo:pages)">
	                    ,p. <xsl:value-of select="$el/bibo:pages"/>
	                  </xsl:when>
	                  <xsl:otherwise>
	                  </xsl:otherwise>
	                </xsl:choose>
                
	                <xsl:choose>
	                  <xsl:when test="exists($el/bibo:section)">
	                    , Sect. <xsl:value-of select="$el/bibo:section"/>
	                  </xsl:when>
	                  <xsl:otherwise>
	                  </xsl:otherwise>
	                </xsl:choose>
				
				</div>
              </div>
              
               <xsl:if test="exists($el/rdfs:comment)">
                    <div class="citation_comment">
						(Comment: <xsl:value-of select="$el/rdfs:comment"/>)
					</div>
                </xsl:if>
              
			  </xsl:otherwise>
			  </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              NOPE
            </xsl:otherwise>
          </xsl:choose>
          <!--<xsl:apply-templates select="attribute() | element()" />-->
        </li>
      </xsl:when>
      <xsl:otherwise>
        KEINE LISTE
        <xsl:apply-templates select="attribute() | element()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="bixt:isDocumentPartOf">
    <xsl:variable name="iri" select="attribute() | element()" as="xs:string*" />
    <xsl:variable name="el" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(element())]" as="element()*" />
    <xsl:choose>
      <xsl:when test="exists($el)">

        <xsl:choose>
          <xsl:when test="exists($el/dct:creator)">
            <xsl:apply-templates select="$el/dct:creator" />,
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:choose>
          <xsl:when test="exists($el/bibo:shortTitle)">
            &quot;<xsl:value-of select="$el/bibo:shortTitle"/>&quot;,
          </xsl:when>
          <xsl:otherwise>
            &quot;<xsl:value-of select="$el/dct:title"/>&quot;,
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="exists($el/dct:date)">
            <xsl:value-of select="$el/dct:date"/>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>     
      
      </xsl:when>
      
      <xsl:otherwise>
        NOPE
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dct:creator">
    <xsl:variable name="iri" select="attribute() | element()" as="xs:string*" />
    <xsl:variable name="el" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(element())]" as="element()*" />
    <xsl:choose>
      <xsl:when test="exists($el)">
        <xsl:value-of select="$el" disable-output-escaping="yes"/>
        <!--<xsl:choose>
          <xsl:when test="exists(foaf:givenname)">
            YES
          </xsl:when>
          <xsl:otherwise>
            NO-NAME
          </xsl:otherwise>
        </xsl:choose>-->
      </xsl:when>
      <xsl:otherwise>
        NOPE
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:function name="f:getMetadata" as="xs:string*">
    <xsl:param name="ele" as="element()*" />
    <!--<xsl:variable name="result" select="$ele/bibo:pages"/>-->
    JOP
    <!--<xsl:if test="exists($ele/bibo:pages)">
      <xsl:value-of select="$ele/bibo:pages"/>
    </xsl:if>
    <xsl:if test="exists($ele/bixt:isDocumentPartOf)">
      PART OF
      <xsl:value-of select="$ele/bixt:isDocumentPartOf"/>
    </xsl:if>-->
    <!--<xsl:variable name="iriNew" select="if (contains($iri,'#') or contains($iri,'/')) then $iri else concat(base-uri($root), $iri)" as="xs:string" />

    <xsl:variable name="ns" select="if (contains($iriNew,'#')) then substring($iriNew,1,f:string-first-index-of($iriNew,'#')) else substring($iriNew,1,f:string-last-index-of($iriNew,'/'))" as="xs:string" />

    <xsl:variable name="result" select="(for $prefix in in-scope-prefixes($rdf) return if (namespace-uri-for-prefix($prefix,$rdf) = $ns) then $prefix else ())" />
    <xsl:choose>
      <xsl:when test="count($result) > 1">
        <xsl:value-of select="$result[normalize-space() != ''][1]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$result[1]" />
      </xsl:otherwise>
    </xsl:choose>-->
  </xsl:function>

  <!--<xsl:function name="f:getAnnotation" as="xs:string">-->
    <!--<xsl:param name="iri" as="xs:string" />-->
<!--
    <xsl:variable name="node" select="$root//rdf:RDF/element()[(@rdf:about = $iri or @rdf:ID = $iri) and exists(rdfs:label)][1]" as="element()*" />
    <xsl:if test="exists($node/bibo:pages)">
      YES MOM!
    </xsl:if>-->
    
    <!--<xsl:choose>
      <xsl:when test="exists($node/rdfs:label)">
        <xsl:value-of select="$node/rdfs:label[f:isInLanguage(.)]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="prefix" select="f:getPrefixFromIRI($iri)" as="xs:string*" />
        <xsl:choose>
          <xsl:when test="empty($prefix)">
            <xsl:value-of select="$iri" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($prefix,':',substring-after($iri, namespace-uri-for-prefix($prefix,$rdf)))" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>-->
  <!--</xsl:function>-->
  <!-- Edited End-->

  <!-- Edited Begin: added extraction of bibo and bixt components-->
 <!-- Edited Jan: seems to be forgotten code. Delete?
 <xsl:template name="get.documentReference">
    <div class="quotation">
    <xsl:if test="exists(bixt:documentContent)">
      &quot;<xsl:value-of select="bixt:documentContent" />&quot;
      (<xsl:value-of select="bibo:pages" />
      <xsl:if test="exists(bixt:isDocumentPartOf)">
        ,<xsl:value-of select="bixt:isDocumentPartOf" disable-output-escaping="yes"/>
      </xsl:if>)
  </xsl:if>
    </div>
  </xsl:template>
  -->
  
    <xsl:template name="get.document">
      <xsl:if test="exists(bixt:documentContent)">
      </xsl:if>
    </xsl:template>

  <xsl:template name="get.documentContent">
  </xsl:template>

  <xsl:template name="get.documentPages">

  </xsl:template>
  <!-- Edited End-->
  
  
    <xsl:template name="get.original.source">
        <xsl:if test="exists(rdfs:isDefinedBy)">
            <dl class="definedBy">
                <dt><xsl:value-of select="f:getDescriptionLabel('isdefinedby')" /></dt>
                <xsl:for-each select="rdfs:isDefinedBy">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="normalize-space(@rdf:resource) = ''">
                                <xsl:value-of select="$ontology-url" />
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{@rdf:resource}">
                                    <xsl:value-of select="@rdf:resource" />
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                </xsl:for-each>
            </dl>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.description">
        <xsl:if test="exists(rdfs:subClassOf | owl:sameAs | owl:hasKey | owl:equivalentClass | owl:disjointWith) or f:hasMembers(.) or f:hasSubclasses(.) or f:isInDomain(.) or f:isInRange(.)">
            <dl class="description">
                <xsl:call-template name="get.class.equivalent" />
                <xsl:call-template name="get.class.superclasses" />
                <xsl:call-template name="get.class.subclasses" />
                <xsl:call-template name="get.class.indomain" />
                <xsl:call-template name="get.class.inrange" />
                <xsl:call-template name="get.class.members" />
                <xsl:call-template name="get.class.keys" />
                <xsl:call-template name="get.entity.sameas" />
                <xsl:call-template name="get.entity.disjoint" />
                <xsl:call-template name="get.entity.punning" />
            </dl>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.individual.description">
        <xsl:if test="exists(owl:sameAs | rdf:type | owl:disjointWith)">
            <dl class="description">
                <xsl:call-template name="get.entity.type" />
                <xsl:call-template name="get.entity.sameas" />
                <xsl:call-template name="get.entity.disjoint" />
                <xsl:call-template name="get.entity.punning" />
            </dl>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.entity.type">
        <xsl:if test="exists(rdf:type)">
            <dt><xsl:value-of select="f:getDescriptionLabel('belongsto')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="rdf:type">
                        <xsl:with-param name="type" tunnel="yes" select="'class'" as="xs:string" />
                    </xsl:apply-templates>
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.entity.sameas">
        <xsl:if test="exists(owl:sameAs)">
            <dt><xsl:value-of select="f:getDescriptionLabel('issameas')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="owl:sameAs" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.entity.punning">
        <xsl:variable name="iri" select="@rdf:about|@rdf:ID" as="xs:string" />
        <xsl:variable name="type" select="f:getType(.)" as="xs:string" />
        <xsl:variable name="punningsequence" select="/rdf:RDF/element()[@rdf:about = $iri or @rdf:ID = $iri][f:getType(.) != $type]" as="element()*" />
        
        <xsl:if test="$punningsequence">
            <dt><xsl:value-of select="f:getDescriptionLabel('isalsodefinedas')" /></dt>
            <dd>
                <xsl:for-each select="$punningsequence">
                    <a href="#{generate-id(.)}"><xsl:value-of select="f:getType(.)" /></a>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>
        </xsl:if> 
    </xsl:template>
    
    <xsl:template name="get.entity.disjoint">
        <xsl:if test="exists(owl:disjointWith)">
            <dt><xsl:value-of select="f:getDescriptionLabel('isdisjointwith')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="owl:disjointWith" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.keys">
        <xsl:if test="exists(owl:hasKey)">
            <dt><xsl:value-of select="f:getDescriptionLabel('haskeys')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="owl:hasKey" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.equivalent">
        <xsl:if test="exists(owl:equivalentClass)">
            <dt><xsl:value-of select="f:getDescriptionLabel('isequivalentto')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="owl:equivalentClass" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.superclasses">
        <xsl:if test="exists(rdfs:subClassOf)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hassuperclasses')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="rdfs:subClassOf" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.subclasses">
        <xsl:variable name="about" select="@rdf:about|@rdf:ID" as="xs:string" />
        <xsl:variable name="sub-classes" as="attribute()*" select="/rdf:RDF/owl:Class[some $res in rdfs:subClassOf/@rdf:resource satisfies $res = $about]/(@rdf:about|@rdf:ID)" />
        <xsl:if test="exists($sub-classes)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hassubclasses')" /></dt>
            <dd>
                <xsl:for-each select="$sub-classes">
                    <xsl:sort select="f:getLabel(.)" data-type="text" order="ascending" />
                    <xsl:apply-templates select="." />
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.indomain">
        <xsl:variable name="about" select="@rdf:about|@rdf:ID" as="xs:string" />
        <xsl:variable name="properties" as="attribute()*" select="/rdf:RDF/(owl:ObjectProperty|owl:DatatypeProperty|owl:AnnotationProperty)[some $res in rdfs:domain/@rdf:resource satisfies $res = $about]/(@rdf:about|@rdf:ID)" />
        <xsl:if test="exists($properties)">
            <dt><xsl:value-of select="f:getDescriptionLabel('isindomainof')" /></dt>
            <dd>
                <xsl:for-each select="$properties">
                    <xsl:sort select="f:getLabel(.)" order="ascending" data-type="text" />
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="type" as="xs:string" tunnel="yes" select="if (../owl:AnnotationProperty) then 'annotation' else 'property'" />
                    </xsl:apply-templates>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.inrange">
        <xsl:variable name="about" select="(@rdf:about|@rdf:ID)" as="xs:string" />
        <xsl:variable name="properties" as="attribute()*" select="/rdf:RDF/(owl:ObjectProperty|owl:DatatypeProperty|owl:AnnotationProperty)[some $res in rdfs:range/@rdf:resource satisfies $res = $about]/(@rdf:about|@rdf:ID)" />
        <xsl:if test="exists($properties)">
            <dt><xsl:value-of select="f:getDescriptionLabel('isinrangeof')" /></dt>
            <dd>
                <xsl:for-each select="$properties">
                    <xsl:sort select="f:getLabel(.)" order="ascending" data-type="text" />
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="type" as="xs:string" tunnel="yes" select="if (../owl:AnnotationProperty) then 'annotation' else 'property'" />
                    </xsl:apply-templates>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.class.members">
        <xsl:variable name="about" select="(@rdf:about|@rdf:ID)" as="xs:string" />
        <xsl:variable name="members" as="attribute()*" select="/rdf:RDF/owl:NamedIndividual[some $res in rdf:type/@rdf:resource satisfies $res = $about]/(@rdf:about|@rdf:ID)" />
        <xsl:if test="exists($members)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hasmembers')" /></dt>
            <dd>
                <xsl:for-each select="$members">
                    <xsl:sort select="f:getLabel(.)" order="ascending" data-type="text" />
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="type" as="xs:string" tunnel="yes" select="'individual'" />
                    </xsl:apply-templates>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.property.description">
        <xsl:if test="exists(rdfs:subPropertyOf | owl:sameAs | rdfs:domain | rdfs:range | owl:disjointWith | owl:propertyChainAxiom | owl:inverseOf) or f:hasSubproperties(.)">
            <div class="description">
                <xsl:call-template name="get.characteristics" />
                <dl>
                    <xsl:call-template name="get.property.superproperty" />
                    <xsl:call-template name="get.property.subproperty" />
                    <xsl:call-template name="get.property.domain" />
                    <xsl:call-template name="get.property.range" />
                    <xsl:call-template name="get.property.inverse" />
                    <xsl:call-template name="get.property.chain" />
                    <xsl:call-template name="get.entity.sameas" />
                    <xsl:call-template name="get.entity.disjoint" />
                    <xsl:call-template name="get.entity.punning" />
                </dl>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.property.inverse">
        <xsl:if test="exists(owl:inverseOf)">
            <dt><xsl:value-of select="f:getDescriptionLabel('isinverseof')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="owl:inverseOf" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.property.chain">
        <xsl:if test="exists(owl:propertyChainAxiom)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hassubpropertychains')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="owl:propertyChainAxiom" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.property.superproperty">
        <xsl:if test="exists(rdfs:subPropertyOf)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hassuperproperties')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="rdfs:subPropertyOf" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.property.subproperty">
        <xsl:variable name="type" select="if (self::owl:AnnotationProperty) then 'annotation' else 'property'" as="xs:string" />
        <xsl:variable name="about" select="(@rdf:about|@rdf:ID)" as="xs:string" />
        <xsl:variable name="sub-properties" as="attribute()*" select="/rdf:RDF/(if ($type = 'property') then owl:DatatypeProperty | owl:ObjectProperty else owl:AnnotationProperty)[some $res in rdfs:subPropertyOf/@rdf:resource satisfies $res = $about]/(@rdf:about|@rdf:ID)" />
        <xsl:if test="exists($sub-properties)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hassubproperties')" /></dt>
            <dd>
                <xsl:for-each select="$sub-properties">
                    <xsl:sort select="f:getLabel(.)" data-type="text" order="ascending" />
                    <xsl:apply-templates select="." />
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.property.domain">
        <xsl:if test="exists(rdfs:domain)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hasdomain')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="rdfs:domain" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.property.range">
        <xsl:if test="exists(rdfs:range)">
            <dt><xsl:value-of select="f:getDescriptionLabel('hasrange')" /></dt>
            <dd>
                <ul>
                    <xsl:apply-templates select="rdfs:range" />
                </ul>
            </dd>
        </xsl:if>
    </xsl:template>
    
    <!--  Jan edited note: added  disable-output-escaping="yes" here to allow for (encoded) 
    html being rendered as html. Edited again: Temporarily turned this back since encoded  ampersands in the 
    viso-anno for example were also decoded, which lead to invalid xhtml and problems when lode tries to import
    ontology modules  (no idea, why it notes the changes in the documentation. should actually only use the ontology data 
    -->
    <xsl:template name="get.content">
        <xsl:for-each select="text()">
            <xsl:for-each select="tokenize(.,$n)">
                <xsl:if test="normalize-space(.) != ''">
                    <p>
                        <xsl:value-of disable-output-escaping="yes" select="." />
                    </p>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="get.title">
        <xsl:for-each select="tokenize(.//text(),$n)">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()">
                <br />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="get.ontology.url">
        <xsl:if test="exists((@rdf:about|@rdf:ID)[normalize-space() != ''])">
          <div class="url">
            <xsl:value-of select="@rdf:about|@rdf:ID" />
          </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.version">
        <xsl:if test="exists(owl:versionInfo | owl:priorVersion | dc:date | dct:date)">
            <dl>
                <xsl:apply-templates select="dc:date | dct:date" />
                <xsl:apply-templates select="owl:versionInfo" />
                <xsl:apply-templates select="owl:priorVersion" />
            </dl>
        </xsl:if>
    </xsl:template>
    
    <!-- added by Jan -->
    <xsl:template name="get.stableinfo">
        <xsl:choose>
	        <xsl:when test="$ignore-stable">
	        	<!--All resources are currently displayed, including non-stable ones.-->
	        </xsl:when>
	        <xsl:otherwise>
	        	<p class="info" style="font-style:italic">Only stable resources are currently shown!
	        		<a title="Show all resources, not only those being marked as stable."
            		 href="{$server-url-prefix}{$ontology-url}{$lode-parameters}&amp;nonstable=true">Show all</a> ... 
	        	</p>
	        </xsl:otherwise>
	     </xsl:choose>
    </xsl:template>
    
    <xsl:template name="get.imports">
        <xsl:if test="exists(owl:imports)">
            <dl id="imports">
                <dt><xsl:value-of select="f:getDescriptionLabel('importedontologies')" />:</dt>
                <xsl:apply-templates select="owl:imports" />
            </dl>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.entity.name">
    	<xsl:variable name="url" select="@rdf:about|@rdf:ID" as="xs:string" />
        <a name="{$url}" />
        <xsl:if test="starts-with($url, if (ends-with($ontology-url,'#')) then $ontology-url else concat($ontology-url, '#'))">
        	<a name="{substring-after($url, '#')}" />
        </xsl:if>
        <xsl:choose>
            <xsl:when test="exists(rdfs:label)">
                <xsl:apply-templates select="rdfs:label" />
            </xsl:when>
            <xsl:otherwise>
                <h3>
                  <!-- Edited Begin: DocumentTitle-->
                    <span class="dotted" title="{@rdf:about|@rdf:ID|@bibo:doi}">
                      <xsl:choose>
                        <xsl:when test="exists(dct:title)">
                          <xsl:value-of select="dct:title"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="f:getLabel(@rdf:about|@rdf:ID)" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </span>
                  <!-- Edited End-->
                    <xsl:call-template name="get.entity.type.descriptor">
                        <xsl:with-param name="iri" select="@rdf:about|@rdf:ID" as="xs:string" />
                    </xsl:call-template>
                    <xsl:call-template name="get.backlink" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="get.author">
        <xsl:if test="exists(dc:creator | dc:contributor | dct:creator[ancestor::owl:Ontology] | dct:contributor[ancestor::owl:Ontology])">
            <dl>
                <xsl:if test="exists(dc:creator|dct:creator[ancestor::owl:Ontology])">
                    <dt><xsl:value-of select="f:getDescriptionLabel('authors')" />:</dt>
                    <xsl:apply-templates select="dc:creator|dct:creator[ancestor::owl:Ontology]">
                        <!-- Error: A sequence of more than one item is not allowed as the @select attribute of xsl:sort: <xsl:sort select="text()|@rdf:resource" data-type="text" order="ascending" />-->
                    </xsl:apply-templates>
                </xsl:if>
                <xsl:if test="exists(dc:contributor|dct:contributor[ancestor::owl:Ontology])">
                    <dt><xsl:value-of select="f:getDescriptionLabel('contributors')" />:</dt>
                    <xsl:apply-templates select="dc:contributor|dct:contributor[ancestor::owl:Ontology]">
                        <xsl:sort select="text()|@rdf:resource" data-type="text" order="ascending" />
                    </xsl:apply-templates>
                </xsl:if>
                <dt>Contact:</dt>
                	<dd>jan.polowinski at tu-dresden.de</dd>
            </dl>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.toc">
        <div id="toc">
            <h2><xsl:value-of select="f:getDescriptionLabel('toc')" /></h2>
            <ol>
                <xsl:if test="exists(//owl:Ontology/dct:description[normalize-space() != ''])">
                    <li><a href="#introduction"><xsl:value-of select="f:getDescriptionLabel('introduction')" /></a></li>
                </xsl:if>
                <xsl:if test="exists(/rdf:RDF/owl:Class/element())">
                    <li><a href="#classes"><xsl:value-of select="f:getDescriptionLabel('classes')" /></a></li>
                </xsl:if>
                <xsl:if test="exists(//owl:ObjectProperty/element())">
                    <li><a href="#objectproperties"><xsl:value-of select="f:getDescriptionLabel('objectproperties')" /></a></li>
                </xsl:if>
                <xsl:if test="exists(//owl:DatatypeProperty/element())">
                    <li><a href="#dataproperties"><xsl:value-of select="f:getDescriptionLabel('dataproperties')" /></a></li>
                </xsl:if>
              
                <xsl:if test="exists(//owl:NamedIndividual/element())">
                    <li><a href="#namedindividuals"><xsl:value-of select="f:getDescriptionLabel('namedindividuals')" /></a></li>
                </xsl:if>
                <xsl:if test="exists(//owl:AnnotationProperty)">
                    <li><a href="#annotationproperties"><xsl:value-of select="f:getDescriptionLabel('annotationproperties')" /></a></li>
                </xsl:if>
                <xsl:if test="exists(//rdf:Description[exists(rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#AllDisjointClasses'])]) or exists(/rdf:RDF/(owl:Class|owl:Restriction)[empty(@rdf:about | @rdf:ID) and exists(rdfs:subClassOf|owl:equivalentClass)])">
                    <li><a href="#generalaxioms"><xsl:value-of select="f:getDescriptionLabel('generalaxioms')" /></a></li>
                </xsl:if>
                <xsl:if test="exists(/rdf:RDF/swrl:Imp)">
                    <li><a href="#swrlrules"><xsl:value-of select="f:getDescriptionLabel('rules')" /></a></li>
                </xsl:if>
                <li><a href="#namespacedeclarations"><xsl:value-of select="f:getDescriptionLabel('namespaces')" /></a></li>
            </ol>
        </div>
    </xsl:template>
    
    <xsl:template name="get.entity.url">
        <p class="url">
            <xsl:value-of select="@rdf:about|@rdf:ID" />
        </p>
    </xsl:template>
    
    <xsl:template name="get.generalaxioms">
        <xsl:if test="exists(/rdf:RDF/rdf:Description[exists(rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#AllDisjointClasses'])]) or exists(/rdf:RDF/(owl:Class|owl:Restriction)[empty(@rdf:ID | @rdf:about) and exists(rdfs:subClassOf|owl:equivalentClass)])">
            <div id="generalaxioms">
                <h2><xsl:value-of select="f:getDescriptionLabel('generalaxioms')" /></h2>
                <xsl:apply-templates select="/rdf:RDF/(rdf:Description[exists(rdf:type[@rdf:resource = 'http://www.w3.org/2002/07/owl#AllDisjointClasses'])]|(owl:Class|owl:Restriction)[empty(@rdf:ID | @rdf:about) and exists(rdfs:subClassOf|owl:equivalentClass)])" />
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.namespacedeclarations">
        <div id="namespacedeclarations">
            <h2>
                <xsl:value-of select="f:getDescriptionLabel('namespaces')" /><xsl:text> </xsl:text>
                <xsl:call-template name="get.backlink" />
            </h2>
            <dl>
                <xsl:for-each select="in-scope-prefixes($rdf)">
                    <xsl:sort select="." data-type="text" order="ascending" />
                    <xsl:if test=". != 'xml'">
                        <dt>
                            <xsl:choose>
                                <xsl:when test=". = ''">
                                    <em><xsl:value-of select="f:getDescriptionLabel('namespace')" /></em>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="." />
                                </xsl:otherwise>
                            </xsl:choose>
                        </dt>
                        <dd>
                            <xsl:value-of select="namespace-uri-for-prefix(.,$rdf)" />
                        </dd>
                    </xsl:if>
                </xsl:for-each>
            </dl>
        </div>
    </xsl:template>
    
    <xsl:template name="get.classes">
        <xsl:if test="exists(/rdf:RDF/owl:Class/element())">
            <div id="classes">
                <h2><xsl:value-of select="f:getDescriptionLabel('classes')" /></h2>
                <xsl:call-template name="get.classes.toc" />
                <xsl:apply-templates select="/rdf:RDF/owl:Class[exists(element()) and exists(@rdf:about|@rdf:ID) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable) and not(contains(@rdf:about|@rdf:ID,'Container'))]">
                    <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                        order="ascending" data-type="text" />
                    <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'class'" />
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.classes.toc">
        <ul class="hlist">
            <xsl:apply-templates select="/rdf:RDF/owl:Class[exists(element()) and exists(@rdf:about|@rdf:ID) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)   and (swstatus:term_status= 'stable' or $ignore-stable) and not(contains(@rdf:about|@rdf:ID,'Container'))]" mode="toc">
                <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                    order="ascending" data-type="text" />
                <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'class'" />
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    
    <xsl:template name="get.namedindividuals">
        <xsl:if test="exists(//owl:NamedIndividual/element())">
            <div id="namedindividuals">
                <h2><xsl:value-of select="f:getDescriptionLabel('namedindividuals')" /></h2>
                <xsl:call-template name="get.namedindividuals.toc" />
                <xsl:apply-templates select="/rdf:RDF/owl:NamedIndividual[exists(element())  and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]">
                    <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                        order="ascending" data-type="text" />
                    <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'individual'" />
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.namedindividuals.toc">
        <ul class="hlist">
            <xsl:apply-templates select="/rdf:RDF/owl:NamedIndividual[exists(element())  and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]" mode="toc">
                <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                    order="ascending" data-type="text" />
                <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'individual'" />
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    
    <xsl:template name="get.objectproperties">
        <xsl:if test="exists(//owl:ObjectProperty/element())">
            <div id="objectproperties">
                <h2><xsl:value-of select="f:getDescriptionLabel('objectproperties')" /></h2>
                <xsl:call-template name="get.objectproperties.toc" />
                <xsl:apply-templates select="/rdf:RDF/owl:ObjectProperty[exists(element()) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]">
                    <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                        order="ascending" data-type="text" />
                    <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'property'" />
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.objectproperties.toc">
        <ul class="hlist">
            <xsl:apply-templates select="/rdf:RDF/owl:ObjectProperty[exists(element()) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]" mode="toc">
                <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                    order="ascending" data-type="text" />
                <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'annotation'" />
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    
    <xsl:template name="get.annotationproperties">
        <xsl:if test="exists(//owl:AnnotationProperty)">
            <div id="annotationproperties">
                <h2><xsl:value-of select="f:getDescriptionLabel('annotationproperties')" /></h2>
                <xsl:call-template name="get.annotationproperties.toc" />
                <xsl:apply-templates select="/rdf:RDF/owl:AnnotationProperty[exists(element()) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]">
                    <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                        order="ascending" data-type="text" />
                    <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'annotation'" />
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.annotationproperties.toc">
        <ul class="hlist">
            <xsl:apply-templates select="/rdf:RDF/owl:AnnotationProperty[exists(element()) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]" mode="toc">
                <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                    order="ascending" data-type="text" />
                <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'property'" />
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    
    <xsl:template name="get.dataproperties">
        <xsl:if test="exists(//owl:DatatypeProperty/element()) ">
            <div id="dataproperties">
                <h2><xsl:value-of select="f:getDescriptionLabel('dataproperties')" /></h2>
                <xsl:call-template name="get.dataproperties.toc" />
                <xsl:apply-templates select="/rdf:RDF/owl:DatatypeProperty[exists(element()) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]">
                    <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                        order="ascending" data-type="text" />
                    <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'property'" />
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get.dataproperties.toc">
        <ul class="hlist">
            <xsl:apply-templates select="/rdf:RDF/owl:DatatypeProperty[exists(element()) and (starts-with(@rdf:about|@rdf:ID, $ontology-url) or $render-imports)  and (swstatus:term_status= 'stable' or $ignore-stable)]" mode="toc">
                <xsl:sort select="lower-case(f:getLabel(@rdf:about|@rdf:ID))"
                    order="ascending" data-type="text" />
                <xsl:with-param name="type" tunnel="yes" as="xs:string" select="'property'" />
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    
    <xsl:template name="get.entity.type.descriptor">
        <xsl:param name="iri" as="xs:string" />
        <xsl:param name="type" as="xs:string" select="''" tunnel="yes" />
        <xsl:variable name="el" select="/rdf:RDF/element()[@rdf:about = $iri or @rdf:ID = $iri]" as="element()*" />
        <xsl:choose>
            <xsl:when test="($type = '' or $type = 'class') and $el[self::owl:Class]">
                <sup title="{f:getDescriptionLabel('class')}" class="type-c">c</sup>
            </xsl:when>
            <xsl:when test="($type = '' or $type = 'property') and $el[self::owl:ObjectProperty]">
                <sup title="{f:getDescriptionLabel('objectproperty')}" class="type-op">op</sup>
            </xsl:when>
            <xsl:when test="($type = '' or $type = 'property') and $el[self::owl:DatatypeProperty]">
                <sup title="{f:getDescriptionLabel('dataproperty')}" class="type-dp">dp</sup>
            </xsl:when>
            <xsl:when test="($type = '' or $type = 'annotation') and $el[self::owl:AnnotationProperty]">
                <sup title="{f:getDescriptionLabel('annotationproperty')}" class="type-ap">ap</sup>
            </xsl:when>
            <xsl:when test="($type = '' or $type = 'individual') and $el[self::owl:NamedIndividual]">
                <sup title="{f:getDescriptionLabel('namedindividual')}" class="type-ni">ni</sup>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
	<!-- Edited Begin (Jan)
		Modified to show only the specific ToCs not the main ToC -->
    <xsl:template name="get.backlink">
        <xsl:param name="toc" select="''" as="xs:string*" tunnel="yes" />
        <xsl:param name="toc.string" select="''" as="xs:string*" tunnel="yes" />
        <!--<span class="backlink">
            <xsl:text> </xsl:text>
            <xsl:value-of select="f:getDescriptionLabel('backto')" />
            <xsl:text> </xsl:text>
            <a href="#toc"><xsl:value-of select="f:getDescriptionLabel('tocabbr')" /></a>
            <xsl:if test="$toc != '' and $toc.string != ''">
                <xsl:text> </xsl:text>
                <xsl:value-of select="f:getDescriptionLabel('or')" />
                <xsl:text> </xsl:text>
                <a href="#{$toc}">
                    <xsl:value-of select="$toc.string" />
                </a>
            </xsl:if>
        </span>-->
		<span class="backlink">
			<a href="#{$toc}">
				<!--<img src="{$static-files-location}arrow_top.png" alt="Back to the {$toc.string}" title="Back to the {$toc.string}"/>-->
				<span alt="Back to the {$toc.string}" title="Back to the {$toc.string}">▲</span>
			</a>
		</span>
    </xsl:template>
	<!-- Edited End (Jan)-->
	
	<!--<xsl:template name="get.backlink">
        <xsl:param name="toc" select="''" as="xs:string*" tunnel="yes" />
        <xsl:param name="toc.string" select="''" as="xs:string*" tunnel="yes" />
        <span class="backlink">
            <xsl:text> </xsl:text>
            <xsl:value-of select="f:getDescriptionLabel('backto')" />
            <xsl:text> </xsl:text>
            <a href="#toc"><xsl:value-of select="f:getDescriptionLabel('tocabbr')" /></a>
            <xsl:if test="$toc != '' and $toc.string != ''">
                <xsl:text> </xsl:text>
                <xsl:value-of select="f:getDescriptionLabel('or')" />
                <xsl:text> </xsl:text>
                <a href="#{$toc}">
                    <xsl:value-of select="$toc.string" />
                </a>
            </xsl:if>
        </span>
    </xsl:template>-->
    
    <xsl:template name="get.characteristics">
        <xsl:variable name="nodes" select="rdf:type[some $c in ('http://www.w3.org/2002/07/owl#FunctionalProperty', 'http://www.w3.org/2002/07/owl#InverseFunctionalProperty', 'http://www.w3.org/2002/07/owl#ReflexiveProperty', 'http://www.w3.org/2002/07/owl#IrreflexiveProperty', 'http://www.w3.org/2002/07/owl#SymmetricProperty', 'http://www.w3.org/2002/07/owl#AsymmetricProperty', 'http://www.w3.org/2002/07/owl#TransitiveProperty') satisfies @rdf:resource = $c]" as="element()*" />
        <xsl:if test="exists($nodes)">
            <p>
                <strong><xsl:value-of select="f:getDescriptionLabel('hascharacteristics')" />:</strong>
                <xsl:text> </xsl:text>
                <xsl:for-each select="$nodes">
                    <xsl:apply-templates select="." />
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </p>
        </xsl:if>
    </xsl:template>
    
    <!--
        input: un elemento tipicamente contenente solo testo
        output: un booleano che risponde se quell'elemento  quello giusto per la lingua considerata        
    -->
    <xsl:function name="f:isInLanguage" as="xs:boolean">
        <xsl:param name="el" as="element()" />
        <xsl:variable name="isRightLang" select="$el/@xml:lang = $lang" as="xs:boolean" />
        <xsl:variable name="isDefLang" select="$el/@xml:lang = $def-lang" as="xs:boolean" />
        
        <xsl:choose>
            <xsl:when test="
                (some $item in ($el/preceding-sibling::element()[name() = name($el)]) satisfies $item/@xml:lang = $lang) or
                (not($isRightLang) and
                    (
                        (some $item in ($el/following-sibling::element()[name() = name($el)]) satisfies $item/@xml:lang = $lang) or
                        (some $item in ($el/preceding-sibling::element()[name() = name($el)]) satisfies $item/@xml:lang = $def-lang) or
                        not($isDefLang) and
                            (
                                (some $item in ($el/following-sibling::element()[name() = name($el)]) satisfies $item/@xml:lang = $def-lang) or
                                exists($el/preceding-sibling::element()[name() = name($el)]))
                            ))">
                <xsl:value-of select="false()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:getPrefixFromIRI" as="xs:string*">
        <xsl:param name="iri" as="xs:string" />
        
        <xsl:variable name="iriNew" select="if (contains($iri,'#') or contains($iri,'/')) then $iri else concat(base-uri($root), $iri)" as="xs:string" />
        
        <xsl:variable name="ns" select="if (contains($iriNew,'#')) then substring($iriNew,1,f:string-first-index-of($iriNew,'#')) else substring($iriNew,1,f:string-last-index-of($iriNew,'/'))" as="xs:string" />
        
        <xsl:variable name="result" select="(for $prefix in in-scope-prefixes($rdf) return if (namespace-uri-for-prefix($prefix,$rdf) = $ns) then $prefix else ())" />
        <xsl:choose>
            <xsl:when test="count($result) > 1">
                <xsl:value-of select="$result[normalize-space() != ''][1]" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$result[1]" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:hasSubclasses" as="xs:boolean">
        <xsl:param name="el" as="element()" />
        <xsl:value-of select="exists($rdf/owl:Class[some $res in rdfs:subClassOf/@rdf:resource satisfies $res = $el/(@rdf:about|@rdf:ID)])" />
    </xsl:function>
    
    <xsl:function name="f:hasMembers" as="xs:boolean">
        <xsl:param name="el" as="element()" />
        <xsl:value-of select="exists($rdf/owl:NamedIndividual[some $res in rdf:type/@rdf:resource satisfies $res = $el/(@rdf:about|@rdf:ID)])" />
    </xsl:function>
    
    <xsl:function name="f:isInRange" as="xs:boolean">
        <xsl:param name="el" as="element()" />
        <xsl:value-of select="exists($rdf/(owl:ObjectProperty|owl:DatatypeProperty|owl:AnnotationProperty)[some $res in rdfs:range/@rdf:resource satisfies $res = $el/(@rdf:about|@rdf:ID)])" />
    </xsl:function>
    
    <xsl:function name="f:isInDomain" as="xs:boolean">
        <xsl:param name="el" as="element()" />
        <xsl:value-of select="exists($rdf/(owl:ObjectProperty|owl:DatatypeProperty|owl:AnnotationProperty)[some $res in rdfs:domain/@rdf:resource satisfies $res = $el/(@rdf:about|@rdf:ID)])" />
    </xsl:function>
    
    <xsl:function name="f:hasSubproperties" as="xs:boolean">
        <xsl:param name="el" as="element()" />
        <xsl:variable name="type" select="if ($el/self::owl:AnnotationProperty) then 'annotation' else 'property'" as="xs:string" />
        <xsl:value-of select="exists($rdf/(if ($type = 'property') then owl:DatatypeProperty | owl:ObjectProperty else owl:AnnotationProperty)[some $res in rdfs:subClassOf/@rdf:resource satisfies $res = $el/(@rdf:about|@rdf:ID)])" />
    </xsl:function>
    
    <xsl:function name="f:getType" as="xs:string?">
        <xsl:param name="element" as="element()" />
        <xsl:variable name="type" select="local-name($element)" as="xs:string" />
        <xsl:choose>
            <xsl:when test="$type = 'Class'">
                <xsl:value-of select="f:getDescriptionLabel('class')" />
            </xsl:when>
            <xsl:when test="$type = 'ObjectProperty'">
                <xsl:value-of select="f:getDescriptionLabel('objectproperty')" />
            </xsl:when>
            <xsl:when test="$type = 'DatatypeProperty'">
                <xsl:value-of select="f:getDescriptionLabel('dataproperty')" />
            </xsl:when>
            <xsl:when test="$type = 'AnnotationProperty'">
                <xsl:value-of select="f:getDescriptionLabel('annotationproperty')" />
            </xsl:when>
            <xsl:when test="$type = 'DataRange'">
                <xsl:value-of select="f:getDescriptionLabel('datarange')" />
            </xsl:when>
            <xsl:when test="$type = 'NamedIndividual'">
                <xsl:value-of select="f:getDescriptionLabel('namedindividual')" />
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:getDescriptionLabel" as="xs:string">
        <xsl:param name="inputlabel" as="xs:string" />
        <xsl:variable name="labelname" select="lower-case(replace($inputlabel,' +',''))" as="xs:string" />
        <xsl:variable name="label" as="xs:string">
            <xsl:variable name="label" select="normalize-space($labels//element()[lower-case(local-name()) = $labelname]/text())" as="xs:string?"/>
            <xsl:choose>
                <xsl:when test="$label">
                    <xsl:value-of select="$label" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space($default-labels//element()[lower-case(local-name()) = $labelname]/text())" />
                </xsl:otherwise>
            </xsl:choose>            
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$label">
                <xsl:value-of select="$label" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'[ERROR-LABEL]'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
