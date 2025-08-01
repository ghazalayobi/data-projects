# 📄 Silver Layer Table Documentation

This document describes how data is transformed from the `bronze` layer to the `silver` layer for selected tables.

---

## 🧾 General Notes

- **Goal**: Clean and standardize raw data for analytics-ready use.
- **Applies To**: All `silver` tables.
- **Standard Cleaning Includes**:
  - Removing invalid characters from city/state names.
  - Normalizing capitalization and whitespace.
  - Replacing numeric-only or invalid city names with `'unknown'`.
  - Correcting known city name exceptions.
  - Adding `dwh_create_date` to track when data is loaded.

---

## 🗺️ Table: `silver.geolocation`

**Source Table**: `bronze.olist_geolocation_dataset`

| Column            | Transformation |
|-------------------|----------------|
| `zip_code_prefix` | Direct mapping. |
| `lat` / `lng`     | Direct mapping. |
| `city`            | - Trimmed and cleaned.<br>- Special case: `'4o centenario'` → `'4º centenario'`.<br>- Remove `*`, `.` characters.<br>- Convert to lowercase and remove accents. |
| `state`           | Convert to uppercase and trim whitespace. |
| `dwh_create_date` | Set to `CURRENT_TIMESTAMP`. |

---

## 👤 Table: `silver.customers`

**Source Table**: `bronze.olist_customers_dataset`

| Column             | Transformation |
|--------------------|----------------|
| `customer_id` / `customer_unique_id` | Direct mapping. |
| `zip_code_prefix`  | Converted to 5-digit format using `LPAD(zip_code_prefix::text, 5, '0')`. |
| `city` | If only numbers or whitespace → `'unknown'`.<br>Special case: `'sp'` with `state = 'SP'` → `'sao paulo'`.<br>Special case: `'4o centenario'` → `'4º centenario'`.<br>Remove everything after `/` or `\` using `regexp_replace(city, '[\\/].*$', '')`.<br>Trim, lowercase, remove special characters (`[^a-z\\s]`), collapse multiple spaces (`\\s+` → `' '`), and unaccent. |
| `state`            | Uppercase and trim whitespace. |
| `dwh_create_date`  | Set to `CURRENT_TIMESTAMP`. |
---

## 🧑‍💼 Table: `silver.sellers`

**Source Table**: `bronze.olist_sellers_dataset`

| Column            | Transformation |
|-------------------|----------------|
| `seller_id`       | Direct mapping. |
| `zip_code_prefix` | Standardized using `LPAD(zip_code_prefix::text, 5, '0')`. |
| `city`            | - If only numbers or whitespace → `'unknown'`.<br>- Special case: `'4o centenario'` → `'4º centenario'`.<br>- Remove everything after `/` or `\` using `regexp_replace(city, '[\\/].*$', '')`.<br>- Trim, lowercase, remove special characters (`[^a-z\s]`), collapse multiple spaces, and unaccent. |
| `state`           | Uppercase and trim whitespace. |
| `dwh_create_date` | Set to `CURRENT_TIMESTAMP`. |

---

## 🛠️ Notes for Developers

- Use `regexp_replace(..., '[\\/].*$', '')` to remove backslash `/` or `\` and everything after it.
- Use `~ '^[0-9\s]+$'` to detect cities that are only numbers or whitespace.
- Ensure `unaccent()` is applied after all regex cleanups.
- Maintain consistency between city cleaning logic across tables.
