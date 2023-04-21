CREATE OR REPLACE PROCEDURE pivot_tb_lystock(tb_name text) as $$
DECLARE
    cols_name text;
    query text := '';
    final_query text := '';
BEGIN
    FOR cols_name IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = tb_name
            AND (column_name LIKE 'lystock#%' )
        ORDER BY column_name
    LOOP
        query := query || format(
        'SELECT "recordeddate",
                "branchname",
                "suppliername",
                "suppliername2",
                "districtname", 
                "provincename", 
				"dryprice",
				"accuprice",
                %L AS column_name, 
                %I::text AS value_lystock 
        FROM landing.%I UNION ALL ', 
        cols_name, cols_name,tb_name);
    END LOOP;
    query := left(query, length(query) - 11); -- remove 'UNION ALL'

    final_query := format(
        'CREATE TABLE staging.%I_lystock AS
        SELECT *,
          CASE 
            WHEN column_name LIKE ''stock#2'' THEN ''2'' 
            WHEN column_name LIKE ''stock#3'' THEN ''3''
            WHEN column_name LIKE ''stock#4'' THEN ''4''
          END AS stock_no
        FROM ( %s ) AS unpvt',
       tb_name,query);

    EXECUTE final_query;
END;
$$ LANGUAGE plpgsql;

CALL pivot_tb_lystock('stock_sheet1');