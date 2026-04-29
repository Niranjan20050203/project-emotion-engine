# Facial Expression Recognition System (DCNN-BiLSTM-DAM)

This is a state-of-the-art implementation of the **DCNN-BiLSTM-DAM** architecture for Facial Expression Recognition (FER), as specified in the project requirements.

## 📁 Project Structure
- `main.py`: The core FastAPI backend server and real-time inference engine.
- `core_model.py`: The DCNN-BiLSTM-DAM Neural Network architecture (PyTorch).
- `train.py`: The automated training script that fetches the FER-2013 dataset and fine-tunes the model.
- `/static`: Premium web-based dashboard and presentation assets.
- `/models`: Contains the trained weights (`.pth`) and exported (`.onnx`) versions.
- `/docs`: Project paperwork, base paper, and requirement forms.
- `/tools`: Auxiliary scripts for testing and exporting models.

## 🚀 Getting Started

### 1. Training the Model
The system is pre-configured to automatically download and train on the **FER-2013** dataset (35,000+ images) via KaggleHub.
```bash
python3 train.py
```
*The model will automatically save the best weights to `models/best_model_dcnn_dam.pth`.*

### 2. Running the Live Dashboard
Access the application at: **http://127.0.0.1:8005**

#### 🐧 macOS / Linux
Starts the production server:
```bash
python3 -m uvicorn main:app --port 8005 --reload
```

#### 💻 Windows (One-Click)

Just simply click on the link provided in the Description of this repository.
Mentioned like this "https://huggingface.co/spaces/Niranjan-ninja/Emotion-engine"

#### 🗺️ Other Methods

Simply double-click the `run_windows.bat` file. 
- It will automatically create a virtual environment (`venv`).
- Installs all dependencies from `requirements.txt`.
- Launches the server and dashboard immediately.

### Or else
Download the production app folder
and open cmd = and follow this :
- type "cd_file path" and press enter.
- And use this prompt:
- :: Activate virtual environment
venv\Scripts\activate

:: Run the server
python -m uvicorn main:app --host 127.0.0.1 --port 8005
- And press enter and host the server in local.

### 3. Viewing the Presentation
Open the interactive landing page at: **http://127.0.0.1:8005**


## 💡 Tech Stack
- **Backend:** FastAPI, PyTorch (DCNN-BiLSTM-DAM Architecture).
- **Computer Vision:** YOLOv8 (Tracking), HOG (Feature Extraction), OpenCV.
- **Frontend:** Vanilla HTML5, CSS3 (Glassmorphism), JavaScript (Particle Engine).
- **Environment:** Compatible with macOS (MPS) and Windows (CUDA) acceleration.


#### 🎞️ Project Preview

1. #### Dashboard
<img width="1919" height="929" alt="Screenshot 2026-04-29 151817" src="https://github.com/user-attachments/assets/c634b0b3-311d-414c-ba7a-bd9bbccff3d7" />

2. #### Live Capturing
<img width="1919" height="928" alt="Screenshot 2026-04-29 151840" src="https://github.com/user-attachments/assets/6ec0d9c9-5174-4050-bb12-9b6dfb4aac13" />

3. #### Uploading Media Preview
<img width="1919" height="931" alt="Screenshot 2026-04-29 151857" src="https://github.com/user-attachments/assets/52b05344-f9bd-430d-8886-38f74376b0b1" />

4. #### Dashboard For Presentation
<img width="1919" height="929" alt="Screenshot 2026-04-29 151924" src="https://github.com/user-attachments/assets/090ecbdc-e7c0-4100-ac38-f018d435060c" />
