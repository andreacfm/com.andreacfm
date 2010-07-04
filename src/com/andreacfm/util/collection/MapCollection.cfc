<!---
	Author: Cristian Costantini - cristian@millemultimedia.it
	Purpose: Manage map collection. Required Coldfusion 8
	License: http://www.gnu.org/licenses/gpl-3.0.html
	Copyright: (c) 2003 - 2009 - Cristian Costantini
	Version: 1.0 alpha 2
	--->

<cfcomponent extends="AbsCollection" output="false">

    <cffunction name="init" access="public" returntype="MapCollection">
        <cfset super.init( this ) />
        <cfreturn this />
    </cffunction>
    
    <cffunction name="set" access="public" returntype="void">
        <cfargument name="key" type="string" required="true" />
        <cfargument name="value" type="any" required="true" />
        <cfset variables.instance[ arguments.key ] = arguments.value />
    </cffunction>
    
    <cffunction name="get" access="public" returntype="any">
        <cfargument name="key" type="string" required="true" />
        <cfreturn variables.instance[ arguments.key ] />
    </cffunction>

    <cffunction name="getAll" access="public" returntype="any">
        <cfreturn variables.instance />
    </cffunction>

    <cffunction name="setStruct" access="public" returntype="void">
    	<cfargument name="str" type="struct" required="true" />
		<cfset var i = "" />
		<cfloop collection="#arguments.str#" item="i">
			<cfset set(i,arguments.str[i]) />
		</cfloop>
   </cffunction>
    
    <cffunction name="containsKey" access="public" returntype="any">
        <cfargument name="key" type="string" required="true" />
        <cfreturn variables.instance.containsKey( arguments.key ) />
    </cffunction>
    
    <cffunction name="keySet" access="public" returntype="any">
        <cfreturn variables.instance.keySet() />
    </cffunction>

</cfcomponent>