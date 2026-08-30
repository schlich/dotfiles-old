{ inputs }:

{
  archify = "${inputs.archify}/archify";

  # Project-specific skills remain available from the repository's .agents/skills directory.
  # jj = ../../../.agents/skills/jj;
  # nu = ../../../.agents/skills/nushell;
}
