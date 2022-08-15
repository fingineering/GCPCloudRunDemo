from distutils.log import debug
from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def main():
    if request.method == 'POST':
        # get some incomming data
        data = request.get_json()
        return f"Hello {data['name']}"
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