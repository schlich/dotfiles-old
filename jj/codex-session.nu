def state-path [session_id: string] {
    let state_dir = ($env.XDG_STATE_HOME? | default ($env.HOME | path join ".local" "state"))
    $state_dir | path join "codex-jj-sessions" $"($session_id).json"
}

def main [event: string] {
    if ($env.CODEX_JJ_SESSION_HOOK? | default "") == "1" {
        return
    }

    let hook = (open --raw /dev/stdin | from json)
    let cwd = $hook.cwd? | default ""
    let session_id = $hook.session_id? | default ""

    if ($cwd | is-empty) or ($session_id | is-empty) {
        return
    }

    match $event {
        "session-start" => {
            if ($hook.source? | default "") != "startup" {
                return
            }

            # Startup can be emitted again for an existing session. Keep its marker
            # after naming so subsequent starts and prompts remain no-ops.
            let path = (state-path $session_id)
            if ($path | path exists) {
                return
            }

            let root = (^jj --repository $cwd root | complete)
            if $root.exit_code != 0 {
                return
            }

            let created = (^jj --repository $cwd new -m "Codex session" | complete)
            if $created.exit_code != 0 {
                error make { msg: $"Could not start a fresh JJ change: ($created.stderr | str trim)" }
            }

            let change_id = (^jj --repository $cwd log -r @ --no-graph -T "change_id" | str trim)
            mkdir ($path | path dirname)
            {
                cwd: $cwd
                change_id: $change_id
                described: false
            } | to json | save --force $path
        }
        "first-prompt" => {
            let path = (state-path $session_id)
            if not ($path | path exists) {
                return
            }

            let state = (open $path)
            if ($state.described? | default false) {
                return
            }

            let described = (
                with-env { CODEX_JJ_SESSION_HOOK: "1" } {
                    ^jj-describe $state.change_id --prompt ($hook.prompt? | default "") | complete
                }
            )
            let description = (
                ^jj --repository $state.cwd log -r $state.change_id --no-graph -T "description.first_line()"
                | str trim
            )

            if $described.exit_code != 0 or ($description | is-empty) {
                {
                    decision: "block"
                    reason: $"Could not name the new JJ change. ($described.stderr | str trim)"
                } | to json
                return
            }

            $state | upsert described true | to json | save --force $path
        }
        _ => {
            error make { msg: $"Unknown Codex JJ hook event: ($event)" }
        }
    }
}
