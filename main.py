import logging
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Processing addition request')

    try:
        a = int(req.params.get('a'))
        b = int(req.params.get('b'))

        result = a + b

        return func.HttpResponse(f"Result: {result}", status_code=200)

    except ValueError:
        return func.HttpResponse(
             "Invalid input. Ensure that both 'a' and 'b' are integers.",
             status_code=400
        )