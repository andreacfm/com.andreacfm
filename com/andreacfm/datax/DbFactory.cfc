<cfcomponent output="false" name="Data Bean Factory"
	 hint="Data Bean Factory" 
	 extends="com.andreacfm.datax.Base"
	 accessors="true"> 

	<cfproperty name="EventManager" type="com.andreacfm.cfem.EventManager">
	<cfproperty name="CacheManager" type="com.andreacfm.caching.ICacheManager">
	<cfproperty name="dataMgr" type="com.andreacfm.datax.dataMgr.dataMgr">
	<cfproperty name="beanFactory" type="coldspring.beans.BeanFactory">		
	
	<cfscript>
	variables.beans = structNew();
	</cfscript>		

	<!---	constructor	 --->		
	<cffunction name="init" description="initialize the object" output="false" returntype="com.andreacfm.datax.dbFactory">	
		<cfargument name="config" required="false" type="array" default="#arraynew(1)#"/>
		<cfargument name="dataMgr" required="true" type="com.andreacfm.datax.dataMgr.dataMgr" />
		<cfargument name="EventManager" required="true" type="com.andreacfm.cfem.EventManager" />
		<cfargument name="CacheManager" required="true" type="com.andreacfm.caching.ICacheManager" />		
		<cfargument name="testMode" required="false" type="boolean" default="false"/>
		<!--- Only for beans. Daos and validators are always autowired --->
		<cfargument name="autowire" required="false" type="Boolean" default="false"/>
		
		<cfscript>
			var bean = "" ;
			
			this.testmode = arguments.testmode;
			this.autowire = arguments.autowire;
			variables.dataMgr = arguments.dataMgr;
			variables.EventManager = arguments.EventManager;

			if(not arrayIsEmpty(config)){
				for( i = 1 ; i <= arraylen(config); i++){
					if(validateBean(config[i])){
						saveModelConfig(config[i]);
					}
				}
			}
			if(arguments.testmode){
				makeBeans();
			}
		</cfscript>

	<cfreturn this/>	
	</cffunction>

	<!-----------------------------------------  PUBLIC   ---------------------------------------------------------------->

	<!---	getBean	--->
	<cffunction name="getBean" output="false" returntype="com.andreacfm.datax.Model">
		<cfargument name="id" type="string" required="true" />
				
		<cfscript>			
			var s = variables.beans;
			var beanClass = s[id].ModelConfig.getbeanClass();
			var decorator = s[id].ModelConfig.getDecorator();
			var dao = getDaoFromCache(id);
			var validator = getValidatorFromCache(id);
			
			if(structIsEmpty(s) or not beanExists(id)){
				throw('Configurations for bean #arguments.id# was not found in the data bean factory. The bean cannot be created.','custom','db008');
			}
			
			if(decorator neq ""){
				beanClass = decorator;
			}
													
			bean = createObject('component','#beanClass#').init(dao,validator); 
			
			bean.setBeanFactory(getbeanFactory());
			
			if(this.autowire){
				getBeanFactory().getBean('beanInjector').autowire(bean);
			}

			return bean;
		</cfscript>
		
	</cffunction>

	<!---	beanExists	--->
	<cffunction name="beanExists" output="false" returntype="boolean">
		<cfargument name="id" type="string" required="true" />
		<cfscript>
		if(structKeyExists(variables.beans,arguments.id)){
			return true;
		}
		return false;
		</cfscript>
	</cffunction>

	<!---	makeBeans=	--->
	<cffunction name="makeBeans" output="false" returntype="void">

		<cfset var config = variables['beans'] />

		<cfscript>			
			try{
				for(item in config){
					if(config[item].ModelConfig.getBeanClass() neq 'com.andreacfm.datax.Model'){
						writeBean(config[item].ModelConfig.getId());
					}
				}
			}
			catch(Any e){
				throw('Error making beans. #e.message#','com.andreacfm.datax.dbFactory.beanMakerExeption','method makeBeans');
			}
		
		</cfscript>		
	</cffunction>

	<!---	makeBean=	--->
	<cffunction name="makeBean" output="false" returntype="void">
		<cfargument name="beanName" required="true">

		<cfset var config = variables['beans'] />

		<cfscript>			
			try{
				if(config[arguments.beanName].ModelConfig.getBeanClass() neq 'com.andreacfm.datax.Model'){
					writeBean(arguments.beanName);
				}
			}
			catch(Any e){
				throw('Error making beans. #e.message#','com.andreacfm.datax.dbFactory.beanMakerExeption','method makeBeans');
			}
		
		</cfscript>		
	</cffunction>

	<!--- getBeanConfig --->
	<cffunction name="getBeanConfig" returntype="Struct" output="false" access="public" hint="">
		<cfargument name="id" required="false" type="string" />
		<cfscript>
		return variables.beans[id];
		</cfscript>
	</cffunction>
	<!-----------------------------------------  PRIVATE   ---------------------------------------------------------------->

	<!---writeBean--->
	<cffunction name="writeBean" output="false" returntype="void">
		<cfargument name="beanName" required="true" type="string" />
		
		<cfset var beanConfig = variables['beans'][arguments.beanName].ModelConfig />
		<cfset var relatedTables = variables['beans'][arguments.beanName].relatedtables />
		<cfset var beanPath = "/" & replace(beanConfig.getbeanClass(),".","/","All") & ".cfc" />
		<cfset var dmTable = getDataMgr().getTableData(beanConfig.getTable()) />
		<cfset var dmConf = xmlParse(fileRead(expandPath("/com/andreacfm/datax/conf/dm-map.cfm"))) />
		<cfset var def = beanConfig.getdefaults() />
		<cfset var properties = arrayNew(1) />
		<cfset var composites = arrayNew(1) />
		<cfset var property = "" />
		<cfset var output = "" />
		<cfset var fields = "" />
		<cfset var temp = "" />
		
		<cfif not structKeyExists(dmTable,beanConfig.getTable())>
			<cfset getDataMgr().loadTable(beanConfig.getTable()) />
			<cfset dmTable = getDataMgr().getTableData(beanConfig.getTable()) />
		</cfif>

		<cfset fields = dmTable[beanConfig.getTable()] />
		
		<!--- loop teh fields --->
		<cfloop from="1" to="#arraylen(fields)#" index="i">	
			<!--- if exists a relation --->		
			<cfif structKeyExists(fields[i],'relation')>
				<cfset relation = fields[i].relation />
				<!--- list NEED A SERVICE ID --->
				<cfif relation.type eq 'list'>
					<cfset property = structNew()/>
					<cfset property.field = relation.field  />
					<cfset property.listname = fields[i].columnName />
					<cfset property.arrayname = replaceNoCase(fields[i].columnName,'list','Array','one') />
					<cfset property.queryname = replaceNoCase(fields[i].columnName,'list','Query','one') />
					<cfset property.serviceid =  relation.table & 'Service'/>
					<cfif structKeyExists(relation,'join-table')>
						<cfset property['joinTable'] = relation['join-table'] />
						<cfset property.isManyToMany = true />
					<cfelse>
						<cfset property['joinField'] = relation['join-field-local'] />
						<cfset property.isManyToMany = false />							
					</cfif>
					<!--- add to composites --->			
					<cfset arrayAppend(composites,property) />
				<cfelse>
					<cfset property = structNew()/>
					<cfset property.default = false />
					<cfset property.name = fields[i].columnName />
					<cfset temp = xmlSearch(dmConf,"//data-mapping/data-type[@name='#fields[i].cf_dataType#']") />
					<cfset property.type = temp[1].XmlText/>	
					<cfset temp = xmlSearch(dmConf,"//data-values/cf-data-type[@name='#property.type#']") />
					<cfset property.value = temp[1].XmlText/>
					<cfset arrayAppend(properties,property) />		
				</cfif>
			<cfelse>
				<!--- normal field add to properties and map the type and add the defaults --->
				<cfset property = structNew()/>
				<cfset property.default = true />
				<cfset property.name = fields[i].columnName />
				<cfif structKeyExists(def,fields[i].columnName) and structKeyExists(def[fields[i].columnName],'type')>
					<cfset property.type = def[fields[i].columnName].type />
				<cfelse>
					<cfset temp = xmlSearch(dmConf,"//data-mapping/data-type[@name='#fields[i].cf_dataType#']") />
					<cfset property.type = temp[1].XmlText/>	
				</cfif>		
				<cfif structKeyExists(def,fields[i].columnName) and structKeyExists(def[fields[i].columnName],'value')>
					<cfset property.value = def[fields[i].columnName].value />
				<cfelse>
					<cfset temp = xmlSearch(dmConf,"//data-values/cf-data-type[@name='#property.type#']") />
					<cfset property.value = temp[1].XmlText/>	
				</cfif>
				<cfset arrayAppend(properties,property) />						 	
			</cfif>
		</cfloop>

		<cfsavecontent variable="output"><cfoutput><cfinclude template="template/model.cfm" /></cfoutput></cfsavecontent>
		
		<cfset output = rereplacenocase(output,"&lt;","<","All") />
		<cfset output = rereplacenocase(output,"&gt;",">","All") />
		<cfset output = rereplacenocase(output,"\$\{\}","##structNew()##","All") />
		<cfset output = rereplacenocase(output,"\$\[\]","##arrayNew(1)##","All") />

		<cffile action="write" file="#expandPath(beanPath)#" output="#output#" />
		
	</cffunction>

	<!---	
	validateBean
	Check that anything is in order to process the bean.
	--->
	<cffunction name="validatebean" output="false" returntype="boolean" access="private">
		<cfargument name="bean" type="struct" required="true" />
		<cfscript>
		var result = true ;
		var dao = "";
		var testobject = "";				
		
		if(not structKeyExists(bean,'ModelConfig')){
			throw('Error loading the data bean. Config Object is missing.','com.andreacfm.datax.dbFactory.configObjectMissingExeption','method validatebean');
		}

		if(not isInstanceOf(bean.ModelConfig,'com.andreacfm.datax.ModelConfig')){
			throw('Error loading the data bean. BeanConfig Object is not of type com.andreacfm.datax.ModelConfig','com.andreacfm.datax.dbFactory.badConfigObjectExeption','method validatebean');
		}

		if(len(bean.ModelConfig.getId()) eq 0){
			throw('Error loading the data bean. The id property is not properly defined.','com.andreacfm.datax.dbFactory.badIdExeption','method validatebean');		
		}
		
		// if no class is passed use the super class to go over
		
		if(len(bean.ModelConfig.getbeanClass()) eq 0){
			bean.beanConfig.setbeanClass('com.andreacfm.datax.Model');
		}
		
		if(!this.testmode){
			try{			
				
				testobject = createObject('component','#bean.ModelConfig.getBeanClass()#'); 
				
				if(not isInstanceOf(testobject,'com.andreacfm.datax.Model')){
					throw('Error loading the data bean #bean.ModelConfig.getId()#. The Object is not of type com.andreacfm.datax.Model','custom','db004');
				}
				
			}
			catch(any e){
				throw('Error loading the data bean #bean.ModelConfig.getId()#. Object with class #bean.ModelConfig.getBeanClass()# cannot been created.','com.andreacfm.datax.dbFactory.beanCreationTestExeption','method validateBean');		
			}
		}
						
		if(structKeyExists(bean,'dao')){
			try{
				if(isInstanceOf(bean.dao,'com.andreacfm.datax.Dao')){
					dao = bean.dao;
				}else{
					dao = createObject('component',#bean.dao#);		
				}
				if(not isInstanceOf(dao,'com.andreacfm.datax.Dao')){					
					throw('Error loading bean #bean.ModelConfig.getId()#. Dao object with class #bean.dao# is not of type com.andreacfm.datax.dao','custom','db006');		
				}		

			}
			catch(Any e){
				throw('Error loading the data bean #bean.ModelConfig.getId()#. Dao #bean.dao# do not exists.','com.andreacfm.datax.dbFactory.daoTestCreationExeption','method validateBean');		
			}
			
			
		}	

		if(structKeyExists(bean,'validator')){
			try{
				if(isInstanceOf(bean.validator,'com.andreacfm.validate.Validator')){
					validator = bean.validator;
				}else{
					validator = createObject('component',#bean.validator#);
				}
				if(not isInstanceOf(validator,'com.andreacfm.validate.Validator')){					
					throw('Error loading the data bean #bean.ModelConfig.getId()#. Validator Object #bean.validator# is not of type com.andreacfm.datax.core.Ivalidator','custom','db009');		
				}		

			}
			catch(Any e){
				throw('Error loading the validator for the bean [#bean.ModelConfig.getId()#]. #e.message#','custom','db010');		
			}
				
		}		
			
		return result;
		</cfscript>
	</cffunction>

	<!---	getDaoFromCache	--->
	<cffunction name="getDaoFromCache" output="false" returntype="com.andreacfm.datax.Dao" access="private">
		<cfargument name="id" type="string" required="true" />
		<cfscript>
			
			var config = variables['beans']['#id#'];			
			var dao = "";

			if(not structkeyExists(config,'daoObject')){
				if(isInstanceOf(config.dao,'com.andreacfm.datax.dao')){
					dao = config.dao;
				}else{
					dao = createObject('component','#config.dao#').init(config.ModelConfig,getdatamgr(),getEventManager(),getCacheManager());
				}
				if(this.autowire){
					getBeanFactory().getBean('beanInjector').autowire(dao);
				}
				variables['beans']['#config.ModelConfig.getid()#']['daoObject'] = dao;
			}
			
			return variables['beans']['#config.ModelConfig.getid()#']['daoObject'];		
		</cfscript>
	</cffunction>

	<!---	getValidatorFromCache	--->
	<cffunction name="getValidatorFromCache" output="false" returntype="com.andreacfm.validate.Validator" access="private">
		<cfargument name="id" type="string" required="true" />
		<cfscript>
					
			var config = variables['beans']['#id#'];			
			var validator = "";
			
			if(not structkeyExists(config,'validatorObject')){
				if(isInstanceOf(config.validator,'com.andreacfm.validate.Validator')){
					validator = config.validator;
				}else{
					validator = createObject('component','#config.validator#').init();
				}
				if(this.autowire){
					getBeanFactory().getBean('beanInjector').autowire(validator);
				}		
				variables['beans']['#config.ModelConfig.getid()#']['validatorObject'] = validator;

			}
			
			return variables['beans']['#config.ModelConfig.getid()#']['validatorObject'];		
		</cfscript>
	</cffunction>

	<!---	saveModelConfig	--->
	<cffunction name="saveModelConfig" output="false" returntype="void" access="private">
		<cfargument name="str" required="true" type="struct" />
		
		<cfscript>
		
		var bean = arguments.str;
		var table = bean.modelConfig.getTable();	
		var dm = getdataMgr();	
		var info = dm.getTableData(table)[table];
		var relatedTables = "'#table#'";	
		var id = bean.ModelConfig.getid();

		variables['beans'][id] = structNew();
		
		//modelconfig
		variables['beans'][id]['ModelConfig'] = bean.ModelConfig;	
		
		//dao
		if(structkeyExists(bean,'dao')){
			dao = bean.dao;
		}else{
			dao = 'com.andreacfm.datax.Dao';				
		}			
		variables['beans'][id]['dao'] = dao;		

		//validator
		if(structkeyExists(bean,'validator')){
			validator = bean.validator;
		}else{
			validator = 'com.andreacfm.validate.Validator';				
		}			
		variables['beans'][id]['validator'] = validator;		
		
		//related tables for cache keys and cache flush		
		for(var item in info){
			if(structKeyExists(item,'relation')){
				var rel = item.relation.table;
				if(not listFindNocase(relatedTables,rel)){
					relatedTables = listAppend(relatedTables,"'#rel#'");
				}
			}
		}
		variables['beans'][id]['relatedtables'] = relatedTables;
		</cfscript>

	</cffunction>
	
</cfcomponent>
