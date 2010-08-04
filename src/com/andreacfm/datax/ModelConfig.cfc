<cfcomponent 
	name="dataSettingsBean"
	output="false">

<cffunction name="init" output="false" returntype="com.andreacfm.datax.ModelConfig">	
	<cfargument name="id" required="false" type="string" default="">
	<cfargument name="table" required="false" type="string" default="">
	<cfargument name="beanClass" required="false" type="string" default="">
	<cfargument name="defaultOrderBy" required="false" type="string" default="">
	<cfargument name="pk" required="false" type="string" default="">
	<cfargument name="skipfields" required="false" type="string" default="">		
	<cfargument name="defaults" required="false" type="struct" default="#structNew()#" />
	<cfargument name="decorator" required="false" type="String" default="" />
	<cfargument name="ignoreUpdate" required="false" type="String" default="" />

	<cfset variables.id = arguments.id />
	<cfset variables.table = arguments.table />
	<cfset variables.beanClass = arguments.beanClass />
	<cfset variables.defaultOrderBy = arguments.defaultOrderBy />
	<cfset variables.pk = arguments.pk />
	<cfset variables.skipfields = arguments.skipfields />
	<cfset variables.defaults = arguments.defaults />
	<cfset variables.decorator = arguments.decorator />
	<cfset variables.ignoreUpdate = arguments.ignoreUpdate />

	<cfreturn this/>		
</cffunction>

	<!---	id	--->
	<cffunction name="getid" access="public" output="false" returntype="string">
		<cfreturn variables.id/>
	</cffunction>

	<!---	table	--->
	<cffunction name="gettable" access="public" output="false" returntype="string">
		<cfreturn variables.table/>
	</cffunction>

	<!---	decorator	--->
	<cffunction name="getdecorator" access="public" output="false" returntype="string">
		<cfreturn variables.decorator/>
	</cffunction>

	<!---	beanClass	--->
	<cffunction name="getbeanClass" access="public" output="false" returntype="string">
		<cfreturn variables.beanClass/>
	</cffunction>
	<cffunction name="setbeanClass" access="public" output="false" returntype="void">
		<cfargument name="beanClass" type="string" required="true"/>
		<cfset variables.beanClass = arguments.beanClass/>
	</cffunction>

	<!---	deafultOrderBy	--->
	<cffunction name="getdefaultOrderBy" access="public" output="false" returntype="string">
		<cfreturn variables.defaultOrderBy/>
	</cffunction>

	<!---	pk	--->
	<cffunction name="getpk" access="public" output="false" returntype="string">
		<cfreturn variables.pk/>
	</cffunction>

	<!---	skipfields	--->
	<cffunction name="getskipfields" access="public" output="false" returntype="string">
		<cfreturn variables.skipfields/>
	</cffunction>

	<!---	defaults	--->
	<cffunction name="getdefaults" access="public" output="false" returntype="struct">
		<cfreturn variables.defaults/>
	</cffunction>

	<!---	ignoreUpdate	--->
	<cffunction name="getignoreUpdate" access="public" output="false" returntype="string">
		<cfreturn variables.ignoreUpdate/>
	</cffunction>

</cfcomponent>
