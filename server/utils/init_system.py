from db_connector import DBConnector

db = DBConnector()

db.IUD("delete from core_variable_changes_mem");

for rec in db.select("select ID, VARIABLE_ID, CHANGE_DATE, VALUE, FROM_ID "
                     "  from core_variable_changes "
                     " where CHANGE_DATE >= current_timestamp() - interval 3 hour"):
    db.IUD("insert into core_variable_changes_mem "
           " (ID, VARIABLE_ID, CHANGE_DATE, VALUE, FROM_ID) "
           " values "
           " (%s, %s, %s, %s, '%s')", (rec[0], rec[1], rec[2], rec[3], rec[4]))
    
print("INIT SYSTEM FINISHED")