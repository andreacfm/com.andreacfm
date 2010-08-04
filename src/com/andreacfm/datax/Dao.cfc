<cfcomponent 
	output="false"
	name="Dao"	 
	hint="Dao base class">

	<!---constructor--->		
	<cffunction name="init" description="initialize the object settings struct" output="false" returntype="com.andreacfm.datax.dao">	
		<cfargument name="ModelConfig" required="true" type="com.andreacfm.datax.ModelConfig" />
		<cfargument name="dataMgr" required="true" type="com.andreacfm.datax.dataMgr.dataMgr" />
		<cfargument name="EventManager" required="true" type="EventManager.EventManager" />		
		<cfscript>
			variables.ModelConfig = arguments.ModelConfig;
			variables.dataMgr = arguments.dataMgr;
			variables.EventManager = arguments.EventManager;
		</cfscript>
	<cfreturn this/>	
	</cffunction>

	<!-----------------------------------------  PUBLIC    ---------------------------------------------------------------->

	<!---create new record--->	
	<cffunction name="create" access="public" output="false" returntype="com.andreacfm.util.Message">
		<cfargument name="bean" type="com.andreacfm.datax.Model" required="true">
			
			<cfset var result = getMessage() />
			<cfset var savedRecord = "" />
			<cfset var dataMgr = getDataMgr() />
			<cfset var d = {} />
			<cfset var inst = bean.getMemento() />
					
 			<cftry>

				<cfif not bean.isAlwaysValid()>
					<cfset bean.validate("create")/>
				</cfif>

				<!--- remove complex values from the struct passed to dataMgr --->
				<cfset stripComplexValues(d,inst) />
				
				<cfif bean.isValidObject()>
					<cfset beforeCreate(bean) />
					<cfset savedRecord = dataMgr.saveRecord(getModelConfig().getTable(),d) />
					<cfset evaluate("bean.set#getModelConfig().getpk()#(savedRecord)") />
					<cfset afterCreate(bean) />
				<cfelse>
					<cfset result.setStatus(false) />
					<cfset result.setData(bean.getErrors()) />
					<cfset onInvalidBean(arguments.bean) />
					<cfreturn result />
				</cfif>
			
				<cfcatch type="any">
				 	<cfset onError(bean,cfcatch) />
					<cfthrow type="com.andreacfm.datax.createRecordExeption" message="#cfcatch.message#" />						
				</cfcatch>

			</cftry>

			<cfset result.setData(savedRecord)>
		<cfreturn result />
	</cffunction>
	
	<!---delete record--->	
	<cffunction name="delete" access="public" output="false" returntype="com.andreacfm.util.Message">
		<cfargument name="bean" type="com.andreacfm.datax.Model" required="true">
			
		<cfset var result = getMessage() />
		<cfset var dataMgr = getDataMgr() />
		<cfset var instance = bean.getMemento() />
		<cfset var data = {} />
		<cfset data["#getModelConfig().getpk()#"] = instance[getModelConfig().getpk()] />
				
			<cftry>
				
				<cfset beforeDelete(bean) />
				<cfset dataMgr.deleteRecord(getModelConfig().getTable(), data )/>
				<cfset afterDelete(bean) />
				
	   			<cfcatch type="any">
				 	<cfset onError(bean,cfcatch) />
					<cfthrow type="com.andreacfm.datax.deleteRecordExeption" message="#cfcatch.message#" />						
				</cfcatch>
			
			</cftry>
		
		<cfreturn result />
		
	</cffunction>
		
	<!---update record--->	
	<cffunction name="update" access="public" output="false" returntype="com.andreacfm.util.Message">
		<cfargument name="bean" type="com.andreacfm.datax.Model" required="true">
	
		<cfset var result = getMessage() />
		<cfset var dataMgr = getDataMgr()/>
		<cfset var validator = bean.getValidator() />
		<cfset var d = {} />
		<cfset var inst = bean.getMemento() />

		<cftry>
			
			<cfif not bean.isAlwaysValid()>
				<cfset bean.validate("update")/>
			</cfif>
			
			<!--- remove complex values from the struct passed to dataMgr --->
			<cfset stripComplexValues(d,inst) />
						
			<cfloop list="#variables.ModelConfig.getIgnoreUpdate()#" index="ig">
				<cfset structdelete(d,ig) />
			</cfloop>
			
			<cfif bean.isValidObject()>
				<cfset beforeUpdate(bean) />					
				<cfset dataMgr.saveRecord( getModelConfig().getTable() , d )/>
				<cfset afterUpdate(bean) />
			<cfelse>
				<cfset result.setStatus(false) />
				<cfset result.setData(bean.getErrors()) />
				<cfset onInvalidBean(bean) />
			</cfif>
			
			 <cfcatch type="any">
			 	<cfset onError(bean,cfcatch) />
				<cfthrow type="com.andreacfm.datax.updateRecordExeption" message="#cfcatch.message#" />			
			</cfcatch>
		
		</cftry> 		
			
		<cfreturn result />
	</cffunction>

	<!---ModelConfig--->
	<cffunction name="getModelConfig" access="public" output="false" returntype="com.andreacfm.datax.ModelConfig">
		<cfreturn variables.ModelConfig/>
	</cffunction>

	<!---dataMgr instance--->
	<cffunction name="getdataMgr" access="public" output="false" returntype="com.andreacfm.datax.dataMgr.dataMgr">
		<cfreturn variables.dataMgr />
	</cffunction>

	<!--- Event Manager--->
	<cffunction name="getEventManager" access="public" returntype="EventManager.EventManager">
		<cfreturn variables.EventManager/>
	</cffunction>
	
	<!-----------------------------------------  PRIVATE   ---------------------------------------------------------------->

	<!---	message	 --->
	<cffunction name="getmessage" access="private" output="false" returntype="com.andreacfm.util.Message">
		<cfreturn createObject('component','com.andreacfm.util.Message').init()/>
	</cffunction>

	<!--- 
	stripComplexValues
	 --->
	<cffunction name="stripComplexValues" returntype="void" output="false" access="private">
		<cfargument name="str" type="struct" required="true" />
		<cfargument name="memento" type="struct" required="true" />
		
		<cfset var key = "" />
		
		<cfloop collection="#memento#" item="key">
			<cfif isSimpleValue(memento[key])>
				<cfset str[key] = memento[key] />
			</cfif>
		</cfloop>

	</cffunction>
	
	<!--- interceptions --->	
	<cffunction name="beforeCreate" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfset var data = { bean = bean, context = 'create', position = 'before'} />
		<cfset getEventManager().dispatchEvent('ModelBeforeCreate',data) />
	</cffunction>

	<cffunction name="afterCreate" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfset var data = { bean = bean , context = 'create', position = 'after'} />
		<cfset getEventManager().dispatchEvent('ModelAfterCreate',data) />
	</cffunction>

	<cffunction name="beforeUpdate" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfset var data = { bean = bean , context = 'update', position = 'before'} />
		<cfset getEventManager().dispatchEvent('ModelBeforeUpdate',data) />
	</cffunction>

	<cffunction name="afterUpdate" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfset var data = { bean = bean , context = 'update', position = 'after'} />
		<cfset getEventManager().dispatchEvent('ModelAfterUpdate',data) />
	</cffunction>

	<cffunction name="beforeDelete" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfset var data = { bean = bean , context = 'delete', position = 'before'} />
		<cfset getEventManager().dispatchEvent('ModelBeforeDelete',data) />
	</cffunction>

	<cffunction name="afterDelete" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfset var data = { bean = bean , context = 'delete', position = 'after'} />
		<cfset getEventManager().dispatchEvent('ModelAfterDelete',data) />
	</cffunction>

	<cffunction name="onInvalidBean" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfset var data = { bean = bean} />
		<cfset getEventManager().dispatchEvent('ModelOnInvalidBean',data) />
	</cffunction>

	<cffunction name="onError" returntype="void" access="private">
		<cfargument name="bean" type="com.andreacfm.datax.Model">
		<cfargument name="error" type="any">
		<cfset var errorStr = {} />
		<cfset var data = {} />
		<cfif structKeyExists(arguments.error,'sql')>
			<cfset errorStr = {
				message = error.message,
				sql = error.sql,
				type = error.type,
				ErrorCode = error.errorCode,
				NativeErrorCode = error.NativeErrorCode,
				queryError = error.queryError
			}/>
		<cfelse>
			<cfset errorStr = arguments.error />	
		</cfif>
		<cfset data = { bean = bean, error = errorStr} />
		<cfset getEventManager().dispatchEvent(name = 'ModelOnDaoError', data = data ) />
	</cffunction>

</cfcomponent>
