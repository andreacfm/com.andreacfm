<cfcomponent
	extends="com.andreacfm.datax.Model">
	
	<cfproperty name="bookId" type="numeric" />
	<cfproperty name="bookName" type="string" />
	<cfproperty name="createOn" type="date" />
	<cfproperty name="sort" type="numeric" />
	
	<cfproperty name="authorList" type="string" />
	<cfproperty name="authorarray" type="array" />

	<cfscript>
	this.loaded = {};
	
	variables.instance['bookId'] = 0;
	variables.instance['bookName'] = "";
	
	
	
	variables.instance['authorList'] = "";
	variables.instance['authorarray'] = createObject('java','java.util.ArrayList').init();
	
	</cfscript>
	
	<!--- Constructor --->
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.datax.Model">	
		<cfargument name="dao" required="true" type="com.andreacfm.datax.Dao"/>
		<cfargument name="validator" required="false" type="com.andreacfm.validate.Validator" default="#createObject('component','com.andreacfm.validate.Validator').init()#"/>		

		<cfscript>
			super.init(arguments.dao,arguments.validator);			
			return this;		
		</cfscript>
	
	</cffunction>
	
	<!-------------------------------------- Public -------------------------------------------------->

	
	<cffunction name="getbookId" output="false" returntype="numeric" >
		<cfscript>	
		return variables.bookId;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setbookId" output="false" returntype="void" >
		<cfargument name="bookId" type="numeric" required="true"/>
		<cfscript>	
		variables.bookId = arguments.bookId;
		</cfscript>
	</cffunction>	


	
	<cffunction name="getbookName" output="false" returntype="string" >
		<cfscript>	
		return variables.bookName;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setbookName" output="false" returntype="void" >
		<cfargument name="bookName" type="string" required="true"/>
		<cfscript>	
		variables.bookName = arguments.bookName;
		</cfscript>
	</cffunction>	


	
	<cffunction name="getcreateOn" output="false" returntype="date" >
		<cfscript>	
		return variables.createOn;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setcreateOn" output="false" returntype="void" >
		<cfargument name="createOn" type="date" required="true"/>
		<cfscript>	
		variables.createOn = arguments.createOn;
		</cfscript>
	</cffunction>	


	
	<cffunction name="getsort" output="false" returntype="numeric" >
		<cfscript>	
		return variables.sort;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setsort" output="false" returntype="void" >
		<cfargument name="sort" type="numeric" required="true"/>
		<cfscript>	
		variables.sort = arguments.sort;
		</cfscript>
	</cffunction>	


<!-------------------------------------- Composite -------------------------------------------------->

	<!--- authorList --->
	<cffunction name="getauthorList" output="false" returntype="string" >
		<cfscript>	
		return variables.authorList;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setauthorList" output="false" returntype="void" >
		<cfargument name="authorList" type="string" required="true"/>
		<cfscript>
		variables.authorList = arguments.authorList;		
		</cfscript>
	</cffunction>	
	
	<!--- authorarray --->	
	<cffunction name="getauthorarray" output="false" returntype="any" >
		<cfargument name="pop" type="boolean" default="false" />
		<cfargument name="data" type="Struct" default="#structNew()#" />
		<cfargument name="filters" type="Array" default="#arrayNew(1)#" />
		<cfargument name="refresh" type="boolean" default="false" />
		<cfscript>
			var advsql = structNew();	
			var list = "";
			if(listlen(variables.authorList) and not structKeyExists(this['loaded'],'authorarray') or arguments.refresh){
				list = getauthorList();
				advsql.where = "authorId IN (#list#)";
				setauthorarray(getBeanFactory().getBean('dsManager').getService('authorService').read( data = arguments.data, filters = arguments.filters, advsql = advsql));
				this['loaded']['authorarray'] = 'loaded';
			};
			if(arguments.pop){
				return variables.authorarray[1];
			}
			return variables.authorarray;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setauthorarray" output="false" returntype="void" >
		<cfargument name="authorarray" type="array" required="true"/>
		<cfscript>	
		variables.authorarray = arguments.authorarray;
		</cfscript>
	</cffunction>	



</cfcomponent>
