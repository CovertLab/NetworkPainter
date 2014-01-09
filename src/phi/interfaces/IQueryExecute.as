package phi.interfaces
{
	/**
	 * The interface definition for a <code>QueryExecute</code> object.
	 * 
	 * <P>
	 * A <code>IQueryExecute</code> implementor have these responsibilities:
	 * <UL>
	 * <LI>Execute a SQL statement on a database.</LI>
	 * </UL>
	 * 
	 * @see phi.db.IDatabase
	 * @see phi.db.IQuery
	 */
	public interface IQueryExecute
	{
		function get query():IQuery 
		function set query(q:IQuery):void 
	}
}