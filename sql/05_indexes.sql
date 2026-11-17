-- ============================================================
-- CP3: Housing.com Query Optimization - Indexes
-- PostgreSQL 18.6
-- ============================================================

SET search_path TO housing;

-- R01: Active rental search
CREATE INDEX IF NOT EXISTS idx_properties_rent_search
ON properties (locality_id, bhk, price)
WHERE listing_type = 'RENT' AND status = 'ACTIVE';

-- R02: Active sale apartment search
CREATE INDEX IF NOT EXISTS idx_properties_sale_search
ON properties (locality_id, bhk, price)
WHERE listing_type = 'SALE'
  AND status = 'ACTIVE'
  AND property_type = 'APARTMENT';

-- R04, R15, R19, R21, R25: Locality-based property queries
CREATE INDEX IF NOT EXISTS idx_properties_locality_listing_status
ON properties (locality_id, listing_type, status);

-- R06, W02, W05: Owner dashboard and owner listing updates
CREATE INDEX IF NOT EXISTS idx_properties_owner_status_type
ON properties (listed_by, status, listing_type);

-- R07: Agent's properties
CREATE INDEX IF NOT EXISTS idx_properties_listed_by
ON properties (listed_by);

-- R09, R11: Project property filtering
CREATE INDEX IF NOT EXISTS idx_properties_project_status_price
ON properties (project_id, status, price);

-- R12, R19, R25: Enquiry lookup by property and user
CREATE INDEX IF NOT EXISTS idx_enquiries_property_user
ON enquiries (property_id, user_id);

-- R12: Date-based enquiry search
CREATE INDEX IF NOT EXISTS idx_enquiries_created_at
ON enquiries (created_at);

-- R17: Find properties without enquiries
CREATE INDEX IF NOT EXISTS idx_enquiries_property_id
ON enquiries (property_id);

-- R06, R07, R12: Site visit lookups
CREATE INDEX IF NOT EXISTS idx_site_visits_property_user
ON site_visits (property_id, user_id);

-- R07: Date-based site visit lookup
CREATE INDEX IF NOT EXISTS idx_site_visits_scheduled_at
ON site_visits (scheduled_at);

-- R08: Price change date filtering
CREATE INDEX IF NOT EXISTS idx_price_changes_changed_at
ON price_changes (changed_at, property_id);

-- R09: Reverse lookup of project amenities
CREATE INDEX IF NOT EXISTS idx_project_amenities_amenity_project
ON project_amenities (amenity_id, project_id);

-- R17: Active old listings
CREATE INDEX IF NOT EXISTS idx_properties_active_posted_at
ON properties (posted_at)
WHERE status = 'ACTIVE';

-- R20: Date-based listing growth report
CREATE INDEX IF NOT EXISTS idx_properties_posted_at
ON properties (posted_at);

-- R22: Newest listings pagination
CREATE INDEX IF NOT EXISTS idx_properties_posted_at_desc
ON properties (posted_at DESC);

-- R23: Mobile number sign-in
CREATE INDEX IF NOT EXISTS idx_users_phone
ON users (phone);

-- R24: Under-construction projects and possession date
CREATE INDEX IF NOT EXISTS idx_projects_possession
ON projects (possession_status, possession_date);

ANALYZE;
