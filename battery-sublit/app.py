# battery_prediction_app.py
import streamlit as st
import joblib
import numpy as np

# Load the pre-trained model
model = joblib.load('battery_life_predictor.pkl')

# Streamlit app title
st.title('Battery Life Predictor')

# Input for battery percentage
battery_percentage = st.slider('Battery Percentage', 0, 100, 50)

# Prediction
if st.button('Predict Battery Life'):
    battery_life = model.predict(np.array([[battery_percentage]]))[0]
    st.write(f"Estimated battery life: {battery_life:.2f} hours")

# Footer
st.write("Predict battery life based on percentage using machine learning.")
