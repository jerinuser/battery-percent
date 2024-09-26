# battery_model.py
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
import joblib

# Generate some example data (you can replace this with actual data)
data = {
    'battery_percentage': np.linspace(0, 100, 100),
    'battery_life_hours': np.linspace(0, 10, 100)  # Assume 10 hours at full charge
}

df = pd.DataFrame(data)

# Features and target
X = df[['battery_percentage']]
y = df['battery_life_hours']

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the model
model = LinearRegression()
model.fit(X_train, y_train)

# Save the model
joblib.dump(model, 'battery_life_predictor.pkl')

print(f"Model trained and saved as 'battery_life_predictor.pkl'.")
