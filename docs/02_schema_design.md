# Schema Design – Housing Property Search Database

## 1. Overview

The Housing Property Search Database is designed to store and manage information related to cities, localities, builders, housing projects, property listings, users, enquiries, site visits and shortlists.

The database uses a relational model with primary keys and foreign keys to maintain relationships between different entities and ensure data consistency.

The schema is implemented using PostgreSQL.

## 2. Tables and Their Purpose

The database consists of the following 12 tables:

| Table Name | Purpose |
|---|---|
| cities | Stores city names and their states. |
| localities | Stores localities belonging to different cities. |
| builders | Stores information about property builders. |
| projects | Stores housing project details and connects them with builders and localities. |
| amenities | Stores available amenities such as facilities offered in projects. |
| project_amenities | Connects projects with their respective amenities. |
| users | Stores details of users, agents and other platform participants. |
| properties | Stores property listings, including price, area, type and location details. |
| price_changes | Maintains the price change history of properties. |
| enquiries | Stores enquiries made by users about properties. |
| site_visits | Stores scheduled property visits and feedback. |
| shortlists | Stores properties saved by users. |

## 3. Primary Keys

Each main entity has a primary key to uniquely identify its records.

- cities: city_id
- localities: locality_id
- builders: builder_id
- projects: project_id
- amenities: amenity_id
- users: user_id
- properties: property_id
- price_changes: change_id
- enquiries: enquiry_id
- site_visits: visit_id

Two junction tables use composite primary keys:

- project_amenities: (project_id, amenity_id)
- shortlists: (user_id, property_id)

These composite keys prevent duplicate project-amenity combinations and duplicate user-property shortlists.

## 4. Foreign Keys and Relationships

The database contains the following relationships:

1. Cities and Localities (One-to-Many):
   - One city can contain multiple localities.
   - Each locality belongs to one city.
   - Foreign key: city_id in localities.

2. Localities and Projects (One-to-Many):
   - One locality can contain multiple projects.
   - Each project belongs to one locality.
   - Foreign key: locality_id in projects.

3. Builders and Projects (One-to-Many):
   - One builder can develop multiple projects.
   - A project can reference a builder.
   - Foreign key: builder