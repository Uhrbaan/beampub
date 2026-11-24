# 🪐 BeamPub

**BeamPub** is a minimalist, federated micro-social network built in Elixir on top of the BEAM (OTP) and Phoenix LiveView. Designed to interoperate with the Fediverse (Mastodon, Pleroma, etc.) via a core subset of the **W3C ActivityPub** specification, it models users and remote instances as lightweight, concurrent Erlang processes (`GenServer`).

## 🏗️ Project Architecture & Structure

BeamPub strictly separates **pure OTP domain logic** (`lib/beampub/`) from the **HTTP/WebSocket web layer** (`lib/beampub_web/`).

```text
.
├── assets/                     # Frontend Tailwind CSS & Phoenix LiveView JS glue
├── config/                     # Environment configurations (dev, test, prod, runtime)
├── priv/                       # Static assets (images, favicons, compiled CSS/JS)
├── test/                       # Unit and integration tests
└── lib/
    ├── beampub/                # 🧠 CORE DOMAIN (Pure Elixir & OTP, zero HTTP/HTML dependencies)
    │   ├── application.ex      # Root supervision tree (PubSub, Registry, DynamicSupervisor, Endpoint)
    │   ├── social/             # Actor-model social engine
    │   │   ├── actor.ex        # GenServer representing a local user's state & mailbox
    │   │   ├── actor/
    │   │   │   ├── inbox.ex    # Pure state transitions for incoming activities (Create, Follow, Accept)
    │   │   │   └── outbox.ex   # Pure state transitions for outgoing user actions (publish, follow)
    │   │   ├── directory.ex    # Polymorphic router (resolves local users vs. remote server proxies)
    │   │   ├── remote.ex       # Proxy GenServer batching outbound federation per domain (Shared Inbox)
    │   │   └── supervisor.ex   # DynamicSupervisor managing Actor & Remote process lifecycles
    │   └── activitypub/        # W3C ActivityPub & ActivityStreams 2.0 protocol layer
    │       ├── activities/     # Structs for Activity wrappers (Create, Follow, Accept, Like, Announce)
    │       ├── objects/        # Structs for content objects (Note)
    │       ├── serializer.ex   # Translates JSON-LD <-> Elixir Structs
    │       ├── signatures.ex   # HTTP Signatures (RSA key generation, signing, verification)
    │       └── client.ex       # Outbound HTTP client for delivering activities to remote inboxes
    │
    └── beampub_web/            # 🌐 WEB & UI LAYER (Phoenix & LiveView)
        ├── endpoint.ex         # HTTP/WebSocket entry point (Bandit)
        ├── router.ex           # Maps URLs to LiveViews (UI) and Controllers (ActivityPub JSON)
        ├── live/               # Real-time LiveView UI modules (e.g., TimelineLive)
        ├── controllers/        # REST/JSON endpoints for federation (/inbox, /users/:id, webfinger)
        └── components/         # Reusable HEEx templates & Tailwind UI components
```

## 🔄 How Data Flows

BeamPub handles two types of traffic seamlessly inside the same BEAM VM:

1. **Real-Time Browser UI (Phoenix LiveView):**
* Each connected browser tab runs as a stateful LiveView process.
* User actions (posting a note, following someone) call the `BeamPub.Social.Actor` API directly.
* When an `Actor` receives a new activity in its `Inbox`, it broadcasts over `Phoenix.PubSub`, pushing live HTML diffs over WebSockets to connected browsers.


2. **Fediverse Interoperability (ActivityPub):**
* **Inbound:** External servers (like Mastodon) send signed JSON-LD payloads to `POST /users/:username/inbox`. A Phoenix Controller verifies the signature, deserializes the JSON into an Elixir struct (`%Create{}`, `%Follow{}`, etc.), and casts it to the target `Actor` GenServer.
* **Outbound:** `Social.Directory` routes deliveries transparently. Local handles resolve to local `Actor` PIDs, while remote handles (`@user@mastodon.social`) resolve to a domain-level `Remote` proxy GenServer that deduplicates and delivers JSON-LD payloads via HTTP `POST`.

## 🚀 Getting Started

### Prerequisites

* **Elixir** 1.15+ & **Erlang/OTP** 26+
* *(Optional, for live federation testing)* **[ngrok](https://ngrok.com/)** or a public HTTPS domain

### Installation & Running Locally

1. **Install dependencies and build assets:**
```bash
mix setup
```


2. **Start the Phoenix server:**
```bash
mix phx.server
```


Or start it inside an interactive Elixir shell (`iex`) to inspect processes directly:
```bash
iex -S mix phx.server
```


3. **Open the app:**
Visit [`http://localhost:4000`](http://localhost:4000) in your browser.

### Testing Federation Locally (with ngrok)

ActivityPub servers require `https://` to communicate:

1. Expose your local port 4000:
```bash
ngrok http 4000
```


2. Start Phoenix with your ngrok host configured:
```bash
PHX_HOST=your-subdomain.ngrok-free.app iex -S mix phx.server
```

## 🧪 Running Tests

```bash
mix test
```

--- 

Right now to test the program out, first run the web server: 

```sh 
iex -S mix phx.server
```

and then inside of the iex env, you can start two actors manually and send messages between them (notice that the actor that displays on the website is alice):

```ex
alias BeamPub.Social.Actor

Actor.start_link("alice")
Actor.start_link("bob")

Actor.follow("alice", "bob")
Actor.publish("bob", "Hello Alice! Live from iex!")
```