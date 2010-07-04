<cfcomponent 
	output="false"
	name="Data Service Manager"	 
	hint="Data Service Class"
	extends="com.andreacfm.Object">
	
	<cfscript>
	variables.instance = structNew();
	variables.instance.services = structNew();
	</cfscript>		

	<!---	constructor	 --->		
	<cffunction name="init" description="initialize the object" output="false" returntype="com.andreacfm.datax.dsManager">
		<cfargument name="dbFactory" required="false" type="com.andreacfm.datax.dbFactory" default="#createObject('component','com.andreacfm.datax.dbfactory').init()#"/>	
		<cfargument name="dataMgr" required="true" type="com.andreacfm.datax.dataMgr.dataMgr"/>	
		<cfargument name="config" required="false" type="array" default="#arraynew(1)#"/>
		<cfargument name="autowire" required="false" type="Boolean" default="false"/>
		<cfargument name="EventManager" required="true" type="EventManager.EventManager" />	
		
		<cfscript>
			var service = "" ;
	
			this.autowire = arguments.autowire;
			variables.instance.dbFactory = arguments.dbFactory;
			variables.instance.dataMgr = arguments.dataMgr;
			variables.instance.EventManager = arguments.EventManager;
			
			for( i = 1 ; i <= arraylen(config); i++){
				if(validateService(config[i])){
					saveServiceConfig(config[i]);
				}
			}

			
		</cfscript>

	<cfreturn this/>	
	</cffunction>

	<!-----------------------------------------  PUBLIC   ---------------------------------------------------------------->
	
	<!---	getService	--->
	<cffunction name="getService" output="false" returntype="com.andreacfm.datax.dataService">
		<cfargument name="id" type="string" required="true" />
		
		<cfscript>
			var serviceConfig = getserviceConfig(id);;
			
			if(not serviceExists(id)){
				throw('Service #arguments.id# was not found in data service manager','custom','ds001');
			}
			
			if(structKeyExists(serviceConfig,'object') and isInstanceOf(serviceConfig.object,'com.andreacfm.datax.dataService')){
					return serviceConfig.object;
			}else{
				cacheService(arguments.id);
				return getServiceFromCache(arguments.id);
			}
		</cfscript>
		
	</cffunction>

	<!---	serviceExists	--->
	<cffunction name="serviceExists" output="false" returntype="boolean">
		<cfargument name="id" type="string" required="true" />
		<cfscript>
		if(structKeyExists(variables.instance.services,arguments.id)){
			return true;
		}
		return false;
		</cfscript>
	</cffunction>

	<!---	loadService	--->
	<cffunction name="loadService" output="false" returntype="boolean" hint="Force a service to be created and cached ( or to be reloaded if already in cache )">
		<cfargument name="id" type="string" required="true"/>
		<cfscript>
		var result = true;
		try{
			if(serviceExists(arguments.id)){
				cacheService(arguments.id);
			}
		}
		catch(any e){
			result = false;
		}
		
		return false;	
		</cfscript>
	</cffunction>
	
	<!---   dbFactory   --->
	<cffunction name="getdbFactory" access="public" output="false" returntype="com.andreacfm.datax.dbFactory">
		<cfreturn variables.instance.dbFactory/>
	</cffunction>

	<!---   dataMgr   --->
	<cffunction name="getdataMgr" access="public" output="false" returntype="com.andreacfm.datax.dataMgr.dataMgr">
		<cfreturn variables.instance.dataMgr/>
	</cffunction>

	<!----	beanFactory	--->
	<cffunction name="getBeanFactory" access="public" returntype="any" output="false" hint="Return the beanFactory instance">
		<cfreturn variables.instance.beanFactory />
	</cffunction>		
	<cffunction name="setBeanFactory" access="public" returntype="void" output="false" hint="Inject a beanFactory reference.">
		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true" />
		<cfset variables.instance.beanFactory = arguments.beanFactory />
	</cffunction>

	<!--- EventManager--->    
    <cffunction name="getEventManager" access="public" returntype="EventManager.EventManager">
    	<cfreturn variables.instance.EventManager/>
    </cffunction>


	<!-----------------------------------------  PRIVATE   ---------------------------------------------------------------->
	
	<!---	validateService	--->
	<cffunction name="validateService" output="false" returntype="boolean" access="private">
		<cfargument name="service" type="struct" required="true" />
		<cfscript>
		var result = true ;
		var decorator = "";	
		var gateway = "";	

		if(not structKeyExists(service,'modelConfig')){
			throw('Error loading the service #service.id#. modelConfig Object is missing.','com.andreacfm.datax.modelConfigMissingExeption','dsManager.cfc');
		}

		if(not isInstanceOf(service.modelConfig,'com.andreacfm.datax.ModelConfig')){
			throw('Error loading the service #service.id#. modelConfig Object is not of type com.andreacfm.datax.ModelConfig','custom','ds004');
		}
		
		if(not structKeyExists(service,'id')){
			service.id = service.modelConfig.getId() & 'Service';
		}

		if(structKeyExists(service,'gateway')){
			
			try{
				gateway = createObject('component',#service.gateway#);
			}
			catch(Any e){
				throw('Error loading the service #service.id#. gateway #service.gateway# do not exists.','custom','ds005');		
			}
			
			if(not isInstanceOf(gateway,'com.andreacfm.datax.Gateway')){				
				throw('Error loading the service #service.id#. gateway #service.gateway# is not of type com.andreacfm.datax.gateway','custom','ds005');		
			}		
			
		}

		if(structKeyExists(service,'decorator')){
			
			try{
				decorator = createObject('component',#service.decorator#);
			}
			catch(Any e){
				throw('Error loading the service #service.id#. #e.message#','custom','ds006');		
			}
			
			if(not isInstanceOf(decorator,'com.andreacfm.datax.DataService')){
				
				throw('Error loading the service #service.id#. Decorator #service.decorator# do not extend class com.andreacfm.datax.dataService','custom','ds005');		
			
			}		
			
		}
		
		return result;
		</cfscript>
	</cffunction>

	<!---	getServiceConfig	--->
	<cffunction name="getServiceConfig" output="false" returntype="struct" access="private">
		<cfargument name="id" type="string" required="true" />
		<cfscript>
			var result = structNew();
			if(serviceExists(id)){
				return variables.instance.services['#arguments.id#'];
			}
			return result;
		</cfscript>
	</cffunction>

	<!---	saveServiceConfig	--->
	<cffunction name="saveServiceConfig" output="false" returntype="void" access="private">
		<cfargument name="str" required="true" type="struct" />
		<cfscript>
		var service = arguments.str;
		variables.instance['services']['#service.id#'] = structNew();
		variables.instance['services']['#service.id#']['modelConfig'] = service.modelConfig;		
		if(structkeyExists(service,'decorator')){
			variables.instance['services']['#service.id#']['decorator'] = service.decorator;
		}
		if(structkeyExists(service,'gateway')){
			variables.instance['services']['#service.id#']['gateway'] = service.gateway;
		}
		</cfscript>
	</cffunction>

	<!---	cacheService	--->
	<cffunction name="cacheService" output="false" returntype="void" access="private" hint="Create the dataService object and cache it.">
		<cfargument name="id" required="true" type="string" />
		
		<cfscript>
		var serviceConfig = "";
		var service = "";
		var gateway = "" ;
			
		serviceConfig = getserviceConfig(id);
		
		if(structKeyExists(serviceConfig,'gateway')){
			gateway = createObject('component','#serviceConfig.gateway#').init(serviceConfig.modelConfig,getDbFactory(),getDataMgr(),getEventManager());
		}else{
			gateway = createObject('component','com.andreacfm.datax.Gateway').init(serviceConfig.modelConfig,getDbFactory(),getDataMgr(),getEventManager());				
		}
		if(this.autowire){
			getBeanFactory().getBean('beanInjector').autowire(gateway);
		}
		
		if(structKeyExists(serviceConfig,'decorator')){
			service = createObject('component','#serviceConfig.decorator#').init(gateway); 
		}else{
			service = createObject('component','com.andreacfm.datax.DataService').init(gateway);			
		}
		if(this.autowire){
			getBeanFactory().getBean('beanInjector').autowire(service);
		}
		serviceConfig.object = service;
		</cfscript>			
			
	</cffunction>

	<!---	getServiceFromCache	--->
	<cffunction name="getServiceFromCache" output="false" returntype="com.andreacfm.datax.dataService" access="private" hint="Returned the cached service object by id.">
		<cfargument name="id" required="true" type="string" />		
		<cfscript>
		var service = "";		
		try{
			service = getserviceConfig(id).object;
		}
		catch(any e){
			throw('Service #arguments.id# cannot be found in the service manager cache respository','custom','ds011');
		}
			
		return service;
		</cfscript>			
			
	</cffunction>


</cfcomponent>
