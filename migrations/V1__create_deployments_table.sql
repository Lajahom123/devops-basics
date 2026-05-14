CREATE TABLE deployments (
  id UUID PRIMARY KEY,
  service TEXT NOT NULL,
  version TEXT NOT NULL,
  environment TEXT NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);