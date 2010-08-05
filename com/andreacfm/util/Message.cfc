<!--- error / warning / info / question / ok --->
﻿<cfcomponent
	 name="Message"
	 extends="com.andreacfm.Object">

	<cfproperty name="text" type="string"/>
	<cfproperty name="type" type="string"/>	
	<cfproperty name="status" type="boolean"/>
	<cfproperty name="data" type="any" />
	<cfproperty name="success" type="string" />

	<!---------------------------CONSTRUCTOR------------------------------------------------------->
	<cffunction name="init" output="false" returntype="com.andreacfm.util.message">
	
		<cfset variables.instance['status'] = true />
		<!--- added for ext js compatibility // managed by status getter setter--->
		<cfset variables.instance['success'] = true />
		<cfset variables.instance['text'] = "" />
		<cfset variables.instance['type'] = "ok" />
		<cfset variables.instance['data'] = "" />
		
		<cfreturn this/>
	</cffunction>

	<!------------------------------------			PUBLIC   		----------------------------------------------------->

	<!---text--->
	<cffunction name="getText" access="public" output="false" returntype="string">
		<cfreturn variables.instance['text'] />
	</cffunction>
	<cffunction name="setText" access="public" output="false" returntype="void">
		<cfargument name="text" type="string" required="true" />
		<cfset variables.instance['text'] = arguments['text'] />
	</cffunction>

	<!---type--->
	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfreturn variables.instance['type'] />
	</cffunction>
	<cffunction name="setType" access="public" output="false" returntype="void">
		<cfargument name="type" type="string" required="true" />
		<cfset variables.instance['type'] = arguments['type'] />
	</cffunction>

	<!---status--->
	<cffunction name="getStatus" access="public" output="false" returntype="boolean">
		<cfreturn variables.instance['status'] />
	</cffunction>
	<cffunction name="setStatus" access="public" output="false" returntype="void">
		<cfargument name="status" type="boolean" required="true" />
		<cfset variables.instance['status'] = arguments['status'] />
		<cfset variables.instance['success'] = arguments['status'] />
	</cffunction>

	<!---data--->
	<cffunction name="getData" access="public" output="false" returntype="any">
		<cfreturn variables.instance['data'] />
	</cffunction>
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset variables.instance['data'] = arguments['data'] />
	</cffunction>

</cfcomponent>