&lt;cfcomponent
	extends="com.andreacfm.datax.Model"&gt;
	<cfloop from="1" to="#arraylen(properties)#" index="i">
	<cfoutput>&lt;cfproperty name="#properties[i].name#" type="#properties[i].type#" /&gt;</cfoutput></cfloop>
	<cfloop from="1" to="#arraylen(composites)#" index="i">
	<cfoutput>&lt;cfproperty name="#composites[i].listname#" type="string" /&gt;
	&lt;cfproperty name="#composites[i].arrayname#" type="array" /&gt;</cfoutput></cfloop>

	&lt;cfscript&gt;
	variables.instance['loaded'] = {};
	<cfloop from="1" to="#arraylen(properties)#" index="i">
	<cfoutput><cfif properties[i].default><cfif properties[i].type eq 'string'>variables.instance['#properties[i].name#'] = "#properties[i].value#";<cfelse>variables.instance['#properties[i].name#'] = #properties[i].value#;</cfif></cfif></cfoutput></cfloop>
	<cfloop from="1" to="#arraylen(composites)#" index="i"><cfoutput>
	variables.instance['#composites[i].listname#'] = "";
	variables.instance['#composites[i].arrayname#'] = createObject('java','java.util.ArrayList').init();</cfoutput></cfloop>

	&lt;/cfscript&gt;
	
	&lt;!--- Constructor --->
	&lt;cffunction name="init" access="public" output="false" returntype="com.andreacfm.datax.Model"&gt;	
		&lt;cfargument name="dao" required="true" type="com.andreacfm.datax.Dao"/&gt;
		&lt;cfargument name="validator" required="false" type="com.andreacfm.validate.Validator" default="#createObject('component','com.andreacfm.validate.Validator').init()#"/&gt;		

		&lt;cfscript&gt;
			super.init(arguments.dao,arguments.validator);			
			return this;		
		&lt;/cfscript&gt;
	
	&lt;/cffunction&gt;
	
	&lt;!-------------------------------------- Public -------------------------------------------------->
<cfloop from="1" to="#arraylen(properties)#" index="i"><cfoutput>
	<!--- #properties[i].name# --->
	&lt;cffunction name="get#properties[i].name#" output="false" returntype="#properties[i].type#" &gt;
		&lt;cfscript&gt;	
		return variables.instance.#properties[i].name#;
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;	
	
	&lt;cffunction name="set#properties[i].name#" output="false" returntype="void" &gt;
		&lt;cfargument name="#properties[i].name#" type="#properties[i].type#" required="true"/>
		&lt;cfscript&gt;	
		variables.instance.#properties[i].name# = arguments.#properties[i].name#;
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;	
</cfoutput>
</cfloop>
&lt;!-------------------------------------- Composite -------------------------------------------------->
<cfloop from="1" to="#arraylen(composites)#" index="i"><cfoutput>
	&lt;!--- #composites[i].listname# --->
	&lt;cffunction name="get#composites[i].listname#" output="false" returntype="string" &gt;
		&lt;cfscript&gt;	
		return variables.instance.#composites[i].listname#;
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;	
	
	&lt;cffunction name="set#composites[i].listname#" output="false" returntype="void" &gt;
		&lt;cfargument name="#composites[i].listname#" type="string" required="true"/>
		&lt;cfscript&gt;
		variables.instance.#composites[i].listname# = arguments.#composites[i].listname#;		
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;	
	
	&lt;!--- #composites[i].arrayname# --->	
	&lt;cffunction name="get#composites[i].arrayname#" output="false" returntype="any" &gt;
		&lt;cfargument name="pop" type="boolean" default="false" /&gt;
		&lt;cfargument name="data" type="Struct" default="${}" /&gt;
		&lt;cfargument name="filters" type="Array" default="$[]" /&gt;
		&lt;cfargument name="refresh" type="boolean" default="false" /&gt;
		&lt;cfscript&gt;
			var advsql = structNew();	
			var list = "";
			<cfif composites[i].ismanytomany>
				if(listlen(get#composites[i].listname#()) and not structKeyExists(variables.instance['loaded'],'#composites[i].arrayname#') or arguments.refresh){
					list = get#composites[i].listname#();
					advsql.where = "#composites[i].field# IN (##list##)";
					set#composites[i].arrayname#(getBeanFactory().getBean('dsManager').getService('#composites[i].serviceid#').read( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache));
				};			
			<cfelse>
				if(len(get#composites[i].joinField#()) and not structKeyExists(variables.instance['loaded'],'#composites[i].arrayname#') or arguments.refresh){
					list = get#composites[i].joinField#();
					advsql.where = "#composites[i].joinField# IN (##list##)";
					set#composites[i].arrayname#(getBeanFactory().getBean('dsManager').getService('#composites[i].serviceid#').read( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache));
				};							
			</cfif>
			if(arguments.pop){
				return variables.instance.#composites[i].arrayname#[1];
			}
			return variables.instance.#composites[i].arrayname#;
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;	
	
	&lt;cffunction name="set#composites[i].arrayname#" output="false" returntype="void" &gt;
		&lt;cfargument name="#composites[i].arrayname#" type="array" required="true"/>
		&lt;cfscript&gt;	
		variables.instance.#composites[i].arrayname# = arguments.#composites[i].arrayname#;
		variables.instance['loaded']['#composites[i].arrayname#'] = 'loaded';
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;	

	&lt;!--- #composites[i].queryname# --->	
	&lt;cffunction name="get#composites[i].queryname#" output="false" returntype="query" &gt;
		&lt;cfargument name="pop" type="boolean" default="false" /&gt;
		&lt;cfargument name="data" type="Struct" default="${}" /&gt;
		&lt;cfargument name="filters" type="Array" default="$[]" /&gt;
		&lt;cfargument name="refresh" type="boolean" default="false" /&gt;
		&lt;cfscript&gt;
			var advsql = structNew();	
			var list = "";
			var q = queryNew('x');

			<cfif composites[i].ismanytomany>
				if(listlen(get#composites[i].listname#()) or arguments.refresh){
					list = get#composites[i].listname#();
					advsql.where = "#composites[i].field# IN (##list##)";
					q = getBeanFactory().getBean('dsManager').getService('#composites[i].serviceid#').list( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache);
				};			
			<cfelse>
				if(len(get#composites[i].joinField#()) or arguments.refresh){
					list = get#composites[i].joinField#();
					advsql.where = "#composites[i].joinField# IN (##list##)";
					q = getBeanFactory().getBean('dsManager').getService('#composites[i].serviceid#').list( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache);
				};							
			</cfif>

			return q;
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;	

</cfoutput>
</cfloop>

&lt;/cfcomponent&gt;
