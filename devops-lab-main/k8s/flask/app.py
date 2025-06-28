import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    welcome_msg = os.getenv("WELCOME_MSG", "Hello, default!")
    return welcome_msg

if __name__ == "__main__":
    db_pass = os.getenv("DB_PASSWORD", "not_set")
    print(f"Starting app with DB_PASSWORD: {db_pass}")
    app.run(host="0.0.0.0", port=5000)
