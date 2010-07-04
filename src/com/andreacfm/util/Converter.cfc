<cfcomponent output="false" name="converter">

	<!---queryToXml--->
	<cffunction name="queryToXML" access="public" returntype="xml" output="false" hint="Return xml">
		<cfargument name="query" type="query" required="yes" />
		<cfargument name="root" type="string" required="no" default="recordset" />
		<cfargument name="elm" type="string" required="no" default="row" />
		<cfscript>
		var myQuery		= arguments.query ;
		var result		= XmlNew();
		var colCount	= 0 ;
		var colName		= arrayNew(1) ;
		var metaData	= "" ;
		var q	=	0 ;
		var i	=	0 ;
		
		metaData	=	myQuery.getMetaData() ;
		colCount	=	metadata.getColumnCount() ;
		colName	 	=	metadata.getColumnLabels() ;
			
		result.xmlRoot = XmlElemNew( result , arguments.root );				
		
		for( q = 1 ; q LTE myQuery.recordCount ; q = q + 1 ) {

			result.recordset.XmlChildren[q] = XmlElemNew( result , arguments.elm );
		
			for( i = 1 ; i LTE colCount ; i = i + 1 ) {
				
				
				result.recordset.row[q].XmlChildren[i] = XmlElemNew( result , colName[ i ] ) ;
				result.recordset.row[q].XmlChildren[i].XmlText = myQuery[colName[ i ]][ q ] ;
		
			}
		
		}
		</cfscript>
		<cfreturn result />
	</cffunction>

	<!---queryToArray--->
	<cffunction name="queryToArray" access="public" returntype="array" output="false" hint="Return array of struct" >
		<cfargument name="query" type="query" required="yes" />
		<cfscript>
		var myArray		=	arrayNew(1) ;
		var myStruct	=	structNew() ;
		var myQuery		=	arguments.query ;
		var colCount	=	0 ;
		var colName		=	arrayNew(1) ;
		var metaData	=	"" ;
		var q	=	0 ;
		var i	=	0 ;
		
		metaData	=	getMetaData(myQuery);
		colCount	=	arraylen(metaData);
		
		for( q = 1 ; q LTE myQuery.recordCount ; q = q + 1 ) {
		
			for( i = 1 ; i LTE colCount ; i = i + 1 ) {
			
				myStruct[ metadata[i].name ] = myQuery[metadata[i].name][ q ] ;
		
			}
		
			myArray[ q ] = myStruct ;
		
			myStruct = structNew() ;
		
		}
		</cfscript>
		<cfreturn myArray />
	</cffunction>

	<!---	queryToBean  --->
	<cffunction name="queryToBean" access="public" returntype="array" output="false" hint="Return array of bean" >
		<cfargument name="query" type="query" required="yes" />
		<cfargument name="class" type="string" required="true" />
		
		<cfscript>
		var myArray		=	arrayNew(1) ;
		var myQuery		=	arguments.query ;
		var myBean	=	"";
		var colCount	=	0 ;
		var colName		=	arrayNew(1) ;
		var metaData	=	"" ;
		var q	=	0 ;
		var i	=	0 ;
		
		metaData	=	getMetaData(myQuery);
		colCount	=	arraylen(metaData);
		
		for( q = 1 ; q LTE myQuery.recordCount ; q = q + 1 ) {
			
			myBean = createObject('component',arguments.class);
			
			for( i = 1 ; i LTE colCount ; i = i + 1 ) {

				if( StructKeyExists( myBean , 'Set#metadata[i].name#' ) ){

					try{
				
						Evaluate("myBean.Set#metadata[i].name#( myQuery[metadata[i].name][q])");
					
					}catch( any excp ){
					
					}
				
				}
		
			}
		
			myArray[ q ] = myBean ;		
		}
		</cfscript>
		
		<cfreturn myArray />
	</cffunction>

	<!---queryToStruct--->
	<cffunction name="queryToStruct" access="public" returntype="struct" output="false" hint="Return struct of array" >
		<cfargument name="query" type="query" required="yes" />
		<cfscript>
		var myArray		=	ArrayNew(1) ;
		var myStruct	=	StructNew() ;
		var myQuery		=	arguments.query ;
		var colCount	=	0 ;
		var colName		=	arrayNew(1) ;
		var metaData	=	"" ;
		var q	=	0 ;
		var i	=	0 ;
		
		metaData	=	myQuery.getMetaData() ;
		colCount	=	metadata.getColumnCount() ;
		colName	 	=	metadata.getColumnLabels() ;
		
		for( i = 1 ; i LTE colCount ; i = i + 1 ) {
		
			for( q = 1 ; q LTE myQuery.recordCount ; q = q + 1 ) {
		
				myArray[ q ] = Trim( myQuery[colName[ i ]][ q ] );
		
			}
		
			myStruct[ colName[ i ] ] =  myArray;
			
			myArray = ArrayNew(1) ;
		
		}
		</cfscript>
		<cfreturn myStruct />
	</cffunction>

	<!---arrayToQuery--->
	<cffunction name="arrayToQuery" access="public" returntype="query" output="false">
		<cfargument name="array" type="array" required="yes"/>
		<cfscript>
		var r					=	0;
		var c					=	0;
		var myArray			=	ArrayNew(1);
		var myStruct		=	StructNew();
		var myQuery		=	QueryNew( "" );
		var colName		=	ArrayNew(1);
		var colCount		=	0;
		var recCount		=	0;
		var columnList		=	"";
		// assegno i valori
		myArray				=	arguments.array;
		myStruct			=	myArray[1];
		colName				=	StructKeyArray( myStruct );
		colCount			=	ArrayLen( colName );
		columnList			=	ArrayToList( colName );
		recCount			=	ArrayLen( myArray );
		myQuery				=	QueryNew( columnList );
		// setto la query
		QueryAddRow( myQuery , recCount );
		// eseguo il ciclo
		for( r = 1 ; r LTE recCount ; r = r + 1 ) {
		
			for( c = 1 ; c LTE colCount ; c = c + 1 ) {
				// creo i record
				QuerySetCell( myQuery , colName[ c ] , myArray[ r ][colName[ c ] ] , r );
			
			}
			
		}
		</cfscript>
		<cfreturn myQuery />
	</cffunction>

	<!---bean2Query--->
	<cffunction name="bean2Query" access="public" returntype="query" output="no">
		<cfargument name="bean" type="array" required="yes" hint="required array of bean"/>
		<cfscript>
		var i = 0;
		var l = 0;
		var q = "";
		var colName = QueryNew('temp');
		var result = QueryNew('temp');
		var colList = "";
		var arrCount = ArrayLen( arguments.bean );
		var myBeanObj = arguments.bean[1];
		var myBeanMetadata = getMetadata( myBeanObj );
				
		q = arrayToQuery( myBeanMetadata.properties );
		colList = ValueList( q.name );
		result = QueryNew( colList );
		
		for( i = 1 ; i <= arrCount ; i++ ){
		
			QueryAddRow( result );
			
			for( l = 1 ; l <= ListLen( colList ) ; l++ ){
			
				colname = ListGetAt( colList , l , Chr(44) );
				
				QuerySetCell( result , colname , Evaluate( "arguments.bean[i].get#colname#()" ) ) ;
			
			}		
		
		}
		
		return result;
		</cfscript>
	</cffunction>

	<!---bean2array--->
	<cffunction name="bean2Array" access="public" returntype="array" output="no">
		<cfargument name="bean" type="array" required="yes" hint="required array of bean"/>
		<cfreturn queryToArray( bean2Query( arguments.bean ) )/>
	</cffunction>

	<!---XmltoStruct--->
	<cffunction name="XmlToStruct" access="public" returntype="struct" output="false"
				hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
	<cfargument name="xmlNode" type="string" required="true" />
	<cfargument name="str" type="struct" required="true" />
	<!---Setup local variables for recurse: --->
	<cfset var i = 0 />
	<cfset var axml = arguments.xmlNode />
	<cfset var astr = arguments.str />
	<cfset var n = "" />
	<cfset var tmpContainer = "" />
	<!--- For each children of context node: --->
	<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
		<!--- Read XML node name without namespace: --->
		<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
		<!--- If key with that name exists within output struct ... --->
		<cfif structKeyExists(astr, n)>
			<!--- ... and is not an array... --->
			<cfif not isArray(astr[n])>
				<!--- ... get this item into temp variable, ... --->
				<cfset tmpContainer = astr[n] />
				<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
				<cfset astr[n] = arrayNew(1) />
				<!--- ... and reassing temp item as a first element of new array: --->
				<cfset astr[n][1] = tmpContainer />
				<!---
					If context child node has child nodes (which means it will be complex type): --->
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n][arrayLen(astr[n])+1] = xmltostruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<!--- else: assign node value as last element of array: --->
					<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
				</cfif>
			<cfelse>
				<!--- Item is already an array: --->
				<!---
					If context child node has child nodes (which means it will be complex type): --->
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n][arrayLen(astr[n])+1] = xmltostruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<!--- else: assign node value as last element of array: --->
					<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
				</cfif>
			</cfif>
		<cfelse>
			<!---
				This is not a struct. This may be first tag with some name.
				This may also be one and only tag with this name.
			--->
			<!---
					If context child node has child nodes (which means it will be complex type): --->
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
				<!--- recurse call: get complex item: --->
				<cfset astr[n] = xmltostruct(axml.XmlChildren[i], structNew()) />
			<cfelse>
				<!--- else: assign node value as last element of array: --->
				<!--- if there are any attributes on this element--->
				<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
					<!--- assign the text --->
					<cfset astr[n] = axml.XmlChildren[i].XmlText />
						<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
					 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
					 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
						 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
							 <!--- remove any namespace attributes--->
							<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
						 </cfif>
					 </cfloop>
					 <!--- if there are any atributes left, append them to the response--->
					 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
						 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
					</cfif>
				<cfelse>
					 <cfset astr[n] = axml.XmlChildren[i].XmlText />
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<!--- return struct: --->
	<cfreturn astr />
</cffunction>

	<!---structToObj--->
	<cffunction name="structToObj" output="false" returntype="any" description="modify the object with passed struct matches">
		<cfargument name="class" required="true" type="string" />		
		<cfargument name="str" required="true" type="struct" />
		<cfargument name="initObject" required="false" type="boolean" default="false" />		
		<cfargument name="hasSetMethods" required="false" type="boolean" default="true">
		
		<cfset var obj = createObject("component","#arguments.class#")/>
		<cfset var meta = getMetaData(obj) />
		<cfset var prop = meta.properties />

		<cfif arguments.initObject>
			<cfset obj = obj.init() />
		</cfif>
		
		<cfloop from="1" to="#arrayLen(prop)#" index="i">
			<cfif structkeyExists(arguments.str,"#prop[i].name#")>
				<cfset key = "#prop[i].name#" />
				<cfset value = arguments.str[key] />
				<cfif arguments.hasSetMethods>
					<cfset evaluate("obj.set#key#(value)") />
				<cfelse>
					<cfset obj[key] = value>	
				</cfif>	
			</cfif>
		</cfloop>

		<cfreturn obj>
</cffunction>
	
</cfcomponent>