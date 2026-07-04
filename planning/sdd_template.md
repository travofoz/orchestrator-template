# Software Design Document
# Project: [PROJECT NAME]
# Version: 0.1.0
# Status: DRAFT | REVIEW | APPROVED
# Last Updated: YYYY-MM-DD

---

## 1. Executive Summary

**System Name**: 
**Version**: 
**Mission**: 
**Primary Users**: 
**Key Success Metric**: 

---

## 2. System Context & Boundaries

### In Scope


### Out of Scope


### External Integrations

| System | Direction | Protocol | Notes |
|--------|-----------|----------|-------|
| | reads from / writes to | | |

### System Boundary Diagram

```
[Draw ASCII or Mermaid diagram here]
```

---

## 3. Functional Requirements

<!-- Format: FR-NNN: <verb> <object> <measurable condition> -->

- **FR-001**: 
- **FR-002**: 
- **FR-003**: 

---

## 4. Non-Functional Requirements

**Performance**:
- Latency: p50 = , p95 = , p99 = 
- Throughput: req/s or records/s

**Reliability**:
- Uptime target: 
- MTTR: 
- Acceptable data loss window: 

**Security**:
- Authentication: 
- Authorization: 
- Encryption at rest: 
- Encryption in transit: 

**Scalability**:
- Scaling model: horizontal / vertical / both
- Expected peak load: 
- Growth rate: 

**Observability**:
- Logs: structured (JSON) / plaintext, log level defaults
- Metrics: list key metrics
- Traces: yes / no
- Alerts: list critical alert conditions

---

## 5. Architecture & Design

### Component Diagram

```
[ASCII or Mermaid diagram]
```

### Data Flow


### Key Design Decisions

| Decision | Chosen Approach | Alternatives Considered | Rationale |
|----------|----------------|------------------------|-----------|
| | | | |

### Technology Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Language | | |
| Framework | | |
| Database | | |
| Auth | | |
| Deployment | | |

---

## 6. Data Model

### Core Entities


### Relationships


### Schema

```sql
-- or struct definitions, JSON Schema, etc.
```

### Data Lifecycle


---

## 7. API / Interface Design

### Endpoints / Commands

<!-- REST example: -->
```
GET  /api/v1/resource      — List all resources
POST /api/v1/resource      — Create resource
GET  /api/v1/resource/:id  — Get by ID
PUT  /api/v1/resource/:id  — Update
DELETE /api/v1/resource/:id — Delete
```

### Request / Response Shapes


### Auth Model


### Error Format

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Human-readable description",
    "details": {}
  }
}
```

---

## 8. Error Handling & Failure Modes

| Dependency | Failure Mode | Retry Strategy | User Experience |
|------------|-------------|----------------|-----------------|
| | | | |

---

## 9. Testing Strategy

**Unit Tests**: Coverage target = %

**Integration Test Scenarios**:
1. 
2. 

**End-to-End Test** (what a human does to verify):


**Performance Test** (how to verify NFRs):


---

## 10. Deployment & Operations

**Build Artifact**: binary / container / package

**Deployment Target**:

**Required Environment Variables**:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| | | yes/no | |

**Health Check**:

**Rollback Procedure**:

---

## 11. Phase Breakdown

| Phase | Name | Deliverable | Acceptance Test | Estimate |
|-------|------|-------------|-----------------|----------|
| 01 | Scaffolding | Compiling skeleton | `make build` exits 0 | |
| 02 | | | | |
| NN | Integration Tests | Full E2E suite | All tests green | |
