from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os

from process_file import process_uploaded_file

app = Flask(__name__)

# Create upload directory if it doesn't exist
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400

    # Sanitize and save the uploaded file
    filename = secure_filename(file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)

    # Process the saved file
    result = process_uploaded_file(filepath)

    return jsonify({"result": result}), 200

if __name__ == '__main__':
    # Start the Flask development server
    app.run(host='0.0.0.0', port=8000, debug=True)

# Create python virtual environment with command: python3 -m venv venv
# Initial python virtual environment activation and reactivation command: source venv/bin/activate
# Install flask (only required once per virtual environment) using command: pip install flask
# Upgrade using: pip install --upgrade pip
# To start running the local server use command: python3 server.py
# This allows the server to listen for inputs coming from the app, but the app has to have the server's IP address declared
