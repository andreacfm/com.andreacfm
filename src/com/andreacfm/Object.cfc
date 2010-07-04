<cfcomponent 
	output="false"
	name="Base class.">
	
	<!---private instance variables--->
	<cfset variables.instance = {} />

	<!---init--->
	<cffunction name="init" output="false" returntype="cfops.core.Object" hint="Return instance of object class.">
		<cfreturn this />	
	</cffunction>

	<!---getMemento--->
	<cffunction name="getMemento" output="false" returntype="any">
		<cfreturn variables.instance />
	</cffunction>

	<!---	validate	--->
	<cffunction name="validate" output="false" returntype="void" hint="Validate method called on an injected validator bean">
		<cfargument name="context" required="false" type="string" default="" />		
		<cfscript>
			var validator = getValidator();
			validator.validate(this,arguments.context);
		</cfscript>
	</cffunction>

	<!---	isValidObject	--->
	<cffunction name="isValidObject" output="false" returntype="boolean">
		<cfset var validator = getValidator() />
		<cfif validator.hasErrors()>
			<cfreturn false>
		</cfif>
		<cfreturn true />	
	</cffunction>

	<!---	geterrors	--->
	<cffunction name="geterrors" output="false" returntype="array">
		<cfreturn getValidator().getErrors() />
	</cffunction>

	<!---	resetErrors	--->
	<cffunction name="resetErrors" output="false" returntype="void">
		<cfreturn getValidator().reset() />
	</cffunction>
	
	<!---	populate	--->
	<cffunction name="populate" output="false" returntype="void" hint="Support method to populate the bean from a passed struct of values">
		<cfargument name="collection" required="false" default="#structNew()#" type="struct" />

		<cfscript>
			for(item in arguments.collection){
				if(structKeyExists(this,"set#item#")){
					evaluate( "set#item#( arguments.collection['#item#'])" );
				}
			}
		</cfscript>

	</cffunction>

	<!---	validator	--->
	<cffunction name="getvalidator" access="public" output="false" returntype="com.andreacfm.validate.Validator">
		<cfreturn variables.instance.validator/>
	</cffunction>
	<cffunction name="setvalidator" access="public" output="false" returntype="void">
		<cfargument name="validator" type="com.andreacfm.validate.Validator" required="true"/>
		<cfset variables.instance.validator = arguments.validator/>
	</cffunction>

	<!---getObjectId--->
	<cffunction name="getObjectId" returntype="string" output="false" hint="Return the identityHashCode of the java object underling the cfc instance.">
		<cfreturn createObject("java", "java.lang.System").identityHashCode(this)/>
	</cffunction>

	<!--- toStruct --->
	<cffunction name="toStruct" output="false" returntype="any">
		<cfset var result = duplicate(variables.instance)/>
		<cfloop collection="#result#" item="i">
			<cfif isArray(result[i]) and not arrayIsEmpty(result[i])>
				<cfloop from="1" to="#arraylen(result[i])#" index="ii">
					<cfif structkeyExists(result[i][ii],'getMemento')>
						<cfset result[i][ii] = result[i][ii].getMemento() />
					</cfif>
				</cfloop>	
			</cfif>
		</cfloop>
		<cfreturn result />
	</cffunction>

	<!---throw--->
	<cffunction name="Throw" returntype="void" output="no" access="public" >   
		<cfargument name="Message" type="string" required="false" default="" />
		<cfargument name="type" type="string" required="false" default="any" />  
		<cfargument name="extendedinfo" type="string" required="false" default="" />  
		<cfargument name="errorcode" type="string" required="false" default="001" />  		
		<cfthrow message="#arguments.Message#" type="#arguments.type#" extendedinfo="#Arguments.errorcode#" errorcode="#arguments.errorcode#"/> 
	</cffunction> 

</cfcomponent>