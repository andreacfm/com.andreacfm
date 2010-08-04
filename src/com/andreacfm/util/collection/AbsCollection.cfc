<!---
	Author: Cristian Costantini - cristian@millemultimedia.it
	Purpose: Manage collection. Required Coldfusion 8
	License: http://www.gnu.org/licenses/gpl-3.0.html
	Copyright: (c) 2003 - 2009 - Cristian Costantini
	Version: 1.0 alpha 2
	--->

<cfcomponent output="false">
    
    <cffunction name="init" access="private" returntype="AbsCollection" output="false">
        <cfargument name="collectionType" type="AbsCollection" required="true" hint="Map or List collection" />
        <cfscript>
        var colType = listLast( getMetaData( arguments.collectionType ).name, '.' );
        
        variables.instance = createObject( 'component', 'CollectionFactory' ).init().createCollection( colType );
        </cfscript>
        <cfreturn this />
    </cffunction>
    
    <cffunction name="set" access="public" returntype="void">
        <cfabort showerror="Abstract !">
    </cffunction>
    
    <cffunction name="get" access="public" returntype="any">
        <cfabort showerror="Abstract !">
    </cffunction>
    
    <cffunction name="add" access="public" returntype="void">
        <cfabort showerror="Abstract !">
    </cffunction>
    
    <cffunction name="remove" access="public" returntype="boolean">
        <cfargument name="i" type="any" required="true" />
        <cfreturn variables.remove(arguments.i) />
    </cffunction>
    
    <cffunction name="clear" access="public" returntype="void">
        <cfreturn variables.clear() />
    </cffunction>
    
    <cffunction name="contains" access="public" returntype="boolean">
        <cfargument name="value" type="Any" required="true" />

		<cfif structKeyExists(server,'railo')>
			<cfreturn variables.containsKey( arguments.value ) />
		</cfif>	

        <cfreturn variables.contains( arguments.value ) />

    </cffunction>
    
    <cffunction name="isEmpty" access="public" returntype="boolean">
        <cfreturn variables.isEmpty() />
    </cffunction>
    
    <cffunction name="iterator" access="public" returntype="Any">
        <cfset var iterator = "" />
        
		<cfif structKeyExists(server,'railo')>
		
			<cfreturn variables.Iterator() />
		
		</cfif>	
        
		<cfif isStruct( variables.instance )>
            
			<cfset iterator = variables.valuesIterator()/>
        
        <cfelseif isArray( variables.instance )>
        
            <cfset iterator = variables.listIterator()/>
        
        </cfif>
        
        <cfreturn iterator />
    </cffunction>
    
    <cffunction name="size" access="public" returntype="numeric">
        <cfreturn variables.size() />
    </cffunction>
    
     <cffunction name="clone" access="public" returntype="any">
        <cfreturn variables.clone() />
    </cffunction>
    
    <cffunction name="_toString" access="public" returntype="string">
        <cfreturn variables.toString() />
    </cffunction>
    

</cfcomponent>