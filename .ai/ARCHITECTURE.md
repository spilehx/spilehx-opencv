# Architecture map

`src/HomeSharedDash.hx` creates `HomeSharedDashApplication` on the native target or `HomeSharedDashClient` on JavaScript. Server modules live in `spilehx.homeshareddash`; client modules live in `spilehx.homeshareddashclient`. Shared data objects and build tools remain in `spilehx.dataobjects` and `spilehx.buildtools`.

## Settings and metadata

`NewSettings` exposes nine classes scanned from `src/settings` by the unchanged SettingsBuilderMacro: ManagerSettings, EventLogSettings, ClientStyleSettings, ClientLayoutSettings, StorageSettings, RestServerSettings, SideBarSettings, TypographySettings and StaticDataValueSettings. Preserve target conditionals and keep helper classes outside the scanned package.

`HomeSharedDashDataObjectCore` supplies IDs, timestamps, serialization, hydration, validation hooks and metadata types. Register every future concrete class in `StaticDataValueSettings.DATA_OBJECT_TYPES`. The initial registration contains the base's empty editable fields and hidden lastUpdated/id display fields. `StaticValuesDataObject` provides local settings-backed lookups on both targets. Shared arrays are read-only by convention. Static metadata is filtered during serialization; hydration ignores embedded static fields.

## Server lifecycle and storage

Startup configures logging and signal polling, initializes AssetManager, ManagerController, EventLogManager and FileManager in that order, then registers RestServerManager with ThreadedServiceManager. Generic critical-service callbacks and threaded shutdown remain.

ManagerCore is a timer-driven singleton lifecycle with WAITING, STARTING, IDLE, WORKING and ERROR states. `addBlockedBy` gates setup until blockers are IDLE; `addDependency` gates periodic updates only. Retain callback completion and configured intervals/retry limits. ManagerController has no setup blocker: its setup registers FileManager as an update dependency and immediately completes through the base. EventLogManager and FileManager block setup on the controller, avoiding a cycle.

ManagerController is the sole retained manager topic listener. EVENT_INFO/WARN/ERROR log locally and post EVENT_LOG_TOPIC through the server Dispatcher; the controller forwards to EventLogManager, which assigns IDs and trims history. ThreadedServiceManager pumps dispatcher delivery. Diagnostic file logging remains separately configured and is disabled by default.

FileManager creates `homeshareddash/`, keeps an initially empty folder-key map, and processes queued generic file actions. Future folders need a key and constructor registration. CachedManagerCore retains DataCacher and metadata-driven editing, but no concrete cached manager is initialized. Future subclasses call `enableDataCache(folderKey, dataClass)` during setup, arrange setup blockers/update dependencies and initialize in the application in dependency order.

DataCacher owns its in-memory map after initial loading. Mutations must pass through saveEntry to update timestamps and dirty state; batch with saveEntry(entry, false) then persistCacheToFile. Entries sort by ID for comparison while nested array order remains unchanged. Writes are skipped when unchanged, and failed persistence retains pending changes. Recovery retains loaded memory and retries pending writes. Migration hooks, notifications, revision counters and Unicode JSON handling remain. These semantics do not guarantee atomic persistence.

## HTTP

RestServerManager registers MainRoute, ResourcesRoute, LogsRoute and GetEventLogsRoute. HTTPServer keeps request validation, parsing/body limits, threading and generic bytes/HTML/JSON responses. Route and RestDataObject retain native/browser conditionals and call/callWithBytes helpers. Endpoints have no authentication; see API.md.

Future routes extend Route in the server routes package, define path/data/method, implement native handling under `#if !js`, and expose typed browser helpers under `#if js`. Register them in RestServerSettings. UI consumers use a matching static wrapper in HomeSharedDashClientComms with the route's typed response/error callbacks. AssetManager retains its existing direct resource-route usage. PublicUrlUtil retains site-root environment/fallback resolution with no initial caller; ServerEnvironmentUtil resolves the bind host.

## Browser and reusable UI

DOM readiness leads to successful AssetManager initialization, Toolkit/HaxeUIApp setup, the ready callback, app.start and exactly one MainPage. Failed asset loading logs an error and does not open the page. MainPage is a full-area ComponentCore box using the generic app background. Navigation sections are an empty typed array; reusable components are retained without demonstrations.

ComponentCore uses normal HaxeUI SHOWN/HIDDEN events: setupComponentUI and populate run when shown; cleanupComponent runs when hidden. Preserve those hooks, styling and callbacks. New components should extend the nearest existing implementation, use an inline XML box root when applicable, and explicitly include setupComponentUI, populate and cleanupComponent overrides in that order. Register XML-visible components in module.xml; it initially contains eight generic controls.

Reuse UIButton for actions, AppLabel for typography, ValueField for metadata-based values, ImageDisplayComponent for images, DetailsListComponent for field lists, MainSideBar for navigation, and existing table filters/UI effects. AppLabel's String styleID selects one of six configured String IDs in TypographySettings; types remain in AppLabel.hx. Generic sans-serif emits unquoted CSS; named families remain quoted.

AppModal and AppModalContent support direct open/close, validation and submission callbacks. Extend setupModal to configure shell/content; the constructor supplies modalData. Validation can prevent dismissal. Apply/Cancel callbacks run after successful validation and dialog closure; they do not wait for asynchronous requests. Account explicitly for cleanup on dismissal: direct close does not explicitly invoke content cleanup. There is no global modal owner or custom client event bus.

This template was statically inspected only; build and runtime validation require explicit authorization. Preserve the existing architecture and algorithms instead of adding alternative frameworks or sample workflows.
