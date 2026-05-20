# Use App Service deployment slots

# Context

Updating the production Web App container image directly gives little room to verify startup, health, and version before users hit the new release. The project also runs migrations before deploying application code, so deployment needs a clear promotion point after database changes succeed.

# Decision

Deploy new application images to the App Service `staging` slot, verify `/health` and `/version`, then swap the staging slot into production. Keep a manual rollback workflow that swaps the slots back.

# Consequences

Benefits:

- production is not updated until staging health checks pass;
- rollback can be performed with a slot swap;
- release verification is explicit in GitHub Actions;
- the deployment flow more closely matches production App Service practices.

Drawbacks and operational impact:

- staging must remain configured like production for verification to be meaningful;
- slot-specific settings must be managed carefully;
- rollback only helps if staging still contains the previous known-good production version;
- schema migrations that are not backward compatible can still make rollback unsafe.
