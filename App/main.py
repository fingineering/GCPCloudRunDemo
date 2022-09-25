from flask import Flask, request
from Jobs import run_search_console_query


app = Flask(__name__)


@app.route('/', methods=['GET', 'POST'])
def main():
    if request.method == 'POST':
        # get some incomming data
        data = request.get_json()
        # This would be the place where could call your code to run.
        # But that wouldn't be a good idea.
        # Therefore we create a script package, register the scripts and run
        # them all in here

        return f"Hello {data['name']}"

    # print(run_search_console_query.run())

    return "Hello World"


if __name__ == '__main__':
    """
    Creating a very basic debug app. Don't use this in production
    """
    app.run(
        debug=True,
        port=8000,
        host="0.0.0.0"
    )
