# NewsUK – iOS (UIKit, MVVM)

## Overview
**NewsUK** is a small sample app that fetches and presents the top 20 StackOverflow users based on their reputation score.
It presents basic details about the user
- Profile Icon
- Name and reputation
- Follow / Unfollow option - using UserDefaults indirectly through a protocol abstraction
Follow status persists across launches. The app handles loading, empty, and error states.

---

## Architecture
The app follows an **MVVM** architecture with protocol-based abstractions for testability and separation of concerns.
### Components
- **`UsersViewController`** – View layer which manages UI and states (loading/error/empty/data). Uses diffable data source for data presentation.
- **`UsersViewModel (via BaseUsersViewModel)`** – Business logic and state. Fetches users, maps network models to UI models, manages follow/unfollow through a service, caches image tasks, and exposes data snapshot to be used by table view data source
**`HTTPClient (BaseHTTPClient + HTTPService)`** - Networking abstraction around URLSession. Decodes JSON with a configurable JSONDecoder.
- **`FollowListService (view BaseFollowListService)`** – Local persistence of follow/unfollow status using UserDefaults.
### Models
- `UsersResponse`, `UserResponse` - Network models matching StackExchange API.
- `User`- UI model used by diffable data source.

## API
**Endpoint:**  
https://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow

## Design Decisions
- MVVM + Protocols: Keeps the controller clean and separates areas of concern (UI, Networking...). Improved testability by using protocols which enable mocks for network and persistence.
- Async/await: Simplifies networking and image loading with structured concurrency and cancellation.
- Local Persistence: UserDefaults is sufficient for keeping track of follow/unfollow state while still adhering to tech spec.

### Trade-offs and Future Improvements
- Image caching: Images are currently fetched each time - could add a cache provider which stores fetched images and reduces network requests
- Task keying: Image tasks are keyed by row index, instead tasks could be fetched by imageURL which with image caching could substantially reduce network load and load times in general
- UI polish: UI is a basic implementation, sufficient enough to be usable for this task
