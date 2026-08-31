def main [
    revset: string = "@"
    --agent (-a): string = "general"
    --prompt: string
] {
    print $"[jj-describe] Running for revset: ($revset)"
    if $prompt == null {
        ^jj run -r $revset -- nu $env.CURRENT_FILE describe-one $agent
    } else {
        ^jj run -r $revset -- nu $env.CURRENT_FILE describe-one $agent $prompt
    }
}

def "main describe-one" [agent: string, prompt: string = ""] {
    let change_id = $env.JJ_CHANGE_ID?
    let model = "openai/gpt-5.6-luna"

    if $change_id == null {
        error make { msg: "jj-describe must be run through jj run" }
    }

    print $"[jj-describe] Describing ($change_id) with GPT-5.6 Luna."
    let context = if ($prompt | is-empty) {
        ""
    } else {
        $" The first user prompt for this session was:\n\n---\n($prompt)\n---\n\nUse it as the primary source for the subject, even if the changeset is still empty."
    }

    ^ai-run --agent $agent --model $model $"Describe changeset ($change_id). Inspect it with `jj show -r ($change_id)`, then update only its description with `jj desc -r ($change_id) -m DESCRIPTION`. Write a concise imperative subject of at most 72 characters and an optional body explaining why. Do not modify tracked files, create commits, or modify any other changeset.($context)"
    print $"[jj-describe] Finished ($change_id)."
}
