
# URL Shortener (Rails + Postgres)

This is a simple URL shortener built with Ruby on Rails (API mode) and PostgreSQL.  
It provides two main endpoints:

- `POST /encode` → Takes a long URL and returns a shortened URL.
- `GET /decode?short_code=<short_url_or_code>` → Takes a short URL (or just the short code) and returns the original long URL.

It also serves a minimal HTML frontend from `public/index.html` for manual testing.

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/zeinaMnada/url_shortener.git
cd url-shortener
```

### 2. Install Dependencies

Make sure you have Ruby (≥3.2), Bundler, and PostgreSQL installed.

```bash
bundle install
```

### 3. Environment Variables

We use dotenv-rails
 to manage environment variables.

Create a .env file in the project root:

```bash
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=secret
DATABASE_HOST=localhost
DATABASE_NAME=url_shortener_development
SECRET_KEY_BASE=rails_secret
DATABASE_URL=prod_db_url
```
Replace with your local Postgres username/password.

### 4. Setup Database

```bash
rails db:create
rails db:migrate
```
### 5. Run the Server

```bash
rails server
```

The app will be running at:
👉 http://localhost:3000

## 🧪 Running Tests

We use Minitest (default in Rails).

```bash
rails test
```

This runs:

  - Unit tests for services [short code generation, URL validation, Base62 converter, and also Link encode/decode]

  - Model tests

  - Controller/API tests
    
## 🔗 API Usage
Encode (Shorten a URL)

Request

```bash
curl -X POST http://localhost:3000/encode \
  -d "long_url=https://rubyonrails.org"
```

Response

```bash
{
  "short_url": "http://localhost:3000/abc1234"
}
```

Decode (Expand a Short URL)

Request

```bash
curl -X GET "http://localhost:3000/decode?short_code=http://localhost:3000/abc1234"
```

Response
```bash
{
  "long_url": "https://rubyonrails.org"
}
```

If the short code does not exist:
```bash
{
  "error": ["Not found"]
}
```

## 🖥 Frontend Interface

Open http://localhost:3000
 in your browser to use a minimal HTML interface for encoding/decoding URLs.

## 🚀 Deployment (Render)

This app is ready to deploy on Render
.

Steps

Push your code to GitHub (or GitLab/Bitbucket).

Create account on Render.

Connect your repository to Render.

Set up:

- A Rails Web Service (running the API + frontend).

- A PostgreSQL Database.

  Now move both to single project [setting server env vars with PostgresSQL DB url]

Render automatically runs (as config in server setting):

```bash
bundle install

rails db:migrate

rails server
```

After deployment, your app will be live at your Render domain, e.g.: https://your-app.onrender.com


Any future push to your repo’s main branch will trigger a new build and deployment.
