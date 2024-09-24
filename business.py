import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
import joblib

def train_battery_lifetime_model(data_path, model_path='battery_lifetime_predictor.pkl'):
    # Load your dataset
    data = pd.read_csv(data_path)
    X = data[['battery_percentage']]
    y = data['battery_lifetime']

    # Split data into train and test sets
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Train the model
    model = LinearRegression()
    model.fit(X_train, y_train)

    # Save the model
    joblib.dump(model, model_path)
    print(f"Model trained and saved as '{model_path}'")


def startpy():
    train_battery_lifetime_model('battery_data.csv') 

if __name__ == '__main__':
    startpy()
