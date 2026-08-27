-- Creating Customers Table
create table customers(
	customer_id VARCHAR(100) PRIMARY KEY,
	customer_unique_id VARCHAR(100),
	customer_zip_code_prefix  VARCHAR(10),
	customer_city VARCHAR(50),
	customer_state VARCHAR(5)
);

-- Creating Orders Table
create table orders(
	order_id VARCHAR(100) PRIMARY KEY,
	customer_id VARCHAR(100) REFERENCES customers(customer_id),
	order_status VARCHAR(50),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

-- Creating Sellers Table
create table sellers(
	seller_id VARCHAR(100) PRIMARY KEY,
	seller_zip_code_prefix VARCHAR(10),
	seller_city VARCHAR(50),
	seller_state VARCHAR(5)
);


-- Creating Products Table
create table products(
	product_id VARCHAR(100) PRIMARY KEY,
	product_category_name VARCHAR(200),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

-- Creating Orders_items Table
create table order_items(
	order_id VARCHAR(100) REFERENCES orders(order_id),
	order_item_id INT,
	product_id VARCHAR(100) REFERENCES products(product_id),
	seller_id VARCHAR(100) REFERENCES sellers(seller_id), 
	shipping_limit_date TIMESTAMP,
	price NUMERIC(10,2),
	freight_value NUMERIC(10,2),
	PRIMARY KEY(order_id,order_item_id)
);

-- Creating Payments Table
create table payments(
	order_id VARCHAR(100) REFERENCES orders(order_id),
	payment_sequential INT,
	payment_type VARCHAR(30),
	payment_installments INT,
	payment_value NUMERIC(10,2),
	PRIMARY KEY(order_id,payment_sequential)
);

-- Creating Reviews Table
create table reviews(
	review_id VARCHAR(100),
	order_id VARCHAR(100) REFERENCES orders(order_id),
	review_score INT,
	review_comment_title TEXT,
	review_comment_message TEXT,
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP,
	PRIMARY KEY(review_id,order_id)
);

-- Creating Product Category Table
create table product_category(
	product_category_name VARCHAR(100) PRIMARY KEY,
	product_Category_name_english VARCHAR(100)
);

-- Creating Geolocation Table
create table geolocation(
	geolocation_id SERIAL PRIMARY KEY,
	geolocation_zip_code_prefix INT,
	geolocation_lat NUMERIC(9,6),
	geolocation_lng NUMERIC(9,6),
	geolocation_city VARCHAR(50),
	geolocation_state VARCHAR(5)
);