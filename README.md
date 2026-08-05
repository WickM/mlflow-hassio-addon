# 🚀 MLflow Home Assistant Add-on

Run an **MLflow tracking server** as a Home Assistant Supervisor add-on — manage experiments, log metrics, and track model artifacts right from your HA network.

![MLflow UI](https://raw.githubusercontent.com/WickM/mlflow-hassio-addon/main/screenshot.png)

## ✨ Features

- 🔬 **MLflow Tracking Server** — full experiment tracking via the MLflow UI
- 💾 **Persistent Storage** — SQLite backend by default, no extra DB needed
- 📦 **Artifact Management** — store model artifacts, plots, and datasets
- 🐳 **Docker-based** — runs as a managed Supervisor add-on container
- 🔒 **Network-isolated** — accessible only from your HA network
- ⚡ **Zero Config** — works out of the box with sensible defaults

## 📦 Installation

1. Add this repository as a custom add-on repository in Home Assistant:
   - **Supervisor → Add-on Store → ⋮ → Add-on Repository**
   - URL: `https://github.com/WickM/mlflow-hassio-addon`
2. Install the **MLflow** add-on
3. Configure as needed (port, storage path, artifact root)
4. Start the add-on

## ⚙️ Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `port` | `5000` | Port for the MLflow server |
| `storage_path` | `/mlflow` | Path for persistent storage |
| `backend_store_uri` | `sqlite:///mlflow.db` | MLflow backend store URI |
| `default_artifact_root` | `/mlflow/artifacts` | Root for model artifacts |
| `host` | `0.0.0.0` | Bind address |
| `workers` | `4` | Number of gunicorn workers |

## 🌐 Access

Once running, the MLflow UI is available at:

```
http://<home-assistant-ip>:5000
```

## 🐍 Usage from Home Assistant

Use the Home Assistant REST API or Python scripts to log experiments:

```python
import mlflow
mlflow.set_tracking_uri("http://<ha-ip>:5000")
mlflow.set_experiment("home-assistant-ml")

with mlflow.start_run():
    mlflow.log_param("model", "random_forest")
    mlflow.log_metric("accuracy", 0.95)
```

## 📁 Repository Structure

```
mlflow-hassio-addon/
├── config.yaml          # Add-on manifest (port, storage, workers, etc.)
├── Dockerfile           # Builds from HA base image, installs MLflow
├── run.sh               # Entrypoint — starts mlflow server
├── build.json           # Build targets for aarch64 + amd64
├── README.md            # This file
└── rootfs/
    ├── etc/
    │   ├── cont-init.d/10-config   # Init: creates dirs, sets permissions
    │   └── services.d/mlflow/run   # Service runner
    └── mlflow-data/                # Persistent data directory
```

## 🔧 Development

### Local Testing

```bash
docker build -t mlflow-hassio-addon .
docker run -p 5000:5000 -v ./data:/mlflow mlflow-hassio-addon
```

### Adding to Home Assistant

1. Go to **Supervisor → Add-on Store → ⋮ → Add-on Repository**
2. Enter: `https://github.com/WickM/mlflow-hassio-addon`
3. Find **MLflow** and install it

## 📄 License

MIT
