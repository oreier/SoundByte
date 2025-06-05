from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os

from process_file import process_uploaded_file

app = Flask(__name__)

# Folder where uploaded files will be saved
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400

    filename = secure_filename(file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)

    # Call your custom file processing function
    result = process_uploaded_file(filepath)

    return jsonify({"result": result}), 200

if __name__ == '__main__':
    # You can change port to 5000 or anything else if needed
    app.run(host='0.0.0.0', port=8000, debug=True)

# reactivate server using command: source venv/bin/activate
