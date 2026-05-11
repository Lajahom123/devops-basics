# Use private PostgreSQL networking

# Context

The application stores deployment data in PostgreSQL. A public database endpoint with IP firewall rules is simple, but it increases exposure and encourages ad hoc local administration patterns.

# Decision

Deploy Azure Database for PostgreSQL Flexible Server with public network access disabled. Place it in a delegated subnet, link a private DNS zone to the VNet, and connect App Service through regional VNet integration.

# Consequences

Benefits:

- PostgreSQL is not publicly routable;
- access requires private network reachability;
- App Service-to-database traffic stays on the private Azure network path;
- firewall drift from developer IPs is avoided.

Drawbacks and operational impact:

- local laptops cannot connect directly;
- DNS and routing become operational dependencies;
- database administration requires a private access path such as a jump host, VPN, or private runner;
- deployment and migration workflows must account for private network reachability.
