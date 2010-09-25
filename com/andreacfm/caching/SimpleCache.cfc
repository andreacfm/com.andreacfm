<cfcomponent output="false" accessors="true" implements="com.andreacfm.caching.ICacheManager">
	
	<cfproperty name="store" type="struct">
	<cfproperty name="cachewithin" type="date">
	<cfproperty name="timeidle" type="date">
	<cfproperty name="cachename" type="string">	
	
	<cfscript>
	variables.store = {};
	variables.LOCK_NAME = 'simplecache';
	</cfscript>
		
	<cffunction name="init" output="false" returntype="com.andreacfm.caching.ICacheManager">
		<cfargument name="cachewithin" type="string" required="false" default="#createtimespan(0,0,0,0)#">
		<cfargument name="timeidle" type="string" required="false" default="#createtimespan(0,0,0,0)#">		
		<cfargument name="cachename" type="string" required="false" default="">
		
		<cfscript>
		setcachewithin(cachewithin);
		setTimeIdle(timeidle);
		setCacheName(cachename);		
		</cfscript>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="put" output="false" returntype="void">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true">
		<cfargument name="cachewithin" type="string" required="false">
		<cfargument name="timeidle" type="string" required="false">		
		<cfargument name="cachename" type="string" required="false">
			
		<cfset var span = structKeyExists(arguments,'cachewithin') ? arguments.cachewithin : getcachewithin()>
		
		<cflock name="#variables.LOCK_NAME#" type="readonly" timeout="5">
			<cfset var expireTs = createODBCDateTime(now() + span)>
			<cfset variables.store[arguments.key] = {
					expires = expireTs,
					value = arguments.value
			}>	
		</cflock>		
		
	</cffunction>

	<cffunction name="get" output="false" returntype="any">
		<cfargument name="key" type="string" required="true">
		<cfargument name="cachename" type="string" required="false">
		
		<cfscript>
		var store = getStore();
		if(this.exists(arguments.key)){
			return store[arguments.key].value;
		}else{
			throw('Key #arguments.key# does not exixts in cache.','com.andreacfm.caching.keyDoesNotExists');
		}
		</cfscript>
		
	</cffunction>

	<cffunction name="exists" output="false" returntype="boolean">
		<cfargument name="key" type="string" required="true">
		<cfargument name="cachename" type="string" required="false">
		
		<cfset var store = getStore()>

		<cflock name="#variables.LOCK_NAME#" type="readonly" timeout="5">
			<cfset checkexpired(arguments.key)>
			<cfreturn structKeyExists(store,arguments.key)>			
		</cflock>
		
	</cffunction>
	
	<cffunction name="remove" output="false" returntype="void">
		<cfargument name="key" type="string" required="false" default="">
		<cfargument name="cachename" type="string" required="false">
		<cfargument name="criteria" type="any" required="false" default="">
		
		<cfset var store = getStore()>
		<cfset var item = "">
		<cfset var c = "">

		<cflock name="#variables.LOCK_NAME#" type="readonly" timeout="5">
			<!--- remove by key --->
			<cfif len(arguments.key)>
				<cfset structDelete(store,arguments.key)>
			</cfif>
			<!--- 
			Remove by criteria
			Criteria may also be an array od strings
			 --->
			<cfif isArray(arguments.criteria) or arguments.criteria neq "">
				<cfif isSimpleValue(criteria)>
					<cfloop collection="#store#" item="item">
						<cfif findnocase(arguments.criteria,item)>
							<cfset structDelete(store,item)>
						</cfif>
					</cfloop>
				<cfelse>
					<cfloop collection="#store#" item="item">
						<cfloop array="#criteria#" index="c">
							<cfif findnocase(c,item)>
								<cfset structDelete(store,item)>
							</cfif>						
						</cfloop>
					</cfloop>						
				</cfif>
			</cfif>
		</cflock>
		
	</cffunction>
	
	<cffunction name="flush" output="false" returntype="void">
		<cfargument name="cachename" type="string" required="false">
		
		<cflock name="#variables.LOCK_NAME#" type="readonly" timeout="5">
			<cfset variables.store = {}>
		</cflock>
						
	</cffunction>

	<cffunction name="checkexpired" returntype="void" output="false" access="private" hint="Check if a cache is still valid and flush it if is not.">
		<cfargument name="key" type="string" required="true">
		
		<cfscript>
			var store = getStore();
			out = createObject('java','java.lang.System').out;
			out.println('precheck store len : ' & structCount(store));

			if(structKeyExists(store,arguments.key)){
				var cache = variables.store[arguments.key];
				if(dateCompare(now(),cache.expires) eq 1){
					structDelete(store,arguments.key);
				}
			}
			out.println('post check store len : ' & structCount(store));
			
		</cfscript>

	</cffunction>

</cfcomponent>