import azure.functions as func
import logging
import pyodbc

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

def get_db_connection():
    conn_str = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=inc-management.database.windows.net;"
        "DATABASE=incident_management_data;"
        "UID=inc_admin_user;"
        "PWD=LochLegends1*"
    )
    return pyodbc.connect(conn_str)

def insert_incident(incident_data):
    logging.info(f"inside insert_incident 1: {incident_data}")
    try:
        conn = get_db_connection()
        logging.info(f"inside insert_incident 2:")

        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO incident_data (INC_Number, Description, Status) VALUES (?, ?, ?)",
            incident_data['INC_Number'],
            incident_data['description'],
            incident_data['status']
        )
        logging.info(f"inside insert_incident 3:")

        conn.commit()
    except Exception as e:
        logging.error(f"Error inserting incident: {e}")
        raise
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()


@app.route(route="http_trigger")
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    description = req.get_body().decode('utf-8')
    
    logging.info(f"Received text: {description}")
    
    name = 'Test1'
    status = 'Open'
    
    insert_incident({
        'INC_Number': name,
        'description': description,
        'status': status
    })

    # name = req.params.get('name')
    # if not name:
    #     try:
    #         req_body = req.get_json()
    #     except ValueError:
    #         pass
    #     else:
    #         name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello, {description}. This HTTP triggered function executed successfully.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )