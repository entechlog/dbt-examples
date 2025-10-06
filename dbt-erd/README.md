# dbt-model-erd Example

A comprehensive example demonstrating how to use [dbt-model-erd](https://github.com/entechlog/dbt-model-erd) to automatically generate Entity Relationship Diagrams (ERDs) for your dbt models.

## 📋 What This Example Demonstrates

This example showcases:

- **Automatic ERD Generation**: Generate interactive ERD diagrams from dbt model relationships
- **Best Practices**: Follow standard data warehouse patterns (staging → prep → dw layers)
- **Real-World Schema**: E-commerce data model with customers, products, orders, and sales
- **Relationship Detection**: Automatically detect fact-dimension relationships using `ref()` statements
- **Interactive Diagrams**: View diagrams as interactive HTML files using Mermaid.js

## 🏗️ Project Structure

```
dbt-erd/
├── models/
│   ├── prep/                    # Staging/preparation layer
│   │   ├── dim/
│   │   │   ├── prep__dim_customer.sql
│   │   │   └── prep__dim_product.sql
│   │   └── fact/
│   │       └── prep__fact_order_items.sql
│   └── dw/                      # Data warehouse layer
│       ├── dim/
│       │   ├── dim_customer.sql
│       │   ├── dim_product.sql
│       │   ├── dim_date.sql     # Generated using date spine
│       │   └── schema.yml
│       └── fact/
│           ├── fact_orders.sql  # Aggregated from order items
│           ├── fact_sales.sql   # Line-item level sales
│           └── schema.yml
├── seeds/
│   ├── seed_customers.csv
│   ├── seed_products.csv
│   └── seed_order_items.csv
├── assets/img/                  # Generated ERD diagrams
└── dbt_project.yml
```

## 🎯 Data Model Overview

### Dimension Tables
- **dim_customer**: Customer master data with segments (Standard, Premium, VIP)
- **dim_product**: Product catalog with pricing, costs, and margin calculations
- **dim_date**: Date dimension from 1900-2100 generated using date spine logic

### Fact Tables
- **fact_orders**: Order-level aggregations (order totals, discounts, item counts)
- **fact_sales**: Line-item level sales with profit analysis

## 🚀 Quick Start (One Command!)

### Prerequisites
- [Docker](https://www.docker.com/get-started) installed (that's it!)

### Run Everything

```bash
# Clone the repo
git clone https://github.com/entechlog/dbt-examples.git
cd dbt-examples/dbt-erd

# Start the demo (builds, runs models, generates docs & ERDs, serves docs)
docker-compose up
```

That's it! The container will automatically:
1. ✓ Install dbt packages
2. ✓ Load seed data (customers, products, orders)
3. ✓ Run all dbt models (prep → dw layers)
4. ✓ Run dbt tests
5. ✓ Generate ERD diagrams
6. ✓ Generate dbt documentation
7. ✓ Start dbt docs server on http://localhost:8080

### View the Results

**dbt Documentation**
- Open http://localhost:8080 in your browser
- Explore lineage graph, model definitions, and column descriptions

**ERD Diagrams**
- Open `assets/img/models/dw/fact/fact_orders_model.html`
- Open `assets/img/models/dw/fact/fact_sales_model.html`
- View relationships between fact and dimension tables

### Stop the Demo

```bash
# Press Ctrl+C in the terminal, then:
docker-compose down
```

## 📊 Example ERD Diagrams

### fact_sales ERD
Shows relationships between:
- `dim_date` → `fact_sales` (via sale_date_id)
- `dim_product` → `fact_sales` (via product_id)
- `dim_customer` → `fact_sales` (via customer_id)

### fact_orders ERD
Shows relationships between:
- `dim_date` → `fact_orders` (via order_date_id)

## ⚙️ How dbt-model-erd Works

1. **Scans SQL Files**: Parses your dbt models to find `ref()` statements
2. **Reads Schema Files**: Extracts column definitions and relationships from `schema.yml`
3. **Detects Relationships**: Identifies foreign key relationships through:
   - Column naming patterns (e.g., `*_id`, `*_key`)
   - Relationship tests in schema.yml
4. **Generates Mermaid**: Creates Mermaid ER diagrams with proper cardinality
5. **Creates HTML**: Wraps diagrams in interactive HTML with Mermaid.js
6. **Updates Documentation**: Adds diagram links to your schema.yml files

## 🔧 Configuration Options

Create a custom `erd_config.yml`:

```yaml
# Mermaid theme
theme: default  # Options: default, neutral, forest, dark

# Diagram direction
direction: LR  # LR (left-right) or TB (top-bottom)

# Column display
show_all_columns: true
max_columns: 10

# Output paths
output_dir: assets/img
mermaid_extension: .mmd
html_extension: .html
```

## 💡 How It Works

This example uses **DuckDB** - an embedded database that requires no separate installation or server. Everything runs inside Docker:

- **No database setup needed** - DuckDB is file-based (like SQLite)
- **No configuration** - profiles.yml points to local DuckDB file
- **Fully isolated** - Runs in Docker container
- **Real dbt workflow** - Actual seeds, models, tests, docs generation
- **ERD generation** - Automatic relationship detection from schema.yml

## 📦 Key Features Demonstrated

### 1. **Layered Architecture**
- **Prep Layer**: Standardization, deduplication using CTEs
- **DW Layer**: Final dimensional models with business logic

### 2. **Date Dimension Pattern**
```sql
{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('1900-01-01' as date)",
    end_date="cast('2100-12-31' as date)"
) }}
```

### 3. **Surrogate Key Generation**
```sql
{{ dbt_utils.generate_surrogate_key(['customer_key']) }} AS customer_id
```

### 4. **Relationship Tests**
```yaml
- name: product_id
  tests:
    - relationships:
        to: ref('dim_product')
        field: product_id
```

## 🔗 Links & Resources

- **dbt-model-erd Repository**: https://github.com/entechlog/dbt-model-erd
- **Main dbt Examples**: https://github.com/entechlog/dbt-examples
- **dbt Documentation**: https://docs.getdbt.com/
- **Mermaid.js**: https://mermaid.js.org/

## 🎓 What You'll Learn

This example demonstrates:

1. **dbt-model-erd Usage** - How to automatically generate ERDs from dbt models
2. **DuckDB with dbt** - Using an embedded database for local development
3. **Docker Workflows** - One-command setup for reproducible environments
4. **Data Modeling Patterns** - Dimensional modeling (facts & dimensions)
5. **dbt Best Practices** - Layered architecture, testing, documentation

## 📝 Next Steps

1. **Extend the Model**: Add more dimensions (stores, sales reps, regions)
2. **Add More Facts**: Create shipping, inventory, or return fact tables
3. **Customize Diagrams**: Modify erd_config.yml for different themes
4. **Integrate CI/CD**: Add ERD generation to your deployment pipeline
5. **Embed in Docs**: Include diagrams in dbt documentation
6. **Publish to Pages**: Add to your existing GitHub Pages site as a subfolder

## 🤝 Contributing

Found an issue or have a suggestion? Please open an issue in the [dbt-model-erd repository](https://github.com/entechlog/dbt-model-erd/issues).

## 📄 License

This example is part of the dbt-examples repository and follows the same license.

---

**Generated with** ❤️ **using [dbt-model-erd](https://github.com/entechlog/dbt-model-erd)**
