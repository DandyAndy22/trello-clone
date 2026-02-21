# trello-clone

## About this Project

A Trello-inspired kanban board application for managing tasks and projects.

Getting my feet wet using Rails as an API only resource, Svelte on the frontend and using Bun for fun.

## Tech Stack

### Backend
- **Framework**: Rails 8.0.3
- **Language**: Ruby 3.4.5
- **Database**: PostgreSQL
- **Server**: Puma
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Deployment**: Kamal

### Frontend
- **Framework**: SvelteKit
- **Language**: TypeScript
- **Build Tool**: Vite
- **Package Manager**: Bun
- **Drag & Drop**: svelte-dnd-action
- **Testing**: Playwright (E2E), Vitest (Unit)

## Getting Started

### Prerequisites

- **Ruby 3.4.5** (recommended: use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/))
- **PostgreSQL** (9.3 or higher)
- **Bun** (latest version)

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install Ruby dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
bin/rails db:create
bin/rails db:migrate
```

4. (Optional) Seed the database:
```bash
bin/rails db:seed
```

5. Start the Rails server:
```bash
bin/rails server
```

The backend API will be available at `http://localhost:3000`

### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies using Bun:
```bash
bun install
```

3. Start the development server:
```bash
bun run dev
```

The frontend will be available at `http://localhost:5173`

### Running Both Services

From the root directory, you can run both backend and frontend simultaneously:

```bash
bun run dev
```

This will start:
- Backend API server on `http://localhost:3000`
- Frontend development server on `http://localhost:5173`

### API Endpoints

The API is available at `/api/v1`:

- `POST /api/v1/signup` - User registration
- `POST /api/v1/login` - User authentication
- `GET /api/v1/boards` - List all boards
- `POST /api/v1/boards` - Create a new board
- `GET /api/v1/boards/:id` - Get a specific board
- `GET /api/v1/boards/:board_id/lists` - Get lists for a board
- `POST /api/v1/boards/:board_id/lists` - Create a new list
- `GET /api/v1/lists/:list_id/cards` - Get cards for a list
- `POST /api/v1/lists/:list_id/cards` - Create a new card
- `PATCH /api/v1/cards/:id` - Update a card

## Deployment

Deployment configuration is set up using Kamal. See `backend/config/deploy.yml` for deployment settings.

For production deployment:
1. Configure your server details in `backend/config/deploy.yml`
2. Set up environment variables and secrets
3. Deploy using Kamal: `bin/kamal deploy`


