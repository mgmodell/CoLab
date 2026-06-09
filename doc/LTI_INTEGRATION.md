# LTI 1.3 Integration Guide

This guide explains how to connect CoLab to an LTI 1.3–compatible Learning Management
System (LMS) such as Moodle, Canvas, Blackboard, or Brightspace.

---

## Overview

CoLab acts as an **LTI 1.3 Tool** (the external application). The LMS is the
**Platform** (the host that embeds CoLab activities). The integration supports:

| Feature | LTI Specification |
|---|---|
| Single sign-on via LMS login | LTI 1.3 Core – OIDC Launch |
| Roster import from LMS | Names and Role Provisioning Services (NRPS) |
| Grade push back to LMS gradebook | Assignment and Grade Services (AGS) |

CoLab's LTI endpoints (replace `https://colab.example.com` with your actual hostname):

| Purpose | URL |
|---|---|
| Dynamic Registration | `https://colab.example.com/lti/tool_connect` |
| OIDC Login Initiation | `https://colab.example.com/lti/login` |
| LTI Launch (receives id_token) | `https://colab.example.com/lti/launch` |
| Public JWK Set | `https://colab.example.com/.well-known/jwks.json` |

---

## Prerequisites

* A running CoLab deployment with HTTPS enabled (LTI 1.3 requires a secure origin).
* Administrator access to the LMS.
* The `LOCKBOX_MASTER_KEY` environment variable set in CoLab (required by the `keypairs`
  gem to store the signing keypair securely at rest).

---

## Connecting via Dynamic Registration (recommended)

LTI Dynamic Registration automates exchanging configuration between CoLab and the
platform.

### Moodle (≥ 4.0)

1. Log in to Moodle as an administrator.
2. Go to **Site administration → Plugins → Activity modules → External tool →
   Manage tools**.
3. Click **Configure a tool manually** and then choose **Tool URL** mode, or use the
   **Dynamic Registration** tab if your Moodle version supports it.
4. In the **Tool URL** field enter:
   ```
   https://colab.example.com/lti/tool_connect
   ```
5. Moodle will POST to that URL with an `openid_configuration` parameter pointing to
   Moodle's own OpenID configuration document.
6. CoLab fetches Moodle's configuration, registers itself, and returns a JSON tool
   configuration. Moodle stores `client_id` and all endpoint URLs automatically.
7. After successful registration, the tool will appear in **Manage tools** with a
   status of **Active**.

> **Note:** If Moodle passes a `registration_token` in the request, CoLab forwards it
> as an Authorization header when posting the tool config back, so no extra steps are
> needed.

### Canvas

1. Log in to Canvas as an administrator.
2. Go to **Admin → Developer Keys** and click **+ Developer Key → + LTI Key**.
3. Choose **Enter URL** and supply:
   ```
   https://colab.example.com/lti/tool_connect
   ```
4. Canvas fetches the JSON configuration from CoLab and pre-fills all fields.
5. Toggle the key to **ON** and note the **Client ID** generated.
6. Go to **Admin → Settings → Apps → View App Configurations → + App** and add the
   key using **Client ID** mode, pasting the Canvas-generated Client ID.

---

## Connecting via Manual Registration

Use manual registration when your LMS does not support Dynamic Registration or when
you need fine-grained control over the tool configuration.

### Required values to enter in the LMS

| Field | Value |
|---|---|
| Tool / Launch URL | `https://colab.example.com/lti/launch` |
| Login Initiation URL | `https://colab.example.com/lti/login` |
| JWKS URL (public keyset) | `https://colab.example.com/.well-known/jwks.json` |
| Redirect URI | `https://colab.example.com/lti/launch` |
| Token endpoint auth method | `private_key_jwt` |
| Supported scopes | `https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly` `https://purl.imsglobal.org/spec/lti-ags/scope/lineitem` `https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly` `https://purl.imsglobal.org/spec/lti-ags/scope/score` |

After the LMS creates the registration it will give you a **Client ID** (and sometimes
an **Issuer** / `iss`). You must persist these in CoLab by creating an `LtiDeployment`
record (via the Rails console or a future admin UI):

```ruby
LtiDeployment.create!(
  issuer:         'https://your-moodle.example.com',   # LMS issuer URL
  client_id:      'CLIENT_ID_FROM_LMS',
  auth_login_url: 'https://your-moodle.example.com/mod/lti/auth.php',
  auth_token_url: 'https://your-moodle.example.com/mod/lti/token.php',
  key_set_url:    'https://your-moodle.example.com/mod/lti/certs.php',
  tool_url:       'https://colab.example.com'
)
```

Typical Moodle endpoint paths:

| Endpoint | Path |
|---|---|
| Authorization | `/mod/lti/auth.php` |
| Token | `/mod/lti/token.php` |
| JWKS / Certs | `/mod/lti/certs.php` |

---

## Launch Flow (OIDC)

Once registration is complete, the typical launch sequence is:

```
User clicks CoLab link in LMS
  → LMS: GET  https://colab.example.com/lti/login?iss=…&login_hint=…&client_id=…
  ← CoLab: 302  https://<lms>/auth?response_type=id_token&state=…&nonce=…
  → LMS: POST https://colab.example.com/lti/launch  (body: id_token=<signed JWT>)
  ← CoLab: signs in the user, redirects to course or assignment
```

CoLab automatically:
* Validates the JWT signature against the platform's public JWK Set.
* Checks `nonce` and `state` to prevent replay attacks.
* Creates a CoLab user account if none exists for the email in the JWT.
* Enrolls the user as **Instructor** or **Student** based on the LTI role claims.

---

## Linking a Resource Link to a Course or Assignment

After the first launch from a specific LMS activity (resource link), CoLab creates an
`LtiResourceLink` record automatically from the JWT claims. To associate that link
with a specific CoLab course or assignment, update the record (via Rails console or a
future admin UI):

```ruby
link = LtiResourceLink.find_by(resource_link_id: 'RESOURCE_LINK_ID_FROM_LMS')

# Associate with a course
link.update!(course: Course.find(COURSE_ID))

# Or associate with a specific assignment
link.update!(assignment: Assignment.find(ASSIGNMENT_ID))
```

Once associated:
* Roster syncs via NRPS populate the linked course.
* Grade pushes via AGS write back to the LMS gradebook line item that was set up when
  the activity was configured.

---

## Roster Sync (NRPS)

Trigger a roster sync for a resource link from a controller, job, or Rails console:

```ruby
link = LtiResourceLink.find(RESOURCE_LINK_ID)

# CoLab requests an access token and fetches the member list from the LMS
response = Net::HTTP.post(
  URI("https://colab.example.com/lti/names_roles/#{link.id}"),
  '',
  'Content-Type' => 'application/json'
)
puts JSON.parse(response.body)
# => { "synced_count" => 30, "members_received" => 30 }
```

Or call the service internally:
```ruby
# via Rails console
link = LtiResourceLink.find(RESOURCE_LINK_ID)
deployment = link.lti_deployment
token = deployment.request_access_token(
  scopes: ['https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly']
)
# … fetch and process members
```

---

## Grade Push (AGS)

Once an assignment linked to a resource link has graded submissions, push grades back
to the LMS by POSTing to:

```
POST https://colab.example.com/lti/grades/:resource_link_id
```

CoLab reads all submissions with a `recorded_score`, requests an AGS access token from
the LMS, and posts each score to the line item URL stored on the resource link.

---

## Testing the Integration

Use the **Saltire LTI Reference Implementation** (`https://saltire.lti.app/`) to test
all endpoints without a full LMS:

1. Open <https://saltire.lti.app/platform>.
2. Under **Tool**, set **Launch URL** to `https://colab.example.com/lti/launch` and
   **Login URL** to `https://colab.example.com/lti/login`.
3. Set **Public JWK Set URL** to `https://colab.example.com/.well-known/jwks.json`.
4. Run the **Core launch** test, then the **NRPS** and **AGS** tests.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Unknown issuer or client_id` at login | No `LtiDeployment` for the platform | Create the record (see Manual Registration above) |
| `State mismatch` at launch | Session expired between login and launch | Ensure cookies / sessions are working; check load-balancer sticky-session config |
| `Nonce mismatch` at launch | Replay or session loss | Same as above |
| `Invalid JWT` | Stale or wrong platform keys | Confirm `key_set_url` is correct and reachable from CoLab |
| AGS returns 401 | Wrong scopes requested | Confirm the LMS granted AGS scopes during registration |
| Grade push: 0 pushed | Submissions have no `recorded_score` | Ensure assignments have been graded in CoLab before pushing |
