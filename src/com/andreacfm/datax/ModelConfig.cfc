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

	<cfset variables.instance.id = arguments.id />
	<cfset variables.instance.table = arguments.table />
	<cfset variables.instance.beanClass = arguments.beanClass />
	<cfset variables.instance.defaultOrderBy = arguments.defaultOrderBy />
	<cfset variables.instance.pk = arguments.pk />
	<cfset variables.instance.skipfields = arguments.skipfields />
	<cfset variables.instance.defaults = arguments.defaults />
	<cfset variables.instance.decorator = arguments.decorator />
	<cfset variables.instance.ignoreUpdate = arguments.ignoreUpdate />

	<cfreturn this/>		
</cffunction>

	<!---	id	--->
	<cffunction name="getid" access="public" output="false" returntype="string">
		<cfreturn variables.instance.id/>
	</cffunction>

	<!---	table	--->
	<cffunction name="gettable" access="public" output="false" returntype="string">
		<cfreturn variables.instance.table/>
	</cffunction>

	<!---	decorator	--->
	<cffunction name="getdecorator" access="public" output="false" returntype="string">
		<cfreturn variables.instance.decorator/>
	</cffunction>

	<!---	beanClass	--->
	<cffunction name="getbeanClass" access="public" output="false" returntype="string">
		<cfreturn variables.instance.beanClass/>
	</cffunction>
	<cffunction name="setbeanClass" access="public" output="false" returntype="void">
		<cfargument name="beanClass" type="string" required="true"/>
		<cfset variables.instance.beanClass = arguments.beanClass/>
	</cffunction>

	<!---	deafultOrderBy	--->
	<cffunction name="getdefaultOrderBy" access="public" output="false" returntype="string">
		<cfreturn variables.instance.defaultOrderBy/>
	</cffunction>

	<!---	pk	--->
	<cffunction name="getpk" access="public" output="false" returntype="string">
		<cfreturn variables.instance.pk/>
	</cffunction>

	<!---	skipfields	--->
	<cffunction name="getskipfields" access="public" output="false" returntype="string">
		<cfreturn variables.instance.skipfields/>
	</cffunction>

	<!---	defaults	--->
	<cffunction name="getdefaults" access="public" output="false" returntype="struct">
		<cfreturn variables.instance.defaults/>
	</cffunction>

	<!---	ignoreUpdate	--->
	<cffunction name="getignoreUpdate" access="public" output="false" returntype="string">
		<cfreturn variables.instance.ignoreUpdate/>
	</cffunction>

</cfcomponent>
