## Plugin Tool Mapping

Reference for migrating from the DataRobot Agent Assist plugin to this Claude skill. Claude's built-in tools replace the plugin's custom Python tools:

| Plugin Tool | Claude Tool |
|---|---|
| `read_file` | Read |
| `write_file` | Write |
| `edit_file` | Edit |
| `shell` | Bash |
| `list_dir` | Glob or Bash (`ls`) |
| `grep_files` | Grep |
| `glob` | Glob |
| `web_search` | Search the web |
| `get_web_page` | Fetch the page |
| `write_todos` / `read_todos` | Keep a short checklist |
| `show_agent_spec` | Write to `<target_dir>/agent_spec.md` + display as YAML |
| `prepare_to_code` | Bash (`git clone` + `dr start`) |
| `list_available_models` | Fetch the page (DataRobot API) |
| `code_research` | Agent (Explore subagent) |
| Agent simulation (dress rehearsal) | [Dress Rehearsal](../SKILL.md#dress-rehearsal) + `<skill_scripts_dir>/rehearsal.py` |
