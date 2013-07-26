<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:emi="http://cuba.coventry.ac.uk/correspondence_corpora/schema"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xd:doc id="Fairman-List.xsl">
        <xd:desc>
            <xd:p>An XSLT Stylesheet for creating a personography as well as a catalogue of letters from Tony Fairman's "Maidstone Fœtus"</xd:p>
            <xd:p><xd:b>Author:</xd:b> Peter Stadler </xd:p>
            <xd:p><xd:b>Version:</xd:b> 1.0 </xd:p>
        </xd:desc>
        <xd:param name="personID-pictureString">The picture string for the to be created person IDs</xd:param>
        <xd:param name="letterID-pictureString">The picture string for the to be created letter IDs</xd:param>
    </xd:doc>
    
    <!-- Picture Strings for person and letter IDs -->
    <xsl:param name="personID-pictureString" as="xs:string" select="'EP00000'"/>
    <xsl:param name="letterID-pictureString" as="xs:string" select="'EL00000'"/>

    <xsl:strip-space elements="*"/>
    <xsl:output exclude-result-prefixes="tei" encoding="UTF-8" indent="yes" omit-xml-declaration="no" method="xml"/>
    
    <xsl:key name="typeOfCopy" match="id('typeOfCopy')//tei:item" use="tei:label"/>
    <xsl:key name="countyCodes" match="id('countyCodes')//tei:item" use="tei:label"/>
    
    <!-- Function for generating IDs by simply applying a running number to the picture strings above -->
    <xsl:function name="emi:generateID" as="xs:string">
        <xsl:param name="runningNumber" as="xs:integer"/>
        <xsl:param name="picture" as="xs:string"/>
        <xsl:value-of select="format-number($runningNumber, $picture)"/>
    </xsl:function>
    
    <xsl:function name="emi:checkPersonID" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:value-of select="$personography//tei:persName[.=normalize-space($name)]/parent::tei:person/data(@xml:id)"/>
    </xsl:function>
    
    <xsl:function name="emi:parseDate" as="xs:date?">
        <xsl:param name="string" as="xs:string"/>
        <xsl:variable name="stringTokens" select="tokenize(normalize-space($string), '\s+')"/>
        <xsl:variable name="months" select="(
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')" 
            as="xs:string+"/>
        <xsl:variable name="year">
            <xsl:if test="matches($stringTokens[1], '^\d{4}$')">
                <xsl:value-of select="$stringTokens[1]"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="month">
            <xsl:if test="$stringTokens[2] = $months">
                <xsl:value-of select="format-number(index-of($months, $stringTokens[2]), '00')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="day">
            <xsl:if test="matches($stringTokens[3], '^\d{1,2}$')">
                <xsl:value-of select="format-number(number($stringTokens[3]), '00')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="string-join(($year, $month, $day), '-') castable as xs:date">
            <xsl:value-of select="string-join(($year, $month, $day), '-') cast as xs:date"/>
        </xsl:if>
    </xsl:function>
    
    <!-- Creating the personography in memory -->
    <xsl:variable name="personography" as="element(tei:listPerson)">
        <xsl:element name="listPerson">
            <xsl:for-each-group select="id('completeList')/tei:table/tei:row" group-by="normalize-space(tei:cell[6])">
                <xsl:element name="person">
                    <xsl:attribute name="xml:id" select="emi:generateID(position(), $personID-pictureString)"/>
                    <xsl:element name="persName">
                        <xsl:attribute name="type" select="'reg'"/>
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:element>
                    <xsl:element name="sex">
                        <xsl:choose>
                            <!-- IN WRITER: If the writer’s name is in bold, she is female -->
                            <xsl:when test="current-group()[1]/tei:cell[6]/tei:hi[@rend='bold']">
                                <xsl:value-of select="'f'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'m'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <!-- There should be only one residence for each writer, but who knows?! -->
                    <xsl:for-each-group select="." group-by="normalize-space(tei:cell[3])">
                        <xsl:element name="residence">
                            <xsl:element name="settlement">
                                <xsl:value-of select="current-grouping-key()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each-group>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:variable>
    
    <!--
        ********************
        Begin main templates
        ********************
    -->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:copy>
            <xsl:namespace name="emi" select="'http://cuba.coventry.ac.uk/correspondence_corpora/schema'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader | tei:text">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:back"/>
    
    <xsl:template match="tei:body">
        <xsl:copy>
            <xsl:element name="div">
                <xsl:attribute name="xml:id" select="'personography'"/>
                <xsl:element name="head">Personography</xsl:element>
                <xsl:copy-of select="$personography"/>
            </xsl:element>
            <xsl:element name="div">
                <xsl:attribute name="xml:id" select="'letter-list'"/>
                <xsl:element name="head">List of letters</xsl:element>
                <xsl:apply-templates select="id('completeList')/tei:table[6]"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- Transforming the TEI header -->
    <!--<xsl:template match="tei:teiHeader">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>-->
    
    <xsl:template match="tei:fileDesc">
        <xsl:copy>
            <xsl:copy-of select="tei:titleStmt"/>
            <xsl:element name="editionStmt">
                <xsl:element name="edition">
                    <xsl:text>Second, transformed version of the original list</xsl:text>
                </xsl:element>
            </xsl:element>
            <xsl:element name="publicationStmt">
                <xsl:element name="availability">
                    <xsl:attribute name="status" select="'restricted'"/>
                    <xsl:element name="p">
                        <xsl:text>This work is licensed under a </xsl:text>
                        <xsl:element name="ref">
                            <xsl:attribute name="type" select="'license'"/>
                            <xsl:attribute name="target" select="'http://creativecommons.org/licenses/by/3.0/'"/>
                            <xsl:text>Creative Commons Attribution 3.0 Unported License (CC BY 3.0)</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:element name="sourceDesc">
                <xsl:element name="p">
                    <xsl:text>Transformed from Fairman-List.xml</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:encodingDesc">
        <xsl:copy>
            <xsl:element name="appInfo">
                <xsl:element name="application">
                    <xsl:attribute name="ident" select="'Fairman-List.xsl'"/>
                    <xsl:attribute name="version" select="'1.0'"/>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:element name="change">
                <xsl:attribute name="when" select="current-date()"/>
                <xsl:attribute name="who" select="'PS'"/>
                <xsl:text>Transformed from Fairman-List.xml</xsl:text>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- Transforming each table as distinct archive -->
    <xsl:template match="tei:table">
        <xsl:variable name="repository" select="preceding-sibling::tei:p[matches(., '-/-')][1]" as="element(tei:p)"/>
        <xsl:variable name="districtCode" as="xs:string">
            <xsl:if test="matches($repository, '[A-Z]{2}')">
                <xsl:analyze-string select="$repository" regex="([A-Z]{{2}})">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="repository" select="normalize-space(substring-before($repository,':'))" tunnel="yes"/>
            <xsl:with-param name="districtCode" select="$districtCode" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Each row holds the description of one letter -->
    <xsl:template match="tei:row">
        <xsl:param name="repository" as="xs:string?" tunnel="yes"/>
        <xsl:param name="districtCode" as="xs:string" tunnel="yes"/>
        <xsl:variable name="date" select="normalize-space(tei:cell[2])"/>
        <xsl:variable name="normalized-date" select="emi:parseDate($date)" as="xs:date?"/>
        <xsl:variable name="sender" select="normalize-space(tei:cell[6])"/>
        <xsl:variable name="senderID" select="emi:checkPersonID($sender)"/>
        <xsl:variable name="placeAddressee" select="normalize-space(tei:cell[3])"/>
        <xsl:variable name="placeSender" select="normalize-space(tei:cell[4])"/>
        <xsl:variable name="idno" select="normalize-space(tei:cell[5])"/>
        <xsl:variable name="runningNumber" select="count(preceding::tei:row)"/>
        <xsl:element name="div">
            <xsl:attribute name="xml:id" select="emi:generateID($runningNumber, $letterID-pictureString)"/>
            
            <!-- Creating correspondence description -->
            <xsl:element name="emi:correspDesc">
                <xsl:element name="emi:sender">
                    <xsl:element name="persName">
                        <xsl:if test="exists($senderID)">
                            <xsl:attribute name="ref" select="$senderID"/>
                        </xsl:if>
                        <xsl:value-of select="$sender"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="emi:addressee">
                    <xsl:element name="name">
                        <xsl:value-of select="concat('Parish ', $placeAddressee, ' (', $districtCode, ')')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="emi:placeSender">
                    <xsl:element name="placeName">
                        <xsl:value-of select="$placeSender"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="emi:placeAddressee">
                    <xsl:element name="placeName">
                        <xsl:value-of select="$placeAddressee"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="emi:dateSender">
                    <xsl:element name="date">
                        <xsl:if test="exists($normalized-date)">
                            <xsl:attribute name="when" select="$normalized-date"/>
                        </xsl:if>
                        <xsl:value-of select="$date"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- Creating manuscript description -->
            <xsl:element name="msDesc">
                <xsl:element name="msIdentifier">
                    <xsl:element name="country">
                        <xsl:text>United Kingdom</xsl:text>
                    </xsl:element>
                    <xsl:element name="region">
                        <xsl:choose>
                            <xsl:when test="matches(key('countyCodes', $districtCode)/tei:desc, '\+')">
                                <xsl:attribute name="n" select="'ArchiveWhichNumbersLettersIndividually'"/>
                                <xsl:value-of select="normalize-space(substring-before(key('countyCodes', $districtCode)/tei:desc, '+'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(key('countyCodes', $districtCode)/tei:desc)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:element name="repository">
                        <xsl:value-of select="$repository"/>
                    </xsl:element>
                    <xsl:element name="idno">
                        <xsl:value-of select="$idno"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>