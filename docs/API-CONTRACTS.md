# API Contract Toolchain

AI Stack Matspectrum treats API contracts as executable engineering artifacts, not prose for the agent to interpret.

Install the optional toolchain:

```bash
ai-stack toolchain api-contracts
```

It installs:

- **Spectral** (`@stoplight/spectral-cli`) for deterministic OpenAPI/JSON/YAML linting.
- **OpenAPI Generator CLI** (`@openapitools/openapi-generator-cli`) for schema validation and optional SDK/server generation.
- **oasdiff** when Go is already available, for OpenAPI breaking-change detection.

Schemathesis is recommended as an additional property-based API verifier, but is not auto-installed because it introduces a Python toolchain dependency.

## Recommended contract loop

```text
OpenAPI source of truth
        |
        v
spectral lint
        |
        v
breaking-change check (oasdiff)
        |
        v
server implementation
        |
        v
integration / contract tests
        |
        v
property-based API tests (Schemathesis, optional)
        |
        v
generated client validation (when codegen is used)
```

## Minimal commands

Assume the contract is `openapi.yaml`.

Lint:

```bash
spectral lint openapi.yaml
```

Validate with OpenAPI Generator:

```bash
openapi-generator-cli validate -i openapi.yaml
```

Generate a client only when the project intentionally uses generated clients:

```bash
openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-fetch \
  -o generated/client
```

Do not commit generated output unless the project's architecture explicitly treats generated clients as source-controlled artifacts.

## Breaking changes

If `oasdiff` is installed:

```bash
oasdiff breaking base-openapi.yaml openapi.yaml --fail-on ERR
```

For CI, compare the current contract against the contract on the target/base ref and fail on breaking changes according to the project's compatibility policy.

The important property is not the exact command: a breaking-change policy should be machine-enforced instead of relying on an agent to remember semantic-versioning rules.

## Runtime verification

A valid OpenAPI file does not prove the implementation matches it.

Add contract/E2E verification against the running API. For property-based testing, Schemathesis is a strong OSS option:

```bash
# Install with your preferred Python environment/tool manager, then:
schemathesis run openapi.yaml --url http://localhost:3000
```

Pin the tool/version in CI rather than using an unbounded `latest` install in production pipelines.

## Agent policy

For API work, the coding agent should:

1. Read the relevant spec/acceptance criteria.
2. Update the OpenAPI contract before or together with behavior changes.
3. Run deterministic lint/validation.
4. Implement the server/client change.
5. Run unit/integration/contract tests.
6. Check for breaking API changes.
7. Only declare completion when evidence passes.

Avoid a generic "API expert" skill when a contract and executable validators can encode the requirement more reliably.

## Sources

- Spectral: https://github.com/stoplightio/spectral
- OpenAPI Generator: https://github.com/OpenAPITools/openapi-generator
- oasdiff: https://github.com/oasdiff/oasdiff
- Schemathesis: https://github.com/schemathesis/schemathesis
