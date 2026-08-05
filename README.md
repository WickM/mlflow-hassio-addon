# MLflow Home Assistant Add-on

Run an MLflow tracking server as a Home Assistant Supervisor add-on.

## What it does

- MLflow tracking server accessible from your Home Assistant network
- Persistent storage for experiments, metrics, and model artifacts
- SQLite backend by default (no extra DB needed)
- Optional S3/MinIO artifact backend support

## Installation

1. Add this repository as a custom add-on repository in Home Assistant:
   - **Supervisor → Add-on Store → ⋮ → Add-on Repository**
   - URL: `https://github.com/WickM/mlflow-hassio-addon`
2. Install the MLflow add-on
3. Configure as needed (port, storage path, artifact root)
4. Start the add-on

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `port` | `5000` | Port for the MLflow server |
| `storage_path` | `/mlflow` | Path for persistent storage |
| `backend_store_uri` | `sqlite:///mlflow.db` | MLflow backend store URI |
| `default_artifact_root` | `/mlflow/artifacts` | Root for model artifacts |
| `host` | `0.0.0.0` | Bind address |
| `workers` | `4` | Number of gunicorn workers |

## Access

Once running, the MLflow UI is available at:
`http://<home-assistant-ip>:5000`

## Usage from Home Assistant

Use the Home Assistant REST API or Python scripts to log experiments:

```python
import mlflow
mlflow.set_tracking_uri("http://<ha-ip>:5000")
mlflow.set_experiment("home-assistant-ml")
```

## License

MIT
