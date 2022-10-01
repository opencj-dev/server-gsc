#include openCJ\util;

onInit()
{
	level.database = [];
	level.database["host"] = getCvar("db_host");
	level.database["user"] = getCvar("db_user");;
	level.database["pass"] = getCvar("db_pass");
	level.database["port"] = int(getCvar("db_port"));
	level.database["name"] = getCvar("db_base") + getCodVersion();

	level.mySQL = mysql_reuse_connection();
	if(!isDefined(level.mySQL))
	{
		level.mySQL = mysql_init();
		ret = mysql_real_connect(level.mySQL, level.database["host"], level.database["user"], level.database["pass"], level.database["name"], level.database["port"]);
		if(!ret)
		{
			printf("errno=" + mysql_errno(level.mySQL) + " error= " + mysql_error(level.mySQL) + "\n");
			mysql_close(level.mySQL);
			return;
		}
	}
	level.asyncMySQLDontStoreRows = [];
	thread _asyncMySQL();
}

_asyncMySQL()
{
	mysql_async_initializer(level.database["host"], level.database["user"], level.database["pass"], level.database["name"], level.database["port"], 4);
	while(true)
	{
		list = mysql_async_getdone_list();
		for(i = 0; i < list.size; i++)
		{
			result = mysql_async_getresult_and_free(list[i]);
			noRows = false;
			for(j = 0; j < level.asyncMySQLDontStoreRows.size; j++)
			{
				if(list[i] == level.asyncMySQLDontStoreRows[j])
				{
					level.asyncMySQLDontStoreRows[j] = level.asyncMySQLDontStoreRows[level.asyncMySQLDontStoreRows.size - 1];
					level.asyncMySQLDontStoreRows[level.asyncMySQLDontStoreRows.size - 1] = undefined;
					level notify("mysqlQueryDoneNoRows" + list[i], result);
					noRows = true;
					break;
				}
			}
			if(!noRows)
			{
				rows = _getRowsAndFree(result);
				level notify("mysqlQueryDone" + list[i], rows);
			}
		}
		wait 0.05;
	}
}

mysqlSyncQuery(query)
{
	ret = mysql_query(level.mySQL, query);
	if(!ret)
	{
		result = mysql_store_result(level.mySQL);
		rows = _getRowsAndFree(result);
		return rows;
	}
	return undefined;
}

_getRowsAndFree(result)
{
	rows = [];
	if(!isDefined(result) || result == 0)
	{
		return rows;
	}
	rowcount = mysql_num_rows(result);
	for(i = 0; i < rowcount; i++)
	{
		row = mysql_fetch_row(result);
		rows[rows.size] = row;
	}
	mysql_free_result(result);
	return rows;
}

mysqlAsyncLongQuerySetup()
{
	return mysql_setup_longquery();
}

mysqlAsyncLongQueryFree(handle)
{
	return mysql_free_longquery(handle);
}

mysqlAsyncLongQueryAppend(queryID, queryPart)
{
	return mysql_append_longquery(queryID, queryPart);
}

mysqlAsyncLongQueryExecuteSave(queryID)
{
	if(isPlayer(self))
	{
		self endon("disconnect");
	}
	id = mysql_async_execute_longquery(queryID, true);
	level waittill("mysqlQueryDone" + id, rows);
	return rows;
}

mysqlAsyncQueryNoRows(query)
{
	if(isPlayer(self))
	{
		self endon("disconnect");
	}
	id = mysql_async_create_query(query);
	level.asyncMySQLDontStoreRows[level.asyncMySQLDontStoreRows.size] = id;
	level waittill("mysqlQueryDoneNoRows" + id, result);
	return result;
}
mysqlAsyncLongQueryExecuteNosave(queryID)
{
	if(isPlayer(self))
	{
		self endon("disconnect");
	}
	id = mysql_async_execute_longquery(queryID, false);
	level waittill("mysqlQueryDone" + id, rows);
	return rows;
}

mysqlAsyncQuery(query)
{
	if(isPlayer(self))
	{
		self endon("disconnect");
	}
	id = mysql_async_create_query(query);
	level waittill("mysqlQueryDone" + id, rows);
	return rows;
}

mysqlAsyncQueryNosave(query)
{
	if(isPlayer(self))
	{
		self endon("disconnect");
	}
	id = mysql_async_create_query_nosave(query);
	level waittill("mysqlQueryDone" + id);
}

escapeString(string)
{
	return mysql_real_escape_string(level.mysql, string);
}
