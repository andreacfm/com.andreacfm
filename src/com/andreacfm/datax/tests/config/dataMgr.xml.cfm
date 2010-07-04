<?xml version="1.0" encoding="UTF-8"?>
<tables xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.bryantwebconsulting.com/cfcs/DataMgr_25.xsd">
    
    <table name="book" introspect="true">
        <field ColumnName="authorList">
            <relation          
                type="list"          
                table="author"          
                field="authorId"          
                join-table="books_authors"
            />
        </field>
        <field ColumnName="createOn" special="CreationDate" CF_DataType="CF_SQL_DATE"/>
        <field ColumnName="sort" special="Sorter" CF_DataType="CF_SQL_INTEGER"/>        
    </table>
    
    <table name="author" introspect="true">
        <field ColumnName="bookList">
            <relation          
                type="list"          
                table="book"          
                field="bookId"          
                join-table="books_authors"          
            />
        </field>
        <field ColumnName="createOn" special="CreationDate" CF_DataType="CF_SQL_DATE"/>
        <field ColumnName="sort" special="Sorter" CF_DataType="CF_SQL_INTEGER"/>        
    </table>
    
</tables>