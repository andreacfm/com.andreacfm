<cfcomponent displayname="core-bean" extends="mxunit.framework.TestCase">

	<cffunction name="setUp">
		<cfset variables.beanfactory = CreateObject('component','com.andreacfm.util.beanutils.DynamicXmlBeanFactory').init()/>
		<cfset variables.beanfactory.loadBeansFromDynamicXmlFile('/com/andreacfm/datax/tests/config/coldspring.xml.cfm') />
		<cfset variables.beanfactory.getBean('EventManager').getLogger().setOut('console')>		
	</cffunction>
	
	<cffunction name="teardown">
		<cfscript>
		</cfscript>
	</cffunction>
	
	<cffunction name="test_getTableData" returntype="void" hint="test dataMgr bean creation">
		<cfset var dataMgr = variables.beanfactory.getBean('dataMgr') />
		<cfset dataMgr.getTableData('book')>		
	</cffunction>

			
</cfcomponent>