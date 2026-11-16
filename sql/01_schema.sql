
CREATE SCHEMA IF NOT EXISTS housing;

SET search_path TO housing;

CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL
);

CREATE TABLE localities (
    locality_id INT PRIMARY KEY,
    city_id INT NOT NULL REFERENCES cities(city_id),
    locality_name VARCHAR(150) NOT NULL,
    pincode VARCHAR(10),
    center_lat NUMERIC(10,7),
    center_lng NUMERIC(10,7)
);

CREATE TABLE builders (
    builder_id INT PRIMARY KEY,
    builder_name VARCHAR(150) NOT NULL,
    founded_year INT
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    builder_id INT REFERENCES builders(builder_id),
    locality_id INT NOT NULL REFERENCES localities(locality_id),
    project_name VARCHAR(200) NOT NULL,
    rera_id VARCHAR(100) UNIQUE,
    possession_status VARCHAR(50),
    possession_date DATE,
    total_units INT CHECK (total_units > 0)
);

CREATE TABLE amenities (
    amenity_id INT PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE project_amenities (
    project_id INT NOT NULL REFERENCES projects(project_id),
    amenity_id INT NOT NULL REFERENCES amenities(amenity_id),
    PRIMARY KEY (project_id, amenity_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    user_type VARCHAR(30) NOT NULL,
    agent_rera_id VARCHAR(100),
    created_at TIMESTAMPTZ
);



CREATE TABLE properties (
    property_id INT PRIMARY KEY,
    listed_by INT NOT NULL REFERENCES users(user_id),
    project_id INT REFERENCES projects(project_id),
    locality_id INT NOT NULL REFERENCES localities(locality_id),

    listing_type VARCHAR(30) NOT NULL
        CHECK (listing_type IN ('RENT', 'SALE')),

    property_type VARCHAR(50) NOT NULL
        CHECK (property_type IN ('APARTMENT', 'INDEPENDENT_HOUSE', 'PLOT', 'VILLA')),

    bhk INT
        CHECK (bhk IS NULL OR bhk BETWEEN 1 AND 5),

    carpet_area_sqft NUMERIC(10,2) NOT NULL
        CHECK (carpet_area_sqft > 0),

    floor_no INT
        CHECK (floor_no IS NULL OR floor_no >= 0),

    total_floors INT
        CHECK (total_floors IS NULL OR total_floors >= 1),

    furnishing VARCHAR(50)
        CHECK (furnishing IN ('FULLY_FURNISHED', 'SEMI_FURNISHED', 'UNFURNISHED')),

    facing VARCHAR(50)
        CHECK (facing IN ('EAST', 'NORTH', 'NORTH_EAST', 'NORTH_WEST',
                          'SOUTH', 'SOUTH_EAST', 'SOUTH_WEST', 'WEST')),

    price NUMERIC(12,2) NOT NULL
        CHECK (price > 0),

    maintenance_monthly NUMERIC(12,2)
        CHECK (maintenance_monthly >= 0),

    security_deposit NUMERIC(12,2)
        CHECK (security_deposit >= 0),

    available_from DATE,

    latitude NUMERIC(10,7)
        CHECK (latitude BETWEEN -90 AND 90),

    longitude NUMERIC(10,7)
        CHECK (longitude BETWEEN -180 AND 180),

    is_verified BOOLEAN,

    status VARCHAR(50) NOT NULL
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'RENTED', 'SOLD')),

    posted_at TIMESTAMPTZ,

    CHECK (floor_no IS NULL OR total_floors IS NULL OR floor_no <= total_floors),

    CHECK (property_type <> 'PLOT' OR bhk IS NULL)
);




CREATE TABLE price_changes (
    change_id INT PRIMARY KEY,
    property_id INT NOT NULL REFERENCES properties(property_id),
    old_price NUMERIC(12,2),
    new_price NUMERIC(12,2),
    changed_at TIMESTAMPTZ
);



CREATE TABLE enquiries (
    enquiry_id INT PRIMARY KEY,
    property_id INT NOT NULL REFERENCES properties(property_id),
    user_id INT NOT NULL REFERENCES users(user_id),
    channel VARCHAR(50),
    message TEXT,
    created_at TIMESTAMPTZ
);



CREATE TABLE site_visits (
    visit_id INT PRIMARY KEY,
    property_id INT NOT NULL REFERENCES properties(property_id),
    user_id INT NOT NULL REFERENCES users(user_id),
    scheduled_at TIMESTAMPTZ,
    status VARCHAR(50),
    feedback_rating INT CHECK (feedback_rating BETWEEN 1 AND 5)
);



CREATE TABLE shortlists (
    user_id INT NOT NULL REFERENCES users(user_id),
    property_id INT NOT NULL REFERENCES properties(property_id),
    added_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, property_id)
);
