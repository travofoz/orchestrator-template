# Future Phases

Place your phase specification files (`.md`) in this directory.

Each file should contain a complete, standalone requirement specification with a `# Tasks` header and checkbox items (`- [ ]`) defining the work for one phase of your project.

**Naming Convention**: Use a zero-padded numeric prefix to control execution order:
- `01_project_scaffolding.md`
- `02_core_data_models.md`
- `03_api_endpoints.md`
- `04_frontend_views.md`
- `05_integration_tests.md`

The supervisor will process these files in lexicographic order, copying each one to `specs/current_phase.md` before launching the inner loop engine.
