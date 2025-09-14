from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import nltk
import string
from nltk.corpus import stopwords

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Load saved vectorizer and model
with open("vectorizer.pkl", "rb") as f:
    vectorizer = pickle.load(f)

with open("spam_model.pkl", "rb") as f:
    model = pickle.load(f)

# Make sure NLTK resources are available
nltk.download('punkt')
nltk.download('stopwords')

# -----------------------------
# Text preprocessing function
# -----------------------------
def transform_text(text):
    text = text.lower()
    text = nltk.word_tokenize(text)

    y = []
    for i in text:
        if i.isalnum():
            y.append(i)
    text = y[:]
    y.clear()

    for i in text:
        if i not in stopwords.words('english') and i not in string.punctuation:
            y.append(i)

    return " ".join(y)

# -----------------------------
# API Routes
# -----------------------------
@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.json['message']  # get message from request
        transformed = transform_text(data)
        vectorized = vectorizer.transform([transformed])
        prediction = model.predict(vectorized)[0]

        return jsonify({
            "prediction": str(prediction),
            "label": "Spam" if prediction == 1 else "Not Spam"
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Run Flask app
if __name__ == "__main__":
    app.run(debug=True)
