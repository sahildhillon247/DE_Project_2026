# Problem Understanding

## P1: Slow Property Search

- **Business Need:** Users should be able to search for rental and sale properties quickly using filters such as price, price per sq. ft., location and amenities.
- **Stakeholders:** Home seekers (tenants and buyers), Search team.
- **Category:** Customer-facing / Real-time.
- **Assumption:** Search results should be returned quickly even when users apply multiple filters.

## P2: Slow Property and Project Pages

- **Business Need:** Property and project pages, including RERA-related information, should load quickly so users can access listing details without delays.
- **Stakeholders:** Home seekers, property owners, agents, builders and Listings team.
- **Category:** Customer-facing / Real-time.
- **Assumption:** Property and project information should be easily accessible and RERA details should be available when provided.

## P3: Slow Owner and Agent Dashboards

- **Business Need:** Owners and agents need responsive dashboards to manage site visits, track price changes and update property listing statuses efficiently.
- **Stakeholders:** Property owners, agents and Listings team.
- **Category:** Customer-facing / Real-time.
- **Assumption:** Only authorised users should be able to manage their respective property listings and related activities.

## P4: Delayed Alerts and Follow-ups

- **Business Need:** The platform should generate timely alerts for price drops, leads without site visits and stale property listings.
- **Stakeholders:** Home seekers, property owners, agents and Engagement team.
- **Category:** Real-time / Background processing.
- **Assumption:** Alerts and follow-ups should be processed at least once every hour.

## P5: Missing Builder Partnership Insights

- **Business Need:** The Builder Partnerships team needs to identify projects that have no property listings so they can find potential partnership opportunities.
- **Stakeholders:** Builders and Builder Partnerships team.
- **Category:** Reporting / Analytics.
- **Assumption:** Projects with no associated property listings should be identifiable through the database.

## P6: Slow Business Insights and Analytics

- **Business Need:** The platform needs to generate insights such as price trends, rental yields, agent leaderboards, site-visit ratings and conversion funnels.
- **Stakeholders:** Management, agents, investors and Insights team.
- **Category:** Reporting / Analytics.
- **Assumption:** Historical property, price-change, enquiry and site-visit data can be used to generate these reports.

## P7: Slow Trust, Safety and Platform Reports

- **Business Need:** Trust and Safety teams need efficient reports to monitor platform activity, while the database must support future growth in property listings.
- **Stakeholders:** Trust and Safety team, Platform team, property owners and home seekers.
- **Category:** Reporting / Analytics.
- **Assumption:** The platform should be designed to handle a projected 20× growth in property listings without major performance issues.

## General Assumptions

1. Each property has a unique property ID.
2. A property listing is associated with a user who listed it.
3. A property may belong to a project, but standalone properties may not have a project.
4. Properties, projects, users, enquiries and site visits are stored as related records.
5. Historical price changes are maintained to support price-trend analysis.
6. The database should maintain data integrity through appropriate primary keys, foreign keys and constraints.
