<cfcomponent output="false">
	
	<cfproperty name="errors" type="array"/>	
	
	<cfset variables.Tester = createObject('component','com.andreacfm.validate.Tester').init() />

	<!---init--->
	<cffunction name="init" output="false" returntype="com.andreacfm.validate.Validator">
		<cfreturn this />
	</cffunction>
		
	<!---	validate	--->
	<cffunction name="validate" output="false" returntype="void">
		<cfargument name="obj" required="true" type="com.andreacfm.validate.IValidatable"/>
		<cfargument name="method" required="false" type="string" default="" />
						
	</cffunction>
	
	<!--- Tester --->
	<cffunction name="getTester" returntype="com.andreacfm.validate.Tester">
		<cfreturn variables.Tester />
	</cffunction>
	

</cfcomponent>