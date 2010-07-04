<cfcomponent extends="com.andreacfm.Object">
	
	<cfset variables.instance.loggers = {} />

	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.logging.LogManager">
		<cfargument name="loggers" type="array" required="false">
		<cfargument name="autowire" type="boolean" required="false" default="false">
		
		<cfset var obj = "" />
			
		<cfloop array="#loggers#" index="args">
			<cfset obj = createObject('component','com.andreacfm.logging.Logger').init(argumentCollection=args) />
			<cfif arguments.autowire>
				<cfset getBeanFactory().getBean('beanInjector').autowire(obj) />
			</cfif>
			<cfset addLogger(obj) />
		</cfloop>
				
		<cfreturn this/>
	</cffunction>

    <!--- Logger--->
    <cffunction name="addLogger" access="public" returntype="void">
		<cfargument name="Logger" type="com.andreacfm.logging.Logger" required="true"/>
		<cfset variables.instance.loggers[arguments.Logger.getId()] = arguments.Logger />
	</cffunction> 

	<cffunction name="getLogger" access="public" returntype="com.andreacfm.logging.Logger">
		<cfargument name="id" required="true" type="String"/>
		<cfreturn variables.instance.loggers[arguments.id]/>
	</cffunction>

	<!----	beanFactory	--->
	<cffunction name="getBeanFactory" access="public" returntype="any" output="false" hint="Return the beanFactory instance">
		<cfreturn variables.instance.beanFactory />
	</cffunction>		
	<cffunction name="setBeanFactory" access="public" returntype="void" output="false" hint="Inject a beanFactory reference.">
		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true" />
		<cfset variables.instance.beanFactory = arguments.beanFactory />
	</cffunction>

</cfcomponent>