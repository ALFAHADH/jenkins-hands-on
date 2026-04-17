from flask import Flask, jsonify
import datetime

app = Flask(__name__)

APP_VERSION = "1.0.0"

@app.route('/')
def home():
    return jsonify({
        "app":     "Jenkins Hands-On App",
        "version": APP_VERSION,
        "status":  "running",
        "time":    str(datetime.datetime.now())
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
