from flask import Flask, request, render_template
import joblib
import os
import business as bus  # Import your business logic from business.py

app = Flask(__name__)

# Model path
MODEL_PATH = 'battery_lifetime_predictor.pkl'

# Check if the model exists; if not, train it
if not os.path.exists(MODEL_PATH):
    bus.train_battery_lifetime_model('battery_data.csv')  # Train and save the model

# Load the saved model
model = joblib.load(MODEL_PATH)

@app.route('/', methods=['GET', 'POST'])
def predict():
    if request.method == 'POST':
        battery_percentage = float(request.form['battery_percentage'])
        # Predict the battery lifetime using the model
        prediction = model.predict([[battery_percentage]])[0]
        message = f"The predicted battery lifetime is {prediction:.2f} hours."
        
        return render_template('index.html', message=message)
    
    return render_template('index.html', message=None)

if __name__ == '__main__':
    app.run(
        debug=True,
        host="0.0.0.0",
        port=5050
        )
