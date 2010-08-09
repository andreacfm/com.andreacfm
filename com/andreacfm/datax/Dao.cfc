<cfcomponent  output="false" accessors="true">
	
	<cfproperty name="ModelConfig" type="com.andreacfm.datax.ModelConfig">
	<cfproperty name="EventManager" type="com.andreacfm.cfem.EventManager">
	<cfproperty name="CacheManager" type="com.andreacfm.caching.ICacheManager">
	<cfproperty name="dataMgr" type="com.andreacfm.datax.dataMgr.dataMgr">

	<!---constructor--->		
	<cffunction name="init" description="initialize the object settings struct" output="false" returntype="com.andreacfm.datax.Dao">	
		<cfargument name="ModelConfig" required="true" type="com.andreacfm.datax.ModelConfig" />
		<cfargument name="dataMgr" required="true" type="com.andreacfm.datax.dataMgr.dataMgr" />
		<cfargument name="EventManager" required="true" type="com.andreacfm.cfem.EventManager" />
		<cfargument name="CacheManager" required="true" type="com.andreacfm.caching.ICacheManager" />		
		<cfscript>
			setModelConfig(arguments.ModelConfig);
			setdataMgr(arguments.dataMgr);
			setEventManager(arguments.EventManager);
			setCacheManager(arguments.CacheManager);
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
					<cfthrow type="com.andreacfm.datax.createRecordExeption" message="#cfcatch.message#" />						
				</cfcatch>

			</cftry>
			
			<!--- clean the cache of all the related tables --->
			<cfset cleanCache(bean.getRelatedTables())>
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
					<cfthrow type="com.andreacfm.datax.deleteRecordExeption" message="#cfcatch.message#" />						
				</cfcatch>
			
			</cftry>

		<!--- clean the cache of all the related tables --->
		<cfset cleanCache(bean.getRelatedTables())>		
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
				<cfthrow type="com.andreacfm.datax.updateRecordExeption" message="#cfcatch.message#" />			
			</cfcatch>
		
		</cftry> 		

		<!--- clean the cache of all the related tables --->
		<cfset cleanCache(bean.getRelatedTables())>
			
		<cfreturn result />
	</cffunction>
	
	<!-----------------------------------------  PRIVATE   ---------------------------------------------------------------->
		
	<!--- 
	cleanCache
	 --->
	<cffunction name="cleanCache" returntype="void" output="false" access="public" hint="Remove from cache all the related tables items">
		<cfargument name="relatedTables" type="array" required="true">
		<cfscript>
		var cm = getCacheManager();
		cm.remove(criteria=relatedTables);
		</cfscript>
	</cffunction>
	
	<!---	message	 --->
	<cffunction name="getmessage" access="private" output="false" returntype="com.andreacfm.util.Message">
		<cfreturn createObject('component','com.andreacfm.util.Message').init()/>
	</cffunction>

	<!--- stripComplexValues --->
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

</cfcomponent>
