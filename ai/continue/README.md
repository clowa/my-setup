# ~/.continue

Global configuration for the [Continue](https://continue.dev) VSCode extension.

## Models

| Model                  | Role              | Provider                                                                               |
|------------------------|-------------------|----------------------------------------------------------------------------------------|
| Apple Foundation Model | Autocomplete      | Local — [apfel](https://github.com/Arthur-Ficial/apfel) on `http://localhost:11434/v1` |
| _GPT Models_           | Chat, Edit, Apply | OpenAI                                                                                 |

## API Key Setup

API keys are stored in 1Password and are **not** hardcoded in `config.yaml`. The config uses Continue's secret interpolation syntax (`${{ secrets.X }}`), which resolves values from a local `.env` file that is never committed.

### First-time setup

1. Install the [1Password CLI](https://developer.1password.com/docs/cli/get-started/) and sign in:

   ```bash
   op signin
   ```

2. Generate the `.env` file from the 1Password template:

   ```bash
   op inject -i ~/.continue/.env.tpl -o ~/.continue/.env
   ```

### Rotating the API key

Update the key in 1Password, then re-run the inject command above.
