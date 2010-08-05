<cfcomponent
 extends="com.andreacfm.Object"
 implements="com.andreacfm.validate.IValidatable">

	<cfset variables.errors = createObject('java','java.util.ArrayList').init() />
	<cfset variables.isAlwaysValid = false />
	
	<!--- 
		Set to true by the gateway if generated in a sql context where caching wa set to true.
		Does not gurantee that data has been cached.
		Used to pass the cache value down to the composite chain.
	--->
	<cfset this.cache = false />

	<!---init--->
	<cffunction name="init" output="false" returntype="com.andreacfm.datax.Model">
		<cfargument name="dao" required="true" type="com.andreacfm.datax.Dao"/>
		<cfargument name="validator" required="false" type="com.andreacfm.validate.Validator" default="#createObject('component','com.andreacfm.validate.Validator').init()#"/>				
		<cfscript>
			setDao(arguments.dao);
			setValidator(arguments.validator);
			return this;		
		</cfscript>
	</cffunction>

	<!-----------------------------------------------PUBLIC --------------------------------------------------------------->

	<!---	create	--->
	<cffunction name="create" output="false" returntype="com.andreacfm.util.Message">
		<cfscript>
			var dao = getDao();
			var result = dao.create(this);
			return result;
		</cfscript>	
	</cffunction>

	<!---	update	--->
	<cffunction name="update" output="false" returntype="com.andreacfm.util.Message">
		<cfscript>
			var dao = getDao();
			var result = dao.update(this);
			return result;
		</cfscript>	
	</cffunction>

	<!---	delete	--->
	<cffunction name="delete" output="false" returntype="com.andreacfm.util.Message">
		<cfscript>
			var dao = getDao();
			var result = dao.delete(this);
			return result;
		</cfscript>	
	</cffunction>

	<!---	commit	--->
	<cffunction name="commit" output="false" returntype="com.andreacfm.util.Message">
		<cfscript>
			var dao = getDao();
			if(evaluate("this.get#dao.getModelConfig().getpk()#()") eq 0){
				return this.create();				
			}else{
				return this.update();
			}
		</cfscript>	
	</cffunction>

	<!---	validate	--->
	<cffunction name="validate" output="false" returntype="void" hint="Validate method called on an injected validator bean">
		<cfargument name="context" required="false" type="string" default="" />		
		<cfscript>
			var validator = getValidator();
			if(not variables.isAlwaysValid){
				validator.validate(this,arguments.context);
			}
		</cfscript>
	</cffunction>

	<!--- isAlwaysValid --->
	<cffunction name="isAlwaysValid" output="false" returntype="boolean">
		<cfreturn variables.isAlwaysValid />	
	</cffunction>
	
	<!---	skipValidation	--->
	<cffunction name="skipValidation" output="false" returntype="void">
		<cfargument name="value" type="boolean" required="true" />
		<cfset variables.isAlwaysValid = value />
	</cffunction>
	
	<!---	isValidObject	--->
	<cffunction name="isValidObject" output="false" returntype="boolean">
		<cfif hasErrors()>
			<cfreturn false>
		</cfif>
		<cfreturn true />	
	</cffunction>

    <!---   errors   --->
	<cffunction name="geterrors" access="public" output="false" returntype="array">
		<cfreturn variables.errors/>
	</cffunction>
	<cffunction name="seterrors" access="public" output="false" returntype="void">
		<cfargument name="errors" type="array" required="true"/>
		<cfset variables.errors = arguments.errors/>
	</cffunction>

	<!---  hasErrors  --->
	<cffunction name="hasErrors" output="false" returntype="boolean">
		<cfset var result = true />
		<cfset var errors = getErrors() />
		<cfif arrayIsEmpty(errors)>
			<cfset result = false />
		</cfif>		
		<cfreturn result />
	</cffunction>
	
	<!--- resetErrors --->
	<cffunction name="resetErrors" returntype="void">	
		<cfset variables.errors.clear() />
	</cffunction>
		
	<!---  addError  --->
	<cffunction name="addError" output="false" returntype="void">
		<cfargument name="error" type="string" required="true" />
		<cfset variables.errors.add(error)>
	</cffunction>

	<!---	validator	--->
	<cffunction name="getvalidator" access="public" output="false" returntype="com.andreacfm.validate.Validator">
		<cfreturn variables.validator/>
	</cffunction>
	<cffunction name="setvalidator" access="public" output="false" returntype="void">
		<cfargument name="validator" type="com.andreacfm.validate.Validator" required="true"/>
		<cfset variables.validator = arguments.validator/>
	</cffunction>

	<!---	dao	--->
	<cffunction name="getdao" access="public" output="false" returntype="com.andreacfm.datax.Dao">
		<cfreturn variables.dao/>
	</cffunction>
	<cffunction name="setdao" access="public" output="false" returntype="void">
		<cfargument name="dao" type="com.andreacfm.datax.dao" required="true"/>
		<cfset variables.dao = arguments.dao/>
	</cffunction>

	<!----	beanFactory	--->
	<cffunction name="getBeanFactory" access="public" returntype="any" output="false" hint="Return the beanFactory instance">
		<cfreturn variables.beanFactory />
	</cffunction>		
	<cffunction name="setBeanFactory" access="public" returntype="void" output="false" hint="Inject a beanFactory reference.">
		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true" />
		<cfset variables.beanFactory = arguments.beanFactory />
	</cffunction>

</cfcomponent>
