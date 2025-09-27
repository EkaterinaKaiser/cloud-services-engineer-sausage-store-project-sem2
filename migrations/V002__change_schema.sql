ALTER TABLE product ADD CONSTRAINT pk_product PRIMARY KEY (id);
ALTER TABLE orders ADD CONSTRAINT pk_orders PRIMARY KEY (id);

ALTER TABLE product ADD COLUMN price double precision;

UPDATE product SET price = pi.price 
FROM product_info pi 
WHERE product.id = pi.product_id;

ALTER TABLE orders ADD COLUMN date_created timestamp DEFAULT current_timestamp;

UPDATE orders SET date_created = od.date_created 
FROM orders_date od 
WHERE orders.id = od.order_id;

ALTER TABLE order_product ADD CONSTRAINT pk_order_product PRIMARY KEY (order_id, product_id);

ALTER TABLE order_product 
ADD CONSTRAINT fk_order_product_order_id 
FOREIGN KEY (order_id) REFERENCES orders(id);

ALTER TABLE order_product 
ADD CONSTRAINT fk_order_product_product_id 
FOREIGN KEY (product_id) REFERENCES product(id);

CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date_created ON orders(date_created);
CREATE INDEX idx_order_product_order_id ON order_product(order_id);
CREATE INDEX idx_order_product_product_id ON order_product(product_id);
CREATE INDEX idx_product_name ON product(name);

DROP TABLE product_info;
DROP TABLE orders_date;