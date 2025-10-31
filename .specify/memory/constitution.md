<!--
Sync Impact Report:
Version Change: N/A → 1.0.0 (Initial Constitution)
Modified Principles: N/A (Initial creation)
Added Sections: All (Initial creation)
  - Core Principles (9 principles)
  - Quality Standards
  - Development Workflow & Collaboration
  - Governance
Removed Sections: N/A
Templates Requiring Updates:
  ✅ plan-template.md - Constitution Check section already compatible
  ✅ spec-template.md - User Stories and Requirements align with educational focus
  ✅ tasks-template.md - Test-driven approach and phase organization compatible
Follow-up TODOs: None
-->

# Codedly Mobile App Constitution

## Core Principles

### I. Clean Code & Architecture (NON-NEGOTIABLE)

**Rules:**

- MUST follow SOLID principles: Single Responsibility, Open-Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- MUST apply DRY (Don't Repeat Yourself) and KISS (Keep It Simple, Stupid) principles consistently
- MUST organize code into clear architectural layers:
  - **Presentation Layer**: UI components, screens, widgets (Flutter)
  - **Domain Layer**: Business logic, use cases, entities (framework-agnostic)
  - **Data Layer**: Repositories, data sources, API clients, local storage
- MUST ensure each class/module has a single, well-defined responsibility
- MUST maintain clear separation of concerns between layers
- MUST make code easy to maintain, extend, and understand by new developers

**Rationale:** Clean architecture ensures the codebase remains maintainable as the app grows. Clear layer separation allows for independent testing, easier refactoring, and better collaboration among team members. Following SOLID principles prevents tight coupling and makes the code more adaptable to change.

### II. State Management & Dependency Injection

**Rules:**

- MUST use a scalable, reactive state management solution (Riverpod or BLoC)
- MUST implement Dependency Injection using GetIt or equivalent DI framework
- MUST keep UI logic separate from business logic at all times
- MUST write testable code where services and controllers can be mocked or stubbed
- MUST NOT allow direct instantiation of dependencies within widgets or use cases
- MUST define clear interfaces for all services and repositories
- MUST ensure state changes are predictable, traceable, and reactive

**Rationale:** Proper state management keeps the UI responsive and maintainable. Dependency injection enables testing by allowing mock implementations and ensures loose coupling between components. Separating UI from business logic prevents Flutter framework dependencies from infecting the domain layer.

### III. UI/UX Quality & Design System

**Rules:**

- MUST adopt a Duolingo-inspired design: engaging, playful, easy to navigate
- MUST implement strict dark mode theme with high contrast and vibrant color accents
- MUST organize content by levels or modules for progressive learning
- MUST ensure interface is clean, readable, and age-appropriate for school students
- MUST provide instant visual feedback: animations, progress indicators, celebratory effects
- MUST use friendly, encouraging language throughout the app
- MUST maintain consistent spacing, typography, and component patterns
- MUST design for learner motivation: clear progress visibility, achievable goals

**Rationale:** Students learn best when engaged and motivated. A playful, well-designed interface reduces cognitive load and keeps learners coming back. Consistent design patterns make the app intuitive, while instant feedback reinforces positive learning behaviors.

### IV. Localization & Internationalization

**Rules:**

- MUST implement full bilingual support: Bahasa Indonesia and English
- MUST use Flutter internationalization best practices (ARB files via flutter_localizations)
- MUST externalize ALL user-facing text strings (no hardcoded text in widgets)
- MUST prepare assets and content for localization (images with text variants if needed)
- MUST allow users to switch languages dynamically within the app
- MUST ensure proper text directionality and layout for supported locales
- MUST localize error messages, hints, and educational content

**Rationale:** Supporting both Indonesian and English makes the app accessible to a wider audience and respects the multilingual context of Indonesian students. Proper internationalization from the start avoids costly refactoring later.

### V. Educational Effectiveness & Content Quality (NON-NEGOTIABLE)

**Rules:**

- MUST ensure all content is age-appropriate for middle and high school students
- MUST organize lessons progressively: basic Python → intermediate programming → introductory data science
- MUST break down concepts into small, digestible, sequential steps
- MUST provide clear instructions, examples, and hints for each lesson
- MUST validate user code submissions and provide meaningful feedback
- MUST encourage hands-on coding practice and exploration
- MUST avoid overwhelming learners with too much information at once
- MUST design exercises that build on previous concepts (scaffolded learning)

**Rationale:** The primary goal is effective learning. Content must be pedagogically sound, scaffolded properly, and engaging. Students need clear guidance and immediate feedback to build confidence and competence in programming.

### VI. Gamification & Learner Engagement

**Rules:**

- MUST implement XP (Experience Points) system for rewarding progress
- MUST display user level, current XP, and progress to next level prominently
- MUST track and display streaks (consecutive days of practice)
- MUST provide celebratory feedback on achievements: level-ups, completed modules, milestones
- MUST use visual cues (badges, animations, progress bars) to celebrate success
- MUST make progression visible and achievable to maintain motivation
- MUST balance challenge and reward to keep learners in the "flow zone"
- MUST NOT introduce punitive mechanics that discourage learners

**Rationale:** Gamification leverages intrinsic motivation and provides extrinsic rewards that keep learners engaged. Clear progression systems give students goals to work toward and a sense of accomplishment, increasing retention and completion rates.

### VII. Security & Privacy

**Rules:**

- MUST use Supabase Auth securely for user authentication
- MUST protect user data: encrypt sensitive information at rest and in transit
- MUST follow privacy best practices: minimal data collection, clear privacy policy
- MUST validate and sanitize ALL user input, especially code submissions
- MUST implement secure storage for authentication tokens and user credentials
- MUST NOT expose API keys or secrets in client code
- MUST implement proper authorization checks for protected resources
- MUST comply with data protection regulations (e.g., GDPR, Indonesian privacy laws)

**Rationale:** Students and parents trust us with personal information. Security breaches or privacy violations can cause serious harm and legal liability. Secure authentication and data handling are non-negotiable for a responsible educational app.

### VIII. Testing & Quality Assurance (NON-NEGOTIABLE)

**Rules:**

- MUST write unit tests for all business logic (domain layer and use cases)
- MUST write widget tests for critical UI components and user flows
- MUST achieve minimum 70% code coverage for domain and data layers
- MUST use Continuous Integration (CI) to run tests automatically on every commit
- MUST NOT merge code that breaks existing tests
- MUST adopt linting (flutter_lints or stricter) and fix all warnings
- MUST perform code reviews for all pull requests before merging
- MUST test on multiple devices and screen sizes (phones and tablets)
- MUST validate accessibility features (screen reader support, sufficient contrast)

**Rationale:** Quality assurance catches bugs early and prevents regressions. Automated testing provides confidence when refactoring or adding features. Code reviews share knowledge and maintain code quality standards across the team.

### IX. Collaboration & Documentation

**Rules:**

- MUST use Git version control with clear, descriptive commit messages (Conventional Commits format preferred)
- MUST document key architectural decisions (ADRs - Architecture Decision Records)
- MUST provide usage documentation for reusable components and services
- MUST maintain onboarding documentation for new developers (setup guide, architecture overview)
- MUST write clear comments for complex algorithms or non-obvious logic
- MUST keep a changelog documenting notable changes in each release
- MUST conduct code reviews with constructive feedback
- MUST share knowledge through team discussions and documentation

**Rationale:** Collaboration depends on clear communication. Documentation ensures knowledge isn't locked in individual developers' heads. Good commit messages and ADRs provide context for future maintainers. Onboarding docs reduce friction for new team members.

## Quality Standards

### Performance & Responsiveness

- Target 60 FPS for animations and scrolling
- App startup time MUST be under 3 seconds on mid-range devices
- Code execution feedback MUST appear within 2 seconds
- Minimize network requests; use caching and offline-first strategies where appropriate

### Accessibility

- Support screen readers (Semantics widgets in Flutter)
- Ensure minimum contrast ratio of 4.5:1 for text (WCAG AA standard)
- Provide alternative text for images and icons
- Support text scaling for readability

### Code Quality Gates

- All linting rules MUST pass before merge
- No compiler warnings allowed in production builds
- Code review approval required for all pull requests
- Automated tests MUST pass in CI before merge

## Development Workflow & Collaboration

### Branch Strategy

- Use feature branches: `feature/<feature-name>`
- Use bugfix branches: `bugfix/<issue-number>-<description>`
- Main branch (`main` or `master`) MUST always be deployable
- Require pull requests for all changes to main branch

### Commit Message Format (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Code Review Requirements

- At least one approval required before merge
- Reviewer MUST verify compliance with constitution principles
- Reviewer MUST check test coverage and documentation
- Author MUST respond to all comments before merge

### Testing Gates

- Unit tests MUST pass locally before pushing
- CI MUST pass before merge (all tests, linting, build)
- Manual testing required for UI changes or critical features

### Documentation Requirements

- Every new feature MUST update relevant documentation
- Public APIs MUST have clear doc comments
- Architectural changes MUST create or update ADRs

## Governance

This constitution supersedes all other development practices and guidelines. All team members MUST adhere to these principles.

### Amendment Process

1. Proposed amendments MUST be documented with rationale
2. Amendments require team consensus or project lead approval
3. Major amendments MUST include migration plan for existing code
4. Amendment history MUST be tracked in this document

### Compliance

- All pull requests MUST verify compliance with constitution principles
- Code reviewers MUST enforce constitution rules
- Any deviation from principles MUST be explicitly justified and documented
- Complexity or architectural exceptions MUST be approved by tech lead

### Version Control

- Version follows MAJOR.MINOR.PATCH semantic versioning
- MAJOR: Backward incompatible principle changes or removals
- MINOR: New principles or materially expanded guidance
- PATCH: Clarifications, wording fixes, non-semantic refinements

**Version**: 1.0.0 | **Ratified**: 2025-10-31 | **Last Amended**: 2025-10-31
