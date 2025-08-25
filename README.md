# WallaMarvel

*A tiny, modular iOS app that lists Marvel heroes and shows their details.*

## Overview
WallaMarvel uses the public Marvel API to display a **Heroes List** with infinite scrolling and a **Hero Details** screen with extra information about a selected hero. The project is organized into multiple Swift Package Manager (SPM) modules for clean separation of concerns and easy reuse.

## Tech Stack
- **SwiftUI**
- **Swift Package Manager (SPM)**
- **Structured Concurrency (async/await)**
- **iOS 15+**

## Module Dependency Graph

![Module dependency graph](docs/dependency-graph.png)

### Notes about the modules graph
- All the red color are not implemented, but it is here show how would I make higher decoupling between domain layer and presentation layer
- **HeroesCoreAPI** - should be module that own only the shared types that both layers (domain and UI) needs to know in order to communicate with each other
- **HeroesCoreAPI** - must only have the public Types and Protocols used cross layer communication.
- **HeroesCoreAPI** - must have NO implementation 
- by doing this arrows going down from the low level module(UI) would not pass to the higher level module (Domain), both will depend on abstraction

## Modules
The app is highly modularized using SPM:

- **DesignSystem** — Centralizes visual language and reusable UI components; provides design guidelines and principles.
- **NetworkClient** — App-agnostic HTTP client with optional middleware support.
- **AppConfig** — Centralized configuration for the app, all the configuration the modules needs from the app.
- **HeroesCore** — Data & domain layer for heroes (repositories, services, models). UI-agnostic and reusable.
- **Heroes** — Feature module that renders the **Heroes List** with pagination.
- **HeroDetails** — Feature module that renders the **Hero Details** view.
- **UnitTestingUtils** — Shared utilities used by unit tests across modules.
- **NetworkStubsUITestUtils** — setting up and defining stubs for running the UITests.

## Architecture
**MVVM + Repository + Coordinator**

- **MVVM** for feature UIs  
- **Repository** in `HeroesCore` to abstract data sources  
- **Coordinator** to drive navigation between screens

## Caching & Offline Behavior
To provide a smooth, offline-friendly experience:

- Each fetched page from the backend is **stored in cache**.
- On app launch, we **preload all cached pages** immediately, while **refreshing the same pages from the network** in the background.
- The cache is **evicted on each launch** and repopulated from remote data to keep it consistent with the backend.
- The API limits responses to **100 heroes per call**. We perform **multiple sequential calls** when needed (e.g., 240 cached items → 3 requests).
- **First-ever launch while offline:** show a retry error view.
- **Subsequent launches while offline:** show the cached list.
- **Paginating while offline:** show a small retry view at the end of the list.
- **Race-safety:** if the user scrolls to paginate while the initial cache refresh hasn’t finished, we **defer pagination** until the refresh completes.

## Testing
- **Snapshot Tests** — only `DesignSystem` components are covered with snapshot tests. to be improved, cover important screen with this type of testing to make sure that grouping the components in one screen are placed properly 
- **Unit Tests** — Each module ships its own unit tests for core logic.
- **UI Tests** — Live in the app target and cover the core user flow.

## CI
- It is work in progress on brach `MRVL-16/feature/added-ci`
- I am using Github Actions
- The file is structured with steps that the workflow would do when a Job runs 
- Just created one to run all the tests including the UITests with any PR review, but ideally in real world, I would makes only unit tests runs with PR review and UITests to run only before the release or at scheduled times  
