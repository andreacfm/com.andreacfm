<!---
	Author: Cristian Costantini - cristian@millemultimedia.it
	Purpose: Manage list collection. Required Coldfusion 8
	License: http://www.gnu.org/licenses/gpl-3.0.html
	Copyright: (c) 2003 - 2009 - Cristian Costantini
	Version: 1.0 alpha 2
	--->

<cfcomponent extends="AbsCollection" output="false">

    <cffunction name="init" access="public" returntype="ListCollection">
        <cfargument name="collection" type="AbsCollection" required="false" />
        <cfset super.init( this ) />
        
        <cfif isDefined( 'arguments.collection' )>
	        <cfset addAll( arguments.collection ) />
        </cfif>
        
        <cfreturn this />
    </cffunction>
    
    <cffunction name="set" access="public" returntype="void">
        <cfargument name="i" type="numeric" required="true" />
        <cfargument name="value" type="any" required="true" />
        <cfset variables.instance[ arguments.i ] = arguments.value />
    </cffunction>
    
    <cffunction name="get" access="public" returntype="any">
        <cfargument name="i" type="numeric" required="true" />
        <cfreturn variables.instance[ arguments.i ] />
    </cffunction>
    
    <cffunction name="add" access="public" returntype="void">
        <cfargument name="value" type="any" required="true" />
        <cfset variables.instance.add( arguments.value )>
    </cffunction>
    
    <cffunction name="addAll" access="public" returntype="void">
        <cfargument name="collection" type="AbsCollection" required="false" />
        <cfset var iterator = arguments.collection.iterator() />
        
        <cfloop condition="#iterator.hasNext()#">
        
            <cfset add( iterator.next() ) />
        
        </cfloop>
        
    </cffunction>

</cfcomponent>