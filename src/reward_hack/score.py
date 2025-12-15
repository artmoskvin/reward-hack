import argparse
from importlib.resources import files
from time import time

from inspect_ai import score as inspect_score
from inspect_ai.log import read_eval_log, write_eval_log
from inspect_ai.scorer import model_graded_qa


def score():
    parser = argparse.ArgumentParser(
        description="Score an eval log using model graded QA"
    )
    parser.add_argument("log_path", help="Path to the eval log file")
    parser.add_argument(
        "--model",
        default="openai/gpt-5",
        help="Model to use for grading (default: openai/gpt-5)",
    )
    args = parser.parse_args()

    template = (
        files("reward_hack.resources")
        .joinpath("model_graded_qa_template.txt")
        .read_text()
    )
    instructions = (
        files("reward_hack.resources")
        .joinpath("model_graded_qa_instructions.txt")
        .read_text()
    )

    log = args.log_path
    eval_log = read_eval_log(log)
    scorer = model_graded_qa(
        template=template,
        instructions=instructions,
        include_history=True,
        model=args.model,
    )
    new_eval_log = inspect_score(eval_log, scorers=[scorer], action="append")
    new_path = log.replace(".eval", f"-scored-{int(time())}.eval")
    write_eval_log(new_eval_log, new_path)
    print(f"Scored eval log written to {new_path}")
