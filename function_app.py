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
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO Incidents (Title, Description, Status) VALUES (?, ?, ?)",
        incident_data['title'],
        incident_data['description'],
        incident_data['status']
    )
    conn.commit()
    cursor.close()
    conn.close()


@app.route(route="http_trigger")
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('title')
    description = req.params.get('description')   
    status = req.params.get('status')
    
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('title')
        
        insert_incident({
            'title': name,
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
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )