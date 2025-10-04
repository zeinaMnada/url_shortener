
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

## 🚀 Scalability

As traffic grows, the system should evolve to handle higher load, ensure reliability, and maintain fast response times.
- Read operations (URL lookups) will far exceed writes (new URL creations), requiring optimization for heavy read traffic.
- The design must also guarantee uniqueness of short codes to prevent collisions and ensure data integrity.

### ⚡ Low Latency
- **Caching Layer (Redis):** Cache frequently accessed URLs to avoid hitting the database on every decode request.  
- **CDN Edge Caching:** Use CDNs (e.g., Cloudflare) to store and serve popular short links closer to users.  
- **Efficient Lookups:** Keep short codes indexed and limit URL table payload to reduce query time.  
- **Background Jobs:** Offload non-critical work (analytics, logging) to asynchronous queues like Sidekiq.

---

### 📈 Scale
- **Database Sharding / Partitioning:** Split data by short code ranges or hash keys to distribute load across multiple databases.
- **Read/Write Service Separation:** Split traffic between encode (write-heavy) and decode (read-heavy) operations into separate services or endpoints to optimize performance and scale each independently.
- **Horizontal Scaling:** Add multiple web and worker dynos to handle concurrent requests efficiently.
- **Distributed ID Generation:** Replace retry-based code generation with distributed unique ID systems to prevent collisions at scale.
- **Optionally Pre-generate Code Pools or Use Hashids:** Maintain a pool of pre-generated unique codes or use libraries like Hashids to deterministically encode IDs without exposing sequential patterns.
- **Stateless Generation Alternatives:** At larger scale, consider distributed ID generators to maintain uniqueness across multiple servers without central coordination.
- **API Versioning:** Support `/api/v1` and future `/api/v2` endpoints for forward-compatible upgrades without breaking existing clients.

---

### 💪 Availability
- **Load Balancing:** Distribute requests across multiple instances to prevent a single point of failure.  
- **Health Checks:** Keep `/health` endpoint monitored to ensure uptime and allow Render/Heroku to restart unhealthy instances.  
- **Replication:** Use database replicas for reads to ensure continuity during primary DB downtime.  
- **Retry & Fallback Logic:** Implement limited retries (as we do in short code generation) for transient failures.

---

### 🔄 Consistency
- **Unique Constraint Enforcement:** Ensure only one short code maps to each URL using database-level unique indexes.  
- **Atomic Operations:** Use transactions when creating URLs to avoid race conditions.  
- **Eventual Consistency for Cache:** Allow slight delays in cache updates are acceptable, as the priority is to keep read operations extremely fast while the cache and database eventually synchronize.
- **Monitoring & Auditing:** Add centralized logging and metrics to trace data inconsistencies early.

---

### 🌐 Future Enhancements
- **Custom Aliases:** Allow users to define their own short codes.  
- **Expiration Rules:** Enable time-bound or usage-based expiration of links.  
- **Analytics:** Add click tracking and geographic data collection for business insights.  


## 🔒 Security

Security is crucial for a URL shortener, since attackers could abuse open redirects, inject malicious URLs, or exploit predictable codes.  
Below are the major concerns, categorized and paired with how the current implementation mitigates them.

---

### 🧠 Input Validation
  **Malicious URL Injection:**
  - Attackers might try to shorten invalid or unsafe links (e.g., `javascript:` or local file URLs).  
  - **Mitigation:** `UrlValidator` service validates URLs before saving using Ruby’s `URI.parse, rejecting malformed links before any database operation.
    It can also be extended to blacklist malicious domains or integrate with threat intelligence APIs to block known phishing or harmful URLs.

  **XSS via URL Parameters:**
  - If URLs were directly rendered in HTML, they could inject scripts.  
  - **Mitigation:** The API returns JSON responses only, and Rails automatically escapes HTML in views.

---

### 🧱 Data Integrity & Predictability
  **Sequential ID Exposure:**
  - Predictable short URLs could reveal how many have been generated or allow enumeration.  
  - **Mitigation:** Codes are generated using `SecureRandom.random_number` combined with Base62 encoding, ensuring randomness and non-sequential patterns.
 
  **SQL Injection:**
  - Unsanitized inputs could compromise the database.  
  - **Mitigation:** Rails’ ActiveRecord ORM uses parameterized queries by default.  

---

### 🌐 Network & API Security
 **Rate Limiting & Abuse:**
 - Attackers could spam `/encode` with mass requests.  
 - **Mitigation (recommended):** Use middleware like `rack-attack` to throttle repeated requests per IP or API key. For stronger protection against automated abuse, add CAPTCHA, authentication.
 
 **Denial of Service (DoS / DDoS):**
 - High traffic—especially to the `/decode` endpoint—could overwhelm the database or server resources.  
 - **Mitigation:** Use load balancing, and rate limiting to distribute requests and protect backend services from overload. 

 **Open Redirects:**
 - Redirecting users to malicious links could harm trust.  
 - **Mitigation:** Only valid and stored URLs are returned; no direct redirects are currently performed by the API.
   When implementing redirection in the future, clearly identify redirect destinations, warn users, or show preview pages before proceeding to external sites.

 **Transport Security:**
 - Data (URLs) could be intercepted over the network.  
 - **Mitigation:** Enforce HTTPS in production via Rails’ `config.force_ssl = true`.

---

### 🧩 Future Hardening
- **Authentication & API Keys:** Introduce API tokens for authenticated shortening.  
- **URL Reputation Checking:** Integrate services (like Google Safe Browsing) to block known phishing or malicious URLs.  
- **Encrypted Analytics:** When adding click tracking, ensure sensitive data is anonymized or encrypted at rest.

