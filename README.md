# reward-hack

Reproducing and extending METR's reward hacking detection experiments.

## Installation

```bash
uv sync
```

## Usage

Score an Inspect AI evaluation log using model-graded QA scorer:

```bash
uv run score path/to/eval.log
```

Use a specific grading model:

```bash
uv run score path/to/eval.log --model openai/gpt-5
```

The scored evaluation log will be saved with a timestamped suffix.
